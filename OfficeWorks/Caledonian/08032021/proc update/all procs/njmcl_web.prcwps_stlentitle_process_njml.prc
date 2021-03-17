DROP PROCEDURE NJMCL_WEB.PRCWPS_STLENTITLE_PROCESS_NJML;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.prcWPS_STLENTITLE_PROCESS_NJML( P_COMPCODE varchar2, 
                                                       P_DIVCODE varchar2, 
                                                       P_YEAR varchar2, 
                                                       P_USER varchar2,
                                                       p_StandardSTLHours number,
                                                       p_AdjustmentSTLHours number default 0,
                                                       p_Workerserial varchar2 default null,
                                                       p_HoursforOnedaySTL number default 160
                                                   )
as
lv_ProcName             varchar2(30):= 'prcWPS_STLENTITLE_PROCESS_NJML';
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
lv_StndSTLDays          number :=Round(p_StandardSTLHours/8,0);
lv_AdjSTLDays           number :=0;

--EXEC prcWPS_STLENTITLE_PROCESS_NJML('CJ0048','0003','2017','SWT',1920, 0,'', 160 )
begin
    ---- FOLLOWING POINTS CONSIDER IN THIS PROCEDURE FOR STL ENTILEMENT CALCULATION --------
    ---- 1. Previous year STL consider in the same year in column prev. year STL 
    ---- 2. When wokrer join in the current calendar year then STL consider working days 20 in enverymonth.
    
    lv_result:='#SUCCESS#';
    lv_Remarks := 'STLENTITLE PROCESS';
    lv_PrevYear := substr(P_YEAR,1,2)|| to_number(substr(P_YEAR,3))-1;
    lv_B4PrevYear := substr(P_YEAR,1,2)|| to_number(substr(P_YEAR,3))-2;
    lv_PrevB4PrevYear := substr(P_YEAR,1,2)|| to_number(substr(P_YEAR,3))-3;
    
    lv_fn_stdt := to_date('01/01/'||P_YEAR,'DD/MM/YYYY');
    lv_fn_endt := to_date('15/01/'||P_YEAR,'DD/MM/YYYY');
    lv_Yr_endt := to_date('31/12/'||P_YEAR,'DD/MM/YYYY');
    
    lv_Cur_fn_stdt := to_date('01/01/'||TO_CHAR(P_YEAR+1),'DD/MM/YYYY');
    lv_Cur_fn_endt := to_date('15/01/'||TO_CHAR(P_YEAR+1),'DD/MM/YYYY');
       
    lv_ApplicableStndhrs := p_StandardSTLHours - p_AdjustmentSTLHours;
    
    lv_ParValues := 'YEAR - '||P_YEAR||',STANDARD HRS - '||p_StandardSTLHours||', Adj Hrs - '||p_AdjustmentSTLHours;
        
    SELECT YEARCODE INTO lv_YearCode 
    FROM FINANCIALYEAR 
    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
    AND STARTDATE <= lv_fn_stdt AND ENDDATE >= lv_fn_stdt;

    lv_sql := 'DELETE FROM WPSSTLTRANSACTION WHERE TRANSACTIONTYPE <>''OPENING'' AND FROMYEAR='||P_YEAR||' '||chr(10);
