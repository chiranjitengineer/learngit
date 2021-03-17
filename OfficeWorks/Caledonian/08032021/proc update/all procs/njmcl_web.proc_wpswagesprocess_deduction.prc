DROP PROCEDURE NJMCL_WEB.PROC_WPSWAGESPROCESS_DEDUCTION;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPSWAGESPROCESS_DEDUCTION (P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2, 
                                                  P_YEARCODE Varchar2,
                                                  P_FNSTDT Varchar2, 
                                                  P_FNENDT Varchar2,
                                                  P_PHASE  number, 
                                                  P_PHASE_TABLENAME VARCHAR2,
                                                  P_TABLENAME Varchar2,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL,
                                                  P_PROCESSTYPE  VARCHAR2 DEFAULT 'WAGES PROCESS')
/* CHANGES AS ON 03/12/2018' PARTIAL*/                                                  
as
lv_Component varchar2(32767) := '';
lv_Sql       varchar2(32767) := '';
lv_ComponentNew  varchar2(32767) := '';
lv_Sql_TblCreate    varchar2(3000) := '';  
lv_sqlerrm      varchar2(1000) := ''; 
lv_ProcName     varchar2(30) := 'PROC_WPSWAGESPROCESS_DEDUCTION';
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
lv_ChkAttnHrs   NUMBER(7,2) :=0; 
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


    lv_Sql := 'UPDATE WPSWAGESDETAILS_SWT SET GROSS_PTAX = NVL(GROSS_PTAX,0)-NVL(NPF_ADJ_DEDN,0)';

    lv_remarks := 'DEDUCT NPF_ADJ_DEN FROM GROSS_PTAX';      
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
    COMMIT;
    EXECUTE IMMEDIATE lv_Sql;    
    COMMIT;



    --- BEFORE DEDUCTION PAHSE START MERGE WORKER WISER MULIPLE DATA IN A SINGLE DATA
    PROC_WPSWAGESDETAILS_MERGE(P_COMPCODE, P_DIVCODE, P_FNSTDT,P_FNENDT, P_PHASE, 'WPSWAGESDETAILS_SWT', 'WPSWAGESDETAILS_MV_SWT',  P_WORKERSERIAL);
    lv_sql :='';
    PROC_WPSVIEWCREATION (P_COMPCODE,P_DIVCODE,'ATTN',7,P_FNSTDT, P_FNENDT, P_TABLENAME);
    PROC_WPSVIEWCREATION (P_COMPCODE,P_DIVCODE,'COMP',7,P_FNSTDT, P_FNENDT, P_TABLENAME);
    ---- TABLE CREATE FROM VIEW ----------
    
    PROC_LOANBLNC(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'','','WPS','YES'); -- 19.02.2020
    PROC_PFLOANBLNC(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'','','WPS','YES'); -- 19.02.2020
   
    PRC_PFLN_EMI_UPDT_ONATTN_HRS(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'), TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'WPSWAGESDETAILS_MV_SWT','GBL_PFLOANBLNC','','',''); -- 19.02.2020
    --RETURN;
--    DBMS_OUTPUT.PUT_LINE ('1_1');
    ---- LIC DATA PREPARATION PROCEDURE CALL--------
    
    ------ ELECTRIC METER READING -----------------------------------
--    PROC_ELECBLNC (P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),NULL,'WPS');
    PROC_ELECBLNC_WITH_BILL_EMI(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),NULL,'WPS','YES');                        

    --  SHOP RENT DATA PREPARATION PROCEDURE CALL
--    PROC_SHOPRENT_BLNC (P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'SHOP_RENT', P_YEARCODE ,'WPS','YES',NULL);    

     
     
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE WPSTEMPCOMPONENT CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'CREATE TABLE WPSTEMPCOMPONENT AS SELECT * FROM COMPONENT';
      EXCEPTION WHEN OTHERS THEN 
        EXECUTE IMMEDIATE 'CREATE TABLE WPSTEMPCOMPONENT AS SELECT * FROM COMPONENT';
    END;
    --insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) values( 'PROC_WPSWAGESPROCESS_DEDCUTION','',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, 'COMPONENT TABLE DROPED SUCCESSFULLY');
    --COMMIT;
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE WPSTEMPATTN CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'CREATE TABLE WPSTEMPATTN AS SELECT * FROM ATTN';
      EXCEPTION WHEN OTHERS THEN 
        EXECUTE IMMEDIATE 'CREATE TABLE WPSTEMPATTN AS SELECT * FROM ATTN';
    END;    
    --insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_DEDCUTION','',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, 'ATTNENDANCE TABLE DROPED SUCCESSFULLY');
    --COMMIT;    
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE '||P_PHASE_TABLENAME||' CASCADE CONSTRAINTS';
      EXCEPTION WHEN OTHERS THEN NULL;
    END;    
    --insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_DEDCUTION','',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, 'PAHSE TABLE DROPED SUCCESSFULLY');
    --COMMIT;

--    START Previous Working Fortnight coin c/f fetching worker wise --

    lv_Sql := ' INSERT INTO WPS_PREV_FN_COIN(WORKERSERIAL, FORTNIGHTSTARTDATE, COINCF) '||CHR(10) 
        ||' SELECT B.WORKERSERIAL, B.FORTNIGHTSTARTDATE, (CASE WHEN B.FORTNIGHTSTARTDATE = TO_DATE(''01/09/2020'',''DD/MM/YYYY'') THEN C.COMPONENTAMOUNT ELSE A.COINCF END) COINCF '||CHR(10) 
        ||' FROM WPSWAGESDETAILS_MV A, '||CHR(10) 
        ||' ( '||CHR(10) 
        ||'     SELECT WORKERSERIAL, MAX(FORTNIGHTSTARTDATE) FORTNIGHTSTARTDATE '||CHR(10)
        ||'     FROM ( '||CHR(10)
