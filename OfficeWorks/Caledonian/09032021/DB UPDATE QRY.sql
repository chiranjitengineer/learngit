

CREATE TABLE WPSLEAVEMASTER
(
  COMPANYCODE                 VARCHAR2(10 BYTE),
  DIVISIONCODE                VARCHAR2(10 BYTE),
  LEAVECODE                   VARCHAR2(5 BYTE)  NOT NULL,
  LEAVEDESC                   VARCHAR2(500 BYTE),
  LEAVESHORTDESC              VARCHAR2(3 BYTE),
  LEAVECF                     VARCHAR2(1 BYTE)  DEFAULT 'N',
  LEAVEENCASH                 VARCHAR2(1 BYTE)  DEFAULT 'N',
  LEAVEINDEX                  NUMBER(3),
  LEAVEENTITLEMENTAPPLICABLE  VARCHAR2(1 BYTE),
  WITHOUTPAYLEAVE             VARCHAR2(1 BYTE),
  INCLUDENIGHTSHIFT           VARCHAR2(1 BYTE),
  LEAVECARRYFORWARDLIMIT      NUMBER(3),
  USERNAME                    VARCHAR2(100 BYTE) NOT NULL,
  LASTMODIFIED                DATE              DEFAULT SYSDATE,
  SYSROWID                    VARCHAR2(50 BYTE) NOT NULL
)

WPSLEAVEAPPLICATION

select * from 
DEPARTMENTMASTER


DROP TABLE DEPARTMENTMASTER CASCADE CONSTRAINTS;

CREATE TABLE DEPARTMENTMASTER
(
  COMPANYCODE              VARCHAR2(10 BYTE)    NOT NULL,
  DIVISIONCODE             VARCHAR2(10 BYTE)    NOT NULL,
  DEPARTMENTCODE           VARCHAR2(10 BYTE)    NOT NULL,
  DEPARTMENTNAME           VARCHAR2(50 BYTE)    NOT NULL,
  DEPARTMENTTYPE           VARCHAR2(50 BYTE),
  NSAAPPLICABLE            VARCHAR2(1 BYTE)     DEFAULT 'N',
  ISMACHINEDEPENDENT       VARCHAR2(1 BYTE)     DEFAULT 'N',
  PRINTABLEDEPARTMENTCODE  VARCHAR2(10 BYTE),
  USERNAME                 VARCHAR2(100 BYTE)   NOT NULL,
  LASTMODIFIED             DATE                 DEFAULT SYSDATE,
  SYSROWID                 VARCHAR2(50 BYTE)    NOT NULL,
  FIXEDHANDS               NUMBER(11,2)         DEFAULT 0,
  DEPTGROUPCODE            VARCHAR2(10 BYTE)
)


SELECT * FROM MENUMASTER_RND_bk080321
WHERE MENUCODE like '0107%'



delete FROM MENUMASTER_RND
WHERE MENUCODE like '0107%'

delete FROM ROLEDETAILS
WHERE MENUCODE like '0107%'



SELECT * FROM SYS_HELP_QRY
WHERE MODULENAME = 'WPS'


SELECT QRY_ID FROM SYS_HELP_QRY
WHERE MODULENAME = 'WPS'
ORDER BY QRY_ID

SELECT * FROM SYS_HELP_QRY
WHERE MODULENAME = 'WPS'
AND QRY_ID='6022'

ORDER BY QRY_ID





SELECT WM_CONCAT(''''||SYS_TABLE_SEQUENCIER||'''') FROM (
SELECT DISTINCT SYS_TABLE_SEQUENCIER FROM SYS_TFMAP
WHERE SYS_TABLENAME_ACTUAL like  '%WPS%'
)


SELECT DISTINCT SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL FROM SYS_TFMAP
WHERE SYS_TABLE_SEQUENCIER IN (
'5003','5006','15012','11008','15018','20084','5005','15017','15019','15020','20086','20109',
'5015','5016','11010','15011','15015','20096','5004','5009','5026','11006','15013','15014',
'20082','20110','20114','5008','5023','20077','20078','20079','20085','5002','5013','5022',
'5050','11013','20080','20092','20099','5014','20089','20090','20091'
)
AND SYS_TABLENAME_ACTUAL <> 'NONE'



SELECT DISTINCT SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL FROM SYS_TFMAP
WHERE SYS_TABLE_SEQUENCIER IN (
'5002','5003','5004','5005','5006','5008','5009','5013','5014','5015','5016',
'5022','5023','5026','5050','11006','11008','11010','11013',
--'15011','15012','15013','15014','15015','15017','15018','15019','15020',
'20077','20078','20079','20080','20082','20084','20085','20086','20089',
'20090','20091','20092','20096','20099','20109','20110','20114'
)
AND SYS_TABLENAME_ACTUAL <> 'NONE'

