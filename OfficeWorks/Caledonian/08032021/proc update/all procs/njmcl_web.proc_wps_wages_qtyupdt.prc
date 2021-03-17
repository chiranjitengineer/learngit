DROP PROCEDURE NJMCL_WEB.PROC_WPS_WAGES_QTYUPDT;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPS_WAGES_QTYUPDT(P_COMPCODE Varchar2,
                                                  P_DIVCODE Varchar2, 
                                                  P_YEARCODE Varchar2,
                                                  P_FNSTDT Varchar2,  --- 01/05/2016 '  
                                                  P_FNENDT Varchar2,  --- 31/05/2016 '
                                                  P_PHASE  number, 
                                                  P_PHASE_TABLENAME VARCHAR2,
                                                  P_TABLENAME Varchar2,  ---' wpswagesdetails_mv_swt
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
lv_ProcName     varchar2(30) := 'PROC_WPS_WAGES_QTYUPDT';
lv_YYYYMM       varchar2(10) := to_char(lv_fn_stdt,'YYYYMM');
lv_updtable varchar2(30) ;
lv_pf_cont_col varchar2(30) ;
lv_cnt int;
lv_FNYearStartdate varchar2(10) :='';
lv_CalenderYearStartdate varchar2(10) :='';
begin
    
    
    
    
    lv_cnt :=0;
    SELECT COUNT(*)
    INTO 
    lv_cnt
    FROM USER_TABLES
    WHERE TABLE_NAME =P_PHASE_TABLENAME;
    
    IF lv_cnt>0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE '|| P_PHASE_TABLENAME;
    END IF;
    
    lv_Remarks:='01 UPDATE TOTALPRODUCTION INTO WPSWAGESDETAILS_SWT';
    
    lv_sql:='UPDATE WPSWAGESDETAILS_SWT AA SET (TOTALPRODUCTION)=NVL(('||CHR(10)
         ||'                                            SELECT  NVL(M.TOTALPRODUCTION,0) FROM ('||CHR(10)
         ||'SELECT     B.COMPANYCODE,B.DIVISIONCODE,B.YEARCODE,B.FORTNIGHTSTARTDATE,B.FORTNIGHTENDDATE,'||CHR(10)
         ||'           B.DEPARTMENTCODE,B.SECTIONCODE,B.SHIFTCODE,B.OCCUPATIONCODE,B.DEPTSERIAL,A.WORKERSERIAL,'||CHR(10)
         ||'            SUM(NVL(A.TOTALPRODUCTION,0))TOTALPRODUCTION'||CHR(10)
         ||'            FROM WPSPRODUCTIONSUMMARY A,WPSATTENDANCEDAYWISE B'||CHR(10)
         ||'         WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''''||CHR(10)
         ||'           AND A.STARTDATE >= TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')'||CHR(10)
         ||'           AND A.STARTDATE <= TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10)
         ||'           AND A.COMPANYCODE = B.COMPANYCODE'||CHR(10)
         ||'           AND A.DIVISIONCODE = B.DIVISIONCODE'||CHR(10)
         ||'           AND A.STARTDATE = B.DATEOFATTENDANCE'||CHR(10)
         ||'          AND A.SHIFTCODE = B.SHIFTCODE'||CHR(10)
         ||'           AND A.DEPARTMENTCODE=B.DEPARTMENTCODE'||CHR(10)
         ||'           AND A.SECTIONCODE=B.SECTIONCODE'||CHR(10)
         ||'           AND A.WORKERSERIAL = B.WORKERSERIAL'||CHR(10)
         ||'         GROUP BY B.COMPANYCODE,B.DIVISIONCODE,B.YEARCODE,B.FORTNIGHTSTARTDATE,B.FORTNIGHTENDDATE,'||CHR(10)
         ||'           B.DEPARTMENTCODE,B.SECTIONCODE,B.SHIFTCODE,B.OCCUPATIONCODE,B.DEPTSERIAL,A.WORKERSERIAL'||CHR(10)
         ||')M'||CHR(10)
         ||'WHERE 1=1'||CHR(10)
         ||'AND AA.COMPANYCODE=M.COMPANYCODE'||CHR(10)
         ||'AND AA.DIVISIONCODE=M.DIVISIONCODE'||CHR(10)
         ||'AND AA.DEPARTMENTCODE=M.DEPARTMENTCODE'||CHR(10)
         ||'AND AA.SECTIONCODE=M.SECTIONCODE'||CHR(10)
         ||'AND AA.SHIFTCODE=M.SHIFTCODE'||CHR(10)
         ||'AND AA.OCCUPATIONCODE=M.OCCUPATIONCODE'||CHR(10)
         ||'AND AA.DEPTSERIAL=M.DEPTSERIAL'||CHR(10)
         ||'AND AA.WORKERSERIAL=M.WORKERSERIAL'||CHR(10)
         ||'),0)'||CHR(10)
         ||'WHERE 1=1'||CHR(10)
         ||'AND AA.FORTNIGHTSTARTDATE=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')'||CHR(10)
         ||'AND AA.FORTNIGHTENDDATE=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10)
         ||'AND AA.WORKERSERIAL IN (  SELECT WORKERSERIAL FROM WPSWAGESDETAILS_SWT '||CHR(10)
         ||'                           WHERE COMPANYCODE ='''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
         ||'                             AND FORTNIGHTSTARTDATE=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')'||CHR(10)
         ||'                             AND FORTNIGHTENDDATE=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10)
         ||'                        )'||CHR(10);           
           
          
    --DBMS_OUTPUT.PUT_LINE(lv_sql);  
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'', lv_sql, lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
    EXECUTE IMMEDIATE lv_sql;  
    COMMIT;
    
    lv_remarks :='';
    
--    dbms_output.put_line('2_1');
    lv_sql := ' CREATE TABLE '||P_PHASE_TABLENAME||' AS  '||CHR(10)
            ||'SELECT COMPANYCODE,DIVISIONCODE,YEARCODE,FORTNIGHTSTARTDATE,FORTNIGHTENDDATE,'||CHR(10)
            ||'WORKERSERIAL,NVL(SUM(NVL(TOTALPRODUCTION,0)),0)TOTALPRODUCTION '||CHR(10)
            ||'FROM WPSWAGESDETAILS_SWT'||CHR(10)
            ||'WHERE 1=1'||CHR(10)
            ||'AND COMPANYCODE='''||P_COMPCODE||''''||CHR(10)
            ||'AND DIVISIONCODE='''||P_DIVCODE||''''||CHR(10)
            ||'AND YEARCODE='''||P_YEARCODE||''''||CHR(10)
            ||'AND FORTNIGHTSTARTDATE= TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')'||CHR(10)
            ||'AND FORTNIGHTENDDATE=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10)
            ||'GROUP BY COMPANYCODE,DIVISIONCODE,YEARCODE,'||CHR(10)
            ||'FORTNIGHTSTARTDATE,FORTNIGHTENDDATE,WORKERSERIAL'||CHR(10);
      lv_remarks := NVL(lv_remarks,'XX ') ||'-02 CREATE '||P_PHASE_TABLENAME||' FOR TOTALPRODUCTION UPDATE ';

      
    --dbms_output.put_line(lv_sql );       
    INSERT INTO WPS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE,PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    VALUES (P_COMPCODE,P_DIVCODE,lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks); 
    EXECUTE IMMEDIATE lv_sql  ;
    COMMIT;
    --RETURN;
    lv_remarks :='';
--    
lv_sql := 'UPDATE '||P_TABLENAME||' A SET (TOTALPRODUCTION)  '||CHR(10)  
        ||' = ( SELECT TOTALPRODUCTION  FROM '||P_PHASE_TABLENAME||' B '||CHR(10) 
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||' AND A.YEARCODE = '''||P_YEARCODE||'''   '||CHR(10) 
        ||' AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||CHR(10)
        ||' AND A.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')               '||CHR(10)
        ||' AND A.WORKERSERIAL = B.WORKERSERIAL )'||CHR(10)
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||' AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||CHR(10)
        ||' AND A.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') '||CHR(10); 
        
   lv_remarks := NVL(lv_remarks,'XX ') ||'-03 UPDATE TOTALPRODUCTION';
  --dbms_output.put_line(lv_sql );   
   INSERT INTO WPS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
   VALUES (P_COMPCODE,P_DIVCODE,lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);
   EXECUTE IMMEDIATE lv_sql;
    COMMIT; 
    
--UPDATE MACHINEALLICABLE PRODUCTION TO 0 
 lv_remarks :='';
lv_sql := 'UPDATE '||P_TABLENAME||' A SET (TOTALPRODUCTION)  '||CHR(10)
        ||'=NVL(( SELECT 0  FROM WPSPRODUCTIONTYPEMAST  B  '||CHR(10)
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''''||CHR(10) 
        ||' AND A.YEARCODE =  '''||P_YEARCODE||''''||CHR(10) 
        ||' AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')'||CHR(10) 
        ||' AND A.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10) 
        ||' AND A.COMPANYCODE=B.COMPANYCODE'||CHR(10)
        ||' AND A.DIVISIONCODE=B.DIVISIONCODE'||CHR(10)
        ||' AND A.DEPARTMENTCODE=B.DEPARTMENTCODE'||CHR(10) 
        ||' AND A.SECTIONCODE=B.SECTIONCODE'||CHR(10) 
        ||' AND B.MACHINEINPUTPOSSIBLE=''Y'''||CHR(10) 
        ||' ),0)'||CHR(10) 
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE ='''||P_DIVCODE||''' '||CHR(10)  
        ||'  AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')'||CHR(10)
        ||' AND A.FORTNIGHTENDDATE =TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10) 
        ||' AND A.DEPARTMENTCODE||A.SECTIONCODE'||CHR(10) 
        ||' IN'||CHR(10) 
        ||' ('||CHR(10) 
        ||' SELECT DEPARTMENTCODE||SECTIONCODE FROM WPSPRODUCTIONTYPEMAST'||CHR(10)
        ||' WHERE MACHINEINPUTPOSSIBLE=''Y'''||CHR(10) 
        ||' AND   COMPANYCODE = '''||P_COMPCODE||''''||CHR(10) 
        ||' AND   DIVISIONCODE = '''||P_DIVCODE||''''||CHR(10)
        ||' )'||CHR(10) ;         
        
   lv_remarks := NVL(lv_remarks,'XX ') ||'-04 UPDATE TOTALPRODUCTION TO 0';
  --dbms_output.put_line(lv_sql );   
   INSERT INTO WPS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
   VALUES (P_COMPCODE,P_DIVCODE,lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);
   EXECUTE IMMEDIATE lv_sql;
    COMMIT; 
--END   UPDATE MACHINEALLICABLE PRODUCTION TO 0 
    
  EXCEPTION
    WHEN OTHERS THEN
      lv_sqlerrm := sqlerrm ;
      insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
      values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm, lv_sql, lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
                                  
end;
/