--        ||'             SELECT WORKERSERIAL, MAX(FORTNIGHTSTARTDATE) FORTNIGHTSTARTDATE '||CHR(10)  
--        ||'             FROM WPSWAGESDETAILS_MV '||CHR(10)  
--        ||'             WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
--        ||'               AND FORTNIGHTSTARTDATE > TO_DATE(''01/08/2018'',''DD/MM/YYYY'') '||CHR(10)  --- DUE TO WAGES GO LIVE ON 01/08/2018'
--        ||'               AND FORTNIGHTSTARTDATE < '''||lv_fn_stdt||'''  '||CHR(10)  ---- add on 16/10/2018 why this line delete , but last fNE (30/09/2018) it is in the system
--        ||'             GROUP BY WORKERSERIAL '||CHR(10)
--        ||'             UNION ALL '||CHR(10)
        ||'             SELECT WORKERSERIAL, FORTNIGHTSTARTDATE '||CHR(10)
        ||'             FROM WPSCOMPONENTOPENING '||CHR(10)
        ||'             WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
        ||'               AND FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'') '||CHR(10)
        ||'               AND COMPONENTCODE = ''COINBF'' '||CHR(10)
        ||'          ) '||CHR(10)
        ||'     GROUP BY WORKERSERIAL '||CHR(10)            
        ||' ) B, '||CHR(10)
        ||' ( SELECT * FROM WPSCOMPONENTOPENING '||CHR(10)
        ||'   WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
        ||'     AND FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'') '||CHR(10)
        ||'     AND COMPONENTCODE=''COINBF'' '||CHR(10) 
        ||'  ) C '||CHR(10) 
        ||' WHERE 1=1 '||CHR(10)
        ||'   AND B.WORKERSERIAL = A.WORKERSERIAL (+) '||CHR(10)  
        ||'   AND B.FORTNIGHTSTARTDATE = A.FORTNIGHTSTARTDATE (+) '||CHR(10)
        ||'   AND B.WORKERSERIAL = C.WORKERSERIAL (+) '||CHR(10);

    BEGIN
        DELETE FROM WPS_PREV_FN_COIN; --WHERE FORTNIGHTSTARTDATE = lv_fn_stdt;
        EXECUTE IMMEDIATE lv_Sql;
    exception
        WHEN OTHERS THEN
            EXECUTE IMMEDIATE lv_Sql;        
    END;
    lv_SqlTemp := '';
    lv_Sql := '';
--    END Previous Working Fortnight coin c/f fetching worker wise --

    SELECT nvl(MINIMUMSALARYPAYABLE,0) MINIMUMSALARYPAYABLE, nvl(ROUNDOFFRS,0) ROUNDOFFRS, 
    nvl(PROCESSTYPE,'FORTNIGHTLY') PROCESSTYPE,ROUNDOFFTYPE, nvl(ESIEMLPLOYEEPERCENT,0) ESIEMLPLOYEEPERCENT,
    NVL(PFEMLPLOYEEPERCENT,0) PFEMLPLOYEEPERCENT,  NVL(MAXIMUMPFGROSS,0) MAXIMUMPFGROSS,  NVL(MAXIMUMPF,0) MAXIMUMPF
    INTO lv_MinimumPayableAmt, lv_RoundOffRs, lv_ProcessType , lv_RoundoffType, lv_ESI_E_Perc,
    lv_PF_PERCENT, lv_MAX_PFGROSS, lv_MAX_PF_CONT
    FROM WPSWAGESPARAMETER WHERE COMPANYCODE= P_COMPCODE AND DIVISIONCODE = P_DIVCODE;
     
    --- START BELOW BLOCK CONSIDER FOR PREVIOUS PAYMENT WIHCH CONSIDER IN CURRENT WAGES PAYMENT FOR REFERES IN DEDUCTION STATEMENT
    DELETE FROM GTT_WPS_PREV_FNDATA;
    
--    if SUBSTR(P_FNSTDT,1,2) = '16' THEN
--        INSERT INTO GTT_WPS_PREV_FNDATA
--        SELECT WORKERSERIAL, TOKENNO,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, 
--        NVL(GROSS_PTAX,0) GROSS_PTAX, NVL(P_TAX,0) P_TAX , NVL(PF_GROSS,0) PF_GROSS, NVL(PENSION_GROSS,0) PENSION_GROSS, 
--        NVL(PF_CONT,0) PF_CONT, NVL(PF_COM,0) PF_COM, NVL(FPF,0) FPF,
--        NVL(ESI_GROSS,0) ESI_GROSS, NVL(ESI_CONT,0) ESI_CONT, NVL(ESI_COMP_CONT,0) ESI_COMP_CONT, NVL(VPF,0) VPF 
--        FROM WPSWAGESDETAILS_MV
--        WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
--          AND FORTNIGHTSTARTDATE = to_date('01/'||substr(P_FNSTDT,4,7),'dd/mm/yyyy') 
--          AND FORTNIGHTENDDATE = to_date('15/'||substr(P_FNSTDT,4,7),'dd/mm/yyyy');
--          
--          
--    end if;
        

    lv_Sql := ' INSERT INTO GTT_WPS_PREV_FNDATA (WORKERSERIAL, PF_GROSS, PENSION_GROSS, PF_CONT, PF_COM, FPF, VPF, '||chr(10) 
        ||' ESI_GROSS, ESI_CONT, ESI_COMP_CONT, GROSS_PTAX, P_TAX ) '||chr(10)
        ||' SELECT WORKERSERIAL, SUM(PF_GROSS) PF_GROSS, SUM(PENSION_GROSS) PENSION_GROSS, SUM(PF_CONT) PF_CONT, SUM(PF_COM) PF_COM, SUM(FPF) FPF, SUM(VPF) VPF, '||chr(10) 
        ||' SUM(ESI_GROSS) ESI_GROSS, SUM(ESI_CONT) ESI_CONT, SUM(ESI_COMP_CONT) ESI_COMP_CONT, SUM(GROSS_PTAX) GROSS_PTAX, SUM(P_TAX) P_TAX '||chr(10)
        ||' FROM ('||chr(10);
    if  SUBSTR(P_FNSTDT,1,2) = '16' THEN
        lv_Sql := lv_Sql||'      SELECT WORKERSERIAL, NVL(PF_GROSS,0) PF_GROSS, NVL(PENSION_GROSS,0) PENSION_GROSS, NVL(PF_CONT,0) PF_CONT, NVL(PF_COM,0) PF_COM, NVL(FPF,0) FPF, NVL(VPF,0) VPF, '||chr(10) 
            ||'      NVL(ESI_GROSS,0) ESI_GROSS, NVL(ESI_CONT,0) ESI_CONT, NVL(ESI_COMP_CONT,0) ESI_COMP_CONT, NVL(GROSS_PTAX,0) GROSS_PTAX, NVL(P_TAX,0) P_TAX  '||chr(10)
            ||'      FROM WPSWAGESDETAILS_MV  '||chr(10)
            ||'      WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
            ||'        AND FORTNIGHTSTARTDATE = to_date(''01/''||substr('''||P_FNSTDT||''',4,7),''dd/mm/yyyy'')  '||chr(10) 
            ||'        AND FORTNIGHTENDDATE = to_date(''15/''||substr('''||P_FNSTDT||''',4,7),''dd/mm/yyyy'')  '||chr(10)
            ||'      UNION ALL '||chr(10);
    
    end if;            
    lv_Sql := lv_Sql||'      SELECT WORKERSERIAL, NVL(PF_GROSS,0) PF_GROSS,  NVL(PENSION_GROSS,0) PENSION_GROSS, NVL(PF_E,0) PF_CONT, NVL(PF_C,0) PF_COM, NVL(FPF,0) FPF, 0 VPF, '||chr(10) 
        ||'      NVL(ESI_GROSS,0) ESI_GROSS, NVL(ESI_E,0) ESI_CONT, NVL(ESI_C,0) ESI_COMP_CONT, NVL(GROSS_PTAX,0) GROSS_PTAX, NVL(P_TAX,0) P_TAX '||chr(10)
        ||'      FROM WPSSTLWAGESDETAILS '||chr(10)
        ||'      WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
        ||'        AND YEARCODE = '''||P_YEARCODE||'''   '||chr(10)
        ||'        AND PAYMENTDATE >= to_date(''01/''||substr('''||P_FNSTDT||''',4,7),''dd/mm/yyyy'') '||chr(10)
        ||'        AND PAYMENTDATE <= '''||lv_fn_LastDailyWagesDT||''' '||chr(10)
        ||'      ) GROUP BY WORKERSERIAL '||CHR(10);
    lv_remarks := 'PREVIOUS WAGES PAYMENT DATA INSERT INTO GTT_WPS_PREV_FNDATA';      
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
    COMMIT;
    EXECUTE IMMEDIATE lv_Sql;    
    COMMIT;
    FOR C1 in (
            SELECT COMPONENTCODE, COMPONENTSHORTNAME, COMPONENTTYPE, AMOUNTORFORMULA, MANUALFORAMOUNT, FORMULA, CALCULATIONINDEX, PHASE, 
            NVL(TAKEPARTINWAGES,'N') AS TAKEPARTINWAGES, NVL(COLUMNINATTENDANCE,'N') AS COLUMNINATTENDANCE, 
            NVL(COMPONENTTAG,'N') AS COMPONENTTAG, NVL(COMPONENTGROUP,'XXXXX') AS COMPONENTGROUP 
            FROM WPSCOMPONENTMASTER
            WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
            AND PHASE = P_PHASE
            AND NVL(TAKEPARTINWAGES,'N') = 'Y'
            ORDER BY CALCULATIONINDEX           
            
          )
    LOOP          
       -- DBMS_OUTPUT.PUT_LINE(C1.COMPONENTGROUP);
        lv_Sql_TblCreate := lv_Sql_TblCreate ||', '||C1.COMPONENTSHORTNAME|| ' NUMBER(11,2) DEFAULT 0';
        if instr(C1.COMPONENTGROUP,'LOAN') > 0 Then  --- loan componet should be 0 in component view
            lv_Component := lv_Component ||', 0 AS '||C1.COMPONENTSHORTNAME;
        elsif C1.COMPONENTGROUP = 'LIC' Then  --- loan componet should be 0 in component view
            lv_Component := lv_Component ||', 0 AS '||C1.COMPONENTSHORTNAME;
        ELSE 
            IF UPPER(TRIM(C1.AMOUNTORFORMULA)) = 'FORMULA' THEN
                If InStr(C1.FORMULA, '~') > 0 Then
                    --dbms_output.put_line(C1.FORMULA);
                    lv_Sql:= C1.FORMULA;
                    --select REPLACE('''A001''','''','''''')  FROM DUAL
                    lv_Sql:= replace(lv_Sql,'''','''''');
                    lv_Sql:= 'SELECT FN_REPL_FORMULA('''||lv_Sql||''') FROM DUAL'; 
                    
                    --BEGIN
                    EXECUTE IMMEDIATE lv_Sql into lv_SqlTemp ;
                    --EXCEPTION WHEN OTHERS THEN
                    --    insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) values( 'ZZZ PROC_WPSWAGESPROCESS_UPDATE',lv_Sql,lv_Sql,lv_parvalues,lv_remarks);
                    --    RETURN;
                    --END ;
                    lv_Component := lv_Component ||', SUM('||lv_SqlTemp||')  AS '||C1.COMPONENTSHORTNAME;
    --                lv_ComponentNew := lv_ComponentNew||''''||C1.COMPONENTSHORTNAME||'''' as COMPONENTSHORTNAME, SUM('||lv_SqlTemp||')  AS COMPVALUE';
                ELSE
                    lv_Component := lv_Component ||', SUM('||C1.FORMULA||') AS '|| C1.COMPONENTSHORTNAME;    
                END IF;
            ELSE
                lv_Component := lv_Component ||', SUM(NVL(ATTN.'||C1.COMPONENTSHORTNAME||',0)) AS '|| C1.COMPONENTSHORTNAME;
            END IF;
        END IF; 
    END loop;
        
    lv_Component :=  Replace(lv_Component, 'ATTN', 'WPSTEMPATTN');
    lv_Component := Replace(lv_Component, 'MAST', 'WPSTEMPMAST');
    lv_Component := Replace(lv_Component, 'COMPONENT', 'WPSTEMPCOMPONENT');
    --DBMS_OUTPUT.PUT_LINE ('XXX '||lv_Component);
    lv_Sql := ' CREATE TABLE '||P_PHASE_TABLENAME||' AS '||CHR(10)
            ||' SELECT WPSTEMPATTN.WORKERSERIAL,  WPSTEMPMAST.WORKERCATEGORYCODE, '||CHR(10)  
            ||' SUM(NVL(WPSTEMPCOMPONENT.GROSS_WAGES,0)) AS GROSS_WAGES '||CHR(10)  
            ||' '|| lv_Component ||chr(10) 
            ||' FROM WPSTEMPMAST, WPSTEMPATTN, WPSTEMPCOMPONENT '||chr(10)   
            ||' WHERE WPSTEMPATTN.WORKERSERIAL = WPSTEMPMAST.WORKERSERIAL '||chr(10) 
            ||'   AND WPSTEMPATTN.WORKERSERIAL = WPSTEMPCOMPONENT.WORKERSERIAL  '||chr(10);
    if P_WORKERSERIAL is not null then
        lv_Sql := lv_Sql ||' AND WPSTEMPMAST.WORKERSERIAL IN ('||P_WORKERSERIAL||')' ||CHR(10); 
    end if; 
    lv_Sql := lv_Sql ||' GROUP BY WPSTEMPATTN.WORKERSERIAL, WPSTEMPMAST.WORKERCATEGORYCODE '||chr(10);        
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, 'PHASE TABLE CREATION '||lv_SrlNo);
    lv_SrlNo:=lv_SrlNo+1;
--    DBMS_OUTPUT.PUT_LINE ('AMALESH- '||lv_Sql); 
    EXECUTE IMMEDIATE lv_Sql;  
    lv_Sql := '';
    COMMIT;

    --DBMS_OUTPUT.PUT_LINE ('AMALESH12345 - '||lv_Sql);
    --RETURN;

    ---- BELOW PROCERURE CALL FOR DATA CONVERT FROM COLUMN TO ROW --- CREATE TABLE NAME  - GTT_SWT_PHASE_DEDN
    lv_Sql := 'begin  proc_wps_PHASE_DEDN_rowise('''||P_COMPCODE||''','''||P_DIVCODE||''', '''||P_FNSTDT||''','''||P_FNENDT||'''); end;';
    EXECUTE IMMEDIATE LV_SQL;
    /*begin     
      proc_wps_PHASE_DEDN_rowise(P_COMPCODE, P_DIVCODE, P_FNSTDT, P_FNENDT);      
    exception
    WHEN OTHERS THEN
        LV_SQLERRM := SQLERRM;
       dbms_output.put_line('xxxxxxxxxxxxxxxxxxx'||LV_SQLERRM);
       RETURN ;
    end; */
    --INSERT INTO WPS_ERROR_LOG(PROC_NAME, ORA_ERROR_MESSG, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_DEDCUTION','','',lv_parvalues, lv_fn_stdt, lv_fn_endt, 'AFTER MERGES '||lv_SrlNo  );
    lv_SrlNo:=lv_SrlNo+1;    
    commit;
    
    lv_strWorkerSerial := 'X';
    For cWages in ( SELECT A.WORKERSERIAL, A.WORKERCATEGORYCODE, A.GROSS_WAGES, A.COMPONENTSHORTNAME, A.COMPONENTAMOUNT, B.CALCULATIONINDEX, 
                    NVL(C.APPLICABLE,'NO') APPLICABLE, NVL(B.COMPONENTGROUP,'XX') COMPONENTGROUP, NVL(B.PARTIALLYDEDUCT,'N') PARTIALLYDEDUCT
                    FROM GTT_SWT_PHASE_DEDN A, WPSCOMPONENTMASTER B, WPSWORKERCATEGORYVSCOMPONENT C--, SWT_PHASE_DEDN D    
                    WHERE B.COMPANYCODE = P_COMPCODE AND B.DIVISIONCODE = P_DIVCODE
                      AND A.COMPONENTSHORTNAME = B.COMPONENTSHORTNAME 
                      AND B.COMPANYCODE= C.COMPANYCODE AND B.DIVISIONCODE = C.DIVISIONCODE
                      AND B.COMPONENTSHORTNAME = C.COMPONENTSHORTNAME
                      AND A.WORKERCATEGORYCODE = C.WORKERCATEGORYCODE
                      AND NVL(C.APPLICABLE,'NO') <> 'NO'
--                    AND A.WORKERSERIAL = D.WORKERSERIAL
                    ORDER BY A.WORKERSERIAL, B.CALCULATIONINDEX )
    LOOP
        lv_intCnt := lv_intCnt+1;
        --INSERT INTO WPS_ERROR_LOG(PROC_NAME, ORA_ERROR_MESSG, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_DEDCUTION','','',lv_parvalues, lv_fn_stdt, lv_fn_endt, 'INSIDE CURSOR LOOP '|| lv_intCnt);
        if lv_strWorkerSerial <> cWages.WORKERSERIAL then
      
            begin
                select NVL(COINCF,0) into lv_CoinBf FROM WPS_PREV_FN_COIN where workerserial = lv_strWorkerSerial;
            exception
                --when others then null;
                when others then lv_CoinBf :=0;
            end;

            pkg_rowtab.WPS_PREV_FNDATA_row(cWages.WORKERSERIAL,lv_RowType_Prev_Data);
            -- select * into lv_RowType_Prev_Data from GTT_WPS_PREV_FNDATA where workerserial = p_workerserial ;
            BEGIN
                SELECT NVL(GROSS_PTAX,0), NVL(P_TAX,0), NVL(PF_GROSS,0), NVL(PF_CONT,0), NVL(ESI_GROSS,0), NVL(ESI_CONT,0), NVL(VPF,0)  
                INTO lv_PREV_FN_PTAXGROSS, lv_PREV_FN_PTAX, lv_PREV_FN_PFGROSS,lv_PREV_FN_PF_E,lv_PREV_FN_ESIGROSS,lv_PREV_FN_ESI_E,
                lv_PREV_FN_VPF 
                FROM GTT_WPS_PREV_FNDATA;
            EXCEPTION
                WHEN OTHERS THEN
                    lv_PREV_FN_PTAXGROSS := 0; 
                    lv_PREV_FN_PTAX :=0; 
                    lv_PREV_FN_PFGROSS :=0;
                    lv_PREV_FN_PF_E :=0;
                    lv_PREV_FN_ESIGROSS :=0;
                    lv_PREV_FN_ESI_E :=0;
                    lv_PREV_FN_VPF :=0;    
            END;


--            if SUBSTR(P_FNSTDT,1,2) = '16' then
--                pkg_rowtab.WPS_PREV_FNDATA_row(cWages.WORKERSERIAL,lv_RowType_Prev_Data);
--                BEGIN
--                    SELECT NVL(GROSS_PTAX,0), NVL(P_TAX,0), NVL(PF_GROSS,0), NVL(PF_CONT,0), NVL(ESI_GROSS,0), NVL(ESI_CONT,0), NVL(VPF,0)  
--                    INTO lv_PREV_FN_PTAXGROSS, lv_PREV_FN_PTAX, lv_PREV_FN_PFGROSS,lv_PREV_FN_PF_E,lv_PREV_FN_ESIGROSS,lv_PREV_FN_ESI_E,
--                    lv_PREV_FN_VPF 
--                    FROM GTT_WPS_PREV_FNDATA;
--                EXCEPTION
--                    WHEN OTHERS THEN
--                        lv_PREV_FN_PTAXGROSS := 0; 
--                        lv_PREV_FN_PTAX :=0; 
--                        lv_PREV_FN_PFGROSS :=0;
--                        lv_PREV_FN_PF_E :=0;
--                        lv_PREV_FN_ESIGROSS :=0;
--                        lv_PREV_FN_ESI_E :=0;
--                        lv_PREV_FN_VPF :=0;    
--                END;
--            end if;
            
            if lv_intCnt <> 1 then
                lv_ComponentAmt := FN_ROUNDOFFRS(lv_GrossWages + nvl(lv_CoinBf,0) - lv_TotalDedn,lv_RoundOffRs,lv_RoundoffType);
                lv_TempDednAmt := lv_GrossWages + nvl(lv_CoinBf,0) - lv_TotalDedn - lv_ComponentAmt;
                lv_CoinBf := NVL(lv_CoinBf,0);
                --lv_Sql := 'UPDATE WPSWAGESDETAILS_MV_SWT set ACTUALPAYBLEAMOUNT = '||lv_ComponentAmt||' where workerserial = '''||lv_strWorkerSerial||''' ';
                
                lv_Sql := 'UPDATE WPSWAGESDETAILS_MV_SWT set ACTUALPAYBLEAMOUNT = '||lv_ComponentAmt||', COINCF = '||lv_TempDednAmt||', COINBF='||lv_CoinBf||' where workerserial = '''||lv_strWorkerSerial||''' ';
                execute immediate lv_Sql;
               -- PRASUN insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_DEDUCTION','',lv_Sql||',COINCF - '||lv_CoinCf||',COINBF - '||lv_CoinBF||';',lv_parvalues, lv_fn_stdt, lv_fn_endt,lv_remarks||' WOKERSERIAL '||lv_strWorkerSerial||' '||lv_SrlNo );
                --insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_DEDUCTION','ACTUALPAYBLEAMOUNT','1: ' ||lv_GrossWages || ' ' || nvl(lv_CoinBf,0)|| ' ' ||lv_TotalDedn|| ' ' ||lv_RoundOffRs|| ' ' ||lv_RoundoffType,lv_parvalues, lv_fn_stdt, lv_fn_endt,lv_remarks||' WOKERSERIAL '||lv_strWorkerSerial||' '||lv_SrlNo );
                lv_SrlNo:=lv_SrlNo+1;
                commit;
            end if;
            lv_strWorkerSerial := cWages.WORKERSERIAL;
            lv_WagesAsOn := cWages.GROSS_WAGES - lv_MinimumPayableAmt + (lv_CoinBf);
            lv_GrossWages := cWages.GROSS_WAGES;
            lv_TotalDedn :=0;
              
        end if; 
        lv_TempDednAmt := 0;
        lv_ComponentAmt := cWages.COMPONENTAMOUNT;
        ------
        --DBMS_OUTPUT.PUT_LINE(cWages.COMPONENTGROUP);
        
        CASE cWages.COMPONENTGROUP
            WHEN 'ESI' THEN
                if lv_ComponentAmt > 0 then
                
                
--                    if SUBSTR(P_FNSTDT,1,2) = '16' THEN
                        BEGIN
                            SELECT ESI_GROSS, ESI_CONT INTO lv_PREV_FN_ESIGROSS, lv_PREV_FN_ESI_E
                            FROM GTT_WPS_PREV_FNDATA 
                            WHERE WORKERSERIAL = cWages.WorkerSerial;
                        EXCEPTION
                            WHEN OTHERS THEN 
                                lv_PREV_FN_ESIGROSS :=0;
                                lv_PREV_FN_ESI_E := 0;        
                        END;
                        IF NVL(lv_PREV_FN_ESI_E,0) >0 THEN                     
                            lv_ComponentAmt := lv_ComponentAmt+ NVL(lv_PREV_FN_ESIGROSS,0); -- NVL(lv_RowType_Prev_Data.ESI_GROSS,0);
                            lv_ComponentAmt := round(lv_ComponentAmt,0);    --- gross value convert to system round off on 14.07.2020 as mail by sonthalia ji.
--                            --- b4 ceiling 1st round off 2 paisa then next hoight digit on 14.07.2020 as mail and advised by sonthalia ji.
                            lv_ComponentAmt := ceil(TRUNC(lv_ComponentAmt*0.01*lv_ESI_E_Perc,2));
                            --lv_ComponentAmt := ceil(lv_ComponentAmt*0.01*lv_ESI_E_Perc);    
                            lv_ComponentAmt := lv_ComponentAmt - NVL(lv_PREV_FN_ESI_E,0);--  NVL(lv_RowType_Prev_Data.ESI_CONT,0);
                        ELSE
                            --lv_ComponentAmt := ceil(lv_ComponentAmt*0.01*lv_ESI_E_Perc);
                            lv_ComponentAmt := round(lv_ComponentAmt,0);    --- gross value convert to system round off on 14.07.2020 as mail by sonthalia ji.
                            lv_ComponentAmt := ceil(TRUNC(lv_ComponentAmt*0.01*lv_ESI_E_Perc,2));
                        END IF;    
--                    else
--                        lv_ComponentAmt := ceil(lv_ComponentAmt*0.01*lv_ESI_E_Perc);    
--                    end if;
                 else
                    lv_ComponentAmt :=0;
                 end if;   
                    lv_PREV_FN_PTAXGROSS := 0; 
                    lv_PREV_FN_PTAX :=0; 
                    lv_PREV_FN_PFGROSS :=0;
                    lv_PREV_FN_PF_E :=0;
                    lv_PREV_FN_ESIGROSS :=0;
                    lv_PREV_FN_ESI_E :=0;    
            WHEN 'PF' THEN
                lv_ComponentAmt := cWages.COMPONENTAMOUNT;
--                IF cWages.Workerserial = '000033' then
--                    dbms_output.put_line ('1_1 - '||lv_ComponentAmt);
--                end if;
    ----- BELOW PART IS AMMEND ON12.07.2020 BECAUSE USER WANT TO CALCULATE ACTUAL PF CONTRIBUTION BASED ON                  
                BEGIN
                    SELECT PF_GROSS, PF_CONT INTO lv_PREV_FN_PFGROSS, lv_PREV_FN_PF_E
                    FROM GTT_WPS_PREV_FNDATA 
                    WHERE WORKERSERIAL = cWages.WorkerSerial;
                EXCEPTION
                    WHEN OTHERS THEN 
                        lv_PREV_FN_PFGROSS :=0;
                        lv_PREV_FN_PF_E := 0;        
                END;
                IF NVL(lv_PREV_FN_PF_E,0) > 0 THEN
                                     
                    lv_ComponentAmt := lv_ComponentAmt+ NVL(lv_PREV_FN_PFGROSS,0); -- NVL(lv_RowType_Prev_Data.ESI_GROSS,0);
                    
                    lv_ComponentAmt := ROUND(lv_ComponentAmt*0.01*lv_PF_PERCENT,0);
                    lv_ComponentAmt := lv_ComponentAmt - NVL(lv_PREV_FN_PF_E,0);--  NVL(lv_RowType_Prev_Data.ESI_CONT,0);
                ELSE
                    lv_ComponentAmt := round(lv_ComponentAmt*0.01*lv_PF_PERCENT,0);
                END IF;    
                
            --- BELOW PART NOT REQUIRED TO NAIHATI BECAUSE THEY NOT MAINTAIN THE MAXIMUM LIMIT FOR THE WORKER'S
--               --lv_PF_PERCENT, lv_MAX_PFGROSS, lv_MAX_PF_CONT
----               IF SUBSTR(P_FNSTDT,1,2) = '16' THEN
               
--                    BEGIN
--                        SELECT PF_GROSS, PF_CONT INTO lv_PREV_FN_PFGROSS, lv_PREV_FN_PF_E
--                        FROM GTT_WPS_PREV_FNDATA 
--                        WHERE WORKERSERIAL = cWages.WorkerSerial;
--                    EXCEPTION
--                        WHEN OTHERS THEN 
--                            lv_PREV_FN_PFGROSS :=0;
--                            lv_PREV_FN_PF_E := 0;        
--                    END; 
--                    lv_ComponentAmt := lv_ComponentAmt+ NVL(lv_PREV_FN_PFGROSS,0);  -- NVL(lv_RowType_Prev_Data.PF_GROSS,0);
--                    if lv_ComponentAmt > lv_MAX_PFGROSS then
--                        lv_TempDednAmt_Prev := lv_MAX_PFGROSS-NVL(lv_PREV_FN_PFGROSS,0); 
--                        lv_Sql := 'UPDATE '||P_TABLENAME||' SET PF_GROSS= '||lv_TempDednAmt_Prev||' WHERE WORKERSERIAL = '''||cWages.WORKERSERIAL||''' '||CHR(10);
--                        EXECUTE IMMEDIATE lv_Sql;                 
--                    end if;
--                    lv_ComponentAmt := round(lv_ComponentAmt*lv_PF_PERCENT*0.01,0);
--                    if lv_ComponentAmt > lv_MAX_PF_CONT then
--                        lv_ComponentAmt := lv_MAX_PF_CONT;
--                    end if;
--                    lv_ComponentAmt := lv_ComponentAmt - NVL(lv_PREV_FN_PF_E,0);    --NVL(lv_RowType_Prev_Data.PF_CONT,0);

----               ELSE
----                    lv_ComponentAmt := round(lv_ComponentAmt*lv_PF_PERCENT*0.01,0);
----                    if lv_ComponentAmt > lv_MAX_PF_CONT then
----                        lv_ComponentAmt := lv_MAX_PF_CONT;
----                    end if;
----               END IF;     
               
            WHEN 'VPF' then
                lv_ComponentAmt := 0;
--                -----------TEMPORARY DISABLE DUE TO NO VPF IN NAIHATI ------------
--                begin
--                    SELECT NVL(VPF_PERC,0) INTO lv_VPF_PERCENT
--                    FROM WPSTEMPMAST
--                    where workerserial = cWages.WORKERSERIAL;
--                exception
--                    when others then lv_VPF_PERCENT :=0;      
--                end;                
--               IF SUBSTR(P_FNSTDT,1,2) = '16' THEN
--                    BEGIN
--                        SELECT PF_GROSS, VPF INTO lv_PREV_FN_PFGROSS, lv_PREV_FN_VPF
--                        FROM GTT_WPS_PREV_FNDATA 
--                        WHERE WORKERSERIAL = cWages.WorkerSerial;
--                    EXCEPTION
--                        WHEN OTHERS THEN 
--                            lv_PREV_FN_PFGROSS :=0;
--                            lv_PREV_FN_VPF := 0;        
--                    END;                
--                    lv_ComponentAmt := lv_ComponentAmt+ NVL(lv_PREV_FN_PFGROSS,0);  -- NVL(lv_RowType_Prev_Data.PF_GROSS,0);
--                    IF lv_ComponentAmt > lv_MAX_PFGROSS then
--                       lv_ComponentAmt :=  lv_MAX_PFGROSS;
--                    end if;   
--                    lv_ComponentAmt := round(lv_ComponentAmt*lv_VPF_PERCENT*0.01,0);
--                    lv_ComponentAmt := lv_ComponentAmt - NVL(lv_PREV_FN_VPF,0);    --NVL(lv_RowType_Prev_Data.PF_CONT,0);
--               ELSE
--                    IF lv_ComponentAmt > lv_MAX_PFGROSS then
--                        lv_ComponentAmt :=  lv_MAX_PFGROSS;
--                    end if;
--                    lv_ComponentAmt := round(lv_ComponentAmt*lv_VPF_PERCENT*0.01,0);
--               END IF;     
            
            WHEN 'PTAX' THEN
                IF SUBSTR(P_FNSTDT,1,2) = '16' THEN
                    if lv_ProcessType = 'MONTHLY' THEN
                        SELECT NVL(PTAXAMOUNT,0) into lv_TempVal FROM PTAXSLAB
                        WHERE 1=1
                          AND STATENAME = 'WEST BENGAL'
                          AND WITHEFFECTFROM = ( SELECT MAX(WITHEFFECTFROM) FROM PTAXSLAB WHERE STATENAME = 'WEST BENGAL' AND WITHEFFECTFROM <= lv_fn_stdt)
                          AND SLABAMOUNTFROM <= lv_ComponentAmt  
                          AND SLABAMOUNTTO >= lv_ComponentAmt;
                          lv_ComponentAmt := nvl(lv_TempVal,0);
                    else            -- OTHER WISER CONSIDER PROCESS TYPE - FORTNIGHTLY
                        --if SUBSTR(P_FNSTDT,1,2) = '16' THEN
                            lv_PREV_FN_PTAXGROSS := 0;
                            lv_PREV_FN_PTAX := 0;
                            BEGIN
                                SELECT GROSS_PTAX, P_TAX INTO lv_PREV_FN_PTAXGROSS, lv_PREV_FN_PTAX
                                FROM GTT_WPS_PREV_FNDATA 
                                WHERE WORKERSERIAL = cWages.WorkerSerial;
                            EXCEPTION
                                WHEN OTHERS THEN 
                                    lv_PREV_FN_PTAXGROSS :=0;
                                    lv_PREV_FN_PTAX := 0;        
                            END; 
                            --lv_ComponentAmt := lv_ComponentAmt+ NVL(lv_RowType_Prev_Data.GROSS_PTAX,0);
                            lv_ComponentAmt := lv_ComponentAmt+ lv_PREV_FN_PTAXGROSS;    
                       -- end if;
                        begin
                            SELECT PTAXAMOUNT into lv_TempVal FROM PTAXSLAB
                            WHERE 1=1
                              AND STATENAME = 'WEST BENGAL'
                              AND WITHEFFECTFROM = ( SELECT MAX(WITHEFFECTFROM) FROM PTAXSLAB WHERE STATENAME = 'WEST BENGAL' AND WITHEFFECTFROM <= lv_fn_stdt)
                              AND SLABAMOUNTFROM <= lv_ComponentAmt  
                              AND SLABAMOUNTTO >= lv_ComponentAmt;
                        exception
                            when others then 
                              null;
                        end;
                        if SUBSTR(P_FNSTDT,1,2) = '16' THEN  
                            --lv_ComponentAmt := nvl(lv_TempVal,0) - nvl(lv_RowType_Prev_Data.P_TAX,0);
                            lv_ComponentAmt := nvl(lv_TempVal,0) - lv_PREV_FN_PTAX;
                        else
                            lv_ComponentAmt := nvl(lv_TempVal,0);
                        end if;                     
                    end if;
                ELSE
                    lv_ComponentAmt := 0;    
                END IF;
             WHEN 'PF LOAN' THEN
                lv_ComponentAmt := 0;
                --- ONLY SALARY AND FINAL SETTLEMENT TIME LOAN VALUE CALCULATE IN THE SYSTEM ---
               -- if P_TRANTYPE = 'SALARY' OR P_TRANTYPE = 'FINAL SETTLEMENT' then
                    lv_ComponentAmt := cWages.COMPONENTAMOUNT;
                    lv_ComponentAmt:=0;
                    lv_PFLN_CAP_STOP :='N';
                    lv_PFLN_INT_STOP :='N';
                    BEGIN
                        
                        if substr(cWages.COMPONENTSHORTNAME,1,5) = 'LOAN_' THEN 
                            SELECT CASE WHEN PFLOAN_BAL > CAP_EMI THEN CAP_EMI ELSE PFLOAN_BAL END, CAP_EMI_DEDUCT_TYPE, NVL(CAP_STOP,'N') 
                            INTO lv_ComponentAmt, lv_EMI_DEDN_TYPE, lv_PFLN_CAP_STOP   
                            FROM GBL_PFLOANBLNC 
                            WHERE WORKERSERIAL = cWages.WorkerSerial
                              AND LOANCODE = substr(cWages.COMPONENTSHORTNAME,6)
                              AND NVL(CAP_STOP,'N') = 'N'
                              AND PFLOAN_BAL > 0;
                              --DBMS_OUTPUT.PUT_LINE('WORKERSERIAL '||cWages.WORKERSERIAL||', COMPONENT '||substr(cWages.COMPONENTSHORTNAME,1,5)||' lv_ComponentAmt ' || lv_ComponentAmt);
                        elsif substr(cWages.COMPONENTSHORTNAME,1,5) = 'LINT_' THEN 
                            SELECT CASE WHEN NVL(PFLOAN_INT_BAL,0) > NVL(INT_EMI,0) THEN INT_EMI ELSE PFLOAN_INT_BAL END , INT_EMI_DEDUCT_TYPE, NVL(INT_STOP,'N') 
                            INTO lv_ComponentAmt, lv_EMI_DEDN_TYPE, lv_PFLN_INT_STOP  
                            FROM GBL_PFLOANBLNC 
                            WHERE WORKERSERIAL = cWages.WorkerSerial
                              AND LOANCODE = substr(cWages.COMPONENTSHORTNAME,6)
                              AND NVL(INT_STOP,'N') = 'N'
                              AND PFLOAN_INT_BAL > 0;
                        
                        
                        insert into WPS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE, ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
                                values( P_COMPCODE, P_DIVCODE,'PROC_WPSWAGESPROCESS_DEDUCTION','',SYSDATE, lv_SqlStr,'COM = '||cWages.COMPONENTSHORTNAME||' WS = '||cWages.WorkerSerial||'  COMVAL = '||lv_ComponentAmt||' WAGES = '||lv_WagesAsOn, lv_fn_stdt, lv_fn_endt, lv_Remarks);

                        else
                            lv_ComponentAmt := 0;
                        end if;
                        
                        --DBMS_OUTPUT.PUT_LINE('PFL   '||lv_WagesAsOn||'    '||lv_ComponentAmt);
                        if lv_WagesAsOn <  lv_ComponentAmt then             
                           -- if lv_EMI_DEDN_TYPE = 'FULL' then
                           IF cWages.PARTIALLYDEDUCT = 'N' THEN
                                lv_ComponentAmt := 0;
                            else
                                lv_ComponentAmt := floor(lv_WagesAsOn);
                            end if;              
                        end if;  
                                              
                    EXCEPTION WHEN NO_DATA_FOUND THEN lv_ComponentAmt := 0;
                              WHEN OTHERS THEN lv_ComponentAmt := 0;      
                    END;        
                --else
               --     lv_ComponentAmt := 0;
                --end if;                
            WHEN 'LOAN' THEN
                lv_ComponentAmt:=0;
                --- ONLY SALARY AND FINAL SETTLEMENT TIME LOAN VALUE CALCULATE IN THE SYSTEM ---
                --if P_TRANTYPE = 'SALARY' OR P_TRANTYPE ='FINAL SETTLEMENT' then
                    /* CHANGES AS ON 03/12/2018' PARTIAL*/    
--                    lv_EMI_DEDN_TYPE := 'PARTIAL';
                    /* CHANGES AS ON 03/12/2018' PARTIAL*/   
                    
--                    DBMS_OUTPUT.PUT_LINE('GENERAL LOAN : '||lv_WagesAsOn ||'  '||  lv_ComponentAmt);
                    
                    BEGIN
                        if substr(cWages.COMPONENTSHORTNAME,1,5) = 'LOAN_' THEN 
                            SELECT CASE WHEN LOAN_BAL > CAP_EMI THEN CAP_EMI ELSE LOAN_BAL END, CAP_EMI_DEDUCT_TYPE INTO lv_ComponentAmt, lv_EMI_DEDN_TYPE  
                            FROM GBL_LOANBLNC 
                            WHERE WORKERSERIAL = cWages.WorkerSerial and MODULE = 'WPS'
                              AND LOANCODE = substr(cWages.COMPONENTSHORTNAME,6)
                              AND LOAN_BAL > 0;
                        elsif substr(cWages.COMPONENTSHORTNAME,1,5) = 'LINT_' THEN 
                            SELECT CASE WHEN LOAN_INT_BAL > INT_EMI THEN INT_EMI ELSE LOAN_INT_BAL END, INT_EMI_DEDUCT_TYPE INTO lv_ComponentAmt, lv_EMI_DEDN_TYPE  
                            FROM GBL_LOANBLNC 
                            WHERE WORKERSERIAL = cWages.WorkerSerial and MODULE = 'WPS'
                              AND LOANCODE = substr(cWages.COMPONENTSHORTNAME,6)
                              AND LOAN_INT_BAL > 0;
                        else
                            lv_ComponentAmt := 0;
                        end if;
                        /* CHANGES AS ON 03/12/2018' PARTIAL*/    
                        if lv_WagesAsOn <  lv_ComponentAmt then             
--                            if lv_EMI_DEDN_TYPE = 'FULL' then
                            IF cWages.PARTIALLYDEDUCT = 'N' THEN
                                lv_ComponentAmt := 0;
                            else
                                lv_ComponentAmt := floor(lv_WagesAsOn); 
                            end if;              
                        end if;  
                        
                        /* CHANGES AS ON 03/12/2018' PARTIAL*/    
                    EXCEPTION WHEN NO_DATA_FOUND THEN lv_ComponentAmt := 0;
                              WHEN OTHERS THEN lv_ComponentAmt := 0;      
                    END;
               -- end if; 
            WHEN 'ELECTRICITY' then
                BEGIN
                    BEGIN
                         SELECT ATTENDANCEHOURS INTO lv_ChkAttnHrs FROM WPSTEMPATTN WHERE WORKERSERIAL = cWages.WorkerSerial;
                    EXCEPTION
                        WHEN OTHERS THEN lv_ChkAttnHrs:=0;
                    END;
                        
                    IF lv_ChkAttnHrs > 0 THEN
                        SELECT CASE WHEN NVL(ELEC_BAL_AMT,0) > NVL(ELEC_EMI_AMT,0) THEN ELEC_EMI_AMT ELSE ELEC_BAL_AMT END INTO lv_ComponentAmt  
--                        SELECT NVL(ELEC_BAL_AMT,0) INTO lv_ComponentAmt 
                        FROM GBL_ELECBLNC
                        WHERE WORKERSERIAL = cWages.WorkerSerial
                        and NVL(ELEC_BAL_AMT,0) > 0; 
                    ELSE
                        lv_ComponentAmt := 0;
                    END IF; 
                    IF lv_ComponentAmt > 0 THEN
                        IF NVL(cWages.PARTIALLYDEDUCT,'NA') = 'Y' THEN
                             if lv_WagesAsOn < lv_ComponentAmt then
                                lv_ComponentAmt := floor(lv_WagesAsOn);
                             end if;
                        END IF;            
                    END IF;
                EXCEPTION WHEN NO_DATA_FOUND THEN lv_ComponentAmt := 0;
                          WHEN OTHERS THEN lv_ComponentAmt := 0;      
                END;               
            
            WHEN 'LIC' THEN                  
                lv_ComponentAmt :=0;
            
            else
              lv_ComponentAmt := cWages.COMPONENTAMOUNT;    
        end case;    
        if lv_WagesAsOn >  lv_ComponentAmt then             -- cWages.COMPONENTAMOUNT
            lv_TempDednAmt := lv_ComponentAmt;              -- cWages.COMPONENTAMOUNT;
        else            
            IF NVL(cWages.PARTIALLYDEDUCT,'NA') = 'N' THEN
                lv_TempDednAmt := 0;
            ELSE
                lv_TempDednAmt := lv_WagesAsOn;  
            END IF;
        end if;
        
        if lv_TempDednAmt <> 0 then
            lv_TotalDedn := lv_TotalDedn + lv_TempDednAmt;
            lv_Sql := 'UPDATE WPSWAGESDETAILS_MV_SWT set '||cWages.componentshortname||' = '||nvl(lv_TempDednAmt,0)||', TOT_DEDUCTION = '||nvl(lv_TotalDedn,0)||' where workerserial = '''||cWages.WorkerSerial||''' ';
--            DBMS_OUTPUT.PUT_LINE('WORKERSERIAL '||cWages.WORKERSERIAL||', lv_Sql '||lv_Sql);
          -- PRASUN  
--          insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_DEDUCTION','',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,lv_remarks||' '||lv_SrlNo||' WAGES ON-'||lv_WagesAsOn ||'Component- '||cWages.componentshortname||', WORKERSERIAL - '||cWages.WorkerSerial||'');
            execute immediate lv_Sql;
            --lv_Sql := 'TEST'; 
        end if;
        lv_WagesAsOn := lv_WagesAsOn - lv_TempDednAmt;
        --lv_remarks := 'DEDUCTION COMPONENT UPDATING => WORKSERIAL='||cWages.WORKERSERIAL||',+'||lv_strWorkerSerial||', GROSS WAGES='||cWages.GROSS_WAGES||',Minimum Pay='||lv_MinimumPayableAmt||', As On Balance='||lv_WagesAsOn;
        --insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_DEDUCTION','',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,lv_remarks||' '||lv_SrlNo||' WAGES ON-'||lv_WagesAsOn );
        lv_SrlNo := lv_SrlNo + 1;          
    END LOOP; 
    
--    start for last record update actual pay, coin bf, coin cf
    begin
        select COINCF into lv_CoinBf FROM WPS_PREV_FN_COIN where workerserial = lv_strWorkerSerial;
    exception
        --when others then null;
        when others then lv_CoinBf :=0;
    end;
    lv_ComponentAmt := FN_ROUNDOFFRS(lv_GrossWages + nvl(lv_CoinBf,0)  - lv_TotalDedn,lv_RoundOffRs,lv_RoundoffType);
    lv_CoinCf := (lv_GrossWages + nvl(lv_CoinBf,0)  - lv_TotalDedn) - lv_ComponentAmt; 
    lv_TempDednAmt := lv_GrossWages /*+ nvl(lv_CoinBf,0)*/ - lv_TotalDedn - lv_ComponentAmt;
    --lv_Sql := 'UPDATE WPSWAGESDETAILS_MV_SWT set ACTUALPAYBLEAMOUNT = '||lv_ComponentAmt||' where workerserial = '''||lv_strWorkerSerial||''' ';
    
    lv_Sql := 'UPDATE WPSWAGESDETAILS_MV_SWT set ACTUALPAYBLEAMOUNT = '||lv_ComponentAmt||', COINBF = '||NVL(lv_CoinBf,0)||', COINCF = '||NVL(lv_CoinCF,0)||' where workerserial = '''||lv_strWorkerSerial||''' ';
    execute immediate lv_Sql;
   -- PRASUN  insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_DEDUCTION','',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,lv_remarks||' '||lv_SrlNo||' WAGES ON-'||lv_WagesAsOn||' workerserial '||lv_strWorkerSerial);
   -- insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_DEDUCTION','ACTUALPAYBLEAMOUNT','2: ' ||lv_GrossWages || ' ' || nvl(lv_CoinBf,0)|| ' ' ||lv_TotalDedn|| ' ' ||lv_RoundOffRs|| ' ' ||lv_RoundoffType,lv_parvalues, lv_fn_stdt, lv_fn_endt,lv_remarks||' WOKERSERIAL '||lv_strWorkerSerial||' '||lv_SrlNo );
    lv_SrlNo := lv_SrlNo + 1;
    commit;
--    end for last record update actual pay, coin bf, coin cf

    -------- NEW ADD ON 13.09.2020 ------------
    UPDATE WPSWAGESDETAILS_MV_SWT SET TOT_EARN = GROSS_WAGES+NVL(COINBF,0); 

    --RETURN;
    lv_remarks := 'PF LOAN BALANCE UPDATE';
    PRC_LOANBREAKUP_INSERT_WAGES(P_COMPCODE,P_DIVCODE,P_YEARCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'WPS', P_TABLENAME, 'PF', NULL,NULL, NULL);
    
    lv_remarks := 'GENERAL LOAN BALANCE UPDATE';
    PRC_LOANBREAKUP_INSERT_WAGES(P_COMPCODE,P_DIVCODE,P_YEARCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'WPS', P_TABLENAME, 'GENERAL', NULL,NULL, NULL);
    
    lv_remarks := 'PF LOAN BALANCE UPDATE';     
    PRC_LOANBALANCE_UPDT_WAGES(P_COMPCODE,P_DIVCODE,P_YEARCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'WPS',P_TABLENAME,'PF',NULL,NULL,NULL);    
    
    lv_remarks := 'GENERAL LOAN BALANCE UPDATE'; 
    PRC_LOANBALANCE_UPDT_WAGES(P_COMPCODE,P_DIVCODE,P_YEARCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'WPS',P_TABLENAME,'GENERAL',NULL,NULL,NULL);        
    lv_remarks := 'PHASE - '||P_PHASE||' SUCESSFULLY COMPLETE';
    --insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_DEDUCTION','','',lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);

    --  ELECTRIC DEDUCTION BREAKUP
    --lv_remarks := 'ELECTRIC BREAKUP DATA INSERT';
    --PRC_ELECTRICBREAKUP_INSERT(P_COMPCODE,P_DIVCODE,P_YEARCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'WPS', P_TABLENAME, NULL);
    

 -- LIC DATA REALIZED/ UNREALIZED 
    lv_remarks := 'LIC UNREALIZED DATA INSERT';
    --PRC_REALIZEDUNREALDATA_INSERT (P_COMPCODE,P_DIVCODE,P_YEARCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'WPS', P_TABLENAME,'LIC', 'ALL', NULL);

    --  ELECTRIC DEDUCTION BREAKUP
    lv_remarks := 'ELECTRIC BREAKUP DATA INSERT';
    PRC_ELECTRICBREAKUP_INSERT(P_COMPCODE,P_DIVCODE,P_YEARCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'WPS', P_TABLENAME, NULL);



 -- SHOP RENT DATA REALIZED/ UNREALIZED 
    lv_remarks := 'SHOP RENT UNREALIZED DATA INSERT';
    --PRC_REALIZEDUNREALDATA_INSERT (P_COMPCODE,P_DIVCODE,P_YEARCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'WPS', P_TABLENAME,'SHOP_RENT', 'ALL', NULL);

    


commit;    
--exception
--    when others then
--    lv_sqlerrm := sqlerrm ;
--    insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_DEDUCTION',lv_sqlerrm,lv_Sql,lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks||' '||lv_SrlNo);
--    commit;
    --dbms_output.put_line('PROC - PROC_WPSWAGESPROCESS_UPDATE : ERROR !! WHILE WAGES PROCESS '||P_FNSTDT||' AND PHASE -> '||ltrim(trim(P_PHASE))||' : '||sqlerrm);
end;
/


