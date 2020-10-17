
SELECT NVL(SUM(AMT),0) 
FROM 
(
	SELECT WORKERSERIAL, SUM(NVL(LOAN_PF,0)+NVL(LINT_PF,0)) AMT FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE='0012'
	AND PERIODFROM = '01-APR-20'  AND PERIODTO='30-APR-20'
	GROUP BY WORKERSERIAL
	HAVING SUM(NVL(LOAN_PF,0)+NVL(LINT_PF,0)) > 0
	UNION ALL 
	SELECT WORKERSERIAL, -1*SUM(AMOUNT) AMT FROM PFLOANBREAKUP WHERE DIVISIONCODE = '0012'
	AND EFFECTFORTNIGHT = '30-APR-20'
	AND MODULE = 'GPS' AND TRANSACTIONTYPE IN ('CAPITAL','INTEREST')
	AND WORKERSERIAL IN 
	( 
		SELECT DISTINCT WORKERSERIAL FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE = '0012'
		AND PERIODFROM = '01-APR-20'  AND PERIODTO='30-APR-20' 
	) 
	GROUP BY WORKERSERIAL
)

SELECT * FROM PFLOANTRANSACTION WHERE WORKERSERIAL='0065423'
 
SELECT A.WORKERSERIAL, A.AMT PAYSHEET, B.AMT BREAKUP, (A.AMT+B.AMT) BALANCE FROM (
SELECT WORKERSERIAL, SUM(NVL(LOAN_PF,0)+NVL(LINT_PF,0)) AMT FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE='0012'
AND PERIODFROM = '01-APR-20'  AND PERIODTO='30-APR-20'
GROUP BY WORKERSERIAL
HAVING SUM(NVL(LOAN_PF,0)+NVL(LINT_PF,0)) > 0
) A, (	
--	UNION ALL 
	SELECT WORKERSERIAL, -1*SUM(AMOUNT) AMT FROM PFLOANBREAKUP WHERE DIVISIONCODE = '0012'
	AND EFFECTFORTNIGHT = '30-APR-20'
	AND MODULE = 'GPS' AND TRANSACTIONTYPE IN ('CAPITAL','INTEREST')
	AND WORKERSERIAL IN 
	( 
		SELECT DISTINCT WORKERSERIAL FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE = '0012'
		AND PERIODFROM = '01-APR-20'  AND PERIODTO='30-APR-20' 
	) 
	GROUP BY WORKERSERIAL
)B
WHERE A.WORKERSERIAL = B.WORKERSERIAL(+) 




lv_MasterTable :GPSEMPLOYEEMAST
CLOUMN :'LOAN_PF','LINT_PF','LNBL_PF','LIBL_PF'
INSERT INTO PFLOANBREAKUP ( 
 COMPANYCODE, DIVISIONCODE, EMPLOYEECOMPANYCODE, EMPLOYEEDIVISIONCODE, YEARCODE, YEARMONTH, CATEGORYCODE, GRADECODE, 
 PFNO, TOKENNO, WORKERSERIAL, LOANCODE, LOANDATE, EFFECTYEARMONTH, AMOUNT, TRANSACTIONTYPE, 
 EFFECTFORTNIGHT, PAIDON, ISPAID, REMARKS, MODULE, USERNAME, LASTMODIFIED,SYSROWID) 
 
 SELECT M.COMPANYCODE, M.DIVISIONCODE, 'DT0079' EMPLOYEECOMPANYCODE, '0012' EMPLOYEEDIVISIONCODE, '2020-2021' YEARCODE, '202004' YEARMONTH, M.CATEGORYCODE, M.GRADECODE, 
 A.PFNO, A.TOKENNO, A.WORKERSERIAL, A.LOANCODE, A.LOANDATE, '202004' EFFECTYEARMONTH, B.AMOUNT, B.TRANTYPE, 
 TO_DATE('30/04/2020','DD/MM/YYYY') EFFECTFORTNIGHT, TO_DATE('30/04/2020','DD/MM/YYYY') PAION, 'Y' ISPAID,'SALARY','GPS', 'SWT', SYSDATE, 
 A.PFNO||'-'||B.TRANTYPE||'-'||A.LOANCODE||'-'||REPLACE('30/04/2020','/','') SYSROWID
 FROM GBL_PFLOANBLNC A, PFEMPLOYEEMASTER M, 
 ( 
    SELECT WORKERSERIAL, TOKENNO, substr('LINT_PF',6) LOANCODE, LINT_PF AS AMOUNT, 'INTEREST' TRANTYPE 
   FROM GPSPAYSHEETDETAILS 
   WHERE 1=1 
     AND DIVISIONCODE = '0012' 
     AND PERIODFROM = '01-APR-20' 
     AND PERIODTO = '30-APR-20' 
     AND nvl(LINT_PF,0) > 0 
   UNION ALL 
   SELECT WORKERSERIAL, TOKENNO, substr('LOAN_PF',6) LOANCODE, LOAN_PF AS AMOUNT, 'CAPITAL' TRANTYPE 
   FROM GPSPAYSHEETDETAILS 
   WHERE 1=1 
     AND DIVISIONCODE = '0012' 
     AND PERIODFROM = '01-APR-20' 
     AND PERIODTO = '30-APR-20' 
     AND nvl(LOAN_PF,0) > 0 
 ) B
 WHERE A.WORKERSERIAL = B.WORKERSERIAL 
   AND A.LOANCODE = B.LOANCODE 
   /*AND A.PFNO = M.PFNO */
   AND M.COMPANYCODE = 'DT0079' 
   AND M.DIVISIONCODE = '0012' 
   AND A.WORKERSERIAL = M.WORKERSERIAL 
 ORDER BY A.PFNO, A.LOANCODE,B.TRANTYPE 

