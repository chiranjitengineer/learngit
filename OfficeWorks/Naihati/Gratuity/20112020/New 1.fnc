SELECT * FROM JSWRAPPER


SELECT * FROM GRATUITYENTITLEMENTYEAR
WHERE TOKENNO='04053'


SELECT * FROM SYS_TFMAP
WHERE SYS_TABLENAME_ACTUAL = 'GRATUITYSETTLEMENT'


SELECT * FROM 


SELECT * FROM SYS_TFMAP
WHERE SYS_TABLENAME_ACTUAL = ''


SELECT SYS_COLUMNNAME FROM SYS_TFMAP
WHERE SYS_TABLENAME_TEMP = 'GBL_GRATUITYSETTLEMENT'
AND SYS_KEYCOLUMN='Y'


SELECT * FROM SYS_TFMAP
WHERE SYS_TABLE_SEQUENCIER = ''


SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE=''

SELECT * FROM ROLEDETAILS
WHERE MENUCODE=''

SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG=''



GRATUITYSETTLEMENT

SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE=''

SELECT * FROM ROLEDETAILS
WHERE MENUCODE=''

SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG=''

EXEC PROC_CREATE_GBL_TMP_TABLES(10,0)





EXEC PROC_CREATE_SYSTFMAP('GRATUITYSETTLEMENT','COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO','',20112)

SELECT * FROM SYS_TFMAP WHERE  SYS_TABLE_SEQUENCIER = 20112

EXEC PROC_CREATE_GBL_TMP_TABLES(20112,0)


PRCWPS_GRATUITY_SETTLE_B4SAVE 


SELECT * FROM GRATUITYSETTLEMENT

delete FROM GRATUITYSETTLEMENT


select * from querymaster




SELECT * FROM SYS_PARAMETER
--
WHERE PARAMETER_NAME ='GRATUITY COMPONENTS'

FBASIC_PEICERT,FBASIC,VBASIC,DA,TSA,ADHOC,NS_ALLOW,NS_HRS,ATTENDANCEHOURS


SELECT SUM(FBASIC_PEICERT) FBASIC_PEICERT, SUM(FBASIC) FBASIC
, SUM(VBASIC) VBASIC, SUM(DA) DA, SUM(TSA) TSA, SUM(ADHOC) ADHOC, SUM(NS_ALLOW) NS_ALLOW,
(SUM(FBASIC_PEICERT) +SUM(FBASIC)+ SUM(VBASIC)+SUM(DA)+SUM(TSA)+SUM(ADHOC)+SUM(NS_ALLOW))/
(SUM(NS_HRS) +SUM(ATTENDANCEHOURS))


DROP TABLE GRATUITYCOMPONENTRATE

CREATE TABLE GRATUITYCOMPONENTRATE
(
    COMPANYCODE VARCHAR2(10),
    DIVISIONCODE VARCHAR2(10),
    TOKENNO VARCHAR2(10),
    WORKERSERIAL VARCHAR2(10),
    FORTNIGHTSTARTDATE DATE,
    FORTNIGHTENDDATE DATE,
    TRANSTYPE VARCHAR2(30),
    MODULE VARCHAR2(10),
    FBASIC_PEICERT NUMBER(20,6),
    FBASIC NUMBER(20,6),
    VBASIC NUMBER(20,6),
    DA NUMBER(20,6),
    TSA NUMBER(20,6),
    ADHOC NUMBER(20,6),
    NS_ALLOW NUMBER(20,6),
    NS_HRS NUMBER(20,6),
    ATTENDANCEHOURS NUMBER(20,6)
)


SELECT FN_GET_FORM_QRY_WEB (38, 'COMPANYCODE:NJ0001~DIVISIONCODE:0002~TOKENNO:04053' ) FROM DUAL


SELECT * FROM WPSWAGESDETAILS
WHERE TOKENNO='04053'

SELECT * FROM VW_WPSSECTIONMAST

DELETE FROM GRATUITYCOMPONENTRATE

SELECT * FROM GRATUITYCOMPONENTRATE


INSERT INTO GRATUITYCOMPONENTRATE
(
    COMPANYCODE, DIVISIONCODE, TOKENNO, WORKERSERIAL, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, 
    TRANSTYPE, MODULE, 
    FBASIC_PEICERT, FBASIC, VBASIC, DA, TSA, ADHOC, NS_ALLOW, NS_HRS, ATTENDANCEHOURS
)

