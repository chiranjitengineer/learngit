SALESOTHERBILLREFDETAILS


SELECT * FROM SYS_PARAMETER

SELECT PARAMETER_VALUE FROM SYS_PARAMETER
WHERE PARAMETER_NAME ='REFERENCE INVOICE TAG IN OTHER SALE'
AND COMPANYCODE='DJ0107'
AND DIVISIONCODE='0002'

SET DEFINE OFF;
Insert into SYS_PARAMETER
   (PARAMETER_NAME, PARAMETER_DESC, PARAMETER_VALUE, PROJECTNAME, COMPANYCODE, LASTMODIFIED, SYSROWID, DIVISIONCODE, USERNAME, ALLOW_CHANGE_FROM_INTERFACE)
 Values
   ('REFERENCE INVOICE TAG IN OTHER SALE', 'REFERENCE INVOICE TAG IN OTHER SALE', 'Y', 'SALES', 'DJ0107', 
    SYSDATE, '2', '0002', 'SWT', 'SWT TO SET');
COMMIT;
