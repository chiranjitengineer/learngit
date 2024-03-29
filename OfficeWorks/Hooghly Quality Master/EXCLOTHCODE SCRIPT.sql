SET DEFINE OFF;
Insert into SYS_HELP_QRY
   (QRY_ID, QRY_STRING, PARAMETER_STRING, QRY_SHORTDESC, QRY_RETURN_TABLE_NAME, WEB_QRY_STRING, SEARCH_COLUMNLIST, MODULENAME)
 Values
   (3009, '""', 'COMPANYCODE~DIVISIONCODE~PATTERN', 'EX CLOTH DESC INFORMATION', NULL, 
    'SELECT QUALITYDESCRIPTION,QUALITYCODE QUALITYCODE__HIDDEN,QUALITYTYPE
FROM SALESQUALITYMASTER
WHERE QUALITYTYPE=''CLOTH''
AND COMPANYCODE=<<COMPANYCODE>>
AND DIVISIONCODE=<<DIVISIONCODE>>
ORDER BY QUALITYCODE', 'QUALITYCODE~QUALITYDESCRIPTION~', 'SALES');
COMMIT;


--------------------------------------------------------------------------------




alter table salesqualitymaster add EXCLOTHCODE VARCHAR2(10)

alter table GBL_salesqualitymaster add EXCLOTHCODE VARCHAR2(10)


--------------------------------------------------------------------------------

SET DEFINE OFF;
Insert into SYS_TFMAP
   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
 Values
   (3029, 'SALESQUALITYMASTER', 'GBL_SALESQUALITYMASTER', 'EXCLOTHCODE', 3, 
    'VARCHAR2', 10, 0, 'N', 'txtEXCLOTHCODE', 
    TO_TIMESTAMP('19/02/2021 12:59:12.000000 PM','DD/MM/YYYY fmHH12fm:MI:SS.FF AM'), 'Y', NULL, NULL);
COMMIT;
