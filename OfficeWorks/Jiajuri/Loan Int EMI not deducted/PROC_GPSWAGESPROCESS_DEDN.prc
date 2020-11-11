CREATE OR REPLACE PROCEDURE JIAJURI.PROC_GPSWAGESPROCESS_DEDN ( P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2, 
                                                  P_PROCESSTYPE Varchar2 default null,
                                                  P_YEARCODE Varchar2,
                                                  P_FNSTDT Varchar2, 
                                                  P_FNENDT Varchar2,
                                                  P_EFFECT_FNEDT    Varchar2,
                                                  P_PHASE  number, 
                                                  P_PHASE_TABLENAME Varchar2,
                                                  P_TABLENAME Varchar2,
                                                  P_USERNAME    VARCHAR2 DEFAULT 'SWT',
                                                  P_CATEGORYTYPE VARCHAR2 DEFAULT 'WORKER',
                                                  P_CATEGORYCODE    Varchar2 default NULL,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL)
as 
lv_fn_stdt DATE := TO_DATE(P_FNSTDT,'DD/MM/YYYY');
lv_fn_endt DATE := TO_DATE(P_FNENDT,'DD/MM/YYYY');
lv_TableName        varchar2(50);
lv_Remarks          varchar2(1000) := '';
lv_Sql              varchar2(4000);
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';
lv_ProcName         varchar2(30) := 'PROC_GPSWAGESPROCESS_DEDN';   
lv_ProcessType      varchar2(20) := '';
lv_Component        varchar2(4000) := ''; 
lv_SqlComponent     varchar2(2000) := ''; 
lv_MinimumPayableAmt    number := 0;
lv_RoundOffRs           number := 0;
lv_RoundOffType     varchar2(10):='S';
lv_WagesAsOn    number(11,2) := 0;
lv_TempVal      number(11,2) := 0;
lv_TempDednAmt  number(11,2) := 0;
lv_ComponentAmt number(11,2) := 0;
lv_WagesAsOnTmp NUMBER(11,2) := 0;
lv_intCnt       number(5) := 0;
lv_GrossWages   number(11,2) := 0;
lv_PtaxGross   number(11,2) := 0;
lv_TotalEarn    number(11,2) := 0;
lv_TotalDedn    number(11,2) := 0;
lv_CoinBf       number(11,2) := 0;
lv_CoinCf       number(11,2) := 0;
lv_SrlNo        NUMBER(5) := 0;
lv_strWorkerSerial  varchar2(10) :='';
lv_PFLN_CAP_STOP varchar2(1)    :='N';
lv_PFLN_INT_STOP varchar2(1)    :='N';
lv_EMI_DEDN_TYPE VARCHAR2(100) := '';
lv_CNT          NUMBER(5) :=0;
lv_GrossWagesPHASE  number(5,2) :=4;
lv_RevnueStampLimit number(7,2) :=5000;
begin
    --RETURN;

    lv_parvalues := 'COHMP ='||P_COMPCODE||', DIV = '||P_DIVCODE||',FNS = '||P_FNSTDT||' FNE = '||P_FNENDT||', PHASE = '||P_PHASE;
    lv_sql := 'drop table '||P_PHASE_TABLENAME;
   
    --lv_prev_fn_stdt := to_date('01'||substr(P_FNSTDT,4,7),'dd/mm/yyyy');

    BEGIN 
        execute immediate lv_sql;
    EXCEPTION WHEN OTHERS THEN NULL;
    END;

    BEGIN
        SELECT PARAMETER_VALUE INTO lv_RoundOffRs FROM SYS_PARAMETER WHERE PROJECTNAME = 'GPS' AND  PARAMETER_NAME = 'SALARYROUNDOFF'
        AND DIVISIONCODE LIKE '%'||P_DIVCODE||'%';
    EXCEPTION
        WHEN OTHERS THEN lv_RoundOffRs :=1;   
    END;

    BEGIN
        SELECT PARAMETER_VALUE INTO lv_RevnueStampLimit FROM SYS_PARAMETER WHERE PROJECTNAME = 'GPS' AND  PARAMETER_NAME = 'REVENUE STAMP LIMIT'
        AND DIVISIONCODE LIKE '%'||P_DIVCODE||'%';
    EXCEPTION
        WHEN OTHERS THEN lv_RevnueStampLimit := 5000;   
    END;
    BEGIN
        SELECT PARAMETER_VALUE INTO lv_RoundOffRs FROM SYS_PARAMETER WHERE PROJECTNAME = 'GPS' AND  PARAMETER_NAME = 'SALARYROUNDOFF'
        AND DIVISIONCODE LIKE '%'||P_DIVCODE||'%';
    EXCEPTION
        WHEN OTHERS THEN lv_RoundOffRs :=1;   
    END;        