DIVCODE : 0012, FROMDATE : 01-APR-20, TO DATE : 30-APR-20, LOAN CODE : PF, BALANCE : 2000




SELECT NVL(SUM(AMT),0) 
FROM 
(
	SELECT WORKERSERIAL, SUM(NVL(LOAN_PF,0)+NVL(LINT_PF,0)) AMT FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE='0012'
	AND PERIODFROM = '12-APR-20'  AND PERIODTO='25-APR-20'
	GROUP BY WORKERSERIAL
	HAVING SUM(NVL(LOAN_PF,0)+NVL(LINT_PF,0)) > 0
	UNION ALL 
	SELECT WORKERSERIAL, -1*SUM(AMOUNT) AMT FROM PFLOANBREAKUP WHERE DIVISIONCODE = '0012'
	AND EFFECTFORTNIGHT = '25-APR-20'
	AND MODULE = 'GPS' AND TRANSACTIONTYPE IN ('CAPITAL','INTEREST')
	AND WORKERSERIAL IN 
	( 
		SELECT DISTINCT WORKERSERIAL FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE = '0012'
		AND PERIODFROM = '12-APR-20'  AND PERIODTO='25-APR-20' 
	) 
	GROUP BY WORKERSERIAL
)


SELECT * FROM PFLOANTRANSACTION WHERE WORKERSERIAL IN 
(
SELECT WORKERSERIAL FROM (
SELECT A.WORKERSERIAL, A.AMT PAYSHEET, B.AMT BREAKUP, (A.AMT+B.AMT) BALANCE FROM (
SELECT WORKERSERIAL, SUM(NVL(LOAN_PF,0)+NVL(LINT_PF,0)) AMT FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE='0012'
AND PERIODFROM = '12-APR-20'  AND PERIODTO='25-APR-20'
GROUP BY WORKERSERIAL
HAVING SUM(NVL(LOAN_PF,0)+NVL(LINT_PF,0)) > 0
) A, (	
--	UNION ALL 
	SELECT WORKERSERIAL, -1*SUM(AMOUNT) AMT FROM PFLOANBREAKUP WHERE DIVISIONCODE = '0012'
	AND EFFECTFORTNIGHT = '25-APR-20'
	AND MODULE = 'GPS' AND TRANSACTIONTYPE IN ('CAPITAL','INTEREST')
	AND WORKERSERIAL IN 
	( 
		SELECT DISTINCT WORKERSERIAL FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE = '0012'
		AND PERIODFROM = '12-APR-20'  AND PERIODTO='25-APR-20' 
	) 
	GROUP BY WORKERSERIAL
)B
WHERE A.WORKERSERIAL = B.WORKERSERIAL(+) 
)
)




