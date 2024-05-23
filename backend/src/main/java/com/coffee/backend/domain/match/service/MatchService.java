package com.coffee.backend.domain.match.service;

import com.coffee.backend.domain.chatroom.dto.ChatroomCreationDto;
import com.coffee.backend.domain.chatroom.service.ChatroomService;
import com.coffee.backend.domain.fcm.service.FcmService;
import com.coffee.backend.domain.match.dto.IsMatchingDto;
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
import java.util.Objects;
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
    private final ChatroomService chatroomService;
    private final UserRepository userRepository;
    private final ReviewRepository reviewRepository;
    private final ModelMapper mapper;
    private final CustomMapper customMapper;

    private static final String LOCK_KEY_PREFIX = "lock:senderId:";

    // 매칭 요청
    public MatchDto sendMatchRequest(MatchRequestDto dto) {
        log.trace("sendMatchRequest()");

        validateUser(dto);
        String lockKey = LOCK_KEY_PREFIX + dto.getSenderId();
        validateLock(lockKey);

        String matchId = UUID.randomUUID().toString();
        long expirationTime = System.currentTimeMillis() + TimeUnit.MINUTES.toMillis(10);
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

        // 매칭 요청 리스트를 위한 정보 저장
        redisTemplate.opsForHash()
                .putAll("receiverId:" + dto.getReceiverId() + "-senderId:" + dto.getSenderId(), matchInfo);

        // 매칭 중인지 조회 위해 저장
        Map<String, String> isMatchingInfo = Map.of(
                "matchId", matchId,
                "senderId", dto.getSenderId().toString(),
                "receiverId", dto.getReceiverId().toString(),
                "isMatching", "no"
        );

        redisTemplate.opsForHash().putAll("userId:" + dto.getSenderId(), isMatchingInfo);
        redisTemplate.opsForHash().putAll("userId:" + dto.getReceiverId(), isMatchingInfo);

        // 10분동안 락 설정
        Map<String, String> lockInfo = Map.of("matchId", matchId);
        redisTemplate.opsForHash().putAll(lockKey, lockInfo);
        redisTemplate.expire(lockKey, 600, TimeUnit.SECONDS);

        // 알림
        User fromUser = userRepository.findByUserId(dto.getSenderId()).orElseThrow();
        User toUser = userRepository.findByUserId(dto.getReceiverId()).orElseThrow();
        fcmService.sendPushMessageTo(toUser.getDeviceToken(), "커피챗 요청", fromUser.getNickname() + "님에게 커피챗 요청이 도착했습니다.");

        MatchDto match = mapper.map(dto, MatchDto.class);
        match.setMatchId(matchId);
        match.setStatus("pending");
        match.setExpirationTime(String.valueOf(expirationTime));
        return match;
    }

    // 보낸 매칭 요청 정보
    public List<MatchInfoResponseDto> getMatchRequestInfo(Long senderId) {
        log.trace("getMatchRequestInfo()");

        Set<String> keys = redisTemplate.keys("receiverId:*-senderId:" + senderId);
        if (keys == null || keys.isEmpty()) {
            throw new CustomException(ErrorCode.REQUEST_NOT_FOUND);
        }

        List<MatchInfoResponseDto> response = new ArrayList<>();
        for (String key : keys) {
            Map<Object, Object> matchInfo = redisTemplate.opsForHash().entries(key);
            String expirationTime = (String) matchInfo.get("expirationTime");
            if (matchInfo.get("status").equals("pending") && hasNotExpired(expirationTime)) {
                String matchId = (String) matchInfo.get("matchId");

                Long receiverId = getLongId(matchInfo.get("receiverId"));
                User receiver = userRepository.findById(receiverId)
                        .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
                ReceiverInfoDto receiverInfo = mapper.map(receiver, ReceiverInfoDto.class);
                receiverInfo.setReceiverId(receiverId);
                receiverInfo.setCompany(customMapper.toCompanyDto(receiver.getCompany()));

                MatchInfoResponseDto res = new MatchInfoResponseDto();
                res.setMatchId(matchId);
                res.setRequestTypeId((String) matchInfo.get("requestTypeId"));
                res.setReceiverInfo(receiverInfo);
                res.setExpirationTime(expirationTime);
                response.add(res);
            }
        }
        return response;
    }

    // 받은 요청 정보
    public List<MatchReceivedInfoDto> getMatchReceivedInfo(Long receiverId) {
        log.trace("getReceivedMatchRequests() for receiverId: {}", receiverId);

        Set<String> keys = redisTemplate.keys("receiverId:" + receiverId + "-senderId:*");
        if (keys == null || keys.isEmpty()) {
            throw new CustomException(ErrorCode.REQUEST_NOT_FOUND);
        }

        List<MatchReceivedInfoDto> response = new ArrayList<>();
        for (String key : keys) {
            Map<Object, Object> matchInfo = redisTemplate.opsForHash().entries(key);
            String expirationTime = (String) matchInfo.get("expirationTime");
            if (matchInfo.get("status").equals("pending") && hasNotExpired(expirationTime)) {
                String matchId = (String) matchInfo.get("matchId");

                Long senderId = getLongId(matchInfo.get("senderId"));
                User sender = userRepository.findById(senderId)
                        .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
                SenderInfoDto senderInfo = mapper.map(sender, SenderInfoDto.class);
                senderInfo.setSenderId(senderId);
                senderInfo.setCompany(customMapper.toCompanyDto(sender.getCompany()));

                MatchReceivedInfoDto res = new MatchReceivedInfoDto();
                res.setMatchId(matchId);
                res.setRequestTypeId((String) matchInfo.get("requestTypeId"));
                res.setSenderInfo(senderInfo);
                response.add(res);
            }
        }
        return response;
    }

    // 매칭 요청 수락
    public MatchAcceptResponse acceptMatchRequest(MatchIdDto dto) {
        log.trace("acceptMatchRequest()");

        validateIfAlreadyAccepted(dto.getMatchId());

        // 요청 만료 확인
        String key = "matchId:" + dto.getMatchId();
        String expirationTime = (String) redisTemplate.opsForHash().get(key, "expirationTime");
        if (!hasNotExpired(expirationTime)) {
            throw new CustomException(ErrorCode.REQUEST_EXPIRED);
        }

        Long senderId = getLongId(redisTemplate.opsForHash().get(key, "senderId"));
        Long receiverId = getLongId(redisTemplate.opsForHash().get(key, "receiverId"));

        ChatroomCreationDto chatroomCreationDto = new ChatroomCreationDto(senderId, receiverId);
        Long chatroomId = chatroomService.createChatroom(chatroomCreationDto);

        redisTemplate.opsForHash().put(key, "status", "accepted");
        redisTemplate.opsForHash().put("receiverId:" + receiverId + "-senderId:" + senderId, "status", "accepted");

        // 알림
        User fromUser = userRepository.findByUserId(receiverId).orElseThrow();
        User toUser = userRepository.findByUserId(senderId).orElseThrow();
        fcmService.sendPushMessageTo(toUser.getDeviceToken(), "커피챗 매칭 성공", fromUser.getNickname() + "님과 커피챗이 성사되었습니다.");

        // receiver가 보낸 다른 요청이 있었다면 해당 요청 취소
        Map<Object, Object> receiverRequest = redisTemplate.opsForHash().entries(LOCK_KEY_PREFIX + receiverId);
        if (!receiverRequest.isEmpty()) {
            log.trace("다른 요청이 있는 경우");

            String matchId = (String) redisTemplate.opsForHash().get(LOCK_KEY_PREFIX + receiverId, "matchId");
            redisTemplate.opsForHash().put("matchId:" + matchId, "status", "canceled");
            Long receiverId2 = getLongId(redisTemplate.opsForHash().get("matchId:" + matchId, "receiverId"));
            redisTemplate.opsForHash()
                    .put("receiverId:" + receiverId2 + "-senderId:" + receiverId, "status", "canceled");
            redisTemplate.delete(LOCK_KEY_PREFIX + receiverId); // receiver 락 해제
        }

        redisTemplate.opsForHash().put("matchId:" + dto.getMatchId(), "status", "accepted");
        redisTemplate.delete(LOCK_KEY_PREFIX + senderId); // sender 락 해제

        // 매칭중 상태 업데이트
        redisTemplate.opsForHash().put("userId:" + senderId, "isMatching", "yes");
        redisTemplate.opsForHash().put("userId:" + receiverId, "isMatching", "yes");

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

        String status = (String) redisTemplate.opsForHash().get("matchId:" + matchId, "status");
        if (status != null && status.equals("accepted")) {
            throw new CustomException(ErrorCode.REQUEST_ALREADY_ACCEPTED);
        }
    }

    // 매칭 요청 거절
    public MatchDto declineMatchRequest(MatchIdDto dto) {
        log.trace("declineMatchRequest()");

        validateRequest(dto.getMatchId());

        // 요청 만료 확인
        String key = "matchId:" + dto.getMatchId();
        String expirationTime = (String) redisTemplate.opsForHash().get(key, "expirationTime");
        if (!hasNotExpired(expirationTime)) {
            throw new CustomException(ErrorCode.REQUEST_EXPIRED);
        }

        Long senderId = getLongId(redisTemplate.opsForHash().get(key, "senderId"));
        Long receiverId = getLongId(redisTemplate.opsForHash().get(key, "receiverId"));

        // 알림
        User fromUser = userRepository.findByUserId(receiverId).orElseThrow();
        User toUser = userRepository.findByUserId(senderId).orElseThrow();
        fcmService.sendPushMessageTo(toUser.getDeviceToken(), "커피챗 매칭 실패",
                fromUser.getNickname() + "님이 커피챗 요청을 거절하였습니다.");

        redisTemplate.opsForHash().put(key, "status", "declined");
        redisTemplate.opsForHash().put("receiverId:" + receiverId + "-senderId:" + senderId, "status", "declined");
        redisTemplate.delete(LOCK_KEY_PREFIX + senderId); // 락 해제

        MatchDto match = new MatchDto();
        match.setMatchId(dto.getMatchId());
        match.setSenderId(senderId);
        match.setReceiverId(receiverId);
        match.setStatus("declined");
        return match;
    }

    // 매칭 요청 취소
    public MatchDto cancelMatchRequest(MatchIdDto dto) {
        log.trace("cancelMatchRequest()");

        validateRequest(dto.getMatchId());

        // 요청 만료 확인
        String key = "matchId:" + dto.getMatchId();
        String expirationTime = (String) redisTemplate.opsForHash().get(key, "expirationTime");
        if (!hasNotExpired(expirationTime)) {
            throw new CustomException(ErrorCode.REQUEST_EXPIRED);
        }

        Long senderId = getLongId(redisTemplate.opsForHash().get(key, "senderId"));
        Long receiverId = getLongId(redisTemplate.opsForHash().get(key, "receiverId"));

        redisTemplate.opsForHash().put(key, "status", "canceled");
        redisTemplate.opsForHash().put("receiverId:" + receiverId + "-senderId:" + senderId, "status", "canceled");
        redisTemplate.delete(LOCK_KEY_PREFIX + senderId); // 락 해제

        MatchDto match = new MatchDto();
        match.setMatchId(dto.getMatchId());
        match.setSenderId(senderId);
        match.setReceiverId(receiverId);
        match.setStatus("canceled");
        return match;
    }

    // 락 검증
    private void validateLock(String lockKey) {
        log.trace("validateLock()");

        // 이미 락이 걸려 있는 경우 요청 처리 X
        if (!redisTemplate.opsForHash().entries(lockKey).isEmpty()) {
            throw new CustomException(ErrorCode.REQUEST_DUPLICATED);
        }
    }

    // 유저 검증
    private void validateUser(MatchRequestDto dto) {
        log.trace("validateUser()");

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

    private boolean hasNotExpired(String expirationTime) {
        try {
            long expirationMillis = Long.parseLong(expirationTime);
            return System.currentTimeMillis() < expirationMillis;
        } catch (NumberFormatException e) {
            log.error("Invalid expiration time format: {}", expirationTime, e);
            return false;
        }
    }

    // 매칭 요청 검증
    private void validateRequest(String matchId) {
        log.trace("validateRequest()");

        String status = (String) redisTemplate.opsForHash().get("matchId:" + matchId, "status");
        switch (Objects.requireNonNull(status)) {
            case "accepted" -> throw new CustomException(ErrorCode.REQUEST_ALREADY_ACCEPTED);
            case "declined" -> throw new CustomException(ErrorCode.REQUEST_DECLINED);
            case "canceled" -> throw new CustomException(ErrorCode.REQUEST_CANCELED);
            case "finished" -> throw new CustomException(ErrorCode.REQUEST_FINISHED);
        }
    }

    // 매칭 종료
    public MatchStatusDto finishMatch(MatchFinishRequestDto dto) {
        log.trace("finishMatch()");

        String key = "matchId:" + dto.getMatchId();
        Long senderId = getLongId(redisTemplate.opsForHash().get(key, "senderId"));
        Long receiverId = getLongId(redisTemplate.opsForHash().get(key, "receiverId"));

        validateEnder(dto.getEnderId(), senderId, receiverId);

        if (dto.getEnderId().equals(senderId)) {
            sendMatchFinishNotification(senderId, receiverId);
        } else {
            sendMatchFinishNotification(receiverId, senderId);
        }

        redisTemplate.opsForHash().put(key, "status", "finished");
        redisTemplate.opsForHash().put("receiverId:" + receiverId + "-senderId:" + senderId, "status", "finished");

        redisTemplate.opsForHash().put("userId:" + senderId, "isMatching", "no");
        redisTemplate.opsForHash().put("userId:" + receiverId, "isMatching", "no");

        MatchStatusDto match = new MatchStatusDto();
        match.setMatchId(dto.getMatchId());
        match.setStatus("finished");
        return match;
    }

    private void validateEnder(Long enderId, Long senderId, Long receiverId) {
        log.trace("validateEnder()");

        if (!enderId.equals(senderId) && !enderId.equals(receiverId)) {
            throw new CustomException(ErrorCode.USER_NOT_FOUND);
        }
    }

    private void sendMatchFinishNotification(Long fromUserId, Long toUserId) {
        log.trace("sendMatchFinishNotification()");

        User fromUser = userRepository.findByUserId(fromUserId).orElseThrow();
        User toUser = userRepository.findByUserId(toUserId).orElseThrow();
        fcmService.sendPushMessageTo(toUser.getDeviceToken(), "커피챗 매칭 종료",
                fromUser.getNickname() + "님과의 커피챗이 종료되었습니다.");
    }

    // 매칭 요청 종료 확인
    public IsMatchingDto isMatching(Long userId) {
        log.trace("isMatching()");

        Map<Object, Object> isMatchingInfo = null;
        try {
            isMatchingInfo = redisTemplate.opsForHash().entries("userId:" + userId);
        } catch (Exception e) {
            log.error("isMatching() 에러");
        }

        if (isMatchingInfo == null || isMatchingInfo.isEmpty()) {
            log.warn("No matching info found for userId: {}", userId);
            IsMatchingDto response = new IsMatchingDto();
            response.setIsMatching("no");
            return response;
        }

        Long senderId = getLongId(isMatchingInfo.get("senderId"));
        Long receiverId = getLongId(isMatchingInfo.get("receiverId"));
        User sender = userRepository.findByUserId(senderId).orElseThrow();
        User receiver = userRepository.findByUserId(receiverId).orElseThrow();

        SenderInfoDto senderInfo = mapper.map(sender, SenderInfoDto.class);
        senderInfo.setSenderId(senderId);
        senderInfo.setCompany(customMapper.toCompanyDto(sender.getCompany()));
        ReceiverInfoDto receiverInfo = mapper.map(receiver, ReceiverInfoDto.class);
        receiverInfo.setReceiverId(receiverId);
        receiverInfo.setCompany(customMapper.toCompanyDto(receiver.getCompany()));

        IsMatchingDto response = mapper.map(isMatchingInfo, IsMatchingDto.class);
        response.setSenderInfo(senderInfo);
        response.setReceiverInfo(receiverInfo);

        if (userId.equals(senderId)) {
            response.setMatchPosition("sender");
        } else if (userId.equals(receiverId)) {
            response.setMatchPosition("receiver");
        }
        return response;
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
