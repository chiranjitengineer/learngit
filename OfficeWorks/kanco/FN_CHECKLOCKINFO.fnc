CREATE OR REPLACE FUNCTION KANCO_WEB.FN_CHECKLOCKINFO
(
    P_GBL_TABLE VARCHAR2,
    P_DATEVALUE VARCHAR2,
    P_MENUCODE VARCHAR2,
    P_COMPANYCODE VARCHAR2 DEFAULT NULL,
    P_DIVISIONCODE VARCHAR2 DEFAULT NULL
)
RETURN VARCHAR2
AS
LV_SQLSTR VARCHAR2(4000);
LV_RETSTR VARCHAR2(10);
LV_COMP VARCHAR2(10);
LV_CNT NUMBER;
BEGIN 

LV_COMP := REPLACE(upper(P_COMPANYCODE),'NULL',null);
--SELECT COUNT(*) INTO LV_CNT FROM MENUMASTER_RND WHERE MENUCODE=P_MENUCODE AND UPPER(MENUTYPE) LIKE 'TRANS%';

SELECT COUNT(C.COLUMNNAME) XX INTO LV_CNT FROM
(
    SELECT A.SYS_TABLENAME_ACTUAL TABLENAME,A.SYS_COLUMNNAME COLUMNNAME FROM SYS_TFMAP A
    WHERE A.SYS_TABLENAME_TEMP=P_GBL_TABLE
) B,
(
    SELECT * FROM CHECKLOCKDATEINFO
--    WHERE PROJECTNAME='GPS'
) C
WHERE   1=1
AND     B.COLUMNNAME=C.COLUMNNAME
AND     B.TABLENAME=C.TABLENAME;

--DBMS_OUTPUT.PUT_LINE(LV_CNT);

IF LV_CNT = 0 THEN
    LV_RETSTR := '1';
ELSE
    SELECT COUNT(*) XX INTO LV_RETSTR FROM LOCKDATE A,
    (
        SELECT A.SYS_TABLENAME_ACTUAL TABLENAME,A.SYS_COLUMNNAME COLUMNNAME FROM SYS_TFMAP A
        WHERE A.SYS_TABLENAME_TEMP=P_GBL_TABLE
    --    AND A.SYS_COLUMNNAME='SUSPENDDATE'
    ) B,
    (
        SELECT * FROM CHECKLOCKDATEINFO
    --    WHERE COLUMNNAME='SUSPENDDATE'
    ) C
    WHERE  A.PROJECTNAME=C.PROJECTNAME
    AND B.COLUMNNAME=C.COLUMNNAME
    AND  B.TABLENAME=C.TABLENAME
    AND TO_DATE(P_DATEVALUE,'DD/MM/YYYY') BETWEEN LOCKSTARTDATE AND LOCKENDDATE
    AND A.COMPANYCODE=NVL(LV_COMP,A.COMPANYCODE)
    AND A.DIVISIONCODE=NVL(P_DIVISIONCODE,A.DIVISIONCODE);
END IF;

--EXECUTE IMMEDIATE LV_SQLSTR ;

RETURN LV_RETSTR ;

--DROP TABLE JOONKTOLLEELIVE.LOCKDATE CASCADE CONSTRAINTS;

--CREATE TABLE CHECKLOCKDATEINFO
--(
--  PROJECTNAME    VARCHAR2(50 BYTE),
--  TABLENAME      VARCHAR2(30 BYTE),
--  TABLEFIELD     VARCHAR2(30 BYTE),
--  SYSROWID       VARCHAR2(100 BYTE),
--  LASTMODIFIED   DATE                 DEFAULT sysdate
--)

--SELECT * FROM CHECKLOCKDATEINFO

--SELECT COUNT(*) XX FROM LOCKDATE A
--WHERE PROJECTNAME='GPS'
--AND TO_DATE('01/10/2019','DD/MM/YYYY') BETWEEN A.LOCKSTARTDATE AND A.LOCKENDDATE 


