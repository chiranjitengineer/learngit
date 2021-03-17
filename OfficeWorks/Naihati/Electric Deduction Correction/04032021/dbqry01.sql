 INSERT INTO GBL_ELECBLNC 
 
  SELECT A.WORKERSERIAL, A.TOKENNO, A.QUARTERNO, READINGDATE, BILLAMOUNT, PREVIOUSDUEAMOUNT, 
  NVL(CONTRIBUTIONAMOUNT,0)+NVL(PREVIOUSDUEAMOUNT,0) TOTALCONTRIBUTION,  
  C.ELEC_BAL_AMT, EMIAMOUNT 
  FROM ELECTRICMETERREADING A, 
  ( 
      SELECT WORKERSERIAL, MAX(FORTNIGHTSTARTDATE) FORTNIGHTSTARTDATE  
      FROM ELECTRICMETERREADING  
      WHERE COMPANYCODE = 'NJ0001'  
        AND FORTNIGHTSTARTDATE <= TO_DATE('15/02/2021','DD/MM/YYYY')  
      GROUP BY WORKERSERIAL  
  ) B,  
  (  
      SELECT WORKERSERIAL, SUM(ELEC_BAL_AMT) ELEC_BAL_AMT  
      FROM (  
              SELECT WORKERSERIAL, SUM(NVL(CONTRIBUTIONAMOUNT,0)) ELEC_BAL_AMT  
              FROM ELECTRICMETERREADING   
               WHERE COMPANYCODE= 'NJ0001'    
                 AND DIVISIONCODE='0002'     
                 AND FORTNIGHTSTARTDATE <= TO_DATE('15/02/2021','DD/MM/YYYY')  
              GROUP BY WORKERSERIAL   
              UNION ALL  
              SELECT WORKERSERIAL,-1* SUM(NVL(DEDUCTEDAMT,0)) ELEC_BAL_AMT  
              FROM ELECTRICDEDUCTIONBREAKUP    
               WHERE COMPANYCODE='NJ0001'     
                 AND DIVISIONCODE= '0002'  
                 AND DEDUCTIONDATE <= TO_DATE('15/02/2021','DD/MM/YYYY')  
              GROUP BY WORKERSERIAL        
         )   
       GROUP BY WORKERSERIAL   
  ) C  
  WHERE A.COMPANYCODE ='NJ0001' AND A.DIVISIONCODE = '0002'   
    AND A.WORKERSERIAL=B.WORKERSERIAL   
    AND A.FORTNIGHTSTARTDATE =B.FORTNIGHTSTARTDATE   
    AND A.WORKERSERIAL = C.WORKERSERIAL(+)   

 insert into GTT_ELECTRIC_OUTTEMP 
    (BILLAMOUNT, ELECTRICITY, BWORSRL, COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, QUARTERNO, TOTALBILLDAYS, 
    FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, CONTRIBUTIONAMOUNT, EMIAMOUNT,READINGFROMDATE, READINGTODATE)              

SELECT A.BILLAMOUNT,B.ELECTRICITY, B.WORKERSERIAL bworsrl,   a.COMPANYCODE, a.DIVISIONCODE, a.WORKERSERIAL, a.TOKENNO, 
QUARTERNO,  TOTALBILLDAYS, a.FORTNIGHTSTARTDATE, a.FORTNIGHTENDDATE, CONTRIBUTIONAMOUNT, EMIAMOUNT,READINGFROMDATE, READINGTODATE  
FROM ELECTRICMETERREADING A,WPSWAGESDETAILS_MV B
WHERE 1=1
AND b.COMPANYCODE='NJ0001' 
AND b.DIVISIONCODE='0002' 
AND nvl(B.FORTNIGHTENDDATE,A.FORTNIGHTENDDATE)=TO_DATE('15/02/2021','DD/MM/YYYY')  
AND A.COMPANYCODE(+)=B.COMPANYCODE
AND A.DIVISIONCODE(+)=B.DIVISIONCODE
AND A.WORKERSERIAL(+)=B.WORKERSERIAL
AND A.FORTNIGHTSTARTDATE(+)=B.FORTNIGHTSTARTDATE
AND A.FORTNIGHTENDDATE(+)= B.FORTNIGHTENDDATE 
              
INSERT INTO GTT_ELECTRICBILL_OUTSTANDING
            (QRTLINENO, QUARTERNO, TOKENNO, WORKERNAME, BALANCE_OS, PERIODFROM, PERIODTO, BILLAMOUNT, TOTALAMT, INSTALLMENTAMT, 
            STATUS, SUPERANNUATIONDATE, GRATIOTYPAIDDATE, COMPANYNAME,ELECTRICITY)
                

SELECT SUBSTR(NVL(A.QUARTERNO,C.QUARTER),1,2) QRTLINENO, SUBSTR(NVL(A.QUARTERNO,C.QUARTER),4,4)QUARTERNO, B.TOKENNO, WORKERNAME, 
nvl(fn_PreviousAmount(b.companycode,b.divisioncode,b.workerserial,'01/02/2021','15/02/2021'),0) BALANCE_OS ,
to_char(READINGFROMDATE,'MON')  PERIODFROM,to_char(READINGTODATE,'MON')  PERIODTO, A.BILLAMOUNT,           
nvl(fn_PreviousAmount(b.companycode,b.divisioncode,b.workerserial,'01/02/2021','15/02/2021'),0)+NVL(A.BILLAMOUNT,0)-NVL(A.ELECTRICITY,0) TOTALAMT,
CASE WHEN A.BILLAMOUNT>0 THEN A.EMIAMOUNT ELSE C.ELEC_EMI_AMT END INSTALLMENTAMT, 
fnWorkerStatus(b.workerserial, nvl(c.quarter,0)) STATUS,
CASE WHEN DATEOFTERMINATION<=TO_DATE('15/02/2021','DD/MM/YYYY') THEN to_char(DATEOFTERMINATION,'dd/mm/yyyy') ELSE NULL END SUPERANNUATIONDATE,                       
to_char(GRATUITYPAYMENTDATE,'dd/mm/yyyy') GRATIOTYPAIDDATE,  
'THE NAIHATI JUTE MILLS  COMPANY LTD.' COMPANYNAME, A.ELECTRICITY
FROM GBL_ELECBLNC C, WPSWORKERMAST B, GTT_ELECTRIC_OUTTEMP A
WHERE 1=1
AND C.WORKERSERIAL=B.WORKERSERIAL
AND C.WORKERSERIAL=A.bworsrl(+)


SELECT * FROM ELECTRICMETERREADING
WHERE TOKENNO='04305'



SELECT * FROM ELECTRICDEDUCTIONBREAKUP
WHERE TOKENNO='00040'


SELECT * FROM GBL_ELECBLNC
WHERE TOKENNO='04305'


--------------------------------------------------------------------------------


SELECT A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, A.TOKENNO, 
QUARTERNO,  A.FORTNIGHTSTARTDATE, A.FORTNIGHTENDDATE,A.READINGFROMDATE, A.READINGTODATE ,
A.TOTALBILLDAYS, A.BILLAMOUNT, CONTRIBUTIONAMOUNT, A.EMIAMOUNT
FROM ELECTRICMETERREADING A 
WHERE 1=1
AND A.COMPANYCODE='NJ0001' 
AND A.DIVISIONCODE='0002' 
AND A.FORTNIGHTENDDATE=
(
    SELECT MAX(FORTNIGHTENDDATE) FROM ELECTRICMETERREADING
    WHERE COMPANYCODE='NJ0001' 
    AND DIVISIONCODE='0002' 
    AND FORTNIGHTENDDATE <= TO_DATE('15/02/2021','DD/MM/YYYY')
    AND A.WORKERSERIAL=WORKERSERIAL
) 
AND TOKENNO='00060'

SELECT * FROM GBL_ELECBLNC
      

SELECT SUBSTR(NVL(A.QUARTERNO,C.QUARTER),1,2) QRTLINENO, SUBSTR(NVL(A.QUARTERNO,C.QUARTER),4,4)QUARTERNO, B.TOKENNO, WORKERNAME, 
nvl(fn_PreviousAmount(b.companycode,b.divisioncode,b.workerserial,'01/02/2021','15/02/2021'),0) BALANCE_OS ,
to_char(READINGFROMDATE,'MON')  PERIODFROM,to_char(READINGTODATE,'MON')  PERIODTO, A.BILLAMOUNT,           
nvl(fn_PreviousAmount(b.companycode,b.divisioncode,b.workerserial,'01/02/2021','15/02/2021'),0)+NVL(A.BILLAMOUNT,0)-NVL(D.DEDUCTEDAMT,0) TOTALAMT,
CASE WHEN A.BILLAMOUNT>0 THEN A.EMIAMOUNT ELSE C.ELEC_EMI_AMT END INSTALLMENTAMT, 
fnWorkerStatus(b.workerserial, nvl(c.quarter,0)) STATUS,
CASE WHEN DATEOFTERMINATION<=TO_DATE('15/02/2021','DD/MM/YYYY') THEN to_char(DATEOFTERMINATION,'dd/mm/yyyy') ELSE NULL END SUPERANNUATIONDATE,                       
to_char(GRATUITYPAYMENTDATE,'dd/mm/yyyy') GRATIOTYPAIDDATE,  
'THE NAIHATI JUTE MILLS  COMPANY LTD.' COMPANYNAME, NVL(D.DEDUCTEDAMT,0) DEDUCTEDAMT
FROM GBL_ELECBLNC C, WPSWORKERMAST B, 
(
    SELECT A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, A.TOKENNO, 
    QUARTERNO,  A.FORTNIGHTSTARTDATE, A.FORTNIGHTENDDATE,A.READINGFROMDATE, A.READINGTODATE ,
    A.TOTALBILLDAYS, A.BILLAMOUNT, CONTRIBUTIONAMOUNT, A.EMIAMOUNT 
    FROM ELECTRICMETERREADING A 
    WHERE 1=1
    AND A.COMPANYCODE='NJ0001' 
    AND A.DIVISIONCODE='0002' 
    AND A.FORTNIGHTENDDATE=TO_DATE('15/02/2021','DD/MM/YYYY')
--    (
--        SELECT MAX(FORTNIGHTENDDATE) FROM ELECTRICMETERREADING
--        WHERE COMPANYCODE='NJ0001' 
--        AND DIVISIONCODE='0002' 
--        AND FORTNIGHTENDDATE <= TO_DATE('15/02/2021','DD/MM/YYYY')
--        AND A.WORKERSERIAL=WORKERSERIAL
--    ) 
    --AND TOKENNO='04305'
) A,
(
    SELECT WORKERSERIAL, DEDUCTEDAMT FROM ELECTRICDEDUCTIONBREAKUP
    WHERE DEDUCTIONDATE = TO_DATE('15/02/2021','DD/MM/YYYY')
) D
WHERE 1=1
AND C.WORKERSERIAL=B.WORKERSERIAL
AND C.WORKERSERIAL=A.WORKERSERIAL(+)
AND C.WORKERSERIAL=D.WORKERSERIAL(+)

SELECT fn_PreviousAmount('NJ0001','0002','000043','01/02/2021','15/02/2021') XX FROM DUAL


SELECT * FROM ELECTRICDEDUCTIONBREAKUP
WHERE DEDUCTIONDATE = TO_DATE('15/02/2021','DD/MM/YYYY')