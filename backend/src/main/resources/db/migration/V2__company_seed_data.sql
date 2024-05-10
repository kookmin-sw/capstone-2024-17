# company 테이블의 seed data (커리어한잔, 구글) insert
INSERT INTO upload_file (file_id, origin_filename, stored_filename)
VALUES (1, 'coffeechat-logo.png', 'coffeechat-logo.png'),
       (2, 'google-logo.png', 'google-logo.png');

INSERT INTO company (company_id, logo_file_id, bno, domain, name)
VALUES (1, 1, '00000000000', 'coffeechat.com', '커리어 한잔'),
       (2, 2, '00000000000', 'gmail.com', 'google(구글)');