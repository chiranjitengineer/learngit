SELECT * FROM SYS_PARAMETER


SET DEFINE OFF;
Insert into SYS_PARAMETER
   (PARAMETER_NAME, PARAMETER_DESC, PARAMETER_VALUE, PROJECTNAME, COMPANYCODE, LASTMODIFIED, SYSROWID, DIVISIONCODE, USERNAME, ALLOW_CHANGE_FROM_INTERFACE)
 Values
   ('CASH OT ROUNDOFF TYPE', 'CASH OT ROUNDOFF TYPE', 'L', 'WPS', '0003', 
    TO_DATE('04/27/2018 11:24:01', 'MM/DD/YYYY HH24:MI:SS'), '0003003200001', '0032', 'SWT', 'SWT TO SET');
COMMIT;


SET DEFINE OFF;
Insert into SYS_PARAMETER
   (PARAMETER_NAME, PARAMETER_DESC, PARAMETER_VALUE, PROJECTNAME, COMPANYCODE, LASTMODIFIED, SYSROWID, DIVISIONCODE, USERNAME, ALLOW_CHANGE_FROM_INTERFACE)
 Values
   ('CASH OT ROUNDOFF AMOUNT', 'CASH OT ROUNDOFF AMOUNT', '5', 'WPS', '0003', 
    TO_DATE('04/27/2018 11:24:01', 'MM/DD/YYYY HH24:MI:SS'), '0003003200001', '0032', 'SWT', 'SWT TO SET');
COMMIT;


SELECT  NVL(ROUND_TYPE,'X'),NVL(TO_NUMBER(ROUND_AMT),0)  
FROM
(
    SELECT 1 SL FROM DUAL
) A
,
(
SELECT 1 SL,PARAMETER_VALUE  ROUND_TYPE FROM SYS_PARAMETER
WHERE PARAMETER_NAME='CASH OT ROUNDOFF AMOUNT1'
) B,
(
SELECT 1 SL, PARAMETER_VALUE ROUND_AMT FROM SYS_PARAMETER
WHERE PARAMETER_NAME='CASH OT ROUNDOFF TYPE1'
) C
WHERE A.SL=B.SL(+)
AND A.SL=C.SL(+);