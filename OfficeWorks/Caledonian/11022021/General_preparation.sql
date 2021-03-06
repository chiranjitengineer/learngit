SELECT * FROM MENUMASTER_RND
         WHERE UPPER(MENUDESC) LIKE UPPER('%GEN%PRE%')
         
         SELECT * FROM MENUMASTER_RND
         WHERE MENUCODE=''
         
         SELECT * FROM ROLEDETAILS
         WHERE MENUCODE=''
         
         SELECT * FROM REPORTPARAMETERMASTER
         WHERE REPORTTAG=''
         
         
         SELECT * FROM SYS_TFMAP
         WHERE SYS_TABLE_SEQUENCIER = '4023'
         
         SELECT * FROM SYS_TFMAP
         WHERE SYS_TABLENAME_ACTUAL = 'STORESRECEIPTMAST'
         AND SYS_COLUMNNAME LIKE 'GATECHALLANI%'
         
         
         SELECT * FROM SYS_TFMAP
         WHERE SYS_TABLENAME_TEMP = ''
         
         GATECHALLANINNO, 
         GATECHALLANINDATE
         
         
                 
         SET DEFINE OFF;
Insert into SYS_TFMAP
   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
 Values
   (4023, 'STORESRECEIPTMAST', 'GBL_STORESRECEIPTMAST', 'GATECHALLANINDATE', 43, 
    'DATE', 10, 0, 'N', 'mskGATECHALLANINDATE', 
    TO_TIMESTAMP('30/12/2014 5:23:48.000000 PM','DD/MM/YYYY fmHH12fm:MI:SS.FF AM'), 'Y', NULL, NULL);
Insert into SYS_TFMAP
   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
 Values
   (4023, 'STORESRECEIPTMAST', 'GBL_STORESRECEIPTMAST', 'GATECHALLANINNO', 42, 
    'VARCHAR2', 50, 0, 'N', 'txtGATECHALLANINNO', 
    TO_TIMESTAMP('30/12/2014 5:23:48.000000 PM','DD/MM/YYYY fmHH12fm:MI:SS.FF AM'), 'Y', NULL, NULL);
COMMIT;

EXEC PROC_CREATE_GBL_TMP_TABLES(4023,0)


SELECT * FROM SYS_HELP_QRY
WHERE QRY_ID='4352'


SET DEFINE OFF;
Insert into SYS_HELP_QRY
   (QRY_ID, QRY_STRING, PARAMETER_STRING, QRY_SHORTDESC, QRY_RETURN_TABLE_NAME, WEB_QRY_STRING, SEARCH_COLUMNLIST, MODULENAME)
 Values
   (4352, '""', 'COMPANYCODE~DIVISIONCODE~YEARCODE~PARTYCODE~PATTERN', 'CHALLAN IN NO', NULL, 
    ' SELECT DISTINCT TRANSACTIONNO,TO_CHAR(A.TRANSACTIONDATE,''DD/MM/YYYY'') TRANSACTIONDATE,A.OUTTYPE DOCTYPE,B.PARTYNAME,A.REPRESENTATIVE 
 FROM STORESCHALLANINDETAILS A ,PARTYMASTER B
  WHERE A.COMPANYCODE = B.COMPANYCODE
  AND A.PARTYCODE = B.PARTYCODE
  AND A.COMPANYCODE = <<COMPANYCODE>> 
   AND A.DIVISIONCODE =<<DIVISIONCODE>>
   AND A.DIVISIONCODE =<<DIVISIONCODE>>
   AND A.OUTTYPE = ''STORE''
   AND A.STKINDICATOR = ''IN''
   AND A.YEARCODE=<<YEARCODE>>
   AND B.PARTYTYPE =''SUPPLIER'' 
   AND B.MODULE = ''STORES''    
   AND A.PARTYCODE=<<PARTYCODE>>
   ORDER BY A.TRANSACTIONNO', 'TRANSACTIONNO~OUTTYPE~PARTYNAME~PARTYCODE~REPRESENTATIVE~', 'STORES');
COMMIT;


SELECT * FROM STORESCHALLANINDETAILS

C/CI/20/00014

STORESRECEIPTMAST