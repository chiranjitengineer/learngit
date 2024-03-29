SELECT * FROM LOGIN

SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%arriva%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE LIKE '01020203'


SELECT * FROM MENUMASTER_RND
WHERE MENUCODE LIKE '01020213'

SELECT * FROM ROLEDETAILS
WHERE MENUCODE='01020203'

SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG=''

--------------------------------------------------------------------------------

SET DEFINE OFF;
Insert into MENUMASTER_RND
   (MENUCODE, MENUNAME, MENUDESC, MENUTYPE, MENUTAG, MENUTAG1, MENUTAG2, ENTRYPOSSIBLE, EDITPOSSIBLE, DELETEPOSSIBLE, REPORTSPOSSIBLE, UTILITIESPOSSIBLE, ACTIVE, PROJECTNAME, MENUDETAILS, EFFECTIVEDIVISION, EFFECTIVEINDIVISION, PROCEDURE_SAVE_EDIT, URLSRC, FRM_HEIGHT, FRM_WIDTH, FUNCTIONCALL_BEFORE, FUNCTIONCALL_AFTER, VIEWPOSSIBLE, PRINTPOSSIBLE, DOCDATEVALIDATEFIELD, KEY_TABLE)
 Values
   ('01020213', NULL, 'Arrival Details without PO', 'TRANSACTIONS', NULL, 
    NULL, NULL, 'Y', 'Y', 'Y', 
    'N', 'N', 'Y', 'JUTE', NULL, 
    NULL, '''0001''', NULL, 'JUTE/Pages/Transaction/pgRawJuteArrival_without_PO.aspx', NULL, 
    NULL, 'prcJuteArr_Before_MainSave', NULL, 'Y', 'N', 
    NULL, NULL);
COMMIT;


SET DEFINE OFF;
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, SYSROWID)
 Values
   ('1', '01020213', 'Y', 'Y', 'Y', 
    'X', 'X', 'Y', 'X', 'JUTE', 
    '201904042021190011822202');
COMMIT;


--------------------------------------------------------------------------------

SELECT * FROM SYS_HELP_QRY
WHERE QRY_ID='1027'



SELECT * FROM SYS_HELP_QRY
WHERE QRY_ID='1025'


--------------------------------------------------------------------------------

SELECT ORDERNO, ORDERDATE, SUM(BALANCEUNIT) AS BALANCEUNIT, SUM(BALANCEQTY) AS BALANCEQTY
FROM ( 
        SELECT A.ORDERNO, TO_CHAR(A.ORDERDATE,'DD/MM/YYYY') ORDERDATE, SUM(A.BALES_ORDERED - A.BALES_RECEIVED - A.BALES_CANC_ADJ) BALANCEUNIT, SUM(A.QTY_ORDERED - A.QTY_RECEIVED - A.QTY_CANC_ADJ) BALANCEQTY 
        FROM VW_RUKA_STOCK_DETAILS A, JUTEPURCHASEORDERMASTER B
        WHERE A.COMPANYCODE = B.COMPANYCODE
          AND A.DIVISIONCODE = B.DIVISIONCODE
          AND A.ORDERNO = B.ORDERNO
          AND A.COMPANYCODE = <<COMPANYCODE>>
          AND A.DIVISIONCODE = <<DIVISIONCODE>>
          AND A.TRANSACTIONDATE <= TO_DATE(<<ARRIVALDATE>>,'DD/MM/YYYY')
        GROUP BY A.ORDERNO, A.ORDERDATE
        HAVING SUM(A.QTY_ORDERED - A.QTY_RECEIVED - A.QTY_CANC_ADJ) >0
        UNION ALL
        SELECT A.ORDERNO,TO_CHAR(A.ORDERDATE,'DD/MM/YYYY') AS ORDERDATE,-SUM(NVL(A.NOOFBALES,0)) AS BALANCEUNIT,-SUM(NVL(A.CHALLANWTINQT,0)) AS BALANCEQTY  
        FROM JUTEARRIVALDETAILS A, JUTEARRIVALMAST B
        WHERE A.COMPANYCODE = B.COMPANYCODE
          AND A.DIVISIONCODE = B.DIVISIONCODE
          AND A.ARRIVALNO = B.ARRIVALNO
          AND A.ARRIVALNO NOT IN (SELECT ARRIVALNO FROM JUTEMILLRECEIPTMAST)
          AND A.COMPANYCODE = <<COMPANYCODE>>
          AND A.DIVISIONCODE = <<DIVISIONCODE>>
          AND B.ARRIVALDATE <= TO_DATE(<<ARRIVALDATE>>,'DD/MM/YYYY')
        GROUP BY A.ORDERNO,A.ORDERDATE
) 
WHERE 1=1
GROUP BY ORDERNO, ORDERDATE
HAVING SUM(BALANCEQTY) > 0
ORDER BY ORDERNO



