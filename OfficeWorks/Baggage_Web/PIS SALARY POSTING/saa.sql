EXEC prc_pissalary_postingdata('0001','001','SALARY PROCESS','202010','001','','','') 


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