--SELECT * FROM LOCKDATE A
--WHERE PROJECTNAME='GPS'
--AND TO_DATE('01/10/2019','DD/MM/YYYY') BETWEEN A.LOCKSTARTDATE AND A.LOCKENDDATE 

-- SELECT COUNT(*) XX FROM LOCKDATE AWHERE PROJECTNAME='GPS'AND TO_DATE('18/10/2019','DD/MM/YYYY') BETWEEN A.LOCKSTARTDATE AND A.LOCKENDDATE
-- 
--SELECT COUNT(*) XX FROM LOCKDATE A,
--(
--    SELECT PROJECTNAME,MENUTYPE FROM MENUMASTER_RND WHERE MENUCODE='011002010101'    
--) B
--WHERE A.PROJECTNAME=A.PROJECTNAME AND A.PROJECTNAME='GPS'
--AND UPPER(MENUTYPE) LIKE 'TRANS%'
--AND TO_DATE('19/10/2019','DD/MM/YYYY') BETWEEN LOCKSTARTDATE AND LOCKENDDATE


-- SELECT * FROM MENUMASTER_RND WHERE PROJECTNAME='GPS' AND UPPER(MENUTYPE) LIKE 'TRANS%'
-- 
-- 
-- 
--SELECT COUNT(*) XX FROM LOCKDATE A,
--(
--    SELECT PROJECTNAME,MENUTYPE FROM MENUMASTER_RND WHERE MENUCODE='01100224'    
--)B
--WHERE A.PROJECTNAME=B.PROJECTNAME AND A.PROJECTNAME='GPS'
--AND UPPER(MENUTYPE) LIKE 'TRANS%'
--AND SYSDATE BETWEEN LOCKSTARTDATE AND LOCKENDDATE

--GBL_GPSSUSPENDDETAILS

--SELECT * FROM SYS_TFMAP A
--WHERE A.SYS_TABLENAME_TEMP='GBL_GPSSUSPENDDETAILS'




--SELECT A.SYS_TABLENAME_ACTUAL FROM SYS_TFMAP A
--WHERE A.SYS_TABLENAME_TEMP='GBL_GPSSUSPENDDETAILS'
--AND A.SYS_COLUMNNAME='SUSPENDDATE'

--SELECT * FROM CHECKLOCKDATEINFO




--SELECT COUNT(*) XX FROM LOCKDATE A,
--(
--    SELECT A.SYS_TABLENAME_ACTUAL TABLENAME,A.SYS_COLUMNNAME COLUMNNAME FROM SYS_TFMAP A
--    WHERE A.SYS_TABLENAME_TEMP='GBL_GPSSUSPENDDETAILS'
----    AND A.SYS_COLUMNNAME='SUSPENDDATE'
--) B,
--(
--    SELECT * FROM CHECKLOCKDATEINFO
----    WHERE COLUMNNAME='SUSPENDDATE'
--) C,
--(
--    SELECT PROJECTNAME,MENUTYPE FROM MENUMASTER_RND WHERE MENUCODE='01100224' AND UPPER(D.MENUTYPE) LIKE 'TRANS%'   
--)D
--WHERE  A.PROJECTNAME=C.PROJECTNAME
--AND B.COLUMNNAME=C.COLUMNNAME
--AND  B.TABLENAME=C.TABLENAME
--AND TO_DATE('19/10/2019','DD/MM/YYYY') BETWEEN LOCKSTARTDATE AND LOCKENDDATE
--AND UPPER(D.MENUTYPE) LIKE 'TRANS%'


--FN_CHARGE_LIST


--SELECT FN_CHECKLOCKINFO('GBL_GPSSUSPENDDETAILS','18/10/2019','01100224') XX FROM DUAL





--SELECT C.COLUMNNAME FROM
--(
--    SELECT A.SYS_TABLENAME_ACTUAL TABLENAME,A.SYS_COLUMNNAME COLUMNNAME FROM SYS_TFMAP A
--    WHERE A.SYS_TABLENAME_TEMP='GBL_GPSSUSPENDDETAILS'
--) B,
--(
--    SELECT * FROM CHECKLOCKDATEINFO
----    WHERE PROJECTNAME='GPS'
--) C
--WHERE   1=1
--AND     B.COLUMNNAME=C.COLUMNNAME
--AND     B.TABLENAME=C.TABLENAME


