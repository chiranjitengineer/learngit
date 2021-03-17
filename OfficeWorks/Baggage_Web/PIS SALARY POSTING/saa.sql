EXEC prc_pissalary_postingdata('0001','001','ARREAR PROCESS','202011','002','','','') 

SELECT * FROM PISSALARY_POSTINGDATA

 SELECT A.ACCODE LEDGER_CODE, A.ACHEAD, 
        A.ACCOSTCENTRECODE COST_CENTRE_CODE, B.COSTCENTREDESC,
        SUM(CASE WHEN A.DRCR = 'DR' THEN AMOUNT ELSE 0 END) AMOUNT_DEBIT, 
        SUM(CASE WHEN A.DRCR = 'CR' THEN AMOUNT ELSE 0 END) AMOUNT_CREDIT
   FROM PISSALARY_POSTINGDATA A, ACCOSTCENTREMAST B
  WHERE A.COMPANYCODE = '0001'
    AND A.DIVISIONCODE = '001'
    AND A.PERIODFROM >= TO_DATE('202011', 'YYYYMM')
    AND A.PERIODTO <= LAST_DAY(TO_DATE('202011', 'YYYYMM'))
    AND A.COMPANYCODE = B.COMPANYCODE (+)
    AND A.ACCOSTCENTRECODE = B.COSTCENTRECODE (+)
    AND NVL(AMOUNT,0) <> 0
    GROUP BY A.ACCODE, A.ACHEAD,A.ACCOSTCENTRECODE,B.COSTCENTREDESC
  ORDER BY A.ACCODE
  
  
 EXEC  prc_pissalary_postingdata('0001','001','SALARY PROCESS','202010','001','','','') 
 
 
 SELECT A.ACCODE LEDGER_CODE, A.ACHEAD, 
        A.ACCOSTCENTRECODE COST_CENTRE_CODE, B.COSTCENTREDESC,
        SUM(CASE WHEN A.DRCR = 'DR' THEN AMOUNT ELSE 0 END) AMOUNT_DEBIT, 
        SUM(CASE WHEN A.DRCR = 'CR' THEN AMOUNT ELSE 0 END) AMOUNT_CREDIT
   FROM PISSALARY_POSTINGDATA A, ACCOSTCENTREMAST B
  WHERE A.COMPANYCODE = '0001'
    AND A.DIVISIONCODE = '001'
    AND A.PERIODFROM >= TO_DATE('202010', 'YYYYMM')
    AND A.PERIODTO <= LAST_DAY(TO_DATE('202010', 'YYYYMM'))
    AND A.COMPANYCODE = B.COMPANYCODE (+)
    AND A.ACCOSTCENTRECODE = B.COSTCENTRECODE (+)
    AND NVL(AMOUNT,0) <> 0
    GROUP BY A.ACCODE, A.ACHEAD,A.ACCOSTCENTRECODE,B.COSTCENTREDESC
  ORDER BY A.ACCODE
  
  -----------------------------------------------------------------------------
  
  
1. CREATE OR REPLACE VIEW VW_PISCOMPONENTLEDGERMAPPING 
 AS 
 
 SELECT COMPANYCODE, DIVISIONCODE, QUALITY_GROUP_CODE as COMPONENTCODE,  ACCODE ACCCODE 
 FROM SYS_PARAM_ACPOST_PAYROLL 
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
 AND  POSTING_PARAM_NAME = 'PIS SALARY POSTING TO ACCOUNTS' 
 AND  MODULENAME = 'PIS' 
 AND ACCODE IS NOT NULL 
 AND QUALITY_GROUP_CODE IN ( 
 SELECT DISTINCT COMPONENTCODE FROM PISCOMPONENTMASTER 
 WHERE COMPANYCODE='0001'  AND DIVISIONCODE = '001' 
 AND  (INCLUDEARREAR='Y' OR COMPONENTCODE='NETSALARY')
 ) 
UNION ALL
 SELECT DISTINCT COMPANYCODE, DIVISIONCODE, COMPONENTCODE, EXPENSECODE 
 FROM PISCOMPONENTMASTER 
 WHERE COMPANYCODE = '0001' 
 AND DIVISIONCODE = '001' 
 AND EXPENSECODE IS NOT NULL 


