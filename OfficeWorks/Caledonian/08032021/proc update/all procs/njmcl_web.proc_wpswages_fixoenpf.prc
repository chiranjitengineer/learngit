DROP PROCEDURE NJMCL_WEB.PROC_WPSWAGES_FIXOENPF;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPSWAGES_FIXOENPF(
    P_COMPCODE varchar2, P_DIVCODE varchar2, P_YEARCODE Varchar2,
    P_FNSTDT varchar2,P_FNENDT varchar2,P_PHASE NUMBER,
    P_PHASE_TABLENAME VARCHAR2,
    P_TABLENAME varchar2 DEFAULT 'WPSWAGESDETAILS',
    P_WORKERSERIAL varchar2 DEFAULT NULL
)

AS  
    lv_sql varchar2(10000):='';
    lv_Remarks varchar2(200); 
    lv_ProcName varchar2(30) := 'PROC_WPSWAGES_FIXOENPF';
    lv_sqlerrm  varchar2(200) := '';
    lv_fn_stdt date := to_date(P_FNSTDT,'DD/MM/YYYY');
    lv_fn_endt date := to_date(P_FNENDT,'DD/MM/YYYY');  
    lv_parvalues varchar2(400):='';
    lv_cnt number:=0;
BEGIN

    PROC_WPSOTHRCOMPONENTPAYMENT(P_COMPCODE,P_DIVCODE,P_FNSTDT,P_FNENDT,'WPSOTHERCOMPONENTPAYMENT','FIX_OENPF');
    
    lv_sql := 'SELECT COUNT(1) FROM COL WHERE TNAME='''||P_PHASE_TABLENAME||'''';
    EXECUTE IMMEDIATE lv_sql INTO lv_cnt;
    
    IF lv_cnt>0 THEN
        lv_sql :='DROP TABLE '||P_PHASE_TABLENAME;
        EXECUTE IMMEDIATE lv_sql;
    END IF;
    lv_Remarks:='TEMP TABLE CREATE';
    lv_sql:='CREATE TABLE '||P_PHASE_TABLENAME||CHR(10)
          ||'AS'||CHR(10)
          ||'('||CHR(10)
          ||'   SELECT A.COMPANYCODE,DIVISIONCODE,A.WORKERSERIAL,A.FORTNIGHTSTARTDATE,A.FORTNIGHTENDDATE, B.SECTIONCODE,A.COMPONENTAMOUNT'||CHR(10)
          ||'   FROM WPSOTHERCOMPONENTPAYMENT A,('||CHR(10)
          ||'                                       SELECT A.WORKERSERIAL, MAX(SECTIONCODE) SECTIONCODE FROM '||P_TABLENAME||' A,'||CHR(10)
          ||'                                       ('||CHR(10)
          ||'                                           SELECT WORKERSERIAL, MAX(NVL(ATTENDANCEHOURS,0)+NVL(OVERTIMEHOURS,0)) HRS'||CHR(10)
          ||'                                           FROM '||P_TABLENAME||CHR(10)
          ||'                                           WHERE FORTNIGHTSTARTDATE=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')'||CHR(10)
          ||'                                               AND  FORTNIGHTENDDATE=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10)
          ||'                                           GROUP BY WORKERSERIAL'||CHR(10)
          ||'                                        )  B '||CHR(10)
          ||'                                   WHERE A.WORKERSERIAL=B.WORKERSERIAL AND (NVL(A.ATTENDANCEHOURS,0)+NVL(A.OVERTIMEHOURS,0)) = B.HRS'||CHR(10)
          ||'                                   AND A.FORTNIGHTSTARTDATE=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')'||CHR(10)
          ||'                                   AND A.FORTNIGHTENDDATE=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10)
          ||'                                   GROUP BY A.WORKERSERIAL'||CHR(10)
          ||'                                 ) B'||CHR(10)
          ||'   WHERE A.WORKERSERIAL=B.WORKERSERIAL'||CHR(10)
          ||'     AND A.COMPONENTCODE=''FIX_OENPF'''||CHR(10)
          ||'     AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')'||CHR(10)
          ||'     AND A.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10)
          ||')'||CHR(10);
          
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'', lv_sql, lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
    EXECUTE IMMEDIATE lv_sql; 
    
    
    lv_Remarks:='UPDATE FIX_OENPF';
    lv_sql:='UPDATE '||P_TABLENAME||' A SET FIX_OENPF=('||CHR(10)
         ||'                                            SELECT COMPONENTAMOUNT FROM '||P_PHASE_TABLENAME||' B'||CHR(10)
         ||'                                            WHERE B.COMPANYCODE=A.COMPANYCODE'||CHR(10)
         ||'                                                AND B.DIVISIONCODE=A.DIVISIONCODE'||CHR(10)
         ||'                                                AND B.WORKERSERIAL=A.WORKERSERIAL'||CHR(10)
         ||'                                                AND B.FORTNIGHTSTARTDATE=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')'||CHR(10)
         ||'                                                AND B.FORTNIGHTENDDATE=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10)
         ||'                                                AND A.SECTIONCODE = B.SECTIONCODE'||CHR(10)
         ||'                                        )'||CHR(10)
         ||'WHERE A.FORTNIGHTSTARTDATE=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')'||CHR(10)
         ||'  AND A.FORTNIGHTENDDATE=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10)
         ||'  AND A.WORKERSERIAL IN (  SELECT WORKERSERIAL FROM '||P_PHASE_TABLENAME||' '||CHR(10)
         ||'                           WHERE COMPANYCODE ='''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
         ||'                             AND FORTNIGHTSTARTDATE=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')'||CHR(10)
         ||'                             AND FORTNIGHTENDDATE=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10)
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