--SELECT COUNT(*) XX FROM LOCKDATE A,
--(
--    SELECT PROJECTNAME,MENUTYPE FROM MENUMASTER_RND WHERE MENUCODE='01100224'    
--)B
--WHERE A.PROJECTNAME=B.PROJECTNAME AND A.PROJECTNAME='GPS'
--AND UPPER(MENUTYPE) LIKE 'TRANS%'
--AND SYSDATE BETWEEN LOCKSTARTDATE AND LOCKENDDATE




--SELECT COUNT(C.COLUMNNAME) XX FROM
--(
--    SELECT A.SYS_TABLENAME_ACTUAL TABLENAME,A.SYS_COLUMNNAME COLUMNNAME FROM SYS_TFMAP A
--    WHERE A.SYS_TABLENAME_TEMP='GBL_GPSSUSPENDDETAILS'
--) B,
--(
--    SELECT * FROM CHECKLOCKDATEINFO
----    WHERE PROJECTNAME='GPS'
--) C
--WHERE   1=1
--AND     B.COLUMNNAME=C.COLUMNNAME
--AND     B.TABLENAME=C.TABLENAME




--SELECT C.COLUMNNAME FROM
--(
--    SELECT A.SYS_TABLENAME_ACTUAL TABLENAME,A.SYS_COLUMNNAME COLUMNNAME FROM SYS_TFMAP A
--    WHERE A.SYS_TABLENAME_TEMP='GBL_SALESCATEGORYMASTER'
--) B,
--(
--    SELECT * FROM CHECKLOCKDATEINFO
--  --  WHERE PROJECTNAME='PRODUCTION_COFFEE'
--) C
--WHERE 1 = 1
--AND     B.COLUMNNAME=C.COLUMNNAME
--AND     B.TABLENAME=C.TABLENAME




--SELECT * FROM SYS_TFMAP


--SELECT DISTINCT 'GPS' PROJECTNAME,SYS_TABLENAME_ACTUAL,SYS_COLUMNNAME,SYS_DATATYPE,SYS_KEYCOLUMN FROM SYS_TFMAP
--WHERE SYS_DATATYPE='DATE' AND SYS_KEYCOLUMN='Y'
--AND SYS_TABLENAME_ACTUAL LIKE 'GPS%'
--UNION
--SELECT DISTINCT 'PIS' PROJECTNAME,SYS_TABLENAME_ACTUAL,SYS_COLUMNNAME,SYS_DATATYPE,SYS_KEYCOLUMN FROM SYS_TFMAP
--WHERE SYS_DATATYPE='DATE' AND SYS_KEYCOLUMN='Y'
--AND SYS_TABLENAME_ACTUAL LIKE 'PIS%'
--UNION
--SELECT DISTINCT 'ACCOUNTS' PROJECTNAME,SYS_TABLENAME_ACTUAL,SYS_COLUMNNAME,SYS_DATATYPE,SYS_KEYCOLUMN FROM SYS_TFMAP
--WHERE SYS_DATATYPE='DATE' AND SYS_KEYCOLUMN='Y'
--AND SYS_TABLENAME_ACTUAL LIKE 'AC%'
--UNION
--SELECT DISTINCT 'SALES' PROJECTNAME, SYS_TABLENAME_ACTUAL,SYS_COLUMNNAME,SYS_DATATYPE,SYS_KEYCOLUMN FROM SYS_TFMAP
--WHERE SYS_DATATYPE='DATE' AND SYS_KEYCOLUMN='Y'
--AND SYS_TABLENAME_ACTUAL LIKE 'SALE%'


--UNION


--SELECT LISTAGG(COLUMNNAME,'~')
--WITHIN GROUP (ORDER BY TABLENAME) AS SUBJECTS
-- FROM CHECKLOCKDATEINFO


