DROP PROCEDURE NJMCL_WEB.PROC_WPSNSHOURS_UPDT;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPSNSHOURS_UPDT ( P_COMPCODE VARCHAR2, P_DIVCODE VARCHAR2, P_YEARCODE VARCHAR2, P_STARTDATE VARCHAR2, 
                                                   P_ENDDATE VARCHAR2, P_MINIMUM_WORKHOURS NUMBER,P_WORKERSERIAL VARCHAR2 DEFAULT NULL, 
                                                   P_CATEGORYCODE VARCHAR2 DEFAULT NULL)
AS
lv_Start_DT     date := to_date(P_STARTDATE,'DD/MM/YYYY');
lv_End_DT       date := to_date(P_ENDDATE,'DD/MM/YYYY');
lv_ProcName     varchar2(30) := 'PROC_WPSNSHOURS_UPDT';
lv_Remarks      varchar2(100):= 'NIGHT SHIFT HOURS UPDATE';
lv_Sql          varchar2(2000) := '';
Begin

    lv_Sql := 'UPDATE WPSATTENDANCEDAYWISE SET NIGHTALLOWANCEHOURS = 0 '||CHR(10)
        ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||'   AND YEARCODE = '''||P_YEARCODE||''' '||CHR(10)
        ||'   AND DATEOFATTENDANCE >= '''||lv_Start_DT||''' AND DATEOFATTENDANCE <= '''||lv_End_DT||''' '||chr(10)
        ||'   AND SHIFTCODE = ''3'' '||CHR(10)
        ||'   /*AND ATTENDANCETAG <> ''HAND WAGES'' */'||CHR(10);
    IF NVL(P_CATEGORYCODE,'SWT') <> 'SWT' THEN
        lv_Sql := lv_Sql || '    AND WORKERCATEGORYCODE = '''||P_CATEGORYCODE||''' '||CHR(10);
    END IF; 
    IF NVL(P_WORKERSERIAL,'SWT') <> 'SWT' THEN
        lv_Sql := lv_Sql || '    AND WORKERSERIAL = '''||P_WORKERSERIAL||''' '||CHR(10);
    END IF;            
    lv_Sql := lv_Sql ||'   AND NVL(NIGHTALLOWANCEHOURS,0) > ''0'' '||CHR(10);
    --dbms_output.put_line(lv_Sql);
    INSERT INTO WPS_ERROR_LOG ( PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) VALUES (lv_ProcName,'',sysdate,lv_Sql,'', lv_Start_DT, lv_End_DT, lv_Remarks);
    execute immediate lv_Sql;
        
    lv_Sql := 'UPDATE WPSATTENDANCEDAYWISE SET NIGHTALLOWANCEHOURS = 0.5 '||CHR(10)
        ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||'   AND YEARCODE = '''||P_YEARCODE||''' '||CHR(10)
        ||'   AND DATEOFATTENDANCE >= '''||lv_Start_DT||''' AND DATEOFATTENDANCE <= '''||lv_End_DT||''' '||chr(10)
        ||'   AND SHIFTCODE = ''3'' '||CHR(10)
        ||'   /*AND ATTENDANCETAG <> ''HAND WAGES'' */'||CHR(10);
    IF NVL(P_CATEGORYCODE,'SWT') <> 'SWT' THEN
        lv_Sql := lv_Sql || '    AND WORKERCATEGORYCODE = '''||P_CATEGORYCODE||''' '||CHR(10);
    END IF; 
    IF NVL(P_WORKERSERIAL,'SWT') <> 'SWT' THEN
        lv_Sql := lv_Sql || '    AND WORKERSERIAL = '''||P_WORKERSERIAL||''' '||CHR(10);
    END IF;            
    lv_Sql := lv_Sql ||'   AND NVL(ATTENDANCEHOURS,0) >= '||P_MINIMUM_WORKHOURS||' '||CHR(10);
    --dbms_output.put_line(lv_Sql);
    INSERT INTO WPS_ERROR_LOG ( PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) VALUES (lv_ProcName,'',sysdate,lv_Sql,'', lv_Start_DT, lv_End_DT, lv_Remarks);
    execute immediate lv_Sql;
    commit;
End;
/


