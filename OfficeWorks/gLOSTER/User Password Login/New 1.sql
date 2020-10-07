SELECT * FROM CHANGEPASSWORDMANAGER


EXEC PROC_CHECKOLDPASSWORD('SWT','SWT','@.','@.')

SELECT PARAMETER_VALUE  -- INTO LV_STRONG_PASSLEN
FROM SYS_PARAMETER 
WHERE PARAMETER_NAME = 'STRONG PASSWORD CHARACTER' 
AND ROWNUM=1;



SELECT SYS_SAVE_INFO FROM SYS_GBL_PROCOUTPUT_INFO where rownum=1

  SELECT COUNT(NEWPASSWORD)  FROM 
        (
            SELECT NEWPASSWORD, CHANGEDATE 
            FROM CHANGEPASSWORDMANAGER 
            ORDER BY CHANGEDATE DESC
        ) A
        WHERE ROWNUM <= 3
        AND NEWPASSWORD='111';