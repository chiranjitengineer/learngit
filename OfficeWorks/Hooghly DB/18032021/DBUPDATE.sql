SYS_AUTOGEN_PARAMS

SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%DUMMY%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE='0102020105'

SELECT * FROM ROLEDETAILS
WHERE MENUCODE=''

SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG=''


prcJutePODummy_Before_MainSave

JUTEPURCHASEORDERMASTER


SELECT * FROM SYS_TFMAP
WHERE SYS_TABLE_SEQUENCIER = '1023'

SELECT * FROM SYS_TFMAP
WHERE SYS_TABLENAME_ACTUAL = 'JUTEPURCHASEORDERMASTER'


SELECT * FROM SYS_TFMAP
WHERE SYS_TABLENAME_TEMP = ''


GBL_JUTEPURCHASEORDERMASTER


SET DEFINE OFF;
Insert into SYS_TFMAP
   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
 Values
   (1023, 'NONE', 'GBL_JUTEPURCHASEORDERMASTER', 'ISDUMMY', 
    8, 'VARCHAR2', 1, 0, 'N', 
    'txtISDUMMY', TO_TIMESTAMP('08/11/2014 11:20:59.000000 AM','DD/MM/YYYY fmHH12fm:MI:SS.FF AM'), 'Y', NULL, NULL);
COMMIT;


SELECT * FROM SYS_HELP_QRY
WHERE QRY_ID='1120'

VW_RUKA_STOCK_DETAILS_DUMMY