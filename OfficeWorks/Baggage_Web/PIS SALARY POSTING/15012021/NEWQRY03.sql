1. CREATE OR REPLACE VIEW VW_PISCOMPONENTLEDGERMAPPING 
 AS 
 SELECT COMPANYCODE, DIVISIONCODE, QUALITY_GROUP_CODE as COMPONENTCODE,  ACCODE ACCCODE 
 FROM SYS_PARAM_ACPOST_PAYROLL 
 WHERE COMPANYCODE = '0001' AND DIVISIONCODE = '001' 
 AND  POSTING_PARAM_NAME = 'PIS SALARY POSTING TO ACCOUNTS' 
 AND  MODULENAME = 'PIS' 
 AND ACCODE IS NOT NULL 
UNION ALL
 SELECT DISTINCT COMPANYCODE, DIVISIONCODE, COMPONENTCODE, EXPENSECODE 
 FROM PISCOMPONENTMASTER 
 WHERE COMPANYCODE = '0001' 
 AND DIVISIONCODE = '001' 
 AND EXPENSECODE IS NOT NULL 


INSERT INTO PISSALARY_POSTINGDATA 
( 
  COMPANYCODE, DIVISIONCODE, PERIODFROM, PERIODTO, ACCODE, ACHEAD, DRCR, AMOUNT, ACCOSTCENTRECODE, CATEGORYCODE, UNITCODE, GRADECODE 
) 


SELECT D.COMPANYCODE,D.DIVISIONCODE, 
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
       FN_PISSALARY_COMP_AMT(C.COMPANYCODE,C.DIVISIONCODE,'SALARY PROCESS',C.COMPONENTCODE, '202011' , '' , '001' , '')  AMOUNT, 
       NULL ACCOSTCENTRECODE, '' CATEGORYCODE, '001' UNITCODE, '' GRADECODE 
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
 
 