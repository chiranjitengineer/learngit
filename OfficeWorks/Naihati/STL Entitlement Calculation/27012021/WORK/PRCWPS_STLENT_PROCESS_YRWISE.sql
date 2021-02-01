CREATE OR REPLACE procedure NJMCL_WEB.PRCWPS_STLENT_PROCESS_YRWISE( P_COMPCODE varchar2, 
                                                       P_DIVCODE varchar2, 
                                                       P_YEAR varchar2, 
                                                       P_USER varchar2,
                                                       p_StandardSTLHours number,
                                                       p_AdjustmentSTLHours number default 0,
                                                       p_Workerserial varchar2 default null,
                                                       p_StandardSTLHours1 number default 1920,
                                                       p_HoursforOnedaySTL number default 160
                                                   )
as
lv_ProcName             varchar2(30):= 'prcWPS_STLENT_PROCESS_YRWISE';
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '';
lv_Remarks              varchar2(1000) := '';
lv_ParValues            varchar2(500) := '';
lv_SqlErrm              varchar2(500) := '';
lv_FNStartDate          date;
lv_FNEndDate            date;
lv_Cnt                  number:=0;
lv_PrevYear             varchar2(4); --2016
lv_B4PrevYear           varchar2(4); --2015
lv_PrevB4PrevYear       varchar2(4); --2014
lv_fn_stdt              date;
lv_fn_endt              date;
lv_Cur_fn_stdt              date;
lv_Cur_fn_endt              date;

lv_Yr_endt              date;
lv_YearCode             varchar2(10);
lv_Sql                  varchar2(10000);
lv_ApplicableStndhrs    number :=1920;
lv_ApplicableStndDays    number :=240;
lv_StndSTLDays          number :=Round(p_StandardSTLHours/8,0);
lv_AdjSTLDays           number :=0;

--EXEC  prcWPS_STLENT_PROCESS_YRWISE('NJ0001','0002','2020','SWT',1920, 0,'', 160 )
begin
    ---- FOLLOWING POINTS CONSIDER IN THIS PROCEDURE FOR STL ENTILEMENT CALCULATION --------
    ---- 1. Previous year STL consider in the same year in column prev. year STL 
    ---- 2. When wokrer join in the current calendar year then STL consider working days 20 in enverymonth.
    
    lv_result:='#SUCCESS#';
    lv_Remarks := 'STLENTITLE PROCESS';
    lv_PrevYear := substr(P_YEAR,1,2)|| to_number(substr(P_YEAR,3))-1;
    lv_B4PrevYear := substr(P_YEAR,1,2)|| to_number(substr(P_YEAR,3))-2;
    lv_PrevB4PrevYear := substr(P_YEAR,1,2)|| to_number(substr(P_YEAR,3))-3;
    
    lv_fn_stdt := to_date('01/01/'||lv_PrevYear,'DD/MM/YYYY');
    lv_fn_endt := to_date('15/01/'||lv_PrevYear,'DD/MM/YYYY');
    lv_Yr_endt := to_date('31/12/'||lv_PrevYear,'DD/MM/YYYY');
    
--    lv_fn_stdt := to_date('01/01/'||P_YEAR,'DD/MM/YYYY');
--    lv_fn_endt := to_date('15/01/'||P_YEAR,'DD/MM/YYYY');
--    lv_Yr_endt := to_date('31/12/'||P_YEAR,'DD/MM/YYYY');
    
    lv_Cur_fn_stdt := to_date('01/01/'||TO_CHAR(P_YEAR),'DD/MM/YYYY');
    lv_Cur_fn_endt := to_date('15/01/'||TO_CHAR(P_YEAR),'DD/MM/YYYY');
       
    lv_ApplicableStndhrs := p_StandardSTLHours - p_AdjustmentSTLHours;
    lv_ApplicableStndDays := (p_StandardSTLHours/8) - p_AdjustmentSTLHours;
    
    lv_ParValues := 'YEAR - '||P_YEAR||',STANDARD HRS - '||p_StandardSTLHours||', Adj Hrs - '||p_AdjustmentSTLHours;
        
    SELECT YEARCODE INTO lv_YearCode 
    FROM FINANCIALYEAR 
    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
    AND STARTDATE <= lv_fn_stdt AND ENDDATE >= lv_fn_stdt;

    lv_YearCode := P_YEAR;
    
    lv_sql := 'DELETE FROM WPSSTLTRANSACTION WHERE TRANSACTIONTYPE <>''OPENING'' AND FROMYEAR='||P_YEAR||' '||chr(10);
--    DBMS_OUTPUT.PUT_LINE (lv_Sql);
    
    execute immediate lv_Sql;
        

    lv_Sql := 'DELETE FROM WPSSTLENTITLEMENTCALCDETAILS '||chr(10) 
        ||' WHERE FORTNIGHTSTARTDATE='''||lv_Cur_fn_stdt||''' AND FORTNIGHTENDDATE='''||lv_Cur_fn_endt||''' '||chr(10);
    
--    DBMS_OUTPUT.PUT_LINE (lv_Sql);
    
    execute immediate lv_Sql;


    lv_Remarks := 'STL ENTITLEMENT CALCULATION PROCESS'; 
--    DBMS_OUTPUT.PUT_LINE ('1_1');


    lv_Sql := 'INSERT INTO WPSSTLENTITLEMENTCALCDETAILS'||CHR(10)
            ||' ( '||CHR(10)
            ||' COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, CATEGORYCODE, FROMYEAR, YEARCODE,'||CHR(10)
            ||' FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, DEPARTMENTCODE, SHIFTCODE,'||CHR(10)
            ||' ATTNHOURS, FESTHOURS, HOLIDAYHOURS, TOTALHOURS, STLHRSTAKEN, STLDAYSTAKEN,'||CHR(10)
            ||' STANDARDSTLHOURS, ADJUSTEDHOURS, APPLICABLESTANDHOURS, STLDAYS, STLHOURS, STLDAYS_BF,'||CHR(10)
            ||' TRANSACTIONTYPE, ADDLESS, USERNAME, LASTMODIFIED, SYSROWID,GRACEDAYS'||CHR(10)
            ||' )'||CHR(10)
            ||' SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, '''||lv_PrevYear||'''  FROMYEAR, '''||lv_YearCode||''' YEARCODE,'||CHR(10)
            ||' '''||lv_Cur_fn_stdt||''' FORTNIGHTSTARTDATE, '''||lv_Cur_fn_endt||''' FORTNIGHTENDDATE, DEPARTMENTCODE, ''1'' SHIFTCODE,'||CHR(10)
            ||' ATTN_HRS ATTNHOURS, 0 FESTHOURS, HOL_HRS HOLIDAYHOURS, (ELIGIBLE_HRS) TOTALHOURS, STL_HRS, STL_DAYS STLDAYSTAKEN,'||CHR(10)
            ||' STNDDAYS*8 STANDARDSTLHOURS, 0 ADJUSTEDHOURS, '||lv_ApplicableStndhrs||' APPLICABLESTANDHOURS, ENT_DAYS STLDAYS, ENT_DAYS*8 STLHOURS, PREV_ENT_STLDAYS STLDAYS_BF,'||CHR(10)
            ||' ''ENTITLEMENT'' TRANSACTIONTYPE, ''ADD'' ADDLESS, '''||P_USER||''' USERNAME, SYSDATE LASTMODIFIED, WORKERSERIAL||''-''||TO_CHAR(SYSDATE,''YYYYMMDDHHMISS'') SYSROWID,GRACEDAYS'||CHR(10)
            ||' FROM ('||CHR(10)
            ||'SELECT'||CHR(10)
            ||' B.COMPANYCODE, B.DIVISIONCODE, A.WORKERSERIAL, B.TOKENNO, B.WORKERCATEGORYCODE, B.DEPARTMENTCODE, B.TERMINATIONDATE,'||CHR(10)
            ||' SUM(PREV_STLDAYS) PREV_STLDAYS, SUM(PRV_STLHRS) PRV_STLHRS,'||CHR(10)
            ||' SUM(ATTN_HRS) ATTN_HRS, SUM(HOL_HRS) HOL_HRS, CASE WHEN SUM(STL_HRS) > 0 THEN case when (SUM(STL_HRS) - SUM(PRV_STLHRS_CALC)) > 0 then SUM(STL_HRS) - SUM(PRV_STLHRS_CALC) else 0 end ELSE 0 END STL_HRS,'||CHR(10)
            ||' SUM(ELIGIBLE_HRS) ELIGIBLE_HRS, SUM(ATTN_DAYS) ATTN_DAYS, SUM(STL_DAYS) STL_DAYS, SUM(HOL_DAYS) HOL_DAYS,'||CHR(10)
            ||' SUM(ELIGIBLE_DAYS) ELIGIBLE_DAYS, SUM(GRACEDAYS)  GRACEDAYS,'||CHR(10)
            ||' 0 PREV_ENT_STLDAYS,'||CHR(10)
            ||'     CASE WHEN B.TERMINATIONDATE IS  NULL THEN'||CHR(10)
            ||'         CASE WHEN SUM(ELIGIBLE_DAYS+NVL(GRACEDAYS,0)) >= '||lv_ApplicableStndDays||' THEN ROUND(SUM(FEWORKINGDAYS)/20,0) ELSE 0 END'||CHR(10)
            ||'          WHEN B.TERMINATIONDATE BETWEEN '''||lv_fn_stdt||'''  AND '''||lv_Yr_endt||''' AND SUM(ELIGIBLE_DAYS+NVL(GRACEDAYS,0)) >= '||lv_ApplicableStndDays||'-((TO_NUMBER(TO_CHAR(TERMINATIONDATE,''MM''))-TO_NUMBER(TO_CHAR(TO_DATE('''||lv_fn_stdt||''',''DD/MM/YYYY''),''MM'')-1))*'||  round(p_HoursforOnedaySTL/8) || ')  THEN'||CHR(10)
            ||'          ROUND(SUM(FEWORKINGDAYS)/20,0)'||CHR(10)
            ||'          ELSE 0'||CHR(10)
            ||'     END'||CHR(10)
            ||'     ENT_DAYS'||CHR(10)
            ||' , CASE WHEN B.TERMINATIONDATE IS  NULL  THEN '||lv_ApplicableStndDays||''||CHR(10)
            ||'        WHEN B.TERMINATIONDATE BETWEEN '''||lv_fn_stdt||'''  AND '''||lv_Yr_endt||''' THEN'||CHR(10)
            ||'        ((TO_NUMBER(TO_CHAR(TERMINATIONDATE,''MM''))-TO_NUMBER(TO_CHAR(TO_DATE('''||lv_fn_stdt||''',''DD/MM/YYYY''),''MM'')-1))*'||  round(p_HoursforOnedaySTL/8,2) || ')'||CHR(10)
            ||'        ELSE 0 END'||CHR(10)
            ||'        STNDDAYS'||CHR(10)
            ||' FROM ('||CHR(10)
            ||'         select WORKERSERIAL, SUM(PREV_STLDAYS) PREV_STLDAYS, SUM(PRV_STLHRS) PRV_STLHRS,'||CHR(10)
            ||'         SUM(PRV_STLHRS_CALC) PRV_STLHRS_CALC,SUM(ATTN_HRS) ATTN_HRS, SUM(HOL_HRS) HOL_HRS,'||CHR(10)
            ||'         SUM(STL_HRS) STL_HRS, SUM(STLENCASH_HRS) STLENCASH_HRS,'||CHR(10)
            ||'         SUM(ELIGIBLE_HRS) ELIGIBLE_HRS,'||CHR(10)
            ||'         ROUND(SUM(NVL(ATTN_HRS,0))/8,2) ATTN_DAYS,'||CHR(10)
            ||'         ROUND(SUM(NVL(STL_HRS,0))/8,2) STL_DAYS,'||CHR(10)
            ||'         ROUND(SUM(NVL(HOL_HRS,0))/8,2) HOL_DAYS,'||CHR(10)
            ||'         SUM(ELIGIBLE_DAYS) ELIGIBLE_DAYS ,'||CHR(10)
            ||'         SUM(FEWORKINGDAYS)FEWORKINGDAYS'||CHR(10)
            ||'         FROM ('||CHR(10)
            ||'                 SELECT WORKERSERIAL,  0 PREV_STLDAYS,  0 PRV_STLHRS,'||CHR(10)
            ||'                 0 PRV_STLHRS_CALC,SUM(NVL(ATTENDANCEHOURS,0)) ATTN_HRS, SUM(NVL(HOLIDAYHOURS,0)) HOL_HRS,'||CHR(10)
            ||'                 0 STL_HRS, 0 STLENCASH_HRS,'||CHR(10)
            ||'                 SUM(NVL(FEWORKINGDAYS*8,0))  ELIGIBLE_HRS,'||CHR(10)
            ||'                 ROUND(SUM(NVL(ATTENDANCEHOURS,0))/8,2) ATTN_DAYS,'||CHR(10)
            ||'                 0 STL_DAYS,'||CHR(10)
            ||'                 ROUND(SUM(NVL(HOLIDAYHOURS,0))/8,2) HOL_DAYS,'||CHR(10)
            ||'                 SUM(NVL(FEWORKINGDAYS,0)) ELIGIBLE_DAYS,'||CHR(10)
            ||'                 SUM(NVL(FEWORKINGDAYS,0)) FEWORKINGDAYS'||CHR(10)
            ||'                 FROM WPSWAGESDETAILS_MV A, WPSWORKERCATEGORYMAST B'||CHR(10)
            ||'                 WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''''||CHR(10)
            ||'                 AND A.FORTNIGHTSTARTDATE >= '''||lv_fn_stdt||''''||CHR(10)
            ||'                 AND A.FORTNIGHTENDDATE <= '''||lv_Yr_endt||''''||CHR(10)
            ||'                 AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE =  B.DIVISIONCODE'||CHR(10)
            ||'                 AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE'||CHR(10)
            ||'                 AND NVL(B.STLAPPLICABLE,''N'')=''Y'''||CHR(10)
            ||'                 GROUP BY A.WORKERSERIAL'||CHR(10)
            ||'                 UNION ALL'||CHR(10)
            ||'                 SELECT WORKERSERIAL, /*FORTNIGHTSTARTDATE, */ 0 PREV_STLDAYS,  0 PRV_STLHRS,'||CHR(10)
            ||'                 0 PRV_STLHRS_CALC,0 ATTN_HRS, 0 HOL_HRS,'||CHR(10)
            ||'                 SUM(NVL(STLHOURS,0)) STL_HRS, 0 STLENCASH_HRS,'||CHR(10)
            ||'                 SUM(NVL(STLHOURS,0)) ELIGIBLE_HRS,'||CHR(10)
            ||'                 0 ATTN_DAYS,'||CHR(10)
            ||'                  SUM(NVL(STLDAYS,0)) STL_DAYS,'||CHR(10)
            ||'                 0 HOL_DAYS,'||CHR(10)
            ||'                 SUM(NVL(STLDAYS,0)) ELIGIBLE_DAYS ,'||CHR(10)
            ||'                 0 FEWORKINGDAYS'||CHR(10)
            ||'                 FROM WPSSTLWAGESDETAILS A, WPSWORKERCATEGORYMAST B'||CHR(10)
            ||'                 WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''''||CHR(10)
            ||'                 AND A.PAYMENTDATE >= '''||lv_fn_stdt||''''||CHR(10)
            ||'                 AND A.PAYMENTDATE <= '''||lv_Yr_endt||''''||CHR(10)
            ||'                 AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE =  B.DIVISIONCODE'||CHR(10)
            ||'                 AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE'||CHR(10)
            ||'                 AND NVL(B.STLAPPLICABLE,''N'')=''Y'''||CHR(10)
            ||'                 GROUP BY A.WORKERSERIAL'||CHR(10)
            ||'             )'||CHR(10)
            ||'              GROUP BY WORKERSERIAL'||CHR(10)
            ||' ) A, WPSWORKERMAST B, WPSWORKERSTLGRACEPERIODDAYS C'||CHR(10)
            ||' WHERE B.COMPANYCODE = '''||P_COMPCODE||''' AND B.DIVISIONCODE = '''||P_DIVCODE||''''||CHR(10)
            ||' AND B.WORKERSERIAL = A.WORKERSERIAL AND B.WORKERSERIAL = C.WORKERSERIAL(+)'||CHR(10)
            ||' GROUP BY B.COMPANYCODE, B.DIVISIONCODE,A.WORKERSERIAL, B.TOKENNO, B.WORKERCATEGORYCODE, B.DEPARTMENTCODE,B.TERMINATIONDATE'||CHR(10)
            ||' )'||CHR(10);
 DBMS_OUTPUT.PUT_LINE (lv_Sql);
        
        
       
     INSERT INTO WPS_ERROR_LOG(PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS)
        VALUES (lv_ProcName, null, sysdate, lv_Sql, lv_ParValues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
          
     execute immediate lv_Sql;
     
     lv_Sql := ' INSERT INTO WPSSTLTRANSACTION'||chr(10)
             ||'  (COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, FROMYEAR, YEARCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, '||chr(10) 
             ||'  STLDAYS, STLHOURS, TRANSACTIONTYPE, ADDLESS, USERNAME, PREV_STLHRS, PREV_STLDAYS) '||chr(10)
             ||'  SELECT '''||P_COMPCODE||''' COMPANYCODE,'''||P_DIVCODE||''' DIVISIONCODE,WORKERSERIAL,TOKENNO,'''||P_YEAR||''','''||lv_YearCode||''' YEARCODE, '||chr(10) 
             ||'         FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, '||chr(10) 
             ||'        /*  STLDAYS, STLDAYS * 8 STLHOURS,*/ '||chr(10)
             ||'         CASE WHEN STLDAYS > 0 AND STLDAYS_BF < 0 THEN STLDAYS+STLDAYS_BF ELSE STLDAYS END STLDAYS, '||chr(10)
             ||'         CASE WHEN STLDAYS > 0 AND STLDAYS_BF < 0 THEN STLDAYS+STLDAYS_BF ELSE STLDAYS END * 8 STLHOURS, '||chr(10) 
             ||'        ''ENTITLEMENT'' TRANSACTIONTYPE,''ADD'' ADDLESS, '''||P_USER||''', '||chr(10)
             ||'        0 STLHRS_BF, '||chr(10)
             ||'        0 STLDAYS_BF '||chr(10)
             ||'        /*STLDAYS_BF * 8, STLDAYS_BF */ '||chr(10)
             ||'    FROM WPSSTLENTITLEMENTCALCDETAILS '||CHR(10)
             ||'    WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
             ||'      AND FORTNIGHTSTARTDATE = '''||lv_Cur_fn_stdt||''' AND FORTNIGHTENDDATE = '''||lv_Cur_fn_endt||''' '||chr(10)
             ||'      AND ( NVL(STLDAYS,0) > 0 OR NVL(STLDAYS_BF,0) <> 0) '||CHR(10); 
             --||'      AND (NVL(STLDAYS,0)+NVL(STLDAYS_BF,0)) > 0 '||chr(10);
     dbms_output.put_line(lv_Sql);
     lv_Remarks := 'WPSSTLTRANSACTION INSERT';
     INSERT INTO WPS_ERROR_LOG(PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS)
        VALUES (lv_ProcName, null, sysdate, lv_Sql, lv_ParValues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
     execute immediate lv_Sql;
    COMMIT;
    
    
    
EXCEPTION 
    WHEN OTHERS THEN
     lv_sqlerrm := sqlerrm ;
 --dbms_output.put_line(lv_sqlerrm);
    insert into WPS_ERROR_LOG(PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    values( lv_ProcName,lv_sqlerrm, sysdate, lv_Sql, lv_ParValues,lv_fn_stdt,lv_fn_endt, lv_Remarks);
 COMMIT;
        
end;
/
