package com.coffee.backend.domain.mail.service;

import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

@SpringBootTest
@Transactional
class MailServiceTest {
    @Autowired
    private MailService mailService;

    @Test
    void sendEmail() throws Exception {
        // given
        String toEmail = "haram8009@gmail.com";
        String title = "제목입니다";
        String text = "텍스트";

        Boolean done = Boolean.TRUE;

        // when
        try {
            mailService.sendEmail(toEmail, title, text);
        } catch (Exception e) {
            done = Boolean.FALSE;
            System.out.println("\n\n" + e.getMessage() + "\n\n");
        }

        // then
        assertTrue(done);

    }
}