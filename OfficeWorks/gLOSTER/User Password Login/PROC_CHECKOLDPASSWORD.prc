CREATE OR REPLACE PROCEDURE GLOSTER_WEB.PROC_CHECKOLDPASSWORD
(
    P_ADMINUSER VARCHAR, 
    P_LOGINUSER VARCHAR, 
    P_OLDPASSWORD VARCHAR,
    P_NEWPASSWORD VARCHAR    
) AS
LV_RESULT VARCHAR2(100);
LV_CNT NUMBER(10);

LV_LOGIN_VALIDATION  VARCHAR2(100);
LV_STRONG_PASSLEN   VARCHAR2(100);
LV_MIN_PASSLEN  VARCHAR2(100);
LV_NOOFWRONGATTEMPT  VARCHAR2(100);
LV_MINIMUM_USERLEN   VARCHAR2(100);
LV_MAXIMUM_USERLEN VARCHAR2(100);

BEGIN
    LV_RESULT := '#SUCCESS';
    DELETE FROM SYS_GBL_PROCOUTPUT_INFO WHERE 1=1;

BEGIN        
    SELECT SUBSTR(PARAMETER_VALUE,1,1) PARAMETER_VALUE  INTO LV_LOGIN_VALIDATION
    FROM SYS_PARAMETER 
    WHERE PARAMETER_NAME = 'LOGIN VALIDATION' 
    AND ROWNUM=1;


--CREATE TABLE CHANGEPASSWORDMANAGER
--(
--  ADMINUSERNAME  VARCHAR2(30 BYTE)              NOT NULL,
--  LOGINUSERNAME  VARCHAR2(30 BYTE)              NOT NULL,
--  OLDPASSWORD    VARCHAR2(30 BYTE),
--  NEWPASSWORD    VARCHAR2(30 BYTE),
--  CHANGEDATE     DATE
--)

    IF LV_LOGIN_VALIDATION = 'Y' THEN

--        SELECT PARAMETER_VALUE   INTO LV_STRONG_PASSLEN
--        FROM SYS_PARAMETER 
--        WHERE PARAMETER_NAME = 'STRONG PASSWORD CHARACTER' 
--        AND ROWNUM=1;
--        dbms_output.put_line('STRONG PASSWORD CHARACTER  '||LV_STRONG_PASSLEN);
--        IF NVL(LV_STRONG_PASSLEN,'NA') <> 'NA' THEN
--            FOR C1 IN (
--                SELECT SUBSTR(LV_STRONG_PASSLEN,LEVEL,1) STRONG_CHAR FROM DUAL CONNECT BY LEVEL <= LENGTH(LV_STRONG_PASSLEN)
--            )
--            LOOP
--                dbms_output.put_line('STRONG_CHAR  '||C1.STRONG_CHAR);
--                LV_CNT := INSTR(P_NEWPASSWORD,C1.STRONG_CHAR);
--                dbms_output.put_line('LV_CNT  '||LV_CNT);
--                IF LV_CNT = 0 THEN
--                    LV_RESULT := 'This is not a Strong Password. A strong password must contains '''|| C1.STRONG_CHAR ||'''';
--                    LV_CNT := (1/0);
--                END IF;
--            END LOOP;
--        END IF;
        

        SELECT  PARAMETER_VALUE  INTO LV_MIN_PASSLEN
        FROM SYS_PARAMETER 
        WHERE PARAMETER_NAME = 'MINIMUM PASSWORD LENGTH' 
        AND ROWNUM=1;

         IF NVL(LV_MIN_PASSLEN,'NA') <> 'NA' THEN
            lv_cnt := length(P_NEWPASSWORD) - TO_NUMBER(LV_MIN_PASSLEN);
            IF LV_CNT < 0 THEN
                LV_RESULT := 'Minimum Password Length Should be '||LV_MIN_PASSLEN||'.';
                LV_CNT := (1/0);
            END IF;
         end if; 

        SELECT PARAMETER_VALUE  INTO LV_NOOFWRONGATTEMPT
        FROM SYS_PARAMETER 
        WHERE PARAMETER_NAME = 'NO OF WRONG PASSWORD ATTEMPT' 
        AND ROWNUM=1;

        SELECT PARAMETER_VALUE  INTO LV_MINIMUM_USERLEN
        FROM SYS_PARAMETER 
        WHERE PARAMETER_NAME = 'MINIMUM USERNAME LENGTH' 
        AND ROWNUM=1;

        SELECT PARAMETER_VALUE  INTO LV_MAXIMUM_USERLEN
        FROM SYS_PARAMETER 
        WHERE PARAMETER_NAME = 'MAXIMUM USERNAME LENGTH' 
        AND ROWNUM=1;
        
        SELECT COUNT(NEWPASSWORD) INTO LV_CNT FROM 
        (
            SELECT NEWPASSWORD, CHANGEDATE 
            FROM CHANGEPASSWORDMANAGER 
            ORDER BY CHANGEDATE DESC
        ) A
        WHERE ROWNUM <= 3
        AND NEWPASSWORD=P_NEWPASSWORD;
        
        IF LV_CNT > 0 THEN
            LV_RESULT := 'New password should not match with last 3 passwords.';
        ELSE
            INSERT INTO CHANGEPASSWORDMANAGER (ADMINUSERNAME, LOGINUSERNAME, OLDPASSWORD, NEWPASSWORD, CHANGEDATE)
            VALUES (P_ADMINUSER,P_LOGINUSER,P_OLDPASSWORD,P_NEWPASSWORD,SYSDATE);
        END IF;
        
    END IF;
EXCEPTION WHEN OTHERS THEN  null;
--    LV_RESULT := '#SUCCESS';
END;   
    INSERT INTO SYS_GBL_PROCOUTPUT_INFO SELECT LV_RESULT FROM DUAL;
END;
/