SELECT * FROM WPSWAGESDETAILS_MV WHERE YEARCODE='2020-2021'


DROP DATABASE LINK WPS_2_KIOSK;

CREATE DATABASE LINK WPS_2_KIOSK
 CONNECT TO KIOSK_VSL
 IDENTIFIED BY "KIOSK_VSL"
 USING 'ORA11GHP';
 

CREATE TABLE WPSDAILYWAGESDETAILS AS
SELECT * FROM WPSWAGESDETAILS
WHERE 1=2


CREATE TABLE WPSDAILYWAGESDETAILS_MV AS
SELECT * FROM WPSWAGESDETAILS_MV
WHERE 1=2







CREATE TABLE WPSCASHOTPAYMENTDETAILS
(
    COMPANYCODE VARCHAR2(10) NOT NULL,
    DIVISIONCODE VARCHAR2(10) NOT NULL,
    PAYMENTFROMDATE DATE NOT NULL,
    PAYMENTTODATE DATE NOT NULL,
    SHIFTCODE VARCHAR2(10) NOT NULL,
    DEPARTMENTCODE VARCHAR2(10) NOT NULL,
    DEPARTMENTNAME VARCHAR2(100) NOT NULL,
    TOKENNO VARCHAR2(10) NOT NULL,
    WORKERSERIAL VARCHAR2(10) NOT NULL,
    WORKERNAME VARCHAR2(10) NOT NULL,
    OTHOURS NUMBER(10,2),
    OTAMOUNT NUMBER(10,2),
    ESI_OT NUMBER(10,2),
    NETPAY NUMBER(12,2),
    PAYMENTLOCK VARCHAR2(1) DEFAULT 'N',
    ISTRANSFER VARCHAR2(1) DEFAULT 'N'
)



SELECT COMPANYCODE, DIVISIONCODE, PROCESSTYPE, PROCEDURE_NAME, PHASE, 
CALCULATIONINDEX, PARAM_1, PARAM_2, PARAM_3, PARAM_4, PARAM_5 
FROM WPSWAGESPROCESSTYPE_PHASE
WHERE PROCESSTYPE='WAGES PROCESS'

WHERE PHASE IN (0,1,2,4)



SELECT  DISTINCT PROCEDURE_NAME , PHASE 
FROM WPSWAGESPROCESSTYPE_PHASE
ORDER BY PHASE

PROCEDURE_NAME

PROC_WPSWAGES_OTHER_COMP_UPDT

PROC_WPSWAGESPROCESS_DEDUCTION

PRC_WPS_ATTNINCENTIVE_CALC

PROC_WPSWAGESPROCESS_UPDATE

PROC_WPSWAGESPROCESS_TRANSFER

PROC_WPSWAGESPROCESS_INSERT



--------------------------------------------------------------------------------
--INSERT WAGES PROCESS TYPE PHASE
--------------------------------------------------------------------------------

SET DEFINE OFF;
Insert into WPSWAGESPROCESSTYPE_PHASE
   (COMPANYCODE, DIVISIONCODE, PROCESSTYPE, PROCEDURE_NAME, PHASE, CALCULATIONINDEX, PARAM_1, PARAM_2, PARAM_3, PARAM_4, PARAM_5)
 Values
   ('0003', '0032', 'DAILY WAGES PROCESS', 'PROC_WPSWAGESPROCESS_UPDATE', 11, 
    20, 'WPSWAGESDETAILS_PHASE_11', 'WPSWAGESDETAILS_SWT', NULL, NULL, 
    NULL);
Insert into WPSWAGESPROCESSTYPE_PHASE
   (COMPANYCODE, DIVISIONCODE, PROCESSTYPE, PROCEDURE_NAME, PHASE, CALCULATIONINDEX, PARAM_1, PARAM_2, PARAM_3, PARAM_4, PARAM_5)
 Values
   ('0003', '0032', 'DAILY WAGES PROCESS', 'PROC_WPSWAGESPROCESS_INSERT', 0, 
    10, 'WPSWAGESDETAILS_PHASE_0', 'WPSWAGESDETAILS_SWT', NULL, NULL, 
    NULL);
Insert into WPSWAGESPROCESSTYPE_PHASE
   (COMPANYCODE, DIVISIONCODE, PROCESSTYPE, PROCEDURE_NAME, PHASE, CALCULATIONINDEX, PARAM_1, PARAM_2, PARAM_3, PARAM_4, PARAM_5)
 Values
   ('0003', '0032', 'DAILY WAGES PROCESS', 'PROC_WPSWAGESPROCESS_UPDATE', 12, 
    55, 'WPSWAGESDETAILS_PHASE_12', 'WPSWAGESDETAILS_SWT', NULL, NULL, 
    NULL);
