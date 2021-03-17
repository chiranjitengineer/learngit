DROP PROCEDURE NJMCL_WEB.PROC_WPSFIXOENPF_TRANSFER;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPSFIXOENPF_TRANSFER(
    P_COMPCODE varchar2,
    P_DIVCODE varchar2,
    P_FNSTDT varchar2,
    P_FNENDT varchar2,
    P_TABLENAME varchar2 DEFAULT 'WPSWAGESDETAILS',
    --P_COMPONENT varchar2,
    P_WORKERSERIAL varchar2 DEFAULT NULL
)
AS  
    lv_sql varchar2(10000):='';
    lv_Remarks varchar2(200); 
    lv_ProcName varchar2(30) := 'PROC_WPSFIXOENPF_TRANSFER';
    lv_sqlerrm  varchar2(200) := '';
    lv_fn_stdt date := to_date(P_FNSTDT,'DD/MM/YYYY');
    lv_fn_endt date := to_date(P_FNENDT,'DD/MM/YYYY');  
    lv_parvalues varchar2(400):='';
BEGIN

    PROC_WPSOTHRCOMPONENTPAYMENT(P_COMPCODE,P_DIVCODE,P_FNSTDT,P_FNENDT,'WPSOTHERCOMPONENTPAYMENT','FIX_OENPF');
    
    lv_Remarks:='UPDATE FIX_OENPF';
    lv_sql:='UPDATE '||P_TABLENAME||' A SET FIX_OENPF=('||CHR(10)
         ||'                                            SELECT COMPONENTAMOUNT FROM WPSOTHERCOMPONENTPAYMENT B'||CHR(10)
         ||'                                            WHERE B.COMPANYCODE=A.COMPANYCODE'||CHR(10)
         ||'                                                AND B.DIVISIONCODE=A.DIVISIONCODE'||CHR(10)
         ||'                                                AND B.WORKERSERIAL=A.WORKERSERIAL'||CHR(10)
         ||'                                                AND B.FORTNIGHTSTARTDATE=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')'||CHR(10)
         ||'                                                AND B.FORTNIGHTENDDATE=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10)
         ||'                                                AND A.SECTIONCODE =('||CHR(10)
         ||'                                                                        SELECT MAX(SECTIONCODE) FROM WPSWAGESDETAILS_SWT'||CHR(10)
         ||'                                                                        WHERE WORKERSERIAL=A.WORKERSERIAL'||CHR(10)
         ||'                                                                            AND FORTNIGHTSTARTDATE= TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')'||CHR(10)
         ||'                                                                            AND FORTNIGHTENDDATE=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10)
         ||'                                                                            AND NVL(ATTENDANCEHOURS,0)+NVL(OVERTIMEHOURS,0)=('||CHR(10)
         ||'                                                                                                                                SELECT MAX(NVL(ATTENDANCEHOURS,0)+NVL(OVERTIMEHOURS,0)) FROM WPSWAGESDETAILS_SWT'||CHR(10)
         ||'                                                                                                                                WHERE WORKERSERIAL=A.WORKERSERIAL'||CHR(10)
         ||'                                                                                                                                    AND FORTNIGHTSTARTDATE= TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')'||CHR(10)
         ||'                                                                                                                                    AND FORTNIGHTENDDATE=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10)
         ||'                                                                                                                            )'||CHR(10)
         ||'                                                                  )'||CHR(10)
         ||'                                        )'||CHR(10)
         ||'WHERE A.FORTNIGHTSTARTDATE=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')'||CHR(10)
         ||'AND A.FORTNIGHTENDDATE=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')'||CHR(10);
         
    DBMS_OUTPUT.PUT_LINE(lv_sql);  
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm, lv_sql, lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
    EXECUTE IMMEDIATE lv_sql;  
    COMMIT;
         
END;
/


