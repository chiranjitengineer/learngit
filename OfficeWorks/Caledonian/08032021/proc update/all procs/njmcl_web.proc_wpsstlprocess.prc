DROP PROCEDURE NJMCL_WEB.PROC_WPSSTLPROCESS;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPSSTLPROCESS(P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2, 
                                                  P_YEARCODE Varchar2,
                                                  P_FN_STDT Varchar2, 
                                                  P_FN_ENDT Varchar2,
                                                  P_PHASE  number  DEFAULT NULL, 
                                                  P_PHASE_TABLENAME VARCHAR2  DEFAULT NULL,
                                                  P_TABLENAME Varchar2  DEFAULT NULL,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL,
                                                  P_PROCESSTYPE  VARCHAR2 DEFAULT 'STL PROCESS')                                                 
as
lv_Component varchar2(32767) := '';
lv_Sql       varchar2(32767) := '';
lv_ComponentNew  varchar2(32767) := '';
lv_Sql_TblCreate    varchar2(3000) := '';  
lv_sqlerrm      varchar2(1000) := ''; 
lv_ProcName     varchar2(30) := 'PROC_WPSSTLPROCESS';
lv_remarks      varchar2(1000) := '';
lv_parvalues    varchar2(1000) := '';
lv_SqlTemp      varchar2 (2000) := '';
lv_Cols         varchar2 (1000) := '';
lv_fn_stdt      date := to_date(P_FN_STDT,'DD/MM/YYYY');
lv_fn_endt      date := to_date(P_FN_STDT,'DD/MM/YYYY');
lv_mn_stdt      date := to_date('01/'||substr(P_FN_STDT,4),'DD/MM/YYYY');
lv_MinimumPayableAmt    number := 0;            -- use for Minimum payment amount which defined in the WPSWAGESPARAMETER TABLE 
lv_RoundOffRs           number := 0;            -- use for Round Off Rs. which defined in the WPSWAGESPARAMETER TABLE
lv_ESI_E_Perc           number := 0.75;         -- USE FOR ESI EMPLOYEE CONTRIBUTION
lv_ProcessType  varchar2(50):= 'FORTNIGHTLY';   -- use for wage process Fortnightly or Monthly which defined in the WPSWAGESPARAMETER TABLE MAINLY REQUIRE FOR P.TAX CALCULATION 
lv_WagesAsOn    number(11,2) := 0;
lv_TempVal      number(11,2) :=0;
lv_TempDednAmt  number(11,2) := 0;
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
lv_ESICOMPANYPERCENT        number(11,2) :=0;
lv_PENSION_PERCENTAGE number(11,2) :=0;
lv_MAXIMUMPENSIONGROSS number(11,2) :=0;
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
lv_fn_LastDailyWagesDT  date := to_date(P_FN_ENDT,'DD/MM/YYYY'); --- NEW ADD ON 21.04.2020 FOR DAILY WAGES AND WEEKLY STL PAYMENT
lv_YYYYMM       varchar2(6) := to_char(lv_fn_stdt,'YYYYMM');   --- NEW ADD ON 21.04.2020 FOR DAILY WAGES AND WEEKLY STL PAYMENT 

