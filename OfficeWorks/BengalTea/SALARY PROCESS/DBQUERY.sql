SELECT  * FROM PISPAYTRANSACTION

SELECT * FROM PIS_ERROR_LOG

SELECT * FROM WPS_ERROR_LOG



DELETE FROM PIS_ERROR_LOG


DELETE FROM WPS_ERROR_LOG

SELECT * FROM WPS_ERROR_LOG

SELECT * FROM PIS_ERROR_LOG

SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%PROCESS%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE='0107020601'

SELECT * FROM ROLEDETAILS
WHERE MENUCODE=''

SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG=''

prcSalary_Bf_MainSave

SELECT * FROM PISCOMPONENTASSIGNMENT

SELECT * FROM PISGRADECOMPONENTMAPPING
WHERE YEARMONTH='202101'
AND COMPONENTCODE LIKE 'PF_E%'


SELECT * FROM PISMONTHATTENDANCE


DELETE FROM PIS_ERROR_LOG

DELETE FROM WPS_ERROR_LOG


EXEC PRC_PIS_SALARY_PROCESS( 'BT0104', 'HO', 'SALARY', 'SWT','202101', '202101','HO','SST','SST','','' );
                       

SELECT * FROM WPS_ERROR_LOG WHERE PROC_NAME ='PRC_PISSALARY_OTHCOMP_UPDATE'

SELECT * FROM PIS_ERROR_LOG

SELECT  * FROM PISPAYTRANSACTION
       
                              
select COMPANYCODE, DIVISIONCODE, PROCESSTYPE, PROCEDURE_NAME, PHASE, CALCULATIONINDEX, PARAM_1, PARAM_2, PARAM_3 
from WAGESPROCESSTYPE_PHASE  
where 1=1 
--AND COMPANYCODE = P_COMPCODE 
--and DIVISIONCODE = P_DIVCODE
and PROCESSTYPE = 'SALARY'
ORDER BY PHASE, CALCULATIONINDEX


UPDATE WAGESPROCESSTYPE_PHASE
SET DIVISIONCODE = 'HO'
WHERE PROCESSTYPE='SALARY'
AND TYPE ='PROCEDURE'



SELECT * FROM PISCOMPONENTMASTER
WHERE COMPONENTCODE LIKE 'PF%'

PRC_PISSALARYPROCESS_DEDN

SELECT * FROM USER_SOURCE
WHERE TEXT LIKE '%PF_E%'
AND TYPE='PROCEDURE'

PRC_PISSALARY_OTHCOMP_UPDATE



 CREATE TABLE PIS_OTH_COMP58610123 AS 
 
 SELECT COMPANYCODE, DIVISIONCODE, UNITCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL, YEARMONTH, PFAPPLICABLE, EPFAPPLICABLE, PF_GROSS, PEN_GROSS, PF_E, FPF, PF_E- FPF PF_C, ESI_GROSS, ESI_E, ESI_C 
 FROM (  
         SELECT A.COMPANYCODE, A.DIVISIONCODE, A.UNITCODE, A.CATEGORYCODE, A.GRADECODE,A.WORKERSERIAL,YEARMONTH, NVL(A.PFAPPLICABLE,'N') PFAPPLICABLE, NVL(A.EPFAPPLICABLE,'N') EPFAPPLICABLE, NVL(B.PF_GROSS,0) PF_GROSS,  
         CASE WHEN  NVL(A.EPFAPPLICABLE,'N') = 'Y' AND  NVL(A.EPFAPPLICABLE,'N') ='Y' THEN   
                        CASE WHEN B.PF_GROSS > 15000 THEN 15000 ELSE PF_GROSS END ELSE 0 END PEN_GROSS,  
         NVL(B.PF_E,0) PF_E,  
         CASE WHEN  NVL(A.EPFAPPLICABLE,'N') = 'Y' AND  NVL(A.EPFAPPLICABLE,'N') = 'Y' THEN  
                        ROUND(CASE WHEN NVL(B.PF_GROSS,0) > 15000 THEN 15000 ELSE NVL(PF_GROSS,0) END * 8.33/100,0) ELSE 0 END FPF,  
                         B.PF_C, NVL(B.ESI_GROSS,0) ESI_GROSS, NVL(B.ESI_E,0) ESI_E, CASE WHEN NVL(ESI_E,0) > 0 THEN CEIL(NVL(ESI_GROSS,0)*3.25/100) ELSE 0 END ESI_C   
         FROM PISEMPLOYEEMASTER A, PISPAYTRANSACTION_SWT B   
         WHERE A.COMPANYCODE = 'BT0104' AND A.DIVISIONCODE = 'HO' 
           AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE  
           AND A.WORKERSERIAL = B.WORKERSERIAL   
           AND B.YEARMONTH = '202101' 
           AND B.UNITCODE = 'HO' 
           AND B.CATEGORYCODE = 'SST' 
           AND B.GRADECODE = 'SST' 
      )  

