CREATE OR REPLACE PROCEDURE BIRLANEW.PRC_GEN_LOAN_INT_CALC 
( 
    P_COMPCODE VARCHAR2, 
    P_DIVCODE VARCHAR2,
    P_USER    VARCHAR2,   
    P_LOANCODE VARCHAR2, 
    P_LOANDATE VARCHAR2, 
    P_AS_ON_DT VARCHAR2,
    P_MODULE    VARCHAR2 DEFAULT 'WPS',
    P_WAGESPROCESS VARCHAR2 DEFAULT 'YES',
    P_TEMPTABLE  varchar2 DEFAULT NULL,   
    P_CATEGORY  VARCHAR2 DEFAULT NULL,
    P_GRADE     VARCHAR2 DEFAULT NULL,
    P_TOKEN VARCHAR2 DEFAULT NULL
)
AS 
LV_YEARCODE     VARCHAR2(10) := '';
LV_YYYYMM       VARCHAR2(6) := '';
lv_LN_TRAN_REC    LOANTRANSACTION%ROWTYPE;
lv_LN_MAST_REC    LOANMASTER%ROWTYPE;   
LV_ASON_DATE    DATE := TO_DATE(P_AS_ON_DT,'DD/MM/YYYY');
LV_FN_STDT      DATE;
LV_FN_ENDT      DATE;
LV_MID_MONTH_DT DATE;
lv_LoanCode     VARCHAR2(10) := '';
LV_INTAMT_ALREADY_CALC  NUMBER(11,2) := 0;
lv_Sql          VARCHAR2(10000) := '';
lv_LNCAP_BAL NUMBER := 0;
lv_From_Day     number(2) := 0;
lv_To_Day       number(2) := 0;
lv_ProcName     varchar2(30) := 'PRC_GEN_LOAN_INT_CALC';
lv_Remarks      varchar2(100) := '';
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := ''; 
lv_ColName      varchar2(20) := '';    
lv_MasterTable  varchar2(30) := '';
lv_DaysIncrement    number(2) := 17;
lv_CalcFactor     number(2) := 1;
BEGIN
    --RETURN;
    LV_YYYYMM := TO_CHAR(LV_ASON_DATE,'YYYYMM');
    if substr(P_AS_ON_DT,4,2)='02' and substr(P_AS_ON_DT,1,2) > 15 then
        lv_DaysIncrement :=17;        
    end if;
    LV_MID_MONTH_DT :=TO_DATE('15/'||SUBSTR(P_AS_ON_DT,4,7),'DD/MM/YYYY');
    IF P_MODULE='WPS' THEN
        lv_MasterTable := 'WPSWORKERMAST';
        lv_CalcFactor := 24;
    ELSE
        lv_MasterTable := 'PISEMPLOYEEMASTER';
        lv_CalcFactor := 12;
    END IF;
    
    SELECT YEARCODE INTO LV_YEARCODE FROM FINANCIALYEAR
    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
      AND STARTDATE <= LV_ASON_DATE AND ENDDATE >= LV_ASON_DATE;
      
    IF P_MODULE ='WPS' THEN
