 
BEGIN
PROC_GPSWAGESDETAILS_MERGE('HP0072','0001','WAGES PROCESS','2020-2021','02/11/2020','08/11/2020','08/11/2020','4','GPSDAILYPAYSHEETDETAILS','GPSPAYSHEETDETAILS_SWT','SWT','WORKER','P','''0007202''');
PROC_GPSWAGESPROCESS_UPDATE('HP0072','0001','WAGES PROCESS','2020-2021','02/11/2020','08/11/2020','08/11/2020','4','SWT_PHASE_4','GPSPAYSHEETDETAILS_SWT','SWT','WORKER','P','''0007202''');
PROC_GPSATTNALLOWANCE('HP0072','0001','WAGES PROCESS','2020-2021','02/11/2020','08/11/2020','08/11/2020','5','GPSPAYSHEETDETAILS_SWT','GPSPAYSHEETDETAILS_SWT','SWT','WORKER','P','''0007202''');
PROC_GPSWAGESPROCESS_UPDATE('HP0072','0001','WAGES PROCESS','2020-2021','02/11/2020','08/11/2020','08/11/2020','5','SWT_PHASE_5','GPSPAYSHEETDETAILS_SWT','SWT','WORKER','P','''0007202''');

END;


EXEC PROC_GPSWAGESPROCESS_DEDN('HP0072','0001','WAGES PROCESS','2020-2021','02/11/2020','08/11/2020','08/11/2020','6','SWT_PHASE_DEDN','GPSPAYSHEETDETAILS_SWT','SWT','WORKER','P','0007202')
 
PROC_GPSWAGES_OTHER_COMP_UPDT('HP0072','0001','WAGES PROCESS','2020-2021','02/11/2020','08/11/2020','08/11/2020','99','GPSPAYSHEETDETAILS_SWT','GPSPAYSHEETDETAILS','SWT','WORKER','P','0007202')

 
PROC_GPSWAGES_LVBAL_UPDT('HP0072','0001','WAGES PROCESS','2020-2021','02/11/2020','08/11/2020','08/11/2020','99','GPSPAYSHEETDETAILS_SWT','GPSPAYSHEETDETAILS_SWT','SWT','WORKER','P','0007202')
   
PROC_GPSWAGESPROCESS_TRANSFER('HP0072','0001','WAGES PROCESS','2020-2021','02/11/2020','08/11/2020','08/11/2020','100','GPSPAYSHEETDETAILS_SWT','GPSPAYSHEETDETAILS','SWT','WORKER','P','0007202')

 
PROC_GPSWAGESPROCESS_TRANSFER('HP0072','0001','WAGES PROCESS','2020-2021','02/11/2020','08/11/2020','08/11/2020','100','GPSPAYSHEETDETAILS_SWT','GPSPAYSHEETDETAILS','SWT','WORKER','P','0007202')
 

SELECT * FROM GPSCOMPONENTMAST


SELECT * FROM GPS_ERROR_LOG

SELECT * FROM WPS_ERROR_LOG

WHERE ERROR_QUERY LIKE '%SWT_PHASE_DEDN%'


DELETE FROM GPS_ERROR_LOG

DELETE FROM WPS_ERROR_LOG



--------------------------------------------------------------------------------
ROUND OFF 1 , S
PROCEDURE EXECURE ; 

begin  
PROC_GPS_PHASE_DEDN_ROWISE('HP0072','0001','02/11/2020','08/11/2020','SWT_PHASE_DEDN'); 
end;

SELECT * FROM GTT_SWT_PHASE_DEDN

SELECT * FROM SWT_PHASE_DEDN


 select column_name cn from cols where table_name = 'SWT_PHASE_DEDN'
        intersect
