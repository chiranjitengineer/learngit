CREATE TABLE SYS_SWT_TABLE_PARAMMAST
(
  COMPANYCODE     VARCHAR2(10 BYTE),
  DIVISIONCODE    VARCHAR2(10 BYTE),
  REF_TABLE_NAME  VARCHAR2(30 BYTE),
  PARAM_NAME      VARCHAR2(100 BYTE),
  PARAM_CAPTION   VARCHAR2(50 BYTE),
  OBJECT_TYPE     VARCHAR2(20 BYTE),
  DATA_TYPE       VARCHAR2(20 BYTE),
  MAXLENGTH       NUMBER(5),
  PARAM_REMARKS   VARCHAR2(100 BYTE),
  KEY_COLUMN      VARCHAR2(50 BYTE),
  DISPLAY_COLUMN  VARCHAR2(50 BYTE),
  DISPLAYINDEX    NUMBER(3),
  USERNAME        VARCHAR2(50 BYTE),
  LASTMODIFIED    DATE                          DEFAULT SYSDATE,
  SYSROWID        VARCHAR2(50 BYTE),
  ONBLUR_QUERY    VARCHAR2(1000 BYTE),
  POPUP_VALUE     VARCHAR2(250 BYTE)
)

--------------------------------------------------------

SET DEFINE OFF;
Insert into SYS_SWT_TABLE_PARAMMAST
   (COMPANYCODE, DIVISIONCODE, REF_TABLE_NAME, PARAM_NAME, PARAM_CAPTION, OBJECT_TYPE, DATA_TYPE, MAXLENGTH, PARAM_REMARKS, KEY_COLUMN, DISPLAY_COLUMN, DISPLAYINDEX, USERNAME, LASTMODIFIED, SYSROWID, ONBLUR_QUERY, POPUP_VALUE)
 Values
   ('CJ0101', '0002', 'WPSSECTIONMAST', 'MACHINEAPPLICABLE', 'Machine Applicable (Y/N)', 
    'VARCHAR2', '10', 10, 'MACHINEAPPLICABLE', 'DEPARTMENTCODE~SECTIONCODE', 
    'CATEGORYCODE,CATEGORYDESC', NULL, NULL, TO_DATE('02/01/2018 11:29:49', 'MM/DD/YYYY HH24:MI:SS'), NULL, 
    'SELECT SECTIONCODE||''~''||SECTIONNAME
  FROM WPSSECTIONMAST
 WHERE COMPANYCODE=''<<COMPANYCODE>>''
   AND DIVISIONCODE=''<<DIVISIONCODE>>''
   AND SECTIONCODE=''<<SECTIONCODE>>''
', 'Y~N');
Insert into SYS_SWT_TABLE_PARAMMAST
   (COMPANYCODE, DIVISIONCODE, REF_TABLE_NAME, PARAM_NAME, PARAM_CAPTION, OBJECT_TYPE, DATA_TYPE, MAXLENGTH, PARAM_REMARKS, KEY_COLUMN, DISPLAY_COLUMN, DISPLAYINDEX, USERNAME, LASTMODIFIED, SYSROWID, ONBLUR_QUERY, POPUP_VALUE)
 Values
   ('CJ0101', '0002', 'WPSSECTIONMAST', 'NSAPPLICABLE', 'Night Shift Allowance Applicable (Y/N)', 
    'VARCHAR2', '10', 10, 'NSAPPLICABLE', 'DEPARTMENTCODE~SECTIONCODE', 
    'CATEGORYCODE,CATEGORYDESC', NULL, NULL, TO_DATE('02/01/2018 11:29:49', 'MM/DD/YYYY HH24:MI:SS'), NULL, 
    'SELECT SECTIONCODE||''~''||SECTIONNAME
  FROM WPSSECTIONMAST
 WHERE COMPANYCODE=''<<COMPANYCODE>>''
   AND DIVISIONCODE=''<<DIVISIONCODE>>''
   AND SECTIONCODE=''<<SECTIONCODE>>''
', 'Y~N');
Insert into SYS_SWT_TABLE_PARAMMAST
   (COMPANYCODE, DIVISIONCODE, REF_TABLE_NAME, PARAM_NAME, PARAM_CAPTION, OBJECT_TYPE, DATA_TYPE, MAXLENGTH, PARAM_REMARKS, KEY_COLUMN, DISPLAY_COLUMN, DISPLAYINDEX, USERNAME, LASTMODIFIED, SYSROWID, ONBLUR_QUERY, POPUP_VALUE)
 Values
   ('CJ0101', '0002', 'WPSSECTIONMAST', 'NIGHTSHIFTATTENDANCEHOURS', 'Night Shift Allowance Attendence Hours', 
    'NUMBER', '18,2', 10, 'NS_ATTN_HRS', 'DEPARTMENTCODE~SECTIONCODE', 
    'CATEGORYCODE,CATEGORYDESC', NULL, NULL, TO_DATE('02/01/2018 11:29:49', 'MM/DD/YYYY HH24:MI:SS'), NULL, 
    'SELECT SECTIONCODE||''~''||SECTIONNAME
  FROM WPSSECTIONMAST
 WHERE COMPANYCODE=''<<COMPANYCODE>>''
   AND DIVISIONCODE=''<<DIVISIONCODE>>''
   AND SECTIONCODE=''<<SECTIONCODE>>''
', NULL);
Insert into SYS_SWT_TABLE_PARAMMAST
   (COMPANYCODE, DIVISIONCODE, REF_TABLE_NAME, PARAM_NAME, PARAM_CAPTION, OBJECT_TYPE, DATA_TYPE, MAXLENGTH, PARAM_REMARKS, KEY_COLUMN, DISPLAY_COLUMN, DISPLAYINDEX, USERNAME, LASTMODIFIED, SYSROWID, ONBLUR_QUERY, POPUP_VALUE)
 Values
   ('CJ0101', '0002', 'WPSSECTIONMAST', 'PFLINKHOURS', 'PF Link Hours', 
    'NUMBER', '18,2', 10, 'PFLINK_HRS', 'DEPARTMENTCODE~SECTIONCODE', 
    'CATEGORYCODE,CATEGORYDESC', NULL, NULL, TO_DATE('02/01/2018 11:29:49', 'MM/DD/YYYY HH24:MI:SS'), NULL, 
    'SELECT SECTIONCODE||''~''||SECTIONNAME
  FROM WPSSECTIONMAST
 WHERE COMPANYCODE=''<<COMPANYCODE>>''
   AND DIVISIONCODE=''<<DIVISIONCODE>>''
   AND SECTIONCODE=''<<SECTIONCODE>>''
', NULL);
Insert into SYS_SWT_TABLE_PARAMMAST
   (COMPANYCODE, DIVISIONCODE, REF_TABLE_NAME, PARAM_NAME, PARAM_CAPTION, OBJECT_TYPE, DATA_TYPE, MAXLENGTH, PARAM_REMARKS, KEY_COLUMN, DISPLAY_COLUMN, DISPLAYINDEX, USERNAME, LASTMODIFIED, SYSROWID, ONBLUR_QUERY, POPUP_VALUE)
 Values
   ('CJ0101', '0002', 'WPSSECTIONMAST', 'NONPFLINKHOURS', 'Non PF Link Hours', 
    'NUMBER', '18,2', 10, 'NONPFLINK_HRS', 'DEPARTMENTCODE~SECTIONCODE', 
    'CATEGORYCODE,CATEGORYDESC', NULL, NULL, TO_DATE('02/01/2018 11:29:49', 'MM/DD/YYYY HH24:MI:SS'), NULL, 
    'SELECT SECTIONCODE||''~''||SECTIONNAME
  FROM WPSSECTIONMAST
 WHERE COMPANYCODE=''<<COMPANYCODE>>''
   AND DIVISIONCODE=''<<DIVISIONCODE>>''
   AND SECTIONCODE=''<<SECTIONCODE>>''
', NULL);
Insert into SYS_SWT_TABLE_PARAMMAST
   (COMPANYCODE, DIVISIONCODE, REF_TABLE_NAME, PARAM_NAME, PARAM_CAPTION, OBJECT_TYPE, DATA_TYPE, MAXLENGTH, PARAM_REMARKS, KEY_COLUMN, DISPLAY_COLUMN, DISPLAYINDEX, USERNAME, LASTMODIFIED, SYSROWID, ONBLUR_QUERY, POPUP_VALUE)
 Values
   ('CJ0101', '0002', 'WPSSECTIONMAST', 'NSAAPPLICABLEINOT', 'Night Shift Allowance Applicable in OT (Y/N)', 
    'VARCHAR2', '10', 10, 'NSAAPPLICABLEINOT', 'DEPARTMENTCODE~SECTIONCODE', 
    'CATEGORYCODE,CATEGORYDESC', NULL, NULL, TO_DATE('02/01/2018 11:29:49', 'MM/DD/YYYY HH24:MI:SS'), NULL, 
    'SELECT SECTIONCODE||''~''||SECTIONNAME
  FROM WPSSECTIONMAST
 WHERE COMPANYCODE=''<<COMPANYCODE>>''
   AND DIVISIONCODE=''<<DIVISIONCODE>>''
   AND SECTIONCODE=''<<SECTIONCODE>>''
', 'Y~N');
Insert into SYS_SWT_TABLE_PARAMMAST
   (COMPANYCODE, DIVISIONCODE, REF_TABLE_NAME, PARAM_NAME, PARAM_CAPTION, OBJECT_TYPE, DATA_TYPE, MAXLENGTH, PARAM_REMARKS, KEY_COLUMN, DISPLAY_COLUMN, DISPLAYINDEX, USERNAME, LASTMODIFIED, SYSROWID, ONBLUR_QUERY, POPUP_VALUE)
 Values
   ('CJ0101', '0002', 'WPSOCCUPATIONMAST', 'FBK_RATE', 'Fall Back Rate (per hrs)', 
    'NUMBER', '18,5', 10, 'FALL BACK RATE', 'DEPARTMENTCODE~SECTIONCODE~OCCUPATIONCODE', 
    NULL, NULL, NULL, TO_DATE('02/01/2018 11:29:49', 'MM/DD/YYYY HH24:MI:SS'), NULL, 
    NULL, 'Y~N');
Insert into SYS_SWT_TABLE_PARAMMAST
   (COMPANYCODE, DIVISIONCODE, REF_TABLE_NAME, PARAM_NAME, PARAM_CAPTION, OBJECT_TYPE, DATA_TYPE, MAXLENGTH, PARAM_REMARKS, KEY_COLUMN, DISPLAY_COLUMN, DISPLAYINDEX, USERNAME, LASTMODIFIED, SYSROWID, ONBLUR_QUERY, POPUP_VALUE)
 Values
   ('CJ0101', '0002', 'WPSOCCUPATIONMAST', 'ADDL_RATE', 'Additional Rate (per hrs)', 
    'NUMBER', '18,5', 10, 'ADDL_RATE', 'DEPARTMENTCODE~SECTIONCODE~OCCUPATIONCODE', 
    NULL, NULL, NULL, TO_DATE('02/01/2018 11:29:49', 'MM/DD/YYYY HH24:MI:SS'), NULL, 
    NULL, 'Y~N');
Insert into SYS_SWT_TABLE_PARAMMAST
   (COMPANYCODE, DIVISIONCODE, REF_TABLE_NAME, PARAM_NAME, PARAM_CAPTION, OBJECT_TYPE, DATA_TYPE, MAXLENGTH, PARAM_REMARKS, KEY_COLUMN, DISPLAY_COLUMN, DISPLAYINDEX, USERNAME, LASTMODIFIED, SYSROWID, ONBLUR_QUERY, POPUP_VALUE)
 Values
   ('CJ0101', '0002', 'WPSOCCUPATIONMAST', 'PFLINK_RATE', 'PF Link Additional Rate (per hrs)', 
    'NUMBER', '18,5', 10, 'PFLINK_RATE', 'DEPARTMENTCODE~SECTIONCODE~OCCUPATIONCODE', 
    NULL, NULL, NULL, TO_DATE('02/01/2018 11:29:49', 'MM/DD/YYYY HH24:MI:SS'), NULL, 
    NULL, 'Y~N');
Insert into SYS_SWT_TABLE_PARAMMAST
   (COMPANYCODE, DIVISIONCODE, REF_TABLE_NAME, PARAM_NAME, PARAM_CAPTION, OBJECT_TYPE, DATA_TYPE, MAXLENGTH, PARAM_REMARKS, KEY_COLUMN, DISPLAY_COLUMN, DISPLAYINDEX, USERNAME, LASTMODIFIED, SYSROWID, ONBLUR_QUERY, POPUP_VALUE)
 Values
   ('CJ0101', '0002', 'WPSSECTIONMAST', 'APPLICABLE_ATN_INCT', 'Is Attendance Rewrds Applicable', 
    'VARCHAR2', '1', 1, 'APPLICABLE_ATN_INCT', 'DEPARTMENTCODE~SECTIONCODE', 
    'CATEGORYCODE,CATEGORYDESC', NULL, NULL, TO_DATE('02/01/2018 11:29:49', 'MM/DD/YYYY HH24:MI:SS'), NULL, 
    'SELECT SECTIONCODE||''~''||SECTIONNAME
  FROM WPSSECTIONMAST
 WHERE COMPANYCODE=''<<COMPANYCODE>>''
   AND DIVISIONCODE=''<<DIVISIONCODE>>''
   AND SECTIONCODE=''<<SECTIONCODE>>''
', 'Y~N');
Insert into SYS_SWT_TABLE_PARAMMAST
   (COMPANYCODE, DIVISIONCODE, REF_TABLE_NAME, PARAM_NAME, PARAM_CAPTION, OBJECT_TYPE, DATA_TYPE, MAXLENGTH, PARAM_REMARKS, KEY_COLUMN, DISPLAY_COLUMN, DISPLAYINDEX, USERNAME, LASTMODIFIED, SYSROWID, ONBLUR_QUERY, POPUP_VALUE)
 Values
   ('CJ0101', '0002', 'WPSSECTIONMAST', 'FBK_RATE', 'Fall Back Rate', 
    'NUMBER', '18,2', 10, 'FBK_RATE', 'DEPARTMENTCODE~SECTIONCODE', 
    'CATEGORYCODE,CATEGORYDESC', NULL, NULL, TO_DATE('07/03/2020 17:29:49', 'MM/DD/YYYY HH24:MI:SS'), NULL, 
    'SELECT SECTIONCODE||''~''||SECTIONNAME
  FROM WPSSECTIONMAST
 WHERE COMPANYCODE=''<<COMPANYCODE>>''
   AND DIVISIONCODE=''<<DIVISIONCODE>>''
   AND SECTIONCODE=''<<SECTIONCODE>>''
', NULL);
Insert into SYS_SWT_TABLE_PARAMMAST
   (COMPANYCODE, DIVISIONCODE, REF_TABLE_NAME, PARAM_NAME, PARAM_CAPTION, OBJECT_TYPE, DATA_TYPE, MAXLENGTH, PARAM_REMARKS, KEY_COLUMN, DISPLAY_COLUMN, DISPLAYINDEX, USERNAME, LASTMODIFIED, SYSROWID, ONBLUR_QUERY, POPUP_VALUE)
 Values
   ('CJ0101', '0002', 'WPSOCCUPATIONMAST', 'EXTRA_RATE', 'Extra Rate (per hrs)', 
    'NUMBER', '18,5', 10, 'EXTRA RATE', 'DEPARTMENTCODE~SECTIONCODE~OCCUPATIONCODE', 
    NULL, NULL, NULL, TO_DATE('02/01/2018 11:29:49', 'MM/DD/YYYY HH24:MI:SS'), NULL, 
    NULL, 'Y~N');
Insert into SYS_SWT_TABLE_PARAMMAST
   (COMPANYCODE, DIVISIONCODE, REF_TABLE_NAME, PARAM_NAME, PARAM_CAPTION, OBJECT_TYPE, DATA_TYPE, MAXLENGTH, PARAM_REMARKS, KEY_COLUMN, DISPLAY_COLUMN, DISPLAYINDEX, USERNAME, LASTMODIFIED, SYSROWID, ONBLUR_QUERY, POPUP_VALUE)
 Values
   ('CJ0101', '0002', 'WPSOCCUPATIONMAST', 'DEPTGROUP', 'Department Group', 
    'VARCHAR2', '50', 50, 'DEPTGROUP', 'DEPARTMENTCODE~SECTIONCODE~OCCUPATIONCODE', 
    NULL, NULL, NULL, TO_DATE('11/03/2020 11:29:49', 'MM/DD/YYYY HH24:MI:SS'), NULL, 
    NULL, NULL);
COMMIT;