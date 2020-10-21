CREATE OR REPLACE PROCEDURE JOONK.PROC_PFLOANBLNC_NEW
(
    P_COMPCODE     VARCHAR2,
    P_DIVCODE      VARCHAR2,
    P_STARTDATE    VARCHAR2,
    P_ENDDATE      VARCHAR2,    
    P_LOANCODE     VARCHAR2,
    P_PFNO         VARCHAR2,
    P_MODULE       VARCHAR2 default 'GPS',
    P_WAGEPROCESS  VARCHAR2 DEFAULT 'NO'
)
AS 
    LV_SQLSTR      VARCHAR2(20000);
    lv_FullMillStop_Cap varchar2(1):='N';
    lv_FullMillStop_Int varchar2(1):='N';
    lv_FullMillStop varchar2(1):='N';
    lv_Cnt number(2) := 0;
    lv_sqlerrm      VARCHAR2(500) := '';
    lv_TableName VARCHAR2(30) := '';
    lv_ProcName    VARCHAR2(30) := '';
    lv_fn_stdt      DATE := TO_DATE(P_STARTDATE,'DD/MM/YYYY');
    lv_fn_endt      DATE := TO_DATE(P_ENDDATE,'DD/MM/YYYY');
    lv_parvalues    VARCHAR2(100) := '';
BEGIN
     if P_WAGEPROCESS = 'YES' THEN
         if P_MODULE = 'WPS' then
            lv_TableName := 'WPSWAGESDETAILS_MV_SWT';
         ELSIF P_MODULE = 'GPS' then
            lv_TableName := 'GPSPAYSHEETDETAILS_SWT';
         else
            lv_TableName := 'PISPAYTRANSACTION_SWT';
         end if;
         LV_SQLSTR := ' DELETE FROM PFLOANBREAKUP '||CHR(10)
                ||' WHERE EMPLOYEECOMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10) 
                ||' AND WORKERSERIAL IN ( SELECT WORKERSERIAL FROM '||lv_TableName||') '||CHR(10)
                ||' AND TRANSACTIONTYPE IN (''CAPITAL'',''INTEREST'') '||CHR(10)
                ||' AND EFFECTFORTNIGHT = TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'') '||CHR(10);
        insert into GPS_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
        values(P_COMPCODE, P_DIVCODE,lv_ProcName,lv_sqlerrm,LV_SQLSTR,lv_parvalues,lv_fn_stdt,lv_fn_endt, 'PF LOAN BREAKUP DATA DELETE');
        COMMIT;
        EXECUTE IMMEDIATE LV_SQLSTR;
        COMMIT;
     end if;                   

    SELECT COUNT(*) into lv_Cnt 
    FROM PFLOANDEDUCTIONSTOP
    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
      AND LOANSTOPFROMDATE <= TO_DATE(P_STARTDATE,'DD/MM/YYYY')
      AND LOANSTOPTODATE >= TO_DATE(P_ENDDATE,'DD/MM/YYYY')
      AND FULLMILL = 'Y';
        
    if lv_Cnt >0 then
        SELECT FULLMILL,CAPITAL, INTEREST into lv_FullMillStop, lv_FullMillStop_Cap, lv_FullMillStop_Int 
        FROM PFLOANDEDUCTIONSTOP
        WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
          AND LOANSTOPFROMDATE <= TO_DATE(P_STARTDATE,'DD/MM/YYYY')
          AND LOANSTOPTODATE >= TO_DATE(P_ENDDATE,'DD/MM/YYYY')
          AND FULLMILL = 'Y';        
    end if;
    
    
    
--CREATE GLOBAL TEMPORARY TABLE GTT_LOANMAXDATE AS
--SELECT DISTINCT COMPANYCODE,DIVISIONCODE,PFNO, WORKERSERIAL,LOANCODE, 
--MAX(LOANDATE) LOANDATE,NVL(MAX(DEDUCTIONSTARTDATE),MAX(LOANDATE)) DEDUCTIONSTARTDATE 
--FROM PFLOANTRANSACTION  
--WHERE COMPANYCODE = 'JT0069' AND DIVISIONCODE = '0002' 
--AND LOANDATE <=  TO_DATE('21/10/2020','DD/MM/YYYY')
--AND LOANTYPE ='REFUNDABLE'
--GROUP BY COMPANYCODE,DIVISIONCODE, LOANCODE,WORKERSERIAL,PFNO 


    LV_SQLSTR := NULL;
    LV_SQLSTR :=   LV_SQLSTR  ||  'INSERT INTO GTT_LOANMAXDATE'|| CHR(10);
    LV_SQLSTR :=   LV_SQLSTR  ||  'SELECT DISTINCT COMPANYCODE,DIVISIONCODE,PFNO, WORKERSERIAL,LOANCODE, '|| CHR(10);
    LV_SQLSTR :=   LV_SQLSTR  ||  'MAX(LOANDATE) LOANDATE,NVL(MAX(DEDUCTIONSTARTDATE),MAX(LOANDATE)) DEDUCTIONSTARTDATE '|| CHR(10);
    LV_SQLSTR :=   LV_SQLSTR  ||  'FROM PFLOANTRANSACTION  '|| CHR(10);
    LV_SQLSTR :=   LV_SQLSTR  ||  'WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '|| CHR(10);
    LV_SQLSTR :=   LV_SQLSTR  ||  'AND LOANDATE <=  TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR :=   LV_SQLSTR  ||  'AND LOANTYPE =''REFUNDABLE'''|| CHR(10);
    LV_SQLSTR :=   LV_SQLSTR  ||  'GROUP BY COMPANYCODE,DIVISIONCODE, LOANCODE,WORKERSERIAL,PFNO'|| CHR(10);
        
        
    
    
    DELETE FROM GBL_PFLOANBLNC;
    LV_SQLSTR :=    'INSERT INTO GBL_PFLOANBLNC '|| CHR(10)
                ||' SELECT B.WORKERSERIAL, B.TOKENNO, A.PFNO, A.LOANCODE, A.LOANDATE, SUM(A.AMOUNT) PFLOAN_BAL, '|| CHR(10)
                ||' CASE WHEN SUM(INTERESTAMOUNT) > 0 THEN SUM(INTERESTAMOUNT) ELSE 0 END PFLOAN_INT_BAL, '|| CHR(10) 
                ||' SUM(LN_CAP_DEDUCT) PFLN_CAP_DEDUCT, SUM(LN_INT_DEDUCT) PFLN_INT_DEDUCT,  '|| CHR(10)
                ||' /*NVL(X.CAP_EMI,0) CAP_EMI, NVL(X.INT_EMI,0) INT_EMI, */'||CHR(10)
                ||' CASE WHEN Z.DEDUCTIONSTARTDATE > TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'') THEN 0 ELSE '||CHR(10)
                ||'         CASE WHEN M.DEDUCTIONTYPE = ''DEDUCT INTEREST FULL THEN CAPITAL'' AND SUM(INTERESTAMOUNT) > 0 THEN 0 ELSE DECODE(DEDUCTIONTYPE,''DEDUCT CAPITAL AND INTEREST SAMETIME'',NVL(X.CAP_EMI,0),NVL(X.TOT_EMI,0)) END END CAP_EMI, '||CHR(10)
--                ||' CASE WHEN Z.DEDUCTIONSTARTDATE > TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'') THEN 0 ELSE '||CHR(10)
--                ||' CASE WHEN M.DEDUCTIONTYPE = ''DEDUCT INTEREST FULL THEN CAPITAL'' AND SUM(INTERESTAMOUNT) > 0 THEN NVL(X.INT_EMI,0) ELSE '||CHR(10)
--                ||' CASE WHEN M.DEDUCTIONTYPE = ''DEDUCT CAPITAL FULL THEN INTEREST'' AND SUM(A.AMOUNT) >0 THEN 0 ELSE DECODE(DEDUCTIONTYPE,''DEDUCT CAPITAL AND INTEREST SAMETIME'',NVL(X.INT_EMI,0),NVL(X.TOT_EMI,0)) END END END INT_EMI, '||CHR(10)
                ||' CASE WHEN Z.DEDUCTIONSTARTDATE > TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'') THEN 0 ELSE '||CHR(10)
                ||'    CASE WHEN M.DEDUCTIONTYPE = ''DEDUCT INTEREST FULL THEN CAPITAL'' AND SUM(INTERESTAMOUNT) > 0 THEN NVL(X.INT_EMI,0) '||CHR(10) 
                ||'    ELSE CASE WHEN SUM(A.AMOUNT) <=0 AND SUM(INTERESTAMOUNT) > 0 THEN NVL(X.INT_EMI,0) ELSE 0 END END END INT_EMI, '||CHR(10)               
                ||' NVL(X.TOT_EMI,0) TOT_EMI, '||CHR(10);
    IF lv_FullMillStop_Cap = 'Y' THEN
        LV_SQLSTR := LV_SQLSTR ||' ''Y'' CAP_STOP,'||CHR(10);
    else
        LV_SQLSTR := LV_SQLSTR ||' NVL(Y.CAP_STOP,''N'') CAP_STOP,'||CHR(10);
    end if;               
    IF lv_FullMillStop_Int = 'Y' THEN
        LV_SQLSTR := LV_SQLSTR ||' ''Y'' INT_STOP, '||CHR(10);
    else
        LV_SQLSTR := LV_SQLSTR ||' NVL(Y.INT_STOP,''N'') INT_STOP,'||CHR(10);
    end if;        
    LV_SQLSTR := LV_SQLSTR    ||' B.MODULE, ''FULL'' CAP_EMI_DEDUCT_TYPE, ''FULL'' INT_EMI_DEDUCT_TYPE  '||chr(10)
                ||' FROM (  '|| CHR(10)
                ||'         SELECT DISTINCT A.COMPANYCODE,A.DIVISIONCODE,A.PFNO, A.LOANCODE, A.LOANDATE, AMOUNT, 0 INTERESTAMOUNT , 0 LN_CAP_DEDUCT, 0 LN_INT_DEDUCT '|| CHR(10) 
                ||'         FROM PFLOANTRANSACTION A,  '|| CHR(10)
                ||'         (  '|| CHR(10)
                ||'             SELECT DISTINCT COMPANYCODE,DIVISIONCODE,PFNO, MAX(LOANDATE) LOANDATE  '|| CHR(10)
                ||'            FROM PFLOANTRANSACTION  '|| CHR(10)
                ||'            WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10) 
                ||'             AND LOANDATE <=  TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'')'|| CHR(10)
                ||'             AND LOANTYPE =''REFUNDABLE'''|| CHR(10)
                ||'             GROUP BY COMPANYCODE,DIVISIONCODE,PFNO  '|| CHR(10)
                ||'         ) B  '|| CHR(10)
                ||'         WHERE A.COMPANYCODE=B.COMPANYCODE AND A.DIVISIONCODE=B.DIVISIONCODE AND A.PFNO = B.PFNO AND A.LOANDATE = B.LOANDATE  AND AMOUNT > 0 '|| CHR(10)
                ||'         UNION ALL     '|| CHR(10)
                ||'         SELECT A.COMPANYCODE,A.DIVISIONCODE,A.PFNO, A.LOANCODE, A.LOANDATE,   '|| CHR(10)
                ||'           (CASE WHEN TRANSACTIONTYPE =''CAPITAL'' THEN CASE WHEN EFFECTFORTNIGHT < TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'') THEN AMOUNT ELSE 0 END  '|| CHR(10)
                ||'                WHEN TRANSACTIONTYPE =''REPAY'' THEN REPAYCAPITAL  '|| CHR(10)
                ||'                WHEN TRANSACTIONTYPE =''REPAYCAP'' THEN AMOUNT  '|| CHR(10)
                ||'                ELSE 0  '|| CHR(10)
                ||'           END)*(-1) AMOUNT, 0 INTERESTAMOUNT '|| CHR(10)
                ||'           , 0 LN_CAP_DEDUCT, 0 LN_INT_DEDUCT     '|| CHR(10)  
                ||'         FROM PFLOANBREAKUP A,  '|| CHR(10)
                ||'         (  '|| CHR(10)
                ||'             SELECT DISTINCT COMPANYCODE,DIVISIONCODE,PFNO, MAX(LOANDATE) LOANDATE  '|| CHR(10)
                ||'             FROM PFLOANTRANSACTION  '|| CHR(10)
                ||'             WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE ='''||P_DIVCODE||''' '|| CHR(10)
                ||'             AND LOANDATE <=  TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'')  '|| CHR(10)
                ||'            AND LOANTYPE =''REFUNDABLE''                     '|| CHR(10)
                ||'             GROUP BY COMPANYCODE,DIVISIONCODE,PFNO  '|| CHR(10)
                ||'         ) B  '|| CHR(10)
                ||'         WHERE A.COMPANYCODE=B.COMPANYCODE AND A.DIVISIONCODE=B.DIVISIONCODE AND A.PFNO = B.PFNO AND A.LOANDATE = B.LOANDATE  '|| CHR(10)
                ||'         AND A.EFFECTFORTNIGHT <=  TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'')  '|| CHR(10)
                ||'         AND TRANSACTIONTYPE <> ''INTEREST''  '|| CHR(10)
                ||'         UNION ALL  '|| CHR(10)
                ||'         SELECT DISTINCT A.COMPANYCODE,A.DIVISIONCODE,A.PFNO, A.LOANCODE, A.LOANDATE, 0 AMOUNT, SUM(NVL(C.INTERESTAMOUNT,0)) INTERESTAMOUNT '|| CHR(10)
                ||'         , 0 LN_CAP_DEDUCT, 0 LN_INT_DEDUCT  '|| CHR(10)
                ||'         FROM ( SELECT DISTINCT COMPANYCODE,DIVISIONCODE,PFNO, LOANCODE, LOANDATE '|| CHR(10)
                ||'                FROM PFLOANTRANSACTION '|| CHR(10)
                ||'                WHERE COMPANYCODE ='''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''''|| CHR(10)
                ||'              ) A, '|| CHR(10)
                ||'            (  '|| CHR(10)
                ||'                 SELECT DISTINCT COMPANYCODE,DIVISIONCODE,PFNO, MAX(LOANDATE) LOANDATE '|| CHR(10) 
                ||'                FROM PFLOANTRANSACTION  '|| CHR(10)
                ||'                WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '|| CHR(10)
                ||'                AND LOANDATE <=  TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'')  '|| CHR(10)
                ||'                AND LOANTYPE =''REFUNDABLE'''|| CHR(10)
                ||'                GROUP BY COMPANYCODE,DIVISIONCODE,PFNO  '|| CHR(10)
                ||'            ) B, PFLOANINTEREST C  '|| CHR(10)
                ||'         WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' AND A.COMPANYCODE=B.COMPANYCODE AND A.DIVISIONCODE=B.DIVISIONCODE AND A.PFNO = B.PFNO AND A.LOANDATE = B.LOANDATE  '|| CHR(10)
                ||'         AND A.PFNO = C.PFNO AND A.LOANDATE = C.LOANDATE AND A.LOANCODE = C.LOANCODE  '|| CHR(10)
                ||'         AND C.FORTNIGHTENDDATE <= TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'') '|| CHR(10)
                ||'         AND C.TRANSACTIONTYPE = ''ADD''  '|| CHR(10)
                ||'         GROUP BY A.COMPANYCODE,A.DIVISIONCODE,A.PFNO, A.LOANCODE, A.LOANDATE  '|| CHR(10)
                ||'         UNION ALL  '|| CHR(10)
                ||'         SELECT A.COMPANYCODE,A.DIVISIONCODE,A.PFNO, A.LOANCODE, A.LOANDATE, 0 AMOUNT,   '|| CHR(10)
                ||'           (CASE WHEN TRANSACTIONTYPE =''INTEREST'' THEN CASE WHEN EFFECTFORTNIGHT < TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'') THEN AMOUNT ELSE 0 END  '|| CHR(10)
                ||'                WHEN TRANSACTIONTYPE =''REPAY'' THEN REPAYINTEREST  '|| CHR(10)
                ||'                WHEN TRANSACTIONTYPE =''REPAYINT'' THEN AMOUNT  '|| CHR(10)
                ||'                ELSE 0  '|| CHR(10)
                ||'           END)*(-1) INTERESTAMOUNT '|| CHR(10)
                ||'           , 0 LN_CAP_DEDUCT, 0 LN_INT_DEDUCT      '|| CHR(10) 
                ||'         FROM PFLOANBREAKUP A,  '|| CHR(10)
                ||'         (  '|| CHR(10)
                ||'             SELECT DISTINCT COMPANYCODE,DIVISIONCODE,PFNO, MAX(LOANDATE) LOANDATE  '|| CHR(10)
                ||'             FROM PFLOANTRANSACTION  '|| CHR(10)
                ||'             WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '|| CHR(10)
                ||'             AND LOANDATE <=  TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'')  '|| CHR(10)
                ||'             AND LOANTYPE =''REFUNDABLE'''|| CHR(10)
                ||'             GROUP BY COMPANYCODE,DIVISIONCODE,PFNO  '|| CHR(10)
                ||'         ) B  '|| CHR(10)
                ||'         WHERE A.COMPANYCODE=B.COMPANYCODE AND A.DIVISIONCODE=B.DIVISIONCODE AND A.PFNO = B.PFNO AND A.LOANDATE = B.LOANDATE  '|| CHR(10)
                ||'         AND A.EFFECTFORTNIGHT <= TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'') '|| CHR(10) 
                ||'         AND TRANSACTIONTYPE <> ''CAPITAL'' '|| CHR(10)
                ||'         UNION ALL '|| CHR(10)
                ||'         SELECT A.COMPANYCODE,A.DIVISIONCODE,A.PFNO, A.LOANCODE, A.LOANDATE, 0 AMOUNT,  0 INTERESTAMOUNT,  '|| CHR(10)
                ||'         DECODE(TRANSACTIONTYPE,''CAPITAL'',AMOUNT,0) LN_CAP_DEDUCT, DECODE(TRANSACTIONTYPE,''INTEREST'',AMOUNT,0) LN_INT_DEDUCT '|| CHR(10)
                ||'         FROM PFLOANBREAKUP A,  '|| CHR(10)
                ||'         (  '|| CHR(10)
                ||'             SELECT DISTINCT COMPANYCODE,DIVISIONCODE,PFNO, MAX(LOANDATE) LOANDATE  '|| CHR(10)
                ||'             FROM PFLOANTRANSACTION  '|| CHR(10)
                ||'             WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '|| CHR(10)
                ||'             AND LOANDATE <=  TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'') '|| CHR(10)
                ||'             AND LOANTYPE =''REFUNDABLE'''|| CHR(10)
                ||'             GROUP BY COMPANYCODE,DIVISIONCODE,PFNO  '|| CHR(10)
                ||'         ) B  '|| CHR(10)
                ||'         WHERE A.COMPANYCODE=B.COMPANYCODE AND A.DIVISIONCODE=B.DIVISIONCODE AND A.PFNO = B.PFNO AND A.LOANDATE = B.LOANDATE  '|| CHR(10)
                ||'         AND A.EFFECTFORTNIGHT <= TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'')'|| CHR(10)
                ||'         AND TRANSACTIONTYPE IN (''CAPITAL'',''INTEREST'')  '||CHR(10)               
                ||'     ) A, PFEMPLOYEEMASTER B, '||CHR(10)
                ||'     (  '||CHR(10)
                ||'        SELECT M.COMPANYCODE,M.DIVISIONCODE,M.PFNO, M.LOANDATE,  '||CHR(10) 
                ||'        NVL(M.CAPITALINSTALLMENTAMT,0) CAP_EMI,  '||CHR(10)
                ||'        NVL(M.INTERESTINSTALLMENTAMT,0) INT_EMI, NVL(M.TOTALEMIAMOUNT,0) TOT_EMI  '||CHR(10) 
                ||'        FROM PFLOANTRANSACTION M, ( SELECT COMPANYCODE,DIVISIONCODE,PFNO, MAX(LOANDATE) LOANDATE  '||CHR(10)
                ||'                                  FROM PFLOANTRANSACTION  '||CHR(10)
                ||'                                  WHERE LOANDATE <= TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'')  '||CHR(10)
                ||'                                  GROUP BY COMPANYCODE,DIVISIONCODE,PFNO  '||CHR(10)
                ||'                                ) N   '||CHR(10)
                ||'        WHERE M.COMPANYCODE=N.COMPANYCODE AND M.DIVISIONCODE=N.DIVISIONCODE AND M.PFNO = N.PFNO AND M.LOANDATE = N.LOANDATE  '||CHR(10)
                ||'     )  X,   '||CHR(10)         
                ||'     ( '||CHR(10)
                ||'        SELECT DISTINCT COMPANYCODE,DIVISIONCODE,LOANCODE, DEDUCTIONTYPE FROM PFLOANMASTER '||CHR(10) 
                ||'     ) M, '||CHR(10)
                ||'     ( '||chr(10)
                ||'         SELECT COMPANYCODE,DIVISIONCODE,PFNO, WORKERSERIAL, TOKENNO, LOANCODE, LOANDATE, '||chr(10)  
                ||'         LOANSTOPFROMDATE, LOANSTOPTODATE, CAPITAL CAP_STOP, INTEREST INT_STOP, FULLMILL '||chr(10)  
                ||'         FROM PFLOANDEDUCTIONSTOP '||chr(10)
                ||'         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
                ||'           AND LOANSTOPFROMDATE <= TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'') '||chr(10)
                ||'           AND LOANSTOPTODATE >= TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'') '||chr(10)
                ||'           AND NVL(FULLMILL,''N'') <> ''Y'' '||chr(10)
                ||'           AND PFNO IS NOT NULL '||chr(10)     
                ||'     ) Y, '||chr(10)                
                ||'     ( '||CHR(10)
                ||'        SELECT DISTINCT COMPANYCODE,DIVISIONCODE,PFNO, MAX(LOANDATE) LOANDATE, NVL(MAX(DEDUCTIONSTARTDATE),MAX(LOANDATE)) DEDUCTIONSTARTDATE '||CHR(10)   
                ||'        FROM PFLOANTRANSACTION '||CHR(10)  
                ||'        WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)  
                ||'          AND LOANDATE <=  TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'')  '||CHR(10) 
                ||'          AND LOANTYPE =''REFUNDABLE'' '||CHR(10)
                ||'        GROUP BY COMPANYCODE,DIVISIONCODE,PFNO '||CHR(10)            
                ||'     ) Z '||CHR(10)
                ||' WHERE A.COMPANYCODE=B.COMPANYCODE  '||CHR(10)
                ||' AND A.COMPANYCODE=M.COMPANYCODE    '||CHR(10)
                ||' AND A.COMPANYCODE=X.COMPANYCODE    '||CHR(10)
                ||' AND A.COMPANYCODE=Y.COMPANYCODE (+)  '||CHR(10)
                ||' AND A.COMPANYCODE=Z.COMPANYCODE  '||CHR(10)
                ||' AND A.DIVISIONCODE=B.DIVISIONCODE  '||CHR(10)
                ||' AND A.DIVISIONCODE=M.DIVISIONCODE  '||CHR(10)
                ||' AND A.DIVISIONCODE=X.DIVISIONCODE  '||CHR(10)
                ||' AND A.DIVISIONCODE=Y.DIVISIONCODE (+)  '||CHR(10)
                ||' AND A.DIVISIONCODE=Z.DIVISIONCODE  '||CHR(10)
                ||' AND A.PFNO = B.PFNO  '||CHR(10)
                ||'   AND A.PFNO = X.PFNO AND A.LOANDATE = X.LOANDATE '||CHR(10)
                ||'   AND A.LOANCODE = M.LOANCODE '||CHR(10)
                ||'   AND A.PFNO = Z.PFNO AND A.LOANDATE = Z.LOANDATE '||CHR(10)
                ||'   AND A.PFNO = Y.PFNO (+)  '||chr(10) ;     
                IF P_PFNO IS NOT NULL THEN
                    LV_SQLSTR := LV_SQLSTR ||' AND A.PFNO IN ( '''||P_PFNO||''')  '||CHR(10);
                END IF;
    LV_SQLSTR := LV_SQLSTR ||'  GROUP BY B.WORKERSERIAL, B.TOKENNO, A.PFNO, A.LOANCODE, A.LOANDATE, Z.DEDUCTIONSTARTDATE, '||CHR(10)
                           ||'  NVL(X.CAP_EMI,0), NVL(X.INT_EMI,0), NVL(X.TOT_EMI,0), B.MODULE, M.DEDUCTIONTYPE, Y.CAP_STOP, Y.INT_STOP '||CHR(10);
 DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
 EXECUTE IMMEDIATE LV_SQLSTR;
 INSERT INTO GPS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS)
    VALUES (P_COMPCODE,P_DIVCODE,'PROC_PFLOANBLNC',NULL,SYSDATE, LV_SQLSTR, NULL, TO_DATE(P_STARTDATE,'DD/MM/YYYY'), TO_DATE(P_ENDDATE,'DD/MM/YYYY'), 'PF LOAN BALANCE QUERY');  
EXCEPTION
    WHEN OTHERS THEN
 lv_sqlerrm := sqlerrm ;
  insert into GPS_ERROR_LOG(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE, ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
  values( P_COMPCODE,P_DIVCODE,'PROC_PFLOANBLNC',lv_sqlerrm,SYSDATE, LV_SQLSTR,NULL, TO_DATE(P_STARTDATE,'DD/MM/YYYY'), TO_DATE(P_ENDDATE,'DD/MM/YYYY'), 'PF LOAN BALANCE QUERY');
 COMMIT;    
 
END;
/
