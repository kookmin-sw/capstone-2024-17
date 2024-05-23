package com.coffee.backend.domain.match.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReviewDto {
    private String matchId;
    private Long reviewerId;
    private Long revieweeId;
    private int rating;
    private String comment;
}
