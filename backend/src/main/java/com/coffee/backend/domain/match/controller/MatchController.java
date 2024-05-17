package com.coffee.backend.domain.match.controller;

import com.coffee.backend.domain.match.dto.MatchDto;
import com.coffee.backend.domain.match.dto.MatchFinishRequestDto;
import com.coffee.backend.domain.match.dto.MatchIdDto;
import com.coffee.backend.domain.match.dto.MatchInfoDto;
import com.coffee.backend.domain.match.dto.MatchInfoResponseDto;
import com.coffee.backend.domain.match.dto.MatchListDto;
import com.coffee.backend.domain.match.dto.MatchReceivedInfoDto;
import com.coffee.backend.domain.match.dto.MatchRequestDto;
import com.coffee.backend.domain.match.dto.MatchStatusDto;
import com.coffee.backend.domain.match.dto.ReviewDto;
import com.coffee.backend.domain.match.entity.Review;
import com.coffee.backend.domain.match.service.MatchService;
import com.coffee.backend.global.DtoLogger;
import com.coffee.backend.utils.ApiResponse;
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
            @RequestParam("matchId") String matchId, @RequestParam("senderId") Long senderId,
            @RequestParam("receiverId") Long receiverId) {
        DtoLogger.requestParam("senderId", senderId);
        DtoLogger.requestParam("receiverId", receiverId);

        MatchInfoDto dto = new MatchInfoDto();
        dto.setMatchId(matchId);
        dto.setSenderId(senderId);
        dto.setReceiverId(receiverId);

        MatchInfoResponseDto response = matchService.getMatchRequestInfo(dto);
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
    public ResponseEntity<ApiResponse<MatchDto>> acceptMatchRequest(@RequestBody MatchIdDto dto) {
        DtoLogger.requestBody(dto);

        log.info("Accept Message Catch!!");
        MatchDto response = matchService.acceptMatchRequest(dto);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @DeleteMapping("/decline")
    public ResponseEntity<ApiResponse<MatchDto>> declineMatchRequest(@RequestBody MatchIdDto dto) {
        DtoLogger.requestBody(dto);

        log.info("Decline Message Catch!!");
        MatchDto response = matchService.declineMatchRequest(dto);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @DeleteMapping("/cancel")
    public ResponseEntity<ApiResponse<MatchDto>> cancelMatchRequest(@RequestBody MatchIdDto dto) {
        DtoLogger.requestBody(dto);

        log.info("Cancel Message Catch!!");
        MatchDto response = matchService.cancelMatchRequest(dto);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PostMapping("/finish")
    public ResponseEntity<ApiResponse<MatchStatusDto>> finishMatch(@RequestBody MatchFinishRequestDto dto) {
        DtoLogger.requestBody(dto);

        log.info("Finish Message Catch!!");
        MatchStatusDto response = matchService.finishMatch(dto);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/isMatching")
    public ResponseEntity<ApiResponse<Boolean>> isMatching(@RequestBody MatchIdDto dto) {
        DtoLogger.requestBody(dto);

        log.info("Check if isMathing");
        Boolean response = matchService.isMatching(dto);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PostMapping("/review")
    public ResponseEntity<ApiResponse<Review>> submitReview(@RequestBody ReviewDto dto) {
        DtoLogger.requestBody(dto);

        Review response = matchService.saveReview(dto);
        return ResponseEntity.ok(ApiResponse.success(response));
    }
}
