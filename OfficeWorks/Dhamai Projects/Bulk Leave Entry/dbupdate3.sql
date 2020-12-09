PROC_GPSLVAPPLICATION_UPDATE


SELECT * FROM SYS_TFMAP
WHERE SYS_TABLE_SEQUENCIER = '20066'

SELECT * FROM SYS_TFMAP
WHERE SYS_TABLENAME_ACTUAL = 'GBL_GPSLVAPPLICATION'


SELECT * FROM SYS_TFMAP
WHERE SYS_TABLENAME_TEMP = 'GBL_GPSLVAPPLICATION'



GPSLEAVEAPPLICATION


SELECT * FROM SYS_HELP_QRY
WHERE QRY_ID='24024'

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