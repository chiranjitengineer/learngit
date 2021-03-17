DROP PROCEDURE NJMCL_WEB.PRCWPS_PFPREVLOANDETAILS;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRCWPS_PFPREVLOANDETAILS" (p_com varchar2,p_div varchar2,p_pfno varchar2,
                                                             p_date varchar2,p_module varchar2,
                                                             p_NRloancode varchar2)
/*  PFNO,LOANDATE,WPS/PIS       exec prcWPS_PFPrevLoanDetails('HC0001','0022','90107','10/03/2016','WPS','''10'',''9'''  ) */
is
lv_pdate varchar2(50) := p_date ;
--lv_startendTag varchar2(50)  := UPPER(p_startendTag);
lv_startDate VARCHAR2(10) := '';
lv_endDate varchar2(10) :='';
lv_cnt number := 0 ;

BEGIN

        SELECT fn_getFortnightStartEndDate(p_date,'END')
          INTO lv_endDate
         FROM DUAL;
          
        SELECT COUNT(*) INTO LV_CNT FROM
        (    
            SELECT DISTINCT PFNO, MAX(LOANDATE) LOANDATE  
            FROM PFLOANTRANSACTION  
            WHERE COMPANYCODE = p_com AND DIVISIONCODE = p_div  
            AND LOANDATE <= TO_DATE(lv_endDate,'DD/MM/YYYY')  
            AND  INSTR(p_NRloancode,LOANCODE) = 0  
            GROUP BY PFNO
        ) ; 
        
      IF LV_CNT >0 THEN  
            INSERT INTO GBL_PFLOANBALACE         
            SELECT B.EMPLOYEEID TOKENNO, A.PFNO, A.LOANCODE, A.LOANDATE, SUM(A.AMOUNT) PFLOAN_BAL, CASE WHEN SUM(INTERESTAMOUNT) > 0 THEN SUM(INTERESTAMOUNT) ELSE 0 END PFLOAN_INT_BAL,  
                 SUM(LN_CAP_DEDUCT) PFLN_CAP_DEDUCT, SUM(LN_INT_DEDUCT) PFLN_INT_DEDUCT  
                 FROM (  
                         SELECT DISTINCT A.PFNO, A.LOANCODE, A.LOANDATE, AMOUNT, 0 INTERESTAMOUNT , 0 LN_CAP_DEDUCT, 0 LN_INT_DEDUCT  
                         FROM PFLOANTRANSACTION A,  
                         (  
                             SELECT DISTINCT PFNO, MAX(LOANDATE) LOANDATE  
                             FROM PFLOANTRANSACTION  
                             WHERE COMPANYCODE = p_com AND DIVISIONCODE = p_div  
                             AND LOANDATE <= TO_DATE(lv_endDate,'DD/MM/YYYY')  
                             AND  INSTR(p_NRloancode,LOANCODE) = 0  
                             GROUP BY PFNO  
                         ) B  
                         WHERE A.PFNO = B.PFNO AND A.LOANDATE = B.LOANDATE  AND AMOUNT > 0 
                         UNION ALL  
                         SELECT A.PFNO, A.LOANCODE, A.LOANDATE,   
                           (CASE WHEN TRANSACTIONTYPE ='CAPITAL' THEN AMOUNT  
                                WHEN TRANSACTIONTYPE ='REPAY' THEN REPAYCAPITAL  
                                WHEN TRANSACTIONTYPE ='REPAYCAP' THEN AMOUNT  
                                ELSE 0  
                           END)*(-1) AMOUNT, 0 INTERESTAMOUNT 
                           , 0 LN_CAP_DEDUCT, 0 LN_INT_DEDUCT       
                         FROM PFLOANBREAKUP A,  
                         (  
                             SELECT DISTINCT PFNO, MAX(LOANDATE) LOANDATE  
                             FROM PFLOANTRANSACTION  
                             WHERE COMPANYCODE = p_com AND DIVISIONCODE = p_div  
                             AND LOANDATE <= TO_DATE(lv_endDate,'DD/MM/YYYY')  
                             AND INSTR(p_NRloancode,LOANCODE) = 0  
                             GROUP BY PFNO  
                         ) B  
                         WHERE A.PFNO = B.PFNO AND A.LOANDATE = B.LOANDATE  
                         AND A.EFFECTFORTNIGHT <= TO_DATE(lv_endDate,'DD/MM/YYYY')  
                         AND TRANSACTIONTYPE <> 'INTEREST'  
                         UNION ALL  
                         SELECT DISTINCT A.PFNO, A.LOANCODE, A.LOANDATE, 0 AMOUNT, SUM(NVL(C.INTERESTAMOUNT,0)) INTERESTAMOUNT 
                         , 0 LN_CAP_DEDUCT, 0 LN_INT_DEDUCT  
                         FROM ( SELECT DISTINCT PFNO, LOANCODE, LOANDATE 
                                FROM PFLOANTRANSACTION 
                                WHERE COMPANYCODE = p_com AND DIVISIONCODE = p_div
                              ) A, 
                            (  
                                 SELECT DISTINCT PFNO, MAX(LOANDATE) LOANDATE  
                                FROM PFLOANTRANSACTION  
                                WHERE COMPANYCODE = p_com AND DIVISIONCODE = p_div  
                                AND LOANDATE <= TO_DATE(lv_endDate,'DD/MM/YYYY')  
                                AND INSTR(p_NRloancode,LOANCODE) = 0  
                                GROUP BY PFNO  
                            ) B, PFLOANINTEREST C  
                         WHERE A.PFNO = B.PFNO AND A.LOANDATE = B.LOANDATE  
                         AND A.PFNO = C.PFNO AND A.LOANDATE = C.LOANDATE AND A.LOANCODE = C.LOANCODE  
                         AND C.FORTNIGHTENDDATE <= TO_DATE(lv_endDate,'DD/MM/YYYY')  
                         AND C.TRANSACTIONTYPE = 'ADD'  
                         GROUP BY A.PFNO, A.LOANCODE, A.LOANDATE  
                         UNION ALL  
                         SELECT A.PFNO, A.LOANCODE, A.LOANDATE, 0 AMOUNT,   
                           (CASE WHEN TRANSACTIONTYPE ='INTEREST' THEN AMOUNT  
                                WHEN TRANSACTIONTYPE ='REPAY' THEN REPAYINTEREST  
                                WHEN TRANSACTIONTYPE ='REPAYINT' THEN AMOUNT  
                                ELSE 0  
                           END)*(-1) INTERESTAMOUNT 
                           , 0 LN_CAP_DEDUCT, 0 LN_INT_DEDUCT       
                         FROM PFLOANBREAKUP A,  
                         (  
                             SELECT DISTINCT PFNO, MAX(LOANDATE) LOANDATE  
                             FROM PFLOANTRANSACTION  
                             WHERE COMPANYCODE = p_com AND DIVISIONCODE = p_div  
                             AND LOANDATE <= TO_DATE(lv_endDate,'DD/MM/YYYY')  
                             AND INSTR(p_NRloancode,LOANCODE) = 0  
                             GROUP BY PFNO  
                         ) B  
                         WHERE A.PFNO = B.PFNO AND A.LOANDATE = B.LOANDATE  
                         AND A.EFFECTFORTNIGHT <= TO_DATE(lv_endDate,'DD/MM/YYYY')  
                         AND TRANSACTIONTYPE <> 'CAPITAL' 
                         UNION ALL 
                         SELECT A.PFNO, A.LOANCODE, A.LOANDATE, 0 AMOUNT,  0 INTERESTAMOUNT,  
                         DECODE(TRANSACTIONTYPE,'CAPITAL',AMOUNT,0) LN_CAP_DEDUCT, DECODE(TRANSACTIONTYPE,'INTEREST',AMOUNT,0) LN_INT_DEDUCT 
                         FROM PFLOANBREAKUP A,  
                         (  
                             SELECT DISTINCT PFNO, MAX(LOANDATE) LOANDATE  
                             FROM PFLOANTRANSACTION  
                             WHERE COMPANYCODE = p_com AND DIVISIONCODE = p_div  
                             AND LOANDATE <= TO_DATE(lv_endDate,'DD/MM/YYYY')  
                             AND INSTR(p_NRloancode,LOANCODE) = 0  
                             GROUP BY PFNO  
                         ) B  
                         WHERE A.PFNO = B.PFNO AND A.LOANDATE = B.LOANDATE  
                         AND A.EFFECTFORTNIGHT = TO_DATE(lv_endDate,'DD/MM/YYYY')  
                         AND TRANSACTIONTYPE IN ('CAPITAL','INTEREST')                    
                     ) A, PFEMPLOYEEMASTER B  /*WPSWORKERMAST B */ 
                 WHERE A.PFNO = B.PFNO  
                   AND A.PFNO = p_pfno 
                 /*GROUP BY B.WORKERSERIAL, A.PFNO, A.LOANCODE, A.LOANDATE */
                 GROUP BY B.EMPLOYEEID, A.PFNO, A.LOANCODE, A.LOANDATE;
           
       END IF;
END;
/


