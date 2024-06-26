package com.coffee.backend.domain.cafe.service;

import com.coffee.backend.domain.cafe.dto.CafeDto;
import com.coffee.backend.domain.cafe.dto.CafeSubDto;
import com.coffee.backend.domain.cafe.dto.CafeUserDto;
import com.fasterxml.jackson.core.JsonProcessingException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.stereotype.Service;

@Slf4j
@RequiredArgsConstructor
@Service
public class CafePublisher {
    private final CafeService cafeService;
    private final SimpMessageSendingOperations sendingOperations;

    public void updateCafeChoice(String sessionId, CafeDto dto)
            throws JsonProcessingException, IllegalArgumentException {
        log.trace("updateCafeChoice()");
        String type = dto.getType();
        Long userId = dto.getUserId();
        String cafeId = dto.getCafeId();

        switch (type) {
            case "add":
                cafeService.addCafeChoice(cafeId, userId, sessionId);
                break;
            case "delete":
                cafeService.deleteCafeChoice(cafeId, userId);
                break;
            default:
                throw new IllegalArgumentException(
                        "updateCafeChoice : request type 형식을 (add/delete) 중 하나로 작성해주세요. 입력 type: '" + type + "'");
        }

        // 해당 user의 전체 정보를 조회
        CafeUserDto cafeUserDto = cafeService.getUserInfoFromDB(userId);
        CafeSubDto cafeSubDto = CafeSubDto.builder().type(type).userId(userId).cafeId(cafeId).cafeUserDto(cafeUserDto)
                .build();
        sendingOperations.convertAndSend("/sub/cafe/" + cafeId, cafeSubDto);
    }
}
