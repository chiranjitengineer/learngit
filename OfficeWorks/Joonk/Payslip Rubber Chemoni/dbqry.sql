
~GPS/PAGES/Report/Transaction/rptRubberRegister.rdlc~GTT_RUBBERREGISTER_FRM16

EXEC PROC_RUBBERREGISTER_FRM16_BK('JT0069','0006','01/11/2020','30/11/2020','''CHEFD''','''PERW''','2020-2021')

SELECT * FROM GTT_RUBBERREGISTER_FRM16


EXEC PROC_LOANBLNC('JT0069','0006','01/11/2020','01/11/2020')


UPDATE GTT_RUBBERREGISTER_FRM16 A SET 
OUT_STAND_DED = 
(
    SELECT LOAN_BAL FROM
    (
        SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, SUM(LOAN_BAL) LOAN_BAL 
        FROM GBL_LOANBLNC
        WHERE 1=1 
        AND LOANCODE <> 'ADVCO'
--        AND TOKENNO ='11359'
        GROUP BY COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO
    )
    WHERE A.COMPANYCODE=COMPANYCODE
    AND A.DIVISIONCODE=DIVISIONCODE
    AND A.WORKERSERIAL=WORKERSERIAL
    AND A.TOKENNO=TOKENNO
)


SELECT * FROM LOANBREAKUP
WHERE TOKENNO='11359'

EXEC PROC_LOANBLNC('JT0069','0006','01/11/2020','01/11/2020')

DELETE FROM GBL_LOANBLNC

SELECT * FROM GBL_LOANBLNC



SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, SUM(LOAN_BAL) LOAN_BAL 
FROM GBL_LOANBLNC
WHERE 1=1 
AND LOANCODE <> 'ADVCO'
AND TOKENNO ='11359'
GROUP BY COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO



SELECT * FROM GBL_LOANBLNC
WHERE TOKENNO='11359'


 P_COMPANYCODE  VARCHAR2,
    P_DIVISIONCODE VARCHAR2,
    P_STARTDATE    VARCHAR2,
    P_ENDDATE      VARCHAR2,    
    P_LOANCODE     VARCHAR2 DEFAULT NULL,
    P_WORKERSERIAL VARCHAR2 DEFAULT NULL,
    P_MODULE       VARCHAR2 DEFAULT 'GPS',
    P_WAGEPROCESS  VARCHAR2 DEFAULT 'NO', 
    P_TRANTYPE     VARCHAR2 DEFAULT 'SALARY'
    
    
    select add_months(to_date('01/11/2020','dd/mm/yyyy'),-1) from dual