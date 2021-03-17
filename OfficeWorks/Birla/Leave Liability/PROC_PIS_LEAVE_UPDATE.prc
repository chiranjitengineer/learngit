CREATE OR REPLACE PROCEDURE BIRLANEW.PROC_PIS_LEAVE_UPDATE(P_COMPCODE Varchar2,
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
lv_fn_stdt      date ;
lv_fn_endt      date ;
lv_YearCode     varchar2(10):= '';
lv_FirtstDt     date; 
lv_ProcName     varchar2(30) := 'PROC_PIS_LEAVE_UPDATE';
lv_updtable varchar2(30):='PIS_LEAVE' ;
lv_pf_cont_col varchar2(30) ;
lv_cnt int;
lv_FNYearStartdate varchar2(10) :='';
lv_CalenderYearStartdate varchar2(10) :='';
lv_LeaveSUM VARCHAR2(2000):='';
lv_LeaveComp VARCHAR2(2000):='';
lv_leaveQuery VARCHAR2(2000):='';
lv_strfn_enddt VARCHAR2(20):='';
begin

    lv_fn_stdt := TO_DATE('01/'||SUBSTR(P_EFFECTYEARMONTH,5,2)||'/'||SUBSTR(P_EFFECTYEARMONTH,1,4),'DD/MM/YYYY');   
    lv_fn_endt := last_day(lv_fn_stdt);
    
    SELECT YEARCODE INTO lv_YearCode FROM FINANCIALYEAR
    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
      AND STARTDATE <= lv_fn_stdt and ENDDATE >= lv_fn_stdt;
      
   lv_cnt :=0;
    SELECT COUNT(*)
    INTO 
    lv_cnt
    FROM USER_TABLES
    WHERE TABLE_NAME =lv_updtable;
    
    IF lv_cnt>0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE '|| lv_updtable;
    END IF;
    lv_strfn_enddt:=TO_CHAR(lv_fn_endt,'DD/MM/YYYY');
    
    -- ADD LEAVE EARN PROCEDURE ON 11/03/2021
    PRC_PISLEAVEEARN_INSERT(P_COMPCODE,P_DIVCODE,P_YEARMONTH,NULL,P_UNIT,P_CATEGORY,P_GRADE,P_DEPARTMENT,P_WORKERSERIAL,'Y');

    
    PROC_PIS_LEAVEBAL(P_COMPCODE,P_DIVCODE,lv_YearCode,lv_strfn_enddt,lv_strfn_enddt);
    
    
    
    FOR C1 IN (SELECT LEAVECODE from PISLEAVEMASTER WHERE COMPANYCODE=P_COMPCODE AND DIVISIONCODE=P_DIVCODE AND WITHOUTPAYLEAVE<>'Y' ORDER BY LEAVECODE)
    LOOP
        lv_LeaveSUM:=lv_LeaveSUM||', SUM(LDAY_'||C1.LEAVECODE||') LDAY_'||C1.LEAVECODE||', SUM(LVBL_'||C1.LEAVECODE||') LVBL_'||C1.LEAVECODE;
        IF LENGTH(lv_LeaveComp)> 0 THEN
            lv_LeaveComp:=lv_LeaveComp||',/*LDAY_'||C1.LEAVECODE||',*/LVBL_'||C1.LEAVECODE;
        ELSE
            lv_LeaveComp:='/*LDAY_'||C1.LEAVECODE||',*/LVBL_'||C1.LEAVECODE;
        END IF;
        IF LENGTH(lv_leaveQuery)> 0 THEN
            lv_leaveQuery:=lv_leaveQuery||'UNION ALL'||CHR(10)
                            ||fn_GET_LEAVEQUERRY(P_COMPCODE,P_DIVCODE,C1.LEAVECODE,'GBL_PIS_LEAVEBAL');
        ELSE
            lv_leaveQuery:=fn_GET_LEAVEQUERRY(P_COMPCODE,P_DIVCODE,C1.LEAVECODE,'GBL_PIS_LEAVEBAL');
        END IF;  
           
    
     END LOOP;
     lv_remarks:='CRAEATE TEMP TABLE';
     lv_Sql_TblCreate:='CREATE TABLE '||lv_updtable||CHR(10)
                      ||'AS'||CHR(10)
                      ||'SELECT COMPANYCODE,DIVISIONCODE,WORKERSERIAL'||lv_LeaveSUM||CHR(10)
                      ||'FROM('||CHR(10)||lv_leaveQuery||'   )'||CHR(10)
                      ||'GROUP BY COMPANYCODE,DIVISIONCODE,WORKERSERIAL'||CHR(10);
                      
     --dbms_output.put_line(lv_Sql_TblCreate ); 
     INSERT INTO PIS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE,PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
        VALUES (P_COMPCODE, P_DIVCODE,lv_ProcName,'',sysdate,lv_Sql_TblCreate,'', lv_fn_stdt, lv_fn_endt, lv_remarks);               
     EXECUTE IMMEDIATE lv_Sql_TblCreate;
     
     lv_remarks:='UPDATE LEAVE';
     lv_sql := 'UPDATE '||P_TABLENAME||' A SET ('||lv_LeaveComp||')  '||CHR(10)  
        ||' = ( SELECT '||lv_LeaveComp||' FROM '||lv_updtable||' B '||CHR(10) 
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||' AND A.YEARCODE = '''||lv_YearCode||'''   '||CHR(10) 
        ||' AND A.YEARMONTH = '''||P_YEARMONTH||''' '||CHR(10)
        ||' AND A.WORKERSERIAL = B.WORKERSERIAL )'||CHR(10)
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||' AND A.YEARMONTH = '''||P_YEARMONTH||'''       '||CHR(10);
     lv_remarks := NVL(lv_remarks,'XX ') ||' UPDATE LDAY_CL,LDAY_PL,LDAY_SL,LVBL_CL,LVBL_PL,LVBL_SL';
    --dbms_output.put_line(lv_sql );   
   INSERT INTO PIS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
   VALUES (P_COMPCODE, P_DIVCODE,lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);
   COMMIT;    
    EXECUTE IMMEDIATE lv_sql;
    
    lv_remarks:='DROP TEMP TABLE';
    EXECUTE IMMEDIATE 'DROP TABLE '||lv_updtable;

EXCEPTION
    WHEN OTHERS THEN
    lv_sqlerrm := sqlerrm;
    INSERT INTO PIS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    VALUES (P_COMPCODE, P_DIVCODE,lv_ProcName,lv_sqlerrm,sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);
end;
/