Insert into WPSWAGESPROCESSTYPE_PHASE
   (COMPANYCODE, DIVISIONCODE, PROCESSTYPE, PROCEDURE_NAME, PHASE, CALCULATIONINDEX, PARAM_1, PARAM_2, PARAM_3, PARAM_4, PARAM_5)
 Values
   ('0003', '0032', 'DAILY WAGES PROCESS', 'PRC_WPSATTNINCENTIVE_UPDATE', 0, 
    15, 'WPSWAGESDETAILS_PHASE_0', 'WPSWAGESDETAILS_SWT', NULL, NULL, 
    NULL);
Insert into WPSWAGESPROCESSTYPE_PHASE
   (COMPANYCODE, DIVISIONCODE, PROCESSTYPE, PROCEDURE_NAME, PHASE, CALCULATIONINDEX, PARAM_1, PARAM_2, PARAM_3, PARAM_4, PARAM_5)
 Values
   ('0003', '0032', 'DAILY WAGES PROCESS', 'PROC_WPSWORKERCATEGORY_UPDT', 0, 
    1, 'WPSATTENDANCEDAYWISE', 'WPSATTENDANCEDAYWISE', NULL, NULL, 
    NULL);
Insert into WPSWAGESPROCESSTYPE_PHASE
   (COMPANYCODE, DIVISIONCODE, PROCESSTYPE, PROCEDURE_NAME, PHASE, CALCULATIONINDEX, PARAM_1, PARAM_2, PARAM_3, PARAM_4, PARAM_5)
 Values
   ('0003', '0032', 'DAILY WAGES PROCESS', 'PROC_WPSDAILYPROCESS_TRANSFER', 100, 
    100, 'WPSWAGESDETAILS_SWT', 'WPSWAGESDETAILS_MV_SWT', NULL, NULL, 
    NULL);
COMMIT;

--------------------------------------------------------------------------------

PROCEDURE_NAME    PHASE

PRC_WPSATTNINCENTIVE_UPDATE    0
PRC_WPS_ATTNINCENTIVE_CALC    0
PROC_WPSWAGESPROCESS_INSERT    0
PROC_WPSWORKERCATEGORY_UPDT    0
PROC_WPSWAGESPROCESS_UPDATE    1
PROC_WPSWAGESPROCESS_UPDATE    2
PROC_WPSWAGESPROCESS_UPDATE    3
PROC_WPSWAGESPROCESS_UPDATE    4
PROC_WPSWAGESPROCESS_UPDATE    5
PROC_WPSWAGESPROCESS_DEDUCTION    6
PROC_WPSWAGES_OTHER_COMP_UPDT    7
PROC_WPSWAGESPROCESS_UPDATE    11
PROC_WPSWAGESPROCESS_UPDATE    12
PROC_WPSDAILYPROCESS_TRANSFER    100
PROC_WPSWAGESPROCESS_TRANSFER    100


PRCWPS_COMPONENT_AFTERSAVE


PROC_WPSVIEWCREATION


ALTER TABLE WPSCOMPONENTMASTER
ADD MISCPAYMENT VARCHAR2(1)


--------------------------------------------------------------------------------

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
WHERE COMPONENTNAME IN ('DAILY_ESI')


WHERE COMPONENTNAME IN ('CASHOT_AMOUNT', 'DAILY_ESI')

EXEC PRCWPS_COMPONENT_AFTERSAVE

SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%%')

DELETE FROM MENUMASTER_RND
WHERE MENUCODE='01100412'

SELECT * FROM ROLEDETAILS
WHERE MENUCODE=''

SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG=''
        


 
  SET DEFINE OFF;
Insert into MENUMASTER_RND
   (MENUCODE, MENUNAME, MENUDESC, MENUTYPE, MENUTAG, MENUTAG1, MENUTAG2, ENTRYPOSSIBLE, EDITPOSSIBLE, DELETEPOSSIBLE, REPORTSPOSSIBLE, UTILITIESPOSSIBLE, ACTIVE, PROJECTNAME, MENUDETAILS, EFFECTIVEDIVISION, EFFECTIVEINDIVISION, PROCEDURE_SAVE_EDIT, URLSRC, FRM_HEIGHT, FRM_WIDTH, FUNCTIONCALL_BEFORE, FUNCTIONCALL_AFTER, VIEWPOSSIBLE, PRINTPOSSIBLE, DOCDATEVALIDATEFIELD, AUDITTABLE)
 Values
    ('01100412', NULL, 'Daily Wages Process', 'PROCESS', 'DAILY WAGES PROCESS', 
    NULL, NULL, 'Y', 'N', 'N', 
    'N', 'N', 'Y', 'WPS', NULL, 
    NULL, '''0032''', NULL, 'WPS/Pages/Process/pgWPSDailyWagesProcess.aspx', NULL, 
    NULL, NULL, NULL, 'Y', NULL, 
    NULL, NULL);
COMMIT;
           
 
             
