package com.coffee.backend.domain.cafe.service;

import com.coffee.backend.domain.cafe.dto.CafeDto;
import com.coffee.backend.domain.cafe.dto.CafeSubDto;
import com.coffee.backend.domain.cafe.dto.CafeUserDto;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class CafePublisher {
    private final CafeService cafeService;
    private final SimpMessageSendingOperations sendingOperations;

    public void updateCafeChoice(CafeDto dto) throws JsonProcessingException, IllegalArgumentException {
        String type = dto.getType();
        Long userId = dto.getUserId();
        String cafeId = dto.getCafeId();

        switch (type) {
            case "add":
                cafeService.addCafeChoice(cafeId, userId);
                break;
            case "delete":
                cafeService.deleteCafeChoice(cafeId, userId);
                break;
            default:
                throw new IllegalArgumentException(
                        "updateCafeChoice : request type 형식을 (add/delete) 중 하나로 작성해주세요. 입력 type: '" + type + "'");
        }
        String cafeDtoJson = new ObjectMapper().writeValueAsString(dto);
        // 해당 user의 전체 정보를 조회
        CafeUserDto cafeUserDto = cafeService.getUserInfoFromDB(userId);
        CafeSubDto cafeSubDto = CafeSubDto.builder().type(type).userId(userId).cafeId(cafeId).cafeUserDto(cafeUserDto)
                .build();
        sendingOperations.convertAndSend("/sub/cafe/" + cafeId, cafeSubDto);
    }
}
