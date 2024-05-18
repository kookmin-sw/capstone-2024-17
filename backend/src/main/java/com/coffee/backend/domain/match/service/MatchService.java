package com.coffee.backend.domain.match.service;

import com.coffee.backend.domain.fcm.service.FcmService;
import com.coffee.backend.domain.match.dto.MatchDto;
import com.coffee.backend.domain.match.dto.MatchFinishRequestDto;
import com.coffee.backend.domain.match.dto.MatchIdDto;
import com.coffee.backend.domain.match.dto.MatchInfoResponseDto;
import com.coffee.backend.domain.match.dto.MatchReceivedInfoDto;
import com.coffee.backend.domain.match.dto.MatchRequestDto;
import com.coffee.backend.domain.match.dto.MatchStatusDto;
import com.coffee.backend.domain.match.dto.ReviewDto;
import com.coffee.backend.domain.match.entity.Review;
import com.coffee.backend.domain.match.repository.ReviewRepository;
import com.coffee.backend.domain.user.dto.ReceiverInfoDto;
import com.coffee.backend.domain.user.dto.SenderInfoDto;
import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.domain.user.repository.UserRepository;
import com.coffee.backend.exception.CustomException;
import com.coffee.backend.exception.ErrorCode;
import com.coffee.backend.utils.CustomMapper;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.TimeUnit;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.ModelMapper;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@RequiredArgsConstructor
@Service
@Slf4j
public class MatchService {
    private final RedisTemplate<String, Object> redisTemplate;
    private final FcmService fcmService;
    private final UserRepository userRepository;
    private final ReviewRepository reviewRepository;
    private final ModelMapper mapper;

    private static final String LOCK_KEY_PREFIX = "lock:senderId:";
    private final CustomMapper customMapper;

    // 매칭 요청
    public MatchDto sendMatchRequest(MatchRequestDto dto) {
        log.trace("sendMatchRequest()");

        validateRequest(dto); // 요청 검증

        String lockKey = LOCK_KEY_PREFIX + dto.getSenderId();
        validateLock(lockKey); // 락 검증

        long expirationTime = System.currentTimeMillis() + TimeUnit.MINUTES.toMillis(10);

        String matchId = UUID.randomUUID().toString();
        Map<String, String> matchInfo = Map.of(
                "matchId", matchId,
                "senderId", dto.getSenderId().toString(),
                "receiverId", dto.getReceiverId().toString(),
                "requestTypeId", dto.getRequestTypeId(),
                "expirationTime", String.valueOf(expirationTime),
                "status", "pending"
        );

        // 매칭 요청 저장
        redisTemplate.opsForHash().putAll("matchId:" + matchId, matchInfo);
        redisTemplate.expire("matchId:" + matchId, 600, TimeUnit.SECONDS);

        // 매칭 요청 리스트를 위한 정보 저장
        redisTemplate.opsForHash()
                .putAll("receiverId:" + dto.getReceiverId() + "-senderId:" + dto.getSenderId(), matchInfo);
        redisTemplate.expire("receiverId:" + dto.getReceiverId() + "-senderId:" + dto.getSenderId(), 600,
                TimeUnit.SECONDS);

        // 알림
        User fromUser = userRepository.findByUserId(dto.getSenderId()).orElseThrow();
        User toUser = userRepository.findByUserId(dto.getReceiverId()).orElseThrow();
        fcmService.sendPushMessageTo(toUser.getDeviceToken(), "커피챗 요청", fromUser.getNickname() + "님에게 커피챗 요청이 도착했습니다.");

        // 10분동안 락 설정
        redisTemplate.opsForValue().set(lockKey, "Locked", 600, TimeUnit.SECONDS);

        MatchDto match = mapper.map(dto, MatchDto.class);
        match.setMatchId(matchId);
        match.setStatus("pending");
        match.setExpirationTime(expirationTime);
        return match;
    }

