exec PROC_REIMBURSEMENT('0001','001','2020-2021','202004','001','02','CIV','','FIX_CONV','','1','A','N')

SELECT * FROM GTT_PISREIMBURSEMENT

exec PROC_REIMBURSEMENT('0001','001','2020-2021','202004','001','02','CIV','','LOCAL_CONV','','1','M','N')

EXEC PRC_PIS_REIMBURSMENT_ENT ('0001','001','2020-2021','202004','TELEPHONE','001','','','','M')


SELECT *  FROM GTT_PISREIMBURSEMENT_ENTITLE

S3002           6900
S3002           10350


P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2,
                                                  P_YEARCODE varchar2,
                                                  P_YEARMONTH Varchar2,
                                                  P_COMPONENTCODE varchar2,
                                                  P_CATEGORYCODE varchar2 DEFAULT NULL,
                                                  P_GRADECODE varchar2 DEFAULT NULL,
                                                  P_USERNAME varchar2 DEFAULT NULL
                                                 )
                                                 .
                                                 
DROP TABLE PISREIMBURSEMENT_ENTITLE CASCADE CONSTRAINTS;


COMPANYCODE, DIVISIONCODE, YEARCODE, WORKERSERIAL, TOKENNO, UNITCODE, CATEGORYCODE, 
GRADECODE, COMPONENTCODE, COMPONENTAMOUNT, TRANSACTIONTYPE, ADDLESS, 
PAYMENTMODE, WORKINGDAYS, USERNAME, SYSROWID, LASTMODIFIED

TOKENNO, EMPLOYEENAME, DATEOFJOIN, BASIC, PREVAMOUNT, CLAIMLIMIT, TAKENAMOUNT, DUEAMOUNT,
PAIDAMOUNT, REMARKS, COMPONENTAMOUNT, WORKERSERIAL, CATEGORYCODE, GRADECODE, COMPONENTCODE, 
YEARCODE, FORYEARCODE, YEARMONTH, TRANSACTIONTYPE, ADDLESS, LEAVEDATEFROM, LEAVEDATETO,
COMPANYCODE, DIVISIONCODE



TOKENNO, EMPLOYEENAME, DATEOFJOIN, COMPONENTAMOUNT


SELECT  * FROM MENUMASTER_RND
WHERE MENUCODE = '01070208'

SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%REIMB%')

SELECT  * FROM ROLEDETAILS
WHERE MENUCODE = '01070208'

SELECT  * FROM REPORTPARAMETERMASTER
WHERE REPORTAG = ''




SET DEFINE OFF;
Insert into MENUMASTER_RND
   (MENUCODE, MENUNAME, MENUDESC, MENUTYPE, MENUTAG, 
    MENUTAG1, MENUTAG2, ENTRYPOSSIBLE, EDITPOSSIBLE, DELETEPOSSIBLE, 
    REPORTSPOSSIBLE, UTILITIESPOSSIBLE, ACTIVE, PROJECTNAME, MENUDETAILS, 
    EFFECTIVEDIVISION, EFFECTIVEINDIVISION, PROCEDURE_SAVE_EDIT, URLSRC, FRM_HEIGHT, 
    FRM_WIDTH, FUNCTIONCALL_BEFORE, FUNCTIONCALL_AFTER, VIEWPOSSIBLE, PRINTPOSSIBLE, 
    DOCDATEVALIDATEFIELD, KEY_TABLE)
 Values
   ('01070209', NULL, 'Reimbursement Entitlement', 'TRANSACTIONS', 'PIS REIMBURSEMENT ENTITLEMENT', 
    'PIS', NULL, 'Y', 'Y', 'Y', 
    'N', 'N', 'Y', 'PIS', NULL, 
    '''0001'',''0002'',''0003'',''0004''', '''0001'',''0002'',''0003'',''0004'',''0005''', NULL, 'PIS/PAGES/Transaction/pgPISReimbursmentEntitle_New.aspx', NULL, 
    NULL, NULL, NULL, NULL, NULL, 
    NULL, NULL);
COMMIT;


SET DEFINE OFF;
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('1', '01070209', 'Y', 'Y', 'Y', 
    'X', 'X', 'X', 'X', 'PIS', 
    '202005271045580008869959');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('25', '01070209', 'Y', 'N', 'N', 
    'X', 'X', 'X', 'X', 'PIS', 
    '202009051116570009280171');
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('35', '01070209', 'Y', 'Y', 'Y', 
    'X', 'X', 'X', 'X', 'PIS', 
    '202009031725040009273482');
COMMIT;
