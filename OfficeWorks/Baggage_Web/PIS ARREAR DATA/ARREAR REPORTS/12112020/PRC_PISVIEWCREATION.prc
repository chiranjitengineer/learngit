CREATE OR REPLACE PROCEDURE BAGGAGE_WEB.PRC_PISVIEWCREATION ( P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2, 
                                                  P_ViewName Varchar2,
                                                  P_Phase Number,
                                                  P_YEARMONTH Varchar2,
                                                  P_EFFECTYEARMONTH Varchar2,
                                                  P_TRANTYPE VARCHAR2 DEFAULT 'SALARY', 
                                                  P_SALRAYTABLENAME VARCHAR2 DEFAULT 'PISPAYTRANSACTION_SWT')
as 
lv_fn_stdt DATE := TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY');
lv_fn_endt DATE := LAST_DAY(TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY'));
lv_TableName        varchar2(50)   := '' ;
lv_Remarks          varchar2(1000) := '';
lv_SqlStr           varchar2(4000);
lv_CompMast_Rec PISCOMPONENTMASTER%ROWTYPE;
lv_AttnComponent    varchar2(32000) := '';
lv_AssignComponent  varchar2(32000) := ''; 
lv_PayComponent     varchar2(32000) := '';
lv_parvalues        varchar2(500)  := '' ;
lv_sqlerrm          varchar2(500)  := '';
lv_ProcName         varchar2(30)   := 'PRC_PISVIEWCREATION';
lv_AttnTranType     varchar2(30);     
lv_PhaseTableName   varchar2(25);
lv_ProcessType      varchar2(50) := 'SALARY';
lv_Lday_Cols        varchar2(100) := '';

--lv_AttnComponent    varchar2(32000) := '';
--lv_AssignComponent  varchar2(32000) := '';
lv_AssignCompWithArrear varchar2(10000) := '';
lv_AssignCompWithOutArrear varchar2(10000) := '';
lv_AssignCompSum           varchar2(10000) := '';
--lv_AssignComponent  varchar2(32000):=''; 
begin
    
    --lv_TableName := 'PISPAYTRANSACTION_SWT';    
    lv_TableName := P_SALRAYTABLENAME;
    if P_SALRAYTABLENAME is null then
        lv_TableName := 'PISPAYTRANSACTION_SWT';
    end if;
    
    lv_AttnTranType := P_TRANTYPE;
    --DBMS_OUTPUT.PUT_LINE ('TRAN TYPE '||P_TRANTYPE);
--    IF P_TRANTYPE = 'ARREAR' OR  P_TRANTYPE = 'SALARY' THEN
--        lv_AttnTranType := 'ATTENDANCE';
--    END IF;
    if NVL(P_TRANTYPE,'N') <> 'FINAL SETTLEMENT' THEN
        lv_AttnTranType := 'ATTENDANCE';        
    end if;
    
    -- the below variable use in component view, 
    -- because at the time of arrear process we store the data in'NEW SALRY' TRANSACTIONTYPE (FORCE FULLY)
    -- DUE TO CLRIFY THE SALARY WITH NEW RATE IN ARREAR TRANSACTION TYPE  
    --DBMS_OUTPUT.PUT_LINE ('0_0');
    IF P_TRANTYPE = 'ARREAR' THEN
        lv_ProcessType := 'NEW SALARY';
    ELSE
        lv_ProcessType := P_TRANTYPE;
    END IF;    
    
--    if NVL(P_TRANTYPE,'N') <> 'FINAL SETTLEMENT' THEN
--        lv_AttnTranType := 'ATTENDANCE';        
--    end if;
    
    --DBMS_OUTPUT.PUT_LINE('STARTDATE: '||lv_fn_stdt||', ENDDATE  '||lv_fn_endt);
    lv_parvalues := 'VIEWNAME = '||P_ViewName||', YEARMONTH = '||P_YEARMONTH;
    FOR C1 IN (
                SELECT COMPONENTCODE, NVL(ROLLOVERAPPLICABLE,'N') ROLLOVERAPPLICABLE, NVL(ATTENDANCEENTRYAPPLICABLE,'N') ATTENDANCEENTRYAPPLICABLE,
                    NVL(INCLUDEARREAR,'N') INCLUDEARREAR
                FROM PISCOMPONENTMASTER
                WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                  AND INCLUDEPAYROLL = 'Y'
                  --AND ROLLOVERAPPLICABLE = 'Y'
                  AND YEARMONTH = ( 
                                    SELECT MAX(YEARMONTH) YEARMONTH FROM PISCOMPONENTMASTER
                                    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                                      AND YEARMONTH <= P_YEARMONTH
                                      --AND INCLUDEPAYROLL = 'Y'
                                  )        
                ) 
    loop
        if C1.ROLLOVERAPPLICABLE = 'Y' THEN
            if lv_AssignComponent = '' then
                lv_AssignComponent := ', NVL(A.'||C1.COMPONENTCODE||',0) AS '|| C1.COMPONENTCODE;
            else
                lv_AssignComponent := lv_AssignComponent ||', NVL(A.'||C1.COMPONENTCODE||',0) AS '|| C1.COMPONENTCODE;
            end if;
            --- BELOW PART IS REQUIRED AT THE TIME ARREAR CALCULATION ---
            --- WHEN USER NOT CLAULATE THE ARREAR ON SOME MASTER COMPONENT THEN THOSE COMPONENT RATE SHOULD BE TAKEN FROM OLD SALARY MONTH (NOT EFFECTED YEARMONTH) 
            IF C1.INCLUDEARREAR = 'Y' THEN
                if lv_AssignCompSum = '' then
                    lv_AssignCompSum := ', SUM('||C1.COMPONENTCODE||') AS '||C1.COMPONENTCODE;
                else
                    lv_AssignCompSum := lv_AssignCompSum||', SUM('||C1.COMPONENTCODE||') AS '||C1.COMPONENTCODE;
                end if;
                IF lv_AssignCompWithArrear = '' THEN
                    lv_AssignCompWithArrear := ', NVL(A.'||C1.COMPONENTCODE||',0) AS '|| C1.COMPONENTCODE;            
                ELSE
                    lv_AssignCompWithArrear := lv_AssignCompWithArrear ||', NVL(A.'||C1.COMPONENTCODE||',0) AS '|| C1.COMPONENTCODE;
                END IF;
                
                IF lv_AssignCompWithOutArrear = '' THEN
                    lv_AssignCompWithOutArrear := ', 0 AS '||C1.COMPONENTCODE;
                ELSE
                    lv_AssignCompWithOutArrear := lv_AssignCompWithOutArrear ||', 0 AS '||C1.COMPONENTCODE;
                END IF;
            ELSE
                if lv_AssignCompSum = '' then
                    lv_AssignCompSum := ', SUM('||C1.COMPONENTCODE||') AS '||C1.COMPONENTCODE;
                else
                    lv_AssignCompSum := lv_AssignCompSum||', SUM('||C1.COMPONENTCODE||') AS '||C1.COMPONENTCODE;
                end if;
                
                IF lv_AssignCompWithArrear = '' THEN
                    lv_AssignCompWithArrear := ', 0 AS '||C1.COMPONENTCODE;
                ELSE
                    lv_AssignCompWithArrear := lv_AssignCompWithArrear ||', 0 AS '||C1.COMPONENTCODE;
                END IF;            
                
                IF lv_AssignCompWithOutArrear = '' THEN
                    lv_AssignCompWithOutArrear := ', NVL(A.'||C1.COMPONENTCODE||',0) AS '|| C1.COMPONENTCODE;            
                ELSE
                    lv_AssignCompWithOutArrear := lv_AssignCompWithOutArrear ||', NVL(A.'||C1.COMPONENTCODE||',0) AS '|| C1.COMPONENTCODE;
                END IF;            
            END IF;            
        elsif c1.ATTENDANCEENTRYAPPLICABLE = 'Y' THEN
            if lv_AttnComponent = '' then
                lv_AttnComponent := ', NVL(A.'||C1.COMPONENTCODE||',0) AS '|| C1.COMPONENTCODE;
            else
                lv_AttnComponent := lv_AttnComponent ||', NVL(A.'||C1.COMPONENTCODE||',0) AS '|| C1.COMPONENTCODE;
            end if;            
        end if;    
        IF SUBSTR(C1.COMPONENTCODE,1,5) <> 'ATTN_' AND SUBSTR(C1.COMPONENTCODE,1,5) <> 'LDAY_' THEN
            if lv_PayComponent = '' then
                lv_PayComponent := ', NVL(A.'||C1.COMPONENTCODE||',0) AS '|| C1.COMPONENTCODE;
            else
                lv_PayComponent := lv_PayComponent ||', NVL(A.'||C1.COMPONENTCODE||',0) AS '|| C1.COMPONENTCODE;
            end if;    
        END IF;
    END LOOP;
   --DBMS_OUTPUT.PUT_LINE ('0_1');
    if P_ViewName = 'PISMAST' OR NVL(P_ViewName,'ALL') = 'ALL' then
        lv_Remarks := 'VIEW - PISMAST';
        lv_SqlStr := ' CREATE OR REPLACE VIEW PISMAST '||CHR(10)
           ||' AS '||CHR(10)
           ||' SELECT A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, A.UNITCODE, A.TOKENNO, A.CATEGORYCODE, A.GRADECODE, NVL(A.PFAPPLICABLE,''N'') PFAPPLICABLE, NVL(A.EPFAPPLICABLE,''N'') EPFAPPLICABLE, '||CHR(10)
           ||' NVL(A.PTAXAPPLICABLE,''N'') PTAXAPPLICABLE,  NVL(A.ESIAPPLICABLE,''Y'') ESIAPPLICABLE,  NVL(A.QUARTERALLOTED,''N'') QUARTERALLOTED, A.EMPLOYEESTATUS, A.DEPARTMENTCODE, A.DESIGNATIONCODE, '||CHR(10)
           ||' A.PFNO, A.PENSIONNO, A.ESINO, A.BANKACCNUMBER, NVL(A.PAYMODE,''CASH'') PAYMODE, '||CHR(10)
           ||' A.DATEOFBIRTH, A.DATEOFJOIN, A.PFENTITLEDATE, A.STATUSDATE, A.EXTENDEDRETIREDATE, NVL(A.PTAXSTATE,''WEST BENGAL'') PTAXSTATE '||CHR(10)
           ||' FROM PISEMPLOYEEMASTER A, PISMONTHATTENDANCE B '||CHR(10)
           ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
           ||'   AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
           ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
           ||'   AND B.YEARMONTH = '''||P_YEARMONTH||''' '||CHR(10)
           ||'   AND B.TRANSACTIONTYPE = '''||lv_AttnTranType||''' '||CHR(10)
           ||' ORDER BY B.TOKENNO '||CHR(10);
       
       insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
       values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_Remarks);
       EXECUTE IMMEDIATE lv_SqlStr;
       
       COMMIT;
    end if;
--    DBMS_OUTPUT.PUT_LINE ('1_0');
--    DBMS_OUTPUT.PUT_LINE('PISMAST: '||lv_SqlStr);
    if P_ViewName = 'PISATTN' OR NVL(P_ViewName,'ALL') = 'ALL' then
        lv_Remarks := 'VIEW - PISATTN';
        lv_SqlStr := ' CREATE OR REPLACE VIEW PISATTN '||CHR(10)
           ||' AS '||CHR(10)
           ||' SELECT A.COMPANYCODE, A.DIVISIONCODE, B.UNITCODE, B.YEARMONTH, B.CATEGORYCODE, B.GRADECODE, B.WORKERSERIAL, B.TOKENNO, '||CHR(10) 
           ||' NVL(B.PRESENTDAYS,0) PRESENTDAYS, NVL(B.WITHOUTPAYDAYS,0) WITHOUTPAYDAYS, NVL(B.HOLIDAYS,0) HOLIDAYS, NVL(B.SALARYDAYS,0) SALARYDAYS, '||CHR(10) 
           ||' NVL(B.LV_ENCASH_DAYS,0) LV_ENCASH_DAYS, NVL(B.LVDAYS_RET,0) LVDAYS_RET, NVL(B.TOTALDAYS,0) TOTALDAYS, NVL(B.CALCULATIONFACTORDAYS,0) CALCULATIONFACTORDAYS '||CHR(10)
           ||' '||lv_AttnComponent||' '||CHR(10)
           ||' FROM PISMONTHATTENDANCE B, '||CHR(10) 
           ||' ( '||CHR(10)
           ||'     SELECT * FROM PISCOMPONENTASSIGNMENT '||CHR(10) 
           ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
           ||'       AND YEARMONTH = '''||P_YEARMONTH||'''  '||CHR(10)
           ||'       AND TRANSACTIONTYPE = '''||lv_AttnTranType||''' '||CHR(10)
           ||' )  A '||CHR(10)
           ||' WHERE B.COMPANYCODE = '''||P_COMPCODE||''' AND B.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
           ||'   AND B.YEARMONTH = '''||P_YEARMONTH||''' '||CHR(10)
           ||'   AND B.TRANSACTIONTYPE = '''||lv_AttnTranType||''' '||CHR(10)
           ||'   AND B.COMPANYCODE = A.COMPANYCODE (+) AND B.DIVISIONCODE = A.DIVISIONCODE (+) '||CHR(10)
           ||'   AND B.YEARMONTH = A.YEARMONTH (+) '||CHR(10)
           ||'   AND B.WORKERSERIAL = A.WORKERSERIAL (+) '||CHR(10)
           ||' ORDER BY B.TOKENNO  '||CHR(10);
  --      DBMS_OUTPUT.PUT_LINE('PISATTN: '||lv_SqlStr);
       insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
       values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_Remarks);
       EXECUTE IMMEDIATE lv_SqlStr;
       COMMIT;

    end if;
    --DBMS_OUTPUT.PUT_LINE ('1_1');
    if P_ViewName = 'PISASSIGN' OR NVL(P_ViewName,'ALL') = 'ALL' then
        lv_Remarks := 'VIEW - PISASSIGN';
        IF P_YEARMONTH = P_EFFECTYEARMONTH THEN
            lv_SqlStr := ' CREATE OR REPLACE VIEW PISASSIGN '||CHR(10)
               ||' AS '||CHR(10)
               ||' SELECT A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, A.YEARMONTH '||CHR(10)
               ||' '||lv_AssignComponent||' '||chr(10)
               ||' FROM PISCOMPONENTASSIGNMENT A, '||chr(10) 
               ||' ( '||chr(10)
               ||'     SELECT WORKERSERIAL, MAX(YEARMONTH) YEARMONTH '||chr(10)
               ||'     FROM PISCOMPONENTASSIGNMENT '||chr(10)
               ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
               ||'       AND YEARMONTH <= '''||P_EFFECTYEARMONTH||''' '||chr(10)
               ||'       AND TRANSACTIONTYPE = ''ASSIGNMENT'' '||chr(10)
               ||'     GROUP BY WORKERSERIAL '||chr(10)
               ||' ) B '||CHR(10)
               ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
               ||'   AND A.TRANSACTIONTYPE = ''ASSIGNMENT'' '||chr(10)
               ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||chr(10)
               ||'   AND A.YEARMONTH = B.YEARMONTH '||chr(10)
               ||' ORDER BY A.YEARMONTH '||CHR(10);
        else
            lv_SqlStr := ' CREATE OR REPLACE VIEW PISASSIGN '||CHR(10)
               ||' AS '||CHR(10)
               ||' SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL, YEARMONTH '||CHR(10)
               ||' '||lv_AssignCompSum||' '||chr(10)
               ||' FROM ('||CHR(10)
               ||'         SELECT  A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, '''|| P_EFFECTYEARMONTH ||''' YEARMONTH '||CHR(10)
               ||'         '||lv_AssignCompWithArrear||' '||chr(10)
               ||'         FROM PISCOMPONENTASSIGNMENT A, '||chr(10) 
               ||'         ( '||chr(10)
               ||'           SELECT WORKERSERIAL, MAX(YEARMONTH) YEARMONTH '||chr(10)
               ||'           FROM PISCOMPONENTASSIGNMENT '||chr(10)
               ||'           WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
               ||'             AND YEARMONTH <= '''||P_EFFECTYEARMONTH||''' '||chr(10)
               ||'             AND TRANSACTIONTYPE = ''ASSIGNMENT'' '||chr(10)
               ||'          GROUP BY WORKERSERIAL '||chr(10)
               ||'         ) B '||CHR(10)
               ||'         WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
               ||'           AND A.TRANSACTIONTYPE = ''ASSIGNMENT'' '||chr(10)
               ||'           AND A.WORKERSERIAL = B.WORKERSERIAL '||chr(10)
               ||'           AND A.YEARMONTH = B.YEARMONTH '||chr(10)
               ||'        /* ORDER BY A.YEARMONTH */'||CHR(10);
            IF LENGTH(TRIM(lv_AssignCompWithOutArrear)) > 0 THEN
            
               lv_SqlStr := lv_SqlStr ||' UNION ALL '||CHR(10);
            
               lv_SqlStr := lv_SqlStr ||'         SELECT  A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, '''|| P_EFFECTYEARMONTH ||''' YEARMONTH '||CHR(10)
                   ||'         '||lv_AssignCompWithOutArrear||' '||chr(10)
                   ||'         FROM PISCOMPONENTASSIGNMENT A, '||chr(10) 
                   ||'         ( '||chr(10)
                   ||'           SELECT WORKERSERIAL, MAX(YEARMONTH) YEARMONTH '||chr(10)
                   ||'           FROM PISCOMPONENTASSIGNMENT '||chr(10)
                   ||'           WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
                   ||'             AND YEARMONTH <= '''||P_YEARMONTH||''' '||chr(10)
                   ||'             AND TRANSACTIONTYPE = ''ASSIGNMENT'' '||chr(10)
                   ||'          GROUP BY WORKERSERIAL '||chr(10)
                   ||'         ) B '||CHR(10)
                   ||'         WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
                   ||'           AND A.TRANSACTIONTYPE = ''ASSIGNMENT'' '||chr(10)
                   ||'           AND A.WORKERSERIAL = B.WORKERSERIAL '||chr(10)
                   ||'           AND A.YEARMONTH = B.YEARMONTH '||chr(10)
                   ||'         /*ORDER BY A.YEARMONTH */'||CHR(10);
                        
            END IF;   
            lv_SqlStr := lv_SqlStr ||' ) '||CHR(10)
                   ||' GROUP BY COMPANYCODE, DIVISIONCODE, WORKERSERIAL, YEARMONTH '||CHR(10)
                   ||' ORDER BY YEARMONTH '||CHR(10);
        
        end if;                     
--        DBMS_OUTPUT.PUT_LINE('PISASSIGN: '||lv_SqlStr);
       insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
       values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_Remarks);
       EXECUTE IMMEDIATE lv_SqlStr;
       COMMIT;

        lv_Remarks := 'VIEW - PISPRVRT';
        lv_SqlStr := ' CREATE OR REPLACE VIEW PISPRVRT '||CHR(10)
           ||' AS '||CHR(10)
           ||' SELECT A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, A.YEARMONTH '||CHR(10)
           ||' '||lv_AssignComponent||' '||chr(10)
           ||' FROM PISCOMPONENTASSIGNMENT A, '||chr(10) 
           ||' ( '||chr(10)
           ||'     SELECT WORKERSERIAL, MAX(YEARMONTH) YEARMONTH '||chr(10)
           ||'     FROM PISCOMPONENTASSIGNMENT '||chr(10)
           ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
           ||'       AND YEARMONTH < '''||P_EFFECTYEARMONTH||''' '||chr(10)
           ||'       AND TRANSACTIONTYPE = ''ASSIGNMENT'' '||chr(10)
           ||'     GROUP BY WORKERSERIAL '||chr(10)
           ||' ) B '||CHR(10)
           ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
           ||'   AND A.TRANSACTIONTYPE = ''ASSIGNMENT'' '||chr(10)
           ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||chr(10)
           ||'   AND A.YEARMONTH = B.YEARMONTH '||chr(10)
           ||' ORDER BY A.YEARMONTH '||CHR(10);               
--        DBMS_OUTPUT.PUT_LINE('PISASSIGN: '||lv_SqlStr);
       insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
       values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_Remarks);
       EXECUTE IMMEDIATE lv_SqlStr;
       COMMIT;



    end if;

    if P_ViewName = 'PISCOMP' OR NVL(P_ViewName,'ALL') = 'ALL' then

        lv_Lday_Cols := '';
        FOR cLvCode in (
                        SELECT LEAVECODE FROM PISLEAVEMASTER WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                        INTERSECT
                        SELECT LTRIM(RTRIM(REPLACE(COLUMN_NAME,'LDAY_',''))) FROM COLS WHERE TABLE_NAME = 'PISPAYTRANSACTION' AND COLUMN_NAME LIKE 'LDAY_%' 
                       )
        loop
           lv_Lday_Cols := lv_Lday_Cols||'A.LDAY_'||cLvCode.LEAVECODE||','; 
        end loop;                         
        lv_Lday_Cols := SUBSTR(lv_Lday_Cols,1,LENGTH(lv_Lday_Cols)-1);
    
        lv_Remarks := 'VIEW - PISCOMP';
        lv_SqlStr := ' CREATE OR REPLACE VIEW PISCOMP '||CHR(10)
           ||' AS '||CHR(10)
           ||' SELECT A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, A.TOKENNO, A.YEARMONTH, '||CHR(10)
           ||' A.ATTN_SALD, A.ATTN_WRKD, A.ATTN_WPAY, A.ATTN_ADJD, A.ATTN_TOTD, ATTN_CALCF, A.ATTN_LDAY, A.ATTN_OFFD,'||lv_Lday_Cols||' /*A.LDAY_PL, A.LDAY_CL, A.LDAY_SL*/ '||CHR(10)
           ||' '||lv_PayComponent||' '||chr(10)
           ||' FROM '||lv_TableName||' A '||CHR(10)           -- PISPAYTRANSACTION
           ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
           ||'   AND A.YEARMONTH = '''||P_YEARMONTH||''' '||CHR(10)
           ||'   AND A.TRANSACTIONTYPE = '''||lv_ProcessType||''' '||CHR(10)            -- P_TRANTYPE REPLACE WITH lv_ProcessType
           ||' ORDER BY A.WORKERSERIAL '||CHR(10);
           --DBMS_OUTPUT.PUT_LINE('PISCOMP: '||lv_SqlStr);
       insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
       values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_Remarks);
       EXECUTE IMMEDIATE lv_SqlStr;
       COMMIT;
    end if;
    
    if P_ViewName = 'PISPREV' OR NVL(P_ViewName,'ALL') = 'ALL' then
        lv_Remarks := 'VIEW - PISPREV';
        lv_SqlStr := ' CREATE OR REPLACE VIEW PISPREV AS '||CHR(10)
                   ||' SELECT A.WORKERSERIAL, A.YEARMONTH, A.MISC_CF AS MISC_CF '||CHR(10)
                   ||' FROM PISPAYTRANSACTION A, '||CHR(10)
                   ||' ( '||CHR(10)
                   ||'   SELECT WORKERSERIAL, MAX(YEARMONTH) YEARMONTH '||CHR(10)
                   ||'   FROM PISPAYTRANSACTION '||CHR(10)
                   ||'   WHERE YEARMONTH < '''||P_YEARMONTH||''' '||CHR(10)
                   ||'   GROUP BY WORKERSERIAL '||CHR(10)
                   ||' ) B '||CHR(10)
                   ||' WHERE A.WORKERSERIAL = B.WORKERSERIAL AND A.YEARMONTH = B.YEARMONTH AND TRANSACTIONTYPE = ''SALARY'' '||CHR(10);
       insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
       values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_Remarks);
       EXECUTE IMMEDIATE lv_SqlStr;
       COMMIT;
    end if;    
exception
when others then
 lv_sqlerrm := sqlerrm ;
 insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
 values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
end;
/
