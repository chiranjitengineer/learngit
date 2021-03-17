 DELETE FROM PISLEAVETRANSACTION A
 WHERE A.COMPANYCODE='BJ0056'
 AND A.DIVISIONCODE='0001'
 AND A.YEARCODE='2020-2021'
 AND A.YEARMONTH='202009'
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
 
 SELECT A.COMPANYCODE, A.DIVISIONCODE, A.YEARCODE, '2020' CALENDARYEAR, '202009' YEARMONTH, 
 A.CATEGORYCODE, A.GRADECODE, A.WORKERSERIAL, A.TOKENNO, LEAVECODE,ROUND((ENTITLEMENTS/12)*NVL(C.FACTOR,0),2) NOOFDAYS,
 'ADD' ADDLESS,'ENT' TRANSACTIONTYPE,SYSDATE WITHEFFECTFROM,'SWT' USERNAME,SYSDATE LASTMODIFIED,FN_GENERATE_SYSROWID SYSROWID 
 FROM PISLEAVEENTITLEMENT A, PISEMPLOYEEMASTER  B,
 (
     SELECT TOKENNO, WORKERSERIAL,DECODE(ATTN_CALCF,0,0,ROUND(ATTN_SALD/ATTN_CALCF,2)) FACTOR  FROM PISPAYTRANSACTION
     WHERE COMPANYCODE='BJ0056'
     AND DIVISIONCODE='0001'
     AND YEARCODE='2020-2021'
     AND YEARMONTH='202009'
 ) C
 WHERE A.COMPANYCODE='BJ0056'
 AND A.DIVISIONCODE='0001'
 AND A.YEARCODE='2020-2021'
 AND A.DIVISIONCODE=B.DIVISIONCODE
 AND A.COMPANYCODE=B.COMPANYCODE
 AND A.DIVISIONCODE=B.DIVISIONCODE
 AND A.WORKERSERIAL=B.WORKERSERIAL
     ORDER BY A.TOKENNO