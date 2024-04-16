package com.coffee.backend.domain.mail.service;

import com.coffee.backend.exception.CustomException;
import com.coffee.backend.exception.ErrorCode;
import jakarta.mail.Message.RecipientType;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@Transactional
@RequiredArgsConstructor
public class MailService {

    @Value("${spring.mail.username}")
    private String fromEmail;
    private final JavaMailSender emailSender;


    public void sendEmail(String toEmail,
                          String title,
                          String text) {
        MimeMessage message = emailSender.createMimeMessage();
        try {
            message.setFrom(new InternetAddress(fromEmail, "커리어 한잔"));
            message.addRecipients(RecipientType.TO, toEmail);
            message.setSubject(title);
            message.setText(text, "UTF-8", "html");
            emailSender.send(message);
        } catch (Exception e) {
            log.info("MailService.sendEmail exception occur toEmail: {}, " +
                    "title: {}, text: {}", toEmail, title, text);
            throw new CustomException(ErrorCode.UNABLE_TO_SEND_EMAIL_ERROR);
        }
    }
}
