DROP PROCEDURE NJMCL_WEB.PROC_WPS_ELECBAL_UPDT;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPS_ELECBAL_UPDT (P_COMPCODE Varchar2,
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

lv_Sql       varchar2(32767) := '';
lv_Sql_TblCreate    varchar2(3000) := '';  
lv_sqlerrm      varchar2(1000) := ''; 
lv_remarks      varchar2(1000) := '';
lv_parvalues    varchar2(1000) := '';
lv_SqlTemp      varchar2 (2000) := '';
lv_fn_stdt      date := to_date(P_FNSTDT,'DD/MM/YYYY');
lv_fn_endt      date := to_date(P_FNENDT,'DD/MM/YYYY');
lv_ProcName     varchar2(30) := 'PROC_WPS_YTDMNTHGRS_UPDT';
lv_YYYYMM       varchar2(10) := to_char(lv_fn_stdt,'YYYYMM');
lv_updtable varchar2(30) ;
lv_pf_cont_col varchar2(30) ;
lv_cnt int;
begin
    
    ------- THIS PROCEDURE USE FOR ELECTRIC BALANCE UPDATE -------------
    
    PROC_ELECBLNC_WITH_BILL_EMI(P_COMPCODE,P_DIVCODE,P_FNSTDT,P_FNENDT,NULL,'WPS');               
     
    lv_sql := 'UPDATE '||P_TABLENAME||' A SET A.ELEC_BAL = (SELECT  NVL(ELEC_BAL_AMT,0) FROM GBL_ELECBLNC B '||CHR(10)  
        ||'             WHERE A.WORKERSERIAL = B.WORKERSERIAL ) '||CHR(10)
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||'   AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||CHR(10)
        ||'   AND A.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') '||CHR(10)
        ||'   AND A.WORKERSERIAL IN (SELECT WORKERSERIAL FROM GBL_ELECBLNC) '||CHR(10);
   lv_remarks := NVL(lv_remarks,'XX ') ||' UPDATE ELECTRIC BALANCE ';
  --dbms_output.put_line(lv_sql );   
   INSERT INTO WPS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
   VALUES (P_COMPCODE, P_DIVCODE,lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);
    EXECUTE IMMEDIATE lv_sql;
    COMMIT;
   
EXCEPTION
WHEN OTHERS THEN
lv_sqlerrm := sqlerrm;
INSERT INTO WPS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
VALUES (P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);
 COMMIT;                             
                          
end;
/


