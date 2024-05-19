package com.coffee.backend.domain.match.service;

import com.coffee.backend.domain.chatroom.dto.ChatroomCreationDto;
import com.coffee.backend.domain.chatroom.service.ChatroomService;
import com.coffee.backend.domain.fcm.service.FcmService;
import com.coffee.backend.domain.match.dto.MatchAcceptResponse;
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
import java.util.NoSuchElementException;
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
    private final ChatroomService chatroomService;

    // 매칭 요청
    public MatchDto sendMatchRequest(MatchRequestDto dto) {
        log.trace("sendMatchRequest()");

        validateRequest(dto);
        String lockKey = LOCK_KEY_PREFIX + dto.getSenderId();
        validateLock(lockKey);

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
    public MatchAcceptResponse acceptMatchRequest(MatchIdDto dto) {
        log.trace("acceptMatchRequest()");

        validateIfAlreadyAccepted(dto.getMatchId());
        validateTTL(dto.getMatchId());

        String key = "matchId:" + dto.getMatchId();
        Long senderId = getLongId(redisTemplate.opsForHash().get(key, "senderId"));
        Long receiverId = getLongId(redisTemplate.opsForHash().get(key, "receiverId"));

        ChatroomCreationDto chatroomCreationDto = new ChatroomCreationDto(senderId, receiverId);
        Long chatroomId = chatroomService.createChatroom(chatroomCreationDto);

        redisTemplate.opsForHash().put(key, "status", "accepted");

        Map<String, String> matchInfo = Map.of(
                "senderId", senderId.toString(),
                "receiverId", receiverId.toString(),
                "status", "accepted"
        );
        redisTemplate.opsForHash().putAll(key + "-info", matchInfo);

        // 알림
        User fromUser = userRepository.findByUserId(receiverId).orElseThrow();
        User toUser = userRepository.findByUserId(senderId).orElseThrow();
        fcmService.sendPushMessageTo(toUser.getDeviceToken(), "커피챗 매칭 성공", fromUser.getNickname() + "님과 커피챗이 성사되었습니다.");

        redisTemplate.delete("receiverId:" + receiverId + "-senderId:" + senderId);

        // receiver가 보낸 다른 요청이 있었다면 해당 요청 취소
        Set<String> keys;
        try {
            keys = redisTemplate.keys("receiverId:*-senderId:" + receiverId);
        } catch (NoSuchElementException e) {
            keys = null; // keys를 null로 설정하여 다음 로직으로 이동
        }

        if (keys != null && !keys.isEmpty()) {
            String actualKey = keys.iterator().next(); // 키가 하나만 있다고 가정
            String matchId = (String) redisTemplate.opsForHash().get(actualKey, "matchId");
            if (matchId != null && !matchId.equals(dto.getMatchId())) {
                redisTemplate.delete("matchId:" + matchId);
                redisTemplate.delete(actualKey);
                redisTemplate.delete(LOCK_KEY_PREFIX + receiverId); // 락 해제
            }
        }

        redisTemplate.delete("matchId:" + dto.getMatchId());
        redisTemplate.delete(LOCK_KEY_PREFIX + senderId); // 락 해제

        MatchAcceptResponse match = new MatchAcceptResponse();
        match.setMatchId(dto.getMatchId());
        match.setSenderId(senderId);
        match.setReceiverId(receiverId);
        match.setStatus("accepted");
        match.setChatroomId(chatroomId);

        return match;
    }

    // 이미 수락된 요청인지 검증
    private void validateIfAlreadyAccepted(String matchId) {
        log.trace("validateIfAlreadyAccepted()");

        String status = (String) redisTemplate.opsForHash().get("matchId:" + matchId + "-info", "status");
        if (status != null && status.equals("accepted")) {
            throw new CustomException(ErrorCode.REQUEST_ALREADY_ACCEPTED);
        }
    }

    // 매칭 요청 거절
    public MatchDto declineMatchRequest(MatchIdDto dto) {
        log.trace("declineMatchRequest()");

        validateTTL(dto.getMatchId());

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

        validateTTL(dto.getMatchId());

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
    private void validateTTL(String matchId) {
        log.trace("validateTTL()");

        Long ttl = redisTemplate.getExpire("matchId:" + matchId);
        if (ttl == null || ttl <= 0) {
            throw new CustomException(ErrorCode.REQUEST_EXPIRED);
        }
    }

    // 락 검증
    private void validateLock(String lockKey) {
        log.trace("validateLock()");

        // 이미 락이 걸려 있는 경우 요청 처리 X
        if (redisTemplate.opsForValue().get(lockKey) != null) {
            throw new CustomException(ErrorCode.REQUEST_DUPLICATED);
        }
    }

    // 유저 검증
    private void validateRequest(MatchRequestDto dto) {
        log.trace("validateRequest()");

        // TODO: 향후 테스트 기간 끝나고 주석 해제
//        // 본인에게 요청을 보내는 경우 처리 X
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

        validateFinishMatch(dto.getMatchId());

        String key = "matchId:" + dto.getMatchId() + "-info";
        Long senderId = getLongId(redisTemplate.opsForHash().get(key, "senderId"));
        Long receiverId = getLongId(redisTemplate.opsForHash().get(key, "receiverId"));

        // Case 1: 본인이 종료한 경우
        if (dto.getEnderId().equals(dto.getLoginUserId())) {
            if (dto.getEnderId().equals(senderId)) { // 본인이 매칭 요청을 보낸 경우
                sendMatchFinishNotification(receiverId);
            } else { // 본인이 매칭 요청을 받은 경우
                sendMatchFinishNotification(senderId);
            }
        }
        // Case 2: 상대방이 종료한 경우
        else {
            if (dto.getEnderId().equals(senderId)) { // 상대방이 매칭 요청을 보낸 경우
                sendMatchFinishNotification(senderId);
            } else { // 상대방이 매칭 요청을 받은 경우
                sendMatchFinishNotification(receiverId);
            }
        }

        // 종료로 상태 변경
        redisTemplate.opsForHash().put("matchId:" + dto.getMatchId() + "-info", "status", "finished");

        MatchStatusDto match = new MatchStatusDto();
        match.setMatchId(dto.getMatchId());
        match.setStatus("finished");
        return match;
    }

    private void validateFinishMatch(String matchId) {
        log.trace("validateFinishMatch()");
        Map<Object, Object> matchInfo = redisTemplate.opsForHash().entries("matchId:" + matchId + "-info");
        if (matchInfo.isEmpty()) {
            throw new CustomException(ErrorCode.REQUEST_NOT_FOUND);
        }
        if (matchInfo.get("status").equals("finished")) {
            throw new CustomException(ErrorCode.REQUEST_ALREADY_FINISHED);
        }
    }
  
      private void sendMatchFinishNotification(Long targetUserId) {
        User toUser = userRepository.findByUserId(targetUserId).orElseThrow();
        fcmService.sendPushMessageTo(toUser.getDeviceToken(), "커피챗 매칭 종료",
                toUser.getNickname() + "님과의 커피챗이 종료되었습니다.");
    }

    // 매칭 요청 종료 확인
    public MatchStatusDto isMatching(MatchIdDto dto) {
        log.trace("isMatching()");

        String key = "matchId:" + dto.getMatchId() + "-info";
        String status = (String) redisTemplate.opsForHash().get(key, "status");

        // status가 null이면 수락되지 않은 것
        if (status == null) {
            throw new CustomException(ErrorCode.REQUEST_NOT_ACCEPTED);
        }

        MatchStatusDto response = new MatchStatusDto();
        response.setMatchId(dto.getMatchId());
        response.setStatus(status);
        return response;
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
