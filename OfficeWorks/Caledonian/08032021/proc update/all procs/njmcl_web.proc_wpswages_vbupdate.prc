DROP PROCEDURE NJMCL_WEB.PROC_WPSWAGES_VBUPDATE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPSWAGES_VBUPDATE(
    P_COMPCODE varchar2, P_DIVCODE varchar2, P_YEARCODE Varchar2,
    P_FNSTDT varchar2,P_FNENDT varchar2,P_PHASE NUMBER,
    P_PHASE_TABLENAME VARCHAR2,
    P_TABLENAME varchar2 DEFAULT 'WPSWAGESDETAILS',
    P_WORKERSERIAL varchar2 DEFAULT NULL,
    P_PROCESSTYPE  VARCHAR2 DEFAULT 'WAGES PROCESS'
)

AS  
    lv_sql varchar2(10000):='';
    lv_Remarks varchar2(200); 
    lv_ProcName varchar2(30) := 'PROC_WPSWAGES_VBUPDATE';
    lv_sqlerrm  varchar2(200) := '';
    lv_fn_stdt date := to_date(P_FNSTDT,'DD/MM/YYYY');
    lv_fn_endt date := to_date(P_FNENDT,'DD/MM/YYYY');  
    lv_parvalues varchar2(400):='';
    lv_cnt number:=0;
BEGIN


    
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
          ||'SELECT A.COMPANYCODE,DIVISIONCODE,A.WORKERSERIAL,A.FORTNIGHTSTARTDATE,A.FORTNIGHTENDDATE,A.DEPARTMENTCODE, A.SECTIONCODE,A.OCCUPATIONCODE,A.SHIFTCODE,A.DEPTSERIAL ,'||CHR(10)
           ||'SUM(NVL(VBAMOUNT,0))VBAMOUNT,SUM(NVL(ATTENDANCEHOURS,0))ATTENDANCEHOURS,'||CHR(10)
            ||'SUM(NVL(OVERTIMEHOURS,0))OVERTIMEHOURS,SUM(NVL(VBAMOUNT_OT,0))VBAMOUNT_OT,'||CHR(10)
             ||'SUM(NVL(NS_HOURS,0))NS_HOURS,SUM(NVL(VBAMOUNT_NS,0))VBAMOUNT_NS,'||CHR(10)
              ||'SUM(NVL(OTNS_HOURS,0))OTNS_HOURS,SUM(NVL(VBAMOUNT_OTNS,0))VBAMOUNT_OTNS,'||CHR(10)
               ||'SUM(NVL(FBKHOURS,0))FBKHOURS,SUM(NVL(VBAMOUNT_FBK,0))VBAMOUNT_FBK,'||CHR(10)
                ||'SUM(NVL(HOLIDAYHOURS,0))HOLIDAYHOURS,SUM(NVL(VBAMOUNT_HOLIDAY,0))VBAMOUNT_HOLIDAY,'||CHR(10)
                 ||'SUM(NVL(TOTAL_VBAMOUNT,0))TOTAL_VBAMOUNT,'||CHR(10)
                  ||'SUM(NVL(PF_ADJ,0))PF_ADJ,SUM(NVL(NPF_ADJ,0))NPF_ADJ'||CHR(10)
                  ||'FROM WPSVBDETAILS  A'||CHR(10)
                   ||'WHERE A.FORTNIGHTSTARTDATE=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')'||CHR(10)
                   ||'AND A.FORTNIGHTENDDATE =TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10)
                   ||'AND A.COMPANYCODE='''||P_COMPCODE||''''||CHR(10)
                   ||'AND A.DIVISIONCODE='''||P_DIVCODE||''''||CHR(10)
                   ||'GROUP BY A.COMPANYCODE,DIVISIONCODE,A.WORKERSERIAL,A.FORTNIGHTSTARTDATE,A.FORTNIGHTENDDATE,A.DEPARTMENTCODE, A.SECTIONCODE,A.OCCUPATIONCODE,A.SHIFTCODE,A.DEPTSERIAL'||CHR(10)
                   ||')'||CHR(10);
          
          
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'', lv_sql, lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
    EXECUTE IMMEDIATE lv_sql; 
    
    
    lv_Remarks:='UPDATE VBASIC,OT_AMOUNT,NS_ALLOW,NS_ALLOW_OT,FBK_WAGES,H_WAGES,PF_ADJ,NPF_ADJ';
    lv_sql:='UPDATE '||P_TABLENAME||' A SET (VBASIC,OT_AMOUNT,NS_ALLOW,NS_ALLOW_OT,FBK_WAGES,H_WAGES,PF_ADJ,NPF_ADJ)=('||CHR(10)
         ||'                                            SELECT VBAMOUNT,VBAMOUNT_OT,VBAMOUNT_NS,VBAMOUNT_OTNS,VBAMOUNT_FBK,VBAMOUNT_HOLIDAY,PF_ADJ,NPF_ADJ FROM '||P_PHASE_TABLENAME||' B'||CHR(10)
         ||'                                            WHERE B.COMPANYCODE=A.COMPANYCODE'||CHR(10)
         ||'                                                AND B.DIVISIONCODE=A.DIVISIONCODE'||CHR(10)
         ||'                                                AND B.WORKERSERIAL=A.WORKERSERIAL'||CHR(10)
         ||'                                                AND B.FORTNIGHTSTARTDATE=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')'||CHR(10)
         ||'                                                AND B.FORTNIGHTENDDATE=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10)
         ||'                                                AND A.SECTIONCODE = B.SECTIONCODE'||CHR(10)
         ||'                                                AND A.DEPARTMENTCODE = B.DEPARTMENTCODE'||CHR(10)
         ||'                                                AND A.SHIFTCODE = B.SHIFTCODE'||CHR(10)
         ||'                                                AND A.DEPTSERIAL = B.DEPTSERIAL'||CHR(10)
         ||'                                                AND A.OCCUPATIONCODE = B.OCCUPATIONCODE'||CHR(10)
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


