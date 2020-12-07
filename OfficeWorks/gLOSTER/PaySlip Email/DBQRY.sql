DROP TABLE EMAIL_PARAMETERS CASCADE CONSTRAINTS;

CREATE TABLE EMAIL_PARAMETERS
(
  COMPANYCODE        VARCHAR2(10 BYTE)          NOT NULL,
  DIVISIONCODE       VARCHAR2(10 BYTE)          NOT NULL,
  DOCUMENT_TYPE      VARCHAR2(100 BYTE)         NOT NULL,
  SENDER_EMAIL_ID    VARCHAR2(50 BYTE)          NOT NULL,
  SENDER_EMAIL_PWD   VARCHAR2(50 BYTE),
  CC_EMAIL_ID        VARCHAR2(200 BYTE),
  BCC_EMAIL_ID       VARCHAR2(200 BYTE),
  REPORT_FILE_PATH   VARCHAR2(200 BYTE)         NOT NULL,
  EMAILBODY          VARCHAR2(1000 BYTE),
  RECEIVER_EMAIL_ID  VARCHAR2(100 BYTE)
) 

-------------------------------------------------------------------------------

DROP TABLE GTT_EMAIL_DATA CASCADE CONSTRAINTS;

CREATE GLOBAL TEMPORARY TABLE GTT_EMAIL_DATA
(
  COMPANYCODE          VARCHAR2(10 BYTE)        NOT NULL,
  DIVISIONCODE         VARCHAR2(10 BYTE)        NOT NULL,
  DOCUMENT_TYPE        VARCHAR2(100 BYTE)       NOT NULL,
  SENDER_EMAIL_ID      VARCHAR2(50 BYTE)        NOT NULL,
  SENDER_EMAIL_PWD     VARCHAR2(50 BYTE),
  RECEIVER_EMAIL_ID    VARCHAR2(50 BYTE)        DEFAULT '123.com'             NOT NULL,
  CC_EMAIL_ID          VARCHAR2(200 BYTE),
  EMAIL_SUBJECT        VARCHAR2(500 BYTE),
  EMAIL_BODY           CLOB,
  ATTACHMENT_FILENAME  VARCHAR2(100 BYTE),
  ATTACHMENT_BLOB      BLOB
)
ON COMMIT DELETE ROWS
NOCACHE;


-------------------------------------------------------------------------------

DROP TABLE GTT_EMAIL_DATA_STAGE CASCADE CONSTRAINTS;

CREATE GLOBAL TEMPORARY TABLE GTT_EMAIL_DATA_STAGE
(
  COMPANYCODE          VARCHAR2(10 BYTE)        NOT NULL,
  DIVISIONCODE         VARCHAR2(10 BYTE)        NOT NULL,
  DOCUMENT_TYPE        VARCHAR2(100 BYTE)       NOT NULL,
  SENDER_EMAIL_ID      VARCHAR2(50 BYTE)        NOT NULL,
  SENDER_EMAIL_PWD     VARCHAR2(50 BYTE),
  RECEIVER_EMAIL_ID    VARCHAR2(50 BYTE)        DEFAULT 'softweb.techteam.com' NOT NULL,
  CC_EMAIL_ID          VARCHAR2(200 BYTE),
  EMAIL_SUBJECT        VARCHAR2(500 BYTE),
  EMAIL_BODY           VARCHAR2(1000 BYTE),
  ATTACHMENT_FILENAME  VARCHAR2(100 BYTE),
  ATTACHMENT_BLOB      BLOB
)
ON COMMIT PRESERVE ROWS
NOCACHE;


-------------------------------------------------------------------------------


DROP TABLE EMAIL_DATA CASCADE CONSTRAINTS;

CREATE TABLE EMAIL_DATA
(
  COMPANYCODE          VARCHAR2(10 BYTE)        NOT NULL,
  DIVISIONCODE         VARCHAR2(10 BYTE)        NOT NULL,
  DOCUMENT_TYPE        VARCHAR2(100 BYTE)       NOT NULL,
  SENDER_EMAIL_ID      VARCHAR2(50 BYTE)        NOT NULL,
  SENDER_EMAIL_PWD     VARCHAR2(50 BYTE),
  RECEIVER_EMAIL_ID    VARCHAR2(50 BYTE)        NOT NULL,
  CC_EMAIL_ID          VARCHAR2(200 BYTE),
  EMAIL_SUBJECT        VARCHAR2(500 BYTE),
  EMAIL_BODY           VARCHAR2(1000 BYTE),
  ATTACHMENT_FILENAME  VARCHAR2(100 BYTE),
  ATTACHMENT_BLOB      BLOB
)



-------------------------------------------------------------------------------

DROP TABLE EMAIL_HISTORY CASCADE CONSTRAINTS;

