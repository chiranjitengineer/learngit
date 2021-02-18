CREATE OR REPLACE PROCEDURE JOONK.PRC_GPSLEAVEBALANCE
(
    P_COMPCODE Varchar2, 
    P_DIVCODE Varchar2,
    P_YEARCODE VARCHAR2,     
    P_ASONDATE Varchar2,
    P_PHASE  number, 
    P_PHASE_TABLENAME Varchar2,
    P_TABLENAME Varchar2,
    P_USERNAME    VARCHAR2 DEFAULT 'SWT',
    P_CATEGORYTYPE VARCHAR2 DEFAULT 'WORKER'
)
AS
lv_ProcName     varchar2(30) := 'PRC_GPSLEAVEBALANCE';
lv_Sql          varchar2(10000) := '';
lv_Remarks      varchar2(250) := '';
lv_AsOnDate     date := to_date(P_ASONDATE,'DD/MM/YYYY');
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';
lv_LeaveCode        varchar2(100) := '';
lv_CalendarYear     varchar2(10) := SUBSTR(P_ASONDATE,7,4);
pragma autonomous_transaction ;
                                                  
BEGIN
    lv_parvalues := 'COMPANY - '||P_COMPCODE||',DIVISION - '||P_DIVCODE||',AS ON DATE '||P_ASONDATE;
    
    DELETE FROM GBL_LEAVEBAL WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE;
    
    for c1 in  ( SELECT * FROM GPSLEAVEMASTER 
                 WHERE COMPANYCODE = P_COMPCODE
                   AND DIVISIONCODE = P_DIVCODE
                   AND NVL(WITHOUTPAYLEAVE,'N') <> 'Y'
                   AND NVL(LEAVEENTITLEMENTAPPLICABLE,'N') = 'Y'
               )
    loop
        lv_Sql := '';    
    end loop;                  
    
    lv_Sql := 'SELECT LISTAGG(LEAVECODE,'','') WITHIN GROUP (ORDER BY LEAVECODE) LEAVECODE '||chr(10) 
        ||' FROM ( '||CHR(10) 
        ||'         SELECT 1 AS LEAVEID, LEAVECODE '||CHR(10)
        ||'         FROM GPSLEAVEMASTER '||CHR(10)
        ||'         WHERE COMPANYCODE = '''||P_COMPCODE||''' '||CHR(10)
        ||'           AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10) 
        ||'           AND NVL(WITHOUTPAYLEAVE,''N'') <> ''Y'' '||CHR(10)
        ||'           AND NVL(LEAVEENTITLEMENTAPPLICABLE,''N'') = ''Y'' '||CHR(10)
        ||'     ) '||CHR(10)  
        ||' GROUP BY LEAVEID '||CHR(10);  
    
    DBMS_OUTPUT.PUT_LINE ('1. '||lv_Sql);
    
    EXECUTE IMMEDIATE lv_Sql into lv_LeaveCode;
    
    lv_LeaveCode := ''''||replace(lv_LeaveCode,',',''',''')||'''';
    
    ----DBMS_OUTPUT.PUT_LINE ('2. '||lv_LeaveCode);
    
    --return;
    
    lv_Remarks := 'INSERTING LEAVE BALANCE BASED ON CALENDAR YEAR';
    
    lv_Sql := ' INSERT INTO GBL_LEAVEBAL ( '||CHR(10)
            ||' COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, LEAVECODE, OPENINIG, ENTITLEMENT, AVAILED, BALANCE ) '||CHR(10)  
            ||' SELECT A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, B.TOKENNO, LEAVECODE, SUM(NVL(OPENING,0)) OPENING, SUM(NVL(A.ENTITLEMENT,0)) ENTITLEMENT, SUM(NVL(AVAILED,0)) AVAILED, '||CHR(10)
            ||' (SUM(NVL(OPENING,0)) + SUM(NVL(A.ENTITLEMENT,0)) - SUM(NVL(AVAILED,0))) BALANCE '||CHR(10)
            ||' FROM ( '||CHR(10)  
            ||'     SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL, LEAVECODE, 0 OPENING, SUM(NVL(ENTITLEMENTS,0)+NVL(CARRYFORWARD,0)) ENTITLEMENT, 0 AVAILED '||CHR(10)
            ||'     FROM GPSLEAVEENTITLEMENT '||CHR(10)
            ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' '||CHR(10)
            ||'       AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'       AND CALENDARYEAR = '''||lv_CalendarYear||''' '||CHR(10)
            ||'       AND LEAVECODE IN ('||lv_LeaveCode||') '||chr(10)
            ||'       /*AND LEAVECODE IN (''ANL'',''LWW'',''SCK'') */'||CHR(10)
            ||'     GROUP BY COMPANYCODE, DIVISIONCODE, WORKERSERIAL, LEAVECODE '||CHR(10)    
            ||'     UNION ALL '||CHR(10)
            ||'     SELECT COMPANYCODE, DIVISIONCODE,WORKERSERIAL, LEAVECODE, 0 OPENING, 0 ENTITLEMENT, SUM(NVL(LEAVEDAYS,0)) AVAILED '||CHR(10)
            ||'     FROM GPSLEAVEAPPLICATION '||CHR(10)
            ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' '||CHR(10)
            ||'       AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'       AND LEAVECODE IN ('||lv_LeaveCode||') '||chr(10)
            ||'       AND CALENDARYEAR = '''||lv_CalendarYear||''' '||CHR(10)
            ||'       /*AND LEAVECODE IN (''ANL'',''LWW'',''SCK'')*/ '||CHR(10)
            ||'       AND LEAVESANCTIONEDON IS NOT NULL '||CHR(10)
            ||'       AND LEAVEDATE <= TO_DATE('''||P_ASONDATE||''',''DD/MM/YYYY'') '||CHR(10)  
            ||'     GROUP BY COMPANYCODE, DIVISIONCODE, WORKERSERIAL, LEAVECODE '||CHR(10)
            ||' ) A, GPSEMPLOYEEMAST B, GPSCATEGORYMAST C '||CHR(10)
            ||' WHERE B.COMPANYCODE = '''||P_COMPCODE||''' AND B.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
            ||'   AND B.COMPANYCODE = C.COMPANYCODE AND B.DIVISIONCODE = C.DIVISIONCODE '||CHR(10)
            ||'   AND B.CATEGORYCODE = C.CATEGORYCODE '||CHR(10)
--            ||'   AND C.CATEGORYTYPE = '''||P_CATEGORYTYPE||''' '||CHR(10)
            ||'   AND C.LEAVECALENDARORFINYRWISE = ''C'' '||CHR(10)
            ||' GROUP BY A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, B.TOKENNO, A.LEAVECODE '||CHR(10);
 DBMS_OUTPUT.PUT_LINE(lv_Sql);
    insert into GPS_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName, NULL, lv_Sql, lv_parvalues,lv_AsOnDate,lv_AsOnDate, lv_Remarks);
    execute immediate lv_Sql;                                              
    COMMIT;            

    lv_Remarks := 'INSERTING LEAVE BALANCE BASED ON FINANCIAL YEAR';
    
    lv_Sql := ' INSERT INTO GBL_LEAVEBAL ( '||CHR(10)
            ||' COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, LEAVECODE, OPENINIG, ENTITLEMENT, AVAILED, BALANCE ) '||CHR(10)  
            ||' SELECT A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, B.TOKENNO, LEAVECODE, SUM(NVL(OPENING,0)) OPENING, SUM(NVL(A.ENTITLEMENT,0)) ENTITLEMENT, SUM(NVL(AVAILED,0)) AVAILED, '||CHR(10)
            ||' (SUM(NVL(OPENING,0)) + SUM(NVL(A.ENTITLEMENT,0)) - SUM(NVL(AVAILED,0))) BALANCE '||CHR(10)
            ||' FROM ( '||CHR(10)  
            ||'     SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL, LEAVECODE, 0 OPENING, SUM(NVL(ENTITLEMENTS,0)+NVL(CARRYFORWARD,0)) ENTITLEMENT, 0 AVAILED '||CHR(10)
            ||'     FROM GPSLEAVEENTITLEMENT '||CHR(10)
            ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' '||CHR(10)
            ||'       AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'       AND YEARCODE = '''||P_YEARCODE||''' '||CHR(10)
            ||'       AND LEAVECOde in ('||lv_LeaveCode||') '||chr(10)
            ||'       /*AND LEAVECODE IN (''ANL'',''LWW'',''SCK'') */'||CHR(10)
            ||'     GROUP BY COMPANYCODE, DIVISIONCODE, WORKERSERIAL, LEAVECODE '||CHR(10)    
            ||'     UNION ALL '||CHR(10)
            ||'     SELECT COMPANYCODE, DIVISIONCODE,WORKERSERIAL, LEAVECODE, 0 OPENING, 0 ENTITLEMENT, SUM(NVL(LEAVEDAYS,0)) AVAILED '||CHR(10)
            ||'     FROM GPSLEAVEAPPLICATION '||CHR(10)
            ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' '||CHR(10)
            ||'       AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'       AND YEARCODE = '''||P_YEARCODE||''' '||CHR(10)
            ||'       AND LEAVECOde in ('||lv_LeaveCode||') '||chr(10)
            ||'       /*AND LEAVECODE IN (''ANL'',''LWW'',''SCK'')*/ '||CHR(10)
            ||'       AND LEAVESANCTIONEDON IS NOT NULL '||CHR(10)
            ||'       AND LEAVEDATE <= TO_DATE('''||P_ASONDATE||''',''DD/MM/YYYY'') '||CHR(10)  
            ||'     GROUP BY COMPANYCODE, DIVISIONCODE, WORKERSERIAL, LEAVECODE '||CHR(10)
            ||' ) A, GPSEMPLOYEEMAST B, GPSCATEGORYMAST C '||CHR(10)
            ||' WHERE B.COMPANYCODE = '''||P_COMPCODE||''' AND B.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
            ||'   AND B.COMPANYCODE = C.COMPANYCODE AND B.DIVISIONCODE = C.DIVISIONCODE '||CHR(10)
            ||'   AND B.CATEGORYCODE = C.CATEGORYCODE '||CHR(10)
--            ||'   AND C.CATEGORYTYPE = '''||P_CATEGORYTYPE||''' '||CHR(10)
            ||'   AND C.LEAVECALENDARORFINYRWISE = ''F'' '||CHR(10)
            ||' GROUP BY A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, B.TOKENNO, A.LEAVECODE '||CHR(10);
    DBMS_OUTPUT.PUT_LINE(lv_Sql);
    insert into GPS_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName, NULL, lv_Sql, lv_parvalues,lv_AsOnDate,lv_AsOnDate, lv_Remarks);
    execute immediate lv_Sql;                                              
    COMMIT;            


EXCEPTION
    WHEN OTHERS THEN
    lv_sqlerrm := SqlErrm;
    insert into GPS_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_Sql,lv_parvalues,lv_AsOnDate,lv_AsOnDate, 'ERROR TRAP - '||lv_Remarks);
    COMMIT;    
                                                      
--PROC_GPSWAGESPROCESS_DEDN                                                      
END;
/
