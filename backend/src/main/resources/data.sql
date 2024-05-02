# DB 초기화할 때 company 테이블의 학생, 무직 레코드 insert 하는 구문
# 커리어한잔, 구글은 임시로 넣음
INSERT INTO upload_file (file_id, origin_filename, stored_filename)
VALUES (1, 'unknown-iogo.png', 'unknown-iogo.png'),
       (2, 'coffeechat-logo.png', 'coffeechat-logo.png'),
       (3, 'google-logo.png', 'google-logo.png');

INSERT INTO company (logo_file_id, bno, domain, name)
VALUES (1, '00000000000', 'none', '학생'),
       (1, '00000000000', 'none', '무직'),
       (2, '00000000000', 'coffeechat.com', '커리어 한잔'),
       (3, '00000000000', 'gmail.com', 'google(구글)');