--SELECT 'PUR' PROJECTNAME,SYS_TABLENAME_ACTUAL,SYS_COLUMNNAME,SYS_DATATYPE,SYS_KEYCOLUMN FROM SYS_TFMAP
--WHERE SYS_DATATYPE='DATE' AND SYS_KEYCOLUMN='Y'
--AND SYS_TABLENAME_ACTUAL LIKE 'PUR%'


--DELETE FROM CHECKLOCKDATEINFO;

--INSERT INTO CHECKLOCKDATEINFO
--(
--  PROJECTNAME,TABLENAME,COLUMNNAME
--)
--SELECT PROJECTNAME,SYS_TABLENAME_ACTUAL TABLENAME, SYS_COLUMNNAME COLUMNNAME FROM 
--(
--    SELECT DISTINCT 'GPS' PROJECTNAME,SYS_TABLENAME_ACTUAL ,SYS_COLUMNNAME,SYS_DATATYPE,SYS_KEYCOLUMN FROM SYS_TFMAP
--    WHERE SYS_DATATYPE='DATE' AND SYS_KEYCOLUMN='Y'
--    AND SYS_TABLENAME_ACTUAL LIKE 'GPS%'
--    UNION
--    SELECT DISTINCT 'PIS' PROJECTNAME,SYS_TABLENAME_ACTUAL,SYS_COLUMNNAME,SYS_DATATYPE,SYS_KEYCOLUMN FROM SYS_TFMAP
--    WHERE SYS_DATATYPE='DATE' AND SYS_KEYCOLUMN='Y'
--    AND SYS_TABLENAME_ACTUAL LIKE 'PIS%'
--    UNION
--    SELECT DISTINCT 'ACCOUNTS' PROJECTNAME,SYS_TABLENAME_ACTUAL,SYS_COLUMNNAME,SYS_DATATYPE,SYS_KEYCOLUMN FROM SYS_TFMAP
--    WHERE SYS_DATATYPE='DATE' AND SYS_KEYCOLUMN='Y'
--    AND SYS_TABLENAME_ACTUAL LIKE 'AC%'
--    UNION
--    SELECT DISTINCT 'SALES' PROJECTNAME, SYS_TABLENAME_ACTUAL,SYS_COLUMNNAME,SYS_DATATYPE,SYS_KEYCOLUMN FROM SYS_TFMAP
--    WHERE SYS_DATATYPE='DATE' AND SYS_KEYCOLUMN='Y'
--    AND SYS_TABLENAME_ACTUAL LIKE 'SALE%'
--    UNION
--    SELECT DISTINCT 'STORES' PROJECTNAME, SYS_TABLENAME_ACTUAL,SYS_COLUMNNAME,SYS_DATATYPE,SYS_KEYCOLUMN FROM SYS_TFMAP
--    WHERE SYS_DATATYPE='DATE' AND SYS_KEYCOLUMN='Y'
--    AND SYS_TABLENAME_ACTUAL LIKE 'STORE%'    
--)



--SELECT LISTAGG(COLUMNNAME,'~')
--WITHIN GROUP (ORDER BY TABLENAME) AS SUBJECTS
-- FROM CHECKLOCKDATEINFO
-- WHERE TABLENAME='PISLEAVEAPPLICATION'


--SELECT TABLENAME, COLUMNNAME FROM CHECKLOCKDATEINFO



--CREATE TABLE CHECKLOCKDATEINFO
--(
--  PROJECTNAME   VARCHAR2(50 BYTE),
--  TABLENAME     VARCHAR2(30 BYTE),
--  COLUMNNAME    VARCHAR2(30 BYTE),
--  SYSROWID      VARCHAR2(100 BYTE)              DEFAULT SYS_GUID(),
--  LASTMODIFIED  DATE                            DEFAULT sysdate,
--  USERNAME      VARCHAR2(50 BYTE)               DEFAULT 'SWT'
--)
END;
/