----------------------------------------------------------------


                
                SELECT A.WORKERSERIAL, A.TOKENNO, A.UNITCODE, A.CATEGORYCODE, A.GRADECODE, A.GROSSEARN,A.TOTEARN,A.COMPONENTCODE, A.COMPONENTAMOUNT,
                NVL(B.COMPONENTGROUP,'OTHERS') COMPONENTGROUP, NVL(DEPENDENCYTYPE,'A') DEPENDENCYTYPE, NVL(ROUNDOFFTYPE,'N') ROUNDOFFTYPE, NVL(ROUNDOFFRS,1) ROUNDOFFRS,
                INCLUDEPAYROLL, nvl(ROLLOVERAPPLICABLE,'N') ROLLOVERAPPLICABLE, NVL(USERENTRYAPPLICABLE,'N') USERENTRYAPPLICABLE, 
                NVL(ATTENDANCEENTRYAPPLICABLE,'N') ATTENDANCEENTRYAPPLICABLE, NVL(INCLUDEARREAR,'N') INCLUDEARREAR,
                NVL(LIMITAPPLICABLE,'N') LIMITAPPLICABLE, NVL(SLABAPPLICABLE,'N') SLABAPPLICABLE,
                NVL(MISCPAYMENT,'N') MISCPAYMENT, NVL(FINALSETTLEMENT,'N') FINALSETTLEMENT    
                FROM PIS_GTT_SWT_PHASE_DEDN A,
                ( 
                  SELECT * FROM PISCOMPONENTMASTER B
                  WHERE COMPANYCODE = 'BT0104' AND DIVISIONCODE = 'HO'
                    AND PHASE = 6
                    AND NVL(INCLUDEPAYROLL,'N') = 'Y'
                    AND YEARMONTH = ( 
                                      SELECT MAX(YEARMONTH) YEARMONTH FROM PISCOMPONENTMASTER
                                      WHERE COMPANYCODE = 'BT0104' AND DIVISIONCODE = 'HO'
                                        AND YEARMONTH <= '202101'
                                    )
                ) B,
                ( 
                  SELECT X.UNITCODE, X.CATEGORYCODE, X.GRADECODE, X.COMPONENTCODE, NVL(X.APPLICABLE,'NO') APPLICABLE
                  FROM PISGRADECOMPONENTMAPPING X, 
                  (
                    SELECT UNITCODE, CATEGORYCODE, GRADECODE, MAX(YEARMONTH) YEARMONTH 
                    FROM PISGRADECOMPONENTMAPPING 
                    WHERE COMPANYCODE = 'BT0104' AND DIVISIONCODE = 'HO'
                      AND UNITCODE = 'HO' 
                      AND YEARMONTH <=  '202101'
                    GROUP BY UNITCODE, CATEGORYCODE, GRADECODE  
                  ) Y
                  WHERE X.COMPANYCODE = 'BT0104' AND X.DIVISIONCODE = 'HO'   
                    AND X.UNITCODE = X.UNITCODE AND X.CATEGORYCODE = Y.CATEGORYCODE AND X.GRADECODE = Y.GRADECODE
                    AND X.YEARMONTH = Y.YEARMONTH
                    AND X.APPLICABLE = 'Y'                     
                ) C                                     
                WHERE A.COMPONENTCODE = B.COMPONENTCODE
                  AND A.UNITCODE = C.UNITCODE AND A.CATEGORYCODE = C.CATEGORYCODE AND A.GRADECODE = C.GRADECODE  
                  AND A.COMPONENTCODE = C.COMPONENTCODE
                ORDER BY A.WORKERSERIAL,B.CALCULATIONINDEX
                
-------------------------                      

SELECT X.UNITCODE, X.CATEGORYCODE, X.GRADECODE, X.COMPONENTCODE, NVL(X.APPLICABLE,'NO') APPLICABLE
FROM PISGRADECOMPONENTMAPPING X, 
(
SELECT UNITCODE, CATEGORYCODE, GRADECODE, MAX(YEARMONTH) YEARMONTH 
FROM PISGRADECOMPONENTMAPPING 
WHERE COMPANYCODE = 'BT0104' AND DIVISIONCODE = 'HO'
AND UNITCODE = 'HO' 
AND YEARMONTH <=  '202101'
--AND X.UNITCODE = UNITCODE AND X.CATEGORYCODE = CATEGORYCODE AND X.GRADECODE = GRADECODE
GROUP BY UNITCODE, CATEGORYCODE, GRADECODE  
) Y
WHERE X.COMPANYCODE = 'BT0104' AND X.DIVISIONCODE = 'HO'   
AND X.UNITCODE = X.UNITCODE AND X.CATEGORYCODE = Y.CATEGORYCODE AND X.GRADECODE = Y.GRADECODE
AND X.YEARMONTH = Y.YEARMONTH
AND X.APPLICABLE = 'Y' 
AND COMPONENTCODE LIKE 'PF%'


SELECT X.UNITCODE, X.CATEGORYCODE, X.GRADECODE, X.COMPONENTCODE, APPLICABLE
FROM PISGRADECOMPONENTMAPPING X
WHERE 1=1
AND COMPONENTCODE LIKE 'PF%'


UPDATE PISGRADECOMPONENTMAPPING SET APPLICABLE = 'Y'
WHERE 1=1
AND COMPONENTCODE LIKE 'PF%'