    // 보낸 매칭 요청 정보
    public MatchInfoResponseDto getMatchRequestInfo(Long senderId) {
        log.trace("getMatchRequestInfo()");

        Set<String> keys = redisTemplate.keys("receiverId:*-senderId:" + senderId);
        if (keys.isEmpty()) {
            throw new CustomException(ErrorCode.REQUEST_NOT_FOUND);
        }

        String actualKey = keys.iterator().next(); // 키가 하나만 있다고 가정
        Map<Object, Object> matchInfo = redisTemplate.opsForHash().entries(actualKey);
        if (matchInfo.isEmpty()) {
            throw new CustomException(ErrorCode.REQUEST_NOT_FOUND);
        }

        Long receiverId = getLongId(matchInfo.get("receiverId"));
        User receiver = userRepository.findById(receiverId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        ReceiverInfoDto receiverInfo = mapper.map(receiver, ReceiverInfoDto.class);
        receiverInfo.setCompany(customMapper.toCompanyDto(receiver.getCompany()));

        MatchInfoResponseDto response = mapper.map(matchInfo, MatchInfoResponseDto.class);
        response.setReceiverInfo(receiverInfo);

        return response;
    }

    // 받은 요청 정보
    public List<MatchReceivedInfoDto> getMatchReceivedInfo(Long receiverId) {
        log.trace("getReceivedMatchRequests() for receiverId: {}", receiverId);

        Set<String> keys = redisTemplate.keys("receiverId:" + receiverId + "-senderId:*");
        if (keys == null || keys.isEmpty()) {
            throw new CustomException(ErrorCode.REQUEST_NOT_FOUND);
        }

        List<MatchReceivedInfoDto> requests = new ArrayList<>();
        for (String key : keys) {
            Map<Object, Object> matchInfo = redisTemplate.opsForHash().entries(key);
            String matchId = (String) matchInfo.get("matchId");

            Long senderId = getLongId(matchInfo.get("senderId"));
            User sender = userRepository.findById(senderId)
                    .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
            SenderInfoDto senderInfo = mapper.map(sender, SenderInfoDto.class);
            senderInfo.setCompany(customMapper.toCompanyDto(sender.getCompany()));

            MatchReceivedInfoDto res = new MatchReceivedInfoDto();
            res.setMatchId(matchId);
            res.setRequestTypeId((String) matchInfo.get("requestTypeId"));
            res.setSenderInfo(senderInfo);
            requests.add(res);
        }
        return requests;
    }

    // 매칭 요청 수락
    public MatchDto acceptMatchRequest(MatchIdDto dto) {
        log.trace("acceptMatchRequest()");

        if (!verifyMatchRequest(dto)) {
            throw new CustomException(ErrorCode.REQUEST_EXPIRED);
        }

        String key = "matchId:" + dto.getMatchId();
        redisTemplate.opsForHash().put(key, "status", "accepted");
        redisTemplate.opsForHash().put(key + "-info", "status", "matching");

        Long senderId = getLongId(redisTemplate.opsForHash().get(key, "senderId"));
        Long receiverId = getLongId(redisTemplate.opsForHash().get(key, "receiverId"));

        // 알림
        User fromUser = userRepository.findByUserId(senderId).orElseThrow();
        User toUser = userRepository.findByUserId(senderId).orElseThrow();
        fcmService.sendPushMessageTo(toUser.getDeviceToken(), "커피챗 매칭 성공", fromUser.getNickname() + "님과 커피챗이 성사되었습니다.");

        MatchDto match = new MatchDto();
        match.setMatchId(dto.getMatchId());
        match.setSenderId(senderId);
        match.setReceiverId(receiverId);
        match.setStatus("accepted");

        redisTemplate.delete("receiverId:" + receiverId + "-senderId:" + senderId);

        return match;
    }

    // 매칭 요청 거절
    public MatchDto declineMatchRequest(MatchIdDto dto) {
        log.trace("declineMatchRequest()");

        if (!verifyMatchRequest(dto)) {
            throw new CustomException(ErrorCode.REQUEST_EXPIRED);
        }

        String key = "matchId:" + dto.getMatchId();
        Long senderId = getLongId(redisTemplate.opsForHash().get(key, "senderId"));
        Long receiverId = getLongId(redisTemplate.opsForHash().get(key, "receiverId"));

        // 알림
        User fromUser = userRepository.findByUserId(receiverId).orElseThrow();
        User toUser = userRepository.findByUserId(senderId).orElseThrow();
        fcmService.sendPushMessageTo(toUser.getDeviceToken(), "커피챗 매칭 실패",
                fromUser.getNickname() + "님이 커피챗 요청을 거절하였습니다.");

        redisTemplate.delete(key);
        redisTemplate.delete("receiverId:" + receiverId + "-senderId:" + senderId);
        redisTemplate.delete(LOCK_KEY_PREFIX + senderId); // 락 해제

        MatchDto match = new MatchDto();
        match.setMatchId(dto.getMatchId());
        match.setSenderId(senderId);
        match.setReceiverId(receiverId);
        match.setStatus("declined");
        return match;
    }

    // 매칭 요청 수동 취소
    public MatchDto cancelMatchRequest(MatchIdDto dto) {
        log.trace("cancelMatchRequest()");
        if (!verifyMatchRequest(dto)) {
            throw new CustomException(ErrorCode.REQUEST_EXPIRED);
        }

        String key = "matchId:" + dto.getMatchId();
        Long senderId = getLongId(redisTemplate.opsForHash().get(key, "senderId"));
        Long receiverId = getLongId(redisTemplate.opsForHash().get(key, "receiverId"));

        redisTemplate.delete(key);
        redisTemplate.delete("receiverId:" + receiverId + "-senderId:" + senderId);
        redisTemplate.delete(LOCK_KEY_PREFIX + senderId); // 락 해제

        MatchDto match = new MatchDto();
        match.setMatchId(dto.getMatchId());
        match.setSenderId(senderId);
        match.setReceiverId(receiverId);
        match.setStatus("canceled");
        return match;
    }

    // 매칭 요청 검증
    private boolean verifyMatchRequest(MatchIdDto dto) {
        log.trace("verifyMatchRequest()");
        Long ttl = redisTemplate.getExpire("matchId:" + dto.getMatchId());
        return ttl != null && ttl > 0; // true
    }

    // 락 검증
    private void validateLock(String lockKey) {
        // 이미 락이 걸려 있는 경우 요청 처리 X
        if (redisTemplate.opsForValue().get(lockKey) != null) {
            throw new CustomException(ErrorCode.REQUEST_DUPLICATED);
        }
    }

    // 유저 검증
    private void validateRequest(MatchRequestDto dto) {
        // 본인에게 요청을 보내는 경우 처리 X
//        if (dto.getSenderId().equals(dto.getReceiverId())) {
//            throw new CustomException(ErrorCode.REQUEST_SAME_USER);
//        }
        // 유저 DB에 없는 유저가 보낼 경우 처리 X
        if (!userRepository.existsById(dto.getSenderId())) {
            throw new CustomException(ErrorCode.USER_NOT_FOUND);
        }
    }

    // Object -> Long 타입 변환
    private Long getLongId(Object result) {
        log.trace("getLongId()");

        Long id = null;
        if (result != null) {
            if (result instanceof Number) {
                id = ((Number) result).longValue();
            } else {
                try {
                    id = Long.parseLong(result.toString());
                } catch (NumberFormatException e) {
                    log.trace("변환 에러: {}", e.getMessage());
                }
            }
        }
        return id;
    }

    // 매칭 종료
    public MatchStatusDto finishMatch(MatchFinishRequestDto dto) {
        log.trace("finishMatch()");

        String key = "matchId:" + dto.getMatchId();
        Long senderId = getLongId(redisTemplate.opsForHash().get(key, "senderId"));
        Long receiverId = getLongId(redisTemplate.opsForHash().get(key, "receiverId"));

        if (dto.getEnderId().equals(senderId)) {
            User toUser = userRepository.findByUserId(receiverId).orElseThrow();
            fcmService.sendPushMessageTo(toUser.getDeviceToken(), "커피챗 매칭 종료",
                    toUser.getNickname() + "님과의 커피챗이 종료되었습니다.");
        } else if (dto.getEnderId().equals(receiverId)) {
            User toUser = userRepository.findByUserId(senderId).orElseThrow();
            fcmService.sendPushMessageTo(toUser.getDeviceToken(), "커피챗 매칭 종료",
                    toUser.getNickname() + "님과의 커피챗이 종료되었습니다.");
        }

        redisTemplate.delete("matchId:" + dto.getMatchId() + "-info");

        MatchStatusDto match = new MatchStatusDto();
        match.setMatchId(dto.getMatchId());
        match.setStatus("finished");
        return match;
    }

    // 매칭 요청 종료 확인
    public Boolean isMatching(MatchIdDto dto) {
        log.trace("isMatching()");

        String key = "matchId:" + dto.getMatchId() + "-info";
        Object status = redisTemplate.opsForHash().get(key, "status");
        return status != null; // true
    }

    @Transactional
    public Review saveReview(ReviewDto dto) {
        log.trace("saveReview()");

        if (dto.getRating() < 1 || dto.getRating() > 5) {
            throw new CustomException(ErrorCode.VALUE_ERROR);
        }

        User sender = userRepository.findByUserId(dto.getSenderId()).orElseThrow();
        User receiver = userRepository.findByUserId(dto.getReceiverId()).orElseThrow();

        int numberOfReviews = reviewRepository.countByReceiverUserId(receiver.getUserId());
        double oldCoffeeBean = receiver.getCoffeeBean();

        double standard = 3.0;
        double randomRatio = 0.3 + (1.0 - 0.3) * Math.random(); //0.3 ~ 1.0

        // 기존 평점 + (새로운 평점 - 기준 평점) * 랜덤 반영 비율
        double newCoffeeBean = oldCoffeeBean + (dto.getRating() - standard) * randomRatio;
        double newCoffeeBeanDouble = Double.parseDouble(String.format("%.3f", newCoffeeBean)); // 소수점 3자리까지

        receiver.setCoffeeBean(newCoffeeBeanDouble);
        userRepository.save(receiver);

        Review review = new Review();
        review.setSender(sender);
        review.setReceiver(receiver);
        review.setRating(dto.getRating());
        review.setComment(dto.getComment());
        review.setCreatedAt(new Date());
        reviewRepository.save(review);
        return review;
    }
}
