package com.coffee.backend.domain.match.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReviewDto {
    private Long senderId;
    private Long receiverId;
    private int rating;
    private String comment;
}