SELECT A.COMPANYCODE, A.DIVISIONCODE,A.TOKENNO,WORKERSERIAL, FORTNIGHTSTARTDATE,FORTNIGHTENDDATE,
'FORTNIGHT DETAILS' TRANSTYPE, 'WPS' MODULE,
A.FBASIC_PEICERT, A.FBASIC,A.VBASIC ,A.DA,
A.TSA,A.ADHOC , (CASE WHEN B.PFLINKHOURS >0 THEN A.NS_ALLOW ELSE 0 END) NS_ALLOW 
,(CASE WHEN B.PFLINKHOURS >0 THEN A.NIGHTALLOWANCEHOURS ELSE 0 END) NS_HRS , A.ATTENDANCEHOURS
FROM WPSWAGESDETAILS A, VW_WPSSECTIONMAST  B
WHERE TOKENNO='04053' --'04053'
AND A.COMPANYCODE='NJ0001'
AND A.DIVISIONCODE='0002'
AND A.SECTIONCODE=B.SECTIONCODE
AND A.COMPANYCODE=B.COMPANYCODE
AND A.DIVISIONCODE=B.DIVISIONCODE
AND A.DEPARTMENTCODE=B.DEPARTMENTCODE
AND FORTNIGHTENDDATE IN 
(
    SELECT FORTNIGHTENDDATE FROM 
    (
        SELECT ROW_NUMBER() OVER (ORDER BY FORTNIGHTENDDATE DESC) RNO, FORTNIGHTENDDATE
        FROM WPSWAGESDETAILS 
        WHERE TOKENNO='04053' --'04053'
        AND COMPANYCODE='NJ0001'
        AND DIVISIONCODE='0002'
--        GROUP BY FORTNIGHTENDDATE
    )
    WHERE RNO <= 
    (
        SELECT CASE WHEN VBASIC > 0 THEN 6 ELSE 1 END FROM
        (
            SELECT SUM(VBASIC)  VBASIC FROM WPSWAGESDETAILS
            WHERE FORTNIGHTENDDATE IN
            (
                SELECT FORTNIGHTENDDATE FROM 
                (
                    SELECT ROW_NUMBER() OVER (ORDER BY FORTNIGHTENDDATE DESC) RNO
                    FROM WPSWAGESDETAILS 
                    WHERE TOKENNO='04053' --'04053'
                    AND COMPANYCODE='NJ0001'
                    AND DIVISIONCODE='0002'
                    GROUP BY FORTNIGHTENDDATE
                )
                WHERE RNO <= 6
            )
            AND TOKENNO='04053' --'04053'
            AND COMPANYCODE='NJ0001'
            AND DIVISIONCODE='0002'
        )
    )
);



INSERT INTO GRATUITYCOMPONENTRATE
(
    COMPANYCODE, DIVISIONCODE, TOKENNO, WORKERSERIAL, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, 
    TRANSTYPE, MODULE, 
    FBASIC_PEICERT, FBASIC, VBASIC, DA, TSA, ADHOC, NS_ALLOW, NS_HRS, ATTENDANCEHOURS
)

SELECT COMPANYCODE, DIVISIONCODE, TOKENNO, WORKERSERIAL, 
MIN(FORTNIGHTSTARTDATE) FORTNIGHTSTARTDATE ,MAX(FORTNIGHTENDDATE) FORTNIGHTENDDATE ,
'TOTAL RATE PER HOUR' TRANSTYPE,'WPS' MODULE,
ROUND(SUM(FBASIC_PEICERT)/(SUM(NS_HRS)+SUM(ATTENDANCEHOURS)),5) FBASIC_PEICERT, 
SUM(FBASIC)/(SUM(NS_HRS)+SUM(ATTENDANCEHOURS)) FBASIC, 
SUM(VBASIC)/(SUM(NS_HRS)+SUM(ATTENDANCEHOURS)) VBASIC, 
SUM(DA)/(SUM(NS_HRS)+SUM(ATTENDANCEHOURS)) DA, 
SUM(TSA)/(SUM(NS_HRS)+SUM(ATTENDANCEHOURS)) TSA, 
SUM(ADHOC)/(SUM(NS_HRS)+SUM(ATTENDANCEHOURS)) ADHOC, 
SUM(NS_ALLOW)/(SUM(NS_HRS)+SUM(ATTENDANCEHOURS)) NS_ALLOW, 
SUM(NS_HRS)/(SUM(NS_HRS)+SUM(ATTENDANCEHOURS)) NS_HRS, 
SUM(ATTENDANCEHOURS)/(SUM(NS_HRS)+SUM(ATTENDANCEHOURS)) ATTENDANCEHOURS
FROM GRATUITYCOMPONENTRATE
GROUP BY COMPANYCODE, DIVISIONCODE, TOKENNO, WORKERSERIAL


SELECT COUNT(VBASIC) FROM WPSWAGESDETAILS
WHERE TOKENNO='04053'
AND FORTNIGHTENDDATE = 
(
    SELECT MAX(FORTNIGHTENDDATE) FROM WPSWAGESDETAILS
    WHERE TOKENNO='04053' 
)
AND NVL(VBASIC,0) > 0



