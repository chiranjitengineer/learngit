DROP PROCEDURE NJMCL_WEB.PRC_WPSWAGES_NSA_PFLINK_UPDT;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PRC_WPSWAGES_NSA_PFLINK_UPDT(
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
    lv_ProcName varchar2(30) := 'PRC_WPSWAGES_NSA_PFLINK_UPDT';
    lv_sqlerrm  varchar2(200) := '';
    lv_fn_stdt date := to_date(P_FNSTDT,'DD/MM/YYYY');
    lv_fn_endt date := to_date(P_FNENDT,'DD/MM/YYYY');  
    lv_parvalues varchar2(400):='';
    lv_cnt number:=0;
    lv_DetailsTable VARCHAR2(30) := '';
BEGIN

    
    IF INSTR(P_TABLENAME,'_SWT') > 0 THEN
        lv_DetailsTable :='WPSWAGESDETAILS_SWT';
    ELSE
        lv_DetailsTable :='WPSWAGESDETAILS';
    END IF;
    
    
    lv_Remarks:='NS_HRS, NS_ALLOW. UPDATE IN PF LINK NS ALLOW NS_HRS  - WPSWAGESDETAILS';
    
    
    lv_SQL := ' UPDATE '||lv_DetailsTable||'  SET NS_HRS_PFLINK = NIGHTALLOWANCEHOURS, NS_ALLOW_PFLINK = NS_ALLOW '||chr(10)
            ||' WHERE DEPARTMENTCODE||SECTIONCODE IN (SELECT DEPARTMENTCODE||SECTIONCODE '||CHR(10) 
            ||' FROM VW_WPSSECTIONMAST '||chr(10)
            ||' WHERE COMPANYCODE='''||P_COMPCODE||''' AND DIVISIONCODE='''||P_DIVCODE||''' AND NVL(PFLINKHOURS,0)>0) '||CHR(10)
            ||'   AND FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' AND FORTNIGHTENDDATE = '''||lv_fn_endt||''' '||chr(10)
            ||'   AND WORKERCATEGORYCODE <> ''R'' '||CHR(10);
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'', lv_sql, lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
    EXECUTE IMMEDIATE lv_sql;            
    COMMIT;
    lv_Remarks:='NS_HRS, NS_ALLOW. UPDATE IN NON PF LINK NS ALLOW NS_HRS  - WPSWAGESDETAILS';

    lv_Sql := ' UPDATE '||lv_DetailsTable||' WPSWAGESDETAILS  SET NS_HRS_NONPFLINK = NIGHTALLOWANCEHOURS, NS_ALLOW_NONPFLINK = NS_ALLOW '||chr(10)
            ||' WHERE DEPARTMENTCODE||SECTIONCODE IN (SELECT DEPARTMENTCODE||SECTIONCODE '||chr(10) 
            ||' FROM VW_WPSSECTIONMAST WHERE COMPANYCODE='''||P_COMPCODE||''' AND DIVISIONCODE='''||P_DIVCODE||''' '||chr(10)
            ||'   AND FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' AND FORTNIGHTENDDATE = '''||lv_fn_endt||''' '||chr(10) 
            ||'  AND nvl(PFLINKHOURS,0)<=0) '||chr(10);


    insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'', lv_sql, lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
    EXECUTE IMMEDIATE lv_sql;            
    COMMIT;
    
    lv_Remarks:='NS_HRS, NS_ALLOW. UPDATE IN NON PF LINK NS ALLOW NS_HRS FOR R-CATG  - WPSWAGESDETAILS';

    lv_Sql := ' UPDATE '||lv_DetailsTable||'  SET NS_HRS_PFLINK = 0, NS_ALLOW_PFLINK = 0, '||chr(10) 
            ||' NS_HRS_NONPFLINK = NIGHTALLOWANCEHOURS, NS_ALLOW_NONPFLINK = NS_ALLOW '||chr(10)
            ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE='''||P_DIVCODE||''' '||CHR(10)
            ||'   AND FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' AND FORTNIGHTENDDATE = '''||lv_fn_endt||''' '||chr(10)
            ||'   AND WORKERCATEGORYCODE=''R'' '||CHR(10);
    
    
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'', lv_sql, lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
    EXECUTE IMMEDIATE lv_sql;            
    COMMIT;
    
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE TMP_WPSNSHRSUPDATE_SWT';
    EXCEPTION
        WHEN OTHERS THEN NULL;    
    END ;
    
    lv_Remarks:='TEMP TABLE CREATE FOR '||P_TABLENAME||' UPDATE';
    lv_Sql := ' CREATE TABLE TMP_WPSNSHRSUPDATE_SWT AS '||CHR(10)
            ||' SELECT WORKERSERIAL, FORTNIGHTSTARTDATE,  '||CHR(10)
            ||' SUM(NVL(NS_HRS_PFLINK,0)) NS_HRS_PFLINK, SUM(NVL(NS_ALLOW_PFLINK,0)) NS_ALLOW_PFLINK, SUM(NVL(NS_HRS_NONPFLINK,0)) NS_HRS_NONPFLINK,  '||CHR(10) 
            ||' SUM(NVL(NS_ALLOW_NONPFLINK,0)) NS_ALLOW_NONPFLINK  '||CHR(10)
            ||' FROM '||lv_DetailsTable||'  '||CHR(10)
            ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE='''||P_DIVCODE||''' '||CHR(10)
            ||'   AND FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' AND FORTNIGHTENDDATE = '''||lv_fn_endt||''' '||chr(10)
            ||' GROUP BY WORKERSERIAL, FORTNIGHTSTARTDATE '||CHR(10);
        
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'', lv_sql, lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
    EXECUTE IMMEDIATE lv_sql;            
    COMMIT;

    lv_Remarks:='NS_HRS, NS_ALLOW UPDATE IN '||P_TABLENAME||'';
    lv_Sql := ' UPDATE '||P_TABLENAME||' A SET (A.NS_HRS_PFLINK, A.NS_ALLOW_PFLINK, A.NS_HRS_NONPFLINK, A.NS_ALLOW_NONPFLINK) =  '||CHR(10)
            ||' ( SELECT B.NS_HRS_PFLINK, B.NS_ALLOW_PFLINK, B.NS_HRS_NONPFLINK, B.NS_ALLOW_NONPFLINK '||CHR(10)
            ||'   FROM TMP_WPSNSHRSUPDATE_SWT B '||CHR(10) 
            ||'   WHERE A.WORKERSERIAL = B.WORKERSERIAL AND A.FORTNIGHTSTARTDATE=B.FORTNIGHTSTARTDATE '||CHR(10)
            ||' ) '||CHR(10)
            ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE='''||P_DIVCODE||''' '||CHR(10)
            ||'   AND A.FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' AND A.FORTNIGHTENDDATE = '''||lv_fn_endt||''' '||chr(10)
            ||'   AND A.WORKERSERIAL IN (SELECT WORKERSERIAL FROM TMP_WPSNSHRSUPDATE_SWT) '||CHR(10);
 
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


