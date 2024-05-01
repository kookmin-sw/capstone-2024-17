package com.coffee.backend.domain.match.service;

import com.coffee.backend.domain.company.entity.Company;
import com.coffee.backend.domain.fcm.service.FcmService;
import com.coffee.backend.domain.match.dto.MatchDto;
import com.coffee.backend.domain.match.dto.MatchInfoResponseDto;
import com.coffee.backend.domain.match.dto.MatchIdDto;
import com.coffee.backend.domain.match.dto.MatchInfoDto;
import com.coffee.backend.domain.match.dto.MatchRequestDto;
import com.coffee.backend.domain.match.dto.ReviewDto;
import com.coffee.backend.domain.match.entity.Review;
import com.coffee.backend.domain.match.repository.ReviewRepository;
import com.coffee.backend.domain.user.dto.ReceiverInfoDto;
import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.domain.user.repository.UserRepository;
import com.coffee.backend.exception.CustomException;
import com.coffee.backend.exception.ErrorCode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.Date;
import java.util.Map;
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
    private final ReviewRepository reviewRepository;
    private final ModelMapper mapper;
    private final ObjectMapper objectMapper;
    private final UserRepository userRepository;

    private static final String LOCK_KEY_PREFIX = "lock:senderId:";

    // 매칭 요청
    public MatchDto sendMatchRequest(MatchRequestDto dto) {
        String lockKey = LOCK_KEY_PREFIX + dto.getSenderId();

        // 이미 락이 걸려 있는 경우 요청 처리 X
        if (redisTemplate.opsForValue().get(lockKey) != null) {
            throw new CustomException(ErrorCode.REQUEST_DUPLICATED);
        }

        String matchId = UUID.randomUUID().toString();
        Map<String, String> matchInfo = Map.of(
                "senderId", dto.getSenderId().toString(),
                "receiverId", dto.getReceiverId().toString(),
                "requestTypeId", dto.getRequestTypeId().toString(),
                "status", "pending"
        );

        redisTemplate.opsForHash().putAll("matchId:" + matchId, matchInfo);
        redisTemplate.expire("matchId:" + matchId, 600, TimeUnit.SECONDS);

//        // 알림
//        User toUser = userRepository.findByUserId(dto.getReceiverId()).orElseThrow();
//        fcmService.sendPushMessageTo(toUser.getDeviceToken(), "커피챗 요청", "커피챗 요청이 도착했습니다.");

        // 10분동안 락 설정
        redisTemplate.opsForValue().set(lockKey, "Locked", 600, TimeUnit.SECONDS);

        MatchDto match = mapper.map(dto, MatchDto.class);
        match.setMatchId(matchId);
        match.setStatus("pending");
        return match;
    }

    // 매칭 요청 정보
    public MatchInfoResponseDto getMatchRequestInfo(MatchInfoDto dto) {
        User receiver = userRepository.findByUserId(dto.getReceiverId()).orElseThrow();

        ReceiverInfoDto receiverInfo = mapper.map(receiver, ReceiverInfoDto.class);
        Company company = receiver.getCompany();
        receiverInfo.setCompany(company);

        String key = "matchId:" + dto.getMatchId();
        Long requestTypeId = getLongId(redisTemplate.opsForHash().get(key, "requestTypeId"));

        MatchInfoResponseDto matchInfo = new MatchInfoResponseDto();
        matchInfo.setReceiverInfo(receiverInfo);
        matchInfo.setSenderId(dto.getSenderId());
        matchInfo.setReceiverId(dto.getReceiverId());
        matchInfo.setRequestTypeId(requestTypeId);
        return matchInfo;
    }

    // 매칭 요청 수락
    public MatchDto acceptMatchRequest(MatchIdDto dto) {
        if (!verifyMatchRequest(dto)) {
            throw new CustomException(ErrorCode.REQUEST_EXPIRED);
        }

        String key = "matchId:" + dto.getMatchId();

        redisTemplate.opsForHash().put(key, "status", "accepted");

        Object sender = redisTemplate.opsForHash().get(key, "senderId");
        Long senderId = getLongId(sender);
        Object receiver = redisTemplate.opsForHash().get(key, "receiverId");
        Long receiverId = getLongId(receiver);

//        // 알림
//        User toUser = userRepository.findByUserId(senderId).orElseThrow();
//        fcmService.sendPushMessageTo(toUser.getDeviceToken(), "커피챗 매칭 성공", "커피챗이 성사되었습니다.");

        MatchDto match = new MatchDto();
        match.setMatchId(dto.getMatchId());
        match.setSenderId(senderId);
        match.setReceiverId(receiverId);
        match.setStatus("accepted");
        return match;
    }

    // 매칭 요청 거절
    public MatchDto declineMatchRequest(MatchIdDto dto) {
        if (!verifyMatchRequest(dto)) {
            throw new CustomException(ErrorCode.REQUEST_EXPIRED);
        }

        String key = "matchId:" + dto.getMatchId();
        Object sender = redisTemplate.opsForHash().get(key, "senderId");
        Long senderId = getLongId(sender);
        Object receiver = redisTemplate.opsForHash().get(key, "receiverId");
        Long receiverId = getLongId(receiver);

//        // 알림
//        User toUser = userRepository.findByUserId(senderId).orElseThrow();
//        fcmService.sendPushMessageTo(toUser.getDeviceToken(), "커피챗 매칭 실패", "커피챗 요청이 거절되었습니다.");

        redisTemplate.delete(key);

        // 락 해제
        String lockKey = LOCK_KEY_PREFIX + senderId;
        redisTemplate.delete(lockKey);

        MatchDto match = new MatchDto();
        match.setMatchId(dto.getMatchId());
        match.setSenderId(senderId);
        match.setReceiverId(receiverId);
        match.setStatus("declined");
        return match;
    }

    // 매칭 요청 수동 취소
    public MatchDto cancelMatchRequest(MatchIdDto dto) {
        if (!verifyMatchRequest(dto)) {
            throw new CustomException(ErrorCode.REQUEST_EXPIRED);
        }

        String key = "matchId:" + dto.getMatchId();
        Object sender = redisTemplate.opsForHash().get(key, "senderId");
        Long senderId = getLongId(sender);
        Object receiver = redisTemplate.opsForHash().get(key, "receiverId");
        Long receiverId = getLongId(receiver);

        redisTemplate.delete(key);

        // 락 해제
        String lockKey = LOCK_KEY_PREFIX + senderId;
        redisTemplate.delete(lockKey);

        MatchDto match = new MatchDto();
        match.setMatchId(dto.getMatchId());
        match.setSenderId(senderId);
        match.setReceiverId(receiverId);
        match.setStatus("canceled");
        return match;
    }

    // 매칭 요청 검증
    private boolean verifyMatchRequest(MatchIdDto dto) {
        Long ttl = redisTemplate.getExpire("matchId:" + dto.getMatchId());
        return ttl != null && ttl > 0; // true
    }

    // Object -> Long 타입 변환
    private Long getLongId(Object result) {
        Long id = null;
        if (result != null) {
            if (result instanceof Number) {
                id = ((Number) result).longValue();
            } else {
                try {
                    id = Long.parseLong(result.toString());
                } catch (NumberFormatException e) {
                    System.err.println("변환 에러: " + e.getMessage());
                }
            }
        }
        return id;
    }

    @Transactional
    public Review saveReview(ReviewDto dto) {
        User sender = userRepository.findByUserId(dto.getSenderId()).orElseThrow();
        User receiver = userRepository.findByUserId(dto.getReceiverId()).orElseThrow();

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