--    DBMS_OUTPUT.PUT_LINE('ROUND OFF '||lv_RoundOffRs||' , '||lv_RoundOffType);
    --- BEFORE DEDUCTION PAHSE START MERGE WORKER WISER MULIPLE DATA IN A SINGLE DATA
    --- DISABLE DUE TO IT'S CALL FROM TABLE -------
    --PROC_GPSVIEWCREATION ( P_COMPCODE,P_DIVCODE,'ALL',P_PHASE,P_FNSTDT,P_FNENDT,P_TABLENAME,P_PROCESSTYPE); --ITS CALL FROM WAGESPROCESS TYPE TABLE
    IF (P_PROCESSTYPE = 'WAGES' OR P_PROCESSTYPE = 'WAGES PROCESS') THEN
    
        SELECT PHASE into lv_GrossWagesPHASE 
        FROM GPSCOMPONENTMAST 
        WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
          AND COMPONENTCODE ='GROSSWAGES'; 
          
        SELECT PHASE into lv_PtaxGross 
        FROM GPSCOMPONENTMAST 
        WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
          AND COMPONENTCODE ='PTAX_GROSS'; 
          
          
              
        --PROC_GPSWAGESDETAILS_MERGE(P_COMPCODE,P_DIVCODE, 'DAILY', P_YEARCODE, P_FNSTDT,P_FNENDT,P_FNENDT, P_PHASE,'GPSDAILYPAYSHEETDETAILS', 'GPSPAYSHEETDETAILS_SWT',P_USERNAME,'N' ,P_CATEGORYTYPE, P_CATEGORYCODE, P_WORKERSERIAL);
        --PROC_GPSATTNALLOWANCE(P_COMPCODE,P_DIVCODE,P_PROCESSTYPE,P_YEARCODE, P_FNSTDT,P_FNENDT,P_FNENDT,  5,'GPSPAYSHEETDETAILS_SWT', 'GPSPAYSHEETDETAILS_SWT','SWT', NULL, NULL,NULL);
        --PROC_GPSWAGESPROCESS_UPDATE(P_COMPCODE,P_DIVCODE,'WAGES',P_YEARCODE, P_FNSTDT,P_FNENDT,P_FNENDT,  lv_GrossWagesPHASE,'SWT_GPS_PHASE_4', 'GPSPAYSHEETDETAILS_SWT','SWT', NULL, NULL,NULL);
        
        --RETURN;
    END IF;
    
    --- SET NETSALARY = GROSS WAGES DUE TO WHEN NO DEDUCTION COMPONENT FOUND IN A CATEGORY THEN NET SALARY CALCULATE FOR THIS CATEGORY'S WORKER ----
    UPDATE GPSPAYSHEETDETAILS_SWT SET NETSALARY = GROSSWAGES, GROSSDEDN = 0;
    
    PROC_GPSVIEWCREATION ( P_COMPCODE,P_DIVCODE,'ALL',P_PHASE,P_FNSTDT,P_FNENDT,P_TABLENAME,P_PROCESSTYPE);
    --RETURN;
    --- PREPARE THE LOAN OUTSTANDNG FOR DEDUCTION -----------
    --DBMS_OUTPUT.PUT_LINE ('LOAN BALANCE QUERY RUN 1');    
    PROC_LOANBLNC(P_COMPCODE,P_DIVCODE,P_FNSTDT,P_FNENDT,NULL,NULL,'GPS','YES');
    --DBMS_OUTPUT.PUT_LINE ('LOAN BALANCE QUERY RUN 2');
    PROC_PFLOANBLNC(P_COMPCODE,P_DIVCODE,P_FNSTDT,P_FNENDT,NULL,NULL,'GPS','YES');
    
    
    ----- PF LOAN EMI UPDATE BASED ON HAZIRA SLAB PARAMETER TABLE --------------------
    PRC_PFLN_EMI_UPDT_ONATTN_HRS(P_COMPCODE,P_DIVCODE,P_FNSTDT, P_FNENDT,'GPSPAYSHEETDETAILS_SWT','GBL_PFLOANBLNC','','','');
    --DBMS_OUTPUT.PUT_LINE ('LOAN BALANCE QUERY CLOSE 3');
    PROC_GPSRATION_DEDUCTIONBAL(P_COMPCODE,P_DIVCODE,P_FNSTDT,P_FNENDT,NULL, NULL, NULL);
    ------ COIN BF DATA PREPARATION TABLE => GPS_PREV_FN_COIN ----------
    PROC_GPS_PREV_FNCOIN (P_COMPCODE, P_DIVCODE, P_FNSTDT, P_USERNAME, 'NONE');
    ------- LIC DEDUCTION DATA PREPARATION ---------
    PRC_GPSLICDEDUCTION (P_COMPCODE,P_DIVCODE,P_YEARCODE, P_FNENDT, 99, P_PHASE_TABLENAME, P_TABLENAME,P_USERNAME, P_CATEGORYTYPE);
    
    --------- CASH ADVANCE DATA PREPARATION -------------
    PRC_GPSOTHR_DEDN_PROCESS (P_COMPCODE,P_DIVCODE,P_YEARCODE, P_FNSTDT, P_FNENDT, 99, 'GPSCASHADVANCE', 'WAGE ADVANCE', P_USERNAME, P_CATEGORYTYPE);
     
    --DBMS_OUTPUT.PUT_LINE ('RATION DEDUCTION QUERY CLOS 3');
