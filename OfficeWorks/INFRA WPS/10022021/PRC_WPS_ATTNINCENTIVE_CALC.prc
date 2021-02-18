CREATE OR REPLACE PROCEDURE INFRA_WPS.PRC_WPS_ATTNINCENTIVE_CALC (P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2, 
                                                  P_YEARCODE Varchar2,
                                                  P_FNSTDT Varchar2, 
                                                  P_FNENDT Varchar2,
                                                  P_PHASE  number, 
                                                  P_PHASE_TABLENAME VARCHAR2,
                                                  P_TABLENAME Varchar2,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL,
                                                  P_PROCESSTYPE VARCHAR2 DEFAULT NULL )
AS
lv_Component    varchar2(32767) := '';
lv_Sql          varchar2(32767) := '';
lv_Sql_TblCreate    varchar2(3000) := '';  
lv_sqlerrm      varchar2(1000) := ''; 
lv_remarks      varchar2(1000) := '';
lv_parvalues    varchar2(1000) := '';
lv_SqlTemp      varchar2 (2000) := '';
lv_Cols         varchar2 (1000) := '';
lv_fn_stdt      date := to_date(P_FNSTDT,'DD/MM/YYYY');
lv_fn_endt      date := to_date(P_FNENDT,'DD/MM/YYYY');
lv_NoOfDays     number(5) := 0;
lv_ProcName     varchar2(100) :='PRC_WPS_ATTNINCENTIVE_CALC';
lv_MinimumWorkHrs   number(7,2);
lv_TempTable    varchar2(30) := 'WPSATTNTEMP_INFRA'; 

