CREATE OR REPLACE PROCEDURE PRC_LOANBREAKUP_INSERT_WAGES1
( 
    P_COMPCODE VARCHAR2, 
    P_DIVCODE VARCHAR2, 
    P_YEARCODE VARCHAR2, 
    P_START_DT VARCHAR2, 
    P_END_DT VARCHAR2,
    P_MODULE VARCHAR2, 
    P_TABLENAME VARCHAR2, 
    P_TRANTYPE VARCHAR2 DEFAULT 'GPS', 
    P_LOANCODE VARCHAR2 DEFAULT NULL, 
    P_PFNO VARCHAR2 DEFAULT NULL, 
    P_WORKERSERIAL VARCHAR2 DEFAULT NULL,
    P_DEDUCTFROM   VARCHAR2 DEFAULT 'SALARY' 
)
AS
lv_Sql varchar2(32767) := null;
lv_SqlLnBrkUp varchar2(20000) :='';
lv_fn_stdt DATE := TO_DATE(P_START_DT,'DD/MM/YYYY');
lv_fn_endt DATE := TO_DATE(P_END_DT,'DD/MM/YYYY');
lv_YYYYMM  VARCHAR2(10) := to_char(lv_fn_endt,'YYYYMM'); --substr(P_END_DT,5,4)||substr(P_END_DT,3,2);
lv_Remarks          varchar2(1000) := null;
--lv_SqlStr           varchar2(10000) := null;
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := null;   
lv_ProcName         varchar2(30)   := 'PRC_LOANBREAKUP_INSERT_WAGES'; 
lv_Component        varchar2(4000) := null; 
lv_strWorkerSerial  varchar2(10) :='';
lv_PFNo             varchar2(20) := null;
lv_TableName        varchar2(30) := null;
lv_MasterTable      varchar2(30) := null;
lv_ModuleTableNm    varchar2(30) := null;
lv_ColName          varchar2(5000) := null;
lv_TableColName     varchar2(5000) := null;
lv_InsertTable      varchar2(30) := null;


Begin

    if P_TRANTYPE = 'PF' then
        PROC_PFLOANBLNC(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'','',P_MODULE);
        lv_InsertTable := 'PFLOANBREAKUP';
    else
        PROC_LOANBLNC(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'','',P_MODULE);
        lv_InsertTable := 'LOANBREAKUP';
    end if;
    lv_TableName := P_TABLENAME;
    
    IF P_DEDUCTFROM = 'SALARY' THEN
        lv_Sql := ' DELETE FROM '||lv_InsertTable||' WHERE EFFECTFORTNIGHT = TO_DATE('''||P_END_DT||''',''DD/MM/YYYY'') '||CHR(10)
                  ||' AND MODULE = '''||P_MODULE||''' AND TRANSACTIONTYPE IN (''CAPITAL'',''INTEREST'') '||CHR(10)
                  ||' AND WORKERSERIAL IN ( SELECT DISTINCT WORKERSERIAL FROM '||lv_TableName||' WHERE DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10) 
                  ||' AND PERIODFROM = TO_DATE('''||P_START_DT||''',''DD/MM/YYYY'')  AND PERIODTO=TO_DATE('''||P_END_DT||''',''DD/MM/YYYY'') ) '||CHR(10);
    ELSE
        lv_Sql := ' DELETE FROM '||lv_InsertTable||' WHERE EFFECTFORTNIGHT = TO_DATE('''||P_END_DT||''',''DD/MM/YYYY'') '||CHR(10)
                  ||' AND MODULE = '''||P_MODULE||''' AND TRANSACTIONTYPE IN (''CAPITAL'',''INTEREST'') '||CHR(10)
                  ||' AND WORKERSERIAL IN ( SELECT DISTINCT WORKERSERIAL FROM '||lv_TableName||' WHERE DIVISIONCODE = '''||P_DIVCODE||''') '||CHR(10)
--                  ||' AND PERIODFROM = TO_DATE('''||P_START_DT||''',''DD/MM/YYYY'')  AND PERIODTO=TO_DATE('''||P_END_DT||''',''DD/MM/YYYY'') '||CHR(10)
                  ||' AND DEDUCTFROM = ''ARREAR'' '||CHR(10);
    END IF;              
    lv_Remarks := P_MODULE||' LOAN BREAKUP DATA DELETE';
--        --DBMS_OUTPUT.PUT_LINE (lv_Remarks);
       -- DBMS_OUTPUT.PUT_LINE (lv_Sql);
        
    --insert into gps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,null,lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
    
    EXECUTE IMMEDIATE lv_sql;
    
    -- DBMS_OUTPUT.PUT_LINE (lv_Sql);
    --end if;                                    
    
    if P_MODULE = 'PIS' then
        --lv_TableName := 'PISPAYTRANSACTION_SWT';
        lv_MasterTable := 'PISEMPLOYEEMASTER';
    else
        --lv_TableName := 'WPSWAGESDETAILS_MV_SWT';
        lv_MasterTable := 'GPSEMPLOYEEMAST';
    end if;
    lv_ColName := null;
    
    
    DBMS_OUTPUT.PUT_LINE ('lv_MasterTable :'||lv_MasterTable);
    if P_TRANTYPE = 'PF' then   
        FOR c1 in (select DISTINCT LOANCODE FROM PFLOANMASTER WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE AND REFUNDTYPE = 'REFUNDABLE')
        loop
            lv_ColName := lv_ColName||',''LOAN_'||c1.LOANCODE||''',''LINT_'||c1.LOANCODE||''',''LNBL_'||c1.LOANCODE||''',''LIBL_'||c1.LOANCODE||''''; 
        end loop;
    else
        FOR c1 in (select DISTINCT LOANCODE FROM LOANMASTER WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE)
        loop
            lv_ColName := lv_ColName||',''LOAN_'||c1.LOANCODE||''',''LINT_'||c1.LOANCODE||''',''LNBL_'||c1.LOANCODE||''',''LIBL_'||c1.LOANCODE||''''; 
    DBMS_OUTPUT.PUT_LINE ('CLOUMN :'||lv_ColName);
        end loop;
    
    end if;
    lv_ColName := SUBSTR(lv_ColName,2);
    DBMS_OUTPUT.PUT_LINE ('CLOUMN :'||lv_ColName);
    lv_SqlLnBrkUp := null;
    if P_TRANTYPE = 'PF' then
        for c2 in ( 
                    select COLUMN_NAME FROM COLS 
                    where TABLE_NAME = lv_TableName  --'PISPAYTRANSACTION_SWT'
                      AND (COLUMN_NAME LIKE 'LOAN_%' OR COLUMN_NAME LIKE 'LINT_%' OR COLUMN_NAME LIKE 'LNBL_%' OR COLUMN_NAME LIKE 'LIBL_%')
                    intersect
                    SELECT LOANCODE CLOUMN_NAME 
                    FROM (
                            SELECT 'LOAN_'||LOANCODE LOANCODE FROM PFLOANMASTER WHERE REFUNDTYPE = 'REFUNDABLE'
                            UNION 
                            SELECT 'LINT_'||LOANCODE LOANCODE FROM PFLOANMASTER WHERE REFUNDTYPE = 'REFUNDABLE'
                         )
                  )                   
        loop
            lv_TableColName := lv_TableColName||','||c2.COLUMN_NAME;
            if substr(c2.COLUMN_NAME,1,5) = 'LOAN_' then
                if NVL(lv_SqlLnBrkUp,'N') <> 'N' then
                    lv_SqlLnBrkUp := lv_SqlLnBrkUp||'   UNION ALL '||CHR(10);
                end if;
                lv_SqlLnBrkUp := lv_SqlLnBrkUp ||'   SELECT WORKERSERIAL, TOKENNO, substr('''||c2.COLUMN_NAME||''',6) LOANCODE, '||c2.COLUMN_NAME||' AS AMOUNT, ''CAPITAL'' TRANTYPE '||CHR(10) 
                                               ||'   FROM '||lv_TableName||' '||chr(10)
                                               ||'   WHERE 1=1 '||CHR(10)
                                               ||'     AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                                               ||'     AND PERIODFROM = '''||lv_fn_stdt||''' '||CHR(10)
                                               ||'     AND PERIODTO = '''||lv_fn_endt||''' '||CHR(10)
                                               ||'     AND nvl('||c2.COLUMN_NAME||',0) > 0 '||chr(10);  
                                               
            elsif substr(c2.COLUMN_NAME,1,5) = 'LINT_' then
                if NVL(lv_SqlLnBrkUp,'N') <> 'N' then
                    lv_SqlLnBrkUp := lv_SqlLnBrkUp||'   UNION ALL '||CHR(10);
                end if;
                lv_SqlLnBrkUp := lv_SqlLnBrkUp ||'   SELECT WORKERSERIAL, TOKENNO, substr('''||c2.COLUMN_NAME||''',6) LOANCODE, '||c2.COLUMN_NAME||' AS AMOUNT, ''INTEREST'' TRANTYPE '||CHR(10) 
                                               ||'   FROM '||lv_TableName||' '||chr(10)
                                               ||'   WHERE 1=1 '||CHR(10)
                                               ||'     AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                                               ||'     AND PERIODFROM = '''||lv_fn_stdt||''' '||CHR(10)
                                               ||'     AND PERIODTO = '''||lv_fn_endt||''' '||CHR(10)
                                               ||'     AND nvl('||c2.COLUMN_NAME||',0) > 0 '||chr(10);
            
            end if;
        end loop;    
    else
        for c3 in ( 
                    select COLUMN_NAME FROM COLS 
                    where TABLE_NAME = lv_TableName  --'PISPAYTRANSACTION_SWT'
                      AND (COLUMN_NAME LIKE 'LOAN_%' OR COLUMN_NAME LIKE 'LINT_%' OR COLUMN_NAME LIKE 'LNBL_%' OR COLUMN_NAME LIKE 'LIBL_%')
                    intersect
                    SELECT LOANCODE CLOUMN_NAME 
                    FROM (
                            SELECT 'LOAN_'||LOANCODE LOANCODE FROM LOANMASTER WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                            UNION 
                            SELECT 'LINT_'||LOANCODE LOANCODE FROM LOANMASTER WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                         )
                  )                   
        loop
            lv_TableColName := lv_TableColName||','||c3.COLUMN_NAME;
            if substr(c3.COLUMN_NAME,1,5) = 'LOAN_' then
                if NVL(lv_SqlLnBrkUp,'N') <> 'N' then
                    lv_SqlLnBrkUp := lv_SqlLnBrkUp||'   UNION ALL '||CHR(10);
                end if;
                /*lv_SqlLnBrkUp := lv_SqlLnBrkUp ||'   SELECT WORKERSERIAL, TOKENNO, substr('''||c3.COLUMN_NAME||''',6) LOANCODE, '||c3.COLUMN_NAME||' AS AMOUNT, ''CAPITAL'' TRANTYPE '||CHR(10) 
                                               ||'   FROM '||lv_TableName||' '||chr(10)
                                               ||'   WHERE 1=1 '||CHR(10)
                                               ||'     AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                                               ||'     AND PERIODFROM = '''||lv_fn_stdt||''' '||CHR(10)
                                               ||'     AND PERIODTO = '''||lv_fn_endt||''' '||CHR(10) 
                                               ||'     AND nvl('||c3.COLUMN_NAME||',0) > 0 '||chr(10);*/
                
                lv_SqlLnBrkUp := lv_SqlLnBrkUp ||'   SELECT WORKERSERIAL, TOKENNO, substr('''||c3.COLUMN_NAME||''',6) LOANCODE, '||c3.COLUMN_NAME||' AS AMOUNT, ''CAPITAL'' TRANTYPE '||CHR(10) 
                                               ||'   FROM '||lv_TableName||' '||chr(10)
                                               ||'   WHERE 1=1 '||CHR(10)
                                               ||'     AND DIVISIONCODE = '''||P_DIVCODE||''' ';
                
                if P_MODULE <> 'PIS' then                               
                   lv_SqlLnBrkUp := lv_SqlLnBrkUp ||'     AND PERIODFROM = '''||lv_fn_stdt||''' '||CHR(10)
                                                  ||'     AND PERIODTO = '''||lv_fn_endt||''' '; 
                END IF;
                                               
                lv_SqlLnBrkUp := lv_SqlLnBrkUp ||'     AND nvl('||c3.COLUMN_NAME||',0) > 0 '||chr(10);
                                                                              
            elsif substr(c3.COLUMN_NAME,1,5) = 'LINT_' then
                if NVL(lv_SqlLnBrkUp,'N') <> 'N' then
                    lv_SqlLnBrkUp := lv_SqlLnBrkUp||'   UNION ALL '||CHR(10);
                end if;
                
                /*lv_SqlLnBrkUp := lv_SqlLnBrkUp ||'   SELECT WORKERSERIAL, TOKENNO, substr('''||c3.COLUMN_NAME||''',6) LOANCODE, '||c3.COLUMN_NAME||' AS AMOUNT, ''INTEREST'' TRANTYPE '||CHR(10) 
                                               ||'   FROM '||lv_TableName||' '||chr(10)
                                               ||'   WHERE 1=1 '||CHR(10)
                                               ||'     AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                                               ||'     AND PERIODFROM = '''||lv_fn_stdt||''' '||CHR(10)
                                               ||'     AND PERIODTO = '''||lv_fn_endt||''' '||CHR(10) 
                                               ||'     AND  nvl('||c3.COLUMN_NAME||',0) > 0 '||chr(10);*/
                                               
                lv_SqlLnBrkUp := lv_SqlLnBrkUp ||'   SELECT WORKERSERIAL, TOKENNO, substr('''||c3.COLUMN_NAME||''',6) LOANCODE, '||c3.COLUMN_NAME||' AS AMOUNT, ''INTEREST'' TRANTYPE '||CHR(10) 
                                               ||'   FROM '||lv_TableName||' '||chr(10)
                                               ||'   WHERE 1=1 '||CHR(10)
                                               ||'     AND DIVISIONCODE = '''||P_DIVCODE||''' ';
                
                if P_MODULE <> 'PIS' then                               
                   lv_SqlLnBrkUp := lv_SqlLnBrkUp ||'     AND PERIODFROM = '''||lv_fn_stdt||''' '||CHR(10)
                                                  ||'     AND PERIODTO = '''||lv_fn_endt||''' ';
                END IF;
                                                
                lv_SqlLnBrkUp := lv_SqlLnBrkUp ||'     AND  nvl('||c3.COLUMN_NAME||',0) > 0 '||chr(10);                               
            
            end if;            
        end loop;
    end if;                   
    lv_TableColName := SUBSTR(lv_TableColName,2); 
    
    ----DBMS_OUTPUT.PUT_LINE ('TABLE CLOUMN :'||lv_TableColName);
    IF LENGTH(lv_SqlLnBrkUp) > 10 THEN
        if P_TRANTYPE = 'PF' THEN
            lv_Sql := ' INSERT INTO PFLOANBREAKUP ( '||chr(10)
                    ||' COMPANYCODE, DIVISIONCODE, EMPLOYEECOMPANYCODE, EMPLOYEEDIVISIONCODE, YEARCODE, YEARMONTH, CATEGORYCODE, GRADECODE, '||chr(10) 
                    ||' PFNO, TOKENNO, WORKERSERIAL, LOANCODE, LOANDATE, EFFECTYEARMONTH, AMOUNT, TRANSACTIONTYPE, '||chr(10) 
                    ||' EFFECTFORTNIGHT, PAIDON, ISPAID, REMARKS, MODULE, USERNAME, LASTMODIFIED,SYSROWID) '||chr(10)
                    ||' SELECT M.COMPANYCODE, M.DIVISIONCODE, '''||P_COMPCODE||''' EMPLOYEECOMPANYCODE, '''||P_DIVCODE||''' EMPLOYEEDIVISIONCODE, '''||P_YEARCODE||''' YEARCODE, '''||lv_YYYYMM||''' YEARMONTH, M.CATEGORYCODE, M.GRADECODE, '||chr(10)
                    ||' A.PFNO, A.TOKENNO, A.WORKERSERIAL, A.LOANCODE, A.LOANDATE, '''||lv_YYYYMM||''' EFFECTYEARMONTH, B.AMOUNT, B.TRANTYPE, '||chr(10) 
                    ||' TO_DATE('''||P_END_DT||''',''DD/MM/YYYY'') EFFECTFORTNIGHT, TO_DATE('''||P_END_DT||''',''DD/MM/YYYY'') PAION, ''Y'' ISPAID,''SALARY'','''||P_MODULE||''', ''SWT'', SYSDATE, '||chr(10)
                    ||' A.PFNO||''-''||B.TRANTYPE||''-''||A.LOANCODE||''-''||REPLACE('''||P_END_DT||''',''/'','''') SYSROWID'||chr(10)
                    ||' FROM GBL_PFLOANBLNC A, PFEMPLOYEEMASTER M, '||chr(10) 
                    ||' ( '||chr(10)
                    ||' '||lv_SqlLnBrkUp||' '||chr(10)           
                    ||' ) B'||chr(10)
                    ||' WHERE A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
                    ||'   AND A.LOANCODE = B.LOANCODE '||CHR(10)
                    ||'   /*AND A.PFNO = M.PFNO */'||CHR(10)
                    ||'   AND M.COMPANYCODE = '''||P_COMPCODE||''' '||CHR(10)
                    ||'   AND M.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                    ||'   AND A.WORKERSERIAL = M.WORKERSERIAL '||CHR(10) 
                    ||' ORDER BY A.PFNO, A.LOANCODE,B.TRANTYPE '||CHR(10);
            lv_Remarks := 'PF DATA TRANSFER TO PFLOANBREAKUP';
        --    --DBMS_OUTPUT.PUT_LINE (lv_Remarks);
            DBMS_OUTPUT.PUT_LINE (lv_Sql);
        
           -- insert into gps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
            EXECUTE IMMEDIATE lv_Sql;
            lv_sql := null;
            COMMIT;
        else
            lv_Sql := ' INSERT INTO LOANBREAKUP ( '||chr(10)
                    ||' COMPANYCODE, DIVISIONCODE, EMPLOYEECOMPANYCODE, EMPLOYEEDIVISIONCODE, YEARCODE, YEARMONTH, CATEGORYCODE, GRADECODE, '||chr(10) 
                    ||' TOKENNO, WORKERSERIAL, LOANCODE, LOANDATE, EFFECTYEARMONTH, AMOUNT, TRANSACTIONTYPE, '||chr(10) 
                    ||' EFFECTFORTNIGHT, PAIDON, ISPAID, REMARKS, MODULE, USERNAME, LASTMODIFIED,SYSROWID) '||chr(10)
                    ||' SELECT M.COMPANYCODE, M.DIVISIONCODE, '''||P_COMPCODE||''' EMPLOYEECOMPANYCODE, '''||P_DIVCODE||''' EMPLOYEEDIVISIONCODE, '''||P_YEARCODE||''' YEARCODE, '''||lv_YYYYMM||''' YEARMONTH, M.CATEGORYCODE, M.GRADECODE, '||chr(10)
                    ||' A.TOKENNO, A.WORKERSERIAL, A.LOANCODE, A.LOANDATE, '''||lv_YYYYMM||''' EFFECTYEARMONTH, B.AMOUNT, B.TRANTYPE, '||chr(10) 
                    ||' TO_DATE('''||P_END_DT||''',''DD/MM/YYYY'') EFFECTFORTNIGHT, TO_DATE('''||P_END_DT||''',''DD/MM/YYYY'') PAION, ''Y'' ISPAID,''SALARY'','''||P_MODULE||''', ''SWT'', SYSDATE, '||chr(10)
                    ||' A.WORKERSERIAL||''-''||B.TRANTYPE||''-''||A.LOANCODE||''-''||REPLACE('''||P_END_DT||''',''/'','''') SYSROWID '||chr(10)  
                    ||' FROM GBL_LOANBLNC A, '||lv_MasterTable||' M, '||chr(10) 
                    ||' ( '||chr(10)
                    ||' '||lv_SqlLnBrkUp||' '||chr(10)           
                    ||' ) B'||chr(10)
                    ||' WHERE A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
                    ||'   AND A.LOANCODE = B.LOANCODE '||CHR(10)
                    ||'   AND A.WORKERSERIAL = M.WORKERSERIAL '||CHR(10)
                    ||' ORDER BY A.WORKERSERIAL, A.LOANCODE,B.TRANTYPE '||CHR(10);
            lv_Remarks := 'LOAN DATA TRANSFER TO LOANBREAKUP';
            DBMS_OUTPUT.PUT_LINE(lv_sql);
           -- insert into gps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
            EXECUTE IMMEDIATE lv_Sql;
            lv_sql := null;
            COMMIT;        
        end if;
    END IF;    
return;
exception
    when others then
          lv_sqlerrm := sqlerrm ;
    insert into gps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,lv_sqlerrm,lv_sql,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);      
end;
/
