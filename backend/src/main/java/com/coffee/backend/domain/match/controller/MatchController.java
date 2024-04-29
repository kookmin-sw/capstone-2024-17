package com.coffee.backend.domain.match.controller;

import com.coffee.backend.domain.match.dto.MatchDto;
import com.coffee.backend.domain.match.dto.MatchIdDto;
import com.coffee.backend.domain.match.dto.MatchRequestDto;
import com.coffee.backend.domain.match.dto.ReviewDto;
import com.coffee.backend.domain.match.entity.Review;
import com.coffee.backend.domain.match.service.MatchService;
import com.coffee.backend.utils.ApiResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequiredArgsConstructor
@RestController
@Slf4j
@RequestMapping("/match")
public class MatchController {
    private final MatchService matchService;

    @PostMapping("/request")
    public ResponseEntity<ApiResponse<MatchDto>> sendMatchRequest(@RequestBody MatchRequestDto dto) {
        log.info("Request Message Catch!!");
        MatchDto response = matchService.sendMatchRequest(dto);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PutMapping("/accept")
    public ResponseEntity<ApiResponse<MatchDto>> acceptMatchRequest(@RequestBody MatchIdDto dto) {
        log.info("Accept Message Catch!!");
        MatchDto response = matchService.acceptMatchRequest(dto);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @DeleteMapping("/decline")
    public ResponseEntity<ApiResponse<MatchDto>> declineMatchRequest(@RequestBody MatchIdDto dto) {
        log.info("Decline Message Catch!!");
        MatchDto response = matchService.declineMatchRequest(dto);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @DeleteMapping("/cancel")
    public ResponseEntity<ApiResponse<MatchDto>> cancelMatchRequest(@RequestBody MatchIdDto dto) {
        log.info("Cancel Message Catch!!");
        MatchDto response = matchService.cancelMatchRequest(dto);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PostMapping("/review")
    public ResponseEntity<ApiResponse<Review>> submitReview(@RequestBody ReviewDto dto) {
        Review response = matchService.saveReview(dto);
        return ResponseEntity.ok(ApiResponse.success(response));
    }
}