SELECT * FROM PISARREARTRANSACTION  PISCOMP
WHERE TOKENNO='00184'
--AND YEARMONTH='202011'
AND TRANSACTIONTYPE='MONTHLYARR'


SELECT *
FROM  
PISARREARTRANSACTION  PISCOMP
WHERE TOKENNO='00184'

AND YEARMONTH='202011'

SELECT PISCOMP.BASIC,PISCOMP.CHILD_ALLW,PISCOMP.HRA,PISCOMP.SOFT_ALLW,PISCOMP.SERV_ALLW,PISCOMP.CONV_ALLW,
PISCOMP.PERS_ALLW,PISCOMP.OTH_ALLW,PISCOMP.INCENTIVE,PISCOMP.FSTL_EARN,PISCOMP.FIX_ALW,PISCOMP.OTH_ALLW2
FROM PISARREARTRANSACTION  PISCOMP
WHERE TOKENNO='00184'
--AND YEARMONTH='202011'
AND TRANSACTIONTYPE='NEW SALARY'

SELECT * FROM PISCOMPONENTMASTER
WHERE COMPONENTCODE='PTAX_GROSS'

SELECT * FROM PISCOMPONENTMASTER
WHERE COMPONENTCODE='GROSSEARN'


PISCOMP.BASIC+PISCOMP.HRA+PISCOMP.CONV_ALW+PISCOMP.ATN_ALW+PISCOMP.PUNC_ALW+PISCOMP.ATN_INCTV+PISCOMP.WASH_ALW+PISCOMP.EDU_ALW+PISCOMP.SHIFT_ALW+PISCOMP.CLEAN_ALW+PISCOMP.LGBK_ALW+PISCOMP.INSP_ALW+PISCOMP.CHRG_HAND+PISCOMP.PERF_ALW



INSERT INTO PISSALARY_POSTINGDATA 
( 
  COMPANYCODE, DIVISIONCODE, PERIODFROM, PERIODTO, ACCODE, ACHEAD, DRCR, AMOUNT, ACCOSTCENTRECODE, CATEGORYCODE, UNITCODE, GRADECODE 
) 

SELECT D.COMPANYCODE,D.DIVISIONCODE, D.COMPONENTCODE,
       TO_DATE('01/11/2020','DD/MM/YYYY') PERIODFROM,TO_DATE('30/11/2020','DD/MM/YYYY') PERIODTO, 
       C.ACCCODE, B.ACHEAD, 
       CASE                                                
            WHEN D.COMPONENTCODE = 'NETSALARY' THEN 'CR' 
            WHEN C.ACCCODE IN (SELECT DISTINCT EXPENSECODE FROM PISCOMPONENTMASTER ) THEN 'CR' 
            WHEN C.ACCCODE IN (SELECT DISTINCT ACCCODE FROM PISCOMPONENTMASTER WHERE COMPONENTCODE IN ('PF_C','FPF')) THEN 'CR' 
            WHEN D.COMPONENTTYPE = 'EARNING' THEN 'DR' 
            WHEN D.COMPONENTTYPE = 'DEDUCTION' THEN 'CR' 
            ELSE 'DR' 
        END AS DRCR, 
       FN_PISSALARY_COMP_AMT(C.COMPANYCODE,C.DIVISIONCODE,'ARREAR PROCESS',C.COMPONENTCODE, '202011' , '' , '002' , '')  AMOUNT, 
       NULL ACCOSTCENTRECODE, '' CATEGORYCODE, '002' UNITCODE, '' GRADECODE 
  FROM PISCOMPONENTMASTER D, 
        ( 
          SELECT DISTINCT COMPANYCODE, DIVISIONCODE, COMPONENTCODE, ACCCODE 
            FROM VW_PISCOMPONENTLEDGERMAPPING 
           WHERE COMPANYCODE = '0001' 
             AND DIVISIONCODE = '001' 
        ) C ,ACACLEDGER B 
 WHERE C.COMPANYCODE = '0001' 
   AND C.DIVISIONCODE = '001' 
   AND C.COMPANYCODE = D.COMPANYCODE 
   AND C.DIVISIONCODE = D.DIVISIONCODE 
   AND C.COMPONENTCODE=D.COMPONENTCODE 
   AND B.COMPANYCODE = C.COMPANYCODE 
   AND B.ACCODE = C.ACCCODE 
   
