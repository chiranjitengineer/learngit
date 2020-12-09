
INSERT INTO GTT_GRATUITYCALC_DETAILS
(
    EBNO, WORKERNAME, PFNO, TOKENNO, OCCUPATIONNAME, DEPARTMENTNAME, AGE, DATEOFJOINING, 
    PAY_DATE, TOTAL_DAYS, TOTAL_HRS, BASIC, A_BASIC, FE, DA, NS_ALLOW, ADHOC, TSA, GROSS_EARN, 
    PERDAY_EARN, DATEOFTERMINATION, LASTWAGESDRAWN, GRATUITYPAYABLE, INWORDS, 
    COMPANYCODE, DIVISIONCODE, COMPANYNAME, DIVISIONNAME, REPORTTYPE, LENGTHOFGRATUITY, REPORTNAME
)  


EMP_NAME, EBNO, PFNO, RECORDNO, ESINO, DESIGNATION, DEPARTMENT, EMPLOYEE_NATURE,SUPPERANNUATION_TYPE, 
JOINING_DATE, SUPPERANNUATION_DATE, LASTPAYMENTDATE, SERVICEPERIOD,

DAILY_EARNING, SAL_15DAYS, SERVICEYEAR, NONCONT_YEAR, GRAYUITY_YEAR, GRATUITY_AMT,AMOUNT_INWORDS

SELECT * FROM WORKERVIEWGRATUITY WHERE TOKENNO='00754'


        End Try

select * from gratuitysettlement

select fn_datediff('','')
                   
SELECT B.WORKERNAME, A.TOKENNO EBNO,B.PFNO, A.TOKENNO,B.OCCUPATIONNAME, DEPARTMENTNAME,
NVL(GRATUITYJOINDATE, PFMEMBERSHIPDATE) DATEOFJOINING,
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
  AND A.TOKENNO IN ('04053')
  ORDER BY A.TOKENNO




                   
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
  AND A.TOKENNO IN ('04053')
  ORDER BY A.TOKENNO
  
  
  
  
exec PRC_STLBAL_YEARWISE ( 'NJ0001','0002', '07/12/2020', '50183')


            dbManager.CommitTransaction()



--------------------------------------------------------------------------------

     INSERT INTO GBL_STLBAL ( COMPANYCODE, DIVISIONCODE, LEAVECODE, YEAR, ASONDATE, WORKERSERIAL, TOKENNO, 
     ENTITLE_DAYS, PREV_STLDAYS, STLTAKEN_DAYS, STLBAL_DAYS) 
     
     
     SELECT A.COMPANYCODE, A.DIVISIONCODE, 'STL' LEAVECODE, B.YEARCODE,  
     TO_DATE('07/12/2020','DD/MM/YYYY') ASONDATE, B.WORKERSERIAL, A.TOKENNO, 
     SUM(STLDAYS) ENTITLE_DAYS, SUM(PREV_STLDAYS) PREV_STLDAYS, SUM(STLDAYS_TAKEN) STLTAKEN_DAYS,  
     (SUM(STLDAYS) + SUM(PREV_STLDAYS) - SUM(STLDAYS_TAKEN)) STLBAL_DAYS 
     FROM WPSWORKERMAST A, 
     (   
         SELECT WORKERSERIAL,FROMYEAR YEARCODE, STLDAYS,PREV_STLDAYS, 0 STLDAYS_TAKEN 
         FROM WPSSTLTRANSACTION  
         WHERE COMPANYCODE = 'NJ0001' AND DIVISIONCODE = '0002'  
         AND FROMYEAR BETWEEN '2017' AND '2019'
         AND TOKENNO = '50183' 
         UNION ALL 
         SELECT WORKERSERIAL,/*'2020'*/YEAR YEARCODE, 0  STLDAYS,0 PREV_STLDAYS, SUM(LEAVEDAYS) STLDAYS_TAKEN 
         FROM WPSSTLENTRYDETAILS  
         WHERE COMPANYCODE = 'NJ0001' AND DIVISIONCODE = '0002'  
         AND PAYMENTDATE<=TO_DATE('07/12/2020','DD/MM/YYYY')
         AND YEAR BETWEEN '2017' AND '2019'
         AND LEAVECODE='STL' AND LEAVEDAYS>0
         AND TOKENNO = '50183' 
         GROUP BY WORKERSERIAL,YEAR    
     ) B 
     WHERE A.COMPANYCODE = 'NJ0001' AND A.DIVISIONCODE = '0002'  
      AND A.WORKERSERIAL = B.WORKERSERIAL 
      GROUP BY A.COMPANYCODE, A.DIVISIONCODE, B.YEARCODE, B.WORKERSERIAL, A.TOKENNO
      
      
      
      SELECT *
         FROM WPSSTLENTRYDETAILS  
         WHERE COMPANYCODE = 'NJ0001' AND DIVISIONCODE = '0002'  
         AND PAYMENTDATE<=TO_DATE('07/12/2020','DD/MM/YYYY')
         AND YEAR BETWEEN '2017' AND '2019'
         AND LEAVECODE='STL' AND LEAVEDAYS>0
         AND TOKENNO = '50183' 
         
     
     select * from wpsstlentry
     where tokenno='50183'
     
     
         SELECT a.WORKERSERIAL,/*'2020'*/b.YEAR YEARCODE, 0  STLDAYS,0 PREV_STLDAYS, SUM(LEAVEDAYS) STLDAYS_TAKEN 
         FROM WPSSTLENTRYDETAILS a, (
            select workerserial,DOCUMENTNO,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, year from  wpsstlentry
         )  b
         WHERE COMPANYCODE = 'NJ0001' AND DIVISIONCODE = '0002'  
         AND PAYMENTDATE<=TO_DATE('07/12/2020','DD/MM/YYYY')
         AND b.YEAR BETWEEN '2017' AND '2019'
         AND LEAVECODE='STL' AND LEAVEDAYS>0
         AND TOKENNO = '50183' 
         and a.workerserial=b.workerserial
         and a.documentno=b.documentno
         GROUP BY a.WORKERSERIAL,b.YEAR        
         
         
      
      SELECT *
         FROM WPSwagesdetails_mv
         where tokenno='50183'
         and to_char(fortnightstartdate,'yyyy')='2017'
         
         
         WHERE COMPANYCODE = 'NJ0001' AND DIVISIONCODE = '0002'  
         AND PAYMENTDATE<=TO_DATE('07/12/2020','DD/MM/YYYY')
         AND YEAR BETWEEN '2017' AND '2019'
