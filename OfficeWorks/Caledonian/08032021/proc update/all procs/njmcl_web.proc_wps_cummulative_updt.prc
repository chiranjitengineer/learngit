DROP PROCEDURE NJMCL_WEB.PROC_WPS_CUMMULATIVE_UPDT;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPS_CUMMULATIVE_UPDT(P_COMPCODE Varchar2,
                                                  P_DIVCODE Varchar2, 
                                                  P_YEARCODE Varchar2,
                                                  P_FNSTDT Varchar2,  --- 01/05/2016 '  
                                                  P_FNENDT Varchar2,  --- 31/05/2016 '
                                                  P_PHASE  number, 
                                                  P_PHASE_TABLENAME VARCHAR2, -- 'wpswagesdetails_mv_swt
                                                  P_TABLENAME Varchar2,  ---' wpswagesdetails_mv
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL,
                                                  P_PROCESSTYPE  VARCHAR2 DEFAULT 'WAGES PROCESS')
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
lv_ProcName     varchar2(30) := 'PROC_WPS_CUMMULATIVE_UPDT';
lv_YYYYMM       varchar2(10) := to_char(lv_fn_stdt,'YYYYMM');
lv_updtable varchar2(30) ;
lv_pf_cont_col varchar2(30) ;
lv_cnt int;
lv_FNYearStartdate varchar2(10) :='';
lv_CalenderYearStartdate varchar2(10) :='';
begin
    
    
--    dbms_output.put_line('1_1');
    SELECT '01/04/'||SUBSTR(YEARCODE,1,4)
      INTO lv_FNYearStartdate
      FROM WPSWAGEDPERIODDECLARATION
     WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
       AND FORTNIGHTSTARTDATE=TO_DATE(P_FNSTDT,'DD/MM/YYYY')
       AND FORTNIGHTENDDATE=TO_DATE(P_FNENDT,'DD/MM/YYYY');
--    dbms_output.put_line('1_2');   
    lv_CalenderYearStartdate :='01/01/'||substr(P_FNSTDT,7,4)  ; 
    
    select SUBSTR( ( 'WPS1_'||SYS_CONTEXT('USERENV', 'SESSIONID')) ,1,30) into lv_updtable  from dual ;
    
    
    lv_cnt :=0;
    SELECT COUNT(*)
    INTO 
    lv_cnt
    FROM USER_TABLES
    WHERE TABLE_NAME =lv_updtable;
    
    IF lv_cnt>0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE '|| lv_updtable;
    END IF;
    
--    dbms_output.put_line('2_1');
    lv_sql := ' CREATE TABLE '||lv_updtable||' AS  '||CHR(10)
            ||' SELECT WORKERSERIAL, SUM(PF_E) PF_E, SUM(PF_C) PF_C, SUM(VPF) VPF, SUM(CUM_WORKINGDAYS) CUM_WORKINGDAYS, SUM(CUM_WORKINGHRS) CUM_WORKINGHRS,SUM(CUM_PFGROSS) CUM_PFGROSS '||CHR(10)
            ||' FROM ( '||CHR(10)
            ||'         SELECT WORKERSERIAL, SUM(PF_E) PF_E, SUM(PF_C) PF_C, SUM(VPF) VPF, 0 CUM_WORKINGDAYS, 0 CUM_WORKINGHRS , 0 CUM_PFGROSS '||CHR(10)
            ||'         FROM ( '||CHR(10)
            ||'                 SELECT WORKERSERIAL, PFNO, DECODE(COMPONENTCODE,''PF_E'',COMPONENTAMOUNT,0) PF_E, '||CHR(10)
            ||'                 DECODE(COMPONENTCODE,''PF_C'',COMPONENTAMOUNT,0) PF_C, '||CHR(10)
            ||'                 DECODE(COMPONENTCODE,''VPF'',COMPONENTAMOUNT,0) VPF '||CHR(10)
            ||'                 FROM PFTRANSACTIONDETAILS '||CHR(10)
            ||'                 WHERE EMPLOYEECOMPANYCODE = '''||P_COMPCODE||''' AND EMPLOYEEDIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'                   AND YEARCODE = '''||P_YEARCODE||''' '||CHR(10)
            ||'                   AND STARTDATE <= TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'') '||CHR(10)
            ||'                   AND TRANSACTIONTYPE <> ''SALARY'' '||CHR(10) 
            ||'                 UNION ALL '||CHR(10)
            ||'                 SELECT WORKERSERIAL, PFNO, DECODE(COMPONENTCODE,''PF_E'',COMPONENTAMOUNT,0) PF_E, '||CHR(10)
            ||'                 DECODE(COMPONENTCODE,''PF_C'',COMPONENTAMOUNT,0) PF_C, '||CHR(10)
            ||'                 DECODE(COMPONENTCODE,''VPF'',COMPONENTAMOUNT,0) VPF '||CHR(10)
            ||'                 FROM PFTRANSACTIONDETAILS '||CHR(10)
            ||'                 WHERE EMPLOYEECOMPANYCODE = '''||P_COMPCODE||''' AND EMPLOYEEDIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'                   AND YEARCODE = '''||P_YEARCODE||''' '||CHR(10)
            ||'                   AND STARTDATE < TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'') '||CHR(10)
            ||'                   AND TRANSACTIONTYPE = ''SALARY'' '||CHR(10)
            ||'                 UNION ALL '||CHR(10)
            ||'                 SELECT A.WORKERSERIAL, B.PFNO, NVL(PF_CONT,0) PF_E, NVL(PF_COM,0) PF_C, NVL(VPF,0) VPF '||CHR(10)
            ||'                 FROM '||P_TABLENAME||' A, WPSWORKERMAST B '||CHR(10)
            ||'                 WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'                   AND YEARCODE = '''||P_YEARCODE||'''  '||CHR(10)
            ||'                   AND FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'') '||CHR(10)
            ||'                   AND FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') '||CHR(10)
            ||'                   AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
            ||'                   AND A.WORKERSERIAL = B.WORKERSERIAL  '||CHR(10)
            ||'             )  '||CHR(10)
            ||'             GROUP BY WORKERSERIAL, PFNO  '||CHR(10)     
            ||'             UNION ALL  '||CHR(10)
            ||'             SELECT WORKERSERIAL, 0 PF_E, 0 PF_C, 0 VPF, SUM(CUM_WORKINGDAYS) CUM_WORKINGDAYS,  SUM(CUM_WORKINGHRS) CUM_WORKINGHRS, SUM(CUM_PFGROSS) CUM_PFGROSS  '||CHR(10)
            ||'             FROM (  '||CHR(10)
            ||'                     SELECT WORKERSERIAL, FORTNIGHTENDDATE, SUM(NVL(ATN_DAYS,0)) CUM_WORKINGDAYS  , SUM(NVL(ATTENDANCEHOURS,0)) CUM_WORKINGHRS, 0 CUM_PFGROSS '||CHR(10)
            ||'                     FROM WPSWAGESDETAILS_MV A, WPSWORKERCATEGORYMAST B '||CHR(10)
            ||'                     WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''      '||CHR(10)
            ||'                       AND A.FORTNIGHTSTARTDATE >= TO_DATE('''||lv_CalenderYearStartdate||''',''DD/MM/YYYY'') '||CHR(10)
            ||'                       AND A.FORTNIGHTSTARTDATE < TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')  '||CHR(10)
            ||'                       AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
            ||'                       AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE '||CHR(10)
            ||'                       AND (B.STLAPPLICABLE = ''Y'' OR B.CALC_CUMULATIVEWORKDAYS = ''Y'') '||CHR(10)   
            ||'                     GROUP BY A.WORKERSERIAL, A.FORTNIGHTENDDATE  '||CHR(10)
            ||'                     UNION ALL  '||CHR(10)
            ||'                     SELECT WORKERSERIAL, FORTNIGHTENDDATE, ROUND(NVL(ATTENDANCEHOURS,0)/8,2) CUM_WORKINGDAYS , NVL(ATTENDANCEHOURS,0) CUM_WORKINGHRS, 0 CUM_PFGROSS '||CHR(10)
            ||'                     FROM '||P_TABLENAME||' A, WPSWORKERCATEGORYMAST B '||CHR(10)
            ||'                     WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''   '||CHR(10)
            ||'                       AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')   '||CHR(10)
            ||'                       AND A.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')    '||CHR(10)
            ||'                       AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
            ||'                       AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE '||CHR(10)
            ||'                       AND (B.STLAPPLICABLE = ''Y'' OR B.CALC_CUMULATIVEWORKDAYS = ''Y'') '||CHR(10)
            ||'                     UNION ALL '||chr(10)
            ||'                     SELECT WORKERSERIAL, FORTNIGHTENDDATE, 0 CUM_WORKINGDAYS , 0 CUM_WORKINGHRS, SUM(NVL(PF_GROSS,0)) CUM_PFGROSS  '||CHR(10) 
            ||'                     FROM WPSWAGESDETAILS_MV A, WPSWORKERCATEGORYMAST B   '||CHR(10)
            ||'                     WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''    '||CHR(10)
            ||'                       AND A.YEARCODE = '''||P_YEARCODE||'''    '||CHR(10)
            ||'                       AND A.FORTNIGHTSTARTDATE < TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')  '||CHR(10)    
            ||'                       AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE   '||CHR(10)
            ||'                       AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE  '||CHR(10)
            ||'                       AND NVL(B.BONUSAPPLICABLE,''N'') = ''Y''   '||CHR(10)
            ||'                     GROUP BY A.WORKERSERIAL, A.FORTNIGHTENDDATE  '||CHR(10)
            ||'                     UNION ALL  '||CHR(10)
            ||'                     SELECT WORKERSERIAL, FORTNIGHTENDDATE, 0 CUM_WORKINGDAYS , 0 CUM_WORKINGHRS, NVL(PF_GROSS,0) CUM_PFGROSS  '||CHR(10) 
            ||'                     FROM '||P_TABLENAME||' A, WPSWORKERCATEGORYMAST B   '||CHR(10)
            ||'                     WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''    '||CHR(10)
            ||'                       AND A.YEARCODE = '''||P_YEARCODE||'''    '||CHR(10)
            ||'                       AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')  '||CHR(10)   
            ||'                       AND A.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')     '||CHR(10)
            ||'                       AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
            ||'                       AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE  '||CHR(10)
            ||'                       AND NVL(B.BONUSAPPLICABLE,''N'') = ''Y''   '||CHR(10)                  
            ||'                 )  '||CHR(10)  
            ||'             GROUP BY WORKERSERIAL  '||CHR(10)

            ||'        )  '||CHR(10)
            ||'         GROUP BY WORKERSERIAL  '||CHR(10);

--      dbms_output.put_line('2_2');
      
    --dbms_output.put_line(lv_sql );       
    INSERT INTO WPS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE,PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    VALUES (P_COMPCODE,P_DIVCODE,lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks); 
    EXECUTE IMMEDIATE lv_sql  ;
    COMMIT;
    --RETURN;
--    
lv_sql := 'UPDATE '||P_TABLENAME||' A SET (CUM_PF_E, CUM_PF_C,CUM_VPF, CALENDARWORKINGDAYS, CALENDARWORKINGHRS,CUM_PFGROSS )  '||CHR(10)  
        ||' = ( SELECT PF_E, PF_C, VPF, CUM_WORKINGDAYS , CUM_WORKINGHRS,CUM_PFGROSS  FROM '||lv_updtable||' B '||CHR(10) 
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||' AND A.YEARCODE = '''||P_YEARCODE||'''   '||CHR(10) 
        ||' AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||CHR(10)
        ||' AND A.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')               '||CHR(10)
        ||' AND A.WORKERSERIAL = B.WORKERSERIAL )'||CHR(10)
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||' AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||CHR(10)
        ||' AND A.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') '||CHR(10); 
   lv_remarks := NVL(lv_remarks,'XX ') ||' UPDATE CUMPF_CONT, CUMPF_COM,CALENDARWORKINGDAYS';
  --dbms_output.put_line(lv_sql );   
   INSERT INTO WPS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
   VALUES (P_COMPCODE,P_DIVCODE,lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);
   COMMIT;    
    EXECUTE IMMEDIATE lv_sql;
       BEGIN
        execute immediate 'DROP TABLE '||lv_updtable ;
       EXCEPTION
        WHEN OTHERS THEN
          lv_sqlerrm := sqlerrm;
          raise_application_error(-20101, lv_sqlerrm||'ERROR WHILE UPDATING '||P_TABLENAME||' FROM TABLE '||lv_updtable);
       END ;
EXCEPTION
    WHEN OTHERS THEN
    lv_sqlerrm := sqlerrm;
    INSERT INTO WPS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    VALUES (P_COMPCODE,P_DIVCODE, lv_ProcName,lv_sqlerrm,sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);
                                  
end;
/