20088
20114


SELECT DISTINCT SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL FROM SYS_TFMAP
WHERE SYS_TABLE_SEQUENCIER IN (
'15011','15012','15013','15014','15015','15017','15018','15019','15020'
)
AND SYS_TABLENAME_ACTUAL <> 'NONE'

SELECT * FROM SYS_TFMAP
WHERE SYS_TABLE_SEQUENCIER = '15011'

SELECT MAX(SYS_TABLE_SEQUENCIER) FROM SYS_TFMAP

WHERE SYS_TABLENAME_ACTUAL = ''


SELECT * FROM SYS_TFMAP
WHERE SYS_TABLENAME_TEMP = ''


JUTEBALESHORTWTSLAB
SALESGOVTBILLREFMAPPING

20088



--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

INSERT INTO SYS_TFMAP

SELECT * FROM NJMCL_WEB.SYS_TFMAP
WHERE SYS_TABLE_SEQUENCIER IN (
'5002','5003','5004','5005','5006','5008','5009','5013','5014','5015','5016',
'5022','5023','5026','5050','11006','11008','11010','11013',
--'15011','15012','15013','15014','15015','15017','15018','15019','15020',
'20077','20078','20079','20080','20082','20084','20085','20086','20089',
'20090','20091','20092','20096','20099','20109','20110','20114'
)



SELECT * FROM NJMCL_WEB.SYS_TFMAP
WHERE SYS_TABLE_SEQUENCIER IN (
'15011','15012','15013','15014','15015','15017','15018','15019','15020'
)


SELECT (SELECT MAX(SYS_TABLE_SEQUENCIER) FROM SYS_TFMAP) + LEVEL FROM DUAL 
CONNECT BY LEVEL <= 9 + 
(
    SELECT MAX(SYS_TABLE_SEQUENCIER) FROM SYS_TFMAP
) 


    SELECT MAX(SYS_TABLE_SEQUENCIER) FROM SYS_TFMAP

SELECT * FROM NJMCL_WEB.
WHERE SYS_TABLE_SEQUENCIER IN (
'15011','15012','15013','15014','15015','15017','15018','15019','15020'
)



INSERT INTO SYS_TFMAP
--
SELECT 20114 + 10 SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, 
SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, 
SYS_USEMAP, SYS_DEFAULT, TDSCODE, IS_EDITABLE, ISCONVERT_TOUPPER
FROM NJMCL_WEB.SYS_TFMAP
WHERE SYS_TABLE_SEQUENCIER = 15010 + 10

SELECT * FROM SYS_TFMAP WHERE  SYS_TABLE_SEQUENCIER > 20114


--------------------------------------------------------------------------------

SELECT * FROM SYS_HELP_QRY
WHERE QRY_ID IN (
'6100','7001','7002','7003','7004','7005','7007','7008','7009','7010','7011',
'7012','7013','7014','7015','7016','7017','7018','7019','7020','7021','7022',
'7023','7024','7025','7026','7027','7028','7029','7030','7031','7032','7033',
'7035','7036','7040','7041','7042','7071','7501','7502','7506','7507','7508'
)

--------------------------------------------------------------------------------

SELECT * FROM DIVISIONMASTER

SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%PIS%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE='0107'

UPDATE MENUMASTER_RND
SET EFFECTIVEDIVISION = '''0001'',''0002''',
    EFFECTIVEINDIVISION = '''0001'',''0002'''
WHERE MENUCODE LIKE '0107%'

SELECT * FROM ROLEDETAILS
WHERE MENUCODE=''

SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG=''

--------------------------------------------------------------------------------
 
 COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, DEPARTMENTNAME, DEPARTMENTTYPE, 
 NSAAPPLICABLE, ISMACHINEDEPENDENT, PRINTABLEDEPARTMENTCODE, USERNAME, 
 LASTMODIFIED, SYSROWID, FIXEDHANDS, DEPTGROUPCODE
 
 
 SELECT COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, DEPARTMENTNAME, DEPARTMENTTYPE,NULL NSAAPPLICABLE, ISMACHINEDEPENDENT,NULL PRINTABLEDEPARTMENTCODE, 
DEPARTMENTCODE DEPTGROUPCODE,NULL FIXEDHANDS, 'SWT' USERNAME, SYSDATE LASTMODIFIED, SYS_GUID() SYSROWID
FROM WPSDEPARTMENTMAST@

 
TRG_INSUPD_WPSWORKERMAST

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------