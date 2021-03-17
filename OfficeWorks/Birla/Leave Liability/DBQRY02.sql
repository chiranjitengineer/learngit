select TOKENNO, WORKERSERIAL,  from pisattn




SELECT * FROM pisattn

SELECT * FROM PISMONTHATTENDANCE
WHERE PRESENTDAYS <> SALARYDAYS


DELETE FROM PISLEAVETRANSACTION


SELECT * FROM PISLEAVETRANSACTION

EXEC PRC_PISLEAVEEARN_INSERT('BJ0056','0001','2020-2021','202101','SL')






 DELETE FROM PISLEAVETRANSACTION A
 WHERE A.COMPANYCODE='BJ0056'
 AND A.DIVISIONCODE='0001'
 AND A.YEARCODE='2020-2021'
 AND A.YEARMONTH='202101'
 AND A.WORKERSERIAL IN 
 (
     SELECT WORKERSERIAL FROM PISEMPLOYEEMASTER
     WHERE COMPANYCODE='BJ0056'
     AND DIVISIONCODE='0001'
 )
 AND A.TRANSACTIONTYPE = 'ENT'

 INSERT INTO PISLEAVETRANSACTION
 (
     COMPANYCODE, DIVISIONCODE, YEARCODE, CALENDARYEAR, YEARMONTH, CATEGORYCODE, GRADECODE, WORKERSERIAL, 
     TOKENNO, LEAVECODE, NOOFDAYS, ADDLESS, TRANSACTIONTYPE, WITHEFFECTFROM, USERNAME, LASTMODIFIED, SYSROWID
 )
 
 
 SELECT A.COMPANYCODE, A.DIVISIONCODE, A.YEARCODE, A.CALENDARYEAR, '202101' YEARMONTH, 
 A.CATEGORYCODE, A.GRADECODE, A.WORKERSERIAL, A.TOKENNO, LEAVECODE,ROUND(ENTITLEMENTS/12,2) NOOFDAYS,
 'ADD' ADDLESS,'ENT' TRANSACTIONTYPE,SYSDATE WITHEFFECTFROM,'SWT' USERNAME,SYSDATE LASTMODIFIED,FN_GENERATE_SYSROWID SYSROWID 
 FROM PISLEAVEENTITLEMENT A, PISEMPLOYEEMASTER  B
 WHERE A.COMPANYCODE='BJ0056'
 AND A.DIVISIONCODE='0001'
 AND A.YEARCODE='2020-2021'
 AND A.DIVISIONCODE=B.DIVISIONCODE
 AND A.COMPANYCODE=B.COMPANYCODE
 AND A.DIVISIONCODE=B.DIVISIONCODE
 AND A.WORKERSERIAL=B.WORKERSERIAL
     ORDER BY A.TOKENNO
 
 
 SELECT * FROM USER_SOURCE
 WHERE UPPER(TEXT) LIKE UPPER('%PRC_PIS_LEAVEBALANCE%')  
 
 SELECT * FROM USER_SOURCE
 WHERE UPPER(TEXT) LIKE UPPER('%PROC_PIS_LEAVEBAL%')  
 
 
 PROC_PIS_LEAVEBAL
 
 
 PRC_PIS_LEAVEBALANCE
 
 SELECT * FROM GBL_PIS_LEAVEBAL
 
EXEC PRC_PISLEAVEEARN_INSERT('BJ0056','0001','2020-2021','202101')

EXEC PRC_PISLEAVEEARN_INSERT('BJ0056','0001','2020-2021','202009')

SELECT * FROM PISLEAVETRANSACTION
WHERE YEARMONTH='202009'


SELECT * FROM PISPAYTRANSACTION

 
 
EXEC PROC_PIS_LEAVEBAL('BJ0056','0001','2020-2021','01/08/2020','31/08/2020')


 PROC_PIS_LEAVEBAL('','','','','','')
 
 P_COMPANYCODE VARCHAR2,
 P_DIVISIONCODE VARCHAR2,
 P_YEARCODE VARCHAR2,
 P_FROMDATE VARCHAR2,
 P_TODATE VARCHAR2, 
 P_WORKERSERIAL VARCHAR2 DEFAULT NULL
 
 )
 
 select * from PISLEAVETRANSACTION
 
 delete from PISLEAVETRANSACTION
 where YEARMONTH='20201'
 
 
 SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL,LEAVECODE, SUM(NOOFDAYS) 
 FROM PISLEAVETRANSACTION
 WHERE YEARCODE='2020-2021'
 GROUP BY COMPANYCODE, DIVISIONCODE, WORKERSERIAL,LEAVECODE
 
 select * from PISLEAVEENTITLEMENT
 
 select substr(202101,1,4) from dual
 
   SELECT A.CATEGORYCODE, A.WORKERSERIAL, LEAVECODE, 0 OPENING, SUM(ENTITLEMENTS) ENT, 0 AVAIL
     FROM PISEMPLOYEEMASTER A, PISCATEGORYMASTER C,
     (
         SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL,LEAVECODE,YEARCODE, SUM(NOOFDAYS) ENTITLEMENTS
         FROM PISLEAVETRANSACTION
         WHERE YEARCODE='2020-2021'
         GROUP BY COMPANYCODE, DIVISIONCODE, WORKERSERIAL,LEAVECODE,YEARCODE
     ) B
     WHERE A.COMPANYCODE='BJ0056'
         AND A.DIVISIONCODE='0001'
         AND A.COMPANYCODE=C.COMPANYCODE
         AND A.DIVISIONCODE=C.DIVISIONCODE
         AND A.CATEGORYCODE=C.CATEGORYCODE
         AND C.LEAVECALENDARORFINYRWISE='F'
         AND A.COMPANYCODE=B.COMPANYCODE
         AND A.DIVISIONCODE=B.DIVISIONCODE
         AND A.WORKERSERIAL=B.WORKERSERIAL
         AND B.YEARCODE='2020-2021'
     GROUP BY A.CATEGORYCODE,A.WORKERSERIAL,B.LEAVECODE
     
     
     
     
      SELECT WORKERSERIAL, LEAVECODE, SUM(NOOFDAYS) NOOFDAYS, 0 LV_TAKEN 
      FROM  PISLEAVETRANSACTION
      WHERE COMPANYCODE = ''
      AND DIVISIONCODE = ''
      AND YEARCODE = ''
      
      SELECT WORKERSERIAL,LEAVECODE, SUM(NOOFDAYS) NOOFDAYS, 0 LV_TAKEN 
         FROM PISLEAVETRANSACTION
         WHERE YEARCODE='2020-2021'
         GROUP BY WORKERSERIAL,LEAVECODE,YEARCODE
         
         SELECT * FROM PISLEAVETRANSACTION
         
EXEC PRC_PIS_LEAVEBALANCE ('BJ0056','0001','2020-2021','202101')

SELECT * FROM GBL_PISLEAVEBALANCE


P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2,
                                                  P_YEARCODE varchar2,
                                                  P_YEARMONTH Varchar2,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL
                                                 )         
                                                 
PISCOMP.ATTN_SALD/PISCOMP.ATTN_CALCF                                                 


SELECT * FROM PISPAYTRANSACTION


SELECT DISTINCT YEARCODE FROM FINANCIALYEAR
WHERE TO_DATE('202009','YYYYMM') BETWEEN STARTDATE AND ENDDATE



EXEC PRC_PISLEAVEEARN_INSERT('BJ0056','0001','202007')

SELECT * FROM PISLEAVETRANSACTION
WHERE YEARMONTH='202007'