--    DBMS_OUTPUT.PUT_LINE (lv_Sql);
    
    --execute immediate lv_Sql;
        

    lv_Sql := 'DELETE FROM WPSSTLENTITLEMENTCALCDETAILS '||chr(10) 
        ||' WHERE FORTNIGHTSTARTDATE='''||lv_Cur_fn_stdt||''' AND FORTNIGHTENDDATE='''||lv_Cur_fn_endt||''' '||chr(10);
    
--    DBMS_OUTPUT.PUT_LINE (lv_Sql);
    
    execute immediate lv_Sql;


    lv_Remarks := 'STL ENTITLEMENT CALCULATION PROCESS'; 
--    DBMS_OUTPUT.PUT_LINE ('1_1');

    lv_Sql := ' INSERT INTO WPSSTLENTITLEMENTCALCDETAILS ( '||CHR(10)
        ||' COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, CATEGORYCODE, FROMYEAR, YEARCODE, '||CHR(10) 
        ||' FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, DEPARTMENTCODE, SHIFTCODE, '||CHR(10) 
        ||' ATTNHOURS, FESTHOURS, HOLIDAYHOURS, TOTALHOURS, STLHRSTAKEN, STLDAYSTAKEN, '||CHR(10) 
        ||' STANDARDSTLHOURS, ADJUSTEDHOURS, APPLICABLESTANDHOURS, STLDAYS, STLHOURS, STLDAYS_BF, '||CHR(10) 
        ||' TRANSACTIONTYPE, ADDLESS, USERNAME, LASTMODIFIED, SYSROWID, STLHOURSTAKEN_CURYEAR) '||CHR(10)
        ||' SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, '''||TO_CHAR(P_YEAR)||''' FROMYEAR, '''||lv_YearCode||''' YEARCODE, '||CHR(10)
        ||' '''||lv_Cur_fn_stdt||''' FORTNIGHTSTARTDATE, '''||lv_Cur_fn_endt||''' FORTNIGHTENDDATE, DEPARTMENTCODE, ''1'' SHIFTCODE, '||CHR(10)
        ||' ATTN_HRS ATTNHOURS, 0 FESTHOURS, HOL_HRS HOLIDAYHOURS, (ATTN_HRS) TOTALHOURS, STL_HRS, STL_DAYS STLDAYSTAKEN, '||CHR(10)
        ||' STNDHRS STANDARDSTLHOURS, '||p_AdjustmentSTLHours||' ADJUSTEDHOURS, '||lv_ApplicableStndhrs||' APPLICABLESTANDHOURS, ENT_DAYS STLDAYS, ENT_DAYS*8 STLHOURS, PREV_ENT_STLDAYS STLDAYS_BF, '||CHR(10);
 --    DBMS_OUTPUT.PUT_LINE ('1_2');        
     lv_Sql := lv_Sql ||' ''ENTITLEMENT'' TRANSACTIONTYPE, ''ADD'' ADDLESS, '''||P_USER||''' USERNAME, SYSDATE LASTMODIFIED, WORKERSERIAL||''-''||TO_CHAR(SYSDATE,''YYYYMMDDHHMISS'') SYSROWID '||CHR(10)
        ||' , 0 STLHOURSTAKEN_CURYEAR '||CHR(10) 
        ||' FROM ( '||CHR(10)
        ||' SELECT B.COMPANYCODE, B.DIVISIONCODE, A.WORKERSERIAL, B.TOKENNO, B.WORKERCATEGORYCODE, B.DEPARTMENTCODE, B.DATEOFJOINING, '||CHR(10)
        ||' SUM(PREV_STLDAYS) PREV_STLDAYS, SUM(PRV_STLHRS) PRV_STLHRS, '||CHR(10)
        ||' SUM(ATTN_HRS) ATTN_HRS, SUM(HOL_HRS) HOL_HRS, CASE WHEN SUM(STL_HRS) > 0 THEN case when (SUM(STL_HRS) - SUM(PRV_STLHRS_CALC)) > 0 then SUM(STL_HRS) - SUM(PRV_STLHRS_CALC) else 0 end ELSE 0 END STL_HRS, '||CHR(10)
        ||' SUM(ELIGIBLE_HRS) ELIGIBLE_HRS, SUM(ATTN_DAYS) ATTN_DAYS, SUM(STL_DAYS) STL_DAYS, SUM(HOL_DAYS) HOL_DAYS, '||CHR(10) 
        ||' SUM(ELIGIBLE_DAYS) ELIGIBLE_DAYS, '||CHR(10)
        ||' CASE WHEN SUM(STLENCASH_HRS)> 0 THEN 0 ELSE SUM(PREV_STLDAYS) - SUM(STL_DAYS) END PREV_ENT_STLDAYS, '||CHR(10)
        ||' CASE WHEN SUM(STLENCASH_HRS) > 0 THEN 0 '||CHR(10)
        ||' ELSE '||CHR(10) 
        ||'     CASE WHEN B.DATEOFJOINING <= '''||lv_fn_stdt||''' THEN '||CHR(10) 
        ||'         CASE WHEN SUM(ELIGIBLE_HRS) >='||p_StandardSTLHours||' THEN ROUND(SUM(ATTN_DAYS)/20,0) ELSE 0 END '||CHR(10)
        ||'     ELSE CASE WHEN SUM(ELIGIBLE_HRS) >= '||p_StandardSTLHours||' - ((TO_NUMBER(TO_CHAR(DATEOFJOINING,''MM''))-1)*'||  p_HoursforOnedaySTL || ') THEN ROUND(SUM(ATTN_DAYS)/20,0) '||CHR(10)
        ||'             ELSE 0 END '||CHR(10)
        ||'     END '||CHR(10)
        ||' END ENT_DAYS '||CHR(10)
        ||' , CASE WHEN B.DATEOFJOINING <= '''||lv_fn_stdt||''' THEN '||p_StandardSTLHours||' '||CHR(10)
        ||'        ELSE  ((12-TO_NUMBER(TO_CHAR(DATEOFJOINING,''MM'')))*'|| p_HoursforOnedaySTL || ') END STNDHRS '||CHR(10)
        ||' FROM (  '||CHR(10)
        ||'        select WORKERSERIAL, SUM(PREV_STLDAYS) PREV_STLDAYS, SUM(PRV_STLHRS) PRV_STLHRS, '||CHR(10) 
        ||'         SUM(PRV_STLHRS_CALC) PRV_STLHRS_CALC,SUM(ATTN_HRS) ATTN_HRS, SUM(HOL_HRS) HOL_HRS,  '||CHR(10) 
        ||'         SUM(STL_HRS) STL_HRS, SUM(STLENCASH_HRS) STLENCASH_HRS,'||CHR(10)
        ||'         (SUM(NVL(ATTN_HRS,0)) + (CASE WHEN SUM(STL_HRS) > 0 THEN CASE WHEN  (SUM(STL_HRS)- SUM(PRV_STLHRS_CALC)) > 0 THEN (SUM(STL_HRS)- SUM(PRV_STLHRS_CALC)) ELSE 0 END ELSE 0 END)) ELIGIBLE_HRS,  '||CHR(10) 
        ||'         ROUND(SUM(NVL(ATTN_HRS,0))/8,2) ATTN_DAYS,  '||CHR(10)
        ||'         ROUND(SUM(NVL(STL_HRS,0))/8,2) STL_DAYS,  '||CHR(10)
        ||'         ROUND(SUM(NVL(HOL_HRS,0))/8,2) HOL_DAYS,  '||CHR(10)
        ||'         ROUND((SUM(NVL(ATTN_HRS,0)) + (CASE WHEN  (SUM(STL_HRS)- SUM(PRV_STLHRS_CALC)) > 0 THEN (SUM(STL_HRS)- SUM(PRV_STLHRS_CALC)) ELSE 0 END ))/8,2) ELIGIBLE_DAYS  '||CHR(10)
        ||'         FROM (  '||CHR(10) 
        ||'                 SELECT WORKERSERIAL, /*FORTNIGHTSTARTDATE, */ 0 PREV_STLDAYS,  0 PRV_STLHRS, '||CHR(10)
        ||'                 0 PRV_STLHRS_CALC,SUM(NVL(ATTENDANCEHOURS,0)) ATTN_HRS, SUM(NVL(HOLIDAYHOURS,0)) HOL_HRS, '||CHR(10)
        ||'                 SUM(NVL(STLHOURS,0)+NVL(STLHOURS_ENCASH,0)) STL_HRS, SUM(NVL(STLHOURS_ENCASH,0)) STLENCASH_HRS, '||CHR(10)
        ||'                 SUM(NVL(ATTENDANCEHOURS,0)) + SUM(NVL(STLHOURS,0)+NVL(STLHOURS_ENCASH,0)) ELIGIBLE_HRS, '||CHR(10)
        ||'                 ROUND(SUM(NVL(ATTENDANCEHOURS,0))/8,2) ATTN_DAYS, '||CHR(10) 
        ||'                 ROUND(SUM(NVL(STLHOURS,0)+NVL(STLHOURS_ENCASH,0))/8,2) STL_DAYS, '||CHR(10)
        ||'                 ROUND(SUM(NVL(HOLIDAYHOURS,0))/8,2) HOL_DAYS, '||CHR(10)
        ||'                 round((SUM(NVL(ATTENDANCEHOURS,0) + NVL(STLHOURS,0)+NVL(STLHOURS_ENCASH,0)))/8,2) ELIGIBLE_DAYS '||CHR(10)
        ||'                 FROM WPSWAGESDETAILS_MV A, WPSWORKERCATEGORYMAST B '||CHR(10)  
        ||'                 WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||'                 AND A.FORTNIGHTSTARTDATE >= '''||lv_fn_stdt||''' '||CHR(10)
        ||'                 AND A.FORTNIGHTENDDATE <= '''||lv_Yr_endt||''' '||CHR(10)
        ||'                 AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE =  B.DIVISIONCODE '||CHR(10)
        ||'                 AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE '||CHR(10)
        ||'                 AND NVL(B.STLAPPLICABLE,''N'')=''Y'' '||CHR(10)
        ||'                 GROUP BY A.WORKERSERIAL/*, A.FORTNIGHTSTARTDATE */'||CHR(10)
        ||'                 UNION ALL '||CHR(10)
        ||'                 SELECT WORKERSERIAL, /*FORTNIGHTSTARTDATE,*/ SUM(NVL(STLDAYS,0)+NVL(PREV_STLDAYS,0)) PREV_STLDAYS, SUM(NVL(STLHOURS,0)+NVL(PREV_STLHRS,0)) PRV_STLHRS, '||CHR(10)
        ||'                 SUM(NVL(PREV_STLHRS,0)) PRV_STLHRS_CALC  ,0 ATTN_HRS, 0 HOL_HRS, 0 STL_HRS, 0 STLENCASH_HRS, '||CHR(10) 
        ||'                 0 ELIGIBLE_HRS, 0 ATTN_DAYS, 0 STL_DAYS, 0 HOL_DAYS, 0 ELIGIBLE_DAYS '||CHR(10)
        ||'                 FROM WPSSTLTRANSACTION '||CHR(10)
        ||'                 WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||'                 AND FORTNIGHTSTARTDATE >= '''||lv_fn_stdt||''' '||CHR(10)
        ||'                 AND FORTNIGHTENDDATE <= '''||lv_fn_endt||''' '||CHR(10)
        ||'                 GROUP BY WORKERSERIAL/*, FORTNIGHTSTARTDATE */'||CHR(10)
        ||'             ) GROUP BY WORKERSERIAL '||CHR(10)
        ||' ) A, WPSWORKERMAST B '||CHR(10)
        ||' WHERE B.COMPANYCODE = '''||P_COMPCODE||''' AND B.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||' /*AND B.ACTIVE=''Y'' */'||CHR(10)
        ||' AND B.WORKERSERIAL = A.WORKERSERIAL '||CHR(10)    
        ||' GROUP BY B.COMPANYCODE, B.DIVISIONCODE,A.WORKERSERIAL, B.TOKENNO, B.WORKERCATEGORYCODE, B.DEPARTMENTCODE,B.DATEOFJOINING '||CHR(10)        
        ||' ) '||CHR(10);

 DBMS_OUTPUT.PUT_LINE (lv_Sql);
        
         lv_Sql := '          INSERT INTO WPSSTLENTITLEMENTCALCDETAILS '||CHR(10)
                 ||'          ('||CHR(10)
                 ||'            COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, CATEGORYCODE, FROMYEAR, YEARCODE,'||CHR(10)
                 ||'            FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, DEPARTMENTCODE, SHIFTCODE,'||CHR(10)
                 ||'            ATTNHOURS, FESTHOURS, HOLIDAYHOURS, TOTALHOURS, STLHRSTAKEN, STLDAYSTAKEN,'||CHR(10)
                 ||'            STANDARDSTLHOURS, ADJUSTEDHOURS, APPLICABLESTANDHOURS, STLDAYS, STLHOURS, STLDAYS_BF,'||CHR(10)
                 ||'            TRANSACTIONTYPE, ADDLESS, USERNAME, LASTMODIFIED, SYSROWID'||CHR(10)
                 ||'          )'||CHR(10)
                 ||'         SELECT B.COMPANYCODE, B.DIVISIONCODE, B.WORKERSERIAL, B.TOKENNO, B.WORKERCATEGORYCODE, '''||TO_CHAR(P_YEAR)||''' FROMYEAR,'''||lv_YearCode||''' YEARCODE,'||CHR(10)
                 ||'                '''||lv_Cur_fn_stdt||''' FORTNIGHTSTARTDATE, '''||lv_Cur_fn_endt||''' FORTNIGHTENDDATE,B.DEPARTMENTCODE,''1'' SHIFTCODE,'||CHR(10)
                 ||'                SUM(ATTN_HRS)ATTN_HRS,0 FESTHOURS,SUM(HOL_HRS)HOL_HRS,SUM(ELIGIBLE_HRS)TOTALHOURS,SUM(STL_HRS)STL_HRS,SUM(STL_DAYS)STL_DAYS,'||CHR(10)
                 ||'                CASE WHEN B.DATEOFJOINING <= '''||lv_fn_stdt||''' THEN '||p_StandardSTLHours||''||CHR(10)
                 ||'                ELSE  ((12-TO_NUMBER(TO_CHAR( B.DATEOFJOINING,''MM'')))*'|| p_HoursforOnedaySTL || ') END STNDHRS ,0 ADJUSTEDHOURS,'||lv_ApplicableStndhrs||' APPLICABLESTANDHOURS,'||CHR(10)
                 ||'                SUM(STL_DAYS)STLDAYS,SUM(STL_HRS)STLHOURS,0 STLDAYS_BF,'||CHR(10)
                 ||'                ''ENTITLEMENT'' TRANSACTIONTYPE, ''ADD'' ADDLESS, '''||P_USER||''' USERNAME, SYSDATE LASTMODIFIED,'||CHR(10)
                 ||'                 B.WORKERSERIAL||''-''||TO_CHAR(SYSDATE,''YYYYMMDDHHMISS'') SYSROWID'||CHR(10)
                 ||'--                SUM(PREV_STLDAYS)PREV_STLDAYS,SUM(PRV_STLHRS)PRV_STLHRS,'||CHR(10)
                 ||'--                SUM(PRV_STLHRS_CALC)PRV_STLHRS_CALC'||CHR(10)
                 ||'--                ,SUM(STLENCASH_HRS)STLENCASH_HRS,'||CHR(10)
                 ||'--                SUM(ATTN_DAYS)ATTN_DAYS,SUM(HOL_DAYS)HOL_DAYS'||CHR(10)
                 ||'--               SUM(ELIGIBLE_HRS)ELIGIBLE_HRS,SUM(ELIGIBLE_DAYS)ELIGIBLE_DAYS'||CHR(10)
                 ||'                FROM('||CHR(10)
                 ||'                     SELECT WORKERSERIAL,  0 PREV_STLDAYS,  0 PRV_STLHRS,'||CHR(10)
                 ||'                     0 PRV_STLHRS_CALC,SUM(NVL(ATTENDANCEHOURS,0)) ATTN_HRS, SUM(NVL(HOLIDAYHOURS,0)) HOL_HRS,'||CHR(10)
                 ||'                     0 STL_HRS, 0 STLENCASH_HRS,'||CHR(10)
                 ||'                     ROUND(SUM(NVL(ATTENDANCEHOURS,0))/8,2) ATTN_DAYS,'||CHR(10)
                 ||'                     0 STL_DAYS,'||CHR(10)
                 ||'                     ROUND(SUM(NVL(HOLIDAYHOURS,0))/8,2) HOL_DAYS,'||CHR(10)
                 ||'                     SUM(NVL(FEWORKINGDAYS,0)*8) ELIGIBLE_HRS,'||CHR(10)
                 ||'                     SUM(NVL(FEWORKINGDAYS,0)) ELIGIBLE_DAYS,'||CHR(10)
                 ||'                     SUM(NVL(FEWORKINGDAYS,0)) STLELIGIBLEDAYS'||CHR(10)
                 ||'                     FROM WPSWAGESDETAILS_MV A, WPSWORKERCATEGORYMAST B '||CHR(10)
                 ||'                     WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''''||CHR(10)
                 ||'                     AND A.FORTNIGHTSTARTDATE >= '''||lv_fn_stdt||''''||CHR(10)
                 ||'                     AND A.FORTNIGHTENDDATE <= '''||lv_Yr_endt||''''||CHR(10)
                 ||'                     AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE =  B.DIVISIONCODE '||CHR(10)
                 ||'                     AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE'||CHR(10)
                 ||'                     AND NVL(B.STLAPPLICABLE,''N'')=''Y'''||CHR(10)
                 ||'                     GROUP BY A.WORKERSERIAL'||CHR(10)
                 ||'                     UNION ALL'||CHR(10)
                 ||'                     SELECT WORKERSERIAL,  0 PREV_STLDAYS,  0 PRV_STLHRS,'||CHR(10)
                 ||'                     0 PRV_STLHRS_CALC,0 ATTN_HRS, 0 HOL_HRS,'||CHR(10)
                 ||'                     SUM(NVL(STLHOURS,0)) STL_HRS, 0 STLENCASH_HRS,'||CHR(10)
                 ||'                     0 ATTN_DAYS,'||CHR(10)
                 ||'                     SUM(NVL(STLDAYS,0)) STL_DAYS,'||CHR(10)
                 ||'                     0 HOL_DAYS,'||CHR(10)
                 ||'                     SUM(NVL(STLHOURS,0)) ELIGIBLE_HRS,'||CHR(10)
                 ||'                     SUM(NVL(STLDAYS,0)) ELIGIBLE_DAYS,'||CHR(10)
                 ||'                     0 STLELIGIBLEDAYS'||CHR(10)
                 ||'                     FROM WPSSTLWAGESDETAILS A, WPSWORKERCATEGORYMAST B'||CHR(10)
                 ||'                     WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''''||CHR(10)
                 ||'                     AND A.PAYMENTDATE >= '''||lv_fn_stdt||''''||CHR(10)
                 ||'                     AND A.PAYMENTDATE <= '''||lv_Yr_endt||''''||CHR(10)
                 ||'                     AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE =  B.DIVISIONCODE'||CHR(10)
                 ||'                     AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE'||CHR(10)
                 ||'                     AND NVL(B.STLAPPLICABLE,''N'')=''Y'''||CHR(10)
                 ||'                     GROUP BY A.WORKERSERIAL'||CHR(10)
                 ||'                )A, WPSWORKERMAST B'||CHR(10)
                 ||'                WHERE B.COMPANYCODE = '''||P_COMPCODE||''' AND B.DIVISIONCODE = '''||P_DIVCODE||''''||CHR(10)
                 ||'                AND B.WORKERSERIAL = A.WORKERSERIAL'||CHR(10)
                 ||'                GROUP BY B.COMPANYCODE, B.DIVISIONCODE, B.WORKERSERIAL, B.TOKENNO, B.WORKERCATEGORYCODE, B.DEPARTMENTCODE, B.DATEOFJOINING'||CHR(10)
                 ||'                HAVING (SUM(ELIGIBLE_DAYS)+'||p_AdjustmentSTLHours||')>('||lv_StndSTLDays||')'||CHR(10);
        
        
         
     DBMS_OUTPUT.PUT_LINE (lv_Sql);
       
     INSERT INTO WPS_ERROR_LOG(PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS)
        VALUES (lv_ProcName, null, sysdate, lv_Sql, lv_ParValues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
          
     execute immediate lv_Sql;
     
     lv_Sql := ' INSERT INTO WPSSTLTRANSACTION_0912  '||chr(10)
             ||'  (COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, FROMYEAR, YEARCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, '||chr(10) 
             ||'  STLDAYS, STLHOURS, TRANSACTIONTYPE, ADDLESS, USERNAME, PREV_STLHRS, PREV_STLDAYS) '||chr(10)
             ||'  SELECT '''||P_COMPCODE||''' COMPANYCODE,'''||P_DIVCODE||''' DIVISIONCODE,WORKERSERIAL,TOKENNO,'''||P_YEAR||''','''||lv_YearCode||''' YEARCODE, '||chr(10) 
             ||'         FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, '||chr(10) 
             ||'        /*  STLDAYS, STLDAYS * 8 STLHOURS,*/ '||chr(10)
             ||'         CASE WHEN STLDAYS > 0 AND STLDAYS_BF < 0 THEN STLDAYS+STLDAYS_BF ELSE STLDAYS END STLDAYS, '||chr(10)
             ||'         CASE WHEN STLDAYS > 0 AND STLDAYS_BF < 0 THEN STLDAYS+STLDAYS_BF ELSE STLDAYS END * 8 STLHOURS, '||chr(10) 
             ||'        ''ENTITLEMENT'' TRANSACTIONTYPE,''ADD'' ADDLESS, '''||P_USER||''', '||chr(10)
             ||'        CASE WHEN STLDAYS > 0 AND STLDAYS_BF < 0 THEN 0 ELSE STLDAYS_BF END *8 STLHRS_BF, '||chr(10)
             ||'        CASE WHEN STLDAYS > 0 AND STLDAYS_BF < 0 THEN 0 ELSE STLDAYS_BF END STLDAYS_BF '||chr(10)
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


