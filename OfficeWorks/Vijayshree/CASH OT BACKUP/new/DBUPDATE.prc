
----------------------------------------------------------------------------------
--INSERT SCRIPT FOR WPSWAGESPROCESSTYPE_PHASE
----------------------------------------------------------------------------------

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
   ('0003', '0032', 'DAILY WAGES PROCESS', 'PROC_WPSDAILYPROCESS_TRANSFER', 100, 
    100, 'WPSWAGESDETAILS_SWT', 'WPSWAGESDETAILS_MV_SWT', NULL, NULL, 
    NULL);
COMMIT;


----------------------------------------------------------------------------------
--INSERT SCRIPT FOR SYS_PARAMETER
----------------------------------------------------------------------------------
SET DEFINE OFF;
Insert into SYS_PARAMETER
   (PARAMETER_NAME, PARAMETER_DESC, PARAMETER_VALUE, PROJECTNAME, COMPANYCODE, LASTMODIFIED, SYSROWID, DIVISIONCODE, USERNAME, ALLOW_CHANGE_FROM_INTERFACE)
 Values
   ('KIOSK DBLINK', 'KIOSK DBLINK', 'WPS_2_KIOSK', 'WPS', '0003', 
    TO_DATE('04/27/2018 11:24:01', 'MM/DD/YYYY HH24:MI:SS'), '0003003200001', '0032', 'SWT', 'SWT TO SET');
COMMIT;

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

CREATE TABLE WPSWAGESDETAILS_150221 AS
SELECT * FROM WPSWAGESDETAILS


CREATE TABLE WPSWAGESDETAILS_MV_150221 AS
SELECT * FROM WPSWAGESDETAILS_MV



----------------------------------------------------------------------------------

ALTER TABLE WPSCOMPONENTMASTER
ADD MISCPAYMENT VARCHAR2(1)

----------------------------------------------------------------------------------


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

 

SELECT * FROM GBL_WPSCOMPONENTMASTER
 

INSERT INTO GBL_WPSCOMPONENTMASTER
SELECT 
COMPANYCODE, DIVISIONCODE, COMPONENTCODE, COMPONENTNAME, COMPONENTSHORTNAME, COMPONENTGROUP, 
COMPONENTTYPE, FORMULA, CALCULATIONINDEX, PHASE, AMOUNTORFORMULA, TAKEPARTINWAGES, 
COLUMNINATTENDANCE, SYSROWID, USERNAME, MASTERCOMPONENT, NAMETOPRINT, INCLUDEARREAR, 
PAYSLIPROWNO, PAYSLIPCOLWIDTH, PAYSLIPCOLSTART, SALARYREGISTERCOLWIDTH, SALARYREGISTERCOLSTART, 
SALARYREGISTERROWNO, COMPONENTTAG, PAYSLIPPRINT, COMPANYCONTIBUTION, LEDGERACCOUNT, MANUALFORAMOUNT, 
'M' OPERATIONMODE, PRINTINDEX, EMPLOYEECONTIBUTION, DEPENDENTONOTHERCOMPONENT
FROM WPSCOMPONENTMASTER
WHERE COMPONENTNAME IN ('CASHOT_AMOUNT')

SELECT * FROM WPSCOMPONENTMASTER
WHERE COMPONENTNAME IN ('CASHOT_AMOUNT', 'DAILY_ESI')

EXEC PRCWPS_COMPONENT_AFTERSAVE

SELECT * FROM WPSCOMPONENTMASTER



----------------------------------------------------------------------------------



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

SELECT * FROM WPSCOMPONENTMASTER
WHERE COMPONENTNAME IN ('DAILY_ESI')

EXEC PRCWPS_COMPONENT_AFTERSAVE

SELECT * FROM WPSCOMPONENTMASTER



----------------------------------------------------------------------------------


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


SELECT * FROM WPSWORKERCATEGORYVSCOMPONENT
WHERE COMPONENTCODE IN ('DAILY_ESI')

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
