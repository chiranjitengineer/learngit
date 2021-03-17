CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_PFSTATUS
(
    P_YEARCODE  VARCHAR2,
    P_COMPCODE  VARCHAR2,
    P_DIVCODE   VARCHAR2,
    P_FROMDATE    VARCHAR2,
    P_TODATE  VARCHAR2,
    P_REPORTOPTION VARCHAR2 DEFAULT 'ALL',
    P_PFNO VARCHAR2 DEFAULT NULL,
    P_MODULE VARCHAR2 DEFAULT 'ALL'
    --P_PERIOD VARCHAR2 DEFAULT NULL
)   
AS


    LV_PAIDON    VARCHAR2(20);
    LV_LOANDATE  VARCHAR2(20);
    LV_PFSETTLEMENTDATE VARCHAR2(20);

    LV_SQLSTR VARCHAR2 (20000);
BEGIN
    DELETE FROM GTT_PFSTATUS;
    
    LV_PAIDON := P_TODATE;
    LV_LOANDATE := P_TODATE;
    LV_PFSETTLEMENTDATE := P_TODATE;
    
    LV_SQLSTR := ' INSERT INTO GTT_PFSTATUS '|| CHR(10)
    || 'SELECT '''|| P_YEARCODE ||''' YEARCODE, A.PFNO, B.EMPLOYEENAME, D.COMPANYNAME, E.DIVISIONNAME, ' || CHR(10)
    ||      'SUM(OB_PF_E) OB_PF_E, SUM(OB_PF_C) OB_PF_C, SUM(OB_VPF) OB_VPF,' || CHR(10)
    ||      'SUM(LN_PF_E) LN_PF_E, SUM(LN_PF_C) LN_PF_C, SUM(LN_VPF) LN_VPF, ' || CHR(10)
    ||      'SUM(SAL_PF_E) CONT_PF_E, SUM(SAL_PF_C) CONT_PF_C, SUM(SAL_VPF) CONT_VPF,' || CHR(10) 
    ||      'SUM(INT_PF_E) INT_PF_E, SUM(INT_PF_C) INT_PF_C, SUM(INT_VPF) INT_VPF,' || CHR(10)  
    ||      'SUM(CB_PF_E)+ SUM(INT_PF_E) CB_PF_E, SUM(CB_PF_C) + SUM(INT_PF_C) CB_PF_C, SUM(CB_VPF) + SUM(INT_VPF) CB_VPF,' || CHR(10) 
    ||      'B.PFSETTLEMENTDATE ,C.LOANBALANCE, ' || CHR(10)
    ||      'F.PFBALANCE, F.OTHEREARNING, F.PFLOANCAPITALBAL, F.PFLOANINTERESTBAL, F.OTHERDEDUCTION , F.NETPAYABLE AS SETTLEMENTAMOUNT , ''As on ' || LV_LOANDATE || ''', B.TOKENNO' || CHR(10)
    ||'FROM (' || CHR(10) 
    ||      'SELECT PFNO,' || CHR(10)    
    ||      'CASE WHEN TRANSACTIONTYPE = ''PF INTEREST OPENING BALANCE'' AND COMPONENTCODE = ''PF_E'' THEN NVL(COMPONENTAMOUNT,0) ELSE 0 END  OB_PF_E,' || CHR(10) 
    ||      'CASE WHEN TRANSACTIONTYPE = ''PF INTEREST OPENING BALANCE'' AND COMPONENTCODE = ''PF_C'' THEN NVL(COMPONENTAMOUNT,0) ELSE 0 END  OB_PF_C,' || CHR(10) 
    ||      'CASE WHEN TRANSACTIONTYPE = ''PF INTEREST OPENING BALANCE'' AND COMPONENTCODE = ''VPF'' THEN NVL(COMPONENTAMOUNT,0) ELSE 0 END  OB_VPF,' || CHR(10) 
    ||      '0  LN_PF_E,' || CHR(10) 
    ||      '0  LN_PF_C,' || CHR(10) 
    ||      '0  LN_VPF,' || CHR(10)         
    ||      '0  SAL_PF_E,' || CHR(10) 
    ||      '0  SAL_PF_C,' || CHR(10) 
    ||      '0  SAL_VPF,' || CHR(10) 
    ||      'CASE WHEN TRANSACTIONTYPE = ''PF INTEREST CALCULATION'' AND COMPONENTCODE = ''PF_E'' THEN NVL(INT_AMT,0) ELSE 0 END  INT_PF_E,' || CHR(10) 
    ||      'CASE WHEN TRANSACTIONTYPE = ''PF INTEREST CALCULATION'' AND COMPONENTCODE = ''PF_C'' THEN NVL(INT_AMT,0) ELSE 0 END  INT_PF_C,' || CHR(10) 
    ||      'CASE WHEN TRANSACTIONTYPE = ''PF INTEREST CALCULATION'' AND COMPONENTCODE = ''VPF'' THEN NVL(INT_AMT,0) ELSE 0 END  INT_VPF,' || CHR(10) 
    ||      '0  CB_PF_E,' || CHR(10) 
    ||      '0  CB_PF_C,' || CHR(10) 
    ||      '0  CB_VPF' || CHR(10) 
    ||      'FROM PFTRANSACTIONDETAILS' || CHR(10) 
    ||      'WHERE YEARCODE = '''|| P_YEARCODE || ''' ' || CHR(10); 
        IF P_PFNO IS NOT NULL THEN  
            LV_SQLSTR := LV_SQLSTR || 'AND PFNO = '''|| P_PFNO ||''' ' || CHR(10);
        END IF;
        IF P_MODULE <>'ALL' THEN  
            LV_SQLSTR := LV_SQLSTR || 'AND MODULE = '''|| P_MODULE ||''' ' || CHR(10);
        END IF;
        
       LV_SQLSTR := LV_SQLSTR ||      'UNION ALL' || CHR(10)    
    ||      'SELECT PFNO,' || CHR(10)    
    ||      'CASE WHEN TRANSACTIONTYPE = ''SALARY'' AND COMPONENTCODE = ''PF_E'' THEN NVL(COMPONENTAMOUNT,0) ELSE 0 END  OB_PF_E,' || CHR(10) 
    ||      'CASE WHEN TRANSACTIONTYPE = ''SALARY'' AND COMPONENTCODE = ''PF_C'' THEN NVL(COMPONENTAMOUNT,0) ELSE 0 END  OB_PF_C,' || CHR(10) 
    ||      'CASE WHEN TRANSACTIONTYPE = ''SALARY'' AND COMPONENTCODE = ''VPF'' THEN NVL(COMPONENTAMOUNT,0) ELSE 0 END  OB_VPF,' || CHR(10) 
    ||      'CASE WHEN TRANSACTIONTYPE = ''LOAN'' AND COMPONENTCODE = ''PF_E'' THEN NVL(COMPONENTAMOUNT,0) ELSE 0 END  LN_PF_E,' || CHR(10) 
    ||      'CASE WHEN TRANSACTIONTYPE = ''LOAN'' AND COMPONENTCODE = ''PF_C'' THEN NVL(COMPONENTAMOUNT,0) ELSE 0 END  LN_PF_C,' || CHR(10) 
    ||      'CASE WHEN TRANSACTIONTYPE = ''LOAN'' AND COMPONENTCODE = ''VPF'' THEN NVL(COMPONENTAMOUNT,0) ELSE 0 END  LN_VPF,' || CHR(10)         
    ||      '0  SAL_PF_E,' || CHR(10) 
    ||      '0  SAL_PF_C,' || CHR(10) 
    ||      '0  SAL_VPF,' || CHR(10) 
    ||      '0  INT_PF_E,' || CHR(10) 
    ||      '0  INT_PF_C,' || CHR(10) 
    ||      '0  INT_VPF,' || CHR(10) 
    ||      'CASE WHEN TRANSACTIONTYPE <> ''PF INTEREST CALCULATION'' AND COMPONENTCODE = ''PF_E'' THEN NVL(COMPONENTAMOUNT,0) ELSE 0 END  CB_PF_E,' || CHR(10) 
    ||      'CASE WHEN TRANSACTIONTYPE <> ''PF INTEREST CALCULATION'' AND COMPONENTCODE = ''PF_C'' THEN NVL(COMPONENTAMOUNT,0) ELSE 0 END  CB_PF_C,' || CHR(10) 
    ||      'CASE WHEN TRANSACTIONTYPE <> ''PF INTEREST CALCULATION'' AND COMPONENTCODE = ''VPF'' THEN NVL(COMPONENTAMOUNT,0) ELSE 0 END  CB_VPF' || CHR(10) 
    ||      'FROM PFTRANSACTIONDETAILS' || CHR(10) 
    ||      'WHERE YEARCODE = '''|| P_YEARCODE || ''' ' || CHR(10) 
    ||      '  AND STARTDATE <TO_DATE(''' || P_FROMDATE ||''',''DD/MM/YYYY'') ' || CHR(10); 
    
        IF P_PFNO IS NOT NULL THEN  
            LV_SQLSTR := LV_SQLSTR || 'AND PFNO = '''|| P_PFNO ||''' ' || CHR(10);
        END IF;
        IF P_MODULE <>'ALL' THEN  
            LV_SQLSTR := LV_SQLSTR || 'AND MODULE = '''|| P_MODULE ||''' ' || CHR(10);
        END IF;
        
       LV_SQLSTR := LV_SQLSTR ||      'UNION ALL' || CHR(10)    
    ||      'SELECT PFNO,' || CHR(10)    
    ||      '0  OB_PF_E,' || CHR(10) 
    ||      '0  OB_PF_C,' || CHR(10) 
    ||      '0  OB_VPF,' || CHR(10) 
    ||      'CASE WHEN TRANSACTIONTYPE = ''LOAN'' AND COMPONENTCODE = ''PF_E'' THEN NVL(COMPONENTAMOUNT,0) ELSE 0 END  LN_PF_E,' || CHR(10) 
    ||      'CASE WHEN TRANSACTIONTYPE = ''LOAN'' AND COMPONENTCODE = ''PF_C'' THEN NVL(COMPONENTAMOUNT,0) ELSE 0 END  LN_PF_C,' || CHR(10) 
    ||      'CASE WHEN TRANSACTIONTYPE = ''LOAN'' AND COMPONENTCODE = ''VPF'' THEN NVL(COMPONENTAMOUNT,0) ELSE 0 END  LN_VPF,' || CHR(10)         
    ||      'CASE WHEN TRANSACTIONTYPE = ''SALARY'' AND COMPONENTCODE = ''PF_E'' THEN NVL(COMPONENTAMOUNT,0) ELSE 0 END  SAL_PF_E,' || CHR(10) 
    ||      'CASE WHEN TRANSACTIONTYPE = ''SALARY'' AND COMPONENTCODE = ''PF_C'' THEN NVL(COMPONENTAMOUNT,0) ELSE 0 END  SAL_PF_C,' || CHR(10) 
    ||      'CASE WHEN TRANSACTIONTYPE = ''SALARY'' AND COMPONENTCODE = ''VPF'' THEN NVL(COMPONENTAMOUNT,0) ELSE 0 END  SAL_VPF,' || CHR(10) 
    ||      '0  INT_PF_E,' || CHR(10) 
    ||      '0  INT_PF_C,' || CHR(10) 
    ||      '0  INT_VPF,' || CHR(10) 
    ||      'CASE WHEN TRANSACTIONTYPE <> ''PF INTEREST CALCULATION'' AND COMPONENTCODE = ''PF_E'' THEN NVL(COMPONENTAMOUNT,0) ELSE 0 END  CB_PF_E,' || CHR(10) 
    ||      'CASE WHEN TRANSACTIONTYPE <> ''PF INTEREST CALCULATION'' AND COMPONENTCODE = ''PF_C'' THEN NVL(COMPONENTAMOUNT,0) ELSE 0 END  CB_PF_C,' || CHR(10) 
    ||      'CASE WHEN TRANSACTIONTYPE <> ''PF INTEREST CALCULATION'' AND COMPONENTCODE = ''VPF'' THEN NVL(COMPONENTAMOUNT,0) ELSE 0 END  CB_VPF' || CHR(10) 
    ||      'FROM PFTRANSACTIONDETAILS' || CHR(10) 
    ||      'WHERE YEARCODE = '''|| P_YEARCODE || ''' ' || CHR(10) 
    ||      '  AND STARTDATE >=TO_DATE(''' || P_FROMDATE ||''',''DD/MM/YYYY'') ' || CHR(10) 
    ||      '  AND ENDDATE <=TO_DATE(''' || P_TODATE ||''',''DD/MM/YYYY'') ' || CHR(10); 
    
        IF P_PFNO IS NOT NULL THEN  
            LV_SQLSTR := LV_SQLSTR || 'AND PFNO = '''|| P_PFNO ||''' ' || CHR(10);
        END IF;
        IF P_MODULE <>'ALL' THEN  
            LV_SQLSTR := LV_SQLSTR || 'AND MODULE = '''|| P_MODULE ||''' ' || CHR(10);
        END IF;        
        
        LV_SQLSTR := LV_SQLSTR ||  ') A, PFEMPLOYEEMASTER B, COMPANYMAST D, DIVISIONMASTER E, ' || CHR(10)
    ||    '( ' || CHR(10)
    ||      'SELECT A.PFNO,A.LOANCODE,A.LOANDATE,A.AMOUNT LOAN_AMT,B.AMOUNT REALISE_AMT,NVL(A.AMOUNT,0) - NVL(B.AMOUNT,0) LOANBALANCE ' || CHR(10) 
    ||      'FROM ' || CHR(10) 
    ||      '(' || CHR(10) 
    ||          'SELECT PFNO, LOANCODE, LOANDATE, CASE WHEN NVL(CAPITALBALANCEAMOUNT,0) > NVL(AMOUNT,0) THEN CAPITALBALANCEAMOUNT ELSE AMOUNT END AMOUNT  ' || CHR(10) 
    ||            'FROM PFLOANTRANSACTION ' || CHR(10) 
    ||             'WHERE COMPANYCODE = ''' || P_COMPCODE ||''' ' || CHR(10)
    ||              'AND DIVISIONCODE = '''||P_DIVCODE ||'''  ' || CHR(10)
    ||        ') A, ' || CHR(10)
    ||      '( ' || CHR(10) 
    ||          'SELECT PFNO,LOANCODE,LOANDATE, ' || CHR(10) 
    /*||                 'SUM(CASE WHEN TRANSACTIONTYPE IN (''REPAYCAP'',''REPAYINT'') THEN AMOUNT ELSE DEDUCTEDAMT END) AS AMOUNT ' || CHR(10)*/ 
    --||                  'SUM(CASE WHEN TRANSACTIONTYPE IN (''CAPITAL'', ''REPAYCAP'',''REPAYINT'', ''INTEREST'') THEN AMOUNT ELSE NVL(REPAYCAPITAL,0) + nvl(REPAYINTEREST,0) END) AS AMOUNT'  || CHR(10)  
    ||                  'SUM(CASE WHEN TRANSACTIONTYPE IN (''CAPITAL'', ''REPAYCAP'') THEN AMOUNT ELSE NVL(REPAYCAPITAL,0) END) AS AMOUNT'  || CHR(10)  
    ||            'FROM PFLOANBREAKUP' || CHR(10)
    ||             'WHERE COMPANYCODE = ''' || P_COMPCODE ||''' ' || CHR(10)
    ||              'AND DIVISIONCODE = '''||P_DIVCODE ||'''  ' || CHR(10)
    ||              'AND PAIDON <= TO_DATE(''' || LV_PAIDON || ''',''DD/MM/YYYY'') ' || CHR(10)
    ||           'GROUP BY PFNO,LOANCODE,LOANDATE   ' || CHR(10)
    ||        ') B,   ' || CHR(10)
    ||        '( ' || CHR(10)
    ||           'SELECT LOANCODE ' || CHR(10)
    ||           '  FROM PFLOANMASTER ' || CHR(10)
    ||           ' WHERE COMPANYCODE = ''' || P_COMPCODE ||''' ' || CHR(10)
    ||           '   AND DIVISIONCODE = '''||P_DIVCODE ||''' ' || CHR(10)
    ||           '   AND REFUNDTYPE = ''REFUNDABLE'' ' || CHR(10)
    ||        ') C ' || CHR(10)
    ||     'WHERE A.PFNO = B.PFNO (+) ' || CHR(10) 
    ||        'AND A.LOANCODE = B.LOANCODE (+) ' || CHR(10)  
    ||        'AND A.LOANDATE = B.LOANDATE (+) ' || CHR(10) 
    ||        'AND A.LOANCODE = C.LOANCODE ' || CHR(10)
    ||        'AND A.LOANDATE = ( ' || CHR(10) 
    ||                             ' SELECT MAX(LOANDATE) ' || CHR(10) 
    ||                              'FROM PFLOANTRANSACTION ' || CHR(10) 
    ||                              'WHERE PFNO = A.PFNO ' || CHR(10) 
    ||                              'AND LOANCODE = A.LOANCODE ' || CHR(10) 
    ||                              'AND LOANDATE <= TO_DATE(''' || LV_LOANDATE || ''',''DD/MM/YYYY'') ' || CHR(10)
    ||                          ')    ' || CHR(10)
    ||    ') C , ' || CHR(10)
    ||    '( ' || CHR(10)
    ||    'SELECT COMPANYCODE, DIVISIONCODE, YEARCODE, PFNO, NVL(PFBALANCE,0) PFBALANCE, NVL(OTHEREARNING,0) OTHEREARNING, ' || CHR(10) 
    ||    '     NVL(PFLOANCAPITALBAL,0) PFLOANCAPITALBAL , NVL(PFLOANINTERESTBAL,0) PFLOANINTERESTBAL,  ' || CHR(10)
    ||    '     NVL(OTHERDEDUCTION,0) OTHERDEDUCTION , NVL(NETPAYABLE,0) NETPAYABLE ' || CHR(10)
    ||    '  FROM PFSETTLEMENT ' || CHR(10)
    ||    ' WHERE COMPANYCODE = ''' || P_COMPCODE ||''' ' || CHR(10)
    ||    '   AND DIVISIONCODE  = '''||P_DIVCODE ||''' ' || CHR(10)
    ||    ')F ' || CHR(10)
    || 'WHERE A.PFNO = B.PFNO ' || CHR(10) ;
    
    

    IF P_REPORTOPTION ='ACTIVE' THEN
        LV_SQLSTR := LV_SQLSTR ||'   AND (B.PFSETTLEMENTDATE  IS NULL  OR B.PFSETTLEMENTDATE > TO_DATE(''' || P_TODATE || ''',''DD/MM/YYYY'') )'|| CHR(10);
    ELSIF P_REPORTOPTION ='PF SETTLED' THEN
    
        LV_SQLSTR := LV_SQLSTR ||'   AND B.PFSETTLEMENTDATE  BETWEEN TO_DATE( ''' || P_FROMDATE || ''',''DD/MM/YYYY'') AND TO_DATE(''' || P_TODATE || ''',''DD/MM/YYYY'') '|| CHR(10);
    
    END IF;
    
        
--    || 'AND (B.PFSETTLEMENTDATE is null or B.PFSETTLEMENTDATE >= TO_DATE(''' || LV_PFSETTLEMENTDATE ||''',''DD/MM/YYYY'')) ' || CHR(10)
    LV_SQLSTR := LV_SQLSTR  || 'AND A.PFNO = C.PFNO (+) ' || CHR(10)
    
    
    
    --|| 'AND B.COMPANYCODE = C.PFNO (+) ' || CHR(10)
    || 'AND B.COMPANYCODE ='''|| P_COMPCODE ||''' '||CHR(10)
    || 'AND B.DIVISIONCODE ='''|| P_DIVCODE ||''' '||CHR(10)
    || 'AND B.COMPANYCODE = D.COMPANYCODE ' || CHR(10)
    || 'AND B.DIVISIONCODE = E.DIVISIONCODE ' || CHR(10)
    || 'AND B.COMPANYCODE = E.COMPANYCODE ' || CHR(10)
    || 'AND B.COMPANYCODE = F.COMPANYCODE (+) ' || CHR(10)
    || 'AND B.DIVISIONCODE = F.DIVISIONCODE  (+)' || CHR(10) 
    || 'AND B.PFNO = F.PFNO (+)  ' || CHR(10)
    || 'GROUP BY A.PFNO, B.EMPLOYEENAME, B.PFSETTLEMENTDATE ,C.LOANBALANCE, D.COMPANYNAME, E.DIVISIONNAME ,F.PFBALANCE, F.OTHEREARNING, F.PFLOANCAPITALBAL,' || CHR(10)
    || '         F.PFLOANINTERESTBAL, F.OTHERDEDUCTION , F.NETPAYABLE , B.TOKENNO' || CHR(10)
    || 'ORDER BY A.PFNO ' || CHR(10) ;
   DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
    EXECUTE IMMEDIATE LV_SQLSTR;
    
END;
/