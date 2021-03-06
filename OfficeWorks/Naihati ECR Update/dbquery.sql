

SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%E%C%R%') AND PROJECTNAME='WPS'

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE='0107030317'
 
EXEC PROC_RPT_ECR('NJ0001','0002','2020-2021','202009','PIS','')

SELECT * FROM PISPAYTRANSACTION


--DELETE FROM PISPAYTRANSACTION


INSERT INTO PISPAYTRANSACTION
(
COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH,EFFECT_YEARMONTH, 
UNITCODE, CATEGORYCODE, GRADECODE,DEPARTMENTCODE, TOKENNO, WORKERSERIAL, 
ATTN_SALD, ATTN_WPAY,ATTN_WRKD, GROSSEARN, PF_GROSS, PEN_GROSS, ESI_GROSS, 
PTAX_GROSS, PF_E, EPF, PF_C, PTAX, ESI_E, ESI_C, LOAN_MPL, LINT_MPL, TRANSACTIONTYPE, PAYMODE
)
SELECT B.COMPANYCODE, B.DIVISIONCODE, B.YEARCODE, YEARMONTH,YEARMONTH EFFECT_YEARMONTH, 
'01' UNITCODE, A.CATEGORYCODE, A.GRADECODE,    A.DEPARTMENTCODE,A.TOKENNO , A.WORKERSERIAL , 
B.ATTN_SALD, B.NCP_DAYS,B.ATTN_SALD ATTN_WRKD, B.GROSSWAGES, B.PF_GROSS, B.PEN_GROSS, B.ESI_GROSS, 
B.PTAX_GROSS, B.PF_E, B.EPF, B.PF_C, B.PTAX, B.ESI_E, B.ESI_C, B.LOAN_MPL, B.LINT_MPL, 
'SALARY'  TRANSACTIONTYPE,'BANK' PAYMODE
FROM 
(
SELECT CATEGORYCODE, GRADECODE,DEPARTMENTCODE,TOKENNO,WORKERSERIAL FROM PISEMPLOYEEMASTER
) A,
(
SELECT COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, UNITCODE, CATEGORYCODE, GRADECODE, LPAD(EMPLOYEECODE,5,'7') TOKENNO , 
ATTN_SALD, NCP_DAYS, GROSSWAGES, PF_GROSS, PEN_GROSS, ESI_GROSS, PTAX_GROSS, PF_E, EPF, PF_C, PTAX, ESI_E, ESI_C, 
LOAN_MPL, LINT_MPL FROM PISSALARYUPLOADRAWDATA
) B
WHERE A.TOKENNO=B.TOKENNO;

SELECT * FROM PFEMPLOYEEMASTER WHERE TOKENNO = '01425'

SELECT * FROM (
SELECT CATEGORYCODE, GRADECODE,DEPARTMENTCODE,TOKENNO,WORKERSERIAL FROM PISEMPLOYEEMASTER
UNION 
SELECT CATEGORYCODE, GRADECODE,DEPARTMENTCODE,TOKENNO,WORKERSERIAL FROM PFEMPLOYEEMASTER
)
WHERE TOKENNO NOT IN (
SELECT DISTINCT LPAD(EMPLOYEECODE,5,'7') TOKENNO FROM PISSALARYUPLOADRAWDATA
)


SELECT * FROM (
SELECT DISTINCT LPAD(EMPLOYEECODE,5,'7') TOKENNO FROM PISSALARYUPLOADRAWDATA
)
WHERE TOKENNO NOT IN 
(
SELECT TOKENNO FROM PISEMPLOYEEMASTER
--    UNION 
--    SELECT TOKENNO FROM PFEMPLOYEEMASTER
)

SELECT * FROM PFEMPLOYEEMASTER WHERE TOKENNO LIKE '%143%'

SELECT * FROM (
SELECT TOKENNO FROM PISEMPLOYEEMASTER
UNION 
SELECT TOKENNO FROM PFEMPLOYEEMASTER
)
WHERE LENGTH(TOKENNO) > 4


SELECT * FROM PISPAYTRANSACTION

SELECT * FROM PISEMPLOYEEMASTER