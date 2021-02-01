CREATE OR REPLACE procedure BAGGAGE_WEB.prc_pissalary_postingdata 
--EXEC prc_pissalary_postingdata('0001','001','SALARY PROCESS','202008','001','02','LTA')
(
   p_compcode varchar2, 
   p_divcode varchar2, 
   p_processtype varchar2 default 'SALARY PROCESS',
   p_yearmonth varchar2, 
   p_unitcode  varchar2 default NULL, 
   p_categorycode  varchar2 default NULL, 
   p_gradecode  varchar2 default NULL, 
   p_componentcode  varchar2 default NULL
) 
as
lv_sql              varchar2(8000);
lv_fn_stdt          varchar2(10) := '01/' || SUBSTR(p_yearmonth,-2,2) || '/' || SUBSTR(p_yearmonth,1,4);
lv_fn_endt          varchar2(10) := TO_CHAR(last_day(to_date(lv_fn_stdt,'dd/mm/yyyy')),'DD/MM/YYYY');           
lv_yearmonth        varchar2(6) := p_yearmonth;
lv_compcol          varchar2(500) := '';
lv_acledger         varchar2(500) := '';
lv_procname         varchar2(30) := '';
lv_remarks          varchar2(10);
lv_effectivedate    date;
lv_error_remark     varchar2(4000) := '' ;
lv_strtablename     varchar2(50);
begin

    
    if p_processtype = 'SALARY PROCESS' THEN
       lv_strtablename := 'PISPAYTRANSACTION';    
    elsif p_processtype = 'ARREAR PROCESS' THEN
       lv_strtablename := 'PISARREARTRANSACTION';  
    elsif p_processtype = 'REIMBURSEMENT PROCESS' THEN
       lv_strtablename := 'PISREIMBURSEMENTDETAILS';
    end if;
      
    lv_sql := 'CREATE OR REPLACE VIEW VW_PISCOMPONENTLEDGERMAPPING '||chr(10); 
    lv_sql := lv_sql ||' AS '||chr(10);
    
    IF (p_processtype = 'REIMBURSEMENT PROCESS') THEN 
        lv_sql := lv_sql || ' SELECT DISTINCT COMPANYCODE, DIVISIONCODE, COMPONENTCODE, ACCCODE '|| CHR(10) ; 
        lv_sql := lv_sql || ' FROM PISCOMPONENTMASTER ' || CHR(10);   
        lv_sql := lv_sql || ' WHERE COMPANYCODE = '''||p_compcode||''' '|| CHR(10) ; 
        lv_sql := lv_sql || ' AND DIVISIONCODE = '''||p_divcode||''' '|| CHR(10);      
        lv_sql := lv_sql || ' AND ACCODE IS NOT NULL '|| CHR(10);          
    ELSE
        lv_sql := lv_sql ||' SELECT COMPANYCODE, DIVISIONCODE, QUALITY_GROUP_CODE as COMPONENTCODE,  ACCODE ACCCODE '||chr(10);
        lv_sql := lv_sql ||' FROM SYS_PARAM_ACPOST_PAYROLL '||chr(10);
        lv_sql := lv_sql ||' WHERE COMPANYCODE = '''||p_compcode||''' AND DIVISIONCODE = '''||p_divcode||''' '||chr(10);
        lv_sql := lv_sql ||' AND  POSTING_PARAM_NAME = ''PIS SALARY POSTING TO ACCOUNTS'' '||chr(10);
        lv_sql := lv_sql ||' AND  MODULENAME = ''PIS'' '||chr(10);     
        lv_sql := lv_sql || ' AND ACCODE IS NOT NULL '|| CHR(10); 
        
         IF (p_processtype = 'ARREAR PROCESS') THEN 
             lv_sql := lv_sql || ' AND QUALITY_GROUP_CODE IN ( '|| CHR(10); 
             lv_sql := lv_sql || ' SELECT DISTINCT COMPONENTCODE FROM PISCOMPONENTMASTER '|| CHR(10); 
             lv_sql := lv_sql || ' WHERE COMPANYCODE='''||p_compcode||'''  AND DIVISIONCODE = '''||p_divcode||''' '|| CHR(10); 
             lv_sql := lv_sql || ' AND  (INCLUDEARREAR=''Y'' OR COMPONENTCODE=''NETSALARY'')'|| CHR(10); 
             lv_sql := lv_sql || ' ) '|| CHR(10); 
         END IF;
                 
    END IF;
     
    lv_sql := lv_sql  || 'UNION ALL'|| CHR(10); 
    lv_sql := lv_sql || ' SELECT DISTINCT COMPANYCODE, DIVISIONCODE, COMPONENTCODE, EXPENSECODE '|| CHR(10) ; 
    lv_sql := lv_sql || ' FROM PISCOMPONENTMASTER ' || CHR(10);   
    lv_sql := lv_sql || ' WHERE COMPANYCODE = '''||p_compcode||''' '|| CHR(10) ; 
    lv_sql := lv_sql || ' AND DIVISIONCODE = '''||p_divcode||''' '|| CHR(10);      
    lv_sql := lv_sql || ' AND EXPENSECODE IS NOT NULL '|| CHR(10);          
   
    
                         
    
    DBMS_OUTPUT.PUT_LINE ('1. '||lv_sql);
    
    execute immediate lv_sql;

    delete from PISSALARY_POSTINGDATA WHERE 1=1;
    
    lv_sql := '';
    lv_sql := lv_sql || CHR(10) || 'INSERT INTO PISSALARY_POSTINGDATA ';
    lv_sql := lv_sql || CHR(10) || '( ';
    lv_sql := lv_sql || CHR(10) || '  COMPANYCODE, DIVISIONCODE, PERIODFROM, PERIODTO, ACCODE, ACHEAD, DRCR, AMOUNT, ACCOSTCENTRECODE, CATEGORYCODE, UNITCODE, GRADECODE ';
    lv_sql := lv_sql || CHR(10) || ') ';
    lv_sql := lv_sql || CHR(10) || 'SELECT D.COMPANYCODE,D.DIVISIONCODE, ';
    lv_sql := lv_sql || CHR(10) || '       TO_DATE(''' || lv_fn_stdt || ''',''DD/MM/YYYY'') PERIODFROM,TO_DATE(''' || lv_fn_endt || ''',''DD/MM/YYYY'') PERIODTO, ';
    lv_sql := lv_sql || CHR(10) || '       C.ACCCODE, B.ACHEAD, ';
    lv_sql := lv_sql || CHR(10) || '       CASE                                                ';
    lv_sql := lv_sql || CHR(10) || '            WHEN D.COMPONENTCODE = ''NETSALARY'' THEN ''CR'' ';
    --ADDED ON 25/07/2020
    lv_sql := lv_sql || CHR(10) || '            WHEN C.ACCCODE IN (SELECT DISTINCT EXPENSECODE FROM PISCOMPONENTMASTER ) THEN ''CR'' ';
    --ENDED ON 25/07/2020
    lv_sql := lv_sql || CHR(10) || '            WHEN C.ACCCODE IN (SELECT DISTINCT ACCCODE FROM PISCOMPONENTMASTER WHERE COMPONENTCODE IN (''PF_C'',''FPF'')) THEN ''CR'' ';
    lv_sql := lv_sql || CHR(10) || '            WHEN D.COMPONENTTYPE = ''EARNING'' THEN ''DR'' ';
    lv_sql := lv_sql || CHR(10) || '            WHEN D.COMPONENTTYPE = ''DEDUCTION'' THEN ''CR'' '; 
--    lv_sql := lv_sql || CHR(10) || '            WHEN C.ACCCODE IN (''SYS0599'',''E000072'',''P000180'',''D000109'') THEN ''CR'' ';
    lv_sql := lv_sql || CHR(10) || '            ELSE ''DR'' ';
    lv_sql := lv_sql || CHR(10) || '        END AS DRCR, '; 
--    lv_sql := lv_sql || CHR(10) || '       FN_PISSALARY_COMP_AMT(C.COMPANYCODE,C.DIVISIONCODE,'''||p_processtype||''',C.COMPONENTCODE, ''' || p_yearmonth || ''' , ''' || p_categorycode || ''')  AMOUNT, ';
    lv_sql := lv_sql || CHR(10) || '       FN_PISSALARY_COMP_AMT_NEW(C.COMPANYCODE,C.DIVISIONCODE,''' || p_processtype || ''',C.COMPONENTCODE, ''' || p_yearmonth || ''' , ''' || p_categorycode || ''' , ''' || p_unitcode || ''' , ''' || p_gradecode || ''')  AMOUNT, '; 
--      lv_sql := lv_sql || CHR(10) || '       FN_PISSALARY_COMP_AMT(C.COMPANYCODE,C.DIVISIONCODE,''' || p_processtype || ''',C.COMPONENTCODE, ''' || p_yearmonth || ''' , ''' || p_categorycode || ''' , ''' || p_unitcode || ''' , ''' || p_gradecode || ''')  AMOUNT, '; 
    lv_sql := lv_sql || CHR(10) || '       NULL ACCOSTCENTRECODE, ''' || p_categorycode || ''' CATEGORYCODE, ''' || p_unitcode || ''' UNITCODE, ''' || p_gradecode || ''' GRADECODE ';
    lv_sql := lv_sql || CHR(10) || '  FROM PISCOMPONENTMASTER D, '; 
    lv_sql := lv_sql || CHR(10) || '        ( '; 
    lv_sql := lv_sql || CHR(10) || '          SELECT DISTINCT COMPANYCODE, DIVISIONCODE, COMPONENTCODE, ACCCODE '; 
    lv_sql := lv_sql || CHR(10) || '            FROM VW_PISCOMPONENTLEDGERMAPPING ';   
    lv_sql := lv_sql || CHR(10) || '           WHERE COMPANYCODE = '''||p_compcode||''' '; 
    lv_sql := lv_sql || CHR(10) || '             AND DIVISIONCODE = '''||p_divcode||''' '; 
    --ADDED ON 25/07/2020
--    lv_sql := lv_sql || CHR(10) || '             UNION ALL'; 
--    lv_sql := lv_sql || CHR(10) || '          SELECT DISTINCT COMPANYCODE, DIVISIONCODE, COMPONENTCODE, EXPENSECODE '; 
--    lv_sql := lv_sql || CHR(10) || '            FROM PISCOMPONENTMASTER '; 
--    lv_sql := lv_sql || CHR(10) || '           WHERE COMPANYCODE = '''||p_compcode||''' '; 
--    lv_sql := lv_sql || CHR(10) || '             AND DIVISIONCODE = '''||p_divcode||''' '; 
    --ENDED ON 25/07/2020
    lv_sql := lv_sql || CHR(10) || '        ) C ,ACACLEDGER B ';
    lv_sql := lv_sql || CHR(10) || ' WHERE C.COMPANYCODE = '''||p_compcode||''' '; 
    lv_sql := lv_sql || CHR(10) || '   AND C.DIVISIONCODE = '''||p_divcode||''' '; 
    lv_sql := lv_sql || CHR(10) || '   AND C.COMPANYCODE = D.COMPANYCODE '; 
    lv_sql := lv_sql || CHR(10) || '   AND C.DIVISIONCODE = D.DIVISIONCODE '; 
    lv_sql := lv_sql || CHR(10) || '   AND C.COMPONENTCODE=D.COMPONENTCODE '; 
    lv_sql := lv_sql || CHR(10) || '   AND B.COMPANYCODE = C.COMPANYCODE '; 
    lv_sql := lv_sql || CHR(10) || '   AND B.ACCODE = C.ACCCODE ';

    IF (p_processtype = 'REIMBURSEMENT PROCESS') THEN 
        lv_sql := lv_sql || CHR(10) || '   AND D.ALLOWREIMBURSEMENT = ''Y'' ';
    END IF;

   DBMS_OUTPUT.PUT_LINE (lv_sql);
      
    --RETURN;
           
    execute immediate lv_sql;
    
    delete from PISSALARY_POSTINGDATA_CC;
    lv_sql := '';
    lv_sql := lv_sql || CHR(10) || 'INSERT INTO PISSALARY_POSTINGDATA_CC ';
    lv_sql := lv_sql || CHR(10) || '( ';
    lv_sql := lv_sql || CHR(10) || '  COMPANYCODE, DIVISIONCODE, PERIODFROM, PERIODTO, ACCODE, ACHEAD, DRCR, AMOUNT, ACCOSTCENTRECODE, CATEGORYCODE, UNITCODE, GRADECODE  ';
    lv_sql := lv_sql || CHR(10) || ') ';
    lv_sql := lv_sql || CHR(10) || 'SELECT D.COMPANYCODE,D.DIVISIONCODE, ';
    lv_sql := lv_sql || CHR(10) || '       TO_DATE(''' || lv_fn_stdt || ''',''DD/MM/YYYY'') PERIODFROM,TO_DATE(''' || lv_fn_endt || ''',''DD/MM/YYYY'') PERIODTO, ';
    lv_sql := lv_sql || CHR(10) || '       C.ACCCODE, B.ACHEAD, ';
    lv_sql := lv_sql || CHR(10) || '       CASE  ';
    lv_sql := lv_sql || CHR(10) || '            WHEN D.COMPONENTCODE = ''NETSALARY'' THEN ''CR'' ';
    --ADDED ON 25/07/2020
    lv_sql := lv_sql || CHR(10) || '            WHEN C.ACCCODE IN (SELECT DISTINCT EXPENSECODE FROM PISCOMPONENTMASTER ) THEN ''CR'' ';
    --ENDED ON 25/07/2020
    lv_sql := lv_sql || CHR(10) || '            WHEN C.ACCCODE IN (SELECT DISTINCT ACCCODE FROM PISCOMPONENTMASTER WHERE COMPONENTCODE IN (''PF_C'',''FPF'')) THEN ''CR'' ';
    lv_sql := lv_sql || CHR(10) || '            WHEN D.COMPONENTTYPE = ''EARNING'' THEN ''DR'' ';
    lv_sql := lv_sql || CHR(10) || '            WHEN D.COMPONENTTYPE = ''DEDUCTION'' THEN ''CR'' '; 
--    lv_sql := lv_sql || CHR(10) || '            WHEN C.ACCCODE IN (''SYS0599'',''E000072'',''P000180'',''D000109'') THEN ''CR'' ';
    lv_sql := lv_sql || CHR(10) || '            ELSE ''DR'' ';
    lv_sql := lv_sql || CHR(10) || '        END AS DRCR, '; 
    --lv_sql := lv_sql || CHR(10) || '       FN_PISSALARY_COMP_AMT_CC(C.COMPANYCODE,C.DIVISIONCODE,''SALARY PROCESS'',C.COMPONENTCODE, ''' || p_yearmonth || ''' , ''' || p_categorycode || ''',PT.WORKERSERIAL)  AMOUNT, ';
    lv_sql := lv_sql || CHR(10) || '       FN_PISSALARY_COMP_AMT_CC(C.COMPANYCODE,C.DIVISIONCODE,''' || p_processtype || ''',C.COMPONENTCODE, ''' || p_yearmonth || ''' , ''' || p_categorycode || ''' , ''' || p_unitcode || ''' , ''' || p_gradecode  || ''',PT.WORKERSERIAL)  AMOUNT, '; 
    lv_sql := lv_sql || CHR(10) || '       X.COSTCENTRECODE ACCOSTCENTRECODE, ''' || p_categorycode || ''' CATEGORYCODE, ''' || p_unitcode || ''' UNITCODE , ''' || p_gradecode || ''' GRADECODE ';
    --lv_sql := lv_sql || CHR(10) || '  FROM PISCOMPONENTMASTER D, PISPAYTRANSACTION PT, PISEMPLOYEEMASTER X,';
    lv_sql := lv_sql || CHR(10) || '  FROM PISCOMPONENTMASTER D, ' || lv_strtablename || ' PT, PISEMPLOYEEMASTER X,'; 
    lv_sql := lv_sql || CHR(10) || '        ( '; 
    lv_sql := lv_sql || CHR(10) || '          SELECT DISTINCT COMPANYCODE, DIVISIONCODE, COMPONENTCODE, ACCCODE '; 
    lv_sql := lv_sql || CHR(10) || '            FROM VW_PISCOMPONENTLEDGERMAPPING ';   
    lv_sql := lv_sql || CHR(10) || '           WHERE COMPANYCODE = '''||p_compcode||''' '; 
    lv_sql := lv_sql || CHR(10) || '             AND DIVISIONCODE = '''||p_divcode||''' '; 
--    --ADDED ON 25/07/2020
--    lv_sql := lv_sql || CHR(10) || '             UNION ALL'; 
--    lv_sql := lv_sql || CHR(10) || '          SELECT DISTINCT COMPANYCODE, DIVISIONCODE, COMPONENTCODE, EXPENSECODE '; 
--    lv_sql := lv_sql || CHR(10) || '            FROM PISCOMPONENTMASTER '; 
--    lv_sql := lv_sql || CHR(10) || '           WHERE COMPANYCODE = '''||p_compcode||''' '; 
--    lv_sql := lv_sql || CHR(10) || '             AND DIVISIONCODE = '''||p_divcode||''' '; 
--    --ENDED ON 25/07/2020
    lv_sql := lv_sql || CHR(10) || '        ) C ,ACACLEDGER B ';
    lv_sql := lv_sql || CHR(10) || ' WHERE C.COMPANYCODE = '''||p_compcode||''' '; 
    lv_sql := lv_sql || CHR(10) || '   AND C.DIVISIONCODE = '''||p_divcode||''' '; 
    lv_sql := lv_sql || CHR(10) || '   AND C.COMPANYCODE = D.COMPANYCODE '; 
    lv_sql := lv_sql || CHR(10) || '   AND C.DIVISIONCODE = D.DIVISIONCODE '; 
    lv_sql := lv_sql || CHR(10) || '   AND C.COMPONENTCODE=D.COMPONENTCODE '; 
    lv_sql := lv_sql || CHR(10) || '   AND B.COMPANYCODE = C.COMPANYCODE '; 
    lv_sql := lv_sql || CHR(10) || '   AND B.ACCODE = C.ACCCODE ';    
    lv_sql := lv_sql || CHR(10) || '   AND C.COMPANYCODE = PT.COMPANYCODE ';
    lv_sql := lv_sql || CHR(10) || '   AND C.DIVISIONCODE = PT.DIVISIONCODE ';
    lv_sql := lv_sql || CHR(10) || '   AND PT.YEARMONTH = '''||p_yearmonth||''' ';
    lv_sql := lv_sql || CHR(10) || '   AND PT.CATEGORYCODE = '''||p_categorycode||''' ';
    lv_sql := lv_sql || CHR(10) || '   AND PT.COMPANYCODE = X.COMPANYCODE ';
    lv_sql := lv_sql || CHR(10) || '   AND PT.DIVISIONCODE = X.DIVISIONCODE ';
    lv_sql := lv_sql || CHR(10) || '   AND PT.WORKERSERIAL = X.WORKERSERIAL ';

    IF (p_processtype = 'REIMBURSEMENT PROCESS') THEN 
        lv_sql := lv_sql || CHR(10) || '   AND D.ALLOWREIMBURSEMENT = ''Y'' ';
    END IF;

    --DBMS_OUTPUT.PUT_LINE (lv_sql);
    execute immediate lv_sql;
    commit;   
    
exception
     when others then    lv_error_remark := sqlerrm;
     raise_application_error(to_number(fn_display_error( 'COMMON')),fn_display_error( 'COMMON',6,lv_error_remark)) ;    
end;
/