--------------------------------------------------------------------------------

SELECT * FROM JUTEMILLGRDREGIONDTL

SELECT COUNT(*)
AS LV_CNT
FROM JUTEMILLGRDREGIONDTL
WHERE COMPANYCODE = C1.COMPANYCODE
AND DIVISIONCODE = C1.DIVISIONCODE
AND REGIONCODE = LV_MASTER.REGIONCODE
AND MKTGRDCODE = C1.MKTGRDCODEMR
AND MILLGRDCODE = C1.MILLGRDCODEMR;


SELECT *
FROM JUTEMILLGRDREGIONDTL
WHERE COMPANYCODE = 'LJ0054'
AND DIVISIONCODE = '0001'
AND REGIONCODE = 'DS'


SELECT COUNT(*)
AS LV_CNT
FROM JUTEMILLGRDREGIONDTL
WHERE COMPANYCODE = 'LJ0054'
AND DIVISIONCODE = '0001'
AND REGIONCODE = 'DS'

AND MKTGRDCODE = 'TD7'
AND MILLGRDCODE = 'TD7DS';
        

--------------------------------------------------------------------------------
SELECT * FROM JUTEARRIVALMAST A
WHERE 1=1 AND A.ARRIVALNO = 'L/JAR/21/00287'

SELECT * FROM JUTEBOOKINGSTNMAST


 SELECT A.*, S.PARTYNAME SUPPLIERNAME, B.PARTYNAME BROKERNAME, R.REGIONDESC REGIONNAME , J.STNNAME BOOKINGSTATIONNAME, K.STNCODE AGENCY, K.STNNAME AGENCYNAME, C.CHANNELSUBTYPE AS CHANNELTAG 
FROM JUTEARRIVALMAST A, PARTYMASTER S, PARTYMASTER B, JUTEREGIONMAST R, 
JUTEPURCHASEORDERMASTER P , JUTEBOOKINGSTNMAST J, JUTEBOOKINGSTNMAST K, CHANNELMASTER C 
WHERE A.COMPANYCODE = S.COMPANYCODE   
  AND A.SUPPLIERCODE = S.PARTYCODE  
  AND S.MODULE = 'JUTE'  
  AND S.PARTYTYPE = 'SUPPLIER'  
  AND A.COMPANYCODE = B.COMPANYCODE   
  AND A.BROKERCODE = B.PARTYCODE  
  AND B.MODULE = 'JUTE'  
  AND B.PARTYTYPE = 'BROKER'  
  AND A.COMPANYCODE = R.COMPANYCODE  
  AND A.DIVISIONCODE = R.DIVISIONCODE  
  AND A.REGIONCODE = R.REGIONCODE  
  AND A.COMPANYCODE = P.COMPANYCODE 
  AND A.DIVISIONCODE = P.DIVISIONCODE 
  AND A.ORDERNO = P.ORDERNO 
  AND A.ORDERDATE = P.ORDERDATE 
  AND A.COMPANYCODE = J.COMPANYCODE 
  AND A.DIVISIONCODE = J.DIVISIONCODE 
  AND A.REGIONCODE = J.REGIONCODE 
  AND A.BOOKINGSTATION = J.STNCODE 
  AND A.COMPANYCODE =  'LJ0054'
  AND A.DIVISIONCODE = '0001'
  AND A.ARRIVALNO = 'L/JAR/21/00287'
  AND P.COMPANYCODE = K.COMPANYCODE 
  AND P.DIVISIONCODE = K.DIVISIONCODE 
  AND P.REGIONCODE = K.REGIONCODE 
  AND P.BOOKINGSTATION = K.STNCODE 
  AND C.COMPANYCODE = P.COMPANYCODE 
  AND C.DIVISIONCODE = P.DIVISIONCODE 
  AND C.CHANNELCODE = P.CHANNELCODE 
  AND C.MODULE = 'JUTE' 
  
  

--------------------------------------------------------------------------------

SELECT COUNT(*) FROM JUTEARRIVALMAST A,JUTEBOOKINGSTNMAST J
  WHERE  A.COMPANYCODE =  'LJ0054'
  AND A.DIVISIONCODE = '0001'
  AND A.ARRIVALNO = 'L/JAR/21/00287'  
  AND A.COMPANYCODE = J.COMPANYCODE 
  AND A.DIVISIONCODE = J.DIVISIONCODE 
  AND A.REGIONCODE = J.REGIONCODE 
  AND A.BOOKINGSTATION = J.STNCODE 
 
SELECT COUNT(*) FROM  JUTEBOOKINGSTNMAST A
 WHERE  A.COMPANYCODE =  'LJ0054'
  AND  A.DIVISIONCODE = '0001'
  AND  REGIONCODE ='DS'
  AND STNCODE = 'S016'

SQL = "   "
SQL = SQL & "SELECT COUNT(*) FROM  JUTEBOOKINGSTNMAST A "
SQL = SQL & " WHERE  A.COMPANYCODE =  'LJ0054' "
SQL = SQL & "  AND  A.DIVISIONCODE = '0001' "
SQL = SQL & "  AND  REGIONCODE ='DS' "
SQL = SQL & "  AND STNCODE = 'S016' "

     SELECT * FROM  JUTEBOOKINGSTNMAST A  
     WHERE  A.COMPANYCODE =  'LJ0054'   
     AND  A.DIVISIONCODE = '0001'   
     AND  REGIONCODE ='SN'   
     
     AND STNCODE = 'H008'  
   
   
 SELECT * 
FROM JUTEARRIVALMAST A, PARTYMASTER S, PARTYMASTER B, JUTEREGIONMAST R, 
JUTEPURCHASEORDERMASTER P  , JUTEBOOKINGSTNMAST J --, JUTEBOOKINGSTNMAST K --, CHANNELMASTER C 
WHERE A.COMPANYCODE = S.COMPANYCODE   
  AND A.SUPPLIERCODE = S.PARTYCODE  
  AND S.MODULE = 'JUTE'  
  AND S.PARTYTYPE = 'SUPPLIER'  
  AND A.COMPANYCODE = B.COMPANYCODE   
  AND A.BROKERCODE = B.PARTYCODE  
  AND B.MODULE = 'JUTE'  
  AND B.PARTYTYPE = 'BROKER'  
  AND A.COMPANYCODE = R.COMPANYCODE  
  AND A.DIVISIONCODE = R.DIVISIONCODE  
  AND A.REGIONCODE = R.REGIONCODE  
  AND A.COMPANYCODE = P.COMPANYCODE 
  AND A.DIVISIONCODE = P.DIVISIONCODE 
  AND A.ORDERNO = P.ORDERNO 
  AND A.ORDERDATE = P.ORDERDATE 
  AND A.COMPANYCODE = J.COMPANYCODE 
  AND A.DIVISIONCODE = J.DIVISIONCODE 
  AND A.REGIONCODE = J.REGIONCODE 
  AND A.BOOKINGSTATION = J.STNCODE 
  AND A.COMPANYCODE =  'LJ0054'
  AND A.DIVISIONCODE = '0001'
  AND A.ARRIVALNO = 'L/JAR/21/00287'