lv_MasterTable :GPSEMPLOYEEMAST
CLOUMN :'LOAN_PF','LINT_PF','LNBL_PF','LIBL_PF'
INSERT INTO PFLOANBREAKUP ( 
 COMPANYCODE, DIVISIONCODE, EMPLOYEECOMPANYCODE, EMPLOYEEDIVISIONCODE, YEARCODE, YEARMONTH, CATEGORYCODE, GRADECODE, 
 PFNO, TOKENNO, WORKERSERIAL, LOANCODE, LOANDATE, EFFECTYEARMONTH, AMOUNT, TRANSACTIONTYPE, 
 EFFECTFORTNIGHT, PAIDON, ISPAID, REMARKS, MODULE, USERNAME, LASTMODIFIED,SYSROWID) 
 
 SELECT M.COMPANYCODE, M.DIVISIONCODE, 'DT0079' EMPLOYEECOMPANYCODE, '0012' EMPLOYEEDIVISIONCODE, '2020-2021' YEARCODE, '202004' YEARMONTH, M.CATEGORYCODE, M.GRADECODE, 
 A.PFNO, A.TOKENNO, A.WORKERSERIAL, A.LOANCODE, A.LOANDATE, '202004' EFFECTYEARMONTH, B.AMOUNT, B.TRANTYPE, 
 TO_DATE('25/04/2020','DD/MM/YYYY') EFFECTFORTNIGHT, TO_DATE('25/04/2020','DD/MM/YYYY') PAION, 'Y' ISPAID,'SALARY','GPS', 'SWT', SYSDATE, 
 A.PFNO||'-'||B.TRANTYPE||'-'||A.LOANCODE||'-'||REPLACE('25/04/2020','/','') SYSROWID
 FROM GBL_PFLOANBLNC A, PFEMPLOYEEMASTER M, 
 ( 
    SELECT WORKERSERIAL, TOKENNO, substr('LINT_PF',6) LOANCODE, LINT_PF AS AMOUNT, 'INTEREST' TRANTYPE 
   FROM GPSPAYSHEETDETAILS 
   WHERE 1=1 
     AND DIVISIONCODE = '0012' 
     AND PERIODFROM = '12-APR-20' 
     AND PERIODTO = '25-APR-20' 
     AND nvl(LINT_PF,0) > 0 
   UNION ALL 
   SELECT WORKERSERIAL, TOKENNO, substr('LOAN_PF',6) LOANCODE, LOAN_PF AS AMOUNT, 'CAPITAL' TRANTYPE 
   FROM GPSPAYSHEETDETAILS 
   WHERE 1=1 
     AND DIVISIONCODE = '0012' 
     AND PERIODFROM = '12-APR-20' 
     AND PERIODTO = '25-APR-20' 
     AND nvl(LOAN_PF,0) > 0 
 ) B
 WHERE A.WORKERSERIAL = B.WORKERSERIAL 
   AND A.LOANCODE = B.LOANCODE 
   /*AND A.PFNO = M.PFNO */
   AND M.COMPANYCODE = 'DT0079' 
   AND M.DIVISIONCODE = '0012' 
   AND A.WORKERSERIAL = M.WORKERSERIAL 
 ORDER BY A.PFNO, A.LOANCODE,B.TRANTYPE 

DIVCODE : 0012, FROMDATE : 12-APR-20, TO DATE : 25-APR-20, LOAN CODE : PF, BALANCE : 10428




SELECT NVL(SUM(AMT),0) 
FROM 
(
	SELECT WORKERSERIAL, SUM(NVL(LOAN_PF,0)+NVL(LINT_PF,0)) AMT FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE='0012'
	AND PERIODFROM = '26-APR-20'  AND PERIODTO='09-MAY-20'
	GROUP BY WORKERSERIAL
	HAVING SUM(NVL(LOAN_PF,0)+NVL(LINT_PF,0)) > 0
	UNION ALL 
	SELECT WORKERSERIAL, -1*SUM(AMOUNT) AMT FROM PFLOANBREAKUP WHERE DIVISIONCODE = '0012'
	AND EFFECTFORTNIGHT = '09-MAY-20'
	AND MODULE = 'GPS' AND TRANSACTIONTYPE IN ('CAPITAL','INTEREST')
	AND WORKERSERIAL IN 
	( 
		SELECT DISTINCT WORKERSERIAL FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE = '0012'
		AND PERIODFROM = '26-APR-20'  AND PERIODTO='09-MAY-20' 
	) 
	GROUP BY WORKERSERIAL
)