lv_TempTable    varchar2(50) := 'WPSSTLRATE_TEMP'; 
lv_PF_E_Amt number(11,2) := 0; 
lv_ESI_Amt number(11,2) := 0; 
lv_FPF_Amt number(11,2) := 0; 
begin
    
    

    SELECT nvl(MINIMUMSALARYPAYABLE,0) MINIMUMSALARYPAYABLE, nvl(ROUNDOFFRS,0) ROUNDOFFRS, 
    nvl(PROCESSTYPE,'FORTNIGHTLY') PROCESSTYPE,ROUNDOFFTYPE, nvl(ESIEMLPLOYEEPERCENT,0) ESIEMLPLOYEEPERCENT,
    NVL(PFEMLPLOYEEPERCENT,0) PFEMLPLOYEEPERCENT,  NVL(MAXIMUMPFGROSS,0) MAXIMUMPFGROSS,  NVL(MAXIMUMPF,0) MAXIMUMPF,
    PENSION_PERCENTAGE,MAXIMUMPENSIONGROSS,ESICOMPANYPERCENT
    INTO lv_MinimumPayableAmt, lv_RoundOffRs, lv_ProcessType , lv_RoundoffType, lv_ESI_E_Perc,
    lv_PF_PERCENT, lv_MAX_PFGROSS, lv_MAX_PF_CONT,
    lv_PENSION_PERCENTAGE,lv_MAXIMUMPENSIONGROSS,lv_ESICOMPANYPERCENT
    FROM WPSWAGESPARAMETER WHERE COMPANYCODE= P_COMPCODE AND DIVISIONCODE = P_DIVCODE;

    PROC_WPSWORKERRATE(P_COMPCODE,P_DIVCODE,P_FN_STDT,'GBL_WORKERRATE_ASON',P_PROCESSTYPE);
    
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE '||lv_TempTable;
    EXCEPTION
        WHEN OTHERS THEN NULL;    
    END;
    lv_Remarks := '0 STL HOURLY TABLE CREATION';
    lv_Sql := ' CREATE TABLE '||lv_TempTable||' AS '||CHR(10)
            ||' SELECT B.WORKERSERIAL, B.BASIC, A.DA, A.ADHOC, A.TSA, (ROUND(B.BASIC/48,5) + ROUND((NVL(A.DA,0)+NVL(A.ADHOC,0)+NVL(A.TSA,0))/208,5)) STL_HRS_RATE '||chr(10)
            ||' FROM GBL_WORKERRATE_ASON A,  '||chr(10)
            ||' (  '||chr(10)
            ||'     SELECT WORKERSERIAL, NVL(MAX(STLRATE),0) BASIC  '||chr(10)
            ||'     FROM WPSSTLENTRY  '||chr(10)
            ||'     WHERE COMPANYCODE ='''||P_COMPCODE||''' AND DIVISIONCODE ='''||P_DIVCODE||'''  '||chr(10)
            ||'       AND PAYMENTDATE='''||lv_FN_STDT||'''  '||chr(10)
            ||'     GROUP BY WORKERSERIAL  '||chr(10)
            ||' ) B  '||chr(10)
            ||' WHERE A.WORKERSERIAL = B.WORKERSERIAL  '||chr(10);
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
    COMMIT;
    EXECUTE IMMEDIATE lv_Sql;
    COMMIT;
                
    
    lv_Remarks := '1 DELETE FROM  WPSSTLWAGESDETAILS';
    lv_Sql := ' DELETE FROM WPSSTLWAGESDETAILS '||chr(10)
            ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  AND YEARCODE='''||P_YEARCODE||''''||chr(10)
            ||'   AND PAYMENTDATE >= '''||lv_FN_STDT||''' '||chr(10)
            ||'   AND PAYMENTDATE <= '''||lv_FN_ENDT||''' '||chr(10);
    EXECUTE IMMEDIATE lv_Sql;
    COMMIT;
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);

    --- START BELOW BLOCK CONSIDER FOR PREVIOUS PAYMENT WIHCH CONSIDER IN CURRENT WAGES PAYMENT FOR REFERES IN DEDUCTION STATEMENT
    DELETE FROM GTT_WPS_PREV_FNDATA;
    lv_Sql := ' INSERT INTO GTT_WPS_PREV_FNDATA (WORKERSERIAL, PF_GROSS, PENSION_GROSS, PF_CONT, PF_COM, FPF, VPF, '||chr(10) 
        ||' ESI_GROSS, ESI_CONT, ESI_COMP_CONT, GROSS_PTAX, P_TAX ) '||chr(10)
        ||' SELECT WORKERSERIAL, SUM(PF_GROSS) PF_GROSS, SUM(PENSION_GROSS) PENSION_GROSS, SUM(PF_CONT) PF_CONT, SUM(PF_COM) PF_COM, SUM(FPF) FPF, SUM(VPF) VPF, '||chr(10) 
        ||' SUM(ESI_GROSS) ESI_GROSS, SUM(ESI_CONT) ESI_CONT, SUM(ESI_COMP_CONT) ESI_COMP_CONT, SUM(GROSS_PTAX) GROSS_PTAX, SUM(P_TAX) P_TAX '||chr(10)
        ||' FROM ('||chr(10)
        ||'      SELECT WORKERSERIAL, NVL(PF_GROSS,0) PF_GROSS, NVL(PENSION_GROSS,0) PENSION_GROSS, NVL(PF_CONT,0) PF_CONT, NVL(PF_COM,0) PF_COM, NVL(FPF,0) FPF, NVL(VPF,0) VPF, '||chr(10) 
        ||'      NVL(ESI_GROSS,0) ESI_GROSS, NVL(ESI_CONT,0) ESI_CONT, NVL(ESI_COMP_CONT,0) ESI_COMP_CONT, NVL(GROSS_PTAX,0) GROSS_PTAX, NVL(P_TAX,0) P_TAX  '||chr(10)
        ||'      FROM WPSWAGESDETAILS_MV  '||chr(10)
        ||'      WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
        ||'        AND FORTNIGHTSTARTDATE >= '''||lv_mn_stdt||'''   '||chr(10)
        ||'        AND FORTNIGHTSTARTDATE <  TO_DATE('''||P_FN_STDT||''',''DD/MM/YYYY'')  '||chr(10) 
--        ||'        AND FORTNIGHTENDDATE = to_date(''15/''||substr('''||P_FN_ENDT||''',4,7),''dd/mm/yyyy'')  '||chr(10)
        ||'      UNION ALL '||chr(10)          
        ||'      SELECT WORKERSERIAL, NVL(PF_GROSS,0) PF_GROSS,  NVL(PENSION_GROSS,0) PENSION_GROSS, NVL(PF_E,0) PF_CONT, NVL(PF_C,0) PF_COM, NVL(FPF,0) FPF, 0 VPF, '||chr(10) 
        ||'      NVL(ESI_GROSS,0) ESI_GROSS, NVL(ESI_E,0) ESI_CONT, NVL(ESI_C,0) ESI_COMP_CONT, NVL(GROSS_PTAX,0) GROSS_PTAX, NVL(P_TAX,0) P_TAX '||chr(10)
        ||'      FROM WPSSTLWAGESDETAILS '||chr(10)
        ||'      WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
        ||'        AND YEARCODE = '''||P_YEARCODE||'''   '||chr(10)
        ||'        AND PAYMENTDATE >= '''||lv_mn_stdt||'''   '||chr(10)
        ||'        AND PAYMENTDATE < TO_DATE('''||P_FN_STDT||''',''DD/MM/YYYY'') '||chr(10)
        --||'        AND PAYMENTDATE <= to_date('''||lv_fn_LastDailyWagesDT||''') '||chr(10)
        ||'      ) GROUP BY WORKERSERIAL '||CHR(10);
    lv_remarks := '2 PREVIOUS WAGES PAYMENT DATA INSERT INTO GTT_WPS_PREV_FNDATA';      
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
    COMMIT;
    EXECUTE IMMEDIATE lv_Sql;    
    COMMIT;
    
    
    
        DELETE FROM WPSSTLWAGESDETAILS_SWT;
        
        COMMIT;
        
        lv_remarks := '3 INSERT INTO  WPSSTLWAGESDETAILS_SWT   STL DATA';    
--        BELOW QUERY CHANGES BY AMALESH ON 03.06.2020  
--        lv_Sql := 'INSERT INTO  WPSSTLWAGESDETAILS_SWT '||CHR(10)
--        ||'SELECT STL.COMPANYCODE,STL.DIVISIONCODE,STL.YEARCODE,STL.DOCUMENTDATE,STL.WORKERSERIAL,STL.TOKENNO,WORKERCATEGORYCODE,'||CHR(10)
--        ||'SHIFTCODE,DEPARTMENTCODE,SECTIONCODE,OCCUPATIONCODE,'||CHR(10)
--        ||'0 ATTENDANCEHOURS,SUM(STLHOURS)STLHOURS,0 OVERTIMEHOURS,SUM(STLHOURS_RATE) STLAMOUNT,SUM(STLDAYS)STLDAYS,0 OTHER_EARN,'||CHR(10)
--        ||'0 BASIC,0 DA,0 ADHOC,0 HRA,0 HRS_RATE,'||CHR(10)
--        ||'SUM(STLHOURS_RATE) PF_GROSS,SUM(STLHOURS_RATE) ESI_GROSS,SUM(STLHOURS_RATE) GROSS_PTAX,'||CHR(10)
--        ||'SUM(STLHOURS_RATE) GROSS_WAGES,SUM(STL_A.PF_GROSS) TOTAL_EARN,'||CHR(10)
--        ||'SUM(ROUND((NVL(STL_A.PF_GROSS,0)+NVL(LD.PF_GROSS,0))*'||lv_PF_PERCENT||'*0.01,0)-NVL(LD.PF_CONT,0)) PF_E,'||CHR(10)
--        ||'SUM(CASE WHEN LD.PF_GROSS>0 THEN  (ceil((NVL(STL_A.PF_GROSS,0)+NVL(LD.PF_GROSS,0))*0.01*'||lv_ESI_E_Perc||'))-LD.ESI_CONT  ELSE  ceil(NVL(STL_A.PF_GROSS,0)*0.01*'||lv_ESI_E_Perc||')-LD.ESI_CONT END) ESI_E,'||CHR(10)
--        ||'SUM(CASE WHEN (NVL(STL_A.PF_GROSS,0)+NVL(LD.PF_GROSS,0))<='||lv_MAXIMUMPENSIONGROSS||' THEN  (ceil((NVL(STL_A.PF_GROSS,0)+NVL(LD.PF_GROSS,0))*0.01*'||lv_PENSION_PERCENTAGE||'))-NVL(LD.FPF,0) ELSE  ceil(NVL('||lv_MAXIMUMPENSIONGROSS||',0)*0.01*'||lv_PENSION_PERCENTAGE||') -NVL(LD.FPF,0) END) FPF,'||CHR(10)
--        ||'0 PF_C,'||CHR(10)
--        ||'SUM(CASE WHEN LD.PF_GROSS>0 THEN  (ceil((NVL(STL_A.PF_GROSS,0)+NVL(LD.PF_GROSS,0))*0.01*'||lv_ESICOMPANYPERCENT||'))-LD.ESI_CONT  ELSE  ceil(NVL(STL_A.PF_GROSS,0)*0.01*'||lv_ESICOMPANYPERCENT||')-LD.ESI_CONT END) ESI_C,'||CHR(10)
--        ||'0 OTHER_DEDN,'||CHR(10)
--        ||'0 COINBF,0 COINCF,0 TOTAL_DEDN,0 NETPAY,''STL'' TRANTYPE,STLFROMDATE LEAVEFROM,STLTODATE LEAVETO,''SWT'' USERNAME,'||CHR(10)
--        ||'SYSDATE LASTMODIFIED,FN_GENERATE_SYSROWID,'||CHR(10)
--        ||'0 PENSION_GROSS,'||CHR(10)
--        ||'SUM(NVL((CASE WHEN '''||lv_ProcessType||''' =''MONTHLY'' THEN '||CHR(10)
--        ||'(SELECT NVL(PTAXAMOUNT,0) FROM PTAXSLAB'||CHR(10)
--        ||'                    WHERE 1=1'||CHR(10)
--        ||'                      AND STATENAME = ''WEST BENGAL'''||CHR(10)
--        ||'                      AND WITHEFFECTFROM = ( SELECT MAX(WITHEFFECTFROM) FROM PTAXSLAB WHERE STATENAME = ''WEST BENGAL'' AND WITHEFFECTFROM <= '''||lv_FN_STDT||''')'||CHR(10)
--        ||'                      AND SLABAMOUNTFROM <= NVL(STL_A.PF_GROSS,0)'||CHR(10)
--        ||'                      AND SLABAMOUNTTO >= NVL(STL_A.PF_GROSS,0) AND ROWNUM=1'||CHR(10)
--        ||')ELSE'||CHR(10)
--        ||'(SELECT NVL(PTAXAMOUNT,0) FROM PTAXSLAB'||CHR(10)
--        ||'                    WHERE 1=1'||CHR(10)
--        ||'                      AND STATENAME = ''WEST BENGAL'''||CHR(10)
--        ||'                      AND WITHEFFECTFROM = ( SELECT MAX(WITHEFFECTFROM) FROM PTAXSLAB WHERE STATENAME = ''WEST BENGAL'' AND WITHEFFECTFROM <= '''||lv_FN_STDT||''')'||CHR(10)
--        ||'                      AND SLABAMOUNTFROM <= (NVL(STL_A.PF_GROSS,0)+NVL(LD.GROSS_PTAX,0)) '||CHR(10)
--        ||'                      AND SLABAMOUNTTO >= (NVL(STL_A.PF_GROSS,0)+NVL(LD.GROSS_PTAX,0))  AND ROWNUM=1'||CHR(10)
--        ||')-NVL(LD.P_TAX,0) END),0)) P_TAX'||CHR(10)
--        ||'FROM WPSSTLENTRY STL,GTT_WPS_PREV_FNDATA LD,'||CHR(10)
--        ||'('||CHR(10)
--        ||'SELECT COMPANYCODE,DIVISIONCODE,YEARCODE,YEAR,FORTNIGHTSTARTDATE,FORTNIGHTENDDATE,DOCUMENTDATE,WORKERSERIAL,'||CHR(10)
--        ||'ROUND(NVL(STLHOURS,0)*(NVL(STLRATE,0)/48),2) STLHOURS_RATE,'||CHR(10)
--        ||'ROUND(NVL(STLHOURS,0)*(NVL(STLRATE,0)/48),2) PF_GROSS'||CHR(10)
--        ||'FROM WPSSTLENTRY'||CHR(10)
--        ||'WHERE 1=1'||CHR(10)
--        ||'AND COMPANYCODE='''||P_COMPCODE||''''||CHR(10)
--        ||'AND DIVISIONCODE='''||P_DIVCODE||''''||CHR(10)
--        ||'AND YEARCODE='''||P_YEARCODE||''' --AND WORKERSERIAL=''002253'''||CHR(10)
--        ||'AND DOCUMENTDATE>= '''||lv_FN_STDT||''''||CHR(10)
--        ||'AND DOCUMENTDATE<=  '''||lv_FN_ENDT||''''||CHR(10)
--        ||')STL_A'||CHR(10)
--        ||'WHERE 1=1 AND STL.WORKERSERIAL=LD.WORKERSERIAL(+) '||CHR(10)
--        ||'AND STL.COMPANYCODE=STL_A.COMPANYCODE(+)'||CHR(10)
--        ||'AND STL.DIVISIONCODE=STL_A.DIVISIONCODE(+)'||CHR(10)
--        ||'AND STL.YEARCODE=STL_A.YEARCODE(+)'||CHR(10)
--        ||'AND STL.FORTNIGHTSTARTDATE=STL_A.FORTNIGHTSTARTDATE(+)'||CHR(10)
--        ||'AND STL.FORTNIGHTENDDATE=STL_A.FORTNIGHTENDDATE(+)'||CHR(10)
--        ||'AND STL.DOCUMENTDATE=STL_A.DOCUMENTDATE(+)'||CHR(10)
--        ||'AND STL.WORKERSERIAL=STL_A.WORKERSERIAL(+)'||CHR(10)
--        ||'AND STL.YEAR=STL_A.YEAR(+)'||CHR(10)
--        ||'AND STL.COMPANYCODE='''||P_COMPCODE||''' '||CHR(10)
--        ||'AND STL.DIVISIONCODE='''||P_DIVCODE||''''||CHR(10)
--        ||'AND STL.YEARCODE='''||P_YEARCODE||''' --AND WORKERSERIAL=''002253'''||CHR(10)
--        ||'AND STL.DOCUMENTDATE>= '''||lv_FN_STDT||''''||CHR(10)
--        ||'AND STL.DOCUMENTDATE<=  '''||lv_FN_ENDT||''''||CHR(10)
--        ||'GROUP BY '||CHR(10)
--        ||'STL.COMPANYCODE,STL.DIVISIONCODE,STL.YEARCODE,STL.DOCUMENTDATE,STL.WORKERSERIAL,STL.TOKENNO,WORKERCATEGORYCODE,'||CHR(10)
--        ||'SHIFTCODE,DEPARTMENTCODE,SECTIONCODE,OCCUPATIONCODE,STLFROMDATE,STLTODATE'||CHR(10);
       
    lv_Sql := ' INSERT INTO  WPSSTLWAGESDETAILS_SWT ( '||chr(10)
            ||' COMPANYCODE, DIVISIONCODE, YEARCODE, PAYMENTDATE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, '||chr(10) 
            ||' SHIFTCODE, DEPARTMENTCODE, SECTIONCODE, OCCUPATIONCODE, DEPTSERIAL, SERIALNO, STLHOURS, STLDAYS, STLAMOUNT,  OTHER_EARN,  '||chr(10) 
            ||' HRS_RATE, PF_GROSS, ESI_GROSS, GROSS_PTAX, GROSS_WAGES, TOTAL_EARN, PF_E, ESI_E, FPF, PF_C, ESI_C, OTHER_DEDN, COINBF, COINCF, TOTAL_DEDN, NETPAY,  '||chr(10) 
            ||' TRANTYPE, LEAVEFROM, LEAVETO, USERNAME, LASTMODIFIED, SYSROWID, PENSION_GROSS, P_TAX, LEAVEENCASHMENT ) '||chr(10)

            ||' SELECT S.COMPANYCODE, S.DIVISIONCODE, S.YEARCODE, S.PAYMENTDATE, S.WORKERSERIAL, M.TOKENNO, M.WORKERCATEGORYCODE, '||chr(10) 
            ||' S.SHIFTCODE, S.DEPARTMENTCODE, S.SECTIONCODE, S.OCCUPATIONCODE, S.DEPTSERIAL, S.SERIALNO, S.STLHOURS, S.STLDAYS, S.STLAMOUNT, 0 OTHER_EARN,  '||chr(10) 
            ||' S.HRS_RATE, S.STLAMOUNT PF_GROSS, S.STLAMOUNT ESI_GROSS, S.STLAMOUNT GROSS_PTAX, S.STLAMOUNT GROSS_WAGES, S.STLAMOUNT TOTAL_EARN,  '||chr(10)
            ||' (ROUND((S.STLAMOUNT+NVL(P.PF_GROSS,0))*'||lv_PF_PERCENT||'*0.01,0)- NVL(P.PF_CONT,0)) PF_E, '||CHR(10)
--            ||' (ROUND((S.STLAMOUNT+NVL(P.ESI_GROSS,0))*'||lv_ESI_E_Perc||'*0.01,0)- NVL(P.ESI_CONT,0)) ESI_E, '||chr(10)
            ||' (CEIL(TRUNC(ROUND(S.STLAMOUNT+NVL(P.ESI_GROSS,0),0)*'||lv_ESI_E_Perc||'*0.01,2))-NVL(P.ESI_CONT,0)) ESI_E, '||CHR(10)
--            ||' CASE WHEN (NVL(S.STLAMOUNT,0)+NVL(P.PF_GROSS,0))<= '||lv_MAXIMUMPENSIONGROSS||' THEN  (ceil((NVL(S.STLAMOUNT,0)+NVL(P.PF_GROSS,0))*0.01*8.33))-NVL(P.FPF,0) ELSE  ceil(NVL('||lv_MAXIMUMPENSIONGROSS||',0)*0.01*'||lv_PENSION_PERCENTAGE||') -NVL(P.FPF,0) END FPF, '||CHR(10)
            ||' CASE WHEN NVL(M.EPFAPPLICABLE,''N'') =''N'' THEN 0 ELSE CASE WHEN (NVL(S.STLAMOUNT,0)+NVL(P.PF_GROSS,0))<= '||lv_MAXIMUMPENSIONGROSS||' THEN  (ROUND(ROUND((NVL(S.STLAMOUNT,0)+NVL(P.PF_GROSS,0)),0)*0.01*8.33,0))-NVL(P.FPF,0) ELSE  ROUND(NVL('||lv_MAXIMUMPENSIONGROSS||',0)*0.01*'||lv_PENSION_PERCENTAGE||',0) -NVL(P.FPF,0) END END FPF, '||CHR(10)
            ||' 0 PF_C, CASE WHEN NVL(P.PF_GROSS,0)>0 THEN  (ceil((NVL(S.STLAMOUNT,0)+NVL(P.PF_GROSS,0))*0.01*3.25))-NVL(P.ESI_CONT,0)  ELSE  ceil(NVL(S.STLAMOUNT,0)*0.01*3.25)- NVL(P.ESI_CONT,0) END ESI_C, '||chr(10) 
            ||' 0 OTHER_DEDN, 0 COINBF, 0 COINCF, 0 TOTAL_DEDN, 0 NETPAY,  '||chr(10)
            ||' ''STL'' TRANTYPE, STLFROMDATE LEAVEFROM, STLTODATE LEAVETO, ''SWT'' USERNAME, SYSDATE LASTMODIFIED, SYS_GUID() SYSROWID, 0 PENSION_GROSS, 0 P_TAX, LEAVEENCASHMENT '||chr(10)
            ||' FROM WPSWORKERMAST M, GTT_WPS_PREV_FNDATA P, '||chr(10)
            ||' ( '||chr(10)
            ||'     SELECT A.COMPANYCODE, A.DIVISIONCODE, A.YEARCODE, A.PAYMENTDATE, A.WORKERSERIAL, '||chr(10) 
            ||'     A.SHIFTCODE, A.DEPARTMENTCODE, A.SECTIONCODE, MAX(A.OCCUPATIONCODE) OCCUPATIONCODE, MAX(A.STLSERIALNO) DEPTSERIAL, MAX(A.STLSERIALNO) SERIALNO '||chr(10)
            ||'     ,A.STLFROMDATE, A.STLTODATE, NVL(A.LEAVEENCASHMENT,''N'') LEAVEENCASHMENT,'||chr(10)
            ||'     SUM(STLDAYS) STLDAYS, SUM(STLHOURS) STLHOURS, B.STL_HRS_RATE HRS_RATE, ROUND((B.STL_HRS_RATE*SUM(STLHOURS)),2) STLAMOUNT '||chr(10)
            ||'     FROM WPSSTLENTRY A, '||lv_TempTable||' B  '||chr(10)
            ||'     WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
            ||'       AND A.PAYMENTDATE >= '''||lv_FN_STDT||''' AND A.PAYMENTDATE <='''||lv_FN_ENDT||''' '||chr(10)
            ||'       AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
            ||'     GROUP BY A.COMPANYCODE, A.DIVISIONCODE, A.YEARCODE, A.PAYMENTDATE, A.WORKERSERIAL,  '||chr(10)
            ||'     A.SHIFTCODE, A.DEPARTMENTCODE, A.SECTIONCODE, A.STLFROMDATE, A.STLTODATE, B.STL_HRS_RATE, NVL(A.LEAVEENCASHMENT,''N'') '||chr(10)
            ||' ) S  '||chr(10)
            ||' WHERE M.COMPANYCODE = '''||P_COMPCODE||''' AND M.DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
            ||'   AND M.COMPANYCODE = S.COMPANYCODE AND M.DIVISIONCODE = S.DIVISIONCODE AND M.WORKERSERIAL = S.WORKERSERIAL '||chr(10)
            ||'   AND S.WORKERSERIAL = P.WORKERSERIAL (+) '||chr(10);
        
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
    COMMIT;
    EXECUTE IMMEDIATE lv_Sql;    
    COMMIT;

    lv_Remarks := '4_1 UPDATE DEDUCTION HEADS TO ZERO FROM LEAVEENCASMENT IN WPSSTLWAGESDETAILS_SWT';
    lv_Sql := ' UPDATE WPSSTLWAGESDETAILS_SWT SET PF_E = 0,FPF=0, PF_C=0, ESI_E=0, ESI_C=0, P_TAX=0,PF_GROSS = 0, ESI_GROSS =0 , GROSS_PTAX =0 '||CHR(10)
        ||' , TRANTYPE =''STL ENCASHMENT'' WHERE NVL(LEAVEENCASHMENT,''N'') =''Y'' '||chr(10);
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
    COMMIT;
    EXECUTE IMMEDIATE lv_Sql;    
    COMMIT;


    lv_Remarks := '4_2 UPDATE PF_C,TOTAL_DEDN,NETPAY  WPSSTLWAGESDETAILS_SWT';
    lv_Sql := 'UPDATE WPSSTLWAGESDETAILS_SWT SET PF_C=PF_E-FPF,TOTAL_DEDN=NVL(PF_E,0)+NVL(ESI_E,0)+NVL(P_TAX,0)+NVL(OTHER_DEDN,0),NETPAY=TOTAL_EARN-(NVL(PF_E,0)+NVL(ESI_E,0)+NVL(P_TAX,0)+NVL(OTHER_DEDN,0))'||chr(10);
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
    COMMIT;
    EXECUTE IMMEDIATE lv_Sql;    
    COMMIT;
   
    lv_Remarks := '5 INESERT IN WPSSTLWAGESDETAILS ';

     lv_Sql := 'INSERT INTO WPSSTLWAGESDETAILS'||chr(10)
         ||'('||chr(10)
         ||'COMPANYCODE, DIVISIONCODE, YEARCODE, PAYMENTDATE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, SHIFTCODE,'||chr(10)
         ||'DEPARTMENTCODE, SECTIONCODE, OCCUPATIONCODE, DEPTSERIAL, SERIALNO, ATTENDANCEHOURS, STLHOURS, OVERTIMEHOURS, STLAMOUNT, '||chr(10)
         ||'STLDAYS, OTHER_EARN, BASIC, DA, ADHOC, HRA, HRS_RATE, PF_GROSS, ESI_GROSS, GROSS_PTAX, GROSS_WAGES, '||chr(10)
         ||'TOTAL_EARN, PF_E, ESI_E, FPF, PF_C, ESI_C, OTHER_DEDN, COINBF, COINCF, TOTAL_DEDN, NETPAY, TRANTYPE, '||chr(10)
         ||'LEAVEFROM, LEAVETO, USERNAME, LASTMODIFIED, SYSROWID, PENSION_GROSS, P_TAX, LEAVEENCASHMENT'||chr(10)
         ||')'||chr(10)
         ||'SELECT '||chr(10)
         ||'COMPANYCODE, DIVISIONCODE, YEARCODE,PAYMENTDATE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, SHIFTCODE,'||chr(10)
         ||'DEPARTMENTCODE, SECTIONCODE, OCCUPATIONCODE, DEPTSERIAL, SERIALNO, 0 ATTENDANCEHOURS, STLHOURS, 0 OVERTIMEHOURS, STLAMOUNT, '||chr(10)
         ||'STLDAYS, OTHER_EARN, 0 BASIC, 0 DA, 0 ADHOC, 0 HRA, HRS_RATE, PF_GROSS, ESI_GROSS, GROSS_PTAX, GROSS_WAGES, '||chr(10)
         ||'TOTAL_EARN, PF_E, ESI_E, FPF, PF_C, ESI_C, OTHER_DEDN, COINBF, COINCF, TOTAL_DEDN, NETPAY, TRANTYPE, '||chr(10)
         ||'LEAVEFROM, LEAVETO, USERNAME, LASTMODIFIED, SYSROWID, PENSION_GROSS, P_TAX, LEAVEENCASHMENT'||chr(10)
         ||'FROM WPSSTLWAGESDETAILS_SWT'||chr(10)
         ||'WHERE COMPANYCODE= '''||P_COMPCODE||''''||chr(10)
         ||'AND DIVISIONCODE= '''||P_DIVCODE||''''||chr(10)
         ||'AND YEARCODE= '''||P_YEARCODE||''''||chr(10)
         ||'AND PAYMENTDATE >= '''||lv_FN_STDT||''''||chr(10)
         ||'AND PAYMENTDATE <= '''||lv_FN_ENDT||''''||chr(10);
    if P_WORKERSERIAL is not null then
        lv_Sql := lv_Sql ||' AND WORKERSERIAL IN ('||P_WORKERSERIAL||')' ||CHR(10); 
    end if; 
         
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
    COMMIT;
    EXECUTE IMMEDIATE lv_Sql; 
    COMMIT;
    
    
--exception    
--    when others then
--        lv_sqlerrm := sqlerrm;
--    insert into wps_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
--    values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
--    commit; 
end;
/


