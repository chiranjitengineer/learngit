DROP PROCEDURE NJMCL_WEB.PROC_WPSWAGES_DEPTSHIFT_UPDT;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PROC_WPSWAGES_DEPTSHIFT_UPDT" (P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2, 
                                                  P_YEARCODE Varchar2,
                                                  P_FNSTDT Varchar2,  --- 01/05/2016 '  
                                                  P_FNENDT Varchar2,  --- 31/05/2016 '
                                                  P_PHASE  number, 
                                                  P_PHASE_TABLENAME VARCHAR2, -- 'wpswagesdetails_mv_swt
                                                  P_TABLENAME Varchar2,  ---' wpswagesdetails_mv
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL,
                                                  P_PROCESSTYPE  VARCHAR2 DEFAULT 'WAGES PROCESS')
as
lv_Component varchar2(32767) := '';
lv_Sql       varchar2(32767) := '';
lv_upd1_sql  varchar2(32767) := '';
lv_upd2_sql  varchar2(32767) := '';
lv_colstr    varchar2(32767) := '';
lv_Sql_TblCreate    varchar2(3000) := '';  
lv_sqlerrm      varchar2(1000) := ''; 
lv_remarks      varchar2(1000) := '';
lv_parvalues    varchar2(1000) := '';
lv_SqlTemp      varchar2 (2000) := '';
lv_Cols         varchar2 (1000) := '';
lv_fn_stdt      date := to_date(P_FNSTDT,'DD/MM/YYYY');
lv_fn_endt      date := to_date(P_FNENDT,'DD/MM/YYYY');
lv_FirtstDt     date; 
lv_ProcName     varchar2(30) := 'PROC_WPSWAGES_DEPTSHIFT_UPDT';
lv_YYYYMM       varchar2(10) := to_char(lv_fn_stdt,'YYYYMM');
lv_updtable varchar2(30) ;
lv_cnt int;
lv_WAGES_DEPT_SHIFT varchar2(100) := '';
lv_WAGES_SLIPNO     varchar2(100) := '';
begin
    
    lv_parvalues := 'DEPT, SHIFT UPDATE DIV = '||P_DIVCODE||', FNE = '||P_FNENDT||', PHASE = '||P_PHASE;
    lv_remarks := 'PHASE - '||P_PHASE||' START';
    
    SELECT NVL(WAGES_DEPT_SHIFT,'MASTER DEPARTMENT AND MASTER SHIFT'), NVL(WAGES_SLIPNO,'NONE') INTO lv_WAGES_DEPT_SHIFT, lv_WAGES_SLIPNO 
    FROM WPSWAGESPARAMETER WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE;
    
    DBMS_OUTPUT.PUT_LINE ('WAGES_DEPT_SHIFT - '||lv_WAGES_DEPT_SHIFT||', SLIP NO - '||lv_WAGES_SLIPNO);
    
    if  substr(P_FNSTDT,1,2) = '01' then
        lv_FirtstDt := to_date(P_FNSTDT,'DD/MM/YYYY');        
    else
        lv_FirtstDt := to_date('01'||substr(P_FNSTDT,3,8),'DD/MM/YYYY');
    end if;
    select SUBSTR( ( 'WPS_'||SYS_CONTEXT('USERENV', 'SESSIONID')) ,1,30) into lv_updtable  from dual ;
    lv_remarks := 'TEMPORARY TABLE CREATION - FOR DEPRTMENT, SHIFT UPDATION';
    
    begin
        lv_sql := 'DROP TABLE '||lv_updtable||' '||CHR(10);
        execute immediate lv_sql;
    exception
        when others then null; 
    end;
    if lv_WAGES_DEPT_SHIFT = 'MASTER DEPARTMENT AND MASTER SHIFT' THEN
        lv_sql := ' CREATE TABLE '||lv_updtable||' AS  '||CHR(10)
                || ' SELECT A.WORKERSERIAL, A.DEPARTMENTCODE, A.GROUPCODE, DECODE(NVL(A.GROUPCODE,''A''),''A'',''1'',''B'',''2'',''C'',''3'',''A'') SHIFTCODE '||CHR(10)
                ||' FROM WPSWORKERMAST A,'||P_TABLENAME||' B '||CHR(10)
                ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                ||'   AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
                ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
                ||'   AND B.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||CHR(10)
                ||'   AND B.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')               '||CHR(10); 
        INSERT INTO WPS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE,PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
        VALUES (P_COMPCODE, P_DIVCODE, lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks); 
        EXECUTE IMMEDIATE lv_sql  ;
        
    ELSIF  lv_WAGES_DEPT_SHIFT = 'MAX DEPARTMENT AND MAX SHIFT' THEN
            lv_sql := ' CREATE TABLE '||lv_updtable||' AS  '||CHR(10)
                    ||' SELECT WORKERSERIAL, SUBSTR(DEPTSHIFTOCP,1,INSTR(DEPTSHIFTOCP,'','')-1) DEPARTMENTCODE,  '||CHR(10)
                    ||' SUBSTR(DEPTSHIFTOCP,INSTR(DEPTSHIFTOCP,'','')+1,INSTR(DEPTSHIFTOCP,''-'')-INSTR(DEPTSHIFTOCP,'','')-1)SHIFTCODE,  '||CHR(10)  
                    ||' SUBSTR(DEPTSHIFTOCP,INSTR(DEPTSHIFTOCP,''-'')+1,INSTR(DEPTSHIFTOCP,''-'')) OCCUPATIONCODE,   '||CHR(10)
                    ||' DEPTSHIFTOCP  '||CHR(10)
                    ||' FROM ('||CHR(10)
                    ||'     SELECT WORKERSERIAL, MAX(DEPARTMENTCODE||'',''||SHIFTCODE||''-''||OCCUPATIONCODE) DEPTSHIFTOCP  '||CHR(10)
                    ||'     FROM WPSATTENDANCEDAYWISE  '||CHR(10)
                    ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10) 
                    ||'       AND DATEOFATTENDANCE>=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||CHR(10)
                    ||'       AND DATEOFATTENDANCE<=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') AND ATTENDANCETAG <>''HAND WAGES'' '||CHR(10)
                    ||'     GROUP BY WORKERSERIAL   '||CHR(10)
                    ||'     UNION ALL '||CHR(10)  --- NEW ADD BY AMALESH ON 05/05/2017 FOR THOSE WOKRER WHOSE NO ATENDANCE BUT HAND WAGES AVAILABLE
                    ||'     SELECT WORKERSERIAL, MAX(DEPARTMENTCODE||'',''||SHIFTCODE||''-''||OCCUPATIONCODE) DEPTSHIFTOCP   '||CHR(10)
                    ||'     FROM WPSATTENDANCEDAYWISE   '||CHR(10)
                    ||'     WHERE COMPANYCODE ='''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''   '||CHR(10) 
                    ||'       AND DATEOFATTENDANCE>=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')    '||CHR(10)     
                    ||'       AND DATEOFATTENDANCE<=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') AND ATTENDANCETAG = ''HAND WAGES''   '||CHR(10)
                    ||'       AND WORKERSERIAL IN (    '||CHR(10)
                    ||'             SELECT DISTINCT WORKERSERIAL FROM WPSATTENDANCEDAYWISE   '||CHR(10)
                    ||'             WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''   '||CHR(10)
                    ||'               AND DATEOFATTENDANCE>=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')   '||CHR(10)      
                    ||'               AND DATEOFATTENDANCE<=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') AND ATTENDANCETAG = ''HAND WAGES''   '||CHR(10)
                    ||'             MINUS   '||CHR(10)
                    ||'             SELECT DISTINCT WORKERSERIAL FROM WPSATTENDANCEDAYWISE   '||CHR(10)
                    ||'             WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''    '||CHR(10)
                    ||'               AND DATEOFATTENDANCE>=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')   '||CHR(10)      
                    ||'               AND DATEOFATTENDANCE<=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') AND ATTENDANCETAG <> ''HAND WAGES''   '||CHR(10)
                    ||'           )    '||CHR(10)         
                    ||'       GROUP BY WORKERSERIAL   '||CHR(10)
                    ||'    )          '||CHR(10);
            INSERT INTO WPS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
            VALUES (P_COMPCODE, P_DIVCODE, lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks); 
            --dbms_output.put_line( lv_sql );
            EXECUTE IMMEDIATE lv_sql  ;   
    ELSIF lv_WAGES_DEPT_SHIFT = 'MAX WORKING DEPARTMENT AND USER DEFINED SHIFT' THEN
        lv_sql := ' CREATE TABLE '||lv_updtable||' AS  '||CHR(10)
                ||' SELECT WORKERSERIAL, SUBSTR(DEPTSHIFTOCP,1,INSTR(DEPTSHIFTOCP,'','')-1) DEPARTMENTCODE,  '||CHR(10)
                ||' SUBSTR(DEPTSHIFTOCP,INSTR(DEPTSHIFTOCP,'','')+1,INSTR(DEPTSHIFTOCP,''-'')-INSTR(DEPTSHIFTOCP,'','')-1)SHIFTCODE,  '||CHR(10)  
                ||' SUBSTR(DEPTSHIFTOCP,INSTR(DEPTSHIFTOCP,''-'')+1,INSTR(DEPTSHIFTOCP,''-'')) OCCUPATIONCODE,   '||CHR(10)
                ||' DEPTSHIFTOCP  '||CHR(10)
                ||' FROM ('||CHR(10)
                ||'     SELECT WORKERSERIAL, MAX(DEPARTMENTCODE||'',''||SHIFTCODE||''-''||OCCUPATIONCODE) DEPTSHIFTOCP  '||CHR(10)
                ||'     FROM WPSATTENDANCEDAYWISE  '||CHR(10)
                ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10) 
                ||'       AND DATEOFATTENDANCE>=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||CHR(10)
                ||'       AND DATEOFATTENDANCE<=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') AND ATTENDANCETAG <>''HAND WAGES'' '||CHR(10)
                ||'     GROUP BY WORKERSERIAL   '||CHR(10)
                ||'     UNION ALL '||CHR(10)  --- NEW ADD BY AMALESH ON 05/05/2017 FOR THOSE WOKRER WHOSE NO ATENDANCE BUT HAND WAGES AVAILABLE
                ||'     SELECT WORKERSERIAL, MAX(DEPARTMENTCODE||'',''||SHIFTCODE||''-''||OCCUPATIONCODE) DEPTSHIFTOCP   '||CHR(10)
                ||'     FROM WPSATTENDANCEDAYWISE   '||CHR(10)
                ||'     WHERE COMPANYCODE ='''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''   '||CHR(10) 
                ||'       AND DATEOFATTENDANCE>=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')    '||CHR(10)     
                ||'       AND DATEOFATTENDANCE<=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') AND ATTENDANCETAG = ''HAND WAGES''   '||CHR(10)
                ||'       AND WORKERSERIAL IN (    '||CHR(10)
                ||'             SELECT DISTINCT WORKERSERIAL FROM WPSATTENDANCEDAYWISE   '||CHR(10)
                ||'             WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''   '||CHR(10)
                ||'               AND DATEOFATTENDANCE>=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')   '||CHR(10)      
                ||'               AND DATEOFATTENDANCE<=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') AND ATTENDANCETAG = ''HAND WAGES''   '||CHR(10)
                ||'             MINUS   '||CHR(10)
                ||'             SELECT DISTINCT WORKERSERIAL FROM WPSATTENDANCEDAYWISE   '||CHR(10)
                ||'             WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''    '||CHR(10)
                ||'               AND DATEOFATTENDANCE>=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')   '||CHR(10)      
                ||'               AND DATEOFATTENDANCE<=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') AND ATTENDANCETAG <> ''HAND WAGES''   '||CHR(10)
                ||'           )    '||CHR(10)         
                ||'       GROUP BY WORKERSERIAL   '||CHR(10)
                ||'    )          '||CHR(10);
          --      dbms_output.put_line( lv_sql );
