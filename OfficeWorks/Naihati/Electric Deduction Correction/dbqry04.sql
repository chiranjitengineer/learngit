select * from pisleavetransaction

SELECT * FROM 



select READINGDATE,WORKERSERIAL,TOKENNO,ELEC_DED_AMT,PREV_DUE_AMT,
ELEC_EMI,BILLAMOUNT,CONTRIBUTIONAMOUNT,EMIAMOUNT 
from ELECTRICMETERREADING
where tokenno='01522'


SELECT DEDUCTIONDATE,WORKERSERIAL,DEDUCTEDAMT ELEC_BAL_AMT  
FROM ELECTRICDEDUCTIONBREAKUP    
WHERE COMPANYCODE='NJ0001'     
AND DIVISIONCODE= '0002'  
--AND DEDUCTIONDATE <= TO_DATE('15/01/2021','DD/MM/YYYY')  
AND tokenno='01522'




select FORTNIGHTENDDATE,READINGDATE,WORKERSERIAL,TOKENNO,ELEC_DED_AMT,PREV_DUE_AMT,
ELEC_EMI,BILLAMOUNT,CONTRIBUTIONAMOUNT,EMIAMOUNT 
from ELECTRICMETERREADING
where tokenno='61312'


SELECT DEDUCTIONDATE,WORKERSERIAL,DEDUCTEDAMT ELEC_BAL_AMT  
FROM ELECTRICDEDUCTIONBREAKUP    
WHERE COMPANYCODE='NJ0001'     
AND DIVISIONCODE= '0002'  
--AND DEDUCTIONDATE <= TO_DATE('15/01/2021','DD/MM/YYYY')  
AND tokenno='61312'


SELECT TOKENNO,FORTNIGHTSTARTDATE,FORTNIGHTENDDATE, ELECTRICITY FROM WPSWAGESDETAILS_MV
WHERE TOKENNO='61312'
AND ELECTRICITY > 0



SELECT DEDUCTIONDATE,WORKERSERIAL,DEDUCTEDAMT ELEC_BAL_AMT  
FROM ELECTRICDEDUCTIONBREAKUP    
WHERE COMPANYCODE='NJ0001'     
AND DIVISIONCODE= '0002'  
--AND DEDUCTIONDATE <= TO_DATE('15/01/2021','DD/MM/YYYY')  
AND tokenno='83545'


SELECT TOKENNO,FORTNIGHTSTARTDATE,FORTNIGHTENDDATE, ELECTRICITY FROM WPSWAGESDETAILS_MV
WHERE TOKENNO='83545'
AND ELECTRICITY > 0



select READINGDATE,WORKERSERIAL,TOKENNO,ELEC_DED_AMT,PREV_DUE_AMT,
ELEC_EMI,BILLAMOUNT,CONTRIBUTIONAMOUNT,EMIAMOUNT 
from ELECTRICMETERREADING
where tokenno='83545'


select *
from ELECTRICMETERREADING
where tokenno='61307'