EXEC PROC_CREATE_SYSTFMAP('GRATUITYCOMPONENTRATE','COMPANYCODE, DIVISIONCODE, TOKENNO, WORKERSERIAL, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, TRANSTYPE')

COMPANYCODE, DIVISIONCODE, TOKENNO, WORKERSERIAL, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, TRANSTYPE 


SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE=''


SELECT * FROM ROLEDETAILS
WHERE MENUCODE=''


SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG = ''

SELECT * FROM SYS_TFMAP
--WHERE SYS_TABLE_SEQUENCIER='20126'
--
WHERE SYS_TABLENAME_ACTUAL='GRATUITYSETTLEMENT'

EXEC PROC_CREATE_GBL_TMP_TABLES(20112,0)


EXEC PROC_GRATUITYRATE_CALC('NJ0001','0002','04053','WPS')

EXEC PROC_GRATUITYRATE_CALC('NJ0001','0002','04053','WPS')

SELECT COMPANYCODE, DIVISIONCODE, TOKENNO, WORKERSERIAL, 
TO_CHAR(FORTNIGHTSTARTDATE,'DD/MM/YYYY') FORTNIGHTSTARTDATE, TO_CHAR(FORTNIGHTENDDATE,'DD/MM/YYYY') FORTNIGHTENDDATE,
TRANSTYPE, MODULE, FBASIC_PEICERT, FBASIC, VBASIC, DA, TSA, ADHOC, NS_ALLOW, NS_HRS, ATTENDANCEHOURS
 FROM GBL_GRATUITYCOMPONENTRATE
 order by TRANSTYPE,FORTNIGHTSTARTDATE
 
 
SELECT FORTNIGHTENDDATE FROM 
(
    SELECT ROW_NUMBER() OVER (ORDER BY FORTNIGHTENDDATE DESC) RNO,FORTNIGHTENDDATE
    FROM WPSWAGESDETAILS 
    WHERE TOKENNO='04053' --'04053'
    AND COMPANYCODE='NJ0001'
    AND DIVISIONCODE='0002'
    GROUP BY FORTNIGHTENDDATE
)
WHERE RNO <= 1



 SELECT * FROM WPSWAGESDETAILS
    WHERE TOKENNO='04053' --
    AND COMPANYCODE='NJ0001'
    AND DIVISIONCODE='0002'
    AND FORTNIGHTENDDATE = 
    (
        SELECT MAX(FORTNIGHTENDDATE) FROM WPSWAGESDETAILS
        WHERE TOKENNO='04053' 
        and nvl(ATTENDANCEHOURS,0) > 0
    )
    
    AND NVL(VBASIC,0) > 0;
    
    
    

SELECT * FROM GRATUITYCOMPONENTRATE


SELECT FN_GET_FORM_QRY_WEB (38, 'COMPANYCODE:NJ0001~DIVISIONCODE:0002~TOKENNO:04053' ) FROM DUAL 

SELECT FN_CHECK_GRATUITY_ELEGIBILITY('NJ0001','0002','04053') ELEGIBILITY FROM DUAL



SELECT COMPANYCODE, DIVISIONCODE, TOKENNO, WORKERSERIAL, 
TO_CHAR(FORTNIGHTSTARTDATE,'DD/MM/YYYY') FORTNIGHTSTARTDATE, TO_CHAR(FORTNIGHTENDDATE,'DD/MM/YYYY') FORTNIGHTENDDATE,
TRANSTYPE, MODULE, FBASIC_PEICERT, FBASIC, VBASIC, DA, TSA, ADHOC, NS_ALLOW, NS_HRS, ATTENDANCEHOURS
FROM GRATUITYCOMPONENTRATE
WHERE TOKENNO =''
WHERE COMPANYCODE =''
WHERE DIVISIONCODE =''
ORDER BY TRANSTYPE,FORTNIGHTSTARTDATE


SELECT COMPANYCODE, DIVISIONCODE, YEARCODE, WORKERSERIAL, TOKENNO, GRATUITYSETTLEMENTNO, 
GRATUITYAMOUNT, OTHEREARNING, LOANCAPITALBAL, LOANINTERESTBAL, OTHERDEDUCTION, NETPAYABLE, 
TO_CHAR(SETTLEMENTDATE,'DD/MM/YYYY') SETTLEMENTDATE,TO_CHAR(GRATUITYENTDATE,'DD/MM/YYYY') GRATUITYENTDATE, 
TO_CHAR(DETACHMENTDATE,'DD/MM/YYYY') DETACHMENTDATE, CHEQUENO, CHEQUEDATE, BANKCODE, REMARKS, 
AUTHORISEDBY, DESIGNATION, MODULE, CATEGORYCODE, GRADECODE, GRATUITYYEAR, SAL_15DAYS
FROM GRATUITYSETTLEMENT