--         AND LEAVECODE='STL' AND LEAVEDAYS>0
         AND TOKENNO = '50183' 
         and to_char(fortnightstartdate,'yyyy')='2017'
         
         
         GROUP BY WORKERSERIAL,YEAR    
         
         
              INSERT INTO GBL_STLBAL ( COMPANYCODE, DIVISIONCODE, LEAVECODE, YEAR, ASONDATE, WORKERSERIAL, TOKENNO, 
     ENTITLE_DAYS, PREV_STLDAYS, STLTAKEN_DAYS, STLBAL_DAYS) 
     
     
     SELECT A.COMPANYCODE, A.DIVISIONCODE, 'STL' LEAVECODE, B.YEARCODE,  
     TO_DATE('07/12/2020','DD/MM/YYYY') ASONDATE, B.WORKERSERIAL, A.TOKENNO, 
     SUM(STLDAYS) ENTITLE_DAYS, SUM(PREV_STLDAYS) PREV_STLDAYS, SUM(STLDAYS_TAKEN) STLTAKEN_DAYS,  
     (SUM(STLDAYS) + SUM(PREV_STLDAYS) - SUM(STLDAYS_TAKEN)) STLBAL_DAYS 
     FROM WPSWORKERMAST A, 
     (   
         SELECT WORKERSERIAL,FROMYEAR YEARCODE, STLDAYS,PREV_STLDAYS, 0 STLDAYS_TAKEN 
         FROM WPSSTLTRANSACTION  
         WHERE COMPANYCODE = 'NJ0001' AND DIVISIONCODE = '0002'  
         AND FROMYEAR BETWEEN '2017' AND '2019'
         AND TOKENNO = '50183' 
         UNION ALL 
         SELECT A.WORKERSERIAL,/*'2020'*/B.YEAR YEARCODE, 0  STLDAYS,0 PREV_STLDAYS, SUM(LEAVEDAYS) STLDAYS_TAKEN 
         FROM WPSSTLENTRYDETAILS A, ( select workerserial,DOCUMENTNO,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, year from  wpsstlentry ) B 
         WHERE COMPANYCODE = 'NJ0001' AND DIVISIONCODE = '0002'  
         AND PAYMENTDATE<=TO_DATE('07/12/2020','DD/MM/YYYY')
         AND B.YEAR BETWEEN '2017' AND '2019'
         and a.workerserial=b.workerserial and a.documentno=b.documentno
         AND LEAVECODE='STL' AND LEAVEDAYS>0
         AND TOKENNO = '50183' 
         GROUP BY A.WORKERSERIAL,B.YEAR    
     ) B 
     WHERE A.COMPANYCODE = 'NJ0001' AND A.DIVISIONCODE = '0002'  
      AND A.WORKERSERIAL = B.WORKERSERIAL 
      GROUP BY A.COMPANYCODE, A.DIVISIONCODE, B.YEARCODE, B.WORKERSERIAL, A.TOKENNO