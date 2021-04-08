SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%pay%-%bank%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE=''

SELECT * FROM ROLEDETAILS
WHERE MENUCODE=''

SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG=''



SELECT  A.PARTYCODE||'~'||A.ACCODE||'~'||A.ACTYPE||'~'||A.GROUPTYPE||'~'||A.ISTDSAPPLICABLE||'~'||A.MODULENAME||'~'||B.MAINGROUPCODE
 FROM VW_AC_PARTY A, ACACLEDGER_VW_ALL B
 WHERE A.COMPANYCODE='0002' 
 AND A.COMPANYCODE=B.COMPANYCODE 
 AND A.ACCODE=B.ACCODE 
 AND A.PARTYNAME ='RAMESH TRADING CO.' 
 
 
 
 ALTER TABLE ACTDSDETAILS_ENTRY ADD CASHFLOWCODE VARCHAR2(10)
 
 ALTER TABLE ACVOUCHERDETAILS_PYMT ADD CASHFLOWCODE VARCHAR2(10)
 
-- ACVOUCHERDETAILS_PYMT
-- 
-- 
--  exec prc_DeductTDS('0002', '0022','2021-2022','R000030','T000001',5000, '01/04/2021') 
-- 
 
  ALTER TABLE ACCCHEQUEBOOKMAST ADD CHECKNOLENGTH NUMBER(10) default 6
  
  
--ACVOUCHER_PYMT

--VOUCHERNATURE, PAYMENTINITAITESYSTEMVOUCHERNO, CASHFLOWCODE

alter table ACVOUCHER_PYMT add VOUCHERNATURE VARCHAR2(200 BYTE)


alter table ACVOUCHER_PYMT add PAYMENTINITAITESYSTEMVOUCHERNO VARCHAR2(50 BYTE)


alter table ACVOUCHER_PYMT add CASHFLOWCODE VARCHAR2(10 BYTE)



select * FROM SYS_TFMAP
WHERE SYS_TABLE_SEQUENCIER = '9025'

SELECT * FROM SYS_TFMAP
WHERE SYS_TABLENAME_ACTUAL = 'ACVOUCHER_PYMT'


SELECT * FROM SYS_TFMAP
WHERE SYS_TABLENAME_TEMP = ''

EXEC PROC_CREATE_GBL_TMP_TABLES(9025,0)

PRCCHECKVOUCHERINTEGRITY

ACVOUCHER_UK2


select  COMPANYCODE, DIVISIONCODE, VOUCHERTYPE, NVL(CASHBANKACCODE,SYSTEMVOUCHERNO), NVL(CHEQUEBOOKSLNO,SYSTEMVOUCHERNO), 
NVL(CHEQUENO,SYSTEMVOUCHERNO) from ACVOUCHER


(COMPANYCODE, DIVISIONCODE, VOUCHERTYPE, NVL("CASHBANKACCODE","SYSTEMVOUCHERNO"), NVL("CHEQUEBOOKSLNO","SYSTEMVOUCHERNO"), 
NVL("CHEQUENO","SYSTEMVOUCHERNO"))


select * from acacledger
where achead like 'CASH%'

H000014

SELECT * FROM ACVOUCHERDETAILS_ENTRY WHERE ACCODE ='C000031'

SELECT * FROM ACVOUCHER WHERE SYSTEMVOUCHERNO ='0002/0022-PVB/2122/00000002'

EXEC prc_delete_systemvoucher('0002','0022','2021-2022','0002/0022-PVC/2122/00000002','FORCED') 



SELECT * FROM INFRA_WEB.DIVISIONMASTER  ---0002


INFRA_WEB           ----    0002    (0022,0023)
FORTWILLIAM_WEB     ----    0003    (0032,0033)
BOWREAH_WEB         ----    0004    (0042,0043)
CALJUTE_WEB         ----    0005    (0052,0053)  
HOOGHLY_WEB         ----    0006   (0012,0013)

DELETE FROM HOOGHLY_WEB.SYS_HELP_QRY
WHERE QRY_ID='2058'


INSERT INTO HOOGHLY_WEB.SYS_HELP_QRY
SELECT * FROM INFRA_WEB.SYS_HELP_QRY
WHERE QRY_ID='2058'


SELECT * FROM HOOGHLY_WEB.SYS_HELP_QRY
WHERE QRY_ID='2058'



 
ALTER TABLE HOOGHLY_WEB.ACTDSDETAILS_ENTRY ADD CASHFLOWCODE VARCHAR2(10)
 
ALTER TABLE HOOGHLY_WEB.ACVOUCHERDETAILS_PYMT ADD CASHFLOWCODE VARCHAR2(10) 
 
ALTER TABLE HOOGHLY_WEB.ACCCHEQUEBOOKMAST ADD CHECKNOLENGTH NUMBER(10) DEFAULT 6
   

ALTER TABLE HOOGHLY_WEB.ACVOUCHER_PYMT ADD VOUCHERNATURE VARCHAR2(200 BYTE)


ALTER TABLE HOOGHLY_WEB.ACVOUCHER_PYMT ADD PAYMENTINITAITESYSTEMVOUCHERNO VARCHAR2(50 BYTE)


ALTER TABLE HOOGHLY_WEB.ACVOUCHER_PYMT ADD CASHFLOWCODE VARCHAR2(10 BYTE)



DELETE FROM HOOGHLY_WEB.SYS_TFMAP
WHERE SYS_TABLE_SEQUENCIER = '9025'






INSERT INTO HOOGHLY_WEB.SYS_TFMAP
SELECT * FROM INFRA_WEB.SYS_TFMAP
WHERE SYS_TABLE_SEQUENCIER = '9025'

EXEC HOOGHLY_WEB.PROC_CREATE_GBL_TMP_TABLES(9025,0)


SELECT * FROM HOOGHLY_WEB.SYS_TFMAP
WHERE SYS_TABLE_SEQUENCIER = '9025'
 
 

SELECT * FROM SYS_HELP_QRY
WHERE QRY_ID='2058'