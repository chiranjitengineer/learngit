CREATE OR REPLACE PROCEDURE BIRLANEW.PRC_PISSALARYPROCESS_DEDN (P_COMPCODE Varchar2, 
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
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL)
as 
lv_fn_stdt DATE := TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,1,4),'DD/MM/YYYY');
lv_fn_endt DATE := LAST_DAY(TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,1,4),'DD/MM/YYYY'));
lv_TableName        varchar2(50);
lv_Remarks          varchar2(1000) := '';
lv_SqlStr           varchar2(10000) := '';
lv_Sql              varchar2(10000) := '';
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';   
lv_ProcName         varchar2(30)   := 'PRC_PISSALARYPROCESS_DEDN';
lv_Sql_TblCreate    varchar2(4000) := '';
lv_Component        varchar2(4000) := ''; 
lv_SqlComponent     varchar2(2000) := ''; 
lv_MinimumPayableAmt    number := 0;
lv_RoundOffRs           number := 0;
lv_RoundOffType     varchar2(10):='L';
lv_WagesAsOn    number(11,2) := 0;
lv_TempVal      number(11,2) :=0;
lv_TempDednAmt  number(11,2) := 0;
lv_ComponentAmt number(11,2) := 0;
lv_intCnt       number(5) :=0;
lv_GrossWages   number(11,2) := 0;
lv_TotalEarn    number(11,2) := 0;
lv_TotalDedn    number(11,2) := 0;
lv_CoinBf       number(11,2) := 0;
lv_CoinCf       number(11,2) := 0;
lv_CapEMI       number(11,2) := 0;
lv_IntEMI       number(11,2) := 0;
lv_strWorkerSerial  varchar2(10) :='';
lv_CNT          number(11,2) := 0;
lv_PFNO         varchar2(100):='';
lv_YearCode     varchar2(10):='';
lv_MinPay     varchar2(10):='';
lv_ChkAttnHrs number(15,2) :=0;

begin


    lv_parvalues := 'COMP='||P_COMPCODE||',DIV = '||P_DIVCODE||', YEARMONTH = '||P_YEARMONTH||', EFF.YEARMONTH'||P_EFFECTYEARMONTH||',PAHSE='||P_PHASE;
    --lv_SqlStr := 'drop table '||P_PHASE_TABLENAME;
    
    SELECT YEARCODE INTO lv_YearCode FROM FINANCIALYEAR WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE =P_DIVCODE
    AND STARTDATE <= lv_fn_stdt AND ENDDATE >= lv_fn_stdt;
    
    
    IF P_TRANTYPE = 'SALARY' THEN
        prc_PISCOMPONENTMERGE( P_COMPCODE, P_DIVCODE, P_YEARMONTH, P_PHASE, 'ADJUSTMENT', 'PISOTHERTRANSACTION', P_TABLENAME);
    END IF;
   
    
    PRC_PISVIEWCREATION ( P_COMPCODE,P_DIVCODE,'PISCOMP',P_PHASE,P_YEARMONTH,P_EFFECTYEARMONTH, P_TRANTYPE,P_TABLENAME);
    --- PREPARE THE LOAN OUTSTANDNG FOR DEDUCTION -----------
    DBMS_OUTPUT.PUT_LINE ('LOAN BALANCE QUERY RUN 1');
    IF P_TRANTYPE = 'SALARY' OR  P_TRANTYPE = 'FINAL SETTLEMENT' THEN --- FOR ARREAR TIME IT'S NOT REQUIRED     
    
        --ADDED LOAN INT CALCULATION OM 06/07/2020
        PRC_GEN_LOAN_INT_CALC(P_COMPCODE,P_DIVCODE,'SWT',NULL,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'PIS','YES','PISPAYTRANSACTION_SWT');


        PROC_LOANBLNC(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'','','PIS','YES');
        ----DBMS_OUTPUT.PUT_LINE ('LOAN BALANCE QUERY RUN 2');
        PROC_PFLOANBLNC(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'','','PIS','YES');
        ----DBMS_OUTPUT.PUT_LINE ('LOAN BALANCE QUERY CLOSE 3');
        PRC_PFLN_EMI_UPDT (P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),P_TABLENAME,'GBL_PFLOANBLNC','','','PIS');
        ----DBMS_OUTPUT.PUT_LINE ('PF LOAN EMI UPDT');
        --PROC_LICDEDUCTION(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'','','LICDETAILS','PIS','YES');
        
        ------ COINBF DATA PREPARATION -------------
        PRC_PIS_PREVMONTHCOINBF (P_COMPCODE, P_DIVCODE, P_YEARMONTH, P_CATEGORY,P_GRADE,P_WORKERSERIAL);
            
            
        ------ ELECTRIC METER READING -----------------------------------
    --    PROC_ELECBLNC (P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),NULL,'WPS');
        PROC_ELECBLNC_WITH_BILL_EMI(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),NULL,'PIS','YES');  
        
        
        --  SHOP RENT DATA PREPARATION PROCEDURE CALL
        PROC_UNREALIZED_COMP_BLNC(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'ALL', LV_YEARCODE ,'PIS','YES',NULL);    
                      

    END IF;    