--    BEGIN 
--        execute immediate lv_SqlStr;
--    EXCEPTION WHEN OTHERS THEN NULL;
--    END;
    ---- ROUND OFF PARAMETER CATPURING FROM SYS_PARAMETER TABLE ----- 
    
    BEGIN 
        SELECT NVL(PARAMETER_VALUE,1) INTO lv_RoundOffRs   
        FROM SYS_PARAMETER WHERE PROJECTNAME = 'GPS' AND PARAMETER_NAME = 'SALARYROUNDOFF' AND DIVISIONCODE LIKE '%'||P_DIVCODE||'%';
    EXCEPTION
        WHEN OTHERS THEN lv_RoundOffRs :=1;        
    END;
    
    BEGIN
        SELECT PARAMETER_VALUE INTO lv_RoundOffType
        FROM SYS_PARAMETER 
        WHERE PROJECTNAME = 'GPS' AND PARAMETER_NAME = 'SALARYROUNDOFFTYPE' AND DIVISIONCODE LIKE '%'||P_DIVCODE||'%';
    EXCEPTION
        WHEN OTHERS THEN lv_RoundOffType := 'L';
    END;


    FOR C1 IN (
                SELECT COMPONENTCODE, COMPONENTTYPE, COMPONENTGROUP, PHASE, CALCULATIONINDEX, AMOUNTORFORMULA, FORMULA, INCLUDEPAYROLL, INCLUDEARREAR,
                NVL(USERENTRYAPPLICABLE,'N') USERENTRYAPPLICABLE,  NVL(ROLLOVERAPPLICABLE,'N') ROLLOVERAPPLICABLE, 
                NVL(ROUNDOFFTYPE,'N') ROUNDOFFTYPE, NVL(ROUNDOFFAMOUNT,0) ROUNDOFFAMOUNT,
                NVL(APPLICABLEBROKENPERIOD,'N') APPLICABLEBROKENPERIOD
                FROM GPSCOMPONENTMAST
                WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                AND PHASE = P_PHASE
                AND NVL(INCLUDEPAYROLL,'N') = 'Y'
              )
    LOOP
        
        if c1.AMOUNTORFORMULA <> 'FORMULA' THEN
            if c1.USERENTRYAPPLICABLE = 'Y' then
                if c1.ROLLOVERAPPLICABLE = 'Y' then
                    lv_SqlComponent := 'NVL(GPSMAST.'||C1.COMPONENTCODE||',0)';
                else
                    lv_SqlComponent := 'NVL(GPSATTN.'||C1.COMPONENTCODE||',0)';
                end if;
            else
                lv_SqlComponent := NVL(c1.FORMULA,0);
            end if;
        ELSE
            lv_SqlComponent := NVL(c1.FORMULA,0);
        END IF;
