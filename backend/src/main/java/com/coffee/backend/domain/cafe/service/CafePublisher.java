package com.coffee.backend.domain.cafe.service;

import com.coffee.backend.domain.cafe.dto.CafeDto;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class CafePublisher {
    private final RedisTemplate<String, Object> redisTemplate;
    private final CafeService cafeService;
    private final SimpMessageSendingOperations sendingOperations;

    public void updateCafeChoice(CafeDto dto) throws JsonProcessingException, IllegalArgumentException {
        String type = dto.getType();
        String loginId = dto.getLoginId();
        String cafeId = dto.getCafeId();

        switch (type) {
            case "add":
                cafeService.addCafeChoice(cafeId, loginId);
                break;
            case "delete":
                cafeService.deleteCafeChoice(cafeId, loginId);
                break;
            default:
                throw new IllegalArgumentException(
                        "updateCafeChoice : request type 형식을 (add/delete) 중 하나로 작성해주세요. 입력 type: '" + type + "'");
        }
        String cafeDtoJson = new ObjectMapper().writeValueAsString(dto);
        sendingOperations.convertAndSend("/sub/cafe/" + cafeId, cafeDtoJson);
    }
}
