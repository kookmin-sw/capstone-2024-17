package com.coffee.backend.domain.match.controller;

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
import com.coffee.backend.domain.match.service.MatchService;
import com.coffee.backend.global.DtoLogger;
import com.coffee.backend.utils.ApiResponse;
import com.google.protobuf.Api;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RequiredArgsConstructor
@RestController
@Slf4j
@RequestMapping("/match")
public class MatchController {
    private final MatchService matchService;

    @PostMapping("/request")
    public ResponseEntity<ApiResponse<MatchDto>> sendMatchRequest(@RequestBody MatchRequestDto dto) {
        DtoLogger.requestBody(dto);

        log.info("Request Message Catch!!");
        MatchDto response = matchService.sendMatchRequest(dto);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/request/info")
    public ResponseEntity<ApiResponse<MatchInfoResponseDto>> getMatchRequestInfo(
            @RequestParam("senderId") Long senderId) {
        DtoLogger.requestParam("senderId", senderId);

        MatchInfoResponseDto response = matchService.getMatchRequestInfo(senderId);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/received/info")
    public ResponseEntity<ApiResponse<List<MatchReceivedInfoDto>>> getMatchReceivedInfo(
            @RequestParam("receiverId") Long receiverId) {
        DtoLogger.requestParam("receiverId", receiverId);

        List<MatchReceivedInfoDto> response = matchService.getMatchReceivedInfo(receiverId);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PutMapping("/accept")
    public ResponseEntity<ApiResponse<MatchAcceptResponse>> acceptMatchRequest(@RequestBody MatchIdDto dto) {
        DtoLogger.requestBody(dto);

        log.info("Accept Message Catch!!");
        MatchAcceptResponse response = matchService.acceptMatchRequest(dto);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PutMapping("/decline")
    public ResponseEntity<ApiResponse<MatchDto>> declineMatchRequest(@RequestBody MatchIdDto dto) {
        DtoLogger.requestBody(dto);

        log.info("Decline Message Catch!!");
        MatchDto response = matchService.declineMatchRequest(dto);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PutMapping("/cancel")
    public ResponseEntity<ApiResponse<MatchDto>> cancelMatchRequest(@RequestBody MatchIdDto dto) {
        DtoLogger.requestBody(dto);

        log.info("Cancel Message Catch!!");
        MatchDto response = matchService.cancelMatchRequest(dto);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PutMapping("/finish")
    public ResponseEntity<ApiResponse<MatchStatusDto>> finishMatch(@RequestBody MatchFinishRequestDto dto) {
        DtoLogger.requestBody(dto);

        log.info("Finish Message Catch!!");
        MatchStatusDto response = matchService.finishMatch(dto);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

//    @GetMapping("/isMatching")
//    public ResponseEntity<ApiResponse<MatchStatusDto>> isMatching(@RequestParam Long userId) {
//        DtoLogger.requestParam("userId", userId);
//
//        log.info("Check if isMathing");
//        MatchStatusDto response = matchService.isMatching(userId);
//        return ResponseEntity.ok(ApiResponse.success(response));
//    }

    @PutMapping("/alert/expired")
    public ResponseEntity<ApiResponse<MatchStatusDto>> alertExpired(@RequestBody MatchIdDto dto) {
        DtoLogger.requestBody(dto);
        log.info("Set the match expired");

        MatchStatusDto response = matchService.setExpired(dto);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PostMapping("/review")
    public ResponseEntity<ApiResponse<Review>> submitReview(@RequestBody ReviewDto dto) {
        DtoLogger.requestBody(dto);

        Review response = matchService.saveReview(dto);
        return ResponseEntity.ok(ApiResponse.success(response));
    }
}
