DROP PROCEDURE NJMCL_WEB.PROC_WPS_YTDMNTHGRS_UPDT;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPS_YTDMNTHGRS_UPDT (P_COMPCODE Varchar2,
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
lv_Prev_fn_stdt  date;
lv_Prev_fn_endt  date;
lv_Mnth_stdt     date;   
lv_FirtstDt     date; 
lv_ProcName     varchar2(30) := 'PROC_WPS_YTDMNTHGRS_UPDT';
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
lv_FNYearStartdate varchar2(10) :='';
lv_CalenderYearStartdate varchar2(10) :='';
begin
    
    if substr(P_FNSTDT,1,2) <> '01' then
       lv_Prev_fn_stdt := TO_DATE('01/'||SUBSTR(P_FNSTDT,-7),'DD/MM/YYYY');
       lv_Prev_fn_endt := TO_DATE('15/'||SUBSTR(P_FNSTDT,-7),'DD/MM/YYYY');
       lv_Mnth_stdt:= TO_DATE('01/'||SUBSTR(P_FNSTDT,-7),'DD/MM/YYYY');
    else
        lv_Mnth_stdt := to_date(P_FNSTDT,'DD/MM/YYYY');  
    end if;
    SELECT '01/04/'||SUBSTR(YEARCODE,1,4)
      INTO lv_FNYearStartdate
      FROM WPSWAGEDPERIODDECLARATION
     WHERE FORTNIGHTSTARTDATE=TO_DATE(P_FNSTDT,'DD/MM/YYYY')
       AND FORTNIGHTENDDATE=TO_DATE(P_FNENDT,'DD/MM/YYYY');
       
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
    
    
      lv_sql := ' CREATE TABLE '||lv_updtable||' AS  '||CHR(10)
           ||' SELECT WORKERSERIAL,SUM(NVL(YTD_PF_E,0)) YTD_PF_E, SUM(NVL(YTD_PF_C,0)) YTD_PF_C, SUM(NVL(YTD_FPF,0)) YTD_FPF,'||chr(10)
           ||' SUM(NVL(MNTH_PF_GROSS,0)) MNTH_PF_GROSS, SUM(NVL(MNTH_ESI_GROSS,0)) MNTH_ESI_GROSS,  SUM(NVL(MNTH_PTAX_GROSS,0)) MNTH_PTAX_GROSS,'||CHR(10)
           ||' SUM(NVL(MNTH_BONUS_GROSS,0)) MNTH_BONUS_GROSS, SUM(NVL(GR_BONOUS_TODATE,0)) GR_BONOUS_TODATE,     '||chr(10)
           ||' SUM(NVL(CALENDARWORKINGDAYS,0)) CALENDARWORKINGDAYS, SUM(NVL(FEWORKINGDAYS,0)) FEWORKINGDAYS    '||chr(10)
           ||' FROM(     '||chr(10)
           ||'        SELECT WORKERSERIAL,SUM(NVL(PF_CONT,0)) YTD_PF_E, SUM(NVL(PF_COM,0)) YTD_PF_C, SUM(NVL(FPF,0)) YTD_FPF, '||chr(10)
           ||'               0 MNTH_PF_GROSS, 0 MNTH_ESI_GROSS, 0 MNTH_PTAX_GROSS, 0 MNTH_BONUS_GROSS, '||CHR(10) 
           ||'               SUM(NVL(PF_GROSS,0)) GR_BONOUS_TODATE,     '||chr(10)
           ||'               0 CALENDARWORKINGDAYS, 0 FEWORKINGDAYS     '||chr(10)
           ||'        FROM WPSWAGESDETAILS_MV    '||chr(10) --- YTD AND bONUS DATA FROM FINANCIAL YEAR STARTING (WAGES TABLE B4 CURRENT FORTNIGHT) 
           ||'        WHERE FORTNIGHTSTARTDATE >= TO_DATE('''||lv_FNYearStartdate||''',''DD/MM/YYYY'')     '||chr(10)
           ||'          AND FORTNIGHTSTARTDATE < TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||chr(10)
           ||'        GROUP BY WORKERSERIAL    '||chr(10)
           ||'        UNION ALL  '||CHR(10)
           ||'        SELECT WORKERSERIAL,SUM(NVL(PF_E,0)) YTD_PF_E, SUM(NVL(PF_C,0)) YTD_PF_C, SUM(NVL(FPF,0)) YTD_FPF, '||chr(10)
           ||'               0 MNTH_PF_GROSS, 0 MNTH_ESI_GROSS, 0 MNTH_PTAX_GROSS, 0 MNTH_BONUS_GROSS, '||CHR(10)
           ||'               SUM(NVL(PF_GROSS,0)) GR_BONOUS_TODATE,     '||chr(10)
           ||'               0 CALENDARWORKINGDAYS, 0 FEWORKINGDAYS     '||chr(10)
           ||'        FROM WPSSTLWAGESDETAILS    '||chr(10) --- YTD AND bONUS DATA FROM FINANCIAL YEAR STARTING (STL TABLE UPTO CURRENT FORTNIGHT)
           ||'        WHERE PAYMENTDATE >= TO_DATE('''||lv_FNYearStartdate||''',''DD/MM/YYYY'')     '||chr(10)
           ||'          AND PAYMENTDATE <= TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')       '||chr(10)
           ||'        GROUP BY WORKERSERIAL    '||chr(10)
           ||'        UNION ALL  '||CHR(10)
           ||'        SELECT WORKERSERIAL,0  YTD_PF_E, 0 YTD_PF_C, 0 YTD_FPF, '||chr(10)
           ||'               sum(nvl(PF_GROSS,0)) MNTH_PF_GROSS, sum(nvl(ESI_GROSS,0)) MNTH_ESI_GROSS, sum(nvl(GROSS_PTAX,0))MNTH_PTAX_GROSS, sum(nvl(PF_GROSS,0)) MNTH_BONUS_GROSS,'||CHR(10) 
           ||'               0 GR_BONOUS_TODATE,     '||chr(10)
           ||'               0 CALENDARWORKINGDAYS, 0 FEWORKINGDAYS     '||chr(10)
           ||'        FROM WPSSTLWAGESDETAILS    '||chr(10)  --- MONTHLY GROSS DATA FROM FINANCIAL YEAR STARTING (STL TABLE UPTO CURRENT FORTNIGHT)
           ||'        WHERE PAYMENTDATE >= '''||lv_Mnth_stdt||'''     '||chr(10)
           ||'          AND PAYMENTDATE <= TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')       '||chr(10)
           ||'        GROUP BY WORKERSERIAL    '||chr(10)
           ||'        UNION ALL           '||chr(10)
           ||'        SELECT WORKERSERIAL,SUM(NVL(PF_CONT,0)) YTD_PF_E, SUM(NVL(PF_COM,0)) YTD_PF_C, SUM(NVL(FPF,0)) YTD_FPF,  '||chr(10)
           ||'               SUM(NVL(PF_GROSS,0)) MNTH_PF_GROSS, SUM(NVL(ESI_GROSS,0)) MNTH_ESI_GROSS, SUM(NVL(GROSS_PTAX,0)) MNTH_PTAX_GROSS, SUM(nvl(PF_GROSS,0)) MNTH_BONUS_GROSS,'||CHR(10)
------- CHNAGES ON 21.08.20 PF ADJUSTMENT HOURS INCLUDE FOR YTD DAYS ADJUSTMENT  BY AMALESH ----------
--           ||'               SUM(NVL(PF_GROSS,0)) GR_FOR_BONUS,SUM(NVL(ATN_DAYS,0)) CALENDARWORKINGDAYS, SUM(NVL(ATN_DAYS,0)) FEWORKINGDAYS   '||chr(10)
           ||'               SUM(NVL(PF_GROSS,0)) GR_FOR_BONUS,SUM((NVL(ATN_DAYS,0)+ROUND(NVL(PFADJHOURS,0)/8,1))) CALENDARWORKINGDAYS, SUM(NVL(ATN_DAYS,0)) FEWORKINGDAYS   '||chr(10)

           ||'          FROM '||P_TABLENAME||'    '||chr(10)  --- CURRENT FORTNIGHT DATA   
           ||'         WHERE FORTNIGHTSTARTDATE=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')    '||chr(10)
           ||'           AND FORTNIGHTENDDATE=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')      '||chr(10)
           ||'           GROUP BY WORKERSERIAL    '||chr(10)
           ||'        UNION ALL    '||chr(10)
           ||'        SELECT WORKERSERIAL, 0 YTD_PF_E, 0 YTD_PF_C, 0 YTD_FPF,    '||chr(10)
           ||'               0 MNTH_PF_GROSS, 0 MNTH_ESI_GROSS, 0 MNTH_PTAX_GROSS, 0 MNTH_BONUS_GROSS, '||CHR(10)
------- CHNAGES ON 21.08.20 PF ADJUSTMENT HOURS INCLUDE FOR YTD DAYS ADJUSTMENT  BY AMALESH ----------           
--           ||'              0 GR_FOR_BONUS,SUM(NVL(ATN_DAYS,0)) CALENDARWORKINGDAYS, 0 FEWORKINGDAYS    '||chr(10)
           ||'              0 GR_FOR_BONUS,SUM((NVL(ATN_DAYS,0)+ROUND(NVL(PFADJHOURS,0)/8,0))) CALENDARWORKINGDAYS, 0 FEWORKINGDAYS    '||chr(10)
           ||'          FROM WPSWAGESDETAILS_MV    '||chr(10) --- YTD DAYS FROM JANUARY TO B4 FORTNIGHTSTART 
           ||'         WHERE FORTNIGHTSTARTDATE>=TO_DATE('''||lv_CalenderYearStartdate||''',''DD/MM/YYYY'')    '||chr(10)
           ||'           AND FORTNIGHTENDDATE < TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')      '||chr(10)
           ||'           GROUP BY WORKERSERIAL    '||chr(10);
      IF SUBSTR(P_FNSTDT,1,2) = '16' THEN       --- ony ptax gross cosider monthly gross  add on 02.08.2020
        lv_sql := lv_sql ||'        UNION ALL    '||chr(10)
           ||'        SELECT WORKERSERIAL,0 YTD_PF_E, 0 YTD_PF_C, 0 YTD_FPF,  '||chr(10)
           ||'               0 MNTH_PF_GROSS, 0 MNTH_ESI_GROSS, SUM(NVL(GROSS_PTAX,0)) MNTH_PTAX_GROSS, 0 MNTH_BONUS_GROSS,'||CHR(10)
           ||'               0 GR_FOR_BONUS, 0  CALENDARWORKINGDAYS, 0 FEWORKINGDAYS   '||chr(10)
           ||'          FROM WPSWAGESDETAILS_MV   '||chr(10)
           ||'         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
           ||'           AND YEARCODE = '''||P_YEARCODE||''' '||CHR(10) 
           ||'           AND FORTNIGHTSTARTDATE = '''||lv_Prev_fn_stdt||'''    '||chr(10)
           ||'           AND FORTNIGHTENDDATE = '''||lv_Prev_fn_endt||'''      '||chr(10)
           ||'           GROUP BY WORKERSERIAL    '||chr(10);
           
      END IF;             
      lv_sql := lv_sql ||'       ) GROUP BY WORKERSERIAL      '||chr(10);
    --dbms_output.put_line(lv_sql );       
    INSERT INTO WPS_ERROR_LOG (COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    VALUES (P_COMPCODE, P_DIVCODE, lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);
    EXECUTE IMMEDIATE lv_sql  ;
    COMMIT;

--    
    lv_sql := 'UPDATE '||P_TABLENAME||' A SET (GR_BONUS_TODATE, CALENDARWORKINGDAYS, FEWORKINGDAYS, YTD_PF_E, YTD_PF_C, YTD_FPF, MNTH_PF_GROSS, MNTH_PTAX_GROSS, MNTH_ESI_GROSS, MNTH_BONUS_GROSS)  '||CHR(10)  
        ||' = ( SELECT GR_BONOUS_TODATE,CALENDARWORKINGDAYS, FEWORKINGDAYS, YTD_PF_E, YTD_PF_C, YTD_FPF, MNTH_PF_GROSS, MNTH_PTAX_GROSS, MNTH_ESI_GROSS, MNTH_BONUS_GROSS FROM '||lv_updtable||' B '||CHR(10) 
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||' AND A.YEARCODE = '''||P_YEARCODE||'''   '||CHR(10) 
        ||' AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||CHR(10)
        ||' AND A.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')               '||CHR(10)
        ||' AND A.WORKERSERIAL = B.WORKERSERIAL )'||CHR(10)
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||' AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||CHR(10)
        ||' AND A.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') '||CHR(10); 
   lv_remarks := NVL(lv_remarks,'XX ') ||' UPDATE CUMPF_CONT, GR_BONOUS_TODATE,CALENDARWORKINGDAYS';
  --dbms_output.put_line(lv_sql );   
   INSERT INTO WPS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
   VALUES (P_COMPCODE, P_DIVCODE,lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);
    EXECUTE IMMEDIATE lv_sql;
    COMMIT;
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
    VALUES (P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);
     COMMIT;                             
                          
end;
/