SELECT SUM(NVL(FPF,0)) 
 FROM PISARREARTRANSACTION A
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
   AND YEARMONTH = '202011' 
   AND UNITCODE = '002'

SELECT SUM(NVL(FPF,0)) 
 FROM PISARREARTRANSACTION A
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
   AND YEARMONTH = '202011' 
   AND UNITCODE = '002'

SELECT SUM(NVL(HRA,0)) 
 FROM PISARREARTRANSACTION A
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
   AND YEARMONTH = '202011' 
   AND UNITCODE = '002'

SELECT SUM(NVL(LTA,0)) 
 FROM PISARREARTRANSACTION A
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
   AND YEARMONTH = '202011' 
   AND UNITCODE = '002'

SELECT SUM(NVL(PF_C,0)) 
 FROM PISARREARTRANSACTION A
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
   AND YEARMONTH = '202011' 
   AND UNITCODE = '002'

SELECT SUM(NVL(PF_C,0)) 
 FROM PISARREARTRANSACTION A
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
   AND YEARMONTH = '202011' 
   AND UNITCODE = '002'

SELECT SUM(NVL(PF_E,0)) 
 FROM PISARREARTRANSACTION A
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
   AND YEARMONTH = '202011' 
   AND UNITCODE = '002'

SELECT SUM(NVL(PTAX,0)) 
 FROM PISARREARTRANSACTION A
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
   AND YEARMONTH = '202011' 
   AND UNITCODE = '002'

SELECT SUM(NVL(BASIC,0)) 
 FROM PISARREARTRANSACTION A
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
   AND YEARMONTH = '202011' 
   AND UNITCODE = '002'

SELECT SUM(NVL(ESI_C,0)) 
 FROM PISARREARTRANSACTION A
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
   AND YEARMONTH = '202011' 
   AND UNITCODE = '002'

SELECT SUM(NVL(ESI_E,0)) 
 FROM PISARREARTRANSACTION A
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
   AND YEARMONTH = '202011' 
   AND UNITCODE = '002'

SELECT SUM(NVL(CANTEEN,0)) 
 FROM PISARREARTRANSACTION A
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
   AND YEARMONTH = '202011' 
   AND UNITCODE = '002'

SELECT SUM(NVL(FIX_ALW,0)) 
 FROM PISARREARTRANSACTION A
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
   AND YEARMONTH = '202011' 
   AND UNITCODE = '002'

SELECT SUM(NVL(MEDICAL,0)) 
 FROM PISARREARTRANSACTION A
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
   AND YEARMONTH = '202011' 
   AND UNITCODE = '002'

SELECT SUM(NVL(OTH_ALLW,0)) 
 FROM PISARREARTRANSACTION A
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
   AND YEARMONTH = '202011' 
   AND UNITCODE = '002'

SELECT SUM(NVL(CONV_ALLW,0)) 
 FROM PISARREARTRANSACTION A
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
   AND YEARMONTH = '202011' 
   AND UNITCODE = '002'

SELECT SUM(NVL(INCENTIVE,0)) 
 FROM PISARREARTRANSACTION A
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
   AND YEARMONTH = '202011' 
   AND UNITCODE = '002'

SELECT SUM(NVL(NETSALARY,0)) 
 FROM PISARREARTRANSACTION A
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
   AND YEARMONTH = '202011' 
   AND UNITCODE = '002'

SELECT SUM(NVL(OTH_ALLW2,0)) 
 FROM PISARREARTRANSACTION A
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
   AND YEARMONTH = '202011' 
   AND UNITCODE = '002'

SELECT SUM(NVL(PERS_ALLW,0)) 
 FROM PISARREARTRANSACTION A
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
   AND YEARMONTH = '202011' 
   AND UNITCODE = '002'

SELECT SUM(NVL(SERV_ALLW,0)) 
 FROM PISARREARTRANSACTION A
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
   AND YEARMONTH = '202011' 
   AND UNITCODE = '002'

SELECT SUM(NVL(SOFT_ALLW,0)) 
 FROM PISARREARTRANSACTION A
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
   AND YEARMONTH = '202011' 
   AND UNITCODE = '002'

SELECT SUM(NVL(TELEPHONE,0)) 
 FROM PISARREARTRANSACTION A
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
   AND YEARMONTH = '202011' 
   AND UNITCODE = '002'