BEGIN
    
    lv_Sql := 'DROP TABLE '||lv_TempTable||' CASCADE CONSTRAINTS'||CHR(10);
    
    BEGIN
        EXECUTE IMMEDIATE lv_Sql;
        lv_Sql := ' CREATE TABLE '||lv_TempTable||' AS SELECT * FROM WPSATTENDANCEDAYWISE '||CHR(10)
                ||' WHERE COMPANYCODE ='''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                ||'   AND YEARCODE = '''||P_YEARCODE||''' '||CHR(10)
                ||'   AND DATEOFATTENDANCE >= '''||lv_fn_stdt||''' AND DATEOFATTENDANCE <= '''||lv_fn_endt||'''  '||CHR(10);
        insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values(lv_ProcName,lv_sqlerrm,lv_Sql,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
        execute immediate lv_Sql;
        COMMIT;        
                
    EXCEPTION
        WHEN OTHERS THEN
        lv_Sql := ' CREATE TABLE '||lv_TempTable||' AS SELECT * FROM WPSATTENDANCEDAYWISE '||CHR(10)
                ||' WHERE COMPANYCODE ='''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                ||'   AND YEARCODE = '''||P_YEARCODE||''' '||CHR(10)
                ||'   AND DATEOFATTENDANCE >= '''||lv_fn_stdt||''' AND DATEOFATTENDANCE <= '''||lv_fn_endt||'''  '||CHR(10);
                
        insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values(lv_ProcName,lv_sqlerrm,lv_Sql,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
        execute immediate lv_Sql;
        COMMIT;
    END;
    
    lv_remarks := 'TEMP TABLE GBL_ATTN_INCENTIVE DATA PREPARATION FOR ATTENDANCE INCENTIVE';
    lv_MinimumWorkHrs := 96;
    DELETE FROM GBL_ATTN_INCENTIVE;
    
    --PROC_WPSVIEWCREATION ( P_COMPCODE,P_DIVCODE,'MAST',0,P_FNSTDT,P_FNENDT,P_TABLENAME);
    lv_Sql := ' INSERT INTO GBL_ATTN_INCENTIVE (COMPANYCODE, DIVISIONCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERSERIAL, TOKENNO, '||CHR(10) 
            ||' WORKERCATEGORYCODE, ATTENDANCEHOURS, HOLIDAYHOURS, STL_HOURS, LEAVE_HOURS, ATN_INCENTIVE) '||chr(10)
            ||' SELECT '''||P_COMPCODE||''' COMPANYCODE,'''||P_DIVCODE||''' DIVISIONCODE, '''||lv_fn_stdt||''' FORTNIGHTSTARTDATE, '''||lv_fn_endt||''' FORTNIGHTENDDATE, A.WORKERSERIAL, B.TOKENNO, '||CHR(10) 
            ||' B.WORKERCATEGORYCODE, SUM(ATTN_HRS) ATTENDANCEHOURS, SUM(HOL_HRS) HOLIDAYHOURS, SUM(STL_HRS) STL_HOURS,SUM(LV_HRS) LV_HOURS,  '||CHR(10)
            ||' CASE WHEN (SUM(ATTN_HRS) + SUM(HOL_HRS) + SUM(STL_HRS) + SUM(LV_HRS)) >='||lv_MinimumWorkHrs||' THEN NVL(D.ATN_INCENTIVE,0)*(SUM(ATTN_HRS)/8) ELSE 0 END ATN_INCENTIVE  '||CHR(10)
            ||' FROM (  '||CHR(10)
            ||'     SELECT WORKERSERIAL, SUM(ATTN_HRS) ATTN_HRS, SUM(HOL_HRS) HOL_HRS, SUM(STL_HRS) STL_HRS, SUM(LV_HRS) LV_HRS '||CHR(10)
            ||'     FROM ( '||CHR(10)
            ||'             SELECT WORKERSERIAL, SUM(ATTN_DAYS)*8 ATTN_HRS, 0 HOL_HRS, 0 STL_HRS, 0 LV_HRS  '||CHR(10)
            ||'             FROM ( '||CHR(10)
            ||'                 SELECT WORKERSERIAL, DATEOFATTENDANCE, 1 ATTN_DAYS '||CHR(10)
            ||'                 FROM /*WPSATTENDANCEDAYWISE*/ '||lv_TempTable||' A  '||CHR(10)
            ||'                 WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
            ||'                   AND YEARCODE = '''||P_YEARCODE||'''  '||CHR(10)
            ||'                   AND DATEOFATTENDANCE >= '''||lv_fn_stdt||''' AND DATEOFATTENDANCE <= '''||lv_fn_endt||'''  '||CHR(10)
            ||'                 GROUP BY WORKERSERIAL, DATEOFATTENDANCE  '||CHR(10)
            ||'                 HAVING SUM(NVL(ATTENDANCEHOURS,0)) + SUM(NVL(NIGHTALLOWANCEHOURS,0)) >= 8 '||CHR(10)
            ||'               ) '||CHR(10) 
            ||'         GROUP BY WORKERSERIAL '||CHR(10)  
            ||'         UNION ALL  '||CHR(10)
            ||'         SELECT WORKERSERIAL, 0 ATTN_HRS, SUM(NVL(HOLIDAYHOURS,0)) HOL_HRS, 0 STL_HRS, 0 LV_HRS  '||CHR(10)
            ||'         FROM /*WPSATTENDANCEDAYWISE*/ '||lv_TempTable||' A  '||CHR(10)
            ||'         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
            ||'           AND YEARCODE = '''||P_YEARCODE||'''  '||CHR(10)
            ||'           AND DATEOFATTENDANCE >= '''||lv_fn_stdt||''' AND DATEOFATTENDANCE <= '''||lv_fn_endt||'''  '||CHR(10)
            ||'         GROUP BY WORKERSERIAL  '||CHR(10)
            ||'         UNION ALL  '||CHR(10)
            ||'         SELECT WORKERSERIAL, 0 ATTN_HRS, 0 HOL_HRS, CASE WHEN LEAVECODE=''STL'' THEN SUM(LEAVEDAYS)*8 ELSE 0 END STLHRS,  '||CHR(10)
            ||'         CASE WHEN LEAVECODE=''ESI'' THEN SUM(LEAVEDAYS)*8 ELSE 0 END LV_HRS  '||CHR(10)
            ||'         FROM  WPSSTLENTRYDETAILS  '||CHR(10)
            ||'         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
            ||'           AND LEAVEDATE >= '''||lv_fn_stdt||''' AND LEAVEDATE <= '''||lv_fn_endt||'''  '||CHR(10)
            ||'           AND NVL(ISSANCTIONED,''N'') = ''Y''  '||CHR(10)
            ||'         GROUP BY WORKERSERIAL, LEAVECODE  '||CHR(10)
            ||'         ) GROUP BY WORKERSERIAL '||CHR(10)
            ||'     ) A, WPSWORKERMAST B, WPSWORKERCATEGORYMAST C,  '||CHR(10)
            ||' (  '||CHR(10)
            ||'     SELECT X.* FROM WPSWORKERWISERATEUPDATE X,  '||CHR(10)
            ||'     (  '||CHR(10)
            ||'         SELECT WORKERSERIAL, MAX(EFFECTIVEDATE) EFFECTIVEDATE  '||CHR(10)
            ||'         FROM WPSWORKERWISERATEUPDATE  '||CHR(10)
            ||'         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
            ||'           AND EFFECTIVEDATE <= '''||lv_fn_endt||'''  '||CHR(10)
            ||'         GROUP BY WORKERSERIAL   '||CHR(10)
            ||'     ) Y  '||CHR(10)
            ||'     WHERE X.COMPANYCODE = '''||P_COMPCODE||''' AND X.DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
            ||'       AND X.WORKERSERIAL = Y.WORKERSERIAL AND X.EFFECTIVEDATE = Y.EFFECTIVEDATE  '||CHR(10)
            ||' ) D,  '||CHR(10)
            ||' ( '||CHR(10)
            ||'     SELECT M.WORKERCATEGORYCODE '||CHR(10)
            ||'     FROM WPSWORKERCATEGORYVSCOMPONENT M,'||CHR(10)
            ||'     ( '||CHR(10)
            ||'         SELECT WORKERCATEGORYCODE, MAX(EFFECTIVEDATE) EFFECTIVEDATE '||CHR(10)
            ||'         FROM WPSWORKERCATEGORYVSCOMPONENT '||CHR(10)
            ||'         WHERE COMPANYCODE  = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'           AND EFFECTIVEDATE <= '''||lv_fn_endt||'''  '||CHR(10)
            ||'         GROUP BY WORKERCATEGORYCODE '||CHR(10)
            ||'     ) N '||CHR(10)  
            ||'     WHERE M.COMPANYCODE  = '''||P_COMPCODE||''' AND M.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'       AND M.WORKERCATEGORYCODE = N.WORKERCATEGORYCODE AND M.EFFECTIVEDATE =N.EFFECTIVEDATE '||CHR(10)
            ||'       AND M.COMPONENTSHORTNAME = ''ATN_INCENTIVE'' AND NVL(APPLICABLE,''NO'') = ''YES'' '||CHR(10)   
            ||' ) E '||CHR(10)
            ||' WHERE B.COMPANYCODE = '''||P_COMPCODE||''' AND B.DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
            ||'   AND A.WORKERSERIAL = B.WORKERSERIAL  '||CHR(10)
            ||'   AND B.COMPANYCODE = C.COMPANYCODE AND B.DIVISIONCODE = C.DIVISIONCODE  '||CHR(10)
            ||'   AND B.WORKERCATEGORYCODE = C.WORKERCATEGORYCODE   '||CHR(10)
            ||'   AND B.COMPANYCODE = D.COMPANYCODE AND B.DIVISIONCODE = D.DIVISIONCODE  '||CHR(10)
            ||'   AND A.WORKERSERIAL = D.WORKERSERIAL   '||CHR(10)     
            ||'   AND B.WORKERCATEGORYCODE = E.WORKERCATEGORYCODE '||CHR(10)
            ||'   GROUP BY A.WORKERSERIAL, B.TOKENNO, B.WORKERCATEGORYCODE, D.ATN_INCENTIVE  '||CHR(10)
            ||'   HAVING CASE WHEN (SUM(ATTN_HRS) + SUM(HOL_HRS) + SUM(STL_HRS) + SUM(LV_HRS)) >='||lv_MinimumWorkHrs||' THEN NVL(D.ATN_INCENTIVE,0)*(SUM(ATTN_HRS)/8) ELSE 0 END > 0  '||CHR(10);

    insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values(lv_ProcName,lv_sqlerrm,lv_Sql,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
    execute immediate lv_Sql;
    
    lv_remarks := 'UPDATE '||P_TABLENAME||' FOR ATTENDANCE INCENTIVE';
    
    lv_Sql := ' UPDATE '||P_TABLENAME||' A SET  A.ATN_INCENTIVE = (SELECT  SUM(NVL(B.ATN_INCENTIVE,0)) FROM GBL_ATTN_INCENTIVE B '||CHR(10)
            ||' WHERE B.COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
            ||' AND B.FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' AND B.FORTNIGHTENDDATE = '''||lv_fn_endt||'''  '||CHR(10)
            ||' AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE  '||CHR(10)
            ||' AND A.WORKERSERIAL = B.WORKERSERIAL  '||CHR(10)
            ||' )  '||CHR(10)
            ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10) 
            ||'  AND A.FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' AND A.FORTNIGHTENDDATE = '''||lv_fn_endt||'''  '||CHR(10)
            ||'  AND A.WORKERSERIAL IN (SELECT DISTINCT WORKERSERIAL FROM  GBL_ATTN_INCENTIVE  '||CHR(10)
            ||'                         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
            ||'                         AND FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' AND FORTNIGHTENDDATE = '''||lv_fn_endt||''' )  '||CHR(10);

    insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values(lv_ProcName,lv_sqlerrm,lv_Sql,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
    execute immediate lv_Sql;
    commit;
exception
when others then
 lv_sqlerrm := sqlerrm ;
 --dbms_output.put_line(lv_sqlerrm);
 insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
 values( lv_ProcName,lv_sqlerrm,lv_Sql,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
END;
/