--        SELECT TO_DATE(FN_GETFORTNIGHTSTARTENDDATE(P_AS_ON_DT, 'START'),'DD/MM/YYYY'), TO_DATE(FN_GETFORTNIGHTSTARTENDDATE(P_AS_ON_DT, 'END'),'DD/MM/YYYY')
--        INTO LV_FN_STDT,LV_FN_ENDT
--        FROM WPSWAGEDPERIODDECLARATION
--        WHERE COMPANYCODE =P_COMPCODE AND DIVISIONCODE = P_DIVCODE
--          AND FORTNIGHTSTARTDATE <= LV_ASON_DATE AND FORTNIGHTENDDATE >= LV_ASON_DATE;
        NULL;
    ELSE
        LV_FN_STDT := TO_DATE('01/'||SUBSTR(P_AS_ON_DT,4,7),'DD/MM/YYYY');
        LV_FN_ENDT := LAST_DAY(LV_ASON_DATE);
    END IF; 
    lv_From_Day := TO_NUMBER(to_char(LV_FN_STDT,'DD'));
    lv_To_Day := TO_NUMBER(to_char(LV_FN_ENDT,'DD'));

    PROC_LOANBLNC(P_COMPCODE, P_DIVCODE, P_AS_ON_DT,P_AS_ON_DT,P_LOANCODE, NULL,P_MODULE, P_WAGESPROCESS);
    
    for c1 in ( SELECT DISTINCT LOANCODE FROM LOANMASTER 
                WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE 
                AND INTERESTPERCENTAGE > 0)
    LOOP
        IF P_LOANCODE IS NOT NULL THEN
            IF P_LOANCODE <> c1.LOANCODE THEN
                GOTO NEXTROW;
            ELSE
                lv_LoanCode := c1.LOANCODE; 
            END IF;
        ELSE
            lv_LoanCode := c1.LOANCODE; 
        END IF;
        
         dbms_output.put_line(c1.LOANCODE||' : THIS IS TSING : '||lv_LoanCode);
        
        SELECT * INTO lv_LN_MAST_REC FROM LOANMASTER 
        WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE AND LOANCODE = lv_LoanCode;

        IF nvl(lv_LN_MAST_REC.INTERESTPERCENTAGE,0) <= 0 then
            return;             --- without interest percentage no need to calculate loan interest
        end if;

    --    SELECT * into lv_PFLN_TRAN_REC FROM LOANTRANSACTION 
    --    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE AND LOANCODE = P_LOANCODE; 
        
        lv_Sql := 'DELETE FROM LOANINTEREST '||chr(10) 
            ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
            ||'    AND FORTNIGHTSTARTDATE = '''||LV_FN_STDT||''' AND FORTNIGHTENDDATE = '''||LV_FN_ENDT||''' '||chr(10)
            ||'    AND LOANCODE = '''||lv_LoanCode||''' '||chr(10)
            ||'    AND MODULE = '''||P_MODULE||''' '||chr(10);
--        if NVL(P_CATEGORY,'SWT') <> 'SWT' THEN
--            lv_Sql := lv_Sql ||' AND WORKERSERIAL IN (SELECT WORKERSERIAL FROM '||lv_MasterTable||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' AND CATEGORYCODE = '''||P_CATEGORY||''')' ||CHR(10);
--            PISPAYTRANSACTION_SWT
--        END IF;  
        if P_MODULE = 'PIS' THEN
--            lv_Sql := lv_Sql ||' AND WORKERSERIAL IN (SELECT WORKERSERIAL FROM '||lv_MasterTable||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' AND CATEGORYCODE = '''||P_CATEGORY||''')' ||CHR(10);
            lv_Sql := lv_Sql ||' AND WORKERSERIAL IN (SELECT WORKERSERIAL FROM '||P_TEMPTABLE||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''') ' ||CHR(10);
        END IF;  

        lv_Remarks := 'DELETE LOAN INTEREST DATA'; 
        --dbms_output.put_line('query :'||lv_Sql);              
        execute immediate lv_Sql;
        IF P_MODULE='WPS' THEN
            insert into WPS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
            values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',SYSDATE,lv_Sql,lv_parvalues, LV_FN_STDT, LV_FN_ENDT,lv_Remarks );
        ELSE
            insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS )
            values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',SYSDATE,lv_Sql,lv_parvalues, LV_FN_STDT, LV_FN_ENDT,lv_Remarks );
        END IF;
        commit;

        IF nvl(lv_LN_MAST_REC.INTERESTTYPE,'F') = 'R' then
        
            lv_ColName := 'LOAN_'||lv_LoanCode;
            -- GLOSTER CALCULATE INTEREST BASED ON CAPITAL BALANCE AFTER CAPITAL FROM THE SALARY
            -- DUE TO SALARY PROCESS IN TEMPORARY TABLE CAPITAL SHOLUD DEDUCT FROM THE BALANE 
            IF P_WAGESPROCESS='YES' AND P_TEMPTABLE IS NOT NULL THEN
                NULL;
