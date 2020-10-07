DIVCODE : 0012, FROMDATE : 01-APR-20, TO DATE : 30-APR-20, LOAN CODE : ADVGN, BALANCE : 0

DIVCODE : 0012, FROMDATE : 01-APR-20, TO DATE : 30-APR-20, LOAN CODE : MD, BALANCE : 0





DIVCODE : 0012, FROMDATE : 12-APR-20, TO DATE : 25-APR-20, LOAN CODE : ADVGN, BALANCE : 0


SELECT /*WORKERSERIAL,*/ NVL(SUM(AMT),0) 
FROM 
(
	SELECT WORKERSERIAL, SUM(NVL(LOAN_MD,0)+NVL(LINT_MD,0)) AMT FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE= '0012' 
	AND PERIODFROM = '12-APR-20' AND PERIODTO='25-APR-20'
	GROUP BY WORKERSERIAL
	HAVING SUM(NVL(LOAN_MD,0)+NVL(LINT_MD,0)) > 0
	UNION ALL 
	SELECT WORKERSERIAL, -1*SUM(AMOUNT) AMT FROM LOANBREAKUP WHERE DIVISIONCODE =  '0012'
	AND EFFECTFORTNIGHT = '25-APR-20'
	AND LOANCODE = 'MD'
	AND MODULE = 'GPS' AND TRANSACTIONTYPE IN ('CAPITAL','INTEREST')
	AND WORKERSERIAL IN 
	( 
		SELECT DISTINCT WORKERSERIAL FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE = '0012'
		AND PERIODFROM = '12-APR-20'  AND PERIODTO='25-APR-20' 
	) 
	GROUP BY WORKERSERIAL
)


DIVCODE : 0012, FROMDATE : 12-APR-20, TO DATE : 25-APR-20, LOAN CODE : MD, BALANCE : 5285

EXEC PROC_UPD_WAGES_PROCESSBYDIV('DT0079','0012','2020-2021','12/04/2020','25/04/2020','MD','GPS','Y')



DIVCODE : 0012, FROMDATE : 26-APR-20, TO DATE : 09-MAY-20, LOAN CODE : ADVGN, BALANCE : 0


SELECT /*WORKERSERIAL,*/ NVL(SUM(AMT),0) 
FROM 
(
	SELECT WORKERSERIAL, SUM(NVL(LOAN_MD,0)+NVL(LINT_MD,0)) AMT FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE= '0012' 
	AND PERIODFROM = '26-APR-20' AND PERIODTO='09-MAY-20'
	GROUP BY WORKERSERIAL
	HAVING SUM(NVL(LOAN_MD,0)+NVL(LINT_MD,0)) > 0
	UNION ALL 
	SELECT WORKERSERIAL, -1*SUM(AMOUNT) AMT FROM LOANBREAKUP WHERE DIVISIONCODE =  '0012'
	AND EFFECTFORTNIGHT = '09-MAY-20'
	AND LOANCODE = 'MD'
	AND MODULE = 'GPS' AND TRANSACTIONTYPE IN ('CAPITAL','INTEREST')
	AND WORKERSERIAL IN 
	( 
		SELECT DISTINCT WORKERSERIAL FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE = '0012'
		AND PERIODFROM = '26-APR-20'  AND PERIODTO='09-MAY-20' 
	) 
	GROUP BY WORKERSERIAL
)


DIVCODE : 0012, FROMDATE : 26-APR-20, TO DATE : 09-MAY-20, LOAN CODE : MD, BALANCE : 4994





DIVCODE : 0012, FROMDATE : 01-MAY-20, TO DATE : 31-MAY-20, LOAN CODE : ADVGN, BALANCE : 0

DIVCODE : 0012, FROMDATE : 01-MAY-20, TO DATE : 31-MAY-20, LOAN CODE : MD, BALANCE : 0





DIVCODE : 0012, FROMDATE : 10-MAY-20, TO DATE : 23-MAY-20, LOAN CODE : ADVGN, BALANCE : 0

DIVCODE : 0012, FROMDATE : 10-MAY-20, TO DATE : 23-MAY-20, LOAN CODE : MD, BALANCE : 0





DIVCODE : 0012, FROMDATE : 24-MAY-20, TO DATE : 06-JUN-20, LOAN CODE : ADVGN, BALANCE : 0

DIVCODE : 0012, FROMDATE : 24-MAY-20, TO DATE : 06-JUN-20, LOAN CODE : MD, BALANCE : 0





DIVCODE : 0012, FROMDATE : 01-JUN-20, TO DATE : 30-JUN-20, LOAN CODE : ADVGN, BALANCE : 0

DIVCODE : 0012, FROMDATE : 01-JUN-20, TO DATE : 30-JUN-20, LOAN CODE : MD, BALANCE : 0





DIVCODE : 0012, FROMDATE : 07-JUN-20, TO DATE : 20-JUN-20, LOAN CODE : ADVGN, BALANCE : 0

DIVCODE : 0012, FROMDATE : 07-JUN-20, TO DATE : 20-JUN-20, LOAN CODE : MD, BALANCE : 0





DIVCODE : 0012, FROMDATE : 21-JUN-20, TO DATE : 04-JUL-20, LOAN CODE : ADVGN, BALANCE : 0

DIVCODE : 0012, FROMDATE : 21-JUN-20, TO DATE : 04-JUL-20, LOAN CODE : MD, BALANCE : 0





DIVCODE : 0012, FROMDATE : 01-JUL-20, TO DATE : 31-JUL-20, LOAN CODE : ADVGN, BALANCE : 0

DIVCODE : 0012, FROMDATE : 01-JUL-20, TO DATE : 31-JUL-20, LOAN CODE : MD, BALANCE : 0





DIVCODE : 0012, FROMDATE : 05-JUL-20, TO DATE : 18-JUL-20, LOAN CODE : ADVGN, BALANCE : 0

DIVCODE : 0012, FROMDATE : 05-JUL-20, TO DATE : 18-JUL-20, LOAN CODE : MD, BALANCE : 0





DIVCODE : 0012, FROMDATE : 19-JUL-20, TO DATE : 01-AUG-20, LOAN CODE : ADVGN, BALANCE : 0


SELECT /*WORKERSERIAL,*/ NVL(SUM(AMT),0) 
FROM 
(
	SELECT WORKERSERIAL, SUM(NVL(LOAN_MD,0)+NVL(LINT_MD,0)) AMT FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE= '0012' 
	AND PERIODFROM = '19-JUL-20' AND PERIODTO='01-AUG-20'
	GROUP BY WORKERSERIAL
	HAVING SUM(NVL(LOAN_MD,0)+NVL(LINT_MD,0)) > 0
	UNION ALL 
	SELECT WORKERSERIAL, -1*SUM(AMOUNT) AMT FROM LOANBREAKUP WHERE DIVISIONCODE =  '0012'
	AND EFFECTFORTNIGHT = '01-AUG-20'
	AND LOANCODE = 'MD'
	AND MODULE = 'GPS' AND TRANSACTIONTYPE IN ('CAPITAL','INTEREST')
	AND WORKERSERIAL IN 
	( 
		SELECT DISTINCT WORKERSERIAL FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE = '0012'
		AND PERIODFROM = '19-JUL-20'  AND PERIODTO='01-AUG-20' 
	) 
	GROUP BY WORKERSERIAL
)


DIVCODE : 0012, FROMDATE : 19-JUL-20, TO DATE : 01-AUG-20, LOAN CODE : MD, BALANCE : 1625





DIVCODE : 0012, FROMDATE : 02-AUG-20, TO DATE : 15-AUG-20, LOAN CODE : ADVGN, BALANCE : 0

DIVCODE : 0012, FROMDATE : 02-AUG-20, TO DATE : 15-AUG-20, LOAN CODE : MD, BALANCE : 0





DIVCODE : 0012, FROMDATE : 16-AUG-20, TO DATE : 29-AUG-20, LOAN CODE : ADVGN, BALANCE : 0

DIVCODE : 0012, FROMDATE : 16-AUG-20, TO DATE : 29-AUG-20, LOAN CODE : MD, BALANCE : 0





DIVCODE : 0012, FROMDATE : 30-AUG-20, TO DATE : 12-SEP-20, LOAN CODE : ADVGN, BALANCE : 0


SELECT /*WORKERSERIAL,*/ NVL(SUM(AMT),0) 
FROM 
(
	SELECT WORKERSERIAL, SUM(NVL(LOAN_MD,0)+NVL(LINT_MD,0)) AMT FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE= '0012' 
	AND PERIODFROM = '30-AUG-20' AND PERIODTO='12-SEP-20'
	GROUP BY WORKERSERIAL
	HAVING SUM(NVL(LOAN_MD,0)+NVL(LINT_MD,0)) > 0
	UNION ALL 
	SELECT WORKERSERIAL, -1*SUM(AMOUNT) AMT FROM LOANBREAKUP WHERE DIVISIONCODE =  '0012'
	AND EFFECTFORTNIGHT = '12-SEP-20'
	AND LOANCODE = 'MD'
	AND MODULE = 'GPS' AND TRANSACTIONTYPE IN ('CAPITAL','INTEREST')
	AND WORKERSERIAL IN 
	( 
		SELECT DISTINCT WORKERSERIAL FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE = '0012'
		AND PERIODFROM = '30-AUG-20'  AND PERIODTO='12-SEP-20' 
	) 
	GROUP BY WORKERSERIAL
)


DIVCODE : 0012, FROMDATE : 30-AUG-20, TO DATE : 12-SEP-20, LOAN CODE : MD, BALANCE : 600





DIVCODE : 0012, FROMDATE : 13-SEP-20, TO DATE : 26-SEP-20, LOAN CODE : ADVGN, BALANCE : 0

DIVCODE : 0012, FROMDATE : 13-SEP-20, TO DATE : 26-SEP-20, LOAN CODE : MD, BALANCE : 0





