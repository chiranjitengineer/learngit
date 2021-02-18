CREATE OR REPLACE PROCEDURE INFRA_WPS.PRC_WPSATTNINCENTIVE_UPDATE (P_COMPCODE Varchar2, 
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
lv_Sql_TblCreate    varchar2(3000) := '';  
lv_sqlerrm      varchar2(1000) := ''; 
lv_remarks      varchar2(1000) := '';
lv_parvalues    varchar2(1000) := '';
lv_SqlTemp      varchar2 (2000) := '';
lv_Cols         varchar2 (1000) := '';
lv_fn_stdt      date := to_date(P_FNSTDT,'DD/MM/YYYY');
lv_fn_endt      date := to_date(P_FNENDT,'DD/MM/YYYY');
lv_NoOfDays     number(5) := 0;
lv_ProcName     varchar2(100) :='PRC_WPSATTNINCENTIVE_UPDATE';

/*  Add NAPP on 29/04/2019 Ref. mail dated 22/04/2019 */

begin

    SELECT (TO_DATE(P_FNENDT,'DD/MM/YYYY') - TO_DATE(P_FNSTDT,'DD/MM/YYYY')+1) INTO lv_NoOfDays FROM  DUAL; 
    DELETE FROM GBL_ATTNINCENTIVE;
    
    LV_REMARKS := ' TEMP TABLE CREATION FOR WORKERWISE NO. OF WORKING DAYS';
    
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE ATTN_INCENTIVEDAYS_SWT';
    EXCEPTION WHEN OTHERS THEN 
        NULL;            
    END;
    
    lv_Sql := ' CREATE TABLE ATTN_INCENTIVEDAYS_SWT AS ' || CHR(10)
        ||' SELECT WORKERSERIAL,TOKENNO,WORKERCATEGORYCODE,DATEOFATTENDANCE '||CHR(10)
        ||' FROM WPSATTENDANCEDAYWISE '||CHR(10)
        ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||'   AND YEARCODE = '''||P_YEARCODE||'''   '||CHR(10) 
        ||'   AND DATEOFATTENDANCE>=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'') '||CHR(10)
        ||'   AND DATEOFATTENDANCE<=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') '||CHR(10)
        ||'   AND DEPARTMENTCODE IN (''24'',''25'',''26'',''35'') '||CHR(10)
        ||'   AND WORKERCATEGORYCODE in(''LRNR'',''NAPP'')  '||CHR(10)
        ||' GROUP BY WORKERSERIAL,TOKENNO,DATEOFATTENDANCE,WORKERCATEGORYCODE  '||CHR(10)
        ||' HAVING SUM(NVL(ATTENDANCEHOURS,0))>=8  '||CHR(10)
        ||' UNION ALL  '||CHR(10)
        ||' SELECT WORKERSERIAL,TOKENNO,WORKERCATEGORYCODE,DATEOFATTENDANCE '||CHR(10)
        ||' FROM WPSATTENDANCEDAYWISE '||CHR(10)
        ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||'   AND YEARCODE = '''||P_YEARCODE||'''   '||CHR(10) 
        ||'   AND DATEOFATTENDANCE>=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'') '||CHR(10)
        ||'   AND DATEOFATTENDANCE<=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') '||CHR(10)
        ||'   AND DEPARTMENTCODE IN (''24'',''25'',''26'',''35'') '||CHR(10)
        ||'   AND WORKERCATEGORYCODE in( ''LRNR'' ,''NAPP'') '||CHR(10)
        ||' GROUP BY WORKERSERIAL,TOKENNO,DATEOFATTENDANCE,WORKERCATEGORYCODE  '||CHR(10)
        ||' HAVING SUM(NVL(ATTENDANCEHOURS,0))=0  AND SUM(NVL(OVERTIMEHOURS,0))>=8 '||CHR(10);
        
    INSERT INTO WPS_ERROR_LOG ( PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) VALUES (lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);
    EXECUTE IMMEDIATE lv_Sql;
        
-----------------    
--    lv_Sql := 'INSERT INTO GBL_ATTNINCENTIVE SELECT WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, DEPARTMENTCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, '||chr(10)
--        ||' FIXEDBASIC,DARATE,NOOFDAYS, ROUND((NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26,2) PERDAY_RATE, '||chr(10)
--        ||' CASE WHEN WORKERCATEGORYCODE = ''LRNR'' AND 16 > '||lv_NoOfDays||' AND NOOFDAYS >= 10 THEN NOOFDAYS*70 '||chr(10)
--        ||'      WHEN WORKERCATEGORYCODE = ''LRNR'' AND 16 = '||lv_NoOfDays||'  AND NOOFDAYS >= 11 THEN NOOFDAYS*70 '||chr(10)
--        ||'      WHEN WORKERCATEGORYCODE IN( ''BCTG'',''NBCT'') AND NOOFDAYS >= 12 AND ROUND((NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26,2) < 375 THEN ROUND((375 - (NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26) * NOOFDAYS,2) '||chr(10)
--        ||'      WHEN WORKERCATEGORYCODE IN( ''BCTG'',''NBCT'') AND 16 > '||lv_NoOfDays||'  AND NOOFDAYS >= 10 AND ROUND((NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26,2) < 350 THEN ROUND((350 - (NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26) * NOOFDAYS,2) '||chr(10)
--        ||'      WHEN WORKERCATEGORYCODE IN( ''BCTG'',''NBCT'') AND 16 = ' ||lv_NoOfDays||' AND NOOFDAYS >= 11 AND ROUND((NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26,2) < 350 THEN ROUND((350 - (NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26) * NOOFDAYS ,2) '||chr(10)        
--        ||' END ATTN_INCENTIVE  '||chr(10)       
--        ||' FROM (  '||chr(10) 
--        ||'         SELECT A.WORKERSERIAL,A.TOKENNO,A.WORKERCATEGORYCODE,B.DEPARTMENTCODE,  '||chr(10)
--        ||'                 TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'') FORTNIGHTSTARTDATE,TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') FORTNIGHTENDDATE, '||chr(10)
--        ||'                 FIXEDBASIC,DARATE, '||CHR(10)
--        ||'                 COUNT(DATEOFATTENDANCE) NOOFDAYS '||CHR(10)
--        ||'            FROM ( '||CHR(10)
--        ||'                    SELECT WORKERSERIAL,TOKENNO,WORKERCATEGORYCODE,DATEOFATTENDANCE '||CHR(10)
--        ||'                      FROM WPSATTENDANCEDAYWISE '||CHR(10)
--        ||'                      WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
--        ||'                        AND YEARCODE = '''||P_YEARCODE||'''   '||CHR(10) 
--        ||'                        AND DATEOFATTENDANCE>=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'') '||CHR(10)
--        ||'                        AND DATEOFATTENDANCE<=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') '||CHR(10)
--        ||'                        AND DEPARTMENTCODE IN (''24'',''25'',''26'') '||CHR(10)
--        ||'                        AND WORKERCATEGORYCODE IN (''LRNR'',''BCTG'',''NBCT'')  '||CHR(10)
--        ||'                     GROUP BY WORKERSERIAL,TOKENNO,DATEOFATTENDANCE,WORKERCATEGORYCODE  '||CHR(10)
--        ||'                     HAVING SUM(NVL(ATTENDANCEHOURS,0))>=8  '||CHR(10)
--        ||'                    UNION ALL  '||CHR(10)
--        ||'                    SELECT WORKERSERIAL,TOKENNO,WORKERCATEGORYCODE,DATEOFATTENDANCE '||CHR(10)
--        ||'                      FROM WPSATTENDANCEDAYWISE '||CHR(10)
--        ||'                      WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
--        ||'                        AND YEARCODE = '''||P_YEARCODE||'''   '||CHR(10) 
--        ||'                        AND DATEOFATTENDANCE>=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'') '||CHR(10)
--        ||'                        AND DATEOFATTENDANCE<=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') '||CHR(10)
--        ||'                        AND DEPARTMENTCODE IN (''24'',''25'',''26'') '||CHR(10)
--        ||'                        AND WORKERCATEGORYCODE IN (''LRNR'',''BCTG'',''NBCT'')  '||CHR(10)
--        ||'                     GROUP BY WORKERSERIAL,TOKENNO,DATEOFATTENDANCE,WORKERCATEGORYCODE  '||CHR(10)
--        ||'                     HAVING SUM(NVL(ATTENDANCEHOURS,0))=0  AND SUM(NVL(OVERTIMEHOURS,0))>=8 '||CHR(10)
--        ||'            ) A,WPSWORKERMAST B,  '||CHR(10)
--        ||'            WHERE A.WORKERSERIAL=B.WORKERSERIAL  '||CHR(10)
--        ||'            GROUP BY A.WORKERSERIAL,A.TOKENNO,A.WORKERCATEGORYCODE,B.DEPARTMENTCODE,FIXEDBASIC,DARATE '||CHR(10)
--        ||'   )  '||CHR(10);

    lv_Sql := 'INSERT INTO GBL_ATTNINCENTIVE SELECT WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, DEPARTMENTCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, '||chr(10)
        ||' FIXEDBASIC,DARATE,NOOFDAYS, DAYS_AB, DAYS_C, ROUND((NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26,2) PERDAY_RATE, '||chr(10)
        ||' CASE WHEN WORKERCATEGORYCODE in( ''LRNR'',''NAPP'') AND 16 > '||lv_NoOfDays||' AND NOOFDAYS >= 10 THEN NOOFDAYS*70 '||chr(10)
        ||'      WHEN WORKERCATEGORYCODE in( ''LRNR'',''NAPP'') AND 16 = '||lv_NoOfDays||'  AND NOOFDAYS >= 11 THEN NOOFDAYS*70 '||chr(10)
--        ||'      WHEN WORKERCATEGORYCODE IN( ''BCTG'',''NBCT'') AND NOOFDAYS >= 12 AND ROUND((NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26,2) < 375 THEN ROUND((375 - (NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26) * NOOFDAYS,2) '||chr(10)
--        ||'      WHEN WORKERCATEGORYCODE IN( ''BCTG'',''NBCT'') AND 16 > '||lv_NoOfDays||'  AND NOOFDAYS >= 10 AND ROUND((NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26,2) < 350 THEN ROUND((350 - (NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26) * NOOFDAYS,2) '||chr(10)
--        ||'      WHEN WORKERCATEGORYCODE IN( ''BCTG'',''NBCT'') AND 16 = ' ||lv_NoOfDays||' AND NOOFDAYS >= 11 AND ROUND((NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26,2) < 350 THEN ROUND((350 - (NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26) * NOOFDAYS ,2) '||chr(10)        
--        ||' END ATTN_INCENTIVE  '||chr(10)       
        ||' WHEN WORKERCATEGORYCODE IN( ''BCTG'',''NBCT'') AND NOOFDAYS >= 12  THEN '||CHR(10)
        ||'     CASE WHEN  ROUND((NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26,2) >= 375 AND ROUND((NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26,2) < 450 THEN ROUND((450 - (NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26) * DAYS_C,2)  '||CHR(10) 
        ||'          WHEN  ROUND((NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26,2) < 375 THEN ROUND((375 - (NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26) * DAYS_AB,2) + ROUND((450 - (NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26) * DAYS_C,2)   '||CHR(10)
        ||'     ELSE 0 END  '||CHR(10)     
        ||' WHEN WORKERCATEGORYCODE IN( ''BCTG'',''NBCT'') AND 16 > '||lv_NoOfDays||'  AND NOOFDAYS >= 10 THEN  '||CHR(10) 
        ||'     CASE WHEN ROUND((NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26,2) >= 350 AND ROUND((NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26,2) < 425 THEN ROUND((425 - (NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26) * DAYS_C,2)  '||CHR(10) 
        ||'          WHEN ROUND((NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26,2) < 350 THEN (ROUND((350 - (NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26) * DAYS_AB,2) + ROUND((425 - (NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26) * DAYS_C,2))  '||CHR(10)
        ||'     ELSE 0 END   '||CHR(10)
        ||' WHEN WORKERCATEGORYCODE IN( ''BCTG'',''NBCT'') AND 16 = '||lv_NoOfDays||' AND NOOFDAYS >= 11 THEN  '||CHR(10)
        ||'     CASE WHEN ROUND((NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26,2) >= 350 AND ROUND((NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26,2) < 425 THEN ROUND((425 - (NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26) * DAYS_C ,2)  '||CHR(10) 
        ||'          WHEN ROUND((NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26,2) < 350 THEN (ROUND((350 - (NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26) * DAYS_AB ,2)+ROUND((425 - (NVL(FIXEDBASIC,0)+ NVL(DARATE,0))/26) * DAYS_C ,2))  '||CHR(10)
        ||'     ELSE 0 END  '||CHR(10)
        ||' ELSE 0   '||CHR(10)
        ||' END  ATTN_INCENTIVE  '||CHR(10)
        ||' FROM (  '||chr(10) 
        ||'         SELECT A.WORKERSERIAL,A.TOKENNO,A.WORKERCATEGORYCODE,B.DEPARTMENTCODE,  '||chr(10)
        ||'                 TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'') FORTNIGHTSTARTDATE,TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') FORTNIGHTENDDATE, '||chr(10)
        ||'                 FIXEDBASIC,DARATE, '||CHR(10)
        ||'                 COUNT(DATEOFATTENDANCE) NOOFDAYS, DAYS_AB, DAYS_C '||CHR(10)
        ||'            FROM  ATTN_INCENTIVEDAYS_SWT A, WPSWORKERMAST B,'||CHR(10)
        ||'            ( '||CHR(10)
        ||'             SELECT WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, SUM(DAYS_AB) DAYS_AB, SUM(DAYS_C) DAYS_C '||CHR(10)   
        ||'             FROM ( '||CHR(10)
        ||'                     SELECT WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, MIN(SHIFTCODE) SHIFTCODE, DATEOFATTENDANCE,  '||CHR(10) 
        ||'                     CASE WHEN MIN(SHIFTCODE)=''1'' THEN 1 ELSE 0 END DAYS_AB,  '||CHR(10)
        ||'                     CASE WHEN MIN(SHIFTCODE)=''3'' THEN 1 ELSE 0 END DAYS_C '||CHR(10)
        ||'                     FROM (  '||CHR(10)
        ||'                             SELECT DISTINCT A.WORKERSERIAL, A.TOKENNO, A.WORKERCATEGORYCODE, DECODE(A.SHIFTCODE,''1'',''1'',''2'',''1'',''3'',''3'') SHIFTCODE, A.DATEOFATTENDANCE  '||CHR(10) 
        ||'                             FROM WPSATTENDANCEDAYWISE A, ATTN_INCENTIVEDAYS_SWT B  '||CHR(10)
        ||'                             WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10) 
        ||'                               AND A.YEARCODE = '''||P_YEARCODE||'''  '||CHR(10)   
        ||'                               AND A.DATEOFATTENDANCE>=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')  '||CHR(10) 
        ||'                               AND A.DATEOFATTENDANCE<=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')  '||CHR(10)
        ||'                               AND A.WORKERSERIAL = B.WORKERSERIAL AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE AND A.DATEOFATTENDANCE = B.DATEOFATTENDANCE  '||CHR(10) 
        ||'                               AND (NVL(A.ATTENDANCEHOURS,0)+NVL(A.OVERTIMEHOURS,0)) > 0  '||CHR(10)
        ||'                               AND A.DEPARTMENTCODE IN (''24'',''25'',''26'',''35'') '||CHR(10)
        ||'                         )    '||CHR(10)
        ||'                         GROUP BY WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, DATEOFATTENDANCE  '||CHR(10)
        ||'                 )  '||CHR(10)
        ||'             GROUP BY  WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE  '||CHR(10)                
        ||'            ) C'||CHR(10) 
        ||'            WHERE A.WORKERSERIAL=B.WORKERSERIAL  '||CHR(10)
        ||'              AND A.WORKERSERIAL = C.WORKERSERIAL '||CHR(10)
        ||'            GROUP BY A.WORKERSERIAL,A.TOKENNO,A.WORKERCATEGORYCODE,B.DEPARTMENTCODE,FIXEDBASIC,DARATE, DAYS_AB, DAYS_C '||CHR(10)
        ||'   )  '||CHR(10);



--DBMS_OUTPUT.PUT_LINE(lv_Sql);
  lv_remarks := ' INSERT INTO FOR OTHR_EARN';
  INSERT INTO WPS_ERROR_LOG ( PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) VALUES (lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);
  EXECUTE IMMEDIATE lv_Sql;  

  lv_sql := 'UPDATE '||P_TABLENAME||' A SET (OTHR_EARN) = ( SELECT ATTN_INCENTIVE  FROM GBL_ATTNINCENTIVE B '||CHR(10) 
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||' AND A.YEARCODE = '''||P_YEARCODE||'''   '||CHR(10) 
        ||' AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||CHR(10)
        ||' AND A.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')               '||CHR(10)
        ||' AND A.WORKERSERIAL = B.WORKERSERIAL )'||CHR(10);

--DBMS_OUTPUT.PUT_LINE(lv_Sql); 

    lv_remarks :=' UPDATE OTHR_EARN';
    INSERT INTO WPS_ERROR_LOG ( PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) VALUES (lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);    
   EXECUTE IMMEDIATE lv_sql;
   
exception
    when others then
    lv_sqlerrm := sqlerrm ;
    insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_UPDATE',lv_Sql,lv_Sql,lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
    commit;
    --dbms_output.put_line('PROC - PROC_WPSWAGESPROCESS_UPDATE : ERROR !! WHILE WAGES PROCESS '||P_FNSTDT||' AND PHASE -> '||ltrim(trim(P_PHASE))||' : '||sqlerrm);
end;
/