--                RETURN;
    ELSIF lv_WAGES_DEPT_SHIFT = 'LAST WORKING SECTION AND SHIFT' THEN
            
    /************************ ADDED BY PRASUN ON 10102019 ****************/
       lv_sql := ' CREATE TABLE '||lv_updtable||' AS  '||CHR(10)
       --modified by prasun 22.11.2019
--               ||'   SELECT A.WORKERSERIAL, MAX(A.DEPARTMENTCODE) DEPARTMENTCODE, MAX(DECODE(NVL(A.GROUPCODE,''R''),''B'',''1'',''R'',''2'',''G'',''3'',''A'')) SHIFTCODE, '||CHR(10) 
               ||'   SELECT A.WORKERSERIAL, MAX(A.DEPARTMENTCODE) DEPARTMENTCODE, MAX(SHIFTCODE) SHIFTCODE, '||CHR(10)
               ||'   MAX(A.OCCUPATIONCODE) OCCUPATIONCODE, MAX(SECTIONCODE) SECTIONCODE      '||CHR(10)
               ||'   FROM WPSATTENDANCEDAYWISE A,  '||CHR(10)
               ||'   (  '||CHR(10)
               ||'       SELECT WORKERSERIAL, MAX(DATEOFATTENDANCE) DATEOFATTENDANCE '||CHR(10)
               ||'       FROM WPSATTENDANCEDAYWISE  '||CHR(10)
               ||'       WHERE COMPANYCODE = '''||P_COMPCODE||'''    '||CHR(10)
               ||'       AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
               ||'       AND YEARCODE  = '''||P_YEARCODE||''' '||CHR(10)
               ||'       AND FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||CHR(10)
               ||'       AND FORTNIGHTENDDATE  = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')       '||CHR(10)
               ||'       AND (NVL(ATTENDANCEHOURS,0)+NVL(OVERTIMEHOURS,0)) > 0 '||CHR(10) 
               ||'       GROUP BY WORKERSERIAL '||CHR(10)
               ||'   ) B '||CHR(10)
               ||'   WHERE 1= 1 '||CHR(10)
               ||'   AND A.COMPANYCODE = '''||P_COMPCODE||'''    '||CHR(10)   
               ||'   AND A.DIVISIONCODE = '''||P_DIVCODE||'''    '||CHR(10)
               ||'   AND A.YEARCODE  = '''||P_YEARCODE||''' '||CHR(10)
               ||'   AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||CHR(10)
               ||'   AND A.FORTNIGHTENDDATE  = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')       '||CHR(10)
               ||'   AND (NVL(A.ATTENDANCEHOURS,0)+NVL(A.OVERTIMEHOURS,0)) > 0 '||CHR(10) 
               ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
               ||'   AND A.DATEOFATTENDANCE = B.DATEOFATTENDANCE '||CHR(10)
               ||'   GROUP BY A.WORKERSERIAL '||CHR(10);
        
        INSERT INTO WPS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE,PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
        VALUES (P_COMPCODE, P_DIVCODE, lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks); 
        EXECUTE IMMEDIATE lv_sql  ;
        
         lv_sql := ' INSERT INTO  '||lv_updtable ||CHR(10)
                 ||'SELECT T1.WORKERSERIAL,  T1.DEPARTMENTCODE, DECODE(NVL(T1.GROUPCODE,''R''),''B'',''1'',''R'',''2'',''G'',''3'',''A'') SHIFTCODE , T1.OCCUPATIONCODE, T1.SECTIONCODE FROM WPSWORKERMAST T1 , '||lv_updtable||' T2 '||CHR(10)
                 ||'WHERE T1.ACTIVE = ''Y'' '||CHR(10)
                 ||'AND T1.WORKERSERIAL = T2.WORKERSERIAL(+) '||CHR(10)
                 ||'AND T2.WORKERSERIAL IS NULL '||CHR(10);
        
        INSERT INTO WPS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
        VALUES (P_COMPCODE, P_DIVCODE, lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks); 
        EXECUTE IMMEDIATE lv_sql  ;
        /************************ ADDED BY PRASUN ON 10102019 ****************/
    ELSIF lv_WAGES_DEPT_SHIFT = 'MAX WORKING DEPT,SECTION,OCP,DEPTSERIAL,SHIFT' THEN
        lv_sql := ' CREATE TABLE '||lv_updtable||' AS '||chr(10)
                ||' SELECT A.WORKERSERIAL, SHIFTCODE, DEPARTMENTCODE, SECTIONCODE, OCCUPATIONCODE, DEPTSERIAL '||CHR(10)
                ||' FROM '||P_PHASE_TABLENAME||' A,  '||CHR(10)
                ||' (  '||CHR(10)
                ||'    SELECT WORKERSERIAL, MAX(DEPARTMENTCODE||SECTIONCODE||OCCUPATIONCODE||DEPTSERIAL||SHIFTCODE) MAXDEPTSFTSECOCPDEPTSRL  '||CHR(10)
                ||'    FROM (  '||CHR(10)
                ||'            SELECT A.WORKERSERIAL, A.SHIFTCODE, A.DEPARTMENTCODE, A.SECTIONCODE, A.OCCUPATIONCODE,A.DEPTSERIAL  '||CHR(10)
                ||'            FROM '||P_PHASE_TABLENAME||' A,  '||CHR(10)
                ||'            (  '||CHR(10)
                ||'                SELECT WORKERSERIAL, MAX(NVL(ATTENDANCEHOURS,0)) MAX_ATTN_HRS, MAX(NVL(OVERTIMEHOURS,0)) MAX_OT_HRS  '||CHR(10)
                ||'                FROM '||P_PHASE_TABLENAME||'  '||CHR(10)
                ||'                WHERE COMPANYCODE ='''||P_COMPCODE||''' AND DIVISIONCODE ='''||P_DIVCODE||'''  '||CHR(10)
                ||'                  AND YEARCODE ='''||P_YEARCODE||'''  '||CHR(10)
                ||'                  AND FORTNIGHTSTARTDATE = '''||lv_fn_stdt||'''  '||CHR(10)
                ||'                  AND FORTNIGHTENDDATE = '''||lv_fn_endt||'''  '||CHR(10)
                ||'                GROUP BY WORKERSERIAL  '||CHR(10)
                ||'            ) B  '||CHR(10)
                ||'            WHERE A.COMPANYCODE ='''||P_COMPCODE||''' AND A.DIVISIONCODE ='''||P_DIVCODE||'''  '||CHR(10)
                ||'              AND A.YEARCODE ='''||P_YEARCODE||'''  '||CHR(10)
                ||'              AND A.FORTNIGHTSTARTDATE = '''||lv_fn_stdt||'''  '||CHR(10)
                ||'              AND A.FORTNIGHTENDDATE = '''||lv_fn_endt||'''  '||CHR(10)
                ||'              AND A.WORKERSERIAL = B.WORKERSERIAL  '||CHR(10)
                ||'              AND A.ATTENDANCEHOURS= B.MAX_ATTN_HRS  '||CHR(10)
                ||'              AND B.MAX_ATTN_HRS > 0  '||CHR(10)
                ||'         )  '||CHR(10)
                ||'    GROUP BY WORKERSERIAL  '||CHR(10)       
                ||'    UNION ALL  '||CHR(10) --- below part for those who only worked in O.T.
                ||'    SELECT WORKERSERIAL, MAX(DEPARTMENTCODE||SECTIONCODE||OCCUPATIONCODE||DEPTSERIAL||SHIFTCODE) MAXDEPTSFTSECOCPDEPTSRL  '||CHR(10)
                ||'    FROM (  '||CHR(10)
                ||'            SELECT A.WORKERSERIAL, A.SHIFTCODE, A.DEPARTMENTCODE, A.SECTIONCODE, A.OCCUPATIONCODE,A.DEPTSERIAL  '||CHR(10)
                ||'            FROM '||P_PHASE_TABLENAME||' A,  '||CHR(10)
                ||'            (  '||CHR(10)
                ||'                SELECT WORKERSERIAL, MAX(ATTENDANCEHOURS) MAX_ATTN_HRS, MAX(OVERTIMEHOURS) MAX_OT_HRS  '||CHR(10)
                ||'                FROM '||P_PHASE_TABLENAME||'  '||CHR(10)
                ||'                WHERE COMPANYCODE ='''||P_COMPCODE||''' AND DIVISIONCODE ='''||P_DIVCODE||'''  '||CHR(10)
                ||'                  AND YEARCODE ='''||P_YEARCODE||'''  '||CHR(10)
                ||'                  AND FORTNIGHTSTARTDATE = '''||lv_fn_stdt||'''  '||CHR(10)
                ||'                  AND FORTNIGHTENDDATE = '''||lv_fn_endt||'''  '||CHR(10)
                ||'                GROUP BY WORKERSERIAL  '||CHR(10)
                ||'            ) B  '||CHR(10)
                ||'            WHERE A.COMPANYCODE ='''||P_COMPCODE||''' AND A.DIVISIONCODE ='''||P_DIVCODE||'''  '||CHR(10)
                ||'              AND A.YEARCODE ='''||P_YEARCODE||'''  '||CHR(10)
                ||'              AND A.FORTNIGHTSTARTDATE = '''||lv_fn_stdt||'''  '||CHR(10)
                ||'              AND A.FORTNIGHTENDDATE = '''||lv_fn_endt||'''  '||CHR(10)
                ||'              AND A.WORKERSERIAL = B.WORKERSERIAL  '||CHR(10)
                ||'              AND B.MAX_ATTN_HRS <= 0  '||CHR(10)
                ||'              AND A.OVERTIMEHOURS = B.MAX_OT_HRS  '||CHR(10)
                ||'       )  '||CHR(10)
                ||'     GROUP BY WORKERSERIAL  '||CHR(10)        
                ||' ) B  '||CHR(10)
                ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10) 
                ||'   AND A.YEARCODE = '''||P_YEARCODE||'''  '||CHR(10)
                ||'   AND A.FORTNIGHTSTARTDATE ='''||lv_fn_stdt||''' AND A.FORTNIGHTENDDATE ='''||lv_fn_endt||'''  '||CHR(10)
                ||'   AND A.DEPARTMENTCODE||A.SECTIONCODE||A.OCCUPATIONCODE||A.DEPTSERIAL||A.SHIFTCODE = B.MAXDEPTSFTSECOCPDEPTSRL  '||CHR(10)
                ||' AND A.WORKERSERIAL = B.WORKERSERIAL  '||CHR(10);

        INSERT INTO WPS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE,PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
        VALUES (P_COMPCODE, P_DIVCODE, lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks); 
        EXECUTE IMMEDIATE lv_sql  ;
    
          
    ELSE
        lv_sql := ' CREATE TABLE '||lv_updtable||' AS  '||CHR(10)
                || ' SELECT A.WORKERSERIAL, A.DEPARTMENTCODE, A.GROUPCODE, DECODE(NVL(A.GROUPCODE,''A''),''A'',''1'',''B'',''2'',''C'',''3'',''A'') SHIFTCODE '||CHR(10)
                ||' FROM WPSWORKERMAST A,'||P_TABLENAME||' B '||CHR(10)
                ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                ||'   AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
                ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10);
        INSERT INTO WPS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
        VALUES (P_COMPCODE, P_DIVCODE, lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks); 
        EXECUTE IMMEDIATE lv_sql  ;
    
    end if;                  
    lv_remarks := 'UPDATE DEPT, SHIFT AGIANST TEMPORARY TABLE';
    if  lv_WAGES_DEPT_SHIFT = 'MASTER DEPARTMENT AND MASTER SHIFT' THEN
        lv_sql := 'UPDATE '||P_TABLENAME||' A SET (DEPARTMENTCODE, SHIFTCODE) = ( SELECT DEPARTMENTCODE, SHIFTCODE  FROM '||lv_updtable||' B '||CHR(10) 
               ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
               ||' AND A.YEARCODE = '''||P_YEARCODE||'''   '||CHR(10) 
               ||' AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||CHR(10)
               ||' AND A.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')               '||CHR(10)
               ||' AND A.WORKERSERIAL = B.WORKERSERIAL )'||CHR(10)
               ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
               ||' AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||CHR(10)
               ||' AND A.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')               '||CHR(10);
    else
        lv_sql := 'UPDATE '||P_TABLENAME||' A SET (DEPARTMENTCODE, SHIFTCODE,OCCUPATIONCODE,SECTIONCODE, DEPTSERIAL) = ( SELECT DEPARTMENTCODE, SHIFTCODE, OCCUPATIONCODE, SECTIONCODE, DEPTSERIAL  FROM '||lv_updtable||' B '||CHR(10) 
               ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
               ||' AND A.YEARCODE = '''||P_YEARCODE||'''   '||CHR(10) 
               ||' AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||CHR(10)
               ||' AND A.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')               '||CHR(10)
               ||' AND A.WORKERSERIAL = B.WORKERSERIAL )'||CHR(10)
               ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
               ||' AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||CHR(10)
               ||' AND A.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')               '||CHR(10);
    end if; 
    --- END ADD ON 29.09.2016 -----------
    --dbms_output.put_line( lv_sql );
    lv_remarks := NVL(lv_remarks,'XX ') ||' UPDATE DEPARTMENT,SHIFT';
    INSERT INTO WPS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    VALUES (P_COMPCODE, P_DIVCODE, lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);
    commit;    
    EXECUTE IMMEDIATE lv_sql;
    commit;
   BEGIN
    execute immediate 'DROP TABLE '||lv_updtable ;
   EXCEPTION
    WHEN OTHERS THEN
      lv_sqlerrm := sqlerrm;
      raise_application_error(-20101, lv_sqlerrm||'ERROR WHILE UPDATING '||P_TABLENAME||' FROM TABLE '||lv_updtable);
   END ;
   ----- update slip no. generation for thed 
   ----- unitwise, department, shift and tokenno wise
   DELETE FROM GBL_WPSSLIPNO_GENERATE;
   IF NVL(P_WORKERSERIAL,'NONE') = 'NONE' then
        --- GENERATE FROM 1 TO NO OF SLIP, ORDER BY UNIT, DEPARTMENT, SHIFT
        lv_Sql := 'INSERT INTO GBL_WPSSLIPNO_GENERATE ( '||chr(10) 
                ||' COMPANYCODE, DIVISIONCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, UNITCODE, WORKERCATEGORYCODE, DEPARTMENTCODE, SHIFTCODE, OCCUPATIONCODE, '||chr(10) 
                ||' WORKERSERIAL, TOKENNO, PAYSLIPNO)  '||chr(10)
                ||' SELECT COMPANYCODE, DIVISIONCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, UNITCODE, WORKERCATEGORYCODE, DEPARTMENTCODE, SHIFTCODE, OCCUPATIONCODE,  '||chr(10)
                ||' WORKERSERIAL, TOKENNO, RANK() OVER (PARTITION BY DIVISIONCODE,DEPARTMENTCODE, SHIFTCODE ORDER BY UNITCODE,DEPARTMENTCODE, SHIFTCODE,TOKENNO) PAYSLIPNO  '||chr(10)
                ||' FROM '||P_TABLENAME||'  '||chr(10)
                ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
                ||' AND FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')  '||chr(10)
                ||' AND FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')   '||chr(10);
        lv_remarks := ' GLOBAL TEMP TABLE CREATE FOR SLIPNO - LOGIC NONE - ORDER BY UNIT,DEPARTMENT, SHIFT';
        INSERT INTO WPS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
        VALUES (P_COMPCODE, P_DIVCODE, lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);
        commit;    
        EXECUTE IMMEDIATE lv_sql;
        commit;        
   end if;
   
    lv_remarks := 'UPDATE PAY SLIP NO AGIANST GLOBAL TEMPORARY TABLE';
    lv_sql := 'UPDATE '||P_TABLENAME||' A SET (SERIALNO) = ( SELECT PAYSLIPNO  FROM GBL_WPSSLIPNO_GENERATE B '||CHR(10) 
           ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
           ||' AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||CHR(10)
           ||' AND A.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')               '||CHR(10)
           ||' AND A.WORKERSERIAL = B.WORKERSERIAL )'||CHR(10)
           ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
           ||' AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||CHR(10)
           ||' AND A.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')               '||CHR(10); 
    lv_remarks := 'UPDATE SLIP FROM TEMPRARY GLOBALE TABLE ';
    INSERT INTO WPS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    VALUES (P_COMPCODE, P_DIVCODE,lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);
    commit;    
    EXECUTE IMMEDIATE lv_sql;
    commit;   
                            
/*EXCEPTION
    WHEN OTHERS THEN
      lv_sqlerrm := sqlerrm;
      raise_application_error(-20101, lv_sqlerrm||'ERROR WHILE UPDATING '||P_TABLENAME||' FROM TABLE '||lv_updtable);
    INSERT INTO WPS_ERROR_LOG ( PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) VALUES (lv_ProcName,lv_sqlerrm,sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);
    */          
end;
/