CREATE TABLE EMAIL_HISTORY
(
  COMPANYCODE          VARCHAR2(10 BYTE)        NOT NULL,
  DIVISIONCODE         VARCHAR2(10 BYTE)        NOT NULL,
  DOCUMENT_TYPE        VARCHAR2(100 BYTE)       NOT NULL,
  SENDER_EMAIL_ID      VARCHAR2(50 BYTE)        NOT NULL,
  SENDER_EMAIL_PWD     VARCHAR2(50 BYTE),
  RECEIVER_EMAIL_ID    VARCHAR2(50 BYTE)        NOT NULL,
  CC_EMAIL_ID          VARCHAR2(200 BYTE),
  EMAIL_SUBJECT        VARCHAR2(500 BYTE),
  EMAIL_BODY           VARCHAR2(1000 BYTE),
  ATTACHMENT_FILENAME  VARCHAR2(100 BYTE),
  STATUS               VARCHAR2(100 BYTE),
  SENDDATETIME         DATE                     DEFAULT SYSDATE,
  SENTLOG              VARCHAR2(4000 BYTE)
)

-------------------------------------------------------------------------------

DROP TYPE EMAIL_ATTACHMENT;

CREATE OR REPLACE TYPE "EMAIL_ATTACHMENT"                                           
AS OBJECT (
    attachment_name VARCHAR2(2000),
    attachment_mime VARCHAR2(200),
    attachment_blob blob
);
/



-------------------------------------------------------------------------------


DROP TYPE ST_ITEMMAST_OBJ_TYPE;

CREATE OR REPLACE TYPE "ST_ITEMMAST_OBJ_TYPE"                                          IS OBJECT 
(
ITEMCODE                        VARCHAR2(50),
ITEMDESC                        VARCHAR2(500),
ITEMUOM                         VARCHAR2(60),
PURCHASEACCODE                  VARCHAR2(50),
PURCHASEGROUPCODE               VARCHAR2(50),
ISISOITEM                       VARCHAR2(1),  
ISSTOREITEM                     VARCHAR2(1),
ISSUEIDENTIFICATIONAPPLICABLE   VARCHAR2(1),
QUANTITY                        NUMBER(15,4),
AMOUNT                          NUMBER(15,4),
VATCREDITALLOWED                VARCHAR2(3),
CSTCREDITALLOWED                VARCHAR2(3),
EXCISECREDITALLOWED             VARCHAR2(3),
ITEMTYPE                        VARCHAR2(50), 
MIN_LVL                         NUMBER(15,4), 
AVGCONSUMPTION                  NUMBER(15,4), 
TOTAL_ISSUEQTY_THISMONTH        NUMBER(15,4)
);
/




-------------------------------------------------------------------------------

DROP TYPE LISTAGGIMPL;

CREATE OR REPLACE TYPE "LISTAGGIMPL"                                          wrapped
a000000
b2
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
d
20d 130
IjFl1xr/tRwwrZLUU0xDLcAqh1Awg5DIr0oVyo7pFwAPUpx5JekLaL4jZWTOdGkdKIKStSxm
VP0TYNeRVGfnnMfRfUPbuPGJ2JSqwA5GUqqRjJoWjL5yqYjWqDutbj7sHZUuA834vM0cN+Fp
fwTAfMUL3c4LGsrvugmnysVdXZcuZZKZPsGTnINvKMsvk8d05zG7rf8wcjL+y2R22SUUn2qZ
n/6RT/oB4vc682f4KDgIQr0MQ/ZVokEaDXd+zXxXwiaHbtgg8s9I7q2DnXpF5M7JPVJDmIAF
VbGykr+pkA==
/


DROP TYPE BODY LISTAGGIMPL;

CREATE OR REPLACE TYPE BODY "LISTAGGIMPL" wrapped
a000000
b2
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
e
480 217
zqRhmj59pclKP0foWtihU1AM/tQwg5C3ckjWfHTUv7lezmDIVGOfxC0rnq+pYy/l28Me0RD3
IuTxZ9V9kq6GyDZ2teCqLO5qy2t9lx0RwFYe7IOQOcBLprXOllme5RkW6P9n6sWbElY88fd0
f6EuJBZuBiDKLLtCl6FbGOm5O/vrxESDmZjd7Flx+19e289I6Of3FN4iQIDcFuYy1AglgfJr
x4R2Lq1Wo1/BaD7ss5KhV3c98BiCtAxVC+OKY1zwoB7aLuQpN8UvCzOxb8MLlQdyjeh676R1
SgBn9lo3/XpJQFnw6ItguL90Fxh19+hLNz1+SUbCnLxCbK3DpJXgDDvjalx3HZsmNKmD7qrM
sOtQYD83Ov9Nl5bSCHMyZEETQ+0n+lnN7JMqbn+JlM9f3QN5iMOjPNEUskFjKFZucwJe2B+V
gQILEmJaYZfbEYMNw7sKyuR5BMOLfXvZxkteWYyT8UnIVdrNOU4mYShjebM8KEg3neMeL+Pb
MfA/ZgbZbBVmXyCdJRCOCw==
/



-------------------------------------------------------------------------------

DROP TYPE ST_STOCKTABTYPE;

CREATE OR REPLACE TYPE "ST_STOCKTABTYPE"                                          AS TABLE OF ST_ITEMMAST_OBJ_TYPE ;

------------------
/




-------------------------------------------------------------------------------


DROP TYPE TABLE_ATTACHMENTS;

CREATE OR REPLACE TYPE "TABLE_ATTACHMENTS"                                           IS TABLE OF email_attachment;
/




-------------------------------------------------------------------------------


SET DEFINE OFF;
Insert into EMAIL_PARAMETERS
   (COMPANYCODE, DIVISIONCODE, DOCUMENT_TYPE, SENDER_EMAIL_ID, SENDER_EMAIL_PWD, CC_EMAIL_ID, BCC_EMAIL_ID, REPORT_FILE_PATH, EMAILBODY, RECEIVER_EMAIL_ID)
 Values
   ('JT0069', '0001', 'PIS_PAYSLIP_EMAIL', 'softweb.techteam@gmail.com', 'NewPassw0rd', 
    NULL, NULL, 'EMAIL/PAYSLIP/', 'Please find the attached Payslip. ___Thanks/Regards __Administration Department __Joonktollee Tea & Industries Limited, Unit : HO', NULL);
COMMIT;



-------------------------------------------------------------------------------

DTA-HO

DTA-UNIT

ANANYA - UNIT

SELECT * FROM EMAIL_PARAMETERS


SELECT * FROM COMPANYMAST


SELECT * FROM DIVISIONMASTER

GLOSTER LIMITED

--------------------------------------------------------------------------

SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%PAY SLIP%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE='0107030801'

SELECT * FROM ROLEDETAILS
WHERE MENUCODE='0107030801'

SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG=''

--------------------------------------------------------------------------

SET DEFINE OFF;
Insert into MENUMASTER_RND
   (MENUCODE, MENUNAME, MENUDESC, MENUTYPE, MENUTAG, MENUTAG1, MENUTAG2, ENTRYPOSSIBLE, EDITPOSSIBLE, DELETEPOSSIBLE, REPORTSPOSSIBLE, UTILITIESPOSSIBLE, ACTIVE, PROJECTNAME, MENUDETAILS, EFFECTIVEDIVISION, EFFECTIVEINDIVISION, PROCEDURE_SAVE_EDIT, URLSRC, FRM_HEIGHT, FRM_WIDTH, FUNCTIONCALL_BEFORE, FUNCTIONCALL_AFTER, VIEWPOSSIBLE, PRINTPOSSIBLE, DOCDATEVALIDATEFIELD, KEY_TABLE, KEY_COLUMN)
 Values
   ('01070309', 'X', 'Email', 'GROUP', NULL, 
    NULL, NULL, 'N', 'N', 'N', 
    'Y', 'N', 'Y', 'PIS', NULL, 
    '''0001'',''0002'',''0005''', '''0001'',''0002'',''0005''', NULL, 'pgUnderConstruction.aspx', NULL, 
    NULL, NULL, NULL, 'Y', NULL, 
    NULL, NULL, NULL);
COMMIT;


--------------------------------------------------------------------------

SET DEFINE OFF;
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, SYSROWID)
 Values
   ('1', '01070309', 'X', 'X', 'X', 
    'Y', 'X', 'N', 'X', 'PIS', 
    '202006091450080005205351');
COMMIT;


--------------------------------------------------------------------------


SET DEFINE OFF;
Insert into MENUMASTER_RND
   (MENUCODE, MENUNAME, MENUDESC, MENUTYPE, MENUTAG, MENUTAG1, MENUTAG2, ENTRYPOSSIBLE, EDITPOSSIBLE, DELETEPOSSIBLE, REPORTSPOSSIBLE, UTILITIESPOSSIBLE, ACTIVE, PROJECTNAME, MENUDETAILS, EFFECTIVEDIVISION, EFFECTIVEINDIVISION, PROCEDURE_SAVE_EDIT, URLSRC, FRM_HEIGHT, FRM_WIDTH, FUNCTIONCALL_BEFORE, FUNCTIONCALL_AFTER, VIEWPOSSIBLE, PRINTPOSSIBLE, DOCDATEVALIDATEFIELD, KEY_TABLE, KEY_COLUMN)
 Values
   ('0107030901', NULL, 'Payslip', 'REPORT', 'PIS_PAYSLIP_EMAIL', 
    NULL, NULL, 'Y', 'Y', 'Y', 
    'Y', 'N', 'Y', 'PIS', NULL, 
    '''0001'',''0002'',''0005'',''0010''', '''0001'',''0002'',''0005'',''0010''', NULL, 'PIS/Pages/Report/pgReportPISTemplate.aspx', NULL, 
    NULL, NULL, NULL, 'Y', NULL, 
    NULL, NULL, NULL);
COMMIT;



--------------------------------------------------------------------------

SET DEFINE OFF;
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, SYSROWID)
 Values
   ('1', '0107030901', 'X', 'X', 'X', 
    'Y', 'X', 'N', 'X', 'PIS', 
    '202006091450080005205352');
COMMIT;


--------------------------------------------------------------------------

--------------------------------------------------------------------------

--------------------------------------------------------------------------

--------------------------------------------------------------------------

--------------------------------------------------------------------------