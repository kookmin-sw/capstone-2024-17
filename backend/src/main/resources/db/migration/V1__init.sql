CREATE TABLE upload_file
(
    file_id         BIGINT AUTO_INCREMENT,
    origin_filename VARCHAR(255),
    stored_filename VARCHAR(255),
    PRIMARY KEY (file_id)
);

CREATE TABLE company
(
    company_id   BIGINT AUTO_INCREMENT,
    name         VARCHAR(255),
    domain       VARCHAR(255),
    bno          VARCHAR(255),
    logo_file_id BIGINT,
    PRIMARY KEY (company_id),
    FOREIGN KEY (logo_file_id) REFERENCES upload_file (file_id)
);

CREATE TABLE user
(
    user_id      BIGINT AUTO_INCREMENT,
    login_id     VARCHAR(255),
    kakao_id     BIGINT,
    password     VARCHAR(255),
    email        VARCHAR(255),
    nickname     VARCHAR(255),
    phone        VARCHAR(255),
    useruuid     VARCHAR(255),
    device_token VARCHAR(255),
    introduction VARCHAR(255),
    company_id   BIGINT,
    PRIMARY KEY (user_id),
    FOREIGN KEY (company_id) REFERENCES company (company_id)
);

CREATE TABLE company_request
(
    company_request_id BIGINT AUTO_INCREMENT,
    user_id            BIGINT,
    name               VARCHAR(255),
    domain             VARCHAR(255),
    bno                VARCHAR(255),
    PRIMARY KEY (company_request_id),
    FOREIGN KEY (user_id) REFERENCES user (user_id)
);

CREATE TABLE chatroom
(
    chatroom_id BIGINT AUTO_INCREMENT,
    PRIMARY KEY (chatroom_id)
);

CREATE TABLE message
(
    message_id  BIGINT AUTO_INCREMENT,
    chatroom_id BIGINT,
    sender_id   BIGINT,
    content     VARCHAR(255),
    created_at  DATETIME(6),
    PRIMARY KEY (message_id),
    FOREIGN KEY (chatroom_id) REFERENCES chatroom (chatroom_id),
    FOREIGN KEY (sender_id) REFERENCES user (user_id)
);

CREATE TABLE user_chatroom
(
    user_chatroom_id BIGINT AUTO_INCREMENT,
    user_id          BIGINT,
    chatroom_id      BIGINT,
    PRIMARY KEY (user_chatroom_id),
    FOREIGN KEY (user_id) REFERENCES user (user_id),
    FOREIGN KEY (chatroom_id) REFERENCES chatroom (chatroom_id)
);

CREATE TABLE review
(
    review_id   BIGINT AUTO_INCREMENT,
    comment     VARCHAR(255),
    created_at  DATETIME(6),
    rating      INT,
    receiver_id BIGINT,
    sender_id   BIGINT,
    PRIMARY KEY (review_id),
    FOREIGN KEY (receiver_id) REFERENCES user (user_id),
    FOREIGN KEY (sender_id) REFERENCES user (user_id)
);