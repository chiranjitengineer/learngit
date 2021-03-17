DROP PROCEDURE NJMCL_WEB.PROC_WPSWAGESPROCESS_TRANSFER;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PROC_WPSWAGESPROCESS_TRANSFER" (P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2, 
                                                  P_YEARCODE Varchar2,
                                                  P_FNSTDT Varchar2, 
                                                  P_FNENDT Varchar2,
                                                  P_PHASE  number, 
                                                  P_PHASE_TABLENAME VARCHAR2,
                                                  P_TABLENAME Varchar2,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL,
                                                  P_PROCESSTYPE  VARCHAR2 DEFAULT 'WAGES PROCESS')
as
lv_Component varchar2(32767) := '';
lv_Sql       varchar2(32767) := '';
lv_Sql_TblCreate    varchar2(3000) := '';  
lv_sqlerrm      varchar2(1000) := ''; 
lv_remarks      varchar2(1000) := '';
lv_parvalues    varchar2(1000) := '';
lv_SqlTemp      varchar2 (2000) := '';
lv_Cols         varchar2 (1000) := '';
lv_fn_stdt      date := to_date(P_FNSTDT,'DD/MM/YYYY');
lv_fn_endt      date := to_date(P_FNENDT,'DD/MM/YYYY');
lv_ProcName     varchar2(30) := 'PROC_WPSWAGESPROCESS_TRANSFER';
begin
    lv_parvalues := 'DIV = '||P_DIVCODE||', FNE = '||P_FNENDT||', PHASE = '||P_PHASE;
    lv_remarks := 'PHASE - '||P_PHASE||' START';
    
 IF  P_PROCESSTYPE='VOUCHER PROCESS' THEN
     IF NVL(P_WORKERSERIAL,'XX') = 'XX' THEN
        delete from WPSVOUCHERDETAILS WHERE COMPANYCODE = P_COMPCODE
          AND DIVISIONCODE = P_DIVCODE
          AND FORTNIGHTSTARTDATE = lv_fn_stdt
          AND FORTNIGHTENDDATE = lv_fn_endt;

        delete from WPSVOUCHERDETAILS_MV WHERE COMPANYCODE = P_COMPCODE
          AND DIVISIONCODE = P_DIVCODE
          AND FORTNIGHTSTARTDATE = lv_fn_stdt
          AND FORTNIGHTENDDATE = lv_fn_endt;
          
    else
        delete from WPSVOUCHERDETAILS WHERE COMPANYCODE = P_COMPCODE
          AND DIVISIONCODE = P_DIVCODE
          AND FORTNIGHTSTARTDATE = lv_fn_stdt
          AND FORTNIGHTENDDATE = lv_fn_endt
          AND WORKERSERIAL IN (P_WORKERSERIAL);
            
        delete from WPSVOUCHERDETAILS_MV WHERE COMPANYCODE = P_COMPCODE
          AND DIVISIONCODE = P_DIVCODE
          AND FORTNIGHTSTARTDATE = lv_fn_stdt
          AND FORTNIGHTENDDATE = lv_fn_endt
          AND WORKERSERIAL IN (P_WORKERSERIAL);
    end if;
    
    INSERT INTO WPSVOUCHERDETAILS SELECT * FROM WPSWAGESDETAILS_SWT;
    INSERT INTO WPSVOUCHERDETAILS_MV SELECT * FROM WPSWAGESDETAILS_MV_SWT;      
 ELSE
 ---------------------------------------------------------------------------
    ----- DELETE FROM WPSATTENDANCEDAYSWISE FOR ATTENDANCETAG='HRA' BECAUSE HRA TAG FORCEFULLY INSERT FOR HRA CALCULATION IN 2ND FORTNIGHT
    DELETE FROM WPSATTENDANCEDAYWISE 
    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
      AND YEARCODE =P_YEARCODE 
      AND DATEOFATTENDANCE >= lv_fn_stdt
      AND DATEOFATTENDANCE <= lv_fn_endt
      AND ATTENDANCETAG='HRA';
      
    IF NVL(P_WORKERSERIAL,'XX') = 'XX' THEN
        delete from WPSWAGESDETAILS WHERE COMPANYCODE = P_COMPCODE
          AND DIVISIONCODE = P_DIVCODE
          AND FORTNIGHTSTARTDATE = lv_fn_stdt
          AND FORTNIGHTENDDATE = lv_fn_endt;

        delete from WPSWAGESDETAILS_MV WHERE COMPANYCODE = P_COMPCODE
          AND DIVISIONCODE = P_DIVCODE
          AND FORTNIGHTSTARTDATE = lv_fn_stdt
          AND FORTNIGHTENDDATE = lv_fn_endt;
          
    else
        delete from WPSWAGESDETAILS WHERE COMPANYCODE = P_COMPCODE
          AND DIVISIONCODE = P_DIVCODE
          AND FORTNIGHTSTARTDATE = lv_fn_stdt
          AND FORTNIGHTENDDATE = lv_fn_endt
          AND WORKERSERIAL IN (P_WORKERSERIAL);
            
        delete from WPSWAGESDETAILS_MV WHERE COMPANYCODE = P_COMPCODE
          AND DIVISIONCODE = P_DIVCODE
          AND FORTNIGHTSTARTDATE = lv_fn_stdt
          AND FORTNIGHTENDDATE = lv_fn_endt
          AND WORKERSERIAL IN (P_WORKERSERIAL);
    end if; 
    ---------------------------------------------------------------------------
    
    INSERT INTO WPSWAGESDETAILS SELECT * FROM WPSWAGESDETAILS_SWT;
    INSERT INTO WPSWAGESDETAILS_MV SELECT * FROM WPSWAGESDETAILS_MV_SWT;    
 END IF;
    
    
   
    
    lv_remarks := 'PHASE - '||P_PHASE||' SUCESSFULLY COMPLETE';
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'','',lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
commit;    
exception
    when others then
    lv_sqlerrm := sqlerrm ;
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_Sql,lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
    commit;
    --dbms_output.put_line('PROC - PROC_WPSWAGESPROCESS_UPDATE : ERROR !! WHILE WAGES PROCESS '||P_FNSTDT||' AND PHASE -> '||ltrim(trim(P_PHASE))||' : '||sqlerrm);
end;
/