SET DEFINE OFF;
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, SYSROWID)
 Values
   ('1', '01100412', 'Y', 'N', 'N', 
    'X', 'X', 'X', 'X', 'WPS', 
    '201504301142320000273797');
COMMIT;

EXEC prcWPS_Wages_Process('DAILY WAGES PROCESS','0003','0032','2020-2021','SWT','18/12/2020','18/12/2020','') 



EXEC PROC_WPSWAGESPROCESS_INSERT('0003','0032','2020-2021','18/12/2020','18/12/2020','0','WPSWAGESDETAILS_PHASE_0','WPSWAGESDETAILS_SWT','','DAILY WAGES PROCESS')

EXEC PROC_WPSWAGESPROCESS_UPDATE('0003','0032','2020-2021','18/12/2020','18/12/2020','11','WPSWAGESDETAILS_PHASE_11','WPSWAGESDETAILS_SWT','','DAILY WAGES PROCESS')

EXEC PROC_WPSWAGESPROCESS_UPDATE('0003','0032','2020-2021','18/12/2020','18/12/2020','12','WPSWAGESDETAILS_PHASE_12','WPSWAGESDETAILS_SWT','','DAILY WAGES PROCESS')

EXEC PROC_WPSDAILYPROCESS_TRANSFER('0003','0032','2020-2021','18/12/2020','18/12/2020','100','WPSWAGESDETAILS_SWT','WPSWAGESDETAILS_MV_SWT','','DAILY WAGES PROCESS')


TRUNCATE TABLE WPS_ERROR_LOG

SELECT * FROM WPS_ERROR_LOG

SELECT * FROM WPSDAILYWAGESDETAILS

SELECT * FROM WPSWAGESDETAILS_SWT
WHERE NVL(CASHOT_AMOUNT,0) > 0



INSERT INTO WPSWORKERCATEGORYVSCOMPONENT
--
SELECT A.COMPANYCODE, A.DIVISIONCODE, A.EFFECTIVEDATE, A.WORKERCATEGORYCODE, 
B.COMPONENTCODE, B.COMPONENTSHORTNAME, A.APPLICABLE, A.USERNAME, 
SYSDATE LASTMODIFIED, FN_GENERATE_SYSROWID SYSROWID FROM WPSWORKERCATEGORYVSCOMPONENT A,
(
SELECT COMPONENTCODE,COMPONENTSHORTNAME FROM WPSCOMPONENTMASTER
WHERE COMPONENTNAME IN ('CASHOT_AMOUNT', 'DAILY_ESI')
) B
WHERE A.COMPONENTSHORTNAME='OT_AMOUNT'



EXEC PROC_CASHOT_EXPORTTOKIOSK('0003','0032','18/12/2020','18/12/2020')


DELETE FROM WPSCASHOTPAYMENTDETAILS 
WHERE PAYMENTFROMDATE = TO_DATE('18/12/2020','DD/MM/YYYY') 
AND PAYMENTTODATE = TO_DATE('18/12/2020','DD/MM/YYYY') 
AND COMPANYCODE='0003' 
AND DIVISIONCODE='0032' 


SELECT * FROM  WPSCASHOTPAYMENTDETAILS


INSERT INTO WPSCASHOTPAYMENTDETAILS 
(
    COMPANYCODE,DIVISIONCODE,PAYMENTFROMDATE, PAYMENTTODATE, 
    DEPARTMENTCODE, DEPARTMENTNAME, SHIFTCODE,
    TOKENNO,WORKERNAME, WORKERSERIAL, OTHOURS,OTAMOUNT,ESI_OT,  
    NETPAY,PAYMENTLOCK,ISTRANSFER
)

SELECT A.COMPANYCODE,A.DIVISIONCODE,A.FORTNIGHTSTARTDATE PAYMENTFROMDATE, A.FORTNIGHTENDDATE PAYMENTTODATE, 
A.DEPARTMENTCODE, B.DEPARTMENTNAME, DECODE(A.SHIFTCODE,'1','A','2','B','C') SHIFTCODE,
A.TOKENNO,C.WORKERNAME, A.WORKERSERIAL, A.OVERTIMEHOURS OTHOURS,A.CASHOT_AMOUNT OTAMOUNT,A.DAILY_ESI ESI_OT,  
ACTUALPAYBLEAMOUNT NETPAY,'N' PAYMENTLOCK,'N' ISTRANSFER  
FROM WPSDAILYWAGESDETAILS A, WPSDEPARTMENTMASTER B, WPSWORKERMAST C 
WHERE A.COMPANYCODE=B.COMPANYCODE
    AND A.DIVISIONCODE=B.DIVISIONCODE
    AND A.COMPANYCODE=C.COMPANYCODE
    AND A.DIVISIONCODE=C.DIVISIONCODE
    AND A.DEPARTMENTCODE=B.DEPARTMENTCODE
    AND A.WORKERSERIAL=C.WORKERSERIAL
 