--    BEGIN 
--        execute immediate lv_SqlStr;
--    EXCEPTION WHEN OTHERS THEN NULL;
--    END;
--    DBMS_OUTPUT.PUT_LINE('1_0');    

    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE '||P_PHASE_TABLENAME||' CASCADE CONSTRAINTS';
      EXCEPTION WHEN OTHERS THEN NULL;
    END;
    for c1 in ( 
                SELECT COMPONENTCODE, COMPONENTTYPE, PAYFORMULA, CALCULATIONINDEX, PHASE,
                NVL(DEPENDENCYTYPE,'A') DEPENDENCYTYPE, NVL(ROUNDOFFTYPE,'N') ROUNDOFFTYPE, NVL(ROUNDOFFRS,0) ROUNDOFFRS,
                INCLUDEPAYROLL, nvl(ROLLOVERAPPLICABLE,'N') ROLLOVERAPPLICABLE, NVL(USERENTRYAPPLICABLE,'N') USERENTRYAPPLICABLE, 
                NVL(ATTENDANCEENTRYAPPLICABLE,'N') ATTENDANCEENTRYAPPLICABLE, 
                NVL(LIMITAPPLICABLE,'N') LIMITAPPLICABLE, NVL(SLABAPPLICABLE,'N') SLABAPPLICABLE,
                NVL(MISCPAYMENT,'N') MISCPAYMENT, NVL(FINALSETTLEMENT,'N') FINALSETTLEMENT, NVL(COMPONENTGROUP,'N/A') COMPONENTGROUP 
                FROM PISCOMPONENTMASTER
                WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                AND PHASE = P_PHASE
                AND NVL(INCLUDEPAYROLL,'N') = 'Y'
                AND YEARMONTH = ( 
                                  SELECT MAX(YEARMONTH) YEARMONTH FROM PISCOMPONENTMASTER
                                  WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                                    and YEARMONTH <= P_YEARMONTH
                                )  
              )   
    loop
        if c1.USERENTRYAPPLICABLE = 'Y' then
            if c1.ROLLOVERAPPLICABLE = 'Y' then
                lv_SqlComponent := 'NVL(PISASSIGN.'||C1.COMPONENTCODE||',0)';
            else
                lv_SqlComponent := 'NVL(PISATTN.'||C1.COMPONENTCODE||',0)';
            end if;

            if length(rtrim(ltrim(c1.PAYFORMULA))) > 0 then
                lv_SqlComponent := lv_SqlComponent||'+'||c1.PAYFORMULA;
            end if;
                        
        else
            lv_SqlComponent := NVL(c1.PAYFORMULA,0);
        end if;
        if c1.DEPENDENCYTYPE = 'A' then
            lv_SqlComponent := 'round(('||lv_SqlComponent||')*PISCOMP.ATTN_SALD/PISCOMP.ATTN_CALCF,2)';
        end if;
        ---- consider round off type criteria --------
        --IF c1.COMPONENTGROUP <> 'LOAN' AND c1.COMPONENTGROUP <> 'PF LOAN' THEN
        IF c1.COMPONENTGROUP NOT IN ('LOAN' , 'PF LOAN') THEN
            if c1.ROUNDOFFTYPE = 'H' or  c1.ROUNDOFFTYPE = 'L' THEN
                if nvl(c1.ROUNDOFFRS,0) = 0 then
                    lv_SqlComponent := 'FN_ROUNDOFFRS('||lv_SqlComponent||',1,'''||c1.ROUNDOFFTYPE||''')';
                else
                    lv_SqlComponent := 'FN_ROUNDOFFRS('||lv_SqlComponent||','||c1.ROUNDOFFRS||','''||c1.ROUNDOFFTYPE||''')';
                end if;
            --elsif c1.ROUNDOFFTYPE = 'S'
            --    lv_SqlComponent := 'FN_ROUNDOFFRS('||lv_SqlComponent||',1,'''||c1.ROUNDOFFTYPE||''')';
            else
            --    lv_SqlComponent := 0
                lv_SqlComponent := 'FN_ROUNDOFFRS('||lv_SqlComponent||',1,'''||c1.ROUNDOFFTYPE||''')'; 
            end if;
        else
            lv_SqlComponent := ' 0 ';
        END IF;
        lv_Component := lv_Component ||', '||lv_SqlComponent||' AS '|| c1.COMPONENTCODE;
     end loop;     
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE PISTEMPCOMP CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'CREATE TABLE PISTEMPCOMP AS SELECT * FROM PISCOMP';
      EXCEPTION WHEN OTHERS THEN 
        EXECUTE IMMEDIATE 'CREATE TABLE PISTEMPCOMP AS SELECT * FROM PISCOMP';
    END;
    
--    BEGIN 
--        EXECUTE IMMEDIATE 'DROP TABLE '||P_PHASE_TABLENAME||' CASCADE CONSTRAINTS';
--      EXCEPTION WHEN OTHERS THEN NULL;
--    END;    
        
    lv_Component := Replace(lv_Component, 'PISATTN', 'PISTEMPATTN');
    lv_Component := Replace(lv_Component, 'PISMAST', 'PISTEMPMAST');
    lv_Component := Replace(lv_Component, 'PISCOMP', 'PISTEMPCOMP');
    lv_Component := Replace(lv_Component, 'PISASSIGN', 'PISTEMPASSIGN');
    lv_Component := Replace(lv_Component, 'PISPREV', 'PISTEMPPREV');
    
--    --DBMS_output.put_line ('component '||lv_Component);
    
    lv_Remarks := 'PHASE TABLE CREATION';
    lv_SqlStr := ' CREATE TABLE '||P_PHASE_TABLENAME||' AS '||CHR(10)
             ||' SELECT PISTEMPATTN.COMPANYCODE, PISTEMPATTN.DIVISIONCODE,PISTEMPATTN.YEARMONTH, PISTEMPATTN.UNITCODE, PISTEMPATTN.CATEGORYCODE, PISTEMPATTN.GRADECODE, PISTEMPATTN.WORKERSERIAL, PISTEMPATTN.TOKENNO, PISTEMPCOMP.ATTN_SALD, PISTEMPCOMP.ATTN_CALCF, '||chr(10)
             ||' PISTEMPCOMP.GROSSEARN, PISTEMPCOMP.TOTEARN '||CHR(10)
             ||' '||lv_Component||' '||chr(10) 
             ||' FROM PISTEMPMAST, PISTEMPATTN, PISTEMPASSIGN, PISTEMPCOMP, PISTEMPPREV '||CHR(10)
             ||' WHERE PISTEMPMAST.WORKERSERIAL = PISTEMPATTN.WORKERSERIAL '||CHR(10)
             ||'   AND PISTEMPMAST.WORKERSERIAL = PISTEMPASSIGN.WORKERSERIAL '||CHR(10)
             ||'   AND PISTEMPMAST.WORKERSERIAL = PISTEMPCOMP.WORKERSERIAL '||CHR(10)
             ||'   AND PISTEMPMAST.WORKERSERIAL = PISTEMPPREV.WORKERSERIAL (+) '||CHR(10);   
     if P_CATEGORY is not null then
        lv_SqlStr := lv_SqlStr||' AND PISTEMPATTN.CATEGORYCODE = '''||P_CATEGORY||''' '||CHR(10); 
     END IF;
     if P_GRADE is not null then
        lv_SqlStr := lv_SqlStr||' AND PISTEMPATTN.GRADECODE = '''||P_GRADE||''' '||CHR(10);
     END IF;        
     if P_DEPARTMENT is not null then
        lv_SqlStr := lv_SqlStr||' AND PISTEMPATTN.DEPARTMENTCODE = '''||P_DEPARTMENT||''' '||CHR(10); 
     END IF;     
     if P_WORKERSERIAL is not null then
        lv_SqlStr := lv_SqlStr||' AND PISTEMPATTN.WORKERSERIAL = '''||P_WORKERSERIAL||''' '||CHR(10); 
     END IF;    
    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE, ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',SYSDATE, lv_SqlStr,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
    EXECUTE IMMEDIATE lv_SqlStr;
    lv_SqlStr := '';
    COMMIT;
    
    ---RETURN; -- TEMPORARILY NOT EXCUTE THE BELOW PART
    lv_Remarks := 'DATA BREAK TO ROW WISE';
    --PRC_PIS_PHASE_DEDN_ROWISE (P_COMPCODE, P_DIVCODE, P_YEARMONTH,'PIS_SWT_PHASE_DEDN',P_PHASE);
    lv_SqlStr := 'begin  PRC_PIS_PHASE_DEDN_ROWISE('''||P_COMPCODE||''','''||P_DIVCODE||''', '''||P_YEARMONTH||''','''||P_PHASE_TABLENAME||''','||P_PHASE||' ); end;';
    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',SYSDATE,lv_SqlStr,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
    EXECUTE IMMEDIATE lv_SqlStr;    
    
    SELECT nvl(MINIMUMSALARYPAYABLE,0) MINIMUMSALARYPAYABLE, NVL(PAYMENTROUNDTYPE,'L') PAYMENTROUNDTYPE, nvl(ROUNDOFFRS,0) ROUNDOFFRS 
    INTO lv_MinimumPayableAmt, lv_RoundOffType, lv_RoundOffRs  
    FROM PISALLPARAMETER WHERE COMPANYCODE= P_COMPCODE AND DIVISIONCODE = P_DIVCODE;        
    
    ----DBMS_output.put_line ( 'minimum salary ='|| lv_MinimumPayableAmt||', Payment Type ='||lv_RoundOffType||', Round off Rs = '||lv_RoundOffRs);
    
--    START Previous MONTH coin c/f fetching worker wise --
/*    DELETE FROM PIS_PREV_FN_COIN;
    
    lv_Sql := ' INSERT INTO PIS_PREV_FN_COIN(WORKERSERIAL, TOKENNO, YEARMONTH, COINCF) '||CHR(10) 
            ||' SELECT A.WORKERSERIAL, A.TOKENNO, A.YEARMONTH, A.COINCF '||CHR(10)
            ||' FROM PISPAYTRANSACTION A, '||CHR(10)
            ||'  ( '||CHR(10)
            ||'    SELECT WORKERSERIAL, MAX(YEARMONTH) YEARMONTH  '||CHR(10)
            ||'    FROM PISPAYTRANSCTION  '||CHR(10)
            ||'    WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
            ||'      AND YEARMONTH < '''||P_YEARMONTH||'''  '||CHR(10)
            ||'    GROUP BY WORKERSERIAL  '||CHR(10)
            ||'  ) B  '||CHR(10)
            ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
            ||'   AND A.WORKERSERIAL = B.WORKERSERIAL  '||CHR(10)
            ||'   AND A.YEARMONTH = B.YEARMONTH  '||CHR(10);
     
    BEGIN
        DELETE FROM PIS_PREV_FN_COIN;
        EXECUTE IMMEDIATE lv_Sql;
    exception
        WHEN OTHERS THEN
            EXECUTE IMMEDIATE lv_Sql;        
    END;
*/         
--    END Previous MONTH coin c/f fetching worker wise --

           DBMS_OUTPUT.PUT_LINE ('RUN QRY 2 '||lv_ComponentAmt);   
    lv_strWorkerSerial := 'X';
    FOR cWages in (
                SELECT A.WORKERSERIAL, A.TOKENNO, A.UNITCODE, A.CATEGORYCODE, A.GRADECODE, A.GROSSEARN,A.TOTEARN,A.COMPONENTCODE, A.COMPONENTAMOUNT,
                NVL(B.COMPONENTGROUP,'OTHERS') COMPONENTGROUP, NVL(DEPENDENCYTYPE,'A') DEPENDENCYTYPE, NVL(ROUNDOFFTYPE,'N') ROUNDOFFTYPE, NVL(ROUNDOFFRS,1) ROUNDOFFRS,
                INCLUDEPAYROLL, nvl(ROLLOVERAPPLICABLE,'N') ROLLOVERAPPLICABLE, NVL(USERENTRYAPPLICABLE,'N') USERENTRYAPPLICABLE, 
                NVL(ATTENDANCEENTRYAPPLICABLE,'N') ATTENDANCEENTRYAPPLICABLE, 
                NVL(LIMITAPPLICABLE,'N') LIMITAPPLICABLE, NVL(SLABAPPLICABLE,'N') SLABAPPLICABLE,
                NVL(MISCPAYMENT,'N') MISCPAYMENT, NVL(FINALSETTLEMENT,'N') FINALSETTLEMENT, NVL(INCLUDEARREAR,'N') INCLUDEARREAR, PARTIALLYDEDUCT    
                FROM PIS_GTT_SWT_PHASE_DEDN A,
                ( 
                  SELECT * FROM PISCOMPONENTMASTER B
                  WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                    AND PHASE = P_PHASE
                    AND NVL(INCLUDEPAYROLL,'N') = 'Y'
                    AND YEARMONTH = ( 
                                      SELECT MAX(YEARMONTH) YEARMONTH FROM PISCOMPONENTMASTER
                                      WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                                        AND YEARMONTH <= P_YEARMONTH
                                    )
                ) B,
                ( 
                  SELECT X.UNITCODE, X.CATEGORYCODE, X.GRADECODE, X.COMPONENTCODE, NVL(X.APPLICABLE,'NO') APPLICABLE
                  FROM PISGRADECOMPONENTMAPPING X, 
                  (
                    SELECT UNITCODE, CATEGORYCODE, GRADECODE, MAX(YEARMONTH) YEARMONTH 
                    FROM PISGRADECOMPONENTMAPPING 
                    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                      AND UNITCODE = P_UNIT 
                      AND YEARMONTH <= P_YEARMONTH
                    GROUP BY UNITCODE, CATEGORYCODE, GRADECODE  
                  ) Y
                  WHERE X.COMPANYCODE = P_COMPCODE AND X.DIVISIONCODE = P_DIVCODE   
                    AND X.UNITCODE = X.UNITCODE AND X.CATEGORYCODE = Y.CATEGORYCODE AND X.GRADECODE = Y.GRADECODE
                    AND X.YEARMONTH = Y.YEARMONTH
                    AND X.APPLICABLE = 'Y'                     
                ) C                                     
                WHERE A.COMPONENTCODE = B.COMPONENTCODE
                  AND A.UNITCODE = C.UNITCODE AND A.CATEGORYCODE = C.CATEGORYCODE AND A.GRADECODE = C.GRADECODE  
                  AND A.COMPONENTCODE = C.COMPONENTCODE
                ORDER BY A.WORKERSERIAL,B.CALCULATIONINDEX
          )
    LOOP          
        lv_intCnt := lv_intCnt+1;
        
           DBMS_OUTPUT.PUT_LINE ('RUN QRY 3 cWages.WORKERSERIAL '||cWages.WORKERSERIAL);   
        if lv_strWorkerSerial <> cWages.WORKERSERIAL then
                begin
                    lv_CoinBf:=0;
                    select NVL(COINCF,0) into lv_CoinBf FROM PIS_PREV_FN_COIN where workerserial = lv_strWorkerSerial;
                exception
                    --when others then null;
                    when others then lv_CoinBf :=0;
                end;
                
             
        
            if lv_strWorkerSerial <> 'X' then
                ---- GENERATION COIN CF, TOTAL DEDUCTION, NET SALARY -------
                lv_ComponentAmt := FN_ROUNDOFFRS (lv_TotalEarn - lv_TotalDedn,lv_RoundOffRs,lv_RoundOffType);
                --lv_TempDednAmt := lv_GrossWages + nvl(lv_CoinBf,0) - lv_TotalDedn - lv_ComponentAmt;
                if lv_RoundOffType <> 'H' then
                    lv_CoinCf := lv_TotalEarn - lv_TotalDedn - lv_ComponentAmt;
                else
                    lv_CoinCf := lv_ComponentAmt - (lv_TotalEarn - lv_TotalDedn);
                end if;
--                lv_Sql := 'UPDATE '||P_TABLENAME||' set NETSALARY = '||lv_ComponentAmt||' ,MISC_BF = '||lv_CoinBf||',  MISC_CF = '||lv_CoinCf||' where workerserial = '''||lv_strWorkerSerial||''' ';
                insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
                values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',sysdate,lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,lv_remarks );
                commit;
                lv_Sql := 'UPDATE '||P_TABLENAME||' set NETSALARY = '||lv_ComponentAmt||' ,MISC_BF = '||nvl(lv_CoinBf,0)||',  MISC_CF = '||lv_CoinCf||' where workerserial = '''||lv_strWorkerSerial||''' ';
                execute immediate lv_Sql;
                commit;
                
                insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
                values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',sysdate,lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,lv_remarks );
                commit;
                
                
                
             
            end if;
            
            
           --added on 12/09/2020
                
            begin
--                    lv_Sql := 'SELECT NVL(MIN_PAY,0) FROM PISPAYTRANSACTION_SWT WHERE TOKENNO='''||00934||''' AND YEARMONTH = '''||202007||'''';
                lv_Sql := 'SELECT NVL(MIN_PAY,0) FROM '||P_TABLENAME||' WHERE workerserial='''||cWages.WORKERSERIAL||'''';
                    
                    
                insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
                values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',sysdate,lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,'MINIMUM PAYABLE AMOUNT' );
                commit;
            

                execute immediate lv_Sql into lv_MinPay;
                lv_MinimumPayableAmt := lv_MinPay;
                    
            exception when others then
                lv_MinPay := 0;
            end;
             --ended on 12/09/2020
                 
            lv_strWorkerSerial := cWages.WORKERSERIAL;
            lv_WagesAsOn := cWages.GROSSEARN - lv_MinimumPayableAmt; -- -lv_CoinBf;
            lv_GrossWages := cWages.GROSSEARN;
            lv_TotalEarn := cWages.GROSSEARN; -- -lv_CoinBf;           --cWages.TOTEARN; CHANGES ON 25.01.2017 NEED TO BE CHANGE LATER FOR CONSIDER COINBF AMOUNT --
            lv_TotalDedn :=0;
            ----DBMS_OUTPUT.PUT_LINE ('WORKERSERIAL '||cWages.WORKERSERIAL||', Component '||cWages.COMPONENTCODE||', Gross Wages '||cWages.GROSSEARN||' , AS On '||lv_WagesAsOn);        
        end if;
        lv_TempDednAmt := 0;
        lv_ComponentAmt := cWages.COMPONENTAMOUNT;    
           DBMS_OUTPUT.PUT_LINE ('lv_ComponentAmt '||lv_ComponentAmt);        

        IF P_TRANTYPE='ARREAR' OR P_TRANTYPE='NEW SALARY' THEN --- NEW ADD ON 11/12/2019
            IF CWages.INCLUDEARREAR<>'Y' THEN
                GOTO LOOPSKIP;
            END IF;
        END IF;    
        
        CASE cWages.COMPONENTGROUP
        
            WHEN 'PTAX' THEN
                --- PTAX CALCULATE BASED ON SLAB EMPLOYEE'S PTAX STATE WHICH DEFINED IN THE EMPLOYEE MASTER, ----
                --- IF NOT DEFINED IN THE EMPLOYEEMASTER THEN IT TAKEN DEFAULT STATE AS WEST BENGAL IN THE MASTER VIEW CREATION ---  
                lv_ComponentAmt := cWages.COMPONENTAMOUNT;
                begin
                    SELECT A.PTAXAMOUNT into lv_TempVal FROM PTAXSLAB A, PISMAST B
                    WHERE 1=1
                      AND B.WORKERSERIAL = cWages.WORKERSERIAL  
                      AND B.PTAXSTATE = A.STATENAME 
                      AND WITHEFFECTFROM = ( SELECT MAX(WITHEFFECTFROM) FROM PTAXSLAB WHERE WITHEFFECTFROM <= lv_fn_stdt)
                      AND SLABAMOUNTFROM <= lv_ComponentAmt  
                      AND SLABAMOUNTTO >= lv_ComponentAmt;
                exception
                    when others then 
                      lv_TempVal := 0;
                end;
                lv_ComponentAmt := nvl(lv_TempVal,0);
                --- LIC DUCTION BASE ON gtt_DEDUCTION
--            WHEN 'LIC' THEN
--                lv_TempVal := 0;
--                lv_ComponentAmt := 0;
--                
--                IF P_TRANTYPE <> 'ARREAR' THEN --- FOR ARREAR TIME IT'S NOT REQUIRED
--                    SELECT COUNT(*) CNT INTO lv_CNT FROM  GBL_LICBALANCE WHERE WORKERSERIAL = cWages.WorkerSerial;
--                    IF lv_CNT > 0 THEN
--                        for cLIC in (SELECT * FROM GBL_LICBALANCE WHERE WORKERSERIAL = cWages.WorkerSerial)
--                        LOOP
--                            ----DBMS_OUTPUT.PUT_LINE('WAGES ON  '||lv_WagesAsOn || 'and RUNNING WAGES' ||(lv_ComponentAmt+ cLIC.DUEAMOUNT));
--                            IF lv_WagesAsOn > lv_ComponentAmt+ cLIC.DUEAMOUNT then
--                              --  --DBMS_OUTPUT.PUT_LINE('lic count  '||lv_CNT||', WORKERSERIAL '||cWages.WorkerSerial);
--                                lv_ComponentAmt := lv_ComponentAmt+cLIC.DUEAMOUNT;
--                                lv_Remarks := 'Updating wages - WORKERSERIAL -'||cWages.WorkerSerial||', Token - '||cWages.TOKENNO||', Component -'||cWages.componentcode||', Amount -'||lv_TempDednAmt||', As On Bal '||lv_WagesAsOn;
--                                lv_SqlStr := 'UPDATE GBL_LICBALANCE   SET DEDUCTIONSTATUS=''Y'',DEDUCTFORTNIGHTSTARTDATE= TO_DATE('''||lv_fn_stdt||''',''DD/MM/RRRR''),'||CHR(10)
--                                            ||'DEDUCTYEARMONTH = TO_CHAR(TO_DATE('''||TO_CHAR(lv_fn_stdt,'DD/MM/YYYY')||''',''DD/MM/YYYY''),''YYYYMM'')'||CHR(10)
--                                            ||'WHERE COMPANYCODE='''||cLIC.COMPANYCODE||''' '||CHR(10)
--                                            ||'     AND DIVISIONCODE='''||cLIC.DIVISIONCODE||''' '||CHR(10)
--                                            ||'     AND POLICYNO='''||cLIC.POLICYNO||''' '||CHR(10)
--                                            ||'     AND DUEDATE=TO_DATE('''||TO_CHAR(cLIC.DUEDATE,'DD/MM/YYYY')||''',''DD/MM/YYYY'')';
--                                insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE, ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
--                                values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',SYSDATE, lv_SqlStr,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
--                                execute immediate lv_SqlStr;
--                            END IF;
--                        END LOOP;
--                        
--                    END IF;
--                END IF;    
                --RETURN;
            WHEN 'PF LOAN' THEN
                lv_ComponentAmt := 0;
                
                lv_CapEMI       := 0;
                lv_IntEMI       := 0;
                
                lv_PFNO         :='';
                --- ONLY SALARY AND FINAL SETTLEMENT TIME LOAN VALUE CALCULATE IN THE SYSTEM ---
                if P_TRANTYPE = 'SALARY' OR P_TRANTYPE = 'FINAL SETTLEMENT' then
                    lv_ComponentAmt := cWages.COMPONENTAMOUNT;
                    lv_ComponentAmt:=0;
                    BEGIN
                        -- ADD 14/09/2019
                            SELECT PFNO INTO lv_PFNO FROM PISEMPLOYEEMASTER WHERE TOKENNO=cWages.TOKENNO;
                        -- ADD 14/09/2019
                        if substr(cWages.componentcode,1,5) = 'LOAN_' THEN
                            --- CHANGES ON 10.05.2017 FOR SECURITY (lUDLOW) GUARD(04) AS ON BALANCE SHOULD BE CHECK ON CAPITAL EMI + INTERNERST EMI 
                            SELECT CASE WHEN PFLOAN_BAL > CAP_EMI THEN CAP_EMI ELSE PFLOAN_BAL END,
                            CASE WHEN PFLOAN_BAL > CAP_EMI THEN CAP_EMI ELSE PFLOAN_BAL END,
                            CASE WHEN PFLOAN_INT_BAL > INT_EMI THEN INT_EMI ELSE PFLOAN_INT_BAL END 
                            INTO lv_ComponentAmt, lv_CapEMI, lv_IntEMI
                            --SELECT CASE WHEN PFLOAN_BAL > CAP_EMI THEN CAP_EMI ELSE PFLOAN_BAL END INTO lv_ComponentAmt  
                            FROM GBL_PFLOANBLNC 
                            -- ADD 14/09/2019
                            --WHERE WORKERSERIAL = cWages.WorkerSerial
                            WHERE PFNO = lv_PFNO
                            -- ADD 14/09/2019
                              AND LOANCODE = substr(cWages.componentcode,6)
                              AND NVL(CAP_STOP,'N') = 'N'
                              AND PFLOAN_BAL > 0;
                        elsif substr(cWages.componentcode,1,5) = 'LINT_' THEN 
                        
                            SELECT CASE WHEN PFLOAN_INT_BAL > INT_EMI THEN INT_EMI ELSE PFLOAN_INT_BAL END,
                            CASE WHEN PFLOAN_BAL > CAP_EMI THEN CAP_EMI ELSE PFLOAN_BAL END,
                            CASE WHEN PFLOAN_INT_BAL > INT_EMI THEN INT_EMI ELSE PFLOAN_INT_BAL END 
                            INTO lv_ComponentAmt, lv_CapEMI, lv_IntEMI
                            --SELECT CASE WHEN PFLOAN_INT_BAL > INT_EMI THEN INT_EMI ELSE PFLOAN_INT_BAL END INTO lv_ComponentAmt  
                            FROM GBL_PFLOANBLNC
                            -- ADD 14/09/2019 
                            --WHERE WORKERSERIAL = cWages.WorkerSerial
                            WHERE PFNO = lv_PFNO
                            -- ADD 14/09/2019
                              AND LOANCODE = substr(cWages.componentcode,6)
                              AND NVL(INT_STOP,'N') = 'N'
                              AND PFLOAN_INT_BAL > 0;
                             -- DBMS_OUTPUT.PUT_LINE(cWages.componentcode|| ' '||lv_ComponentAmt);
                        else
                            lv_ComponentAmt := 0;
                        end if;
                        -- LUDLOW MAINTAIN AS ON BALANCE SHOULD BE 125% MORE THAN EMI AMOUNT OTHER WISE EMI AMOUNT SHOULD BE ZERO
                        --- CHANGES ON 10.05.2017 FOR SECURITY (lUDLOW) GUARD(04) AS ON BALANCE SHOULD BE CHECK ON CAPITAL EMI + INTERNERST EMI
--                        if cWages.CATEGORYCODE = '04' then
--                            -- FOR SECURITY GUARD  AS BALANCE CAN'T LESS THAN SUM OF CAPITAL AND INTEREST EMI.
--                            IF lv_WagesAsOn < (lv_CapEMI+lv_IntEMI) THEN  
--                                lv_ComponentAmt :=0;
--                            end if;                        
--                        else
--                            IF lv_WagesAsOn < lv_ComponentAmt*1.25 THEN
--                                lv_ComponentAmt :=0;
--                            end if;
--                        end if;    

                    EXCEPTION WHEN NO_DATA_FOUND THEN lv_ComponentAmt := 0;
                              WHEN OTHERS THEN lv_ComponentAmt := 0;      
                    END;        
                else
                    lv_ComponentAmt := 0;
                end if;             
                
                

                              DBMS_OUTPUT.PUT_LINE('PF LOAN AMOUNT '||cWages.componentcode|| ' '||lv_ComponentAmt);   
            WHEN 'LOAN' THEN
               -- --DBMS_OUTPUT.PUT_LINE('WORKERSERIAL '||cWages.WORKERSERIAL||', COMPONENT '||cWages.componentcode);
                lv_ComponentAmt:=0;
                --- ONLY SALARY AND FINAL SETTLEMENT TIME LOAN VALUE CALCULATE IN THE SYSTEM ---
                if P_TRANTYPE = 'SALARY' OR P_TRANTYPE ='FINAL SETTLEMENT' then
                    BEGIN
                        if substr(cWages.componentcode,1,5) = 'LOAN_' THEN 
                            SELECT CASE WHEN LOAN_BAL > CAP_EMI THEN CAP_EMI ELSE LOAN_BAL END INTO lv_ComponentAmt  
                            FROM GBL_LOANBLNC 
                            WHERE WORKERSERIAL = cWages.WorkerSerial and MODULE = 'PIS'
                              AND LOANCODE = substr(cWages.componentcode,6)
                              AND NVL(CAP_STOP,'N') = 'N'
                              AND LOAN_BAL > 0;
                        elsif substr(cWages.componentcode,1,5) = 'LINT_' THEN 
                            SELECT CASE WHEN LOAN_INT_BAL > INT_EMI THEN INT_EMI ELSE LOAN_INT_BAL END INTO lv_ComponentAmt  
                            FROM GBL_LOANBLNC 
                            WHERE WORKERSERIAL = cWages.WorkerSerial and MODULE = 'PIS'
                              AND LOANCODE = substr(cWages.componentcode,6)
                              AND NVL(INT_STOP,'N') = 'N'
                              AND LOAN_INT_BAL > 0;
                        else
                            lv_ComponentAmt := 0;
                        end if;
                --DBMS_OUTPUT.PUT_LINE('lv_ComponentAmt '||lv_ComponentAmt);
                    EXCEPTION WHEN NO_DATA_FOUND THEN lv_ComponentAmt := 0;
                              WHEN OTHERS THEN lv_ComponentAmt := 0;      
                    END;
                end if;   
             WHEN 'ELECTRICITY' then
                BEGIN
--                    BEGIN
--                         SELECT ATTENDANCEHOURS INTO lv_ChkAttnHrs FROM WPSTEMPATTN WHERE WORKERSERIAL = cWages.WorkerSerial;
--                    EXCEPTION
--                        WHEN OTHERS THEN lv_ChkAttnHrs:=0;
--                    END;
                    lv_ChkAttnHrs := 1;
                    IF lv_ChkAttnHrs > 0 THEN
                        SELECT CASE WHEN NVL(ELEC_BAL_AMT,0) > NVL(ELEC_EMI_AMT,0) THEN ELEC_EMI_AMT ELSE ELEC_BAL_AMT END INTO lv_ComponentAmt  
--                        SELECT NVL(ELEC_BAL_AMT,0) INTO lv_ComponentAmt 
                        FROM GBL_ELECBLNC
                        WHERE WORKERSERIAL = cWages.WorkerSerial; 
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
            WHEN 'UNREALIZED' THEN
                BEGIN
                    SELECT TOTAL_COMPONENT_EMI INTO lv_ComponentAmt  
--                        SELECT NVL(ELEC_BAL_AMT,0) INTO lv_ComponentAmt 
                    FROM GBL_UNREALIZEDCOMPAMT
                    WHERE WORKERSERIAL = cWages.WorkerSerial; 
--                    IF lv_ComponentAmt > 0 THEN
--                        IF NVL(cWages.PARTIALLYDEDUCT,'NA') = 'Y' THEN
--                             if lv_WagesAsOn < lv_ComponentAmt then
--                                lv_ComponentAmt := floor(lv_WagesAsOn);
--                             end if;
--                        END IF;            
--                    END IF;
                EXCEPTION WHEN NO_DATA_FOUND THEN lv_ComponentAmt := 0;
                          WHEN OTHERS THEN lv_ComponentAmt := 0;      
                END;      
                                 
            WHEN 'OTHERS' THEN
                lv_ComponentAmt := cWages.COMPONENTAMOUNT;
            ELSE
                lv_ComponentAmt := cWages.COMPONENTAMOUNT;
        END CASE;
       -- lv_TempDednAmt := FN_ROUNDOFFRS(lv_TempDednAmt,cWages.ROUNDOFFRS,cWages.ROUNDOFFTYPE);

        if lv_WagesAsOn >=  lv_ComponentAmt then             -- cWages.COMPONENTAMOUNT
            lv_TempDednAmt := lv_ComponentAmt;              -- cWages.COMPONENTAMOUNT;
        else     
            IF NVL(cWages.PARTIALLYDEDUCT,'NA') = 'N' THEN
                lv_TempDednAmt := 0;
            ELSE
                lv_TempDednAmt := lv_WagesAsOn;  
            END IF;
               
           -- lv_TempDednAmt := lv_WagesAsOn;  
        end if;
        lv_Remarks := 'Updating wages - WORKERSERIAL -'||cWages.WorkerSerial||', Token - '||cWages.TOKENNO||', Component -'||cWages.componentcode||', Amount -'||lv_TempDednAmt||', As On Bal '||lv_WagesAsOn||', As Component Amt '||lv_ComponentAmt || '  MinimumPayableAmt :'||lv_MinimumPayableAmt;
        ----DBMS_OUTPUT.PUT_LINE (lv_Remarks);
        if lv_TempDednAmt <> 0 then
            lv_TotalDedn := lv_TotalDedn + lv_TempDednAmt;
--            lv_SqlStr := 'UPDATE PISPAYTRANSACTION_SWT set '||cWages.componentcode||' = '||lv_TempDednAmt||', TOTDEDN = '||lv_TotalDedn||' where workerserial = '''||cWages.WorkerSerial||''' ';
            lv_SqlStr := 'UPDATE '||P_TABLENAME||'  set '||cWages.componentcode||' = '||lv_TempDednAmt||', GROSSDEDN = '||lv_TotalDedn||' where workerserial = '''||cWages.WorkerSerial||''' ';
            insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
            values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',SYSDATE, lv_SqlStr,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
            execute immediate lv_SqlStr;
        end if;
        lv_WagesAsOn := lv_WagesAsOn - lv_TempDednAmt;
        insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
        values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',SYSDATE, lv_SqlStr,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);        
        <<LOOPSKIP>>
                 lv_ComponentAmt:=0;   

    end loop; 
    ---- FRO LAST EMPLOYEE GENERATION COIN CF, TOTAL DEDUCTION, NET SALARY -------
    lv_ComponentAmt := FN_ROUNDOFFRS(lv_TotalEarn - lv_TotalDedn,lv_RoundOffRs,lv_RoundOffType);
    --lv_TempDednAmt := lv_GrossWages + nvl(lv_CoinBf,0) - lv_TotalDedn - lv_ComponentAmt;
    if lv_RoundOffType <> 'H' then
        lv_CoinCf := lv_TotalEarn - lv_TotalDedn - lv_ComponentAmt;
    else
        lv_CoinCf := lv_ComponentAmt - (lv_TotalEarn - lv_TotalDedn);
    end if;
    ---- CHANGES ON 29.02.2020 --
    lv_Remarks := 'NET SALARY UPDATE';
--    lv_Sql := 'UPDATE '||P_TABLENAME||' set NETSALARY = '||lv_ComponentAmt||', MISC_CF = '||lv_CoinCf||' where workerserial = '''||lv_strWorkerSerial||''' ';

    lv_Sql := ' UPDATE '||P_TABLENAME||' SET MISC_BF = 0 WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10);
    
--    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
--    values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',SYSDATE,lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,'COIN BF' );
--    commit;
    execute immediate lv_Sql;
    
    lv_Sql := 'UPDATE '||P_TABLENAME||' A SET A.MISC_BF = (SELECT B.COINCF FROM PIS_PREV_FN_COIN B WHERE A.WORKERSERIAL = B.WORKERSERIAL) '||CHR(10)
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' AND A.YEARMONTH = '''||P_YEARMONTH||''' '||CHR(10)
        ||' AND WORKERSERIAL IN (SELECT WORKERSERIAL FROM PIS_PREV_FN_COIN) '||CHR(10); 
    
--    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
--    values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',SYSDATE,lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,'COIN BF' );
--    commit;
          
    execute immediate lv_Sql;
    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',SYSDATE,lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,'COIN BF' );
    commit;
    
    -- disable on 01/03/2020 ---
    lv_Sql := 'UPDATE '||P_TABLENAME||' set NETSALARY = '||lv_ComponentAmt||',  MISC_CF = '||lv_CoinCf||' where workerserial = '''||lv_strWorkerSerial||''' ';
    execute immediate lv_Sql;
    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',SYSDATE,lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,lv_remarks );
    commit;
    --- NET SALARY UPDATE WRITE ON 29/02/2020 ---
    lv_Sql := ' UPDATE '||P_TABLENAME||' set NETSALARY = NVL(NETSALARY,0) - NVL(MISC_BF,0) WHERE COMPANYCODE='''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' AND YEARMONTH = '''||P_YEARMONTH||''' ';  
    execute immediate lv_Sql;
    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',SYSDATE,lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,lv_remarks );
    commit;
    if P_TRANTYPE = 'SALARY' OR P_TRANTYPE = 'FINAL SETTLEMENT' then -- FOR ARREAR PROCESS IT'S NOT REQUIRED 
     


        ------------ INSERT LOAN DATA IN BREAKUP TABLE ----------
        --- for pf loan contribtion insert --
        PRC_LOANBREAKUP_INSERT_WAGES ( P_COMPCODE,P_DIVCODE, lv_YearCode,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'), TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'PIS','PISPAYTRANSACTION_SWT','PF',NULL,NULL,NULL);        
        --- for GENERAL loan contribtion insert --
        PRC_LOANBREAKUP_INSERT_WAGES ( P_COMPCODE,P_DIVCODE, lv_YearCode,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'), TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'PIS','PISPAYTRANSACTION_SWT','SALARY',NULL,NULL,NULL);        
        --- for pf loan balance update in salary table ------
        ---- WAGES UPDATE PROCEDURE CALL PF LOAN UPDATE ON 01/03/3020'
--        PRC_LOANBALANCEUPDATE_SALARY (P_COMPCODE,P_DIVCODE, TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'), TO_CHAR(lv_fn_endt,'DD/MM/YYYY'), 'PIS', 'PISPAYTRANSACTION_SWT','PF', NULL,NULL);
       PRC_LOANBALANCE_UPDT_WAGES(P_COMPCODE,P_DIVCODE,lv_YearCode,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'), TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'PIS',P_TABLENAME,'PF',NULL,NULL,NULL);             
       PRC_LOANBALANCE_UPDT_WAGES(P_COMPCODE,P_DIVCODE,lv_YearCode,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'), TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'PIS',P_TABLENAME,NULL,NULL,NULL,NULL);             
        --- for GENERAL loan balance update in salary table ------
        PRC_LOANBALANCEUPDATE_SALARY (P_COMPCODE,P_DIVCODE, TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'), TO_CHAR(lv_fn_endt,'DD/MM/YYYY'), 'PIS', 'PISPAYTRANSACTION_SWT','SALARY', NULL,NULL);
        -----FOR LIC BALANCE UPDATE IN LICDETAILS TABLE -------
        --PROC_LICUPDATE();
        
            
        --  ELECTRIC DEDUCTION BREAKUP
        lv_remarks := 'ELECTRIC BREAKUP DATA INSERT';
--        PRC_ELECTRICBREAKUP_INSERT(P_COMPCODE,P_DIVCODE,lv_YearCode,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'PIS', P_TABLENAME, NULL);
        PRC_ELECTRICBREAKUP_INSERT(P_COMPCODE,P_DIVCODE,lv_YearCode,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'PIS', 'PISPAYTRANSACTION', NULL);




     -- REALIZED/ UNREALIZED COMPONENTDATA INSERT 
        lv_remarks := 'UNREALIZED COMPONENT DATA INSERT';
        PRC_REALIZEDUNREALDATA_INSERT (P_COMPCODE,P_DIVCODE,LV_YEARCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'WPS', P_TABLENAME,'SHOP_RENT', 'ALL', NULL);


    end if;            
exception
when others then
 lv_sqlerrm := sqlerrm ;
 --DBMS_output.put_line(lv_sqlerrm||','||lv_sql);
 insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE, ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
 values( P_COMPCODE, P_DIVCODE,lv_ProcName,lv_sqlerrm,SYSDATE, lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);    
end;
/
