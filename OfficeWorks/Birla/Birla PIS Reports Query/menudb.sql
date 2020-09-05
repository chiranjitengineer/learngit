Insert into MENUMASTER_RND
   (MENUCODE, MENUNAME, MENUDESC, MENUTYPE, MENUTAG, 
    MENUTAG1, MENUTAG2, ENTRYPOSSIBLE, EDITPOSSIBLE, DELETEPOSSIBLE, 
    REPORTSPOSSIBLE, UTILITIESPOSSIBLE, ACTIVE, PROJECTNAME, MENUDETAILS, 
    EFFECTIVEDIVISION, EFFECTIVEINDIVISION, PROCEDURE_SAVE_EDIT, URLSRC, FRM_HEIGHT, 
    FRM_WIDTH, FUNCTIONCALL_BEFORE, FUNCTIONCALL_AFTER, VIEWPOSSIBLE, PRINTPOSSIBLE, 
    DOCDATEVALIDATEFIELD, KEY_TABLE)
 Values
   ('0107030304', NULL, 'ATM Control', 'REPORTS', 'PIS EXCEL REPORT BIRLA', 
    'ATM CONTROL', 'PROC_RPT_ATMCONTROL_EXL(''COMPANYCODE'',''DIVISIONCODE'',''YEARCODE'',''txtYEARMONTH'',''btnUnit'',''btnCategory'')', 'N', 'N', 'N', 
    'Y', 'N', 'Y', 'PIS', NULL, 
    NULL, '''0001'',''0003'',''0002'',''0004''', NULL, 'PIS/Pages/Report/pgReportPISTemplate.aspx', NULL, 
    NULL, NULL, NULL, NULL, NULL, 
    NULL, NULL);
Insert into MENUMASTER_RND
   (MENUCODE, MENUNAME, MENUDESC, MENUTYPE, MENUTAG, 
    MENUTAG1, MENUTAG2, ENTRYPOSSIBLE, EDITPOSSIBLE, DELETEPOSSIBLE, 
    REPORTSPOSSIBLE, UTILITIESPOSSIBLE, ACTIVE, PROJECTNAME, MENUDETAILS, 
    EFFECTIVEDIVISION, EFFECTIVEINDIVISION, PROCEDURE_SAVE_EDIT, URLSRC, FRM_HEIGHT, 
    FRM_WIDTH, FUNCTIONCALL_BEFORE, FUNCTIONCALL_AFTER, VIEWPOSSIBLE, PRINTPOSSIBLE, 
    DOCDATEVALIDATEFIELD, KEY_TABLE)
 Values
   ('0107030305', NULL, 'Bank Loan and Compulsory Savings', 'REPORTS', 'PIS EXCEL REPORT BIRLA', 
    'BANK LOAN AND COMPULSORY SAVINGS', 'PROC_RPT_BANKLOAN_COMPSAV_EXL(''COMPANYCODE'',''DIVISIONCODE'',''YEARCODE'',''txtYEARMONTH'',''btnUnit'',''btnCategory'') ', 'N', 'N', 'N', 
    'Y', 'N', 'Y', 'PIS', NULL, 
    NULL, '''0001'',''0003'',''0002'',''0004''', NULL, 'PIS/Pages/Report/pgReportPISTemplate.aspx', NULL, 
    NULL, NULL, NULL, NULL, NULL, 
    NULL, NULL);
Insert into MENUMASTER_RND
   (MENUCODE, MENUNAME, MENUDESC, MENUTYPE, MENUTAG, 
    MENUTAG1, MENUTAG2, ENTRYPOSSIBLE, EDITPOSSIBLE, DELETEPOSSIBLE, 
    REPORTSPOSSIBLE, UTILITIESPOSSIBLE, ACTIVE, PROJECTNAME, MENUDETAILS, 
    EFFECTIVEDIVISION, EFFECTIVEINDIVISION, PROCEDURE_SAVE_EDIT, URLSRC, FRM_HEIGHT, 
    FRM_WIDTH, FUNCTIONCALL_BEFORE, FUNCTIONCALL_AFTER, VIEWPOSSIBLE, PRINTPOSSIBLE, 
    DOCDATEVALIDATEFIELD, KEY_TABLE)
 Values
   ('0107030306', NULL, 'EPS Statement', 'REPORTS', 'PIS EXCEL REPORT BIRLA', 
    'EPS STATEMENT BIRLA', 'PROC_RPT_EPSSTATEMENT_EXL(''COMPANYCODE'',''DIVISIONCODE'',''YEARCODE'',''txtYEARMONTH'',''btnUnit'',''btnCategory'') ', 'N', 'N', 'N', 
    'Y', 'N', 'Y', 'PIS', NULL, 
    NULL, '''0001'',''0003'',''0002'',''0004''', NULL, 'PIS/Pages/Report/pgReportPISTemplate.aspx', NULL, 
    NULL, NULL, NULL, NULL, NULL, 
    NULL, NULL);
Insert into MENUMASTER_RND
   (MENUCODE, MENUNAME, MENUDESC, MENUTYPE, MENUTAG, 
    MENUTAG1, MENUTAG2, ENTRYPOSSIBLE, EDITPOSSIBLE, DELETEPOSSIBLE, 
    REPORTSPOSSIBLE, UTILITIESPOSSIBLE, ACTIVE, PROJECTNAME, MENUDETAILS, 
    EFFECTIVEDIVISION, EFFECTIVEINDIVISION, PROCEDURE_SAVE_EDIT, URLSRC, FRM_HEIGHT, 
    FRM_WIDTH, FUNCTIONCALL_BEFORE, FUNCTIONCALL_AFTER, VIEWPOSSIBLE, PRINTPOSSIBLE, 
    DOCDATEVALIDATEFIELD, KEY_TABLE)
 Values
   ('0107030307', NULL, 'ESI Statement', 'REPORTS', 'PIS EXCEL REPORT BIRLA', 
    'ESI STATEMENT BIRLA', 'PROC_RPT_ESISTATEMENT_EXL(''COMPANYCODE'',''DIVISIONCODE'',''YEARCODE'',''txtYEARMONTH'',''btnUnit'',''btnCategory'') ', 'N', 'N', 'N', 
    'Y', 'N', 'Y', 'PIS', NULL, 
    NULL, '''0001'',''0003'',''0002'',''0004''', NULL, 'PIS/Pages/Report/pgReportPISTemplate.aspx', NULL, 
    NULL, NULL, NULL, NULL, NULL, 
    NULL, NULL);
Insert into MENUMASTER_RND
   (MENUCODE, MENUNAME, MENUDESC, MENUTYPE, MENUTAG, 
    MENUTAG1, MENUTAG2, ENTRYPOSSIBLE, EDITPOSSIBLE, DELETEPOSSIBLE, 
    REPORTSPOSSIBLE, UTILITIESPOSSIBLE, ACTIVE, PROJECTNAME, MENUDETAILS, 
    EFFECTIVEDIVISION, EFFECTIVEINDIVISION, PROCEDURE_SAVE_EDIT, URLSRC, FRM_HEIGHT, 
    FRM_WIDTH, FUNCTIONCALL_BEFORE, FUNCTIONCALL_AFTER, VIEWPOSSIBLE, PRINTPOSSIBLE, 
    DOCDATEVALIDATEFIELD, KEY_TABLE)
 Values
   ('0107030308', NULL, 'PF and Loan Deduction', 'REPORTS', 'PIS TEXT REPORT BIRLA', 
    'PF AND LOAN DEDUCTION', 'PROC_RPT_PF_LOANDEDN_TEXT(''COMPANYCODE'',''DIVISIONCODE'',''YEARCODE'',''txtYEARMONTH'',''btnUnit'',''btnCategory'') ', 'N', 'N', 'N', 
    'Y', 'N', 'Y', 'PIS', NULL, 
    NULL, '''0001'',''0003'',''0002'',''0004''', NULL, 'PIS/Pages/Report/pgReportPISTemplate.aspx', NULL, 
    NULL, NULL, NULL, NULL, NULL, 
    NULL, NULL);
COMMIT;


-----------------------------------------------------------------------------------

Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('1', '0107030304', 'X', 'X', 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202005081119420010404594');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('52', '0107030304', 'X', 'X', 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202005070846440010402103');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('54', '0107030304', 'X', 'X', 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202003131131450010180969');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('59', '0107030304', 'X', 'X', 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202005061003380010395160');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('1', '0107030305', 'X', 'X', 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202005081119420010404594');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('54', '0107030305', 'X', 'X', 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202003131131450010180969');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('59', '0107030305', 'X', 'X', 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202005061003380010395160');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('52', '0107030305', 'X', 'X', 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202005070846440010402103');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('59', '0107030306', 'X', NULL, 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202005061003380010395160');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('52', '0107030306', 'X', NULL, 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202005070846440010402103');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('54', '0107030306', 'X', NULL, 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202003131131450010180969');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('1', '0107030306', 'X', NULL, 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202005081119420010404594');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('54', '0107030307', 'X', NULL, 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202003131131450010180969');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('52', '0107030307', 'X', NULL, 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202005070846440010402103');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('59', '0107030307', 'X', NULL, 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202005061003380010395160');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('1', '0107030307', 'X', NULL, 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202005081119420010404594');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('54', '0107030308', 'X', NULL, 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202003131131450010180969');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('52', '0107030308', 'X', NULL, 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202005070846440010402103');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('59', '0107030308', 'X', NULL, 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202005061003380010395160');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('1', '0107030308', 'X', NULL, 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202005081119420010404594');
COMMIT;

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------