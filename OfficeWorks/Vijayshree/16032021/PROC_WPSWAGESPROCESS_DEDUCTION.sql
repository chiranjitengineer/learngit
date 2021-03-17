CREATE OR REPLACE PROCEDURE FORTWILLIAM_WPS.PROC_WPSWAGESPROCESS_DEDUCTION (P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2, 
                                                  P_YEARCODE Varchar2,
                                                  P_FNSTDT Varchar2, 
                                                  P_FNENDT Varchar2,
                                                  P_PHASE  number, 
                                                  P_PHASE_TABLENAME VARCHAR2,
                                                  P_TABLENAME Varchar2,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL,
                                                  P_PROCESSTYPE VARCHAR2 DEFAULT NULL)
as
lv_Component varchar2(32767) := '';
lv_Sql       varchar2(32767) := '';
lv_ComponentNew  varchar2(32767) := '';
lv_Sql_TblCreate    varchar2(3000) := '';  
lv_sqlerrm      varchar2(1000) := ''; 
lv_remarks      varchar2(1000) := '';
lv_parvalues    varchar2(1000) := '';
lv_SqlTemp      varchar2 (2000) := '';
lv_Cols         varchar2 (1000) := '';
lv_fn_stdt      date := to_date(P_FNSTDT,'DD/MM/YYYY');
lv_fn_endt      date := to_date(P_FNENDT,'DD/MM/YYYY');
lv_prev_fn_stdt date;
lv_prev_fn_endt date;
lv_MinimumPayableAmt    number := 0;            -- use for Minimum payment amount which defined in the WPSWAGESPARAMETER TABLE 
lv_RoundOffRs           number := 0;            -- use for Round Off Rs. which defined in the WPSWAGESPARAMETER TABLE
lv_ESI_E_Perc           number := 1.75;         -- USE FOR ESI EMPLOYEE CONTRIBUTION
lv_ProcessType  varchar2(50):= 'FORTNIGHTLY';   -- use for wage process Fortnightly or Monthly which defined in the WPSWAGESPARAMETER TABLE MAINLY REQUIRE FOR P.TAX CALCULATION 
lv_WagesAsOn    number(11,2) := 0;
lv_TempVal      number(11,2) :=0;
lv_TempDednAmt  number(11,2) := 0;
lv_ComponentAmt number(11,2) := 0;
lv_intCnt       number(5) :=0;
lv_GrossWages   number(11,2) := 0;
lv_TotalDedn    number(11,2) := 0;
lv_CoinBf       number(11,2) := 0;
lv_strWorkerSerial  varchar2(10) :='';
lv_SrlNo        number   :=1;                    -- varaible use for serially which No. execute; 
lv_RowType_Prev_Data    GTT_WPS_PREV_FNDATA%ROWTYPE;
lv_RoundoffType varchar2(1) :='';
lv_EMI_DEDN_TYPE    varchar2(20):='PARTIAL';
lv_PFLN_CAP_STOP    varchar2(1) :='N';
lv_PFLN_INT_STOP    varchar2(1) :='N';
begin
    lv_parvalues := 'COMP ='||P_COMPCODE||', DIV = '||P_DIVCODE||',FNS = '||P_FNSTDT||' FNE = '||P_FNENDT||', PHASE = '||P_PHASE;
    lv_sql := 'drop table '||P_PHASE_TABLENAME;
   
 if SUBSTR(P_FNSTDT,1,2) = '16' then
        lv_prev_fn_stdt := to_date('01'||substr(P_FNSTDT,4,7),'dd/mm/yyyy');
    end if;
    
    BEGIN 
        execute immediate lv_sql;
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    --- BEFORE DEDUCTION PAHSE START MERGE WORKER WISER MULIPLE DATA IN A SINGLE DATA
    PROC_WPSWAGESDETAILS_MERGE(P_COMPCODE, P_DIVCODE, P_FNSTDT,P_FNENDT, P_PHASE, 'WPSWAGESDETAILS_SWT', 'WPSWAGESDETAILS_MV_SWT',  P_WORKERSERIAL);
    lv_sql :='';
    PROC_WPSVIEWCREATION (P_COMPCODE,P_DIVCODE,'ATTN',5,P_FNSTDT, P_FNENDT, P_TABLENAME);
    PROC_WPSVIEWCREATION (P_COMPCODE,P_DIVCODE,'COMP',5,P_FNSTDT, P_FNENDT, P_TABLENAME);
    ---- TABLE CREATE FROM VIEW ----------
    
    --PROC_LOANBLNC(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'','','WPS');
    
    PROC_LOANBLNC(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'','','WPS','YES');
    
    PROC_PFLOANBLNC(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'','','WPS','YES');
   
    PRC_PFLN_EMI_UPDT_ONATTN_HRS(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'), TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'WPSWAGESDETAILS_MV_SWT','GBL_PFLOANBLNC','','','');
--    PRC_LOANBREAKUP_INSERT_WAGES(P_COMPCODE,P_DIVCODE,P_YEARCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'WPS', P_TABLENAME, 'PF', NULL,NULL, NULL); 
--    PRC_LOANBALANCE_UPDT_WAGES(P_COMPCODE,P_DIVCODE,P_YEARCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'WPS',P_TABLENAME,'PF',NULL,NULL,NULL);
             

    --ADDED ON 16/03/2021 FOR CASH OT UNREALIZED CHIRANJIT GHOSH
    
    --  CASH OT DATA PREPARATION PROCEDURE CALL
    PROC_CASHOT_BLNC (P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'CASHOT_AMT', P_YEARCODE ,'WPS','YES',NULL);    
    
    --ENDD ON 16/03/2021 FOR CASH OT UNREALIZED  CHIRANJIT GHOSH


             
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
            ||' SELECT A.WORKERSERIAL, A.FORTNIGHTSTARTDATE, A.COINCF '||CHR(10)
            ||' FROM WPSWAGESDETAILS_MV A, '||CHR(10)
            ||'  ( '||CHR(10)
            ||'    SELECT WORKERSERIAL, MAX(FORTNIGHTSTARTDATE) FORTNIGHTSTARTDATE  '||CHR(10)
            ||'    FROM WPSWAGESDETAILS_MV  '||CHR(10)
            ||'    WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
            ||'      AND FORTNIGHTSTARTDATE < '''||lv_fn_stdt||'''  '||CHR(10)
            ||'    GROUP BY WORKERSERIAL  '||CHR(10)
            ||'  ) B  '||CHR(10)
            ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
            ||'   AND A.WORKERSERIAL = B.WORKERSERIAL  '||CHR(10)
            ||'   AND A.FORTNIGHTSTARTDATE = B.FORTNIGHTSTARTDATE  '||CHR(10);
     
    BEGIN
        INSERT INTO WPS_ERROR_LOG(PROC_NAME, ORA_ERROR_MESSG, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_DEDCUTION','',lv_Sql,'', lv_fn_stdt, lv_fn_endt, 'WPS_PREV_FN_COIN');
        DELETE FROM WPS_PREV_FN_COIN WHERE FORTNIGHTSTARTDATE = lv_fn_stdt;
        EXECUTE IMMEDIATE lv_Sql;
    exception
        WHEN OTHERS THEN
            EXECUTE IMMEDIATE lv_Sql;        
    END;
    lv_SqlTemp := '';
    lv_Sql := '';
--    END Previous Working Fortnight coin c/f fetching worker wise --

    SELECT nvl(MINIMUMSALARYPAYABLE,0) MINIMUMSALARYPAYABLE, nvl(ROUNDOFFRS,0) ROUNDOFFRS, 
    nvl(PROCESSTYPE,'FORTNIGHTLY') PROCESSTYPE,ROUNDOFFTYPE, nvl(ESIEMLPLOYEEPERCENT,0) ESIEMLPLOYEEPERCENT 
    INTO lv_MinimumPayableAmt, lv_RoundOffRs, lv_ProcessType , lv_RoundoffType, lv_ESI_E_Perc 
    FROM WPSWAGESPARAMETER WHERE COMPANYCODE= P_COMPCODE AND DIVISIONCODE = P_DIVCODE;
     
    --- START BELOW BLOCK CONSIDER FOR PREVIOUS FORTNIGHT DATA , WIHCH ONLY CONSIDER IN 2ND FORTNIGHT FOR REFERES IN DEDUCTION STATEMENT
    DELETE FROM GTT_WPS_PREV_FNDATA;
    
    if SUBSTR(P_FNSTDT,1,2) = '16' THEN
        INSERT INTO GTT_WPS_PREV_FNDATA
        SELECT WORKERSERIAL, TOKENNO,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, 
        NVL(GROSS_PTAX,0) GROSS_PTAX, NVL(P_TAX,0) P_TAX , NVL(PF_GROSS,0) PF_GROSS, NVL(PENSION_GROSS,0) PENSION_GROSS, 
        NVL(PF_CONT,0) PF_CONT, NVL(PF_COM,0) PF_COM, NVL(FPF,0) FPF,
        NVL(ESI_GROSS,0) ESI_GROSS, NVL(ESI_CONT,0) ESI_CONT, NVL(ESI_COMP_CONT,0) ESI_COMP_CONT
        FROM WPSWAGESDETAILS_MV
        WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
          AND FORTNIGHTSTARTDATE = to_date('01/'||substr(P_FNSTDT,4,7),'dd/mm/yyyy') 
          AND FORTNIGHTENDDATE = to_date('15/'||substr(P_FNSTDT,4,7),'dd/mm/yyyy');
       --insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_DEDCUTION','',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, 'PAHSE TABLE DROPED SUCCESSFULLY');   
    end if;
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
       -- DBMS_OUTPUT.PUT_LINE('COMPONENT : '||lv_AttnComponent);
        lv_Sql_TblCreate := lv_Sql_TblCreate ||', '||C1.COMPONENTSHORTNAME|| ' NUMBER(11,2) DEFAULT 0';
        if C1.COMPONENTGROUP = 'LOAN' Then  --- loan componet should be 0 in component view
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
    --insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_DEDCUTION','',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, 'PHASE TABLE CREATION '||lv_SrlNo);
    lv_SrlNo:=lv_SrlNo+1;
    EXECUTE IMMEDIATE lv_Sql;  
    lv_Sql := '';
    COMMIT;
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
                    NVL(C.APPLICABLE,'NO') APPLICABLE, NVL(B.COMPONENTGROUP,'XX') COMPONENTGROUP , NVL(B.PARTIALLYDEDUCT,'N') PARTIALLYDEDUCT   
                    FROM GTT_SWT_PHASE_DEDN A, WPSCOMPONENTMASTER B, WPSWORKERCATEGORYVSCOMPONENT C--, SWT_PHASE_DEDN D    
                    WHERE A.COMPONENTSHORTNAME = B.COMPONENTSHORTNAME 
                    AND B.COMPONENTSHORTNAME = C.COMPONENTSHORTNAME
                    AND A.WORKERCATEGORYCODE = C.WORKERCATEGORYCODE
                    AND NVL(C.APPLICABLE,'NO') <> 'NO'
--                    AND A.WORKERSERIAL = D.WORKERSERIAL
                    ORDER BY A.WORKERSERIAL, B.CALCULATIONINDEX )
    LOOP
          IF lv_strWorkerSerial IN ('13539','03339')THEN 
                    DBMS_OUTPUT.PUT_LINE('lv_strWorkerSerial :'||lv_strWorkerSerial||'  cWages.COMPONENTGROUP:'||cWages.COMPONENTGROUP);
          END IF;
        lv_intCnt := lv_intCnt+1;
        --INSERT INTO WPS_ERROR_LOG(PROC_NAME, ORA_ERROR_MESSG, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_DEDCUTION','','',lv_parvalues, lv_fn_stdt, lv_fn_endt, 'INSIDE CURSOR LOOP '|| lv_intCnt);
        if lv_strWorkerSerial <> cWages.WORKERSERIAL then
      
            if SUBSTR(P_FNSTDT,1,2) = '16' then
               /* begin
                    SELECT * INTO lv_RowType_Prev_Data FROM GTT_WPS_PREV_FNDATA where workerserial = cWages.WORKERSERIAL;
                exception
                    when others then 
                      null;
                end;*/
                pkg_rowtab.WPS_PREV_FNDATA_row(cWages.WORKERSERIAL,lv_RowType_Prev_Data);
            end if;
            
            if lv_intCnt <> 1 then
                begin
                    select COINCF into lv_CoinBf FROM WPS_PREV_FN_COIN where workerserial = lv_strWorkerSerial;
                exception
                    when others then null;
                end;
                lv_ComponentAmt := FN_ROUNDOFFRS(lv_GrossWages /*+ nvl(lv_CoinBf,0)*/ - lv_TotalDedn,lv_RoundOffRs,lv_RoundoffType);
                lv_TempDednAmt := lv_GrossWages /*+ nvl(lv_CoinBf,0)*/ - lv_TotalDedn - lv_ComponentAmt;
                
                
                lv_Sql := 'UPDATE WPSWAGESDETAILS_MV_SWT set ACTUALPAYBLEAMOUNT = '||lv_ComponentAmt||' where workerserial = '''||lv_strWorkerSerial||''' ';
                execute immediate lv_Sql;
                --insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_DEDUCTION','',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,lv_remarks||' WOKERSERIAL '||lv_strWorkerSerial||' '||lv_SrlNo );
                lv_SrlNo:=lv_SrlNo+1;
                commit;
            end if;
            lv_strWorkerSerial := cWages.WORKERSERIAL;
            lv_WagesAsOn := cWages.GROSS_WAGES - lv_MinimumPayableAmt;
            lv_GrossWages := cWages.GROSS_WAGES;
            lv_TotalDedn :=0;
              
        end if; 
        lv_TempDednAmt := 0;
        lv_ComponentAmt := cWages.COMPONENTAMOUNT;
      
        CASE cWages.COMPONENTGROUP
            WHEN 'ESI' THEN
                if SUBSTR(P_FNSTDT,1,2) = '16' THEN
                    lv_ComponentAmt := lv_ComponentAmt+ NVL(lv_RowType_Prev_Data.ESI_GROSS,0);
                    lv_ComponentAmt := ceil(lv_ComponentAmt*0.01*lv_ESI_E_Perc);
                    lv_ComponentAmt := lv_ComponentAmt -  NVL(lv_RowType_Prev_Data.ESI_CONT,0);
                else
                    lv_ComponentAmt := ceil(lv_ComponentAmt*0.01*lv_ESI_E_Perc);    
                end if;
                
                IF lv_strWorkerSerial IN ('13539','03339') THEN 
                    DBMS_OUTPUT.PUT_LINE('lv_strWorkerSerial :'||lv_strWorkerSerial||'COM:'||lv_ComponentAmt||'; lv_ESI_E_Perc :'||lv_ESI_E_Perc);
                END IF;
               

            WHEN 'PTAX' THEN
                if lv_ProcessType = 'MONTHLY' THEN
                    SELECT NVL(PTAXAMOUNT,0) into lv_TempVal FROM PTAXSLAB
                    WHERE 1=1
                      AND STATENAME = 'WEST BENGAL'
                      AND WITHEFFECTFROM = ( SELECT MAX(WITHEFFECTFROM) FROM PTAXSLAB WHERE STATENAME = 'WEST BENGAL' AND WITHEFFECTFROM <= lv_fn_stdt)
                      AND SLABAMOUNTFROM <= lv_ComponentAmt  
                      AND SLABAMOUNTTO >= lv_ComponentAmt;
                      lv_ComponentAmt := nvl(lv_TempVal,0);
                else            -- OTHER WISER CONSIDER PROCESS TYPE - FORTNIGHTLY
                    if SUBSTR(P_FNSTDT,1,2) = '16' THEN
                        lv_ComponentAmt := lv_ComponentAmt+ NVL(lv_RowType_Prev_Data.GROSS_PTAX,0);
                    end if;
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
                        lv_ComponentAmt := nvl(lv_TempVal,0) - nvl(lv_RowType_Prev_Data.P_TAX,0);
                    else
                        lv_ComponentAmt := nvl(lv_TempVal,0);
                    end if;                     
                end if;
            
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
                            SELECT CASE WHEN PFLOAN_INT_BAL > INT_EMI THEN INT_EMI ELSE PFLOAN_INT_BAL END , INT_EMI_DEDUCT_TYPE, NVL(INT_STOP,'N') 
                            INTO lv_ComponentAmt, lv_EMI_DEDN_TYPE, lv_PFLN_INT_STOP  
                            FROM GBL_PFLOANBLNC 
                            WHERE WORKERSERIAL = cWages.WorkerSerial
                              AND LOANCODE = substr(cWages.COMPONENTSHORTNAME,6)
                              AND NVL(INT_STOP,'N') = 'N'
                              AND PFLOAN_INT_BAL > 0;
                        else
                            lv_ComponentAmt := 0;
                        end if;
                        if lv_WagesAsOn <  lv_ComponentAmt then             
                            if lv_EMI_DEDN_TYPE = 'FULL' then
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
                    BEGIN
                        if substr(cWages.COMPONENTSHORTNAME,1,5) = 'LOAN_' THEN 
                            SELECT CASE WHEN LOAN_BAL >= CAP_EMI THEN CAP_EMI ELSE LOAN_BAL END INTO lv_ComponentAmt  
                            FROM GBL_LOANBLNC 
                            WHERE WORKERSERIAL = cWages.WorkerSerial --and MODULE = 'PIS'
                              AND LOANCODE = substr(cWages.COMPONENTSHORTNAME,6)
                              AND LOAN_BAL > 0;
                        elsif substr(cWages.COMPONENTSHORTNAME,1,5) = 'LINT_' THEN 
                            SELECT CASE WHEN LOAN_INT_BAL > INT_EMI THEN INT_EMI ELSE LOAN_INT_BAL END INTO lv_ComponentAmt  
                            FROM GBL_LOANBLNC 
                            WHERE WORKERSERIAL = cWages.WorkerSerial --and MODULE = 'PIS'
                              AND LOANCODE = substr(cWages.COMPONENTSHORTNAME,6)
                              AND LOAN_INT_BAL > 0;
                        else
                            lv_ComponentAmt := 0;
                        end if;
                    EXCEPTION WHEN NO_DATA_FOUND THEN lv_ComponentAmt := 0;
                              WHEN OTHERS THEN lv_ComponentAmt := 0;      
                    END;
               -- end if; 
                   
            --ADDED ON 16/03/2021 FOR UNREALIZED CASH OT REALIZED             
            WHEN 'UNREALIZED' THEN
                lv_ComponentAmt:=0;
                BEGIN
                  
                    SELECT NVL(CASHOT_UNREALIZED,0) INTO lv_ComponentAmt 
                    FROM GBL_CASHOTUNREALIZED
                    WHERE WORKERSERIAL = cWages.WorkerSerial and MODULE = 'WPS'; 
                    
                EXCEPTION WHEN NO_DATA_FOUND THEN lv_ComponentAmt := 0;
                          WHEN OTHERS THEN lv_ComponentAmt := 0;      
                END; 
               -- end if; 
            else
              lv_ComponentAmt := cWages.COMPONENTAMOUNT;    
        end case;  
          
        if lv_WagesAsOn >  lv_ComponentAmt then             -- cWages.COMPONENTAMOUNT
            lv_TempDednAmt := lv_ComponentAmt;              -- cWages.COMPONENTAMOUNT;
        else            
            --lv_TempDednAmt := lv_WagesAsOn;
            -- PARTIAL DEDUCTION CONSIDER AT THE TIME DEDUCTION OF THE COMPONENT  05/08/2020
            IF NVL(cWages.PARTIALLYDEDUCT,'N') = 'N' THEN
                lv_TempDednAmt := 0;
            ELSE
                lv_TempDednAmt := lv_WagesAsOn;  
            END IF;  
        end if;
        
        if lv_TempDednAmt <> 0 then
            lv_TotalDedn := lv_TotalDedn + lv_TempDednAmt;
            lv_Sql := 'UPDATE WPSWAGESDETAILS_MV_SWT set '||cWages.componentshortname||' = '||lv_TempDednAmt||', TOT_DEDUCTION = '||lv_TotalDedn||' where workerserial = '''||cWages.WorkerSerial||''' ';
            ---DBMS_OUTPUT.PUT_LINE('WORKERSERIAL '||cWages.WORKERSERIAL||', lv_Sql '||lv_Sql);
            --insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_DEDUCTION','',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,lv_remarks||' '||lv_SrlNo||' WAGES ON-'||lv_WagesAsOn ||'Component- '||cWages.componentshortname );
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
        when others then null;
    end;
    lv_ComponentAmt := FN_ROUNDOFFRS(lv_GrossWages /*+ nvl(lv_CoinBf,0) */ - lv_TotalDedn,lv_RoundOffRs,lv_RoundoffType);
    lv_TempDednAmt := lv_GrossWages /*+ nvl(lv_CoinBf,0)*/ - lv_TotalDedn - lv_ComponentAmt;
    lv_Sql := 'UPDATE WPSWAGESDETAILS_MV_SWT set ACTUALPAYBLEAMOUNT = '||lv_ComponentAmt||' where workerserial = '''||lv_strWorkerSerial||''' ';
    execute immediate lv_Sql;
    --insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_DEDUCTION','',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,lv_remarks||' '||lv_SrlNo||' WAGES ON-'||lv_WagesAsOn );
    lv_SrlNo := lv_SrlNo + 1;
    commit;
--    end for last record update actual pay, coin bf, coin cf

--    PROC_LOANBLNC(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'','','WPS');
--    PROC_PFLOANBLNC(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'','','WPS');
    
    lv_remarks := 'PF LOAN BREAKUP UPDATE';
    PRC_LOANBREAKUP_INSERT_WAGES(P_COMPCODE,P_DIVCODE,P_YEARCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'WPS', P_TABLENAME, 'PF', NULL,NULL, NULL);
    
    lv_remarks := 'GENERAL LOAN BREAKUP UPDATE';
    PRC_LOANBREAKUP_INSERT_WAGES(P_COMPCODE,P_DIVCODE,P_YEARCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'WPS', P_TABLENAME, 'GENERAL', NULL,NULL, NULL);
    
    lv_remarks := 'PF LOAN BALANCE UPDATE'; 
    PRC_LOANBALANCE_UPDT_WAGES(P_COMPCODE,P_DIVCODE,P_YEARCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'WPS',P_TABLENAME,'PF',NULL,NULL,NULL);
    
    lv_remarks := 'GENERAL LOAN BALANCE UPDATE'; 
    PRC_LOANBALANCE_UPDT_WAGES(P_COMPCODE,P_DIVCODE,P_YEARCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'WPS',P_TABLENAME,'GENERAL',NULL,NULL,NULL);        
    
    lv_remarks := 'PHASE - '||P_PHASE||' SUCESSFULLY COMPLETE';
    --insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_DEDUCTION','','',lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
    
    
 -- LIC DATA REALIZED/ UNREALIZED 
    lv_remarks := 'CASH OT UNREALIZED DATA INSERT';
    PRC_REALIZEDDATA_INSERT (P_COMPCODE,P_DIVCODE,P_YEARCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'WPS', P_TABLENAME,'CASHOT_AMT','CASH_REALIZE','OTHR_DEDN', 'ALL', NULL);

    
    
commit;    
exception
    when others then
    lv_sqlerrm := sqlerrm ;
    insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_DEDUCTION',lv_sqlerrm,lv_Sql,lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks||' '||lv_SrlNo);
    commit;
    --dbms_output.put_line('PROC - PROC_WPSWAGESPROCESS_UPDATE : ERROR !! WHILE WAGES PROCESS '||P_FNSTDT||' AND PHASE -> '||ltrim(trim(P_PHASE))||' : '||sqlerrm);
end;
/
