select * from acvoucherdetails_entry

select * from divisionmaster where companycode='GJ0108'

select * from acacledger where divisioncode like '%0001%'

select * from sys_help_qry where qry_id=2026

SELECT PARTYNAME,PARTYCODE,STATE,GROUPHEAD  FROM VW_AC_PARTY 
WHERE COMPANYCODE ='GJ0108'
  --AND DIVISIONCODE like <<DIVISIONCODE>>
ORDER BY PARTYNAME

ACCCHEQUEBOOKMAST

SELECT * FROM ACTDSLEDGERMASTER

SELECT * FROM ACACLEDGER WHERE GROUPTYPE='TDS'


SELECT  A.PARTYCODE||'~'||A.ACCODE||'~'||A.ACTYPE||'~'||A.GROUPTYPE||'~'||A.ISTDSAPPLICABLE||'~'||A.MODULENAME||'~'||B.MAINGROUPCODE
 FROM VW_AC_PARTY A, ACACLEDGER_VW_ALL B
 WHERE A.COMPANYCODE='GJ0108' 
 AND A.COMPANYCODE=B.COMPANYCODE 
 AND A.ACCODE=B.ACCODE 
 AND A.PARTYNAME ='A GOYAL' 
 
 
 
 ALTER TABLE ACTDSDETAILS_ENTRY ADD CASHFLOWCODE VARCHAR2(10)
 
 
 SELECT GROUPTYPE,ACHEAD, ACCODE FROM ACACLEDGER_VW WHERE COMPANYCODE ='GJ0108' 
  AND DIVISIONCODE like'%0001%' 
  AND SHOWINTRANSACTIONS = 'Y' 
  
  AND GROUPTYPE = 'NOTHING' 
  
  
  
  
  SELECT * FROM SYS_HELP_QRY
  WHERE QRY_ID='2058'
  
  SELECT VOUCHERNATURE FROM
(
--SELECT 0 AS TYPE, 'NONE' AS VOUCHERNATURE FROM DUAL
--UNION ALL
SELECT 1 AS TYPE, VOUCHERNATURE FROM ACVOUCHERNATURE 
 WHERE COMPANYCODE=<<COMPANYCODE>>
 AND DIVISIONCODE=<<DIVISIONCODE>>
 AND VOUCHERNATURE LIKE '%ADVANCE%'
 --AND MODULENAME=<<MODULENAME>>
 ) WHERE 1=1
 ORDER BY TYPE, VOUCHERNATURE
 
 SELECT GROUPTYPE,ACHEAD, ACCODE FROM ACACLEDGER_VW WHERE COMPANYCODE ='GJ0108' 
  AND DIVISIONCODE like'%0001%' 
  AND SHOWINTRANSACTIONS = 'Y'
   
  AND GROUPTYPE NOT IN ('CASH','BANK','DEBTORS','CREDITORS') 
  AND ACCODE NOT IN('xx' ) 
  
  
  SELECT NVL(CHECKNOLENGTH, LENGTH(STARTINGSLNO)) CHECKLENGTH 
  FROM ACCCHEQUEBOOKMAST WHERE COMPANYCODE = 'GJ0108' AND DIVISIONCODE = '0001' 
  
  AND CHEQUEBOOKSLNO = ' ' 
  
  ALTER TABLE ACCCHEQUEBOOKMAST ADD CHECKNOLENGTH NUMBER(10)
  
  
  
  
  Data Not Saved ...ORA-01403: no data foundORA-06512: at "GJPL_WEB.PROC_SYNC_ACBRS", line 128ORA-06512: at "GJPL_WEB.PRCAC_LIB_PYMT_BEFORE_MAIN", line 561ORA-06512: at line 1
  
  
  PROC_SYNC_ACBRS
  
  
select accode 
AS lv_AcCode_Opposite 
from acvoucherdetails  
where companycode = 'GJ0108' 
and divisioncode = '0001' 
and yearcode = '2021-2022'
--and systemvoucherno = p_systemvoucherno 
and accode <> c1.accode 
and drcr <> c1.drcr 
and serialno = (select min(serialno) as serialno 
from ACVOUCHERDETAILS  
where companycode = p_companycode 
and divisioncode = p_divisioncode 
and yearcode = p_yearcode 
and systemvoucherno = p_systemvoucherno 
and accode <> c1.accode 
and drcr <> c1.drcr 
); 


PRCAC_LIB_PYMT_BEFORE_MAIN

SELECT * FROM FINANCIALYEAR WHERE COMPANYCODE='GJ0108' AND DIVISIONCODE='0001'

SELECT * FROM DIVISIONMASTER WHERE DIVISIONCODE='0002'

ACTDSLEDGERMASTER


EXEC prc_DeductTDS('GJ0108', '0001','2020-2021','A000368','T000005',10000, '01/04/2021') 
 


FN_GET_SYS_PARAM_VALUE


#SUCCESS#[VOUCHER NUMBER GENERATED: PV/210331/00001 DATED : 31-MAR-21]

SELECT * FROM ACVOUCHER 
WHERE VOUCHERNO='PV/210331/00001'

DJ0108/0001-PVB/2021/00000001


SELECT * FROM ACVOUCHERDETAILS
WHERE SYSTEMVOUCHERNO='DJ0108/0001-PVB/2021/00000001'

SELECT * FROM ACVOUCHERDETAILS_ENTRY
WHERE SYSTEMVOUCHERNO='DJ0108/0001-PVB/2021/00000001'


SELECT * FROM ACVOUCHERDETAILS_PYMT
WHERE SYSTEMVOUCHERNO='DJ0108/0001-PVB/2021/00000001'


SELECT * FROM ACVOUCHER_PYMT
WHERE SYSTEMVOUCHERNO='DJ0108/0001-PVB/2021/00000001'

SELECT * FROM ACVOUCHER_PYMT
WHERE SYSTEMVOUCHERNO='DJ0108/0001-PVB/2021/00000001'


SELECT * FROM ACTDSDETAILS_ENTRY
WHERE SYSTEMVOUCHERNO='DJ0108/0001-PVB/2021/00000001'





PRCCHECKVOUCHERINTEGRITY