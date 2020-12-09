SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%LEAVE%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE LIKE '0110015404'

SELECT * FROM ROLEDETAILS
WHERE MENUCODE='0110015404'

SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG=''



SET DEFINE OFF;
Insert into MENUMASTER_RND
   (MENUCODE, MENUNAME, MENUDESC, MENUTYPE, MENUTAG, MENUTAG1, MENUTAG2, ENTRYPOSSIBLE, EDITPOSSIBLE, DELETEPOSSIBLE, REPORTSPOSSIBLE, UTILITIESPOSSIBLE, ACTIVE, PROJECTNAME, MENUDETAILS, EFFECTIVEDIVISION, EFFECTIVEINDIVISION, PROCEDURE_SAVE_EDIT, URLSRC, FRM_HEIGHT, FRM_WIDTH, FUNCTIONCALL_BEFORE, FUNCTIONCALL_AFTER, VIEWPOSSIBLE, PRINTPOSSIBLE, DOCDATEVALIDATEFIELD)
 Values
   ('01100228', NULL, 'Bulk Leave Entry', 'TRANSACTION', NULL, 
    NULL, NULL, 'Y', 'Y', 'N', 
    'N', 'N', 'Y', 'GPS', NULL, 
    '''0001'',''0002''', '''0001'',''0002''', NULL, 'GPS/Pages/Transaction/pgBulkLeaveEntry.aspx', NULL, 
    NULL, NULL, 'PROC_GPSLVAPPLICATION_UPDATE', 'N', 'N', 
    NULL);
COMMIT;


SET DEFINE OFF;
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, SYSROWID)
 Values
   ('1', '01100228', 'Y', 'Y', 'Y', 
    'X', 'X', 'X', 'X', 'GPS', 
    '202009211036100005744279');
COMMIT;


PROC_GPSLVAPPLICATION_UPDATE

SELECT MAX(SYS_TABLE_SEQUENCIER) FROM SYS_TFMAP

WHERE SYS_TABLE_SEQUENCIER = '20066'


GPSLEAVEAPPLICATION


ALTER TABLE GPSLEAVEAPPLICATION ADD MODETYPE VARCHAR2(30)



SELECT * FROM SYS_HELP_QRY
WHERE QRY_ID='20066'

SET DEFINE OFF;
Insert into SYS_HELP_QRY
   (QRY_ID, QRY_STRING, PARAMETER_STRING, QRY_SHORTDESC, QRY_RETURN_TABLE_NAME, WEB_QRY_STRING, SEARCH_COLUMNLIST, MODULENAME)
 Values
   (24024, '""', 'COMPANYCODE~DIVISIONCODE~PATTERN', 'CLUSTER INFORMATION', NULL, 
    'SELECT DISTINCT CLUSTERCODE,CLUSTERDESC FROM GPSCLUSTERMASTER
 WHERE COMPANYCODE=<<COMPANYCODE>>
  AND DIVISIONCODE=<<DIVISIONCODE>>
  ORDER BY CLUSTERCODE', 'CLUSTERCODE~', 'GPS');
COMMIT;


SELECT DISTINCT TOKENNO,EMPLOYEENAME FROM GPSEMPLOYEEMAST 
WHERE COMPANYCODE=<<COMPANYCODE>>
AND DIVISIONCODE=<<DIVISIONCODE>>
AND ATTNBOOKCODE=<<ATTNBOOKCODE>>
AND CATEGORYCODE=<<CATEGORYCODE>>
AND CLUSTERCODE =<<CLUSTERCODE>>
ORDER BY TOKENNO


SELECT DISTINCT LEAVECODE, LEAVEDESC
FROM GPSLEAVEMASTER 
WHERE LEAVEENTITLEMENTAPPLICABLE='Y'
ORDER BY LEAVECODE





SELECT * FROM GPSLEAVEPARAMS


 strSQL = "PRC_GPSLEAVEBALANCE ('" & HttpContext.Current.Session("COMPANYCODE") & "','" & HttpContext.Current.Session("DIVISIONCODE") & "','" & HttpContext.Current.Session("YEARCODE") & "','" & fromDATE & "',1,'','')"
            dbManager.ExecuteScalar(CommandType.StoredProcedure, strSQL)

EXEC PRC_GPSLEAVEBALANCE('DT0091','0001','2020-2021','19/11/2020',1,'','')