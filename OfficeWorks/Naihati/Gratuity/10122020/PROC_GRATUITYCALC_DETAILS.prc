CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_GRATUITYCALC_DETAILS
    (
        P_COMPANYCODE VARCHAR2,
        P_DIVISIONCODE VARCHAR2,        
        P_TOKENNO VARCHAR2 DEFAULT NULL
    )
AS
    LV_SQLSTR      VARCHAR2(6000);
    LV_COMPANY     VARCHAR2(150);
    LV_DIVISION    VARCHAR2(150);
    LV_COMPADDRESS    VARCHAR2(550);
  
BEGIN 


--   EXEC PROC_GRATUITYCALC_DETAILS('NJ0001','0002','''04053''')
   
 
    SELECT COMPANYNAME,COMPANYADDRESS1 INTO LV_COMPANY, LV_COMPADDRESS FROM COMPANYMAST WHERE COMPANYCODE=P_COMPANYCODE;
    SELECT DIVISIONNAME INTO LV_DIVISION FROM DIVISIONMASTER WHERE COMPANYCODE=P_COMPANYCODE AND DIVISIONCODE=P_DIVISIONCODE;

    DELETE FROM GTT_GRATUITY_CALC_SHEET WHERE 1=1;  
                
    LV_SQLSTR := NULL;   
--    LV_SQLSTR :=   LV_SQLSTR  ||  'INSERT INTO GTT_GRATUITYCALC_DETAILS'|| CHR(10);


LV_SQLSTR :=   LV_SQLSTR  ||  'INSERT INTO GTT_GRATUITY_CALC_SHEET'|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  '('|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  '    COMPANYCODE, DIVISIONCODE, COMPANYNAME, DIVISIONNAME, REPORTTYPE, '|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  '    WORKERNAME, EBNO, PFNO, TOKENNO, ESINO, OCCUPATIONNAME, DEPARTMENTNAME, '|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  '    EMPLOYEE_NATURE, SUPPERANNUATION_TYPE, '|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  '    DATEOFJOINING, SUPPERANNUATION_DATE, '|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  '    LASTPAYMENTDATE, SERVICEPERIOD, '|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  '    PAY_DATE, TOTAL_DAYS, TOTAL_HRS, BASIC,'|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  '    A_BASIC, FE, DA, NS_ALLOW, ADHOC, TSA, GROSS_EARN, PERDAY_EARN, '|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  '    DAILY_EARNING, SAL_15DAYS, SERVICEYEAR, NONCONT_YEAR, GRAYUITY_YEAR, '|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  '    GRATUITYAMOUNT, AMOUNT_INWORDS, REPORTNAME'|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  ')    '|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  'SELECT A.COMPANYCODE,B.DIVISIONCODE, '''||LV_COMPANY||''' COMPANYNAME, '''||LV_DIVISION||''' DIVISIONNAME, ''Original'' REPORTTYPE,'|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  'B.WORKERNAME, B.LBNO  EBNO,B.PFNO, A.TOKENNO,ESINO,B.OCCUPATIONNAME, DEPARTMENTNAME,'|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  '''Time Rate'' EMPLOYEE_NATURE,B.WORKERSTATUS SUPPERANNUATION_TYPE,'|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  'NVL(GRATUITYJOINDATE, PFMEMBERSHIPDATE) DATEOFJOINING,DATEOFTERMINATION SUPPERANNUATION_DATE,'|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  'LASTDATE LASTPAYMENTDATE,FN_DATEDIFF2(NVL(GRATUITYJOINDATE, PFMEMBERSHIPDATE),DATEOFTERMINATION)  SERVICEPERIOD,'|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  'PAY_DATE,TOTAL_DAYS,TOTAL_HRS,BASIC,A_BASIC,FE,C.DA,NS_ALLOW,ADHOC,TSA,GROSS_EARN,PERDAY_EARN, '|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  'A.SAL_15DAYS DAILY_EARNING,  A.SAL_15DAYS*15,ROUND((DATEOFTERMINATION-NVL(GRATUITYJOINDATE, PFMEMBERSHIPDATE))/365,0) SERVICEYEAR,(ROUND((DATEOFTERMINATION-NVL(GRATUITYJOINDATE, PFMEMBERSHIPDATE))/365,0)-GRATUITYYEAR) NONCONT_YEAR,GRATUITYYEAR GRAYUITY_YEAR,'|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  ' a.GRATUITYAMOUNT,  FN_NUM_TO_WORDS(a.GRATUITYAMOUNT,''RS'')  INWORDS, '|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  ' ''GRATUITY CALCULATION SHEET '' REPORTNAME'|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  'FROM GRATUITYSETTLEMENT A, WORKERVIEWGRATUITY B,'|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  '('|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  '    SELECT COMPANYCODE, DIVISIONCODE, TOKENNO, WORKERSERIAL, '|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  '    FORTNIGHTENDDATE PAY_DATE, NVL(TOTAL_HRS,0)/8 TOTAL_DAYS, NVL(TOTAL_HRS,0) TOTAL_HRS, '|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  '    NVL(FBASIC,0) BASIC, NVL(VBASIC,0) A_BASIC,NVL(FBASIC_PEICERT,0) FE , NVL(DA,0) DA, '|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  '    NVL(NS_ALLOW,0) NS_ALLOW, NVL(ADHOC,0) ADHOC, NVL(TSA,0) TSA, NVL(TOTAL_AMT,0) GROSS_EARN,'|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  '    DECODE( NVL(TOTAL_HRS,0),0,0,  NVL(TOTAL_AMT,0)/(NVL(TOTAL_HRS,0)/8)) PERDAY_EARN'|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  '    FROM GRATUITYCOMPONENTRATE'|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  ') C'|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  'WHERE A.WORKERSERIAL=B.WORKERSERIAL '|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  '    AND A.COMPANYCODE=C.COMPANYCODE '|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  '    AND A.DIVISIONCODE=C.DIVISIONCODE '|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  '    AND A.WORKERSERIAL=C.WORKERSERIAL '|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  '    AND B.COMPANYCODE = '''||P_COMPANYCODE||''''|| CHR(10);
LV_SQLSTR :=   LV_SQLSTR  ||  '    AND B.DIVISIONCODE = '''||P_DIVISIONCODE||'''  '|| CHR(10);

                
                
IF P_TOKENNO IS NOT NULL THEN
    LV_SQLSTR := LV_SQLSTR ||   '  AND A.TOKENNO IN ('|| P_TOKENNO ||')' ||CHR(10) ;
END IF;  
            
    LV_SQLSTR := LV_SQLSTR ||   '  ORDER BY A.TOKENNO ' ||CHR(10) ;   
                                      
    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
    EXECUTE IMMEDIATE LV_SQLSTR;

UPDATE GTT_GRATUITY_CALC_SHEET SET COMP_ADDRESS = LV_COMPADDRESS WHERE 1=1;

END;
/
