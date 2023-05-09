--테이블 삭제
DROP TABLE board;

--테이블 생성
CREATE TABLE   board(
    num number CONSTRAINT board_num PRIMARY KEY,
    writer varchar2(50),
    subject varchar2(50),
    reg_date date,
    readcount number default 0, 
    ref number, 
    re_step number, 
    re_level number, 
    content varchar2(100),
    ip varchar2(20),
    upload varchar2(300),
    memberEmail varchar2(50)   
);

--시퀀스 삭제
DROP SEQUENCE board_num_seq;

--시퀀스 생성
CREATE SEQUENCE board_num_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

--테이블에 삽입
INSERT INTO board 
VALUES(board_num_seq.nextval, '홍길동','제목1',sysdate,0,board_num_seq.nextval,
0,0,'내용 테스트.......','127.0.0.1','sample.txt','young@aaaa.com');

--커밋
commit;

--출력
select * from board;

SELECT b.*
FROM(SELECT rownum AS rm, a.*
FROM(SELECT * FROM board
    ORDER BY ref DESC, re_step ASC)a)b
WHERE b.rm >= 1 AND b.rm <= 6
;

DELETE FROM board;

commit;

-----------------------------------------------------------------
--전화번호 11자리 뒤에 공백이 들어가서 테이블 제거 후 다시 생성

SELECT * FROM members;

DROP TABLE members;

SELECT * FROM members;    

CREATE TABLE members(
    memberEmail varchar2(50), --이메일
    memberPass varchar2(30), --비밀번호
    memberName varchar2(30), --이름
    memberPhone char(13), --전화번호
    memberType number(1), --회원구분 일반회원 1, 관리자 2
    constraint members_email primary key(memberEmail)
    );

SELECT * FROM members; 

--테이블 안에 데이터 값이 있으면 수정 불가, 테이블 날리지 않고 수정하고 싶다면
--내부의 데이터 지우고 수정하면 가능
DELETE FROM members;

ALTER TABLE members
MODIFY memberPhone char(11);

SELECT * FROM board
ORDER BY num DESC;

--writer 날리기
ALTER TABLE board
DROP COLUMN writer;

SELECT * FROM board;

SELECT memberEmail FROM board
WHERE num = 27;

SELECT b.*, m.memberName
FROM board b, members m
WHERE b.memberEmail = m.memberEmail
AND m.memberEmail = (SELECT memberEmail FROM board
WHERE num = 27)
AND num = 27;

SELECT memberName
FROM members
WHERE memberEmail='txwxkx@gmail.com';


SELECT b.*
FROM(SELECT rownum AS rm, a.*
FROM(SELECT * FROM board
    ORDER BY ref DESC, re_step ASC)a)b
WHERE b.rm >= 1 AND b.rm <= 6
;