select COMPONENTCODE cn from GPSCOMPONENTMAST where COMPANYCODE = 'HP0072' and DIVISIONCODE = '0001' and COMPONENTCODE <> 'GROSSWAGES'

  CREATE TABLE SWT_PHASE_DEDN AS 
  
  SELECT * FROM GPSTEMPCOMP
  
  SELECT * FROM GPSTEMPMAST
  
  
 SELECT GPSTEMPCOMP.WORKERSERIAL,  GPSTEMPMAST.CATEGORYCODE, 
 SUM(NVL(GPSTEMPCOMP.GROSSWAGES,0)) AS GROSSWAGES 
 , SUM(0) AS DED_WELFARE, SUM(GPSTEMPCOMP.PF_E) AS TOT_PF_DED, SUM(NVL(GPSTEMPCOMP.PF_GROSS,0) *GPSTEMPMAST.PF_PERCENTAGE/100  ) AS PF_E, SUM(0) AS DED_UNION, SUM(0) AS LOAN_PF, SUM(0) AS LINT_PF, SUM(0) AS DED_LIC, SUM(FN_ROUNDOFFRS(0,1,'N')) AS PTAX, SUM(0) AS LINT_ADVGN, SUM(0) AS LOAN_ADVGN, SUM(0) AS LINT_MD, SUM(0) AS LOAN_MD, SUM(FN_ROUNDOFFRS(0,1,'N')) AS DED_WGADV, SUM(0) AS RAT_DED, SUM(FN_ROUNDOFFRS(1,1,'N')) AS DED_REV, SUM(NVL(GPSTEMPATTN.DED_ELEC,0)) AS DED_ELEC
 FROM GPSTEMPMAST, GPSTEMPATTN, GPSTEMPCOMP, GPSTEMPCAT 
 WHERE GPSTEMPCOMP.WORKERSERIAL = GPSTEMPMAST.WORKERSERIAL 
   AND GPSTEMPCOMP.WORKERSERIAL = GPSTEMPATTN.WORKERSERIAL  
   AND GPSTEMPMAST.CATEGORYCODE = GPSTEMPCAT.CATEGORYCODE 
   AND GPSTEMPMAST.COMPANYCODE = GPSTEMPATTN.COMPANYCODE AND GPSTEMPMAST.DIVISIONCODE = GPSTEMPATTN.DIVISIONCODE 
   AND GPSTEMPMAST.COMPANYCODE = GPSTEMPCAT.COMPANYCODE AND GPSTEMPMAST.DIVISIONCODE = GPSTEMPCAT.DIVISIONCODE 
   AND GPSTEMPMAST.COMPANYCODE = 'HP0072' AND GPSTEMPMAST.DIVISIONCODE = '0001' 
 AND GPSTEMPCOMP.WORKERSERIAL IN ('0007202')
 GROUP BY GPSTEMPCOMP.WORKERSERIAL, GPSTEMPMAST.CATEGORYCODE 
 
 
 SELECT * FROM GPSPAYSHEETDETAILS WHERE WORKERSERIAL IN ('0007202')


