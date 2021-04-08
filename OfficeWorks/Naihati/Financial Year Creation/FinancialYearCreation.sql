EXEC PROC_RPT_STL_SANCTION_FORM('NJ0001', '0002', '07/04/2021','07/04/2021','')

SELECT * FROM GTT_RPT_STL_SANCTION_FORM ORDER BY TO_DATE(DOCUMENTDATE,'DD/MM/YYYY'),TO_NUMBER(DOCUMENTNO),TOKENNO,YEAR


SELECT COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO,DOCUMENTDATE,DEPARTMENTCODE,SHIFTCODE,PAYMENTDATE,LEAVEFROMDATE, 
STLSERIALNO DOCUMENTNO,WM_CONCAT(YEAR) YEAR,SUM(DAYS) DAYS,STLRATE,SECTIONCODE,LEAVEENCASHMENT
FROM
(
SELECT D.COMPANYCODE,D.DIVISIONCODE,D.WORKERSERIAL,D.TOKENNO,D.DOCUMENTDATE,D.DEPARTMENTCODE,D.SHIFTCODE,
D.PAYMENTDATE,D.LEAVEFROMDATE,D.STLSERIALNO,D.YEAR,SUM(D.LEAVEDAYS) DAYS,E.STLRATE,E.SECTIONCODE,E.LEAVEENCASHMENT 
FROM WPSSTLENTRYDETAILS D, WPSSTLENTRY E
WHERE   D.COMPANYCODE=C1.COMPANYCODE
AND D.DIVISIONCODE=C1.DIVISIONCODE
--AND D.TOKENNO=C1.TOKENNO
AND D.PAYMENTDATE='07-APR-2021'
AND D.COMPANYCODE=E.COMPANYCODE
AND D.DIVISIONCODE=E.DIVISIONCODE
AND D.WORKERSERIAL=E.WORKERSERIAL
AND D.TOKENNO=E.TOKENNO
AND D.DOCUMENTNO=E.DOCUMENTNO
AND D.PAYMENTDATE=E.PAYMENTDATE
GROUP BY D.COMPANYCODE,D.DIVISIONCODE,D.WORKERSERIAL,D.TOKENNO,D.DOCUMENTDATE,
D.DEPARTMENTCODE,D.SHIFTCODE,D.PAYMENTDATE,D.LEAVEFROMDATE,D.PAYMENTDATE,D.YEAR,D.STLSERIALNO,
E.STLRATE,E.SECTIONCODE ,E.LEAVEENCASHMENT
ORDER BY D.YEAR
) GROUP BY COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO,DOCUMENTDATE,
DEPARTMENTCODE,SHIFTCODE,PAYMENTDATE,LEAVEFROMDATE,PAYMENTDATE,STLSERIALNO,STLRATE,SECTIONCODE,LEAVEENCASHMENT



SELECT * FROM WPSSTLENTRYDETAILS
WHERE 1=1 -- STLSERIALNO='C'
AND DOCUMENTDATE >= '01-APR-2021'



SELECT * FROM WPSSTLENTRY
WHERE 1=1 -- STLSERIALNO='C'
AND DOCUMENTDATE >= '01-APR-2021'


UPDATE WPSSTLENTRY SET 
YEARCODE='2021-2022' 
WHERE 1=1
AND DOCUMENTDATE >= '01-APR-2021'



UPDATE WPSSTLENTRYDETAILS SET 
YEARCODE='2021-2022' 
WHERE 1=1
AND DOCUMENTDATE >= '01-APR-2021'




SELECT* FROM WPSSTLENTRYDETAILS
WHERE 1=1 -- STLSERIALNO='C'
AND DOCUMENTDATE >= '01-APR-2021'




SELECT * FROM WPSSTLENTRYDETAILS


WHERE STLSERIALNO<>'C'


SELECT * FROM FINANCIALYEAR



WHERE TOKENNO='04268'


WHERE STLSERIALNO='C'


SELECT * FROM SYS_TFMAP
WHERE SYS_TABLE_SEQUENCIER = ''

SELECT * FROM SYS_TFMAP
WHERE SYS_TABLENAME_ACTUAL = 'WPSSTLENTRYDETAILS'

STLSERIALNO

SELECT * FROM SYS_TFMAP
WHERE SYS_TABLENAME_TEMP = ''



INSERT INTO FINANCIALYEAR
select 
'2021-2022' YEARCODE, 
AUTORATE, STARTINGPONO, STARTINGMRNO, STARTINGSETTLNO, ADJUSTABLEEXCESSBALE, MINSTOCKDIRECTITEM, MINSTOCKINDIRECTITEM, 
ROLLSPERBALE, CUTTINGMILLGRADE, CADIESMILLGRADE, THREADWASTEMILLGRADE, ROPESMILLGRADE, SALESTAXPERCENTAGE, ACDEBTORSCODE, 
ACCREDITORSCODE, ACTDSCODE, ACJOURNALPREFIX, ACPURCHASEBILLPREFIX, ACSALESBILLPREFIX, ACPAYMENTVOUCHERPREFIX, ACCONTRAPREFIX, 
ACRECEIPTVOUCHERPREFIX, ACVOUCHERDATEFORMAT, ACSALESGLCODE, ACPURCHASEGLCODE, ACMAXIMUMVOUCHERLENGTH, JUTECREDITORS, 
JUTEALLOWANCE, JUTEPURCHASE, JUTECHARGES, SALESWBSTCODE, SALESCSTCODE, SALESCESSCODE, SALESEDUCATIONCESSCODE, 
STORESCREDITORS, STORESPURCHASE, PRINTSTARINCHEQUE, FINYEARCLOSED, ITEMPERINDENT, ADJUSTMENTPERIOD, ROUNDINGOFFITEM, 
JUTECREDITORSIMP, JBRNOPREFIX, COMPANYCODE, DIVISIONCODE, SBRNOPREFIX, CANCELGRACEPR, STORESVATAC, ACCASHPAYMENTVOUCHERPREFIX, 
ACCASHRECEIPTVOUCHERPREFIX, SHOWLEDGERBALANCE, LASTJUTERECONCILIATIONDATEFROM, ACCODEPROFITANDLOSS, ACCODEJUTESALES, 
ACGROUPJUTESALESDEBTORS, ACCODESCRAPSALES, ACCODEMATERIALSALES, ACGROUPSCRAPSALES, ACGROUPMATERIALSALES, 
ACCODEOUTSIDEPURCHASE_TRADING, ACCODEOUTSIDEPURCHASE_OWNCONS, ACGROUPOUTSIDEPURCHASE_TRADING, ACGROUPOUTSIDEPURCHASE_OWNCONS, 
AUTOCHEQUENUMBER, ACVOUCHERBILLWISEBREAKUP, PISCOSTCENTREWISEPOSTING, JUTEORDERPREFIX, DEFAULTBANKPAYMENT, DEFAULTCASHPAYMENT, 
DEFAULTBANKRECEIPT, DEFAULTCASHRECEIPT, ACCODE_BROKERAGEEXP, ACLEDGERCODEFORBROKERAGEEXP, ACCODEFORBROKERAGEPROVLIA, 
JUTEORDERPREFIX_IMPORTED, JUTEORDERPREFIX_JCI, JUTEDISCOUNTPERCENTAGE, JUTEDISCOUNTLEDGER, STORE_BILLDISCOUNTPERCENTAGE, STORE_BILLDISCOUNTLEDGER, 
'01-APR-2021' STARTDATE, '31-MAR-2022' ENDDATE
from FINANCIALYEAR where yearcode='2020-2021'

SELECT * FROM FINANCIALYEAR WHERE YEARCODE = '2020-2021'

SELECT * FROM LOCKDATE  

INSERT INTO SYS_AUTOGEN_PARAMS
SELECT 
COMPANYCODE, DIVISIONCODE, 
'2021-2022' YEARCODE,
PARAM_NAME, TOT_LENGTH, PREFIX, SUFFIX, ACT_TABLENAME, ACT_COL_NAME, PADDING_LENGTH, SEQUENCER_NAME, PURPOSE
 FROM SYS_AUTOGEN_PARAMS
WHERE YEARCODE = '2020-2021'

COMMIT

SELECT * FROM SYS_AUTOGEN_PARAMS
WHERE YEARCODE = '2021-2022'

For wages only::

exec PRCWPS_WAGESPERIOD_DECLARE('0004',  '0042', '2020-2021','F' ,'01/04/2020', '31/03/2021',  'SWT' )

SELECT * FROM WPSWAGEDPERIODDECLARATION
WHERE YEARCODE='2021-2022'