lv_MasterTable :GPSEMPLOYEEMAST
CLOUMN :'LOAN_PF','LINT_PF','LNBL_PF','LIBL_PF'
INSERT INTO PFLOANBREAKUP ( 
 COMPANYCODE, DIVISIONCODE, EMPLOYEECOMPANYCODE, EMPLOYEEDIVISIONCODE, YEARCODE, YEARMONTH, CATEGORYCODE, GRADECODE, 
 PFNO, TOKENNO, WORKERSERIAL, LOANCODE, LOANDATE, EFFECTYEARMONTH, AMOUNT, TRANSACTIONTYPE, 
 EFFECTFORTNIGHT, PAIDON, ISPAID, REMARKS, MODULE, USERNAME, LASTMODIFIED,SYSROWID) 
 SELECT M.COMPANYCODE, M.DIVISIONCODE, 'DT0079' EMPLOYEECOMPANYCODE, '0012' EMPLOYEEDIVISIONCODE, '2020-2021' YEARCODE, '202005' YEARMONTH, M.CATEGORYCODE, M.GRADECODE, 
 A.PFNO, A.TOKENNO, A.WORKERSERIAL, A.LOANCODE, A.LOANDATE, '202005' EFFECTYEARMONTH, B.AMOUNT, B.TRANTYPE, 
 TO_DATE('09/05/2020','DD/MM/YYYY') EFFECTFORTNIGHT, TO_DATE('09/05/2020','DD/MM/YYYY') PAION, 'Y' ISPAID,'SALARY','GPS', 'SWT', SYSDATE, 
 A.PFNO||'-'||B.TRANTYPE||'-'||A.LOANCODE||'-'||REPLACE('09/05/2020','/','') SYSROWID
 FROM GBL_PFLOANBLNC A, PFEMPLOYEEMASTER M, 
 ( 
    SELECT WORKERSERIAL, TOKENNO, substr('LINT_PF',6) LOANCODE, LINT_PF AS AMOUNT, 'INTEREST' TRANTYPE 
   FROM GPSPAYSHEETDETAILS 
   WHERE 1=1 
     AND DIVISIONCODE = '0012' 
     AND PERIODFROM = '26-APR-20' 
     AND PERIODTO = '09-MAY-20' 
     AND nvl(LINT_PF,0) > 0 
   UNION ALL 
   SELECT WORKERSERIAL, TOKENNO, substr('LOAN_PF',6) LOANCODE, LOAN_PF AS AMOUNT, 'CAPITAL' TRANTYPE 
   FROM GPSPAYSHEETDETAILS 
   WHERE 1=1 
     AND DIVISIONCODE = '0012' 
     AND PERIODFROM = '26-APR-20' 
     AND PERIODTO = '09-MAY-20' 
     AND nvl(LOAN_PF,0) > 0 
 
 ) B
 WHERE A.WORKERSERIAL = B.WORKERSERIAL 
   AND A.LOANCODE = B.LOANCODE 
   /*AND A.PFNO = M.PFNO */
   AND M.COMPANYCODE = 'DT0079' 
   AND M.DIVISIONCODE = '0012' 
   AND A.WORKERSERIAL = M.WORKERSERIAL 
 ORDER BY A.PFNO, A.LOANCODE,B.TRANTYPE 

DIVCODE : 0012, FROMDATE : 26-APR-20, TO DATE : 09-MAY-20, LOAN CODE : PF, BALANCE : 10633



DIVCODE : 0012, FROMDATE : 01-MAY-20, TO DATE : 31-MAY-20, LOAN CODE : PF, BALANCE : 0




SELECT NVL(SUM(AMT),0) 
FROM 
(
	SELECT WORKERSERIAL, SUM(NVL(LOAN_PF,0)+NVL(LINT_PF,0)) AMT FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE='0012'
	AND PERIODFROM = '10-MAY-20'  AND PERIODTO='23-MAY-20'
	GROUP BY WORKERSERIAL
	HAVING SUM(NVL(LOAN_PF,0)+NVL(LINT_PF,0)) > 0
	UNION ALL 
	SELECT WORKERSERIAL, -1*SUM(AMOUNT) AMT FROM PFLOANBREAKUP WHERE DIVISIONCODE = '0012'
	AND EFFECTFORTNIGHT = '23-MAY-20'
	AND MODULE = 'GPS' AND TRANSACTIONTYPE IN ('CAPITAL','INTEREST')
	AND WORKERSERIAL IN 
	( 
		SELECT DISTINCT WORKERSERIAL FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE = '0012'
		AND PERIODFROM = '10-MAY-20'  AND PERIODTO='23-MAY-20' 
	) 
	GROUP BY WORKERSERIAL
)


lv_MasterTable :GPSEMPLOYEEMAST
CLOUMN :'LOAN_PF','LINT_PF','LNBL_PF','LIBL_PF'
INSERT INTO PFLOANBREAKUP ( 
 COMPANYCODE, DIVISIONCODE, EMPLOYEECOMPANYCODE, EMPLOYEEDIVISIONCODE, YEARCODE, YEARMONTH, CATEGORYCODE, GRADECODE, 
 PFNO, TOKENNO, WORKERSERIAL, LOANCODE, LOANDATE, EFFECTYEARMONTH, AMOUNT, TRANSACTIONTYPE, 
 EFFECTFORTNIGHT, PAIDON, ISPAID, REMARKS, MODULE, USERNAME, LASTMODIFIED,SYSROWID) 
 SELECT M.COMPANYCODE, M.DIVISIONCODE, 'DT0079' EMPLOYEECOMPANYCODE, '0012' EMPLOYEEDIVISIONCODE, '2020-2021' YEARCODE, '202005' YEARMONTH, M.CATEGORYCODE, M.GRADECODE, 
 A.PFNO, A.TOKENNO, A.WORKERSERIAL, A.LOANCODE, A.LOANDATE, '202005' EFFECTYEARMONTH, B.AMOUNT, B.TRANTYPE, 
 TO_DATE('23/05/2020','DD/MM/YYYY') EFFECTFORTNIGHT, TO_DATE('23/05/2020','DD/MM/YYYY') PAION, 'Y' ISPAID,'SALARY','GPS', 'SWT', SYSDATE, 
 A.PFNO||'-'||B.TRANTYPE||'-'||A.LOANCODE||'-'||REPLACE('23/05/2020','/','') SYSROWID
 FROM GBL_PFLOANBLNC A, PFEMPLOYEEMASTER M, 
 ( 
    SELECT WORKERSERIAL, TOKENNO, substr('LINT_PF',6) LOANCODE, LINT_PF AS AMOUNT, 'INTEREST' TRANTYPE 
   FROM GPSPAYSHEETDETAILS 
   WHERE 1=1 
     AND DIVISIONCODE = '0012' 
     AND PERIODFROM = '10-MAY-20' 
     AND PERIODTO = '23-MAY-20' 
     AND nvl(LINT_PF,0) > 0 
   UNION ALL 
   SELECT WORKERSERIAL, TOKENNO, substr('LOAN_PF',6) LOANCODE, LOAN_PF AS AMOUNT, 'CAPITAL' TRANTYPE 
   FROM GPSPAYSHEETDETAILS 
   WHERE 1=1 
     AND DIVISIONCODE = '0012' 
     AND PERIODFROM = '10-MAY-20' 
     AND PERIODTO = '23-MAY-20' 
     AND nvl(LOAN_PF,0) > 0 
 
 ) B
 WHERE A.WORKERSERIAL = B.WORKERSERIAL 
   AND A.LOANCODE = B.LOANCODE 
   /*AND A.PFNO = M.PFNO */
   AND M.COMPANYCODE = 'DT0079' 
   AND M.DIVISIONCODE = '0012' 
   AND A.WORKERSERIAL = M.WORKERSERIAL 
 ORDER BY A.PFNO, A.LOANCODE,B.TRANTYPE 

DIVCODE : 0012, FROMDATE : 10-MAY-20, TO DATE : 23-MAY-20, LOAN CODE : PF, BALANCE : 10633



DIVCODE : 0012, FROMDATE : 24-MAY-20, TO DATE : 06-JUN-20, LOAN CODE : PF, BALANCE : 0



DIVCODE : 0012, FROMDATE : 01-JUN-20, TO DATE : 30-JUN-20, LOAN CODE : PF, BALANCE : 0



DIVCODE : 0012, FROMDATE : 07-JUN-20, TO DATE : 20-JUN-20, LOAN CODE : PF, BALANCE : 0



DIVCODE : 0012, FROMDATE : 21-JUN-20, TO DATE : 04-JUL-20, LOAN CODE : PF, BALANCE : 0



DIVCODE : 0012, FROMDATE : 01-JUL-20, TO DATE : 31-JUL-20, LOAN CODE : PF, BALANCE : 0



DIVCODE : 0012, FROMDATE : 05-JUL-20, TO DATE : 18-JUL-20, LOAN CODE : PF, BALANCE : 0



DIVCODE : 0012, FROMDATE : 19-JUL-20, TO DATE : 01-AUG-20, LOAN CODE : PF, BALANCE : 0



DIVCODE : 0012, FROMDATE : 02-AUG-20, TO DATE : 15-AUG-20, LOAN CODE : PF, BALANCE : 0



DIVCODE : 0012, FROMDATE : 16-AUG-20, TO DATE : 29-AUG-20, LOAN CODE : PF, BALANCE : 0



DIVCODE : 0012, FROMDATE : 30-AUG-20, TO DATE : 12-SEP-20, LOAN CODE : PF, BALANCE : 0



DIVCODE : 0012, FROMDATE : 13-SEP-20, TO DATE : 26-SEP-20, LOAN CODE : PF, BALANCE : 0


