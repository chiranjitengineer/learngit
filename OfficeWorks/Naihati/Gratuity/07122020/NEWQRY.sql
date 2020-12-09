SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%gratuity%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE='0110041402'

SELECT * FROM ROLEDETAILS
WHERE MENUCODE=''

SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG=''



INSERT INTO GTT_GRATUITYCALC_DETAILS
(
    EX1, EBNO, WORKERNAME, PFNO, TOKENNO, OCCUPATIONNAME, DEPARTMENTNAME, AGE, DATEOFJOINING, DATEOFTERMINATION, LASTWAGESDRAWN, 
    GRATUITYPAYABLE, INWORDS, COMPANYCODE, DIVISIONCODE, COMPANYNAME, DIVISIONNAME, REPORTTYPE,EX6, REPORTNAME
)

DROP TABLE GTT_GRATUITYCALC_DETAILS


INSERT INTO GTT_GRATUITYCALC_DETAILS
(
    EBNO, WORKERNAME, PFNO, TOKENNO, OCCUPATIONNAME, DEPARTMENTNAME, AGE, DATEOFJOINING, 
    PAY_DATE, TOTAL_DAYS, TOTAL_HRS, BASIC, A_BASIC, FE, DA, NS_ALLOW, ADHOC, TSA, GROSS_EARN, 
    PERDAY_EARN, DATEOFTERMINATION, LASTWAGESDRAWN, GRATUITYPAYABLE, INWORDS, 
    COMPANYCODE, DIVISIONCODE, COMPANYNAME, DIVISIONNAME, REPORTTYPE, LENGTHOFGRATUITY, REPORTNAME
)                        
SELECT A.TOKENNO EBNO,B.WORKERNAME, B.PFNO, A.TOKENNO,B.OCCUPATIONNAME, DEPARTMENTNAME,
EXTRACT(YEAR FROM SYSDATE)-EXTRACT(YEAR FROM DATEOFBIRTH)  AGE,NVL(GRATUITYJOINDATE, PFMEMBERSHIPDATE) DATEOFJOINING,
PAY_DATE,TOTAL_DAYS,TOTAL_HRS,BASIC,A_BASIC,FE,C.DA,NS_ALLOW,ADHOC,TSA,GROSS_EARN,PERDAY_EARN, 
DATEOFTERMINATION, A.SAL_15DAYS LASTWAGESDRAWN, NETPAYABLE GRATUITYPAYABLE,  FN_NUM_TO_WORDS(NETPAYABLE,'RS')  INWORDS, 
A.COMPANYCODE,B.DIVISIONCODE, 'THE NAIHATI JUTE MILLS  COMPANY LTD.' COMPANYNAME, 'MILL' DIVISIONNAME, 'Original' REPORTTYPE, 
GRATUITYYEAR LENGTHOFGRATUITY, 'GRATUITY ON '||B.WORKERSTATUS REPORTNAME
FROM GRATUITYSETTLEMENT A, WORKERVIEWGRATUITY B,
(
    SELECT COMPANYCODE, DIVISIONCODE, TOKENNO, WORKERSERIAL, 
    FORTNIGHTENDDATE PAY_DATE, NVL(TOTAL_HRS,0)/8 TOTAL_DAYS, NVL(TOTAL_HRS,0) TOTAL_HRS, 
    NVL(FBASIC,0) BASIC, NVL(VBASIC,0) A_BASIC,NVL(FBASIC_PEICERT,0) FE , NVL(DA,0) DA, 
    NVL(NS_ALLOW,0) NS_ALLOW, NVL(ADHOC,0) ADHOC, NVL(TSA,0) TSA, NVL(TOTAL_AMT,0) GROSS_EARN,
    DECODE( NVL(TOTAL_HRS,0),0,0,  NVL(TOTAL_AMT,0)/(NVL(TOTAL_HRS,0)/8)) PERDAY_EARN
    FROM GRATUITYCOMPONENTRATE
) C
WHERE A.WORKERSERIAL=B.WORKERSERIAL 
    AND A.COMPANYCODE=C.COMPANYCODE 
    AND A.DIVISIONCODE=C.DIVISIONCODE 
    AND A.WORKERSERIAL=C.WORKERSERIAL 
    AND B.COMPANYCODE = 'NJ0001'
    AND B.DIVISIONCODE = '0002'  
    ORDER BY A.TOKENNO 


SELECT * FROM GRATUITYCOMPONENTRATE

SELECT COMPANYCODE, DIVISIONCODE, TOKENNO, WORKERSERIAL, 
FORTNIGHTENDDATE PAY_DATE, NVL(TOTAL_HRS,0)/8 TOTAL_DAYS, NVL(TOTAL_HRS,0) TOTAL_HRS, 
NVL(FBASIC,0) BASIC, NVL(VBASIC,0) A_BASIC,NVL(FBASIC_PEICERT,0) FE , NVL(DA,0) DA, 
NVL(NS_ALLOW,0) NS_ALLOW, NVL(ADHOC,0) ADHOC, NVL(TSA,0) TSA, NVL(TOTAL_AMT,0) GROSS_EARN,
DECODE( NVL(TOTAL_HRS,0),0,0,  NVL(TOTAL_AMT,0)/(NVL(TOTAL_HRS,0)/8)) PERDAY_EARN
FROM GRATUITYCOMPONENTRATE