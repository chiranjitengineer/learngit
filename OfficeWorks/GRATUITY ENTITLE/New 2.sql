SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE=''


SELECT * FROM ROLEDETAILS
WHERE MENUCODE=''


SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG = ''


SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUTAG) LIKE  UPPER('%%')



SELECT * FROM MENUMASTER_RND
WHERE MENUDESC LIKE 'Loan'


01100229

SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE='0110022901'


SELECT * FROM ROLEDETAILS
WHERE MENUCODE='0110022901'


SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG = ''

SELECT * FROM SYSTAF
WHERE SYS_TABLENAME_ACTUAL=''

SET DEFINE OFF;
Insert into NJMCL_WEB.MENUMASTER_RND
   (MENUCODE, MENUNAME, MENUDESC, MENUTYPE, MENUTAG, 
    MENUTAG1, MENUTAG2, ENTRYPOSSIBLE, EDITPOSSIBLE, DELETEPOSSIBLE, 
    REPORTSPOSSIBLE, UTILITIESPOSSIBLE, ACTIVE, PROJECTNAME, MENUDETAILS, 
    EFFECTIVEDIVISION, EFFECTIVEINDIVISION, PROCEDURE_SAVE_EDIT, URLSRC, FRM_HEIGHT, 
    FRM_WIDTH, FUNCTIONCALL_BEFORE, FUNCTIONCALL_AFTER, VIEWPOSSIBLE, PRINTPOSSIBLE, 
    DOCDATEVALIDATEFIELD, KEY_TABLE, KEY_COLUMN)
 Values
   ('01100230', 'X', 'Gratuity', 'GROUP', NULL, 
    NULL, NULL, 'Y', 'Y', 'Y', 
    'N', 'N', 'Y', 'WPS', NULL, 
    '''0001'',''0002'',''0005''', '''0001'',''0002'',''0005''', NULL, 'WPS/Pages/Transaction/pgWPSLoanTransaction.aspx', NULL, 
    NULL, 'prcWPS_LoanEntry_b4Save', NULL, NULL, NULL, 
    NULL, NULL, NULL);
COMMIT;


SET DEFINE OFF;
Insert into NJMCL_WEB.ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('1', '01100230', 'Y', 'Y', 'Y', 
    'X', 'X', 'X', 'X', 'WPS', 
    '202006082014310004040162');
COMMIT;


SET DEFINE OFF;
Insert into NJMCL_WEB.MENUMASTER_RND
   (MENUCODE, MENUNAME, MENUDESC, MENUTYPE, MENUTAG, 
    MENUTAG1, MENUTAG2, ENTRYPOSSIBLE, EDITPOSSIBLE, DELETEPOSSIBLE, 
    REPORTSPOSSIBLE, UTILITIESPOSSIBLE, ACTIVE, PROJECTNAME, MENUDETAILS, 
    EFFECTIVEDIVISION, EFFECTIVEINDIVISION, PROCEDURE_SAVE_EDIT, URLSRC, FRM_HEIGHT, 
    FRM_WIDTH, FUNCTIONCALL_BEFORE, FUNCTIONCALL_AFTER, VIEWPOSSIBLE, PRINTPOSSIBLE, 
    DOCDATEVALIDATEFIELD, KEY_TABLE, KEY_COLUMN)
 Values
   ('0110023001', NULL, 'Gratuity Entitlement', 'TRANSACTIONS', 'GRATUITY ENTITLEMENT', 
    'WPS', NULL, 'Y', 'Y', 'Y', 
    'N', 'N', 'Y', 'WPS', NULL, 
    '''0001'',''0002'',''0005''', '''0001'',''0002'',''0005''', NULL, 'GENERAL/Pages/Common/pgGratuityEntitlement.aspx', NULL, 
    NULL, 'prcWPS_LoanEntry_b4Save', NULL, NULL, NULL, 
    NULL, NULL, NULL);
COMMIT;


SET DEFINE OFF;
Insert into NJMCL_WEB.ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('1', '0110023001', 'Y', 'Y', 'Y', 
    'X', 'X', 'X', 'X', 'WPS', 
    '202006082014310004040163');
COMMIT;
