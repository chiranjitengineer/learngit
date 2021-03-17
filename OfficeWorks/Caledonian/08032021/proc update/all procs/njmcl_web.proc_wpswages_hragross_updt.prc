DROP PROCEDURE NJMCL_WEB.PROC_WPSWAGES_HRAGROSS_UPDT;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPSWAGES_HRAGROSS_UPDT(
    P_COMPCODE varchar2, P_DIVCODE varchar2, P_YEARCODE Varchar2,
    P_FNSTDT varchar2,P_FNENDT varchar2,P_PHASE NUMBER,
    P_PHASE_TABLENAME VARCHAR2,
    P_TABLENAME varchar2 DEFAULT 'WPSWAGESDETAILS_SWT',
    P_WORKERSERIAL varchar2 DEFAULT NULL,
    P_PROCESSTYPE  VARCHAR2 DEFAULT 'WAGES PROCESS'
)

AS  
    lv_sql varchar2(10000):='';
    lv_Remarks varchar2(200); 
    lv_ProcName varchar2(30) := 'PROC_WPSWAGES_HRAGROSS_UPDT';
    lv_sqlerrm  varchar2(200) := '';
    lv_fn_stdt date := to_date(P_FNSTDT,'DD/MM/YYYY');
    lv_fn_endt date := to_date(P_FNENDT,'DD/MM/YYYY');  
    lv_parvalues varchar2(400):='';
    lv_cnt number:=0;
   
    lv_prv_fn_endt  date;
    lv_mn_stdt      date := to_date('01/'||substr(P_FNSTDT,4),'DD/MM/YYYY');
    lv_prev_fn_stdt  date := to_date('01/'||substr(P_FNSTDT,4),'DD/MM/YYYY');
BEGIN


    IF SUBSTR(P_FNSTDT,1,2) = '01' THEN
        RETURN;
    END IF;   
    

    SELECT TO_DATE(FN_GETFORTNIGHTSTARTENDDATE(TO_CHAR(lv_mn_stdt,'DD/MM/YYYY'),'END'),'DD/MM/YYYY') INTO lv_prv_fn_endt FROM DUAL;
    
    lv_sql := 'SELECT COUNT(1) FROM COL WHERE TNAME='''||P_PHASE_TABLENAME||'''';
    EXECUTE IMMEDIATE lv_sql INTO lv_cnt;
    
    IF lv_cnt>0 THEN
        lv_sql :='DROP TABLE '||P_PHASE_TABLENAME;
        EXECUTE IMMEDIATE lv_sql;
    END IF;
    lv_Remarks:='1 TEMP TABLE CREATE';
    lv_sql:='CREATE TABLE '||P_PHASE_TABLENAME||CHR(10)
          ||'AS'||CHR(10)
          ||' SELECT A.WORKERSERIAL, SHIFTCODE, DEPARTMENTCODE, SECTIONCODE, OCCUPATIONCODE, DEPTSERIAL ,X.GROSS_FOR_HRA'||CHR(10)
          ||' FROM WPSWAGESDETAILS_SWT A,'||CHR(10)
          ||' ('||CHR(10)
          ||'    SELECT WORKERSERIAL, MAX(DEPARTMENTCODE||SECTIONCODE||OCCUPATIONCODE||DEPTSERIAL||SHIFTCODE) MAXDEPTSFTSECOCPDEPTSRL'||CHR(10)
          ||'    FROM ('||CHR(10)
          ||'            SELECT A.WORKERSERIAL, A.SHIFTCODE, A.DEPARTMENTCODE, A.SECTIONCODE, A.OCCUPATIONCODE,A.DEPTSERIAL'||CHR(10)
          ||'            FROM WPSWAGESDETAILS_SWT A,'||CHR(10)
          ||'            ('||CHR(10)
          ||'                SELECT WORKERSERIAL, MAX(NVL(ATTENDANCEHOURS,0)) MAX_ATTN_HRS, MAX(NVL(OVERTIMEHOURS,0)) MAX_OT_HRS '||CHR(10)
          ||'                FROM WPSWAGESDETAILS_SWT'||CHR(10)
          ||'                WHERE COMPANYCODE ='''||P_COMPCODE||''' AND DIVISIONCODE ='''||P_DIVCODE||''''||CHR(10)
          ||'                  AND YEARCODE ='''||P_YEARCODE||''''||CHR(10)
          ||'                  AND FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')'||CHR(10)
          ||'                  AND FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10)
          ||'                GROUP BY WORKERSERIAL'||CHR(10)
          ||'            ) B'||CHR(10)
          ||'            WHERE A.COMPANYCODE ='''||P_COMPCODE||''' AND A.DIVISIONCODE ='''||P_DIVCODE||''' '||CHR(10)
          ||'              AND A.YEARCODE ='''||P_YEARCODE||''''||CHR(10)
          ||'              AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')'||CHR(10)
          ||'              AND A.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10)
          ||'              AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
          ||'              AND NVL(A.ATTENDANCEHOURS,0)= NVL(B.MAX_ATTN_HRS ,0)'||CHR(10)
          ||'              AND NVL(B.MAX_ATTN_HRS,0) > 0'||CHR(10)
          ||'         )'||CHR(10)
          ||'    GROUP BY WORKERSERIAL'||CHR(10)
          ||'    UNION ALL'||CHR(10)
          ||'    SELECT WORKERSERIAL, MAX(DEPARTMENTCODE||SECTIONCODE||OCCUPATIONCODE||DEPTSERIAL||SHIFTCODE) MAXDEPTSFTSECOCPDEPTSRL'||CHR(10)
          ||'    FROM ('||CHR(10)
          ||'            SELECT A.WORKERSERIAL, A.SHIFTCODE, A.DEPARTMENTCODE, A.SECTIONCODE, A.OCCUPATIONCODE,A.DEPTSERIAL'||CHR(10)
          ||'            FROM WPSWAGESDETAILS_SWT A, '||CHR(10)
          ||'            ('||CHR(10)
          ||'                SELECT WORKERSERIAL, MAX(ATTENDANCEHOURS) MAX_ATTN_HRS, MAX(OVERTIMEHOURS) MAX_OT_HRS'||CHR(10)
          ||'                FROM WPSWAGESDETAILS_SWT'||CHR(10)
          ||'                WHERE COMPANYCODE ='''||P_COMPCODE||''' AND DIVISIONCODE ='''||P_DIVCODE||''''||CHR(10)
          ||'                  AND YEARCODE ='''||P_YEARCODE||''''||CHR(10)
          ||'                  AND FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')'||CHR(10)
          ||'                  AND FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10)
          ||'                GROUP BY WORKERSERIAL'||CHR(10)
          ||'            ) B'||CHR(10)
          ||'            WHERE A.COMPANYCODE ='''||P_COMPCODE||''' AND A.DIVISIONCODE ='''||P_DIVCODE||''''||CHR(10)
          ||'              AND A.YEARCODE ='''||P_YEARCODE||''' '||CHR(10)
          ||'              AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')'||CHR(10)
          ||'              AND A.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10)
          ||'              AND A.WORKERSERIAL = B.WORKERSERIAL'||CHR(10)
          ||'              AND NVL(B.MAX_ATTN_HRS,0) <= 0'||CHR(10)
          ||'              AND NVL(A.OVERTIMEHOURS,0) = NVL(B.MAX_OT_HRS,0)'||CHR(10)
          ||'       ) '||CHR(10)
          ||'     GROUP BY WORKERSERIAL '||CHR(10)
          ||' ) B'||CHR(10)
          ||',(  '||CHR(10)
          ||'   SELECT WORKERSERIAL, SUM(GROSS_FOR_HRA) GROSS_FOR_HRA  '||CHR(10)
          ||'   FROM (  '||CHR(10)
          ||'           SELECT WORKERSERIAL, NVL(GROSS_FOR_HRA,0) GROSS_FOR_HRA  '||CHR(10)
          ||'           FROM WPSWAGESDETAILS_MV  '||CHR(10)
          ||'           WHERE COMPANYCODE ='''||P_COMPCODE||''' AND DIVISIONCODE ='''||P_DIVCODE||'''  '||CHR(10)
          ||'             AND YEARCODE ='''||P_YEARCODE||'''   '||CHR(10)
          ||'             AND FORTNIGHTSTARTDATE = '''||lv_prev_fn_stdt||'''  '||CHR(10)
          ||'             AND FORTNIGHTENDDATE = '''||lv_prv_fn_endt||'''  '||CHR(10)
          ||'           UNION ALL  '||CHR(10)
          ||'           SELECT WORKERSERIAL, STLAMOUNT GROSS_FOR_HRA  '||CHR(10)
          ||'           FROM WPSSTLWAGESDETAILS  '||CHR(10)
          ||'           WHERE COMPANYCODE ='''||P_COMPCODE||''' AND DIVISIONCODE ='''||P_DIVCODE||'''  '||CHR(10)
          ||'             AND YEARCODE ='''||P_YEARCODE||'''   '||CHR(10)
          ||'             AND PAYMENTDATE >= '''||lv_prev_fn_stdt||'''  '||CHR(10)
          ||'             AND PAYMENTDATE <= '''||lv_fn_endt||'''  '||CHR(10)
          ||'        )    '||CHR(10)      
          ||'    GROUP BY WORKERSERIAL  '||CHR(10)    
          ||' ) X  '||CHR(10)
          ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
          ||'   AND A.YEARCODE = '''||P_YEARCODE||''''||CHR(10)
          ||'   AND A.FORTNIGHTSTARTDATE =TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'') AND A.FORTNIGHTENDDATE =TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10)
          ||'   AND A.DEPARTMENTCODE||A.SECTIONCODE||A.OCCUPATIONCODE||A.DEPTSERIAL||A.SHIFTCODE = B.MAXDEPTSFTSECOCPDEPTSRL'||CHR(10)
          ||'   AND A.WORKERSERIAL = B.WORKERSERIAL'||CHR(10)
          ||'   AND A.WORKERSERIAL = X.WORKERSERIAL'||CHR(10);
  
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'', lv_sql, lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
    EXECUTE IMMEDIATE lv_sql; 
    
    
--    lv_Remarks:='2 UPDATE GROSS_FOR_HRA IN '||P_PHASE_TABLENAME||' TABLES';
--    lv_sql:='UPDATE '||P_PHASE_TABLENAME||' A SET A.GROSS_FOR_HRA=('||CHR(10)
--    ||' SELECT GROSS_FOR_HRA FROM('||CHR(10)
--    ||' SELECT WORKERSERIAL,SUM(GROSS_FOR_HRA) GROSS_FOR_HRA'||CHR(10)
--    ||'    FROM ('||CHR(10)
--    ||'        SELECT WORKERSERIAL,  GROSS_FOR_HRA'||CHR(10)
--    ||'        FROM WPSWAGESDETAILS_MV'||CHR(10)
--    ||'        WHERE COMPANYCODE='''||P_COMPCODE||''' AND DIVISIONCODE ='''||P_DIVCODE||''''||CHR(10)
--    ||'          AND YEARCODE ='''||P_YEARCODE||''''||CHR(10)
--    ||'          AND FORTNIGHTSTARTDATE ='''||lv_prev_fn_stdt||''' AND FORTNIGHTENDDATE ='''||lv_prv_fn_endt||''''||CHR(10)
--    ||'        UNION ALL'||CHR(10)
--    ||'        SELECT WORKERSERIAL, PF_GROSS GROSS_FOR_HRA'||CHR(10)
--    ||'        FROM WPSSTLWAGESDETAILS'||CHR(10)
--    ||'        WHERE COMPANYCODE='''||P_COMPCODE||''' AND DIVISIONCODE ='''||P_DIVCODE||''''||CHR(10)
--    ||'          AND YEARCODE ='''||P_YEARCODE||''''||CHR(10)
--    ||'          AND PAYMENTDATE >='''||lv_prev_fn_stdt||''' AND PAYMENTDATE <=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10)
--    ||'    )'||CHR(10)
--    ||'GROUP BY WORKERSERIAL'||CHR(10)
--    ||')X WHERE X.WORKERSERIAL=A.WORKERSERIAL'||CHR(10)
--    ||')'||CHR(10)
--    ||'WHERE 1=1'||CHR(10)
--    ||'AND WORKERSERIAL'||CHR(10)
--    ||'IN'||CHR(10)
--    ||'('||CHR(10)
--    ||'SELECT DISTINCT WORKERSERIAL FROM WPS_MAX_DEPT_HRA'||CHR(10)
--    ||')'||CHR(10);
--    insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
--    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'', lv_sql, lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
--    EXECUTE IMMEDIATE lv_sql;  
--    COMMIT;
    
    lv_Remarks:='3 DELETE GROSS_FOR_HRA IN '||P_PHASE_TABLENAME||' TABLES';
    lv_sql:='DELETE FROM '||P_PHASE_TABLENAME||' WHERE NVL(GROSS_FOR_HRA,0)=0'||CHR(10);  
    --DBMS_OUTPUT.PUT_LINE(lv_sql);  
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'', lv_sql, lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
    EXECUTE IMMEDIATE lv_sql;

    lv_Remarks:='4 UPDATE GROSS_FOR_HRA IN '||P_TABLENAME||' TABLES';
    lv_sql:='UPDATE '||P_TABLENAME||' A SET (GROSS_FOR_HRA)=NVL(GROSS_FOR_HRA,0)+('||CHR(10)
         ||'                                            SELECT NVL(GROSS_FOR_HRA,0) FROM '||P_PHASE_TABLENAME||' B'||CHR(10)
         ||'                                            WHERE 1=1'||CHR(10)
         ||'                                                AND B.WORKERSERIAL=A.WORKERSERIAL'||CHR(10)
         ||'                                                AND A.SHIFTCODE = B.SHIFTCODE'||CHR(10)       
         ||'                                                AND A.DEPARTMENTCODE = B.DEPARTMENTCODE'||CHR(10)        
         ||'                                                AND A.SECTIONCODE = B.SECTIONCODE'||CHR(10)
         ||'                                                AND A.OCCUPATIONCODE = B.OCCUPATIONCODE'||CHR(10)
         ||'                                                AND A.DEPTSERIAL = B.DEPTSERIAL'||CHR(10)
         ||'                                        )'||CHR(10)
         ||'WHERE A.FORTNIGHTSTARTDATE=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')'||CHR(10)
         ||'  AND A.FORTNIGHTENDDATE=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10)
         ||'  AND A.COMPANYCODE ='''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''''||CHR(10)
         ||'  AND A.WORKERSERIAL||A.SHIFTCODE||A.DEPARTMENTCODE||A.SECTIONCODE||A.OCCUPATIONCODE||A.DEPTSERIAL IN (  SELECT WORKERSERIAL||SHIFTCODE||DEPARTMENTCODE||SECTIONCODE||OCCUPATIONCODE||DEPTSERIAL FROM '||P_PHASE_TABLENAME||' '||CHR(10)
         ||'                        )'||CHR(10);           
    --DBMS_OUTPUT.PUT_LINE(lv_sql);  
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'', lv_sql, lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
    EXECUTE IMMEDIATE lv_sql;  
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
      lv_sqlerrm := sqlerrm ;
      insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
      values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm, lv_sql, lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
              
END;
/


