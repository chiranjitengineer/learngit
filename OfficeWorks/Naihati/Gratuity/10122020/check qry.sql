INSERT INTO GTT_GRATUITY_CALC_SHEET
(
    COMPANYCODE, DIVISIONCODE, COMPANYNAME, DIVISIONNAME, REPORTTYPE, 
    WORKERNAME, EBNO, PFNO, TOKENNO, ESINO, OCCUPATIONNAME, DEPARTMENTNAME, 
    EMPLOYEE_NATURE, SUPPERANNUATION_TYPE, 
    DATEOFJOINING, SUPPERANNUATION_DATE, 
    LASTPAYMENTDATE, SERVICEPERIOD, 
    PAY_DATE, TOTAL_DAYS, TOTAL_HRS, BASIC,
    A_BASIC, FE, DA, NS_ALLOW, ADHOC, TSA, GROSS_EARN, PERDAY_EARN, 
    DAILY_EARNING, SAL_15DAYS, SERVICEYEAR, NONCONT_YEAR, GRAYUITY_YEAR, 
    GRATUITYAMOUNT, AMOUNT_INWORDS, REPORTNAME
)    

SELECT NVL(GRATUITYJOINDATE, PFMEMBERSHIPDATE),DATEOFTERMINATION, A.COMPANYCODE,B.DIVISIONCODE, 'THE NAIHATI JUTE MILLS  COMPANY LTD.' COMPANYNAME, 'MILL' DIVISIONNAME, 'Original' REPORTTYPE,
B.WORKERNAME, B.LBNO  EBNO,B.PFNO, A.TOKENNO,ESINO,B.OCCUPATIONNAME, DEPARTMENTNAME,
'Time Rate' EMPLOYEE_NATURE,B.WORKERSTATUS SUPPERANNUATION_TYPE,
NVL(GRATUITYJOINDATE, PFMEMBERSHIPDATE) DATEOFJOINING,DATEOFTERMINATION SUPPERANNUATION_DATE,
LASTDATE LASTPAYMENTDATE,FN_DATEDIFF2(NVL(GRATUITYJOINDATE, PFMEMBERSHIPDATE),DATEOFTERMINATION)  SERVICEPERIOD,
PAY_DATE,TOTAL_DAYS,TOTAL_HRS,BASIC,A_BASIC,FE,C.DA,NS_ALLOW,ADHOC,TSA,GROSS_EARN,PERDAY_EARN, 
A.SAL_15DAYS DAILY_EARNING,  A.SAL_15DAYS*15,ROUND((DATEOFTERMINATION-NVL(GRATUITYJOINDATE, PFMEMBERSHIPDATE))/365,0)  SERVICEYEAR,0 NONCONT_YEAR,GRATUITYYEAR GRAYUITY_YEAR,
 a.GRATUITYAMOUNT,  FN_NUM_TO_WORDS(a.GRATUITYAMOUNT,'RS')  INWORDS, 
 'GRATUITY CALCULATION SHEET ' REPORTNAME
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
  
  SELECT (TO_DATE('16/09/2020','DD/MM/YYYY') -  TO_DATE('19/01/2019','DD/MM/YYYY'))/365, ROUND((TO_DATE('16/09/2020','DD/MM/YYYY') -  TO_DATE('19/01/2019','DD/MM/YYYY'))/365,0) FROM GRATUITYSETTLEMENT