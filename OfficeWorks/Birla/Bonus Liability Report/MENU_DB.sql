

select * from menumaster_rnd
where menucode='0107030329' 



SET DEFINE OFF;
Insert into MENUMASTER_RND
   (MENUCODE, MENUNAME, MENUDESC, MENUTYPE, MENUTAG, MENUTAG1, MENUTAG2, ENTRYPOSSIBLE, EDITPOSSIBLE, DELETEPOSSIBLE, REPORTSPOSSIBLE, UTILITIESPOSSIBLE, ACTIVE, PROJECTNAME, MENUDETAILS, EFFECTIVEDIVISION, EFFECTIVEINDIVISION, PROCEDURE_SAVE_EDIT, URLSRC, FRM_HEIGHT, FRM_WIDTH, FUNCTIONCALL_BEFORE, FUNCTIONCALL_AFTER, VIEWPOSSIBLE, PRINTPOSSIBLE, DOCDATEVALIDATEFIELD, KEY_TABLE)
 Values
   ('0107030329', NULL, 'Month wise Bonus Earning', 'REPORTS', 'PIS EXCEL REPORT BIRLA', 
    'MONTHLY BONUS EARNING', 'PROC_RPT_MONTHLYBONUS_EXL(''COMPANYCODE'',''DIVISIONCODE'',''YEARCODE'') ', 'N', 'N', 'N', 
    'Y', 'N', 'Y', 'PIS', NULL, 
    NULL, '''0001'',''0003'',''0002'',''0004''', NULL, 'PIS/Pages/Report/pgReportPISTemplate.aspx', NULL, 
    NULL, NULL, NULL, NULL, NULL, 
    NULL, NULL);
COMMIT;



select * from ROLEDETAILS
WHERE MENUCODE='0107030329'

SET DEFINE OFF;
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, SYSROWID)
 Values
   ('59', '0107030329', 'X', 'X', 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202009041631020011148981');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, SYSROWID)
 Values
   ('54', '0107030329', 'X', NULL, 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202003131131450010180969');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, SYSROWID)
 Values
   ('52', '0107030329', 'X', NULL, 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202005070846440010402103');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, SYSROWID)
 Values
   ('1', '0107030329', 'X', NULL, 'X', 
    'Y', 'X', 'X', 'X', 'PIS', 
    '202005081119420010404594');
COMMIT;