SELECT B.COMPANYCODE, B.DIVISIONCODE, A.WORKERSERIAL, A.CATEGORYCODE, A.GROSSWAGES, A.COMPONENTCODE, A.COMPONENTAMOUNT, B.CALCULATIONINDEX, 
NVL(C.APPLICABLE,'NO') APPLICABLE, NVL(B.COMPONENTGROUP,'XX') COMPONENTGROUP
,NVL(D.ISBLOCKED,'N') ISBLOCKED, NVL(D.APPLICABLE_PERCENT,0) APPLICABLE_PERCENT  
FROM GTT_SWT_PHASE_DEDN A, GPSCOMPONENTMAST B, 
(
    SELECT X.CATEGORYCODE, X.COMPONENTCODE, NVL(X.APPLICABLE,'NO') APPLICABLE
    FROM GPSCATEGORYVSCOMPONENT X, 
    (
        SELECT CATEGORYCODE, MAX(EFFECTIVEDATE) EFFECTIVEDATE 
        FROM GPSCATEGORYVSCOMPONENT 
        WHERE COMPANYCODE = 'HP0072' AND DIVISIONCODE = '0001'
        AND EFFECTIVEDATE <= TO_DATE('02/11/2020','DD/MM/YYYY')
        GROUP BY CATEGORYCODE  
    ) Y
    WHERE X.COMPANYCODE = 'HP0072' AND DIVISIONCODE = '0001'
    AND X.CATEGORYCODE = Y.CATEGORYCODE 
    AND X.EFFECTIVEDATE = Y.EFFECTIVEDATE
    AND X.APPLICABLE = 'YES'                     
) C--, SWT_PHASE_DEDN D
---- START BELOW BLOCK BY AMALESH ON 31/10/2018 FOR PERIOD WISE BLOCK COMPONENT CONSIDER IN THE CURSOR    
,(
    SELECT CATEGORYCODE, CATEGORYTYPE, COMPONENTCODE, NVL(ISAPPLICABLE,'Y') ISBLOCKED, NVL(APPLICABLE_PERCENT,0) APPLICABLE_PERCENT 
    FROM GPSWAGESCOMPONENTBLOCK
    WHERE COMPANYCODE = 'HP0072' AND DIVISIONCODE = '0001'
    --AND MODULE = 'GPS' 
    AND PERIODFROM >= TO_DATE('02/11/2020','DD/MM/YYYY')
    AND PERIODTO <= TO_DATE('08/11/2020','DD/MM/YYYY')
    AND CATEGORYTYPE = 'P'                    
) D
---- END BELOW BLOCK BY AMALESH ON 31/10/2018 FOR PERIOD WISE BLOCK COMPONENT CONSIDER IN THE CURSOR
WHERE B.COMPANYCODE = 'HP0072' AND DIVISIONCODE = '0001'
AND B.COMPONENTCODE = A.COMPONENTCODE 
AND B.COMPONENTCODE = C.COMPONENTCODE
AND B.PHASE = 6
AND A.CATEGORYCODE = C.CATEGORYCODE
AND NVL(C.APPLICABLE,'NO') <> 'NO'
AND NVL(A.GROSSWAGES,0) > 0
AND A.CATEGORYCODE = D.CATEGORYCODE (+) AND A.COMPONENTCODE = D.COMPONENTCODE (+)
AND A.WORKERSERIAL IN ('0007202')
ORDER BY A.WORKERSERIAL, B.CALCULATIONINDEX 
 

-----------------------------------------------------

ROUND OFF 1 , S
WORKERSERIAL - 0007202, COMPONENT - PF_E, COMPONENTGROUP - XX, AMOUNTS - 84,GROSS WAGES - 700
WORKERSERIAL - 0007202, COMPONENT - TOT_PF_DED, COMPONENTGROUP - XX, AMOUNTS - 84,GROSS WAGES - 700
WORKERSERIAL - 0007202, COMPONENT - RAT_DED, COMPONENTGROUP - RATION, AMOUNTS - 0,GROSS WAGES - 700
WORKERSERIAL - 0007202, COMPONENT - DED_WELFARE, COMPONENTGROUP - XX, AMOUNTS - 0,GROSS WAGES - 700
WORKERSERIAL - 0007202, COMPONENT - DED_UNION, COMPONENTGROUP - XX, AMOUNTS - 0,GROSS WAGES - 700
WORKERSERIAL - 0007202, COMPONENT - DED_ELEC, COMPONENTGROUP - XX, AMOUNTS - 0,GROSS WAGES - 700
WORKERSERIAL - 0007202, COMPONENT - LOAN_PF, COMPONENTGROUP - PF LOAN, AMOUNTS - 0,GROSS WAGES - 700
P_PROCESSTYPE - WAGES PROCESS, COMPONENT - LOAN_PF, COMPONENTGROUP - PF LOAN, AMOUNTS - 0,GROSS WAGES - 700
WORKERSERIAL - 0007202, COMPONENT - LOAN_ADVGN, COMPONENTGROUP - LOAN, AMOUNTS - 0,GROSS WAGES - 700
WORKERSERIAL - 0007202, COMPONENT - LINT_PF, COMPONENTGROUP - PF LOAN, AMOUNTS - 0,GROSS WAGES - 700
lv_ComponentAmt - 0, lv_EMI_DEDN_TYPE - PART, lv_PFLN_INT_STOP - N, AMOUNTS - 0,GROSS WAGES - 700
P_PROCESSTYPE - WAGES PROCESS, COMPONENT - LINT_PF, COMPONENTGROUP - PF LOAN, AMOUNTS - 0,GROSS WAGES - 700
END LOOP


SELECT CASE WHEN PFLOAN_INT_BAL > INT_EMI THEN INT_EMI ELSE PFLOAN_INT_BAL END , INT_EMI_DEDUCT_TYPE, NVL(INT_STOP,'N') 
--INTO lv_ComponentAmt, lv_EMI_DEDN_TYPE, lv_PFLN_INT_STOP  
FROM GBL_PFLOANBLNC 
WHERE WORKERSERIAL = '0007202'
AND LOANCODE = substr('LINT_PF',6)
AND NVL(INT_STOP,'N') = 'N'
AND PFLOAN_INT_BAL > 0;



ROUND OFF 1 , S
P_PROCESSTYPE - WAGES PROCESS, COMPONENT - LOAN_PF, COMPONENTGROUP - PF LOAN, AMOUNTS - 0,GROSS WAGES - 700
lv_ComponentAmt - 0007202, lv_EMI_DEDN_TYPE - LINT_PF, lv_PFLN_INT_STOP - N, AMOUNTS - 0,GROSS WAGES - 700
P_PROCESSTYPE - WAGES PROCESS, COMPONENT - LINT_PF, COMPONENTGROUP - PF LOAN, AMOUNTS - 0,GROSS WAGES - 700
END LOOP


ROUND OFF 1 , S
P_PROCESSTYPE - WAGES PROCESS, COMPONENT - LOAN_PF, COMPONENTGROUP - PF LOAN, AMOUNTS - 0,GROSS WAGES - 700
lv_Sql - 

SELECT CASE WHEN PFLOAN_INT_BAL > INT_EMI THEN INT_EMI ELSE PFLOAN_INT_BAL END , INT_EMI_DEDUCT_TYPE, NVL(INT_STOP,'N') 
FROM GBL_PFLOANBLNC 
WHERE WORKERSERIAL = '0007202' 
AND LOANCODE = 'PF' 
AND NVL(INT_STOP,'N') = 'N' 
AND PFLOAN_INT_BAL > 0 

lv_ComponentAmt - 0007202, lv_EMI_DEDN_TYPE - LINT_PF, lv_PFLN_INT_STOP - N, AMOUNTS - 0,GROSS WAGES - 700
P_PROCESSTYPE - WAGES PROCESS, COMPONENT - LINT_PF, COMPONENTGROUP - PF LOAN, AMOUNTS - 0,GROSS WAGES - 700
END LOOP



ROUND OFF 1 , S
P_PROCESSTYPE - WAGES PROCESS, COMPONENT - LOAN_PF, COMPONENTGROUP - PF LOAN, AMOUNTS - 0,GROSS WAGES - 700
lv_Sql - 

SELECT CASE WHEN PFLOAN_INT_BAL > INT_EMI THEN INT_EMI ELSE PFLOAN_INT_BAL END , INT_EMI_DEDUCT_TYPE, NVL(INT_STOP,'N') 
FROM GBL_PFLOANBLNC 
WHERE WORKERSERIAL = '0007202' 
AND LOANCODE = 'PF' 
AND NVL(INT_STOP,'N') = 'N' 
AND PFLOAN_INT_BAL > 0 

lv_ComponentAmt - 0007202, lv_EMI_DEDN_TYPE - LINT_PF, lv_PFLN_INT_STOP - N, AMOUNTS - 0,GROSS WAGES - 700
P_PROCESSTYPE - WAGES PROCESS, COMPONENT - LINT_PF, COMPONENTGROUP - PF LOAN, AMOUNTS - 0,GROSS WAGES - 700
END LOOP



    PROC_PFLOANBLNC('HP0072','0001','02/11/2020','08/11/2020',NULL,NULL,'GPS','YES');
    
    
    ROUND OFF 1 , S
P_PROCESSTYPE - WAGES PROCESS, COMPONENT - LOAN_PF, COMPONENTGROUP - PF LOAN, AMOUNTS - 0,GROSS WAGES - 700
lv_Sql - 

SELECT CASE WHEN PFLOAN_INT_BAL > INT_EMI THEN INT_EMI ELSE PFLOAN_INT_BAL END , INT_EMI_DEDUCT_TYPE, NVL(INT_STOP,'N') 
FROM GBL_PFLOANBLNC 
WHERE WORKERSERIAL = '0007202' 
AND LOANCODE = 'PF' 
AND NVL(INT_STOP,'N') = 'N' 
AND PFLOAN_INT_BAL > 0 

lv_ComponentAmt - 0007202, lv_EMI_DEDN_TYPE - LINT_PF, lv_PFLN_INT_STOP - N, AMOUNTS - 0,GROSS WAGES - 700
P_PROCESSTYPE - WAGES PROCESS, COMPONENT - LINT_PF, COMPONENTGROUP - PF LOAN, AMOUNTS - 0,GROSS WAGES - 700
END LOOP












SELECT * FROM  GBL_PFLOANBLNC WHERE PFNO='1825' 

 INSERT INTO GBL_PFLOANBLNC 
 
 
 INSERT INTO GBL_PFLOANBLNC 
 
 
 SELECT B.WORKERSERIAL, B.TOKENNO, A.PFNO, A.LOANCODE, A.LOANDATE, SUM(A.AMOUNT) PFLOAN_BAL, 
 CASE WHEN SUM(INTERESTAMOUNT) > 0 THEN SUM(INTERESTAMOUNT) ELSE 0 END PFLOAN_INT_BAL, 
 SUM(LN_CAP_DEDUCT) PFLN_CAP_DEDUCT, SUM(LN_INT_DEDUCT) PFLN_INT_DEDUCT,  
 /*NVL(X.CAP_EMI,0) CAP_EMI, NVL(X.INT_EMI,0) INT_EMI, */
 CASE WHEN Z.DEDUCTIONSTARTDATE > TO_DATE('08/11/2020','DD/MM/YYYY') THEN 0 ELSE 
         CASE WHEN M.DEDUCTIONTYPE = 'DEDUCT INTEREST FULL THEN CAPITAL' AND SUM(INTERESTAMOUNT) > 0 THEN 0 ELSE DECODE(DEDUCTIONTYPE,'DEDUCT CAPITAL AND INTEREST SAMETIME',NVL(X.CAP_EMI,0),NVL(X.TOT_EMI,0)) END END CAP_EMI, 
 CASE WHEN Z.DEDUCTIONSTARTDATE > TO_DATE('08/11/2020','DD/MM/YYYY') THEN 0 ELSE 
         CASE WHEN M.DEDUCTIONTYPE = 'DEDUCT CAPITAL FULL THEN INTEREST' AND SUM(A.AMOUNT) >0 THEN 0 ELSE DECODE(DEDUCTIONTYPE,'DEDUCT CAPITAL AND INTEREST SAMETIME',NVL(X.INT_EMI,0),NVL(X.TOT_EMI,0))  END END INT_EMI, 
 NVL(X.TOT_EMI,0) TOT_EMI, 
 NVL(Y.CAP_STOP,'N') CAP_STOP,
 NVL(Y.INT_STOP,'N') INT_STOP,
 B.MODULE, 'PART' CAP_EMI_DEDUCT_TYPE, 'PART' INT_EMI_DEDUCT_TYPE  
 FROM (  
         SELECT DISTINCT A.COMPANYCODE,A.DIVISIONCODE,A.PFNO, A.LOANCODE, A.LOANDATE, AMOUNT, 0 INTERESTAMOUNT , 0 LN_CAP_DEDUCT, 0 LN_INT_DEDUCT 
         FROM PFLOANTRANSACTION A,  
         (  
             SELECT DISTINCT COMPANYCODE,DIVISIONCODE,PFNO, MAX(LOANDATE) LOANDATE  
            FROM PFLOANTRANSACTION  
            WHERE COMPANYCODE = 'HP0072' AND DIVISIONCODE = '0001' 
             AND LOANDATE <=  TO_DATE('08/11/2020','DD/MM/YYYY')
             AND LOANTYPE ='REFUNDABLE'
             GROUP BY COMPANYCODE,DIVISIONCODE,PFNO  
         ) B  
         WHERE A.COMPANYCODE=B.COMPANYCODE AND A.DIVISIONCODE=B.DIVISIONCODE AND A.PFNO = B.PFNO AND A.LOANDATE = B.LOANDATE  AND AMOUNT > 0 
         UNION ALL     
         SELECT A.COMPANYCODE,A.DIVISIONCODE,A.PFNO, A.LOANCODE, A.LOANDATE,   
           (CASE WHEN TRANSACTIONTYPE ='CAPITAL' THEN CASE WHEN EFFECTFORTNIGHT < TO_DATE('08/11/2020','DD/MM/YYYY') THEN AMOUNT ELSE 0 END  
                WHEN TRANSACTIONTYPE ='REPAY' THEN REPAYCAPITAL  
                WHEN TRANSACTIONTYPE ='REPAYCAP' THEN AMOUNT  
                ELSE 0  
           END)*(-1) AMOUNT, 0 INTERESTAMOUNT 
           , 0 LN_CAP_DEDUCT, 0 LN_INT_DEDUCT     
         FROM PFLOANBREAKUP A,  
         (  
             SELECT DISTINCT COMPANYCODE,DIVISIONCODE,PFNO, MAX(LOANDATE) LOANDATE  
             FROM PFLOANTRANSACTION  
             WHERE COMPANYCODE = 'HP0072' AND DIVISIONCODE ='0001' 
             AND LOANDATE <=  TO_DATE('08/11/2020','DD/MM/YYYY')  
            AND LOANTYPE ='REFUNDABLE'                     
             GROUP BY COMPANYCODE,DIVISIONCODE,PFNO  
         ) B  
         WHERE A.COMPANYCODE=B.COMPANYCODE AND A.DIVISIONCODE=B.DIVISIONCODE AND A.PFNO = B.PFNO AND A.LOANDATE = B.LOANDATE  
         AND A.EFFECTFORTNIGHT <=  TO_DATE('08/11/2020','DD/MM/YYYY')  
         AND TRANSACTIONTYPE <> 'INTEREST'  
         UNION ALL  
         SELECT DISTINCT A.COMPANYCODE,A.DIVISIONCODE,A.PFNO, A.LOANCODE, A.LOANDATE, 0 AMOUNT, SUM(NVL(C.INTERESTAMOUNT,0)) INTERESTAMOUNT 
         , 0 LN_CAP_DEDUCT, 0 LN_INT_DEDUCT  
         FROM ( SELECT DISTINCT COMPANYCODE,DIVISIONCODE,PFNO, LOANCODE, LOANDATE 
                FROM PFLOANTRANSACTION 
                WHERE COMPANYCODE ='HP0072' AND DIVISIONCODE = '0001'
              ) A, 
            (  
                 SELECT DISTINCT COMPANYCODE,DIVISIONCODE,PFNO, MAX(LOANDATE) LOANDATE 
                FROM PFLOANTRANSACTION  
                WHERE COMPANYCODE = 'HP0072' AND DIVISIONCODE = '0001'  
                AND LOANDATE <=  TO_DATE('08/11/2020','DD/MM/YYYY')  
                AND LOANTYPE ='REFUNDABLE'
                GROUP BY COMPANYCODE,DIVISIONCODE,PFNO  
            ) B, PFLOANINTEREST C  
         WHERE A.COMPANYCODE = 'HP0072' AND A.DIVISIONCODE = '0001' AND A.COMPANYCODE=B.COMPANYCODE AND A.DIVISIONCODE=B.DIVISIONCODE AND A.PFNO = B.PFNO AND A.LOANDATE = B.LOANDATE  
         AND A.PFNO = C.PFNO AND A.LOANDATE = C.LOANDATE AND A.LOANCODE = C.LOANCODE  
         AND C.FORTNIGHTENDDATE <= TO_DATE('08/11/2020','DD/MM/YYYY') 
         AND C.TRANSACTIONTYPE = 'ADD'  
         GROUP BY A.COMPANYCODE,A.DIVISIONCODE,A.PFNO, A.LOANCODE, A.LOANDATE  
         UNION ALL  
         SELECT A.COMPANYCODE,A.DIVISIONCODE,A.PFNO, A.LOANCODE, A.LOANDATE, 0 AMOUNT,   
           (CASE WHEN TRANSACTIONTYPE ='INTEREST' THEN CASE WHEN EFFECTFORTNIGHT < TO_DATE('08/11/2020','DD/MM/YYYY') THEN AMOUNT ELSE 0 END  
                WHEN TRANSACTIONTYPE ='REPAY' THEN REPAYINTEREST  
                WHEN TRANSACTIONTYPE ='REPAYINT' THEN AMOUNT  
                ELSE 0  
           END)*(-1) INTERESTAMOUNT 
           , 0 LN_CAP_DEDUCT, 0 LN_INT_DEDUCT      
         FROM PFLOANBREAKUP A,  
         (  
             SELECT DISTINCT COMPANYCODE,DIVISIONCODE,PFNO, MAX(LOANDATE) LOANDATE  
             FROM PFLOANTRANSACTION  
             WHERE COMPANYCODE = 'HP0072' AND DIVISIONCODE = '0001'  
             AND LOANDATE <=  TO_DATE('08/11/2020','DD/MM/YYYY')  
             AND LOANTYPE ='REFUNDABLE'
             GROUP BY COMPANYCODE,DIVISIONCODE,PFNO  
         ) B  
         WHERE A.COMPANYCODE=B.COMPANYCODE AND A.DIVISIONCODE=B.DIVISIONCODE AND A.PFNO = B.PFNO AND A.LOANDATE = B.LOANDATE  
         AND A.EFFECTFORTNIGHT <= TO_DATE('08/11/2020','DD/MM/YYYY') 
         AND TRANSACTIONTYPE <> 'CAPITAL' 
         UNION ALL 
         SELECT A.COMPANYCODE,A.DIVISIONCODE,A.PFNO, A.LOANCODE, A.LOANDATE, 0 AMOUNT,  0 INTERESTAMOUNT,  
         DECODE(TRANSACTIONTYPE,'CAPITAL',AMOUNT,0) LN_CAP_DEDUCT, DECODE(TRANSACTIONTYPE,'INTEREST',AMOUNT,0) LN_INT_DEDUCT 
         FROM PFLOANBREAKUP A,  
         (  
             SELECT DISTINCT COMPANYCODE,DIVISIONCODE,PFNO, MAX(LOANDATE) LOANDATE  
             FROM PFLOANTRANSACTION  
             WHERE COMPANYCODE = 'HP0072' AND DIVISIONCODE = '0001'  
             AND LOANDATE <=  TO_DATE('08/11/2020','DD/MM/YYYY') 
             AND LOANTYPE ='REFUNDABLE'
             GROUP BY COMPANYCODE,DIVISIONCODE,PFNO  
         ) B  
         WHERE A.COMPANYCODE=B.COMPANYCODE AND A.DIVISIONCODE=B.DIVISIONCODE AND A.PFNO = B.PFNO AND A.LOANDATE = B.LOANDATE  
         AND A.EFFECTFORTNIGHT <= TO_DATE('08/11/2020','DD/MM/YYYY')
         AND TRANSACTIONTYPE IN ('CAPITAL','INTEREST')  
     ) A, PFEMPLOYEEMASTER B, 
     (  
        SELECT M.COMPANYCODE,M.DIVISIONCODE,M.PFNO, M.LOANDATE,  
        NVL(M.CAPITALINSTALLMENTAMT,0) CAP_EMI,  
        NVL(M.INTERESTINSTALLMENTAMT,0) INT_EMI, NVL(M.TOTALEMIAMOUNT,0) TOT_EMI  
        FROM PFLOANTRANSACTION M, ( SELECT COMPANYCODE,DIVISIONCODE,PFNO, MAX(LOANDATE) LOANDATE  
                                  FROM PFLOANTRANSACTION  
                                  WHERE LOANDATE <= TO_DATE('08/11/2020','DD/MM/YYYY')  
                                  GROUP BY COMPANYCODE,DIVISIONCODE,PFNO  
                                ) N   
        WHERE M.COMPANYCODE=N.COMPANYCODE AND M.DIVISIONCODE=N.DIVISIONCODE AND M.PFNO = N.PFNO AND M.LOANDATE = N.LOANDATE  
     )  X,   
     ( 
        SELECT DISTINCT COMPANYCODE,DIVISIONCODE,LOANCODE, DEDUCTIONTYPE FROM PFLOANMASTER 
     ) M, 
     ( 
         SELECT COMPANYCODE,DIVISIONCODE,PFNO, WORKERSERIAL, TOKENNO, LOANCODE, LOANDATE, 
         LOANSTOPFROMDATE, LOANSTOPTODATE, CAPITAL CAP_STOP, INTEREST INT_STOP, FULLMILL 
         FROM PFLOANDEDUCTIONSTOP 
         WHERE COMPANYCODE = 'HP0072' AND DIVISIONCODE = '0001' 
           AND LOANSTOPFROMDATE <= TO_DATE('08/11/2020','DD/MM/YYYY') 
           AND LOANSTOPTODATE >= TO_DATE('08/11/2020','DD/MM/YYYY') 
           AND NVL(FULLMILL,'N') <> 'Y' 
           AND PFNO IS NOT NULL 
     ) Y, 
     ( 
        SELECT DISTINCT COMPANYCODE,DIVISIONCODE,PFNO, MAX(LOANDATE) LOANDATE, NVL(MAX(DEDUCTIONSTARTDATE),MAX(LOANDATE)) DEDUCTIONSTARTDATE 
        FROM PFLOANTRANSACTION 
        WHERE COMPANYCODE = 'HP0072' AND DIVISIONCODE = '0001'  
          AND LOANDATE <=  TO_DATE('08/11/2020','DD/MM/YYYY')  
          AND LOANTYPE ='REFUNDABLE' 
        GROUP BY COMPANYCODE,DIVISIONCODE,PFNO 
     ) Z 
 WHERE A.COMPANYCODE=B.COMPANYCODE  
 AND A.COMPANYCODE=M.COMPANYCODE    
 AND A.COMPANYCODE=X.COMPANYCODE    
 AND A.COMPANYCODE=Y.COMPANYCODE (+)  
 AND A.COMPANYCODE=Z.COMPANYCODE  
 AND A.DIVISIONCODE=B.DIVISIONCODE  
 AND A.DIVISIONCODE=M.DIVISIONCODE  
 AND A.DIVISIONCODE=X.DIVISIONCODE  
 AND A.DIVISIONCODE=Y.DIVISIONCODE (+)  
 AND A.DIVISIONCODE=Z.DIVISIONCODE  
 AND A.PFNO = B.PFNO  
   AND A.PFNO = X.PFNO AND A.LOANDATE = X.LOANDATE 
   AND A.LOANCODE = M.LOANCODE 
   AND A.PFNO = Z.PFNO AND A.LOANDATE = Z.LOANDATE 
   AND A.PFNO = Y.PFNO (+)  
  GROUP BY B.WORKERSERIAL, B.TOKENNO, A.PFNO, A.LOANCODE, A.LOANDATE, Z.DEDUCTIONSTARTDATE, 
  NVL(X.CAP_EMI,0), NVL(X.INT_EMI,0), NVL(X.TOT_EMI,0), B.MODULE, M.DEDUCTIONTYPE, Y.CAP_STOP, Y.INT_STOP 
 
 
