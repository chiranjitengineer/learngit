CREATE OR REPLACE PROCEDURE JOONK.PROC_REP_PISPAYSLIP
(
    p_companycode varchar2,
    p_divisioncode varchar2,
    p_yearmonth varchar2,   
    p_unitcode varchar2,
    p_categorycode varchar2,
    p_gradecode varchar2,
    p_workerserial varchar2,
    p_yearcode varchar2,  
    p_transtype varchar2 default 'SALARY'  
)
AS
    lv_sql varchar2(10000);
    lv_qry varchar2(500);
    lv_columns varchar2(500);
    LV_PAYTRANSTABLE varchar2(30);
    
    LV_transtype varchar2(30);


BEGIN
    DELETE FROM GTT_PISPAYSLIP ;
    
    LV_transtype := TRIM(p_transtype);
    
    IF LV_transtype = 'ARREAR' THEN
        LV_PAYTRANSTABLE := 'PISARREARTRANSACTION';
    ELSE
        LV_PAYTRANSTABLE := 'PISPAYTRANSACTION';
    END IF;
    ----------- TAG A----------------------------
    
    execute immediate 'SELECT LISTAGG(COMPONENTCODE,'','') '|| chr(10)
    || 'WITHIN GROUP ( ORDER BY PHASE, CALCULATIONINDEX) EARNING  '|| chr(10)
    || 'FROM PISCOMPONENTMASTER '|| chr(10)
    || 'WHERE COMPONENTTYPE=''EARNING'' '|| chr(10)
    || 'AND PHASE IS NOT NULL '|| chr(10)
    || 'ORDER BY CALCULATIONINDEX '|| chr(10)
    into lv_columns;
        
    lv_sql:= 'INSERT INTO GTT_PISPAYSLIP(TAG,COMPANYCODE,DIVISIONCODE,UNITCODE,CATEGORYCODE,GRADECODE, WORKERSERIAL, TOKENNO,YEARMONTH , EARNINGS,EARNINGSAMOUNT,EX2) '|| chr(10) 
    || ' SELECT ''A'' TAG,AA.COMPANYCODE,AA.DIVISIONCODE,AA.UNITCODE,AA.CATEGORYCODE,AA.GRADECODE,AA.WORKERSERIAL,AA.TOKENNO, '|| chr(10) 
    || 'AA.YEARMONTH,BB.COMPONENTSHORTNAME EARNINGS,AA.EARNINGSAMOUNT,BB.CALCULATIONINDEX  FROM '|| chr(10) 
    || '( '|| chr(10) 
    || 'SELECT COMPANYCODE,DIVISIONCODE,UNITCODE,CATEGORYCODE,GRADECODE, WORKERSERIAL, TOKENNO,YEARMONTH , EARNINGS,EARNINGSAMOUNT '|| chr(10) 
    || 'FROM '||LV_PAYTRANSTABLE|| chr(10) 
    || 'UNPIVOT(EARNINGSAMOUNT FOR EARNINGS IN ( '||lv_columns||') '|| chr(10) 
    || ') '|| chr(10) 
    || 'WHERE COMPANYCODE='''||p_companycode||''' '|| chr(10) 
    || 'AND DIVISIONCODE='''||p_divisioncode||''' '|| chr(10) 
    || 'AND YEARMONTH='''||p_yearmonth||''' '|| chr(10);  
    
        
    
  
    IF LV_transtype IS NOT NULL THEN
        lv_sql := lv_sql || 'AND TRANSACTIONTYPE='''||LV_transtype||''''|| chr(10);
    END IF;
    
    if (nvl(p_unitcode,'NA') <>'NA') then
        lv_sql := lv_sql || 'AND UNITCODE IN( '||p_unitcode||' ) '|| chr(10);
    end if;  
        
    if (nvl(p_categorycode,'NA') <>'NA') then
        lv_sql := lv_sql || 'AND CATEGORYCODE IN( '||p_categorycode||' ) '|| chr(10);
    end if;
        
    if (nvl(p_gradecode,'NA') <>'NA') then
        lv_sql := lv_sql || 'AND GRADECODE IN( '||p_gradecode||' ) '|| chr(10);
    end if;
        
    if(nvl(p_workerserial,'NA') <>'NA')  THEN
        lv_sql := lv_sql || 'AND WORKERSERIAL IN( '||p_workerserial||' ) '|| chr(10);
    end if ; 
    
    lv_sql := lv_sql || ') AA,PISCOMPONENTMASTER BB '|| chr(10)
    || 'WHERE AA.EARNINGS=BB.COMPONENTCODE '|| chr(10)
    || 'ORDER BY BB.CALCULATIONINDEX '|| chr(10);
           
    --lv_sql:=lv_sql ||  'ORDER BY EARNINGS '|| chr(10);
    
    
--    dbms_output.put_line(lv_sql);
    execute immediate lv_sql;
    
     ----------- TAG B----------------------------
         
    lv_sql:='';
    lv_columns:='';
    
    execute immediate 'SELECT LISTAGG(COMPONENTCODE,'','') '|| chr(10)   
    || 'WITHIN GROUP ( ORDER BY PHASE, CALCULATIONINDEX) DEDUCTION '|| chr(10) 
    || 'FROM PISCOMPONENTMASTER '|| chr(10) 
    || 'WHERE COMPONENTTYPE=''DEDUCTION'' '|| chr(10) 
    || 'AND PHASE IS NOT NULL '|| chr(10)
    || 'ORDER BY CALCULATIONINDEX '|| chr(10)
    into lv_columns;
    
    
    lv_sql:= 'INSERT INTO GTT_PISPAYSLIP(TAG,COMPANYCODE,DIVISIONCODE,UNITCODE,CATEGORYCODE,GRADECODE, WORKERSERIAL, TOKENNO,YEARMONTH , DEDUCTIONS,DEDUCTIONSAMOUNT,EX2) '|| chr(10)  
    || 'SELECT ''B'' TAG,AA.COMPANYCODE,AA.DIVISIONCODE,AA.UNITCODE,AA.CATEGORYCODE,AA.GRADECODE,AA.WORKERSERIAL,AA.TOKENNO, '|| chr(10) 
    || 'AA.YEARMONTH,BB.COMPONENTSHORTNAME DEDUCTIONS,AA.DEDUCTIONSAMOUNT,BB.CALCULATIONINDEX  FROM '|| chr(10) 
    || '( '|| chr(10) 
    || 'SELECT COMPANYCODE,DIVISIONCODE,UNITCODE,CATEGORYCODE,GRADECODE, WORKERSERIAL,TOKENNO,YEARMONTH , DEDUCTIONS,DEDUCTIONSAMOUNT '|| chr(10) 
    || 'FROM '||LV_PAYTRANSTABLE|| chr(10) 
    || 'UNPIVOT(DEDUCTIONSAMOUNT FOR DEDUCTIONS IN ('||lv_columns||') '|| chr(10) 
    || ') '|| chr(10) 
    || 'WHERE COMPANYCODE='''||p_companycode||''' '|| chr(10)   
    || 'AND DIVISIONCODE='''||p_divisioncode||''' '|| chr(10) 
    || 'AND YEARMONTH='''||p_yearmonth||''' '|| chr(10); 
    
  
    IF LV_transtype IS NOT NULL THEN
        lv_sql := lv_sql || 'AND TRANSACTIONTYPE='''||LV_transtype||''''|| chr(10);
    END IF;
    
    
    if (nvl(p_unitcode,'NA') <>'NA') then
        lv_sql := lv_sql || 'AND UNITCODE IN( '||p_unitcode||' ) '|| chr(10);
    end if;  
        
    if (nvl(p_categorycode,'NA') <>'NA') then
        lv_sql := lv_sql || 'AND CATEGORYCODE IN( '||p_categorycode||' ) '|| chr(10);
    end if;
        
    if (nvl(p_gradecode,'NA') <>'NA') then
        lv_sql := lv_sql || 'AND GRADECODE IN( '||p_gradecode||' ) '|| chr(10);
    end if;
        
    if(nvl(p_workerserial,'NA') <>'NA')  THEN
        lv_sql := lv_sql || 'AND WORKERSERIAL IN( '||p_workerserial||' ) '|| chr(10);
    end if ;             
    lv_sql := lv_sql || ') AA,PISCOMPONENTMASTER BB '|| chr(10) 
    || 'WHERE AA.DEDUCTIONS=BB.COMPONENTCODE '|| chr(10) 
     || 'ORDER BY BB.CALCULATIONINDEX '|| chr(10);
--    || 'ORDER BY BB.PHASE,BB.CALCULATIONINDEX '|| chr(10);
     
    --lv_sql:=lv_sql|| 'ORDER BY DEDUCTIONS '|| chr(10);
    
--    dbms_output.put_line(lv_sql);
    execute immediate lv_sql;
    
    
     ----------- TAG C----------------------------
    lv_sql:='';
    lv_columns:='';
    
    lv_sql:= 'INSERT INTO GTT_PISPAYSLIP(TAG,COMPANYCODE,DIVISIONCODE,YEARMONTH, P_O_E_R,P_O_E_R_AMOUNT) '|| chr(10)  
    ||  'VALUES(''C'','''||p_companycode||''','''||p_divisioncode||''','''||p_yearmonth||''',''Exemption U/S 10'',0) '|| chr(10);  
    
    --dbms_output.put_line(lv_sql);
    --execute immediate lv_sql;
    
    lv_sql:= 'INSERT INTO GTT_PISPAYSLIP(TAG,COMPANYCODE,DIVISIONCODE,YEARMONTH, P_O_E_R,P_O_E_R_AMOUNT) '|| chr(10)  
    ||  'VALUES(''C'','''||p_companycode||''','''||p_divisioncode||''','''||p_yearmonth||''',''Agg of Chapter vr'',0) '|| chr(10);  
    
    --dbms_output.put_line(lv_sql);
    --execute immediate lv_sql;
    
    ----------- TAG D----------------------------
    lv_sql:='';
    lv_columns:='';
    
    execute immediate 'SELECT LISTAGG(COMPONENTCODE,'','')  '|| chr(10) 
    || 'WITHIN GROUP ( ORDER BY PHASE, CALCULATIONINDEX) EARNING '|| chr(10)
    ||  'FROM PISCOMPONENTMASTER '|| chr(10)
    ||  'WHERE COMPONENTCODE LIKE ''LNBL_%'' '|| chr(10)
    into lv_columns;
    
    
    lv_sql:= 'INSERT INTO GTT_PISPAYSLIP(TAG,COMPANYCODE,DIVISIONCODE,UNITCODE,CATEGORYCODE,GRADECODE, WORKERSERIAL, TOKENNO,YEARMONTH , BALANCE,BALANCEAMOUNT,EX2) '|| chr(10)  
    || 'SELECT ''D'' TAG,AA.COMPANYCODE,AA.DIVISIONCODE,AA.UNITCODE,AA.CATEGORYCODE,AA.GRADECODE,AA.WORKERSERIAL,AA.TOKENNO, '|| chr(10)
    || 'AA.YEARMONTH,BB.COMPONENTSHORTNAME BALANCE,AA.BALANCEAMOUNT,BB.CALCULATIONINDEX  FROM '|| chr(10)
    || '( '|| chr(10)
    || 'SELECT COMPANYCODE,DIVISIONCODE,UNITCODE,CATEGORYCODE,GRADECODE, WORKERSERIAL,TOKENNO,YEARMONTH , BALANCE,BALANCEAMOUNT '|| chr(10)
    || 'FROM '||LV_PAYTRANSTABLE|| chr(10)
    || 'UNPIVOT(BALANCEAMOUNT FOR BALANCE IN ( LNBL_CRLN,LNBL_HSLN,LNBL_SADV) '|| chr(10)
    || ') '|| chr(10)   
    || 'WHERE COMPANYCODE='''||p_companycode||''' '|| chr(10)   
    || 'AND DIVISIONCODE='''||p_divisioncode||''' '|| chr(10) 
    || 'AND YEARMONTH='''||p_yearmonth||''' '|| chr(10);  
    
  
    IF LV_transtype IS NOT NULL THEN
        lv_sql := lv_sql || 'AND TRANSACTIONTYPE='''||LV_transtype||''''|| chr(10);
    END IF;
    
    if (nvl(p_unitcode,'NA') <>'NA') then
        lv_sql := lv_sql || 'AND UNITCODE IN( '||p_unitcode||' ) '|| chr(10);
    end if;  
        
    if (nvl(p_categorycode,'NA') <>'NA') then
        lv_sql := lv_sql || 'AND CATEGORYCODE IN( '||p_categorycode||' ) '|| chr(10);
    end if;
        
    if (nvl(p_gradecode,'NA') <>'NA') then
        lv_sql := lv_sql || 'AND GRADECODE IN( '||p_gradecode||' ) '|| chr(10);
    end if;
        
    if(nvl(p_workerserial,'NA') <>'NA')  THEN
        lv_sql := lv_sql || 'AND WORKERSERIAL IN( '||p_workerserial||' ) '|| chr(10);
    end if ;             
    
    lv_sql := lv_sql || ') AA,PISCOMPONENTMASTER BB '|| chr(10)
    || 'WHERE AA.BALANCE=BB.COMPONENTCODE '|| chr(10)
    || 'ORDER BY BB.CALCULATIONINDEX '|| chr(10);
--       || 'ORDER BY BB.PHASE,BB.CALCULATIONINDEX '|| chr(10);

    --lv_sql:=lv_sql|| 'ORDER BY BALANCE '|| chr(10);
    
--    dbms_output.put_line(lv_sql);
    execute immediate lv_sql;
    
    ----------- UPDATE TABLE ----------------------------
    
    lv_sql:='';
    lv_columns:='';
    
    lv_sql:= 'UPDATE GTT_PISPAYSLIP AAA SET (COMPANYCODE,COMPANYNAME ,DIVISIONCODE,DIVISIONNAME,UNITCODE, UNITNAME,CATEGORYCODE,CATEGORYDESC , '|| chr(10)
    || 'WORKERSERIAL,TOKENNO, EMPLOYEENAME,DESIGNATIONCODE,DESIGNATIONDESC,GRADECODE,GRADEDESC,PFNO,UANNO,ESINO, '|| chr(10)
    || 'PANCARDNO,PAYROLLNO,SALARY_MONTH, '|| chr(10)
    || 'DATEOFJOIN,DATEOFRETIRE,PAYROLL_TYPE,SALARY_DAYS,LEAVE_WITH_PAY, '|| chr(10)
    || 'LEAVE_WITHOUT_PAY,TRANSFER_DATE,BANKDESC,BANKACCNUMBER,TRANSFERRED_AMT,TOTAL_EARN, '|| chr(10)
    || 'TOTAL_DEDUCTION,NET_PAYABLE,PL_CB_CL, CB_SL,CB,LWP_CURRENT_MONTH,RVRSL_PRV_MONTH, '|| chr(10)
    || 'TOTAL_ADJSTMNT_AMT, CAL) = '|| chr(10)
    || '(SELECT A.COMPANYCODE,D.COMPANYNAME ,A.DIVISIONCODE,E.DIVISIONNAME,G.UNITCODE, I.UNITNAME,A.CATEGORYCODE,H.CATEGORYDESC , '|| chr(10)
    || 'A.WORKERSERIAL,A.TOKENNO, A.EMPLOYEENAME,A.DESIGNATIONCODE,B.DESIGNATIONDESC,A.GRADECODE,C.GRADEDESC,A.PFNO,A.UANNO,A.ESINO, '|| chr(10)
    || 'A.PANCARDNO,'''' PAYROLLNO , TO_CHAR(TO_DATE(''01''||''/''||SUBSTR(G.YEARMONTH, 5, 6) ||''/''|| SUBSTR(G.YEARMONTH,1,4),''dd/MM/yyyy''),''MON-YY'') SALARY_MONTH, '|| chr(10)
    || 'TO_CHAR(A.DATEOFJOIN,''dd/MM/yyyy''),TO_CHAR(A.DATEOFRETIRE,''dd/MM/yyyy''),''MONTHLY PY (IND)'' PAYROLL_TYPE,NVL(G.ATTN_SALD,0) SALARY_DAYS,NVL(G.ATTN_LDAY,0) LEAVE_WITH_PAY, '|| chr(10)
   -- || 'NVL(G.ATTN_WPAY,0) LEAVE_WITHOUT_PAY,TO_CHAR(LAST_DAY(TO_DATE(YEARMONTH,''YYYYMM'')),''DD/MM/YYYY'') TRANSFER_DATE,F.BANKDESC,A.BANKACCNUMBER,0 TRANSFERRED_AMT,NVL(G.GROSSEARN,0) TOTAL_EARN, '|| chr(10)
    || 'NVL(G.ATTN_WPAY,0) LEAVE_WITHOUT_PAY,TO_CHAR(NVL(G.PAYMENTDATE,LAST_DAY(TO_DATE(YEARMONTH,''YYYYMM''))),''DD/MM/YYYY'') TRANSFER_DATE,F.BANKDESC,A.BANKACCNUMBER,0 TRANSFERRED_AMT,NVL(G.GROSSEARN,0) TOTAL_EARN, '|| chr(10)
    || 'NVL(G.GROSSDEDN,0) TOTAL_DEDUCTION,NVL(G.NETSALARY,0) NET_PAYABLE,0 PL_CB_CL, 0 CB_SL,0 CB,0 LWP_CURRENT_MONTH,0 RVRSL_PRV_MONTH, '|| chr(10)
    || '0 TOTAL_ADJSTMNT_AMT, 0 CAL '|| chr(10)
    || 'FROM PISEMPLOYEEMASTER A,PISDESIGNATIONMASTER B,PISGRADEMASTER C,COMPANYMAST D,DIVISIONMASTER E, PISBANKMASTER F,  '|| chr(10)
    || LV_PAYTRANSTABLE||' G,PISCATEGORYMASTER H, PISUNITMASTER I '|| chr(10)
    || 'WHERE A.COMPANYCODE=B.COMPANYCODE(+) '|| chr(10)
    || 'AND A.DIVISIONCODE=B.DIVISIONCODE(+) '|| chr(10)
    || 'AND A.DESIGNATIONCODE=B.DESIGNATIONCODE(+) '|| chr(10)   
    || 'AND G.COMPANYCODE=C.COMPANYCODE(+) '|| chr(10)
    || 'AND G.DIVISIONCODE=C.DIVISIONCODE(+) '|| chr(10)
    || 'AND G.GRADECODE=C.GRADECODE(+) '|| chr(10)
    || 'AND G.CATEGORYCODE=C.CATEGORYCODE(+) '|| chr(10)    
    || 'AND G.COMPANYCODE=D.COMPANYCODE(+) '|| chr(10)
    || 'AND G.COMPANYCODE=E.COMPANYCODE(+) '|| chr(10)
    || 'AND G.DIVISIONCODE=E.DIVISIONCODE(+) '|| chr(10)
    || 'AND A.COMPANYCODE=F.COMPANYCODE(+) '|| chr(10)
    || 'AND A.DIVISIONCODE=F.DIVISIONCODE(+) '|| chr(10)
    || 'AND A.BANKCODE=F.BANKCODE(+) '|| chr(10)
    || 'AND G.COMPANYCODE=A.COMPANYCODE(+) '|| chr(10)
    || 'AND G.DIVISIONCODE=A.DIVISIONCODE(+) '|| chr(10)
    || 'AND G.WORKERSERIAL=A.WORKERSERIAL(+) '|| chr(10)
    || 'AND G.TOKENNO=A.TOKENNO(+) '|| chr(10)
    || 'AND G.COMPANYCODE=H.COMPANYCODE(+) '|| chr(10)
    || 'AND G.DIVISIONCODE=H.DIVISIONCODE(+) '|| chr(10)
    || 'AND G.CATEGORYCODE=H.CATEGORYCODE(+) '|| chr(10)
    || 'AND G.COMPANYCODE=I.COMPANYCODE(+) '|| chr(10)
    || 'AND G.DIVISIONCODE=I.DIVISIONCODE(+) '|| chr(10)
    || 'AND G.UNITCODE=I.UNITCODE(+) '|| chr(10)
    || 'AND G.COMPANYCODE='''||p_companycode||''' '|| chr(10)
    || 'AND G.DIVISIONCODE='''||p_divisioncode||'''  '|| chr(10)    
    || 'AND G.YEARMONTH='''||p_yearmonth||''' '|| chr(10);
    
    
    IF LV_transtype IS NOT NULL THEN
        lv_sql := lv_sql || 'AND G.TRANSACTIONTYPE='''||LV_transtype||''''|| chr(10);
    END IF;
    
    if (nvl(p_unitcode,'NA') <>'NA') then
        lv_sql := lv_sql || 'AND G.UNITCODE IN( '||p_unitcode||' ) '|| chr(10);
    end if;  
        
    if (nvl(p_categorycode,'NA') <>'NA') then
        lv_sql := lv_sql || 'AND G.CATEGORYCODE IN( '||p_categorycode||' ) '|| chr(10);
    end if;
        
    if (nvl(p_gradecode,'NA') <>'NA') then
        lv_sql := lv_sql || 'AND G.GRADECODE IN( '||p_gradecode||' ) '|| chr(10);
    end if;        
   lv_sql:=lv_sql || 'AND G.WORKERSERIAL = AAA.WORKERSERIAL ) '|| chr(10);
       
    if(nvl(p_workerserial,'NA') <>'NA')  THEN
        lv_sql := lv_sql || 'WHERE WORKERSERIAL IN( '||p_workerserial||' )'|| chr(10);
    end if ;
       
--     dbms_output.put_line(lv_sql);
    execute immediate lv_sql;
    
    lv_sql:='';
    lv_columns:='';
    
    --REV ADD PTAX
   -- lv_sql:= 'UPDATE GTT_PISPAYSLIP A1 SET (WORKERSERIAL,ADD_INFO)=(SELECT A2.WORKERSERIAL,SUM(NVL(A2.ITAX,0)) AS ADD_INFO FROM PISPAYTRANSACTION A2 '|| chr(10)
   lv_sql:= 'UPDATE GTT_PISPAYSLIP A1 SET (WORKERSERIAL,ADD_INFO, P_TAX)=(SELECT A2.WORKERSERIAL,SUM(NVL(A2.ITAX,0)) AS ADD_INFO,SUM(NVL(A2.PTAX,0))AS P_TAX FROM '||LV_PAYTRANSTABLE||' A2 '|| chr(10)
   --END REV ADD PTAX
   || 'WHERE A2.COMPANYCODE='''||p_companycode||''' '|| chr(10) 
   || 'AND A2.DIVISIONCODE='''||p_divisioncode||''' '|| chr(10) 
   || 'AND A2.YEARCODE='''||p_yearcode||''' '|| chr(10)
   || 'AND TO_NUMBER(A2.YEARMONTH)<='''||p_yearmonth||''' '|| chr(10);
   
    IF LV_transtype IS NOT NULL THEN
        lv_sql := lv_sql || 'AND A2.TRANSACTIONTYPE='''||LV_transtype||''''|| chr(10);
    END IF;
    
    if (nvl(p_unitcode,'NA') <>'NA') then
        lv_sql := lv_sql || 'AND A2.UNITCODE IN( '||p_unitcode||' ) '|| chr(10);
    end if;  
        
    if (nvl(p_categorycode,'NA') <>'NA') then
        lv_sql := lv_sql || 'AND A2.CATEGORYCODE IN( '||p_categorycode||' ) '|| chr(10);
    end if;
        
    if (nvl(p_gradecode,'NA') <>'NA') then
        lv_sql := lv_sql || 'AND A2.GRADECODE IN( '||p_gradecode||' ) '|| chr(10);
    end if;
        
    if(nvl(p_workerserial,'NA') <>'NA')  THEN
        lv_sql := lv_sql || 'AND A1.WORKERSERIAL = A2.WORKERSERIAL '|| chr(10);
    end if ;
      
   lv_sql:=lv_sql|| 'AND A1.GRADECODE = A2.GRADECODE GROUP BY A2.WORKERSERIAL '|| chr(10)   
   || ') '|| chr(10);
      
      if(nvl(p_workerserial,'NA') <>'NA')  THEN
        lv_sql := lv_sql || 'WHERE A1.WORKERSERIAL IN('||p_workerserial||') '|| chr(10);
    end if ;
   
   
    dbms_output.put_line(lv_sql);
    execute immediate lv_sql;
    
    
    
END;
/