--        if c1.DEPENDENCYTYPE = 'A' then
--            lv_SqlComponent := 'round(('||lv_SqlComponent||')*PISCOMP.ATTN_SALD/PISCOMP.ATTN_CALCF,2)';
--        end if;
        ---- consider round off type criteria --------
        IF c1.COMPONENTGROUP NOT IN ('LOAN' , 'PF LOAN','RATION') THEN
            if c1.ROUNDOFFTYPE = 'H' or  c1.ROUNDOFFTYPE = 'L' THEN
                if nvl(c1.ROUNDOFFAMOUNT,0) = 0 then
                    lv_SqlComponent := 'FN_ROUNDOFFRS('||lv_SqlComponent||',1,'''||c1.ROUNDOFFTYPE||''')';
                else
                    lv_SqlComponent := 'FN_ROUNDOFFRS('||lv_SqlComponent||','||c1.ROUNDOFFAMOUNT||','''||c1.ROUNDOFFTYPE||''')';
                end if;
                
            --elsif c1.ROUNDOFFTYPE = 'S'
            --    lv_SqlComponent := 'FN_ROUNDOFFRS('||lv_SqlComponent||',1,'''||c1.ROUNDOFFTYPE||''')';
            else
            --    lv_SqlComponent := 0
                lv_SqlComponent := 'FN_ROUNDOFFRS('||lv_SqlComponent||',1,'''||c1.ROUNDOFFTYPE||''')'; 
            end if;
--        else
--            lv_SqlComponent := ' 0 ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE ('YYYYY - '||lv_SqlComponent);
        lv_Component := lv_Component ||', SUM('||lv_SqlComponent||') AS '|| c1.COMPONENTCODE;
    END LOOP;
--    DBMS_OUTPUT.PUT_LINE ('3_1');

    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE GPSTEMPMAST CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'CREATE TABLE GPSTEMPMAST AS SELECT * FROM GPSMAST_VW';
      EXCEPTION WHEN OTHERS THEN 
        EXECUTE IMMEDIATE 'CREATE TABLE GPSTEMPMAST AS SELECT * FROM GPSMAST_VW';
    END;
    --DBMS_OUTPUT.PUT_LINE ('2_0');
    ----- CREATE TABLE WMPTEMPATTN FROM THE VIEW ATTN
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE GPSTEMPATTN CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'CREATE TABLE GPSTEMPATTN AS SELECT * FROM GPSATTN_VW';
      EXCEPTION WHEN OTHERS THEN 
        EXECUTE IMMEDIATE 'CREATE TABLE GPSTEMPATTN AS SELECT * FROM GPSATTN_VW';
    END; 
    --DBMS_OUTPUT.PUT_LINE ('2_1');
    ----- CREATE TABLE WMPTEMPCATE FROM THE VIEW VW_GPSCATEGORYMAST
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE GPSTEMPCAT CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'CREATE TABLE GPSTEMPCAT AS SELECT * FROM VW_GPSCATEGORYMAST';
      EXCEPTION WHEN OTHERS THEN 
        EXECUTE IMMEDIATE 'CREATE TABLE GPSTEMPCAT AS SELECT * FROM VW_GPSCATEGORYMAST';
    END;

    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE GPSTEMPCOMP CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'CREATE TABLE GPSTEMPCOMP AS SELECT * FROM GPSCOMPONENT_VW';
      EXCEPTION WHEN OTHERS THEN 
        EXECUTE IMMEDIATE 'CREATE TABLE GPSTEMPCOMP AS SELECT * FROM GPSCOMPONENT_VW';
    END;
        
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE '||P_PHASE_TABLENAME||' CASCADE CONSTRAINTS';
      EXCEPTION WHEN OTHERS THEN NULL;
    END;    
    --DBMS_OUTPUT.PUT_LINE ('2_1');    
        
    lv_Component :=  Replace(lv_Component, 'GPSATTN', 'GPSTEMPATTN');
    lv_Component := Replace(lv_Component, 'GPSMAST', 'GPSTEMPMAST');
    lv_Component := Replace(lv_Component, 'GPSCOMP', 'GPSTEMPCOMP');
    lv_Component := Replace(lv_Component, 'GPSOCP', 'GPSTEMPOCP');
    lv_Component := Replace(lv_Component, 'GPSCAT', 'GPSTEMPCAT');
        
    lv_Sql := ' CREATE TABLE '||P_PHASE_TABLENAME||' AS '||CHR(10)
            ||' SELECT GPSTEMPCOMP.WORKERSERIAL,  GPSTEMPMAST.CATEGORYCODE, '||CHR(10)  
            ||' SUM(NVL(GPSTEMPCOMP.GROSSWAGES,0)) AS GROSSWAGES '||CHR(10)  
            ||' '|| lv_Component ||chr(10) 
            ||' FROM GPSTEMPMAST, GPSTEMPATTN, GPSTEMPCOMP, GPSTEMPCAT '||chr(10)   
            ||' WHERE GPSTEMPCOMP.WORKERSERIAL = GPSTEMPMAST.WORKERSERIAL '||chr(10) 
            ||'   AND GPSTEMPCOMP.WORKERSERIAL = GPSTEMPATTN.WORKERSERIAL  '||chr(10)
            ||'   AND GPSTEMPMAST.CATEGORYCODE = GPSTEMPCAT.CATEGORYCODE '||CHR(10)
            ||'   AND GPSTEMPMAST.COMPANYCODE = GPSTEMPATTN.COMPANYCODE AND GPSTEMPMAST.DIVISIONCODE = GPSTEMPATTN.DIVISIONCODE '||CHR(10)
            ||'   AND GPSTEMPMAST.COMPANYCODE = GPSTEMPCAT.COMPANYCODE AND GPSTEMPMAST.DIVISIONCODE = GPSTEMPCAT.DIVISIONCODE '||CHR(10)
            ||'   AND GPSTEMPMAST.COMPANYCODE = '''||P_COMPCODE||''' AND GPSTEMPMAST.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10);
    if P_WORKERSERIAL is not null then
        lv_Sql := lv_Sql ||' AND GPSTEMPCOMP.WORKERSERIAL IN ('||P_WORKERSERIAL||')' ||CHR(10); 
    end if; 
    lv_Sql := lv_Sql ||' GROUP BY GPSTEMPCOMP.WORKERSERIAL, GPSTEMPMAST.CATEGORYCODE '||chr(10);        
    insert into GPS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, 'PHASE TABLE CREATION '||lv_SrlNo);
    lv_SrlNo:=lv_SrlNo+1;
    --DBMS_OUTPUT.PUT_LINE (lv_Sql);
    EXECUTE IMMEDIATE lv_Sql;  
    lv_Sql := '';
    --RETURN;
    COMMIT;
    ---- BELOW PROCERURE CALL FOR DATA CONVERT FROM COLUMN TO ROW --- CREATE TABLE NAME  - GTT_SWT_PHASE_DEDN
    lv_Sql := 'begin  PROC_GPS_PHASE_DEDN_ROWISE('''||P_COMPCODE||''','''||P_DIVCODE||''','''||P_FNSTDT||''','''||P_FNENDT||''','''||P_PHASE_TABLENAME||'''); end;';
--    DBMS_OUTPUT.PUT_LINE ('PROCEDURE EXECURE ; '||lv_Sql);
    EXECUTE IMMEDIATE LV_SQL;
--    DBMS_OUTPUT.PUT_LINE ('DONE PAHSE WISW ROW DEDN');
    lv_strWorkerSerial := 'SOFTWEB';    --- INITAILIZE THE WORKERSERIAL VARIABLE B4 LOOP RUN
    ----- START WAGES DEDUCTION INDIVUAL WORKER WISE ---------------            
    For cWages in ( SELECT B.COMPANYCODE, B.DIVISIONCODE, A.WORKERSERIAL, A.CATEGORYCODE, A.GROSSWAGES, A.COMPONENTCODE, A.COMPONENTAMOUNT, B.CALCULATIONINDEX, 
                    NVL(C.APPLICABLE,'NO') APPLICABLE, NVL(B.COMPONENTGROUP,'XX') COMPONENTGROUP
                    ,NVL(D.ISBLOCKED,'N') ISBLOCKED, NVL(D.APPLICABLE_PERCENT,0) APPLICABLE_PERCENT  
                    FROM GTT_SWT_PHASE_DEDN A, GPSCOMPONENTMAST B, 
                    (
                        SELECT X.CATEGORYCODE, X.COMPONENTCODE, NVL(X.APPLICABLE,'NO') APPLICABLE
                        FROM GPSCATEGORYVSCOMPONENT X, 
                        (
                            SELECT CATEGORYCODE, MAX(EFFECTIVEDATE) EFFECTIVEDATE 
                            FROM GPSCATEGORYVSCOMPONENT 
                            WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                              AND EFFECTIVEDATE <= TO_DATE(P_FNSTDT,'DD/MM/YYYY')
                            GROUP BY CATEGORYCODE  
                        ) Y
                        WHERE X.COMPANYCODE = P_COMPCODE AND X.DIVISIONCODE = P_DIVCODE   
                          AND X.CATEGORYCODE = Y.CATEGORYCODE 
                          AND X.EFFECTIVEDATE = Y.EFFECTIVEDATE
                          AND X.APPLICABLE = 'YES'                     

                    ) C--, SWT_PHASE_DEDN D
                    ---- START BELOW BLOCK BY AMALESH ON 31/10/2018 FOR PERIOD WISE BLOCK COMPONENT CONSIDER IN THE CURSOR    
                    ,(
                         SELECT CATEGORYCODE, CATEGORYTYPE, COMPONENTCODE, NVL(ISAPPLICABLE,'Y') ISBLOCKED, NVL(APPLICABLE_PERCENT,0) APPLICABLE_PERCENT 
                         FROM GPSWAGESCOMPONENTBLOCK
                         WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                           --AND MODULE = 'GPS' 
                           AND PERIODFROM >= TO_DATE(P_FNSTDT,'DD/MM/YYYY')
                           AND PERIODTO <= TO_DATE(P_FNENDT,'DD/MM/YYYY')
                           AND CATEGORYTYPE = P_CATEGORYTYPE                    
                    ) D
                    ---- END BELOW BLOCK BY AMALESH ON 31/10/2018 FOR PERIOD WISE BLOCK COMPONENT CONSIDER IN THE CURSOR
                    WHERE B.COMPANYCODE = P_COMPCODE AND B.DIVISIONCODE = P_DIVCODE 
                      AND B.COMPONENTCODE = A.COMPONENTCODE 
                      AND B.COMPONENTCODE = C.COMPONENTCODE
                      AND B.PHASE = P_PHASE
                      AND A.CATEGORYCODE = C.CATEGORYCODE
                      AND NVL(C.APPLICABLE,'NO') <> 'NO'
                      AND NVL(A.GROSSWAGES,0) > 0
                      AND A.CATEGORYCODE = D.CATEGORYCODE (+) AND A.COMPONENTCODE = D.COMPONENTCODE (+)
                    ORDER BY A.WORKERSERIAL, B.CALCULATIONINDEX )
    LOOP
        
        lv_intCnt := lv_intCnt+1;
--        DBMS_OUTPUT.PUT_LINE ('WORKESERIAL '||cWages.WORKERSERIAL||' LAST WORKERSERIAL '||lv_strWorkerSerial);
        --INSERT INTO GPS_ERROR_LOG(PROC_NAME, ORA_ERROR_MESSG, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_DEDCUTION','','',lv_parvalues, lv_fn_stdt, lv_fn_endt, 'INSIDE CURSOR LOOP '|| lv_intCnt);
        if lv_strWorkerSerial <> cWages.WORKERSERIAL then
            if lv_intCnt <> 1 then
                begin
                    select nvl(COINCF,0) into lv_CoinBf FROM GPS_PREV_FN_COIN where workerserial = lv_strWorkerSerial;
                exception
                    when others then lv_CoinBf :=0;
                end;
                
                lv_Sql := 'FN_ROUNDOFFRS('||lv_GrossWages||' + nvl('||lv_CoinBf||',0) - '||lv_TotalDedn||','||lv_RoundOffRs||','||lv_RoundoffType||');';
        --        DBMS_OUTPUT.PUT_LINE (lv_sql);
                lv_ComponentAmt := FN_ROUNDOFFRS(lv_GrossWages + nvl(lv_CoinBf,0) - lv_TotalDedn,lv_RoundOffRs,lv_RoundoffType);
                lv_TempDednAmt := lv_GrossWages + nvl(lv_CoinBf,0) - lv_TotalDedn - lv_ComponentAmt;
                lv_CoinBf := NVL(lv_CoinBf,0);  -- new add on 23/01/2019 
                --lv_Sql := 'UPDATE WPSWAGESDETAILS_MV_SWT set NETSALARY = '||lv_ComponentAmt||', COINBF = '||lv_CoinBf||', COINCF = '||lv_TempDednAmt||' where workerserial = '''||lv_strWorkerSerial||''' ';
                --lv_Sql := 'UPDATE '||P_TABLENAME||' set NETSALARY = '||lv_ComponentAmt||' where workerserial = '''||lv_strWorkerSerial||''' ';
                lv_Sql := 'UPDATE '||P_TABLENAME||' set NETSALARY = '||lv_ComponentAmt||',COINCF = '||lv_TempDednAmt||', COINBF='||lv_CoinBf||' where workerserial = '''||lv_strWorkerSerial||''' ';
                
          --      insert into GPS_ERROR_LOG(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,lv_remarks||' '||lv_SrlNo||' WAGES ON-'||lv_WagesAsOn );
                COMMIT;                
                execute immediate lv_Sql;
                --insert into GPS_ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,lv_remarks||' WOKERSERIAL '||lv_strWorkerSerial||' '||lv_SrlNo || ' WAGES ON-BFCF '|| lv_intCnt ||'  '||lv_CoinBf );
                lv_SrlNo:=lv_SrlNo+1;
                commit;
            end if;
            lv_strWorkerSerial := cWages.WORKERSERIAL;
            lv_WagesAsOn := cWages.GROSSWAGES - lv_MinimumPayableAmt;
            lv_GrossWages := cWages.GROSSWAGES;
            lv_TotalDedn :=0;
              
        end if; 
        lv_TempDednAmt := 0;
        lv_ComponentAmt := cWages.COMPONENTAMOUNT;
--        DBMS_OUTPUT.PUT_LINE ('WORKERSERIAL - '||cWages.WORKERSERIAL||', COMPONENT - '||cWages.COMPONENTCODE||', COMPONENTGROUP - '||cWages.COMPONENTGROUP||', AMOUNTS - '||lv_ComponentAmt||',GROSS WAGES - '||lv_GrossWages);
        CASE cWages.COMPONENTGROUP
            WHEN 'PTAX' THEN
                lv_ComponentAmt := 0;
                ---- write the logic later -----        
                --if lv_ProcessType = 'MONTHLY' THEN
                if P_PROCESSTYPE = 'WAGES PROCESS' THEN
                    SELECT NVL(PTAXAMOUNT,0) into lv_TempVal FROM PTAXSLAB
                    WHERE 1=1
                      AND STATENAME = 'ASSAM'
                      AND WITHEFFECTFROM = ( SELECT MAX(WITHEFFECTFROM) FROM PTAXSLAB WHERE STATENAME = 'ASSAM' AND WITHEFFECTFROM <= lv_fn_stdt)
                      AND SLABAMOUNTFROM <= lv_GrossWages 
                      AND SLABAMOUNTTO >= lv_GrossWages;
                      lv_ComponentAmt := nvl(lv_TempVal,0);              
                end if;
            
             WHEN 'PF LOAN' THEN
                lv_ComponentAmt := 0;
                
            --- ONLY SALARY AND FINAL SETTLEMENT TIME LOAN VALUE CALCULATE IN THE SYSTEM ---
                 if P_PROCESSTYPE = 'WAGES PROCESS' OR P_PROCESSTYPE = 'FINAL SETTLEMENT' then
                  
                    --lv_ComponentAmt := cWages.COMPONENTAMOUNT;
                    lv_ComponentAmt:=0;
                    lv_PFLN_CAP_STOP :='N';
                    lv_PFLN_INT_STOP :='N';
                    BEGIN
                        if substr(cWages.COMPONENTCODE,1,5) = 'LOAN_' THEN 
                            SELECT CASE WHEN PFLOAN_BAL > CAP_EMI THEN CAP_EMI ELSE PFLOAN_BAL END, CAP_EMI_DEDUCT_TYPE, NVL(CAP_STOP,'N') 
                            INTO lv_ComponentAmt, lv_EMI_DEDN_TYPE, lv_PFLN_CAP_STOP   
                            FROM GBL_PFLOANBLNC 
                            WHERE WORKERSERIAL = cWages.WorkerSerial
                              AND LOANCODE = substr(cWages.COMPONENTCODE,6)
                              AND NVL(CAP_STOP,'N') = 'N'
                              AND PFLOAN_BAL > 0;
                            --  DBMS_OUTPUT.PUT_LINE('WORKERSERIAL '||cWages.WORKERSERIAL||', COMPONENT '||substr(cWages.COMPONENTCODE,1,5)||' lv_ComponentAmt ' || lv_ComponentAmt);
                        elsif substr(cWages.COMPONENTCODE,1,5) = 'LINT_' THEN 
                            
                            SELECT CASE WHEN PFLOAN_INT_BAL > INT_EMI THEN INT_EMI ELSE PFLOAN_INT_BAL END , INT_EMI_DEDUCT_TYPE, NVL(INT_STOP,'N') 
                            INTO lv_ComponentAmt, lv_EMI_DEDN_TYPE, lv_PFLN_INT_STOP  
                            FROM GBL_PFLOANBLNC 
                            WHERE WORKERSERIAL = cWages.WorkerSerial
                              AND LOANCODE = substr(cWages.COMPONENTCODE,6)
                              AND NVL(INT_STOP,'N') = 'N'
                              AND PFLOAN_INT_BAL > 0; 
                        else
                            lv_ComponentAmt := 0;
                        end if;
                       if lv_WagesAsOn <  NVL(lv_ComponentAmt,0) then             
                           if lv_EMI_DEDN_TYPE = 'FULL' then
                               lv_ComponentAmt := 0;
                           else
                               lv_ComponentAmt := floor(lv_WagesAsOn);
                           end if;              
                        end if;                        
                    EXCEPTION WHEN NO_DATA_FOUND THEN lv_ComponentAmt := 0;
                              WHEN OTHERS THEN lv_ComponentAmt := 0;      
                    END;        
                 else
                        lv_ComponentAmt := 0;
                 end if;
                 
--                 DBMS_OUTPUT.PUT_LINE ('P_PROCESSTYPE - '||P_PROCESSTYPE||', COMPONENT - '||cWages.COMPONENTCODE||', COMPONENTGROUP - '||cWages.COMPONENTGROUP||', AMOUNTS - '||lv_ComponentAmt||',GROSS WAGES - '||lv_GrossWages);
       
            WHEN 'LOAN' THEN
                lv_ComponentAmt:=0;
                --- ONLY SALARY AND FINAL SETTLEMENT TIME LOAN VALUE CALCULATE IN THE SYSTEM ---
                --if P_TRANTYPE = 'SALARY' OR P_TRANTYPE ='FINAL SETTLEMENT' then
                    BEGIN
                        if substr(cWages.COMPONENTCODE,1,5) = 'LOAN_' THEN 
                            SELECT CASE WHEN LOAN_BAL > CAP_EMI THEN CAP_EMI ELSE LOAN_BAL END INTO lv_ComponentAmt  
                            FROM GBL_LOANBLNC 
                            WHERE WORKERSERIAL = cWages.WorkerSerial and MODULE = 'GPS'
                              AND LOANCODE = substr(cWages.COMPONENTCODE,6)
                              AND NVL(CAP_STOP,'N') = 'N'
                              AND LOAN_BAL > 0;
                        elsif substr(cWages.COMPONENTCODE,1,5) = 'LINT_' THEN 
                            SELECT CASE WHEN LOAN_INT_BAL > INT_EMI THEN INT_EMI ELSE LOAN_BAL END INTO lv_ComponentAmt  
                            FROM GBL_LOANBLNC 
                            WHERE WORKERSERIAL = cWages.WorkerSerial and MODULE = 'GPS'
                              AND LOANCODE = substr(cWages.COMPONENTCODE,6)
                              AND NVL(INT_STOP,'N') = 'N'
                              AND LOAN_INT_BAL > 0;
                        else
                            lv_ComponentAmt := 0;
                        end if;
                    EXCEPTION WHEN NO_DATA_FOUND THEN lv_ComponentAmt := 0;
                              WHEN OTHERS THEN lv_ComponentAmt := 0;      
                    END;
               -- end if; 
 
            WHEN 'RATION' THEN
                lv_ComponentAmt := 0;
                    BEGIN
                            SELECT NVL(TOTALAMOUNT,0) INTO lv_ComponentAmt 
                              FROM GBL_GPSRATIONBAL
                             WHERE WORKERSERIAL = cWages.WorkerSerial
                               AND  NVL(TOTALAMOUNT,0)>0;
                               
                    EXCEPTION WHEN NO_DATA_FOUND THEN lv_ComponentAmt := 0;
                              WHEN OTHERS THEN lv_ComponentAmt := 0;
                    END; 
               
            WHEN 'WAGE ADVANCE' THEN
                lv_ComponentAmt := 0;
                    BEGIN
                        SELECT NVL(AMOUNT,0) INTO lv_ComponentAmt 
                              FROM GBL_OTHR_DEDN_PROCESS
                             WHERE COMPANYCODE=cWages.COMPANYCODE AND DIVISIONCODE = cWages.DIVISIONCODE 
                               AND COMPONENTGROUP = cWages.COMPONENTGROUP -- 'WAGE ADVANCE'
                               AND WORKERSERIAL = cWages.WorkerSerial
                               
                               AND  NVL(AMOUNT,0) > 0;
                    EXCEPTION WHEN NO_DATA_FOUND THEN lv_ComponentAmt := 0;
                              WHEN OTHERS THEN lv_ComponentAmt := 0;
                        
                    END;
            WHEN 'REVENUE STAMP' THEN  
            ----  revenue stamp dedcution based maximum net salary set in the parameter table and revenue stamp value set formula (i.e. - Rs 1.00 )
                if lv_WagesAsOn >= lv_RevnueStampLimit then
                    lv_ComponentAmt := cWages.COMPONENTAMOUNT;
                else
                    lv_ComponentAmt := 0;    
                end if;
            WHEN 'LIC' THEN
           ---  DBMS_OUTPUT.PUT_LINE('TEST SUMANTA ');
                       
                lv_TempVal := 0;
                lv_ComponentAmt := 0;
                lv_WagesAsOnTmp := lv_WagesAsOn;
                SELECT COUNT(*) CNT INTO lv_CNT FROM GBL_LICPOLICYDUE WHERE WORKERSERIAL = cWages.WorkerSerial;
                IF lv_CNT > 0 THEN
                    for cLIC in (SELECT * FROM GBL_LICPOLICYDUE 
                                 WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE 
                                   AND WORKERSERIAL = cWages.WorkerSerial
                                 ORDER BY POLICYDATE )
                    LOOP
                       --- DBMS_OUTPUT.PUT_LINE('WAGES ON  '||lv_WagesAsOn || 'and RUNNING WAGES' ||( cLIC.MONTHLYPREMIUMAMOUNT));
                        IF lv_WagesAsOnTmp >  cLIC.MONTHLYPREMIUMAMOUNT then
                            --DBMS_OUTPUT.PUT_LINE('lic count  '||lv_CNT||', WORKERSERIAL '||cWages.WorkerSerial);
                            lv_ComponentAmt := lv_ComponentAmt + cLIC.MONTHLYPREMIUMAMOUNT;
                            lv_WagesAsOnTmp := lv_WagesAsOnTmp  - cLIC.MONTHLYPREMIUMAMOUNT;
                        END IF;
                    END LOOP;
                    
                END IF;

            
            WHEN 'ELECTRICITY' THEN
                lv_ComponentAmt := 0;
/*                    BEGIN
                            SELECT NVL(ELEC_EMI_AMT,0) INTO lv_ComponentAmt 
                              FROM GBL_ELECBLNC
                             WHERE WORKERSERIAL = cWages.WorkerSerial
                               AND  NVL(ELEC_EMI_AMT,0)>=1;
                               
                    EXCEPTION WHEN NO_DATA_FOUND THEN lv_ComponentAmt := 0;
                              WHEN OTHERS THEN lv_ComponentAmt := 0;
                    END; */
            else
              lv_ComponentAmt := cWages.COMPONENTAMOUNT;    
        end case;
            
        IF lv_ComponentAmt > 0 THEN ---- BLOCKED CONDITION APPLICABLE ON 30.10.2018 BY AMALESH
            IF cWages.ISBLOCKED = 'Y' THEN  
                lv_ComponentAmt := lv_ComponentAmt - ROUND(lv_ComponentAmt * cWages.APPLICABLE_PERCENT/100,2); 
            END IF;  
        END IF;        
        
        if lv_WagesAsOn >  lv_ComponentAmt then             -- cWages.COMPONENTAMOUNT
            lv_TempDednAmt := lv_ComponentAmt;              -- cWages.COMPONENTAMOUNT;
        else            
            lv_TempDednAmt := lv_WagesAsOn;  
        end if;
        
        if lv_TempDednAmt <> 0 then
            lv_TotalDedn := lv_TotalDedn + lv_TempDednAmt;
            lv_Sql := 'UPDATE '||P_TABLENAME||' set '||cWages.COMPONENTCODE||' = '||lv_TempDednAmt||', GROSSDEDN = '||lv_TotalDedn||' where workerserial = '''||cWages.WorkerSerial||''' ';
            insert into GPS_ERROR_LOG(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,lv_remarks||' '||lv_SrlNo||' WAGES ON-'||lv_WagesAsOn );
            COMMIT;
            execute immediate lv_Sql;
            --lv_Sql := 'TEST'; 
        end if;
        lv_WagesAsOn := lv_WagesAsOn - lv_TempDednAmt;
        insert into GPS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,lv_remarks||' '||lv_SrlNo||' WAGES ON-'||lv_WagesAsOn );
        lv_SrlNo := lv_SrlNo + 1;          
    END LOOP; 
    
    
--    start for last record update actual pay, coin bf, coin cf
    begin
        select COINCF into lv_CoinBf FROM GPS_PREV_FN_COIN where workerserial = lv_strWorkerSerial;
    exception
        when others then null;
    end;
    lv_ComponentAmt := FN_ROUNDOFFRS(lv_GrossWages + nvl(lv_CoinBf,0) - lv_TotalDedn,lv_RoundOffRs,lv_RoundoffType);
    lv_CoinCf := (lv_GrossWages + nvl(lv_CoinBf,0)  - lv_TotalDedn) - lv_ComponentAmt;  -- NEW ADD ON 23/01/2019
    lv_TempDednAmt := lv_GrossWages + nvl(lv_CoinBf,0) - lv_TotalDedn - lv_ComponentAmt;
    --lv_Sql := 'UPDATE WPSWAGESDETAILS_MV_SWT set NETSALARY = '||lv_ComponentAmt||', COINBF = '||lv_CoinBf||', COINCF = '||lv_TempDednAmt||' where workerserial = '''||lv_strWorkerSerial||''' ';
    lv_Sql := 'UPDATE '||P_TABLENAME||' set NETSALARY = '||lv_ComponentAmt||' where workerserial = '''||lv_strWorkerSerial||''' ';
    --insert into GPS_ERROR_LOG(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
    COMMIT;        
    execute immediate lv_Sql;
    --- BLEOW LINE DISABLE ON 20.09.2017
    --insert into GPS_ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,lv_remarks||' '||lv_SrlNo||' WAGES ON-BFCF'||lv_WagesAsOn||'  '||lv_CoinBf );
    lv_SrlNo := lv_SrlNo + 1;
    commit;
    
    
    --PRC_ELECTRICBREAKUP_INSERT(P_COMPCODE,P_DIVCODE,P_YEARCODE, TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'WPS', P_TABLENAME );
                                  
   
    PROC_LOANBLNC(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'','','GPS');
    PROC_PFLOANBLNC(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'','','GPS');
    
     lv_remarks := 'PF LOAN BALANCE INSERT';
    PRC_LOANBREAKUP_INSERT_WAGES(P_COMPCODE,P_DIVCODE,P_YEARCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'GPS', P_TABLENAME, 'PF', NULL,NULL, NULL);
    lv_remarks := 'GENERAL LOAN BALANCE UPDATE';
    PRC_LOANBREAKUP_INSERT_WAGES(P_COMPCODE,P_DIVCODE,P_YEARCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'GPS', P_TABLENAME, 'GENERAL', NULL,NULL, NULL);
    lv_remarks := 'PF LOAN BALANCE UPDATE'; 
    PRC_LOANBALANCE_UPDT_WAGES(P_COMPCODE,P_DIVCODE,P_YEARCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'GPS',P_TABLENAME,'PF',NULL,NULL,NULL);
    lv_remarks := 'GENERAL LOAN BALANCE UPDATE'; 
    PRC_LOANBALANCE_UPDT_WAGES(P_COMPCODE,P_DIVCODE,P_YEARCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'GPS',P_TABLENAME,'GENERAL',NULL,NULL,NULL);        
    lv_remarks := 'LIC BREAKUP DATA INSERT';
    PRC_GPSLICUPDATE(P_COMPCODE, P_DIVCODE,P_YEARCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'), TO_CHAR(lv_fn_endt,'DD/MM/YYYY'), 99,P_PHASE_TABLENAME, P_TABLENAME, P_USERNAME, P_CATEGORYTYPE); 
    
    lv_remarks := 'PHASE - '||P_PHASE||' SUCESSFULLY COMPLETE';
    insert into GPS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( P_COMPCODE, P_DIVCODE, lv_ProcName,'','',lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
    commit;
     
--    end for last record update actual pay, coin bf, coin cf        
    lv_remarks := 'PHASE - '||P_PHASE||' SUCESSFULLY COMPLETE';
    insert into GPS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( P_COMPCODE, P_DIVCODE, lv_ProcName,'','',lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
    
commit;    
EXCEPTION
   WHEN OTHERS THEN
     lv_sqlerrm := sqlerrm;          
     insert into GPS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values(P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
    COMMIT;            
end;
/