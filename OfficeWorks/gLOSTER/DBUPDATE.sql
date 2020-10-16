Insert into GLOSTER_WEB.SYS_PARAMETER
   (PARAMETER_NAME, PARAMETER_DESC, PARAMETER_VALUE, PROJECTNAME, COMPANYCODE, 
    LASTMODIFIED, SYSROWID, DIVISIONCODE, USERNAME, ALLOW_CHANGE_FROM_INTERFACE)
 Values
   ('LOGIN VALIDATION', 'USER LOGIN VALIDATION', 'YES', 'GENERAL', '0002', 
    TO_DATE('9/29/2020 2:06:03 AM', 'MM/DD/YYYY HH:MI:SS AM'), 'B53CA7FEC0BF412EB8FF3DD1E215DB41', '0010', 'SWT', 'SWT TO SET');
Insert into GLOSTER_WEB.SYS_PARAMETER
   (PARAMETER_NAME, PARAMETER_DESC, PARAMETER_VALUE, PROJECTNAME, COMPANYCODE, 
    LASTMODIFIED, SYSROWID, DIVISIONCODE, USERNAME, ALLOW_CHANGE_FROM_INTERFACE)
 Values
   ('STRONG PASSWORD CHARACTER', 'STRONG PASSWORD CHARACTER', '@.', 'GENERAL', '0002', 
    TO_DATE('9/29/2020 2:06:03 AM', 'MM/DD/YYYY HH:MI:SS AM'), 'ECAB027F27C9488A913ED2D13C61F0C0', '0010', 'SWT', 'SWT TO SET');
Insert into GLOSTER_WEB.SYS_PARAMETER
   (PARAMETER_NAME, PARAMETER_DESC, PARAMETER_VALUE, PROJECTNAME, COMPANYCODE, 
    LASTMODIFIED, SYSROWID, DIVISIONCODE, USERNAME, ALLOW_CHANGE_FROM_INTERFACE)
 Values
   ('MINIMUM PASSWORD LENGTH', 'MINIMUM PASSWORD LENGTH', '7', 'GENERAL', '0002', 
    TO_DATE('9/29/2020 2:06:03 AM', 'MM/DD/YYYY HH:MI:SS AM'), '454FD5470B614CA28595A71BB5F88949', '0010', 'SWT', 'SWT TO SET');
Insert into GLOSTER_WEB.SYS_PARAMETER
   (PARAMETER_NAME, PARAMETER_DESC, PARAMETER_VALUE, PROJECTNAME, COMPANYCODE, 
    LASTMODIFIED, SYSROWID, DIVISIONCODE, USERNAME, ALLOW_CHANGE_FROM_INTERFACE)
 Values
   ('NO OF WRONG PASSWORD ATTEMPT', 'NO OF WRONG PASSWORD ATTEMPT', '3', 'GENERAL', '0002', 
    TO_DATE('9/29/2020 2:06:03 AM', 'MM/DD/YYYY HH:MI:SS AM'), '887F499BF42846F0A46A0FCA658A6DE4', '0010', 'SWT', 'SWT TO SET');
Insert into GLOSTER_WEB.SYS_PARAMETER
   (PARAMETER_NAME, PARAMETER_DESC, PARAMETER_VALUE, PROJECTNAME, COMPANYCODE, 
    LASTMODIFIED, SYSROWID, DIVISIONCODE, USERNAME, ALLOW_CHANGE_FROM_INTERFACE)
 Values
   ('MINIMUM USERNAME LENGTH', 'MINIMUM USERNAME LENGTH', '3', 'GENERAL', '0002', 
    TO_DATE('9/29/2020 2:06:04 AM', 'MM/DD/YYYY HH:MI:SS AM'), 'C586EDA1E6864FC1B1C55C0B22B3DC9E', '0010', 'SWT', 'SWT TO SET');
Insert into GLOSTER_WEB.SYS_PARAMETER
   (PARAMETER_NAME, PARAMETER_DESC, PARAMETER_VALUE, PROJECTNAME, COMPANYCODE, 
    LASTMODIFIED, SYSROWID, DIVISIONCODE, USERNAME, ALLOW_CHANGE_FROM_INTERFACE)
 Values
   ('MAXIMUM USERNAME LENGTH', 'MINIMUM USERNAME LENGTH', '20', 'GENERAL', '0002', 
    TO_DATE('9/29/2020 2:06:04 AM', 'MM/DD/YYYY HH:MI:SS AM'), '0393C01CA5914E2DBA0D1D6A8372EBFA', '0010', 'SWT', 'SWT TO SET');
COMMIT;
