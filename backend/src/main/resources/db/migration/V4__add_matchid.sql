ALTER TABLE review
    ADD COLUMN match_id VARCHAR(255),
    CHANGE COLUMN sender_id reviewer_id BIGINT,
    CHANGE COLUMN receiver_id reviewee_id BIGINT;