--                --dbms_OUTPUT.PUT_LINE ('TEMP TABLE : '||P_TEMPTABLE);
--                IF P_MODULE='WPS' THEN
--                    
--                    lv_Sql := 'UPDATE GBL_LOANBLNC A SET LOAN_BAL = LOAN_BAL- ( SELECT '||NVL(lv_ColName,0)||' FROM '||P_TEMPTABLE||' B '||chr(10) 
--                         ||'                                          WHERE B.COMPANYCODE = '''||P_COMPCODE||''' AND B.DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10) 
--                         ||'                                          AND B.FORTNIGHTSTARTDATE = '''||LV_FN_STDT||''' AND B.FORTNIGHTENDDATE = '''||LV_FN_ENDT||'''  '||chr(10)
--                         ||'                                          AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE  '||chr(10)
--                         ||'                                          AND A.WORKERSERIAL=B.WORKERSERIAL  '||chr(10)
--                         ||'                                        )     '||chr(10)
--                         ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
--                         ||' AND A.LOANCODE = '''||lv_LoanCode||'''  '||chr(10)
--                         ||' AND A.MODULE = '''||P_MODULE||'''  '||chr(10)
--                         ||' AND A.WORKERSERIAL IN (  SELECT WORKERSERIAL FROM '||P_TEMPTABLE||'  '||chr(10) 
--                         ||'                          WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
--                         ||'                            AND FORTNIGHTSTARTDATE = '''||LV_FN_STDT||''' AND FORTNIGHTENDDATE = '''||LV_FN_ENDT||'''  '||chr(10)
--                         ||'                            AND '||NVL(lv_ColName,0)||' > 0  '||chr(10)
--                         ||'                       ) '||chr(10);                                                      
--                ELSE
--                    lv_sql := ' UPDATE GBL_LOANBLNC A SET LOAN_BAL = LOAN_BAL - ( SELECT '||NVL(lv_ColName,0)||' FROM '||P_TEMPTABLE||' B '||chr(10) 
--                         ||'                                            WHERE B.COMPANYCODE = '''||P_COMPCODE||''' AND B.DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10) 
--                         ||'                                              AND B.YEARMONTH = TO_CHAR('''||LV_FN_ENDT||''',''YYYYMM'')  '||chr(10)
--                         ||'                                              AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||chr(10)
--                         ||'                                              AND A.WORKERSERIAL=B.WORKERSERIAL '||chr(10)
--                         ||'                                          )   '||chr(10)
--                         ||'          WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
--                         ||'            AND A.LOANCODE = '''||lv_LoanCode||''' '||chr(10)
--                         ||'             AND A.MODULE = '''||P_MODULE||''' '||chr(10)
--                         ||'             AND A.WORKERSERIAL IN (  SELECT WORKERSERIAL FROM '||P_TEMPTABLE||'  '||chr(10)  
--                         ||'                                      WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
--                         ||'                                        AND YEARMONTH = TO_CHAR('''||LV_FN_ENDT||''',''YYYYMM'')  '||chr(10)
--                         ||'                                        AND '||NVL(lv_ColName,0)||' > 0  '||chr(10)
--                         ||'                                   ) '||chr(10);                                                      
--                
--                END IF;
--                lv_Remarks := 'LOAN BALANCE UPDATE BASED ON DATA THORUGH WAGES PROCESS';
--                IF P_MODULE='WPS' THEN
--                    insert into WPS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
--                    values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',SYSDATE,lv_Sql,lv_parvalues, LV_FN_STDT, LV_FN_ENDT,lv_Remarks );
--                ELSE
--                    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS )
--                    values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',SYSDATE,lv_Sql,lv_parvalues, LV_FN_STDT, LV_FN_ENDT,lv_Remarks );
--                END IF;
--                execute immediate lv_Sql;                
                
            END IF;
            lv_Sql := ' INSERT INTO LOANINTEREST ( COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE,'||CHR(10) 
                ||' TOKENNO, WORKERSERIAL, LOANCODE, LOANDATE, LOANAMOUNT, INTERESTAPPLICABLEON, INTERESTPERCENTAGE, INTERESTAMOUNT, '||CHR(10) 
                ||' MODULE, TRANSACTIONTYPE, REMARKS, USERNAME, SYSROWID, LASTMODIFIED) '||CHR(10)
                ||' SELECT A.COMPANYCODE, A.DIVISIONCODE, '''||LV_YEARCODE||''' YEARCODE, '''||LV_YYYYMM||''' YEARMONTH, '''||LV_FN_STDT||''' FORTNIGHTSTARTDATE, '''||LV_FN_ENDT||''' FORTNIGHTENDDATE, '||CHR(10) 
                ||' A.TOKENNO, A.WORKERSERIAL, A.LOANCODE,A.LOANDATE, B.AMOUNT LOANAMOUNT, A.LOAN_BAL INTERESTAPPLICABLEON, '||CHR(10) 
                ||' '||NVL(lv_LN_MAST_REC.INTERESTPERCENTAGE,0)||' INTERESTPERCENTAGE, '||CHR(10)
                ||' CASE WHEN A.LOANDATE > '||LV_MID_MONTH_DT||' THEN '||CHR(10)
                ||'       ROUND((A.LOAN_BAL*'||(ROUND(NVL(lv_LN_MAST_REC.INTERESTPERCENTAGE,0),2)/lv_CalcFactor)||'*0.01)/2,0) '||CHR(10)
                ||' ELSE '||CHR(10)
                ||'       ROUND((A.LOAN_BAL*'||(ROUND(NVL(lv_LN_MAST_REC.INTERESTPERCENTAGE,0),2)/lv_CalcFactor)||'*0.01),0) '||CHR(10)    
                ||' END INTERESTAMOUNT,'||CHR(10)
                ||' '''||P_MODULE||''', ''ADD'' TRANSACTIONTYPE, ''INTEREST CHARGED THROUGH SYSTEM'' REMARKS, '''||P_USER||''' USERNAME, SYS_GUID() SYSROWID, SYSDATE LASTMODIFIED '||CHR(10)
                ||' FROM GBL_LOANBLNC A, LOANTRANSACTION B '||CHR(10);
        IF P_MODULE = 'PIS' THEN
                lv_Sql := lv_Sql||', '||P_TEMPTABLE||' C'||CHR(10);
        END IF;
                lv_Sql := lv_Sql||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                ||'   AND A.WORKERSERIAL = B.WORKERSERIAL AND A.LOANCODE = B.LOANCODE AND A.LOANDATE = B.LOANDATE '||CHR(10)
                ||'   AND A.LOANCODE ='''||lv_LoanCode||''' AND NVL(A.LOAN_BAL,0) > 0 '||CHR(10)
                ||'   AND A.MODULE='''||P_MODULE||''' '||CHR(10) ;
        IF P_MODULE = 'PIS' THEN
                lv_Sql := lv_Sql||'   AND A.WORKERSERIAL = C.WORKERSERIAL'||CHR(10);
        END IF;
            IF P_MODULE = 'WPS' THEN
--                lv_Sql := lv_Sql ||'   AND TO_NUMBER(TO_CHAR(NVL(B.FORTNIGHTSTARTDATE,A.LOANDATE)+17,''DD'')) BETWEEN '||lv_From_Day||' AND '||lv_To_Day||' '||chr(10);
                lv_Sql := lv_Sql ||'   AND TO_NUMBER(TO_CHAR(NVL(B.FORTNIGHTSTARTDATE,A.LOANDATE)+'||lv_DaysIncrement||',''DD'')) BETWEEN '||lv_From_Day||' AND '||lv_To_Day||' '||chr(10);
                
--            ELSE
            --- AS PER BIAKSH INTEREST CALCULATION EVERY MONTH , CONODER LOAN CALCULATE
--                IF LV_YYYYMM <> '202002' THEN
--                    lv_Sql := lv_Sql ||'   AND TO_CHAR(A.LOANDATE,''YYYYMM'') <>  '''||LV_YYYYMM||''' '||CHR(10);
--                END IF;        
            END IF;     
            if NVL(P_CATEGORY,'SWT') <> 'SWT' THEN
                lv_Sql := lv_Sql ||' AND A.WORKERSERIAL IN (SELECT WORKERSERIAL FROM '||lv_MasterTable||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' AND CATEGORYCODE = '''||P_CATEGORY||''')' ||CHR(10);
            END IF;  
            

        --ELSE
            ----- FOR FLAT RATE INTEREST NEED TO WRITE BELOW IN FUTURE -----
            ----- FOR REFERECE NEED TO CHECK THE PF LOAN INTEREST CALCULATION LOGIC -----
             
        END IF;
        lv_Remarks := 'REDUCTING BALANCE INTEREST CALCULATION';
        lv_parvalues := 'MODULE = '||P_MODULE||' , LOAN CODE = '||lv_LoanCode||'';

        ----dbms_output.put_line('Query : '||lv_Sql);
       execute immediate lv_Sql;
        IF P_MODULE='WPS' THEN
            insert into WPS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
            values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',SYSDATE,lv_Sql,lv_parvalues, LV_FN_STDT, LV_FN_ENDT,lv_Remarks );
        ELSE
            insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS )
            values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',SYSDATE,lv_Sql,lv_parvalues, LV_FN_STDT, LV_FN_ENDT,lv_Remarks );
        END IF;
        commit;
        
    <<NEXTROW>>
            lv_Loancode :='';
    END LOOP;
--exception
--when others then
-- lv_sqlerrm := sqlerrm ;
-- IF P_MODULE='WPS' THEN
--     insert into WPS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE, ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
--     values( P_COMPCODE, P_DIVCODE,lv_ProcName,lv_sqlerrm,SYSDATE, lv_Sql,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);    
-- ELSE
--     insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE, ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
--     values( P_COMPCODE, P_DIVCODE,lv_ProcName,lv_sqlerrm,SYSDATE, lv_Sql,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);    
-- END IF;   
END;
/
