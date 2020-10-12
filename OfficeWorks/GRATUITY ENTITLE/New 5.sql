SELECT PARAMETER_VALUE FROM SYS_PARAMETER
WHERE PARAMETER_NAME ='UPLOAD FILE EXTENSIONS'
AND ROWNUM=1

Insert into BIRLANEW.SYS_PARAMETER
   (PARAMETER_NAME, PARAMETER_DESC, PARAMETER_VALUE, PROJECTNAME, COMPANYCODE, 
    LASTMODIFIED, SYSROWID, DIVISIONCODE, USERNAME, ALLOW_CHANGE_FROM_INTERFACE)
 Values
   ('UPLOAD FILE EXTENSIONS', 'UPLOAD FILE EXTENSIONS (RDLC,ASPX)', 'RDLC,ASPX', 'ALL', 'BJ0056', 
    TO_DATE('2/28/2015 10:45:49 PM', 'MM/DD/YYYY HH:MI:SS AM'), '2', '0001', 'SWT', 'SWT TO SET');
COMMIT;
