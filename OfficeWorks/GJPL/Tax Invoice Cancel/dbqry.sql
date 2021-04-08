EXEC proc_salesbillprintgst_CAN('GJ0108','0002','01/04/2021','31/03/2022','''2122/GJG0008''','D:\SWT_INSTALLER\swterp_gjpl\\LOGO\Logo_GJPL.JPG','D:\SWT_INSTALLER\swterp_gjpl\\LOGO\LOGO.JPG','D:\SWT_INSTALLER\swterp_gjpl\\LOGO\DRAFT_WTR2.png')



~SALES/Pages/Report/Transaction/rptSALESBILLPRINTGST_GJPL_IRN.rdlc~GTT_SALESBILLPRINTGST


SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%custom inv%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE='010503020192'

SELECT * FROM ROLEDETAILS
WHERE MENUCODE='010503020192'

SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG=''




SET DEFINE OFF;
Insert into MENUMASTER_RND
   (MENUCODE, MENUNAME, MENUDESC, MENUTYPE, MENUTAG, MENUTAG1, MENUTAG2, ENTRYPOSSIBLE, EDITPOSSIBLE, DELETEPOSSIBLE, REPORTSPOSSIBLE, UTILITIESPOSSIBLE, ACTIVE, PROJECTNAME, MENUDETAILS, EFFECTIVEDIVISION, EFFECTIVEINDIVISION, PROCEDURE_SAVE_EDIT, URLSRC, FRM_HEIGHT, FRM_WIDTH, FUNCTIONCALL_BEFORE, FUNCTIONCALL_AFTER, VIEWPOSSIBLE, PRINTPOSSIBLE, DOCDATEVALIDATEFIELD, KEY_TABLE)
 Values
   ('010503020193', NULL, 'Tax Invoice Cancel ', 'REPORTS', 'TAX INVOICE CANCEL', 
    NULL, NULL, 'N', 'N', 'N', 
    'Y', 'N', 'Y', 'SALES', NULL, 
    NULL, '''0002''', NULL, 'SALES/Pages/Report/pgReportSalesTemplate.aspx', NULL, 
    NULL, NULL, NULL, 'N', 'N', 
    NULL, NULL);
COMMIT;

SET DEFINE OFF;
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, SYSROWID)
 Values
   ('1', '010503020193', 'X', 'X', 'X', 
    'Y', 'X', 'X', 'X', 'SALES', 
    '201905201317530010061181');
COMMIT;



SET DEFINE OFF;
Insert into REPORTPARAMETERMASTER
   (MODULENAME, REPORTTAG, REPORTTAG1, REPORTTAG2, REPORTTAG3, MAINTABLE, SUBREPORTTABLE, SUBREPORTTABLE1, SUBREPORTTABLE2, SUBREPORTTABLE3, SUBREPORTTABLE4, REPORTNAME)
 Values
   ('SALES', 'TAX INVOICE CANCEL', NULL, NULL, NULL, 
    'GTT_SALESBILLPRINTGST', NULL, NULL, NULL, NULL, 
    NULL, 'SALES/Pages/Report/Transaction/rptSALESBILLPRINTGST_GJPL_IRN_CAN.rdlc');
COMMIT;



select * from MODULEWISELOGO


SET DEFINE OFF;


Insert into MODULEWISELOGO
   (COMPANYCODE, DIVISIONCODE, MODULE, LOGO_TYPE, LOGONAME)
 Values
   ('DJ0107', '0002', 'SALES', 'CANCEL', 'CANCEL01.png');
COMMIT;

SET DEFINE OFF;

Insert into MODULEWISELOGO
   (COMPANYCODE, DIVISIONCODE, MODULE, LOGO_TYPE, LOGONAME)
 Values
   ('GJ0108', '0002', 'SALES', 'CANCEL', 'CANCEL01.png');
COMMIT;