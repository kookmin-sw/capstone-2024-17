package com.coffee.backend.domain.match.service;

import com.coffee.backend.domain.fcm.service.FcmService;
import com.coffee.backend.domain.match.dto.MatchDto;
import java.time.Duration;
import java.util.Map;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@RequiredArgsConstructor
@Service
@Slf4j
public class MatchService {
    private final RedisTemplate<String, Object> redisTemplate;
    private final SimpMessagingTemplate messagingTemplate;
    private final FcmService fcmService;

    private static final String LOCK_KEY_PREFIX = "lock:matchRequest:";

    // 매칭 요청
    @Transactional
    public void sendMatchRequest(MatchDto dto) {
        String lockKey = LOCK_KEY_PREFIX + dto.getSenderId();

        // 이미 락이 걸려 있는 경우 요청 처리 X
        if (Boolean.TRUE.equals(redisTemplate.opsForValue().get(lockKey))) {
            messagingTemplate.convertAndSend("/user/" + dto.getSenderId(), "이미 진행 중인 매칭 요청이 있습니다.");
            return;
        }

        String requestId = UUID.randomUUID().toString();
        dto.setRequestId(requestId);
        dto.setStatus("pending");

        Map<String, String> matchDetails = Map.of(
                "senderId", dto.getSenderId(),
                "receiverId", dto.getReceiverId(),
                "status", dto.getStatus()
        );

        redisTemplate.opsForHash().putAll("requestId:" + requestId, matchDetails);
        redisTemplate.expire("requestId" + requestId, Duration.ofMinutes(10));
        messagingTemplate.convertAndSend("/user/" + dto.getReceiverId(), dto);
      
        // 알림
        fcmService.sendPushMessageTo(dto.getTargetToken(), "커피챗 요청", "커피챗 요청이 도착했습니다.");

        // 10분동안 락 설정
        redisTemplate.opsForValue().set(lockKey, true, Duration.ofMinutes(10));
    }

    // 매칭 요청 수락
    public void acceptMatchRequest(MatchDto dto) {
        if (verifyMatchRequest(dto)) {
            dto.setStatus("accepted");
        } else {
            dto.setStatus("failed");
        }
        messagingTemplate.convertAndSend("/user/" + dto.getReceiverId(), dto);

        // 알림
        fcmService.sendPushMessageTo(dto.getTargetToken(), "커피챗 매칭 성공", "커피챗이 성사되었습니다.");
    }

    // 매칭 요청 거절
    public void declineMatchRequest(MatchDto dto) {
        if (verifyMatchRequest(dto)) {
            dto.setStatus("declined");
        } else {
            dto.setStatus("failed");
        }
        messagingTemplate.convertAndSend("/user/" + dto.getReceiverId(), dto);
      
        // 알림
        fcmService.sendPushMessageTo(dto.getTargetToken(), "커피챗 매칭 실패", "커피챗 요청이 거절되었습니다.");

        // 락 해제
        String lockKey = LOCK_KEY_PREFIX + dto.getSenderId();
        redisTemplate.delete(lockKey);
    }

    // 매칭 요청 수동 취소
    public void cancelMatchRequest(MatchDto dto) {
        dto.setStatus("canceled");
        messagingTemplate.convertAndSend("/user/" + dto.getReceiverId(), dto);

        // 락 해제
        String lockKey = LOCK_KEY_PREFIX + dto.getSenderId();
        redisTemplate.delete(lockKey);
    }

    // 매칭 요청 검증
    private boolean verifyMatchRequest(MatchDto dto) {
        String requestId = dto.getRequestId();
        Long ttl = redisTemplate.getExpire("requestId:" + requestId);
        return ttl != null && ttl > 0;
    }
}