CREATE OR REPLACE PROCEDURE FORTWILLIAM_WPS.PROC_WPSWAGES_OTHER_COMP_UPDT (P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2, 
                                                  P_YEARCODE Varchar2,
                                                  P_FNSTDT Varchar2,  --- 01/05/2016 '  
                                                  P_FNENDT Varchar2,  --- 31/05/2016 '
                                                  P_PHASE  number, 
                                                  P_PHASE_TABLENAME VARCHAR2, -- 'wpswagesdetails_mv_swt
                                                  P_TABLENAME Varchar2,  ---' wpswagesdetails_mv
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL,
                                                  P_PROCESSTYPE VARCHAR2 DEFAULT NULL)
as
lv_Component varchar2(32767) := '';
lv_Sql       varchar2(32767) := '';
lv_upd1_sql  varchar2(32767) := '';
lv_upd2_sql  varchar2(32767) := '';
lv_colstr    varchar2(32767) := '';
lv_Sql_TblCreate    varchar2(3000) := '';  
lv_sqlerrm      varchar2(1000) := ''; 
lv_remarks      varchar2(1000) := '';
lv_parvalues    varchar2(1000) := '';
lv_SqlTemp      varchar2 (2000) := '';
lv_Cols         varchar2 (1000) := '';
lv_fn_stdt      date := to_date(P_FNSTDT,'DD/MM/YYYY');
lv_fn_endt      date := to_date(P_FNENDT,'DD/MM/YYYY');
lv_FirtstDt     date; 
lv_ProcName     varchar2(30) := 'PROC_WPSWAGES_OTHER_COMP_UPDT';
lv_Formula1     varchar2(1000) := '';
lv_Formula1_Col varchar2(30) := '';
lv_Formula2     varchar2(1000) := '';
lv_Formula2_Col varchar2(30) := '';
lv_Formula3     varchar2(1000) :='';
lv_Formula3_Col varchar2(30) := '';
lv_Formula4     varchar2(1000) :='';
lv_Formula4_Col varchar2(30) := '';
lv_YYYYMM       varchar2(10) := to_char(lv_fn_stdt,'YYYYMM');
lv_updtable varchar2(30) ;
lv_pf_cont_col varchar2(30) ;
lv_MaxPensionGrossAmt   number(12,2) := 0;
lv_MaxPensionAmt        number(12,2) := 0;
lv_PensionPercentage    number(7,2) := 0;
lv_ESI_C_Percentage     number(7,2) := 0;
lv_cnt int;
begin
    lv_parvalues := 'DIV = '||P_DIVCODE||', FNE = '||P_FNENDT||', PHASE = '||P_PHASE;
    lv_remarks := 'PHASE - '||P_PHASE||' START';
    if  substr(P_FNSTDT,1,2) = '01' then
        lv_FirtstDt := to_date(P_FNSTDT,'DD/MM/YYYY');        
    else
        lv_FirtstDt := to_date('01'||substr(P_FNSTDT,3,8),'DD/MM/YYYY');
    end if;
    --------- for pension part ---------
    
    --- START ADD ON 29.09.2016 ------
    select MAXIMUMPENSIONGROSS, MAXIMUMPENSION, PENSION_PERCENTAGE, ESICOMPANYPERCENT 
    into lv_MaxPensionGrossAmt, lv_MaxPensionAmt, lv_PensionPercentage, lv_ESI_C_Percentage
    from WPSWAGESPARAMETER 
    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE;
    
    select SUBSTR( ( 'WPS_'||SYS_CONTEXT('USERENV', 'SESSIONID')) ,1,30) into lv_updtable  from dual ;
    
    lv_sql := ' CREATE TABLE '||lv_updtable||' AS  '||CHR(10)
            ||' SELECT WORKERSERIAL, PF_GROSS, PENSION_GROSS, PF_CONT, FPF, PF_COM '||chr(10)
            ||' FROM ( '||chr(10)
            ||'         SELECT WORKERSERIAL, EPFAPPLICABLE, PF_GROSS_CUR, PF_CONT_CUR, PF_GROSS, PENSION_GROSS,PF_CONT, '||chr(10)    
            ||'         CASE WHEN EPFAPPLICABLE = ''Y'' THEN CASE WHEN ROUND(PENSION_GROSS * '||lv_PensionPercentage||'/100)+FPF > '||lv_MaxPensionAmt||' THEN '||lv_MaxPensionAmt||' - FPF ELSE ROUND(PENSION_GROSS * '||lv_PensionPercentage||'/100) END ELSE 0 END FPF, '||chr(10)
            ||'         CASE WHEN EPFAPPLICABLE = ''Y'' THEN PF_CONT_CUR - CASE WHEN ROUND(PENSION_GROSS * '||lv_PensionPercentage||'/100)+FPF > '||lv_MaxPensionAmt||' THEN '||lv_MaxPensionAmt||' - FPF ELSE ROUND(PENSION_GROSS * '||lv_PensionPercentage||'/100) END ELSE PF_CONT_CUR END PF_COM  '||chr(10) 
            ||'     FROM (  '||chr(10)
            ||'             SELECT A.WORKERSERIAL, NVL(B.EPFAPPLICABLE,''N'') EPFAPPLICABLE, SUM(PF_GROSS_CUR) PF_GROSS_CUR, SUM(PF_CONT_CUR) PF_CONT_CUR, SUM(PF_GROSS_PREV) PF_GROSS_PREV,  '||chr(10) 
            ||'             SUM(NVL(PF_GROSS,0)) PF_GROSS, SUM(NVL(PF_CONT,0)) PF_CONT, SUM(FPF) FPF, SUM(PF_COM) PF_COM,  '||chr(10)
            ||'             CASE WHEN SUM(NVL(PF_GROSS,0)) > '||lv_MaxPensionGrossAmt||' THEN '||lv_MaxPensionGrossAmt||' - SUM(PENSION_GROSS) ELSE SUM(PF_GROSS) - SUM(PF_GROSS_PREV) END PENSION_GROSS  '||chr(10)
            ||'             FROM (  '||chr(10)
            ||'                     SELECT WORKERSERIAL, NVL(PF_GROSS,0) PF_GROSS_CUR, NVL(PF_CONT,0) PF_CONT_CUR, 0 PF_GROSS_PREV, NVL(PF_GROSS,0) PF_GROSS, 0 PENSION_GROSS, NVL(PF_CONT,0) PF_CONT, 0 FPF, 0 PF_COM  '||chr(10)
            ||'                     FROM '||P_PHASE_TABLENAME||'   '||chr(10)
            ||'                     WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
            ||'                       AND FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')   '||chr(10)
            ||'                       AND FORTNIGHTENDDATE =  TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')  '||chr(10)
            ||'                       AND NVL(PF_CONT,0) > 0  '||chr(10)
            ||'                     UNION ALL '||chr(10)
            ||'                     SELECT WORKERSERIAL, 0 PF_GROSS_CUR, 0 PF_CONT_CUR, NVL(PF_GROSS,0) PF_GROSS_PREV,NVL(PF_GROSS,0) PF_GROSS, NVL(PENSION_GROSS,0) PENSION_GROSS, NVL(PF_CONT,0) PF_CONT, NVL(FPF,0) FPF, NVL(PF_COM,0) PF_COM '||chr(10)
            ||'                     FROM WPSWAGESDETAILS_MV '||chr(10)
            ||'                     WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
            ||'                       AND YEARCODE = '''||P_YEARCODE||'''  '||chr(10)
            ||'                       AND FORTNIGHTSTARTDATE <> TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')  '||chr(10)
            ||'                       AND FORTNIGHTENDDATE <> TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')  '||chr(10)
            ||'                       AND TO_CHAR(FORTNIGHTSTARTDATE,''YYYYMM'') = '''||lv_YYYYMM||'''  '||chr(10)
            ||'                       AND NVL(PF_CONT,0) > 0  '||chr(10)
            ||'                  ) A, WPSWORKERMAST B  '||chr(10)
            ||'             WHERE B.COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10) 
            ||'               AND A.WORKERSERIAL = B.WORKERSERIAL      '||chr(10)
            ||'             GROUP BY A.WORKERSERIAL, B.EPFAPPLICABLE '||chr(10)
            ||'         ) '||chr(10)
            ||'    )   '||chr(10); 
    --dbms_output.put_line( lv_sql );
    INSERT INTO WPS_ERROR_LOG ( PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) VALUES (lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks); 
    EXECUTE IMMEDIATE lv_sql  ;
    
   
    lv_sql := 'UPDATE '||P_TABLENAME||' A SET (PENSION_GROSS, FPF, PF_COM  ) = ( SELECT PENSION_GROSS, FPF, PF_COM  FROM '||lv_updtable||' B '||CHR(10) 
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||' AND A.YEARCODE = '''||P_YEARCODE||'''   '||CHR(10) 
        ||' AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||CHR(10)
        ||' AND A.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')               '||CHR(10)
        ||' AND A.WORKERSERIAL = B.WORKERSERIAL )'||CHR(10)
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||' AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||CHR(10)
        ||' AND A.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')               '||CHR(10); 
    --- END ADD ON 29.09.2016 -----------
    --dbms_output.put_line( lv_sql );
    lv_remarks := NVL(lv_remarks,'XX ') ||' UPDATE PENSION GROSS, FPF, PF_COM';
    INSERT INTO WPS_ERROR_LOG ( PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) VALUES (lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);    
    EXECUTE IMMEDIATE lv_sql;
       BEGIN
        execute immediate 'DROP TABLE '||lv_updtable ;
       EXCEPTION
        WHEN OTHERS THEN
          lv_sqlerrm := sqlerrm;
          raise_application_error(-20101, lv_sqlerrm||'ERROR WHILE UPDATING '||P_TABLENAME||' FROM TABLE '||lv_updtable);
       END ;                          
   ---------------- ESI COMPANY CONTRIBUTION UPDATE ---------    
   lv_remarks := 'PHASE - '||P_PHASE||' START UPDATE ESI_C';
   lv_Sql := ' UPDATE '||P_TABLENAME||' SET ESI_COMP_CONT = CEIL(ROUND(ESI_GROSS * '||lv_ESI_C_Percentage||'/100,2)) '||CHR(10)
        ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||'   AND YEARCODE = '''||P_YEARCODE||'''   '||CHR(10) 
        ||'   AND FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||CHR(10)
        ||'   AND FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')               '||CHR(10)
        ||'   AND NVL(ESI_CONT,0) > 0 '||CHR(10);
    INSERT INTO WPS_ERROR_LOG ( PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) VALUES (lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);    
    EXECUTE IMMEDIATE lv_sql; 
    
    ------- DEPARTMENT AND SHIFT UPDATE FOR GENERATE THE PAYSLIP
    PROC_WPSWAGES_DEPTSHIFT_UPDT(P_COMPCODE, P_DIVCODE,P_YEARCODE, P_FNSTDT, P_FNENDT,101,P_TABLENAME,P_TABLENAME,'');
    
     ---- CUMULITVE COMPONENT UPDATE PROCEDURE ------
    PROC_WPSOTHER_CUMMULATIVE_UPDT(P_COMPCODE,P_DIVCODE,P_YEARCODE,P_FNSTDT,P_FNENDT,99,P_PHASE_TABLENAME, P_TABLENAME,NULL);       
end;
/