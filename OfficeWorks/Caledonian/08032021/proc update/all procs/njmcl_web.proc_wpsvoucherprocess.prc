DROP PROCEDURE NJMCL_WEB.PROC_WPSVOUCHERPROCESS;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPSVOUCHERPROCESS (P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2, 
                                                  P_YEARCODE Varchar2,
                                                  P_FNSTDT Varchar2, 
                                                  P_FNENDT Varchar2,
                                                  P_PHASE  number, 
                                                  P_PHASE_TABLENAME VARCHAR2,
                                                  P_TABLENAME Varchar2,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL,
                                                  P_PROCESSTYPE  VARCHAR2 DEFAULT 'VOUCHER PROCESS')
/* CHANGES AS ON 03/12/2018' PARTIAL*/                                                  
as
lv_Component varchar2(32767) := '';
lv_Sql       varchar2(32767) := '';
lv_ComponentNew  varchar2(32767) := '';
lv_Sql_TblCreate    varchar2(3000) := '';  
lv_sqlerrm      varchar2(1000) := ''; 
lv_ProcName     varchar2(30) := 'PROC_WPSVOUCHERPROCESS';
lv_remarks      varchar2(1000) := '';
lv_parvalues    varchar2(1000) := '';
lv_SqlTemp      varchar2 (2000) := '';
lv_Cols         varchar2 (1000) := '';
lv_fn_stdt      date := to_date(P_FNSTDT,'DD/MM/YYYY');
lv_fn_endt      date := to_date(P_FNENDT,'DD/MM/YYYY');
lv_Ln_Checked_Dt    date;
lv_prev_fn_stdt date;
lv_prev_fn_endt date;
lv_MinimumPayableAmt    number := 0;            -- use for Minimum payment amount which defined in the WPSWAGESPARAMETER TABLE 
lv_RoundOffRs           number := 0;            -- use for Round Off Rs. which defined in the WPSWAGESPARAMETER TABLE
lv_ESI_E_Perc           number := 0.75;         -- USE FOR ESI EMPLOYEE CONTRIBUTION
lv_ProcessType  varchar2(50):= 'FORTNIGHTLY';   -- use for wage process Fortnightly or Monthly which defined in the WPSWAGESPARAMETER TABLE MAINLY REQUIRE FOR P.TAX CALCULATION 
lv_WagesAsOn    number(11,2) := 0;
lv_TempVal      number(11,2) :=0;
lv_TempDednAmt  number(11,2) := 0;
lv_ComponentAmt number(11,2) := 0;
lv_TempDednAmt_Prev number(11,2) :=0;
lv_intCnt       number(5) :=0;
lv_GrossWages   number(11,2) := 0;
lv_PREV_FN_PTAXGROSS        NUMBER(11,2):= 0;
lv_PREV_FN_PTAX             NUMBER(11,2):= 0;
lv_PREV_FN_PFGROSS          NUMBER(11,2):=0;
lv_PREV_FN_ESIGROSS         NUMBER(11,2) := 0;
lv_PREV_FN_ESI_E            NUMBER(11,2):=0;
lv_PREV_FN_PF_E             NUMBER(11,2):=0;
lv_PREV_FN_VPF              number(11,2) := 0;
lv_VPF_PERCENT              number(11,2) :=0;
lv_TotalDedn    number(11,2) := 0;
lv_CoinBf       number(11,2) := 0;
lv_CoinCf       number(11,2) := 0;
lv_strWorkerSerial  varchar2(10) :='';
lv_SrlNo        number   :=1;                    -- varaible use for serially which No. execute; 
lv_RowType_Prev_Data    GTT_WPS_PREV_FNDATA%ROWTYPE;
lv_RoundoffType varchar2(1) :='';
lv_EMI_DEDN_TYPE    varchar2(20):='PARTIAL';
lv_PFLN_CAP_STOP    varchar2(1) :='N';
lv_PFLN_INT_STOP    varchar2(1) :='N';
lv_CNT          number(11,2) := 0;
lv_SqlStr        varchar2(32767) := '';
lv_PolicyNo     varchar2(50) := ''; 
lv_PF_PERCENT   number(5) := 10;
lv_MAX_PFGROSS  number(11,2) := 0;
lv_MAX_PF_CONT  number(11,2) :=0;
lv_fn_LastDailyWagesDT  date := to_date(P_FNENDT,'DD/MM/YYYY'); --- NEW ADD ON 21.04.2020 FOR DAILY WAGES AND WEEKLY STL PAYMENT
lv_YYYYMM       varchar2(6) := to_char(lv_fn_stdt,'YYYYMM');   --- NEW ADD ON 21.04.2020 FOR DAILY WAGES AND WEEKLY STL PAYMENT 
begin
    lv_parvalues := 'COMP ='||P_COMPCODE||', DIV = '||P_DIVCODE||',FNS = '||P_FNSTDT||' FNE = '||P_FNENDT||', PHASE = '||P_PHASE;
    lv_sql := 'drop table '||P_PHASE_TABLENAME;
    lv_Ln_Checked_Dt := lv_prev_fn_endt+4;
    
    if SUBSTR(P_FNSTDT,1,2) = '16' then
        lv_prev_fn_stdt := to_date('01'||substr(P_FNSTDT,4,7),'dd/mm/yyyy');
    end if;
    
    
    BEGIN 
        execute immediate lv_sql;
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    PROC_WPSWAGESDETAILS_MERGE(P_COMPCODE, P_DIVCODE, P_FNSTDT,P_FNENDT, P_PHASE, 'WPSWAGESDETAILS_SWT', 'WPSWAGESDETAILS_MV_SWT',  P_WORKERSERIAL);
    
    
    lv_Sql := 'UPDATE WPSWAGESDETAILS_MV_SWT set ACTUALPAYBLEAMOUNT = FN_ROUNDOFFRS(GROSS_WAGES,1,''S'')';
    execute immediate lv_Sql;
    commit;


commit;    
end;
/


