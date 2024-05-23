package com.coffee.backend.domain.match.repository;

import com.coffee.backend.domain.match.entity.Review;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Long> {
    List<Review> findByMatchId(String matchId);
}
