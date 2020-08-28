CREATE OR REPLACE PROCEDURE JOONK.PRC_PISSALARYPROCESS_TRANSFER (
                                                  P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2,
                                                  P_TRANTYPE Varchar2, 
                                                  P_PHASE  number, 
                                                  P_YEARMONTH Varchar2,
                                                  P_EFFECTYEARMONTH Varchar2, 
                                                  P_TABLENAME Varchar2,
                                                  P_PHASE_TABLENAME Varchar2,
                                                  P_UNIT  Varchar2,
                                                  P_CATEGORY    Varchar2  DEFAULT NULL,
                                                  P_GRADE       Varchar2  DEFAULT NULL,
                                                  P_DEPARTMENT  Varchar2  DEFAULT NULL,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL
)
as

lv_fn_stdt DATE := TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY');
lv_fn_endt DATE := LAST_DAY(TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY'));
lv_TableName        varchar2(50);
lv_Remarks          varchar2(1000) := '';
lv_SqlStr           varchar2(4000);
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';   
lv_ProcName     varchar2(30) := 'PRC_PISSALARYPROCESS_TRANSFER';
lv_Sql_TblCreate    varchar2(4000) := '';
lv_Component        varchar2(4000) := ''; 
lv_SqlComponent     varchar2(2000) := '';

begin
    lv_remarks := 'PHASE - '||P_PHASE||' START';
    lv_parvalues := 'COMP='||P_COMPCODE||',DIV = '||P_DIVCODE||', YEARMONTH = '||P_YEARMONTH||', EFF.YEARMONTH'||P_EFFECTYEARMONTH||',PHASE='||P_PHASE;
    
    lv_SqlStr := ' delete from '||P_TABLENAME||' WHERE COMPANYCODE = '''||P_COMPCODE||''' '||CHR(10)
               ||' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10) 
--               ||' AND YEARMONTH = '''||P_EFFECTYEARMONTH||''' '||CHR(10) -- FOR ARREAR PROCESS INSTEADE OF EFFECTYEARMONTH YEARMONTH IS USE BISHWANATH 02/11/2019
               ||' AND YEARMONTH = '''||P_YEARMONTH||''' '||CHR(10)
               ||' AND TRANSACTIONTYPE =  '''||P_TRANTYPE||''' '||CHR(10)
               ||' AND UNITCODE = '''||P_UNIT||''' '||CHR(10);
        IF NVL(P_CATEGORY,'AMALESH_SWT') <> 'AMALESH_SWT' THEN                   
               lv_SqlStr := lv_SqlStr||' AND CATEGORYCODE = '''||P_CATEGORY||''' '||CHR(10);
        end if;
        IF NVL(P_GRADE,'AMALESH_SWT') <> 'AMALESH_SWT' THEN                   
               lv_SqlStr := lv_SqlStr||' AND GRADECODE = '''||P_GRADE||''' '||CHR(10);
        end if;            
        IF NVL(P_WORKERSERIAL,'XX') <> 'XX' THEN
               lv_SqlStr := lv_SqlStr||' AND WORKERSERIAL = '''||P_WORKERSERIAL||''' '||CHR(10); 
        END IF;
    insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,'',lv_SqlStr,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
    EXECUTE IMMEDIATE lv_SqlStr;  
    
    --ADDED ON 22/08/2020  UPDATE PAYMENT DATE
    UPDATE PISPAYTRANSACTION_SWT SET PAYMENTDATE = LAST_DAY(TO_DATE(YEARMONTH,'YYYYMM'));
    --ENDED ON 22/08/2020
                     
    lv_SqlStr := 'INSERT INTO '||P_TABLENAME||' SELECT * FROM '||P_PHASE_TABLENAME||' ';
    lv_remarks := 'PHASE - '||P_PHASE||' SUCESSFULLY COMPLETE';
    insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,'',lv_SqlStr,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
    EXECUTE IMMEDIATE lv_SqlStr;    
commit;    
exception
    when others then
    lv_sqlerrm := sqlerrm ;
    insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
    commit;
    --dbms_output.put_line('PROC - PROC_WPSWAGESPROCESS_UPDATE : ERROR !! WHILE WAGES PROCESS '||P_FNSTDT||' AND PHASE -> '||ltrim(trim(P_PHASE))||' : '||sqlerrm);
end;
/