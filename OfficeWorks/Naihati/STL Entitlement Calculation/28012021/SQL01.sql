



SELECT STLENTITLE_PROCEDURE PROCEDURENAME FROM WPSWAGESPARAMETER

PRCWPS_STLENT_PROCESS_YRWISE



SELECT COUNT(*) CNT FROM WPSSTLENTRY
 WHERE COMPANYCODE='NJ0001' 
   AND DIVISIONCODE='0002' 
   AND TO_CHAR(FORTNIGHTSTARTDATE,'YYYY')='2021' 
   AND LEAVECODE='STL' 
   AND NVL(ADDLESS,'LESS')='LESS'
   
   
--   
SELECT STLENTITLE_PROCEDURE PROCEDURENAME FROM WPSWAGESPARAMETER
 WHERE COMPANYCODE='NJ0001' 
   AND DIVISIONCODE='0002' 
   AND MODULENAME='WPS' 
   
   
    SELECT WORKERSERIAL FROM WPSWORKERMAST WHERE TOKENNO='' 
    
SELECT * FROM WPSWAGESPROCESSTYPE_PHASE WHERE PROCESSTYPE='WAGES PROCESS'   
    
EXEC PRCWPS_STLENT_PROCESS_YRWISE('NJ0001','0002','2020','SWT',1920, 0,160)

exec PRCWPS_STLENT_PROCESS_YRWISE('NJ0001','0002','2021','SWT',1920, 0,'',1920) 


DELETE FROM WPS_ERROR_LOG 
    
SELECT * FROM WPS_ERROR_LOG
    
CREATE TABLE WPSSTLTRANSACTION27012021 AS SELECT * FROM WPSSTLTRANSACTION

--PROC_WPSWAGES_OTHER_COMP_UPDT
PROC_WPS_CUMMULATIVE_UPDT
PROC_WPS_YTDMNTHGRS_UPDT

--DELETE FROM WPSSTLENTITLEMENTCALCDETAILS

SELECT * FROM WPSSTLENTRY WHERE DOCUMENTDATE >='16-JAN-2021'

SELECT * FROM WPSSTLWAGESDETAILS WHERE PAYMENTDATE >='16-JAN-2021'

SELECT * FROM WPSSTLENTITLEMENTCALCDETAILS
WHERE TOKENNO='50181'

DELETE WPSSTLENTITLEMENTCALCDETAILS

SELECT  COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, CATEGORYCODE, FROMYEAR, YEARCODE,
 FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, DEPARTMENTCODE, SHIFTCODE,
 ATTNHOURS, FESTHOURS, HOLIDAYHOURS, TOTALHOURS, STLHRSTAKEN, STLDAYSTAKEN,
 STANDARDSTLHOURS, ADJUSTEDHOURS, APPLICABLESTANDHOURS, STLDAYS, STLHOURS, STLDAYS_BF,
 TRANSACTIONTYPE, ADDLESS, USERNAME, LASTMODIFIED, SYSROWID FROM WPSSTLENTITLEMENTCALCDETAILS

create table WPSSTLENTITLEMENTCALCDETAILS1 as
SELECT * FROM WPSSTLENTITLEMENTCALCDETAILS



SELECT * FROM WPSSTLENTITLEMENTCALCDETAILS1



SELECT * FROM WPSWORKERSTLGRACEPERIODDAYS


DROP TABLE GLOSTER_WEB.WPSWORKERSTLGRACEPERIODDAYS CASCADE CONSTRAINTS;

CREATE TABLE WPSWORKERSTLGRACEPERIODDAYS
(
  COMPANYCODE   VARCHAR2(10 BYTE),
  DIVISIONCODE  VARCHAR2(10 BYTE),
  YEAR          VARCHAR2(10 BYTE),
  WORKERSERIAL  VARCHAR2(10 BYTE),
  TOKENNO       VARCHAR2(10 BYTE),
  JOINDATE      DATE,
  GRACEDAYS     NUMBER(11,2),
  MODULE        VARCHAR2(10 BYTE),
  USERNAME      VARCHAR2(50 BYTE),
  LASTMODIFIED  DATE                            DEFAULT SYSDATE,
  SYSROWID      VARCHAR2(50 BYTE)
)


CREATE TABLE STLGRACEDAYS_NJMCL27012021
(
    SLNO NUMBER(10),
    TOKENNO VARCHAR2(10),
    EMP_NAME VARCHAR2(200),
    GRACEDAYS NUMBER(12,2)
)

INSERT INTO WPSWORKERSTLGRACEPERIODDAYS
SELECT COMPANYCODE, DIVISIONCODE,'2021' YEAR, WORKERSERIAL, A.TOKENNO,B.DATEOFJOINING JOINDATE, GRACEDAYS,'WPS' MODULE,'MIGR' USERNAME,
SYSDATE LASTMODIFIED, FN_GENERATE_SYSROWID SYSROWID 
FROM STLGRACEDAYS_NJMCL27012021 A, WPSWORKERMAST B
WHERE A.TOKENNO=B.TOKENNO

FN_GENERATE_SYSROWID()



SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%STL%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE='01100306'

SELECT * FROM ROLEDETAILS
WHERE MENUCODE='01100306'

SELECT DISTINCT FORTNIGHTSTARTDATE FROM REPORTPARAMETERMASTER

WHERE REPORTTAG=''


SELECT  DISTINCT FORTNIGHTSTARTDATE , FORTNIGHTENDDATE FROM WPSWAGESDETAILS_MV

SELECT  DISTINCT FORTNIGHTSTARTDATE , FORTNIGHTENDDATE FROM WPSSTLTRANSACTION

SELECT * FROM WPSSTLENTITLEMENTCALCDETAILS WHERE TOKENNO='50181'


SELECT * FROM WPS_ERROR_LOG

EXEC PROC_RPT_WPSSTLDETAILS('NJ0001','0002','01/01/2021','15/01/2021','','','','','')


    P_COMPCODE VARCHAR2, 
    P_DIVCODE VARCHAR2, 
    P_PERIODFROM VARCHAR2, 
    P_PERIODTO VARCHAR2 DEFAULT NULL, 
    P_DEPTCODE VARCHAR2 DEFAULT 'N', 
    P_CATGCODE VARCHAR2 DEFAULT 'N', 
    P_UNITCODE VARCHAR2 DEFAULT 'N', 
    P_SHIFTCODE VARCHAR2 DEFAULT 'N', 
    P_TOKENNO VARCHAR2 DEFAULT 'N'
    
    
    
    
   EXEC PROC_RPT_STL_SANCTION_FORM('NJ0001', '0002', '16/01/2021','31/01/2021','')
   
   SELECT * FROM GTT_RPT_STL_SANCTION_FORM ORDER BY TO_DATE(DOCUMENTDATE,'DD/MM/YYYY'),TO_NUMBER(DOCUMENTNO),TOKENNO,YEAR
   
   select * from GTT_RPT_STL_SANCTION_FORM
   ORDER BY TO_NUMBER(DOCUMENTNO),TOKENNO,YEAR
   
   
   SELECT * FROM GTT_RPT_STL_SANCTION_FORM ORDER BY TO_DATE(DOCUMENTDATE,'DD/MM/YYYY'),TO_NUMBER(DOCUMENTNO),TOKENNO,YEAR
   