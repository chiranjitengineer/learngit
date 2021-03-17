select * from login



SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%COMP%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE='01100509'

SELECT * FROM ROLEDETAILS
WHERE MENUCODE='01100509'

SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG=''


SET DEFINE OFF;
Insert into MENUMASTER_RND
   (MENUCODE, MENUNAME, MENUDESC, MENUTYPE, MENUTAG, MENUTAG1, MENUTAG2, ENTRYPOSSIBLE, EDITPOSSIBLE, DELETEPOSSIBLE, REPORTSPOSSIBLE, UTILITIESPOSSIBLE, ACTIVE, PROJECTNAME, MENUDETAILS, EFFECTIVEDIVISION, EFFECTIVEINDIVISION, PROCEDURE_SAVE_EDIT, URLSRC, FRM_HEIGHT, FRM_WIDTH, FUNCTIONCALL_BEFORE, FUNCTIONCALL_AFTER, VIEWPOSSIBLE, PRINTPOSSIBLE, DOCDATEVALIDATEFIELD, KEY_TABLE, AUDITTABLE)
 Values
   ('01100509', NULL, 'Cash OT Import from KIOSK', 'UTILITIES', 'CASH OT IMPORT FROM KIOSK', 
    NULL, NULL, 'Y', 'N', 'N', 
    'N', 'N', 'Y', 'WPS', NULL, 
    '''0032''', '''0032''', NULL, 'WPS/Pages/Utilities/pgCashOTExportToKIOSK.aspx', NULL, 
    NULL, NULL, NULL, 'Y', NULL, 
    NULL, NULL, NULL);
COMMIT;



SET DEFINE OFF;
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, SYSROWID)
 Values
   ('1', '01100509', 'Y', 'X', 'X', 
    'X', 'X', 'X', 'X', 'WPS', 
    '201903051523240001188468');
COMMIT;




select  * from WPSCASHOTPAYMENTDETAILS@WPS_2_KIOSK

UPDATE  WPSCASHOTPAYMENTDETAILS@WPS_2_KIOSK
SET PAYMENTLOCK = 'Y'
, ISTRANSFER = 'N'


SELECT * FROM WPSUNREALIZEDDATA




SET DEFINE OFF;
Insert into WPSCOMPONENTMASTER
   (COMPANYCODE, DIVISIONCODE, COMPONENTCODE, COMPONENTNAME, COMPONENTSHORTNAME, COMPONENTTYPE, AMOUNTORFORMULA, MANUALFORAMOUNT, FORMULA, CALCULATIONINDEX, PRINTINDEX, LEDGERACCOUNT, DEPENDENTONOTHERCOMPONENT, EMPLOYEECONTIBUTION, COMPANYCONTIBUTION, PAYSLIPPRINT, COMPONENTTAG, SALARYREGISTERROWNO, SALARYREGISTERCOLSTART, SALARYREGISTERCOLWIDTH, PAYSLIPROWNO, PAYSLIPCOLSTART, PAYSLIPCOLWIDTH, COMPONENTGROUP, PHASE, TAKEPARTINWAGES, COLUMNINATTENDANCE, LASTMODIFIED, USERNAME, SYSROWID, MASTERCOMPONENT, PARTIALLYDEDUCT, NAMETOPRINT, INCLUDEARREAR, SRL, MISCPAYMENT)
 Values
   ('0003', '0032', 'DAILY_ESI', 'DAILY_ESI', 'DAILY_ESI', 
    'DEDUCTION', 'FORMULA', NULL, 'CASE WHEN MAST.ESIAPPLICABLE = ''Y'' THEN  CEIL(TRUNC(COMPONENT.CASHOT_AMOUNT *0.0075,2)) ELSE 0 END', 800, 
    NULL, NULL, NULL, NULL, NULL, 
    NULL, 'N', NULL, NULL, NULL, 
    NULL, NULL, NULL, NULL, 12, 
    'Y', 'Y', TO_DATE('02/08/2021 15:21:30', 'MM/DD/YYYY HH24:MI:SS'), 'SWT', '202102081521300001906281', 
    NULL, NULL, 'DAILY_ESI', 'N', 0, 
    'Y');
Insert into WPSCOMPONENTMASTER
   (COMPANYCODE, DIVISIONCODE, COMPONENTCODE, COMPONENTNAME, COMPONENTSHORTNAME, COMPONENTTYPE, AMOUNTORFORMULA, MANUALFORAMOUNT, FORMULA, CALCULATIONINDEX, PRINTINDEX, LEDGERACCOUNT, DEPENDENTONOTHERCOMPONENT, EMPLOYEECONTIBUTION, COMPANYCONTIBUTION, PAYSLIPPRINT, COMPONENTTAG, SALARYREGISTERROWNO, SALARYREGISTERCOLSTART, SALARYREGISTERCOLWIDTH, PAYSLIPROWNO, PAYSLIPCOLSTART, PAYSLIPCOLWIDTH, COMPONENTGROUP, PHASE, TAKEPARTINWAGES, COLUMNINATTENDANCE, LASTMODIFIED, USERNAME, SYSROWID, MASTERCOMPONENT, PARTIALLYDEDUCT, NAMETOPRINT, INCLUDEARREAR, SRL, MISCPAYMENT)
 Values
   ('0003', '0032', 'CASHOT_AMT', 'CASHOT_AMOUNT', 'CASHOT_AMOUNT', 
    'OTHERS', 'FORMULA', NULL, ' ROUND((ROUND((NVL(MAST.ADHOCRATE,0)+NVL(MAST.FIXEDBASIC,0) + NVL(MAST.ADDLBASIC_RATE,0) + NVL(MAST.DARATE,0))/208,2))*ATTN.OVERTIMEHOURS,0)', 599, 
    NULL, NULL, NULL, NULL, NULL, 
    NULL, 'N', NULL, NULL, NULL, 
    NULL, NULL, NULL, NULL, 11, 
    'Y', NULL, TO_DATE('02/10/2021 15:47:34', 'MM/DD/YYYY HH24:MI:SS'), 'SWT', '202102101547330001906376', 
    NULL, NULL, 'CASHOT_AMOUNT', 'N', 0, 
    'Y');
COMMIT;


SELECT 
COMPANYCODE, DIVISIONCODE, COMPONENTCODE, COMPONENTNAME, COMPONENTSHORTNAME, COMPONENTGROUP, 
COMPONENTTYPE, FORMULA, CALCULATIONINDEX, PHASE, AMOUNTORFORMULA, TAKEPARTINWAGES, 
COLUMNINATTENDANCE, SYSROWID, USERNAME, MASTERCOMPONENT, NAMETOPRINT, INCLUDEARREAR, 
PAYSLIPROWNO, PAYSLIPCOLWIDTH, PAYSLIPCOLSTART, SALARYREGISTERCOLWIDTH, SALARYREGISTERCOLSTART, 
SALARYREGISTERROWNO, COMPONENTTAG, PAYSLIPPRINT, COMPANYCONTIBUTION, LEDGERACCOUNT, MANUALFORAMOUNT, 
OPERATIONMODE, PRINTINDEX, EMPLOYEECONTIBUTION, DEPENDENTONOTHERCOMPONENT
GBL_WPSCOMPONENTMASTER
WHERE COMPONENTNAME IN ('CASHOT_AMOUNT', 'DAILY_ESI')


INSERT INTO GBL_WPSCOMPONENTMASTER
SELECT 
COMPANYCODE, DIVISIONCODE, COMPONENTCODE, COMPONENTNAME, COMPONENTSHORTNAME, COMPONENTGROUP, 
COMPONENTTYPE, FORMULA, CALCULATIONINDEX, PHASE, AMOUNTORFORMULA, TAKEPARTINWAGES, 
COLUMNINATTENDANCE, SYSROWID, USERNAME, MASTERCOMPONENT, NAMETOPRINT, INCLUDEARREAR, 
PAYSLIPROWNO, PAYSLIPCOLWIDTH, PAYSLIPCOLSTART, SALARYREGISTERCOLWIDTH, SALARYREGISTERCOLSTART, 
SALARYREGISTERROWNO, COMPONENTTAG, PAYSLIPPRINT, COMPANYCONTIBUTION, LEDGERACCOUNT, MANUALFORAMOUNT, 
'M' OPERATIONMODE, PRINTINDEX, EMPLOYEECONTIBUTION, DEPENDENTONOTHERCOMPONENT
FROM WPSCOMPONENTMASTER
WHERE COMPONENTCODE IN ('CASH_RLZ')

SELECT * FROM WPSCOMPONENTMASTER
WHERE COMPONENTCODE ='CASH_RLZ'


SELECT * FROM GBL_WPSCOMPONENTMASTER


---INSERT SCRIPT COMPONENT CASH_RLZ

SET DEFINE OFF;
Insert into WPSCOMPONENTMASTER
   (COMPANYCODE, DIVISIONCODE, COMPONENTCODE, COMPONENTNAME, COMPONENTSHORTNAME, COMPONENTTYPE, AMOUNTORFORMULA, MANUALFORAMOUNT, FORMULA, CALCULATIONINDEX, PRINTINDEX, LEDGERACCOUNT, DEPENDENTONOTHERCOMPONENT, EMPLOYEECONTIBUTION, COMPANYCONTIBUTION, PAYSLIPPRINT, COMPONENTTAG, SALARYREGISTERROWNO, SALARYREGISTERCOLSTART, SALARYREGISTERCOLWIDTH, PAYSLIPROWNO, PAYSLIPCOLSTART, PAYSLIPCOLWIDTH, COMPONENTGROUP, PHASE, TAKEPARTINWAGES, COLUMNINATTENDANCE, LASTMODIFIED, USERNAME, SYSROWID, INCLUDEARREAR, MASTERCOMPONENT, NAMETOPRINT, PARTIALLYDEDUCT, SRL, MISCPAYMENT)
 Values
   ('0003', '0032', 'CASH_RLZ', 'CASH_REALIZE', 'CASH_REALIZE', 
    'DEDUCTION', 'AMOUNT', NULL, NULL, 212, 
    NULL, NULL, 'No', 'Yes', 'No', 
    NULL, 'N', NULL, NULL, NULL, 
    NULL, NULL, NULL, NULL, 6, 
    'Y', 'N', TO_DATE('01/29/2016 15:13:13', 'MM/DD/YYYY HH24:MI:SS'), 'SWT', '201601291513070000875094', 
    NULL, NULL, NULL, 'N', 0, 
    NULL);
COMMIT;


prcWPS_Component_b4Save

EXEC PRCWPS_COMPONENT_AFTERSAVE


SELECT * FROM WPSWAGESDETAILS



CREATE TABLE GBL_UNREALIZED_BLNC
(
  COMPANYCODE        VARCHAR2(10 BYTE),
  DIVISIONCODE       VARCHAR2(10 BYTE),     
  WORKERSERIAL       VARCHAR2(10 BYTE),
  TOKENNO            VARCHAR2(10 BYTE),
  COMPONENTCODE      VARCHAR2(20 BYTE),
  COMPONENT_BALANCE  NUMBER(11,2),
  COMPONENT_EMI      NUMBER(11,2),
  MODULE             VARCHAR2(10 BYTE)
)


    --  SHOP RENT DATA PREPARATION PROCEDURE CALL
    PROC_SHOPRENT_BLNC (P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'SHOP_RENT', P_YEARCODE ,'WPS','YES',NULL);    


SELECT * FROM WPSUNREALIZEDDATA

DELETE 


SELECT *
FROM WPSUNREALIZEDDATA
WHERE COMPANYCODE = '0003' AND DIVISIONCODE = '0032' 
AND TRANTYPE IN ('UNREALIZED') 
AND COMPONENTCODE ='CASHOT_AMT' 
AND FORTNIGHTSTARTDATE = TO_DATE('25/12/2020','DD/MM/YYYY')
AND FORTNIGHTENDDATE = TO_DATE('25/12/2020','DD/MM/YYYY')



SELECT *
FROM WPSUNREALIZEDDATA
WHERE COMPANYCODE = '0003' AND DIVISIONCODE = '0032' 
AND TRANTYPE IN ('UNREALIZED','REALIZED') 
AND COMPONENTCODE ='CASHOT_AMT' 
AND FORTNIGHTSTARTDATE = TO_DATE('25/12/2020','DD/MM/YYYY')
AND FORTNIGHTENDDATE = TO_DATE('25/12/2020','DD/MM/YYYY')




SELECT WORKERSERIAL, TOKENNO, CASHOT_EMI, CASHOT_UNREALIZED, MODULE
FROM GBL_CASHOTUNREALIZED


SELECT * FROM WPSUNREALIZEDDATA

INSERT INTO GBL_CASHOTUNREALIZED
(
     WORKERSERIAL, TOKENNO, MODULE, CASHOT_EMI, CASHOT_UNREALIZED
)
SELECT WORKERSERIAL,TOKENNO,MODULE, SUM(COMPONENTAMOUNT) CASHOT_EMI, SUM(COMPONENTAMOUNT) UNREALIZEDAMOUNT
FROM WPSUNREALIZEDDATA
WHERE COMPANYCODE = '0003'
AND DIVISIONCODE = '0032'
AND COMPONENTCODE = 'CASHOT_AMT'
AND TRANTYPE IN('REALIZED','UNREALIZED')
AND YEARCODE = '2020-2021'
AND FORTNIGHTENDDATE < TO_DATE('25/12/2021','DD/MM/YYYY')
GROUP BY WORKERSERIAL,TOKENNO,MODULE

DELETE FROM GBL_CASHOTUNREALIZED


SELECT * FROM GBL_CASHOTUNREALIZED


  SELECT YEARCODE AS LV_YEARCODE FROM FINANCIALYEAR
    WHERE TO_DATE('25/12/2020','DD/MM/YYYY') BETWEEN STARTDATE AND ENDDATE
    AND ROWNUM=1;

SELECT * FROM WPSUNREALIZEDDATA

SELECT  * FROM SYS_GBL_PROCOUTPUT_INFO 

EXEC PROC_CASHOT_IMPORTFROMKIOSK('0003','0032','16/12/2020','16/12/2021')
       

SELECT * FROM WPSWAGEDPERIODDECLARATION

SELECT TO_CHAR(FORTNIGHTSTARTDATE,'DD/MM/YYYY') STARTDATE, TO_CHAR(FORTNIGHTENDDATE,'DD/MM/YYYY') ENDDATE 
FROM WPSWAGEDPERIODDECLARATION
WHERE COMPANYCODE='0003'
AND DIVISIONCODE='0032'
AND YEARCODE='2020-2021'
ORDER BY TO_DATE(STARTDATE,'DD/MM/YYYY')


SELECT * FROM WPS_error_log

TRUNCATE TABLE WPS_error_log


EXEC PROC_CASHOT_BLNC ('0003','0032','25/12/2020','25/12/2020','CASHOT_AMT','2020-2021')


SELECT * FROM WPSWAGESDETAILS    

SELECT OTHR_DEDN,CASH_REALIZE FROM WPSWAGESDETAILS   
WHERE COMPANYCODE='0003'
AND DIVISIONCODE='0032'
AND YEARCODE='2020-2021'


UPDATE WPSWAGESDETAILS SET OTHR_DEDN = NVL(OTHR_DEDN,0)+ NVL(CASH_REALIZE,0)
WHERE COMPANYCODE='0003'
AND DIVISIONCODE='0032'
AND FORTNIGHTSTARTDATE = TO_DATE('01/01/2021','DD/MM/YYYY')
AND FORTNIGHTENDDATE = TO_DATE('01/01/2021','DD/MM/YYYY')



SELECT * FROM WPSCOMPONENTMASTER
WHERE  COMPONENTNAME LIKE 'NPF%'


INSERT INTO WPSUNREALIZEDDATA
(
    COMPANYCODE, DIVISIONCODE, YEARCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERSERIAL, TOKENNO, 
    COMPONENTCODE, COMPONENTAMOUNT, ACTUALAMOUNT, REFERENCE_FNEDATE, PAIDON, TRANTYPE, MODULE, REMARKS, 
    USERNAME, SYSROSWID, LASTMODIFIED, DOCNO, DOCDATE, TRAN_SOURCE
)
SELECT
COMPANYCODE, DIVISIONCODE, YEARCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERSERIAL, TOKENNO, 
'CASHOT_AMT' COMPONENTCODE,CASH_REALIZE COMPONENTAMOUNT,CASH_REALIZE ACTUALAMOUNT,FORTNIGHTENDDATE REFERENCE_FNEDATE,
FORTNIGHTENDDATE PAIDON,'REALIZED' TRANTYPE,'WPS' MODULE,'REALIZED AMOUNT THROUGH WAGES PROCESS' REMARKS, 
'SWT' USERNAME, FN_GENERATE_SYSROWID SYSROSWID,SYSDATE LASTMODIFIED,NULL DOCNO,NULL DOCDATE,NULL TRAN_SOURCE
FROM WPSWAGESDETAILS
WHERE COMPANYCODE='0003'
AND DIVISIONCODE='0032'
AND FORTNIGHTSTARTDATE = TO_DATE('01/01/2021','DD/MM/YYYY')
AND FORTNIGHTENDDATE = TO_DATE('01/01/2021','DD/MM/YYYY')
AND NVL(CASH_REALIZE,0) > 0






INSERT INTO WPSWORKERCATEGORYVSCOMPONENT
--
SELECT A.COMPANYCODE, A.DIVISIONCODE, A.EFFECTIVEDATE, A.WORKERCATEGORYCODE, 
B.COMPONENTCODE, B.COMPONENTSHORTNAME, A.APPLICABLE, A.USERNAME, 
SYSDATE LASTMODIFIED, FN_GENERATE_SYSROWID SYSROWID FROM WPSWORKERCATEGORYVSCOMPONENT A,
(
SELECT COMPONENTCODE,COMPONENTSHORTNAME FROM WPSCOMPONENTMASTER
WHERE COMPONENTNAME IN ('CASH_REALIZE')
) B
WHERE A.COMPONENTSHORTNAME='OT_AMOUNT'