--  AND P.COMPANYCODE = K.COMPANYCODE 
--  AND P.DIVISIONCODE = K.DIVISIONCODE 
--  AND P.REGIONCODE = K.REGIONCODE 
--  AND P.BOOKINGSTATION = K.STNCODE 
--  AND C.COMPANYCODE = P.COMPANYCODE 
--  AND C.DIVISIONCODE = P.DIVISIONCODE 
--  AND C.CHANNELCODE = P.CHANNELCODE 
--  AND C.MODULE = 'JUTE' 
  
  
--------------------------------------------------------------------------------

SELECT * FROM SYS_PARAMETER
WHERE PARAMETER_NAME LIKE 'ARRIVAL %'


SELECT PARAMETER_VALUE FROM SYS_PARAMETER
WHERE PARAMETER_NAME LIKE 'ARRIVAL DETAILS COLUMN TO BE CHANGE'
AND COMPANYCODE='LJ0054'
AND DIVISIONCODE='0001'

--------------------------------------------------------------------------------

ORDER NO, ORDER DATE, BROKERCODE, REGIONCODE, BOOKINGSTATION, CONTRACT NO, CONTRACT DATE, SUPPLIERCODE
--------------------------------------------------------------------------------


 SELECT A.YEARCODE, A.ORDERNO, TO_CHAR(A.ORDERDATE,'DD/MM/YYYY') ORDERDATE, A.CONTRACTNO, TO_CHAR(A.CONTRACTDATE,'DD/MM/YYYY') CONTRACTDATE, A.BROKERCODE, A.SUPPLIERCODE, A.REGIONCODE, 
        A.BOOKINGSTATION, A.PAYMENTTYPE, A.DELIVERYDATE, A.NOOFBALES, A.WEIGHTINKG, A.DISCOUNT, A.ORDERVALUE, A.REMARKS, A.TYPEOFORDER, A.ISAGENCYPURCHASE, B.STNNAME, A.CHANNELCODE, C.CHANNELSUBTYPE  
 FROM JUTEPURCHASEORDERMASTER A, JUTEBOOKINGSTNMAST B, CHANNELMASTER C 
 WHERE A.COMPANYCODE = 'LJ0054' 
   AND A.DIVISIONCODE = '0001' 
   AND A.ORDERNO = 'L/JPO/21/00006' 
   AND A.COMPANYCODE = B.COMPANYCODE 
   AND A.DIVISIONCODE = B.DIVISIONCODE 
   AND A.REGIONCODE = B.REGIONCODE 
   AND A.BOOKINGSTATION = B.STNCODE 
   AND A.COMPANYCODE = C.COMPANYCODE 
   AND A.DIVISIONCODE = C.DIVISIONCODE 
   AND A.CHANNELCODE = C.CHANNELCODE 
   AND C.MODULE = 'JUTE' 
   
   
   
  SELECT * FROM SYS_TFMAP
  WHERE SYS_TABLE_SEQUENCIER = ''
  
  SELECT * FROM SYS_TFMAP
  WHERE SYS_TABLENAME_ACTUAL = 'JUTEARRIVALDETAILS'
  
  
  update SYS_TFMAP set SYS_KEYCOLUMN='N'
  WHERE SYS_TABLENAME_ACTUAL = 'JUTEARRIVALDETAILS'
  AND SYS_TABLE_SEQUENCIER='1026'
  AND SYS_COLUMNNAME='SYSROWID'
  
  
  SELECT * FROM SYS_TFMAP
  WHERE SYS_TABLENAME_TEMP = ''
  