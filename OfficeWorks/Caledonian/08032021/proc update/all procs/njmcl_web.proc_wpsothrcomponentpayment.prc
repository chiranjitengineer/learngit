DROP PROCEDURE NJMCL_WEB.PROC_WPSOTHRCOMPONENTPAYMENT;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPSOTHRCOMPONENTPAYMENT
(
    P_COMPCODE varchar2,
    P_DIVCODE varchar2,
    P_FNSTDT varchar2,
    P_FNENDT varchar2,
    P_TABLENAME varchar2,
    P_COMPONENT varchar2,
    P_WORKERSERIAL varchar2 DEFAULT NULL
   )
AS  
    lv_sql varchar2(10000);
    lv_Remarks varchar2(200); 
    lv_ProcName varchar2(30) := 'PROC_WPSOTHRCOMPONENTPAYMENT';
    lv_sqlerrm  varchar2(200) := '';
    lv_fn_stdt date := to_date(P_FNSTDT,'DD/MM/YYYY');
    lv_fn_endt date := to_date(P_FNENDT,'DD/MM/YYYY');  
    lv_parvalues varchar2(400);
BEGIN
        
        lv_parvalues:=P_COMPCODE||','|| P_DIVCODE||','|| P_FNSTDT||','|| P_FNENDT||','|| P_TABLENAME||','|| P_COMPONENT||','|| P_WORKERSERIAL;
        lv_Remarks := 'DELETE NPF ADJUSTEMNT DATA';
        lv_sql:='DELETE FROM '||P_TABLENAME ||' '|| chr(10)
            ||  'WHERE COMPANYCODE='''|| P_COMPCODE ||''' AND DIVISIONCODE='''|| P_DIVCODE||''' '|| chr(10)
            ||  'AND FORTNIGHTSTARTDATE=to_date('''|| P_FNSTDT ||''',''DD/MM/YYYY'') AND FORTNIGHTENDDATE=to_date('''||P_FNENDT||''',''DD/MM/YYYY'') '|| chr(10);
            
             --dbms_output.put_line(lv_sql);
            insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
            values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm, lv_Sql, lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
            EXECUTE IMMEDIATE lv_Sql;  
            COMMIT;
                    
             
        lv_Remarks := 'INSERT NPF ADJUSTEMNT DATA';
        lv_sql:='';
             
        lv_sql:='INSERT INTO WPSOTHERCOMPONENTPAYMENT ' || chr(10)
                ||  'SELECT COMPANYCODE, DIVISIONCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERSERIAL, TOKENNO, ' || chr(10)
                ||  'WORKERCATEGORYCODE, SHIFTCODE, COMPONENTCODE, ATTENDANCEHOURS, OVERTIMEHOURS, COMPONENTAMOUNT, TRANSACTIONTYPE, USERNAME, LASTMODIFIED, SYSROWID FROM ' || chr(10)
                ||  '( ' || chr(10)
                ||  'SELECT A.COMPANYCODE,A.DIVISIONCODE,A.FORTNIGHTSTARTDATE,A.FORTNIGHTENDDATE,A.WORKERSERIAL,A.TOKENNO, ' || chr(10) 
                ||  'A.WORKERCATEGORYCODE,'''' SHIFTCODE,'''||P_COMPONENT ||''' COMPONENTCODE, ' || chr(10)
                ||  'SUM(ATTENDANCEHOURS) ATTENDANCEHOURS, SUM(OVERTIMEHOURS) OVERTIMEHOURS, ' || chr(10)
                ||  'B.ADJUSTMENTTYPE,' || chr(10)
                ||  'CASE  ' || chr(10)
                ||    'WHEN B.ADJUSTMENTTYPE =''LUMPSUM''  ' || chr(10)
                ||        'THEN B.NPFAMOUNT ' || chr(10) 
                ||     'ELSE ' || chr(10) 
                ||     'CASE WHEN B.HOURTYPE = ''NORMAL'' THEN ROUND((NPFAMOUNT/B.WORKINGHOUR)*(SUM(ATTENDANCEHOURS)),2) ' || chr(10) 
                ||     'ELSE ROUND((NPFAMOUNT/B.WORKINGHOUR)*(SUM(ATTENDANCEHOURS)+SUM(OVERTIMEHOURS)),2) ' || chr(10) 
                ||     'END END COMPONENTAMOUNT,  ' || chr(10)
                ||  ''''' TRANSACTIONTYPE,''SWT'' USERNAME,SYSDATE LASTMODIFIED,SYS_GUID() SYSROWID ' || chr(10)   
                ||  'FROM WPSATTENDANCEDAYWISE A, ' || chr(10)
                ||  '(  ' || chr(10)
                ||  'SELECT X.COMPANYCODE,X.DIVISIONCODE,X.WORKERSERIAL,X.TOKENNO,X.ADJUSTMENTTYPE,X.HOURTYPE,X.WORKINGHOUR,X.NPFAMOUNT FROM WPSNPFADJUSTMENTPARAMETER X, ' || chr(10)
                ||  '( ' || chr(10)
                ||  'SELECT COMPANYCODE,DIVISIONCODE,WORKERSERIAL,MAX(EFFECTIVEDATE) EFFECTIVEDATE ' || chr(10) 
                ||      'FROM WPSNPFADJUSTMENTPARAMETER WHERE EFFECTIVEDATE<TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')    ' || chr(10)
                ||      'GROUP BY COMPANYCODE,DIVISIONCODE,WORKERSERIAL ' || chr(10)
                ||  ') Y ' || chr(10)
                ||  'WHERE X.COMPANYCODE =  Y.COMPANYCODE AND X.DIVISIONCODE = Y.DIVISIONCODE ' || chr(10)
                ||    'AND X.WORKERSERIAL = Y.WORKERSERIAL AND X.EFFECTIVEDATE = Y.EFFECTIVEDATE ' || chr(10)
                ||  ') B ' || chr(10)
                ||  'WHERE A.COMPANYCODE ='''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' ' || chr(10)
                ||  'AND A.DATEOFATTENDANCE >= TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'') ' || chr(10)
                ||  'AND A.DATEOFATTENDANCE <= TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') ' || chr(10)
                ||  'AND A.WORKERSERIAL = B.WORKERSERIAL ' || chr(10)
                ||  'GROUP BY A.COMPANYCODE,A.DIVISIONCODE,A.FORTNIGHTSTARTDATE,A.FORTNIGHTENDDATE,A.WORKERSERIAL,A.TOKENNO,A.WORKERCATEGORYCODE, ' || chr(10)
                ||  'B.ADJUSTMENTTYPE, B.HOURTYPE, B.NPFAMOUNT, B.WORKINGHOUR )' || chr(10);
               
  --dbms_output.put_line(lv_sql);
  
        insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
        values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm, lv_Sql, lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
        EXECUTE IMMEDIATE lv_Sql;  
        COMMIT;
        
exception
    when others then
    lv_sqlerrm := sqlerrm ;
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm, lv_Sql, lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
    commit;
  
END;
/


