package com.coffee.backend.domain.user.entity;

import com.coffee.backend.exception.CustomException;
import com.coffee.backend.exception.ErrorCode;
import com.fasterxml.jackson.annotation.JsonCreator;
import java.util.Arrays;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;

@AllArgsConstructor
@Slf4j
@Getter
public enum Position {
    P00("선택안함"),
    P01("서버/백엔드"),
    P02("프론트엔드"),
    P03("웹 풀스택"),
    P04("안드로이드"),
    P05("ios"),
    P06("머신러닝"),
    P07("인공지능(AI)"),
    P08("데이터 엔지니어링"),
    P09("DBA"),
    P10("모바일 게임"),
    P11("게임 클라이언트"),
    P12("게임 서버"),
    P13("시스템 소프트웨어"),
    P14("시스템/네트워크"),
    P15("데브옵스"),
    P16("인터넷 보안"),
    P17("임베디드 소프트웨어"),
    P18("로보틱스 미들웨어"),
    P19("QA"),
    P20("사물인터넷(IoT)"),
    P21("응용 프로그램"),
    P22("블록체인"),
    P23("개발PM"),
    P24("웹 퍼블리싱"),
    P25("크로스 플랫폼"),
    P26("VR/AR/3D"),
    P27("ERP"),
    P28("그래픽스");

    private final String name;

    @JsonCreator // value 이름으로 Position 생성 (ex. "선택안함" -> Position.P00)
    public static Position of(final String param) {
        return Arrays.stream(values()).filter(position -> position.name.equals(param))
                .findFirst()
                .orElseThrow(() -> {
                    log.info("Invalid position: {}", param);
                    return new CustomException(ErrorCode.ILLEGAL_ARGUMENT_POSITION);
                });
    }
}
