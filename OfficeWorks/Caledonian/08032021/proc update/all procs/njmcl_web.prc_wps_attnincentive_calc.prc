DROP PROCEDURE NJMCL_WEB.PRC_WPS_ATTNINCENTIVE_CALC;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PRC_WPS_ATTNINCENTIVE_CALC (P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2, 
                                                  P_YEARCODE Varchar2,
                                                  P_FNSTDT Varchar2, 
                                                  P_FNENDT Varchar2,
                                                  P_PHASE  number, 
                                                  P_PHASE_TABLENAME VARCHAR2,
                                                  P_TABLENAME Varchar2,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL,
                                                  P_PROCESSTYPE  VARCHAR2 DEFAULT 'WAGES PROCESS' )
AS
lv_Component    varchar2(32767) := '';
lv_Sql          varchar2(32767) := '';
lv_Sql_TblCreate  varchar2(3000) := '';  
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

BEGIN
    
    lv_remarks := '1 TEMP TABLE GBL_ATTN_INCENTIVE DATA PREPARATION FOR ATTENDANCE INCENTIVE';
    --- Naihati consider 88 hours in 2nd fortnight of february 
    if substr(P_FNSTDT,1,5)='16/02' then
        lv_MinimumWorkHrs := 88;
    else
        if P_FNSTDT ='01/06/2020' then
            lv_MinimumWorkHrs := 69;
        else
            lv_MinimumWorkHrs := 96;
        end if;
    end if;   
     
    DELETE FROM GBL_ATTN_INCENTIVE;
    
    --PROC_WPSVIEWCREATION ( P_COMPCODE,P_DIVCODE,'MAST',0,P_FNSTDT,P_FNENDT,P_TABLENAME);
    lv_Sql := ' INSERT INTO GBL_ATTN_INCENTIVE (COMPANYCODE, DIVISIONCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERSERIAL, TOKENNO,  SECTIONCODE,'||CHR(10) 
            ||' WORKERCATEGORYCODE, ATTENDANCEHOURS,NS_HRS, HOLIDAYHOURS, STL_HOURS, LEAVE_HOURS, ATN_INCENTIVE,DEPARTMENTCODE,OCCUPATIONCODE,SHIFTCODE,DEPTSERIAL) '||chr(10)
            ||' SELECT '''||P_COMPCODE||''' COMPANYCODE,'''||P_DIVCODE||''' DIVISIONCODE, '''||lv_fn_stdt||''' FORTNIGHTSTARTDATE, '''||lv_fn_endt||''' FORTNIGHTENDDATE, A.WORKERSERIAL, B.TOKENNO, X.SECTIONCODE,'||CHR(10) 
            ||' B.WORKERCATEGORYCODE, SUM(ATTN_HRS) ATTENDANCEHOURS,SUM(NS_HRS)NS_HRS, SUM(HOL_HRS) HOLIDAYHOURS, SUM(STL_HRS) STL_HOURS,SUM(LV_HRS) LV_HOURS,  '||CHR(10)
            ||' CASE WHEN (SUM(ATTN_HRS)+ SUM(NS_HRS) + SUM(HOL_HRS) + SUM(STL_HRS) + SUM(LV_HRS)) >='||lv_MinimumWorkHrs||' THEN ROUND(NVL(D.ATN_INCENTIVE,0)*((SUM(ATTN_HRS)+SUM(NS_HRS))/8),2) ELSE 0 END ATN_INCENTIVE,X.DEPARTMENTCODE,X.OCCUPATIONCODE,X.SHIFTCODE,X.DEPTSERIAL  '||CHR(10)
            ||' FROM (  '||CHR(10)
--            ||'     SELECT WORKERSERIAL, SUM(ATTN_HRS) ATTN_HRS,SUM(NS_HRS)NS_HRS, SUM(HOL_HRS) HOL_HRS, SUM(STL_HRS) STL_HRS, SUM(LV_HRS) LV_HRS '||CHR(10)
--            ||'     FROM ( '||CHR(10)
--            ||'             SELECT WORKERSERIAL, SUM(nvl(ATTENDANCEHOURS,0)) ATTN_HRS,SUM(nvl(NIGHTALLOWANCEHOURS,0))NS_HRS, SUM(NVL(HOLIDAYHOURS,0)) HOL_HRS, SUM(NVL(ATTN_REWARDS_EXTRAHRS,0)) STL_HRS, 0 LV_HRS  '||CHR(10)
--            ||'             FROM WPSATTENDANCEDAYWISE A  '||CHR(10)
--            ||'                 WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
--            ||'                   AND YEARCODE = '''||P_YEARCODE||'''  '||CHR(10)
--            ||'                   AND DATEOFATTENDANCE >= '''||lv_fn_stdt||''' AND DATEOFATTENDANCE <= '''||lv_fn_endt||'''  '||CHR(10)
--            ||'         GROUP BY WORKERSERIAL '||CHR(10) 
--            ||'         ) GROUP BY WORKERSERIAL'||CHR(10)
            
            ||'         SELECT WORKERSERIAL, SUM(ATTN_HRS) ATTN_HRS,SUM(NS_HRS)NS_HRS, SUM(HOL_HRS) HOL_HRS, SUM(STL_HRS) STL_HRS, SUM(LV_HRS) LV_HRS '||CHR(10) 
            ||'         FROM (  '||CHR(10)
            ||'                 SELECT WORKERSERIAL, nvl(ATTENDANCEHOURS,0) ATTN_HRS, NVL(HOLIDAYHOURS,0) HOL_HRS, NVL(ATTN_REWARDS_EXTRAHRS,0) STL_HRS, 0 LV_HRS, '||CHR(10)
            ||'                 CASE WHEN NVL(B.APPLICABLE_ATN_INCT,''N'') = ''Y'' THEN nvl(NIGHTALLOWANCEHOURS,0) ELSE 0 END NS_HRS   '||CHR(10)
            ||'                 FROM WPSATTENDANCEDAYWISE A, VW_WPSSECTIONMAST B '||CHR(10)
            ||'                 WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10) 
            ||'                   AND A.YEARCODE = '''||P_YEARCODE||'''   '||CHR(10)
            ||'                   AND A.DATEOFATTENDANCE >= '''||lv_fn_stdt||'''  AND A.DATEOFATTENDANCE <= '''||lv_fn_endt||'''  '||CHR(10)
            ||'                   AND A.COMPANYCODE = B.COMPANYCODE (+) AND A.DIVISIONCODE = B.DIVISIONCODE (+) '||CHR(10)
            ||'                   AND A.DEPARTMENTCODE = B.DEPARTMENTCODE (+) AND A.SECTIONCODE = B.SECTIONCODE (+)  '||CHR(10)
            ||'             ) GROUP BY WORKERSERIAL '||CHR(10)
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
            ||' ) E, '||CHR(10)
            ||' (  '||CHR(10)
            ||'    SELECT A.WORKERSERIAL,A.SECTIONCODE,A.DEPARTMENTCODE,A.OCCUPATIONCODE,A.SHIFTCODE,MAX(A.DEPTSERIAL)DEPTSERIAL  '||CHR(10) 
            ||'    FROM '||P_TABLENAME||' A,  '||CHR(10)
            ||'    (  '||CHR(10)
            ||'        SELECT WORKERSERIAL, MAX((NVL(ATTENDANCEHOURS,0)/*+NVL(OVERTIMEHOURS,0)+NVL(NIGHTALLOWANCEHOURS,0)+NVL(HOLIDAYHOURS,0)*/)) ATTENDANCEHOURS  '||CHR(10)
            --||'        /*MAX(SECTIONCODE||DEPARTMENTCODE||DEPTSERIAL)*/MAX(DEPTSERIAL) SEC_DEP_DEPTSRL'||CHR(10)
            ||'        FROM '||P_TABLENAME||'  '||CHR(10)
            ||'        GROUP BY WORKERSERIAL  '||CHR(10)
            ||'    ) B  '||CHR(10)
            ||'    WHERE A.WORKERSERIAL = B.WORKERSERIAL AND (NVL(A.ATTENDANCEHOURS,0)/*+NVL(A.OVERTIMEHOURS,0)+NVL(A.NIGHTALLOWANCEHOURS,0)+NVL(A.HOLIDAYHOURS,0)*/) = B.ATTENDANCEHOURS  '||CHR(10)
             --||'     AND A.DEPTSERIAL=B.SEC_DEP_DEPTSRL'||CHR(10)
            ||'    GROUP BY A.WORKERSERIAL,SECTIONCODE,DEPARTMENTCODE,OCCUPATIONCODE,SHIFTCODE,DEPTSERIAL  '||CHR(10)
            ||' ) X    '||CHR(10)          
            ||' WHERE B.COMPANYCODE = '''||P_COMPCODE||''' AND B.DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
            ||'   AND A.WORKERSERIAL = B.WORKERSERIAL  '||CHR(10)
            ||'   AND B.COMPANYCODE = C.COMPANYCODE AND B.DIVISIONCODE = C.DIVISIONCODE  '||CHR(10)
            ||'   AND B.WORKERCATEGORYCODE = C.WORKERCATEGORYCODE   '||CHR(10)
            ||'   AND B.COMPANYCODE = D.COMPANYCODE AND B.DIVISIONCODE = D.DIVISIONCODE  '||CHR(10)
            ||'   AND A.WORKERSERIAL = D.WORKERSERIAL   '||CHR(10)     
            ||'   AND B.WORKERCATEGORYCODE = E.WORKERCATEGORYCODE '||CHR(10)
            ||'   AND A.WORKERSERIAL = X.WORKERSERIAL '||CHR(10)
            ||'   GROUP BY A.WORKERSERIAL, B.TOKENNO, B.WORKERCATEGORYCODE, D.ATN_INCENTIVE,X.SECTIONCODE,X.DEPARTMENTCODE,X.OCCUPATIONCODE,X.SHIFTCODE,X.DEPTSERIAL  '||CHR(10)
            ||'   HAVING (CASE WHEN (SUM(ATTN_HRS)+ SUM(NS_HRS) + SUM(HOL_HRS) + SUM(STL_HRS) + SUM(LV_HRS)) >='||lv_MinimumWorkHrs||' THEN NVL(D.ATN_INCENTIVE,0)*((SUM(ATTN_HRS)+SUM(NS_HRS))/8) ELSE 0 END) > 0'||CHR(10);
    insert into WPS_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values(P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_Sql,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
    execute immediate lv_Sql;
    
    lv_remarks := '2 INSERT INTO GBL_ATTN_INCEN_UPD FOR ATTENDANCE INCENTIVE';
    DELETE FROM GBL_ATTN_INCEN_UPD;
    
     lv_Sql := 'INSERT INTO GBL_ATTN_INCEN_UPD'||CHR(10)
     ||'SELECT * FROM('||CHR(10)
--     ||'SELECT TOTALHOURS,ROW_NUMBER() OVER(PARTITION BY WORKERSERIAL order by WORKERSERIAL DESC )SRL,'||CHR(10)
--     ||'FORTNIGHTSTARTDATE,FORTNIGHTENDDATE,DEPARTMENTCODE,SECTIONCODE,'||CHR(10)
--     ||'OCCUPATIONCODE,SHIFTCODE,WORKERSERIAL,DEPTSERIAL,ATN_INCENTIVE FROM('||CHR(10)
     ||'SELECT'||CHR(10)
     ||'MAX(NVL(ATTENDANCEHOURS,0)+NVL(OVERTIMEHOURS,0)+NVL(NIGHTALLOWANCEHOURS,0)+NVL(HOLIDAYHOURS,0))TOTALHOURS,'||CHR(10)
     ||'ROW_NUMBER() OVER(PARTITION BY WORKERSERIAL order by'||CHR(10)
     ||'WORKERSERIAL,MAX(NVL(ATTENDANCEHOURS,0)/*+NVL(OVERTIMEHOURS,0)+NVL(NIGHTALLOWANCEHOURS,0)+NVL(HOLIDAYHOURS,0)*/)DESC,DEPTSERIAL DESC )SRL,'||CHR(10)
     ||'FORTNIGHTSTARTDATE,FORTNIGHTENDDATE,DEPARTMENTCODE,SECTIONCODE,'||CHR(10)
     ||'OCCUPATIONCODE,SHIFTCODE,WORKERSERIAL,DEPTSERIAL,0 ATN_INCENTIVE FROM '||P_TABLENAME||''||CHR(10)
     ||'WHERE 1=1'||CHR(10)
     ||'AND COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10) 
     ||'AND FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' AND FORTNIGHTENDDATE = '''||lv_fn_endt||'''  '||CHR(10)
     ||'GROUP BY FORTNIGHTSTARTDATE,FORTNIGHTENDDATE,DEPARTMENTCODE,SECTIONCODE,'||CHR(10)
     ||'OCCUPATIONCODE,SHIFTCODE,WORKERSERIAL,DEPTSERIAL'||CHR(10)
     ||'ORDER BY MAX(NVL(ATTENDANCEHOURS,0)/*+NVL(OVERTIMEHOURS,0)+NVL(NIGHTALLOWANCEHOURS,0)+NVL(HOLIDAYHOURS,0)*/) DESC'||CHR(10)
     ||')'||CHR(10)
     --||')'||CHR(10)
     ||'WHERE 1=1'||CHR(10)
     ||'AND SRL=1'||CHR(10);

    insert into WPS_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values(P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_Sql,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
    execute immediate lv_Sql;
    
    lv_remarks := '3 UPDATE ATN_INCENTIVE INTO  GBL_ATTN_INCEN_UPD FOR ATTENDANCE INCENTIVE';
     lv_Sql := 'UPDATE GBL_ATTN_INCEN_UPD A SET ATN_INCENTIVE='||CHR(10)
     ||'('||CHR(10)
     ||'SELECT NVL(ATN_INCENTIVE,0) FROM GBL_ATTN_INCENTIVE B'||CHR(10)
     ||'WHERE A.FORTNIGHTSTARTDATE=B.FORTNIGHTSTARTDATE'||CHR(10)
     ||'  AND A.FORTNIGHTENDDATE=B.FORTNIGHTENDDATE'||CHR(10)
     ||'  AND A.DEPARTMENTCODE=B.DEPARTMENTCODE'||CHR(10)
     ||'  AND A.SECTIONCODE=B.SECTIONCODE'||CHR(10)
     ||'  AND A.OCCUPATIONCODE=B.OCCUPATIONCODE'||CHR(10)
     ||'  AND A.SHIFTCODE=B.SHIFTCODE'||CHR(10)
     ||'  AND A.DEPTSERIAL=B.DEPTSERIAL'||CHR(10)
     ||'  AND A.WORKERSERIAL=B.WORKERSERIAL'||CHR(10)
     ||')'||CHR(10)
     ||'WHERE 1=1'||CHR(10)
     ||'AND A.WORKERSERIAL IN'||CHR(10)
     ||'('||CHR(10)
     ||'SELECT DISTINCT WORKERSERIAL FROM GBL_ATTN_INCENTIVE'||CHR(10)
     ||')'||CHR(10)
     ||'AND FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' AND FORTNIGHTENDDATE = '''||lv_fn_endt||''''||CHR(10);
     
    insert into WPS_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values(P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_Sql,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
    execute immediate lv_Sql;
    
    lv_remarks := '4 DELETE ATN_INCENTIVE=0 FROM  GBL_ATTN_INCEN_UPD FOR ATTENDANCE INCENTIVE';
    lv_Sql := 'DELETE FROM GBL_ATTN_INCEN_UPD WHERE NVL(ATN_INCENTIVE,0)=0'||CHR(10);
    
    insert into WPS_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values(P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_Sql,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
    execute immediate lv_Sql;

    lv_remarks := '5 UPDATE '||P_TABLENAME||' FOR ATTENDANCE INCENTIVE';
    
    lv_Sql := ' UPDATE '||P_TABLENAME||' A SET  A.ATN_INCENTIVE = (SELECT  NVL(B.ATN_INCENTIVE,0) FROM GBL_ATTN_INCEN_UPD B '||CHR(10)
    ||' WHERE 1=1'||CHR(10)
     ||' AND A.DEPARTMENTCODE = B.DEPARTMENTCODE AND A.OCCUPATIONCODE = B.OCCUPATIONCODE  '||CHR(10)
     ||' AND A.WORKERSERIAL = B.WORKERSERIAL AND A.SECTIONCODE = B.SECTIONCODE '||CHR(10)
     ||' AND A.SHIFTCODE = B.SHIFTCODE AND A.DEPTSERIAL = B.DEPTSERIAL '||CHR(10)
     ||' )  '||CHR(10)
     ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10) 
     ||'  AND A.FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' AND A.FORTNIGHTENDDATE = '''||lv_fn_endt||'''  '||CHR(10)
     ||'  AND A.WORKERSERIAL IN (SELECT DISTINCT WORKERSERIAL FROM  GBL_ATTN_INCEN_UPD  '||CHR(10)
     ||'                         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
     ||'                         AND FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' AND FORTNIGHTENDDATE = '''||lv_fn_endt||''' )  '||CHR(10)
     ||'AND ROWID  IN'||CHR(10)
     ||'( SELECT MIN(rowid) FROM '||P_TABLENAME||' '||CHR(10)
     ||'WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''''||CHR(10)
     ||'AND FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' AND FORTNIGHTENDDATE = '''||lv_fn_endt||''''||CHR(10)
     ||' GROUP BY WORKERSERIAL,DEPARTMENTCODE, OCCUPATIONCODE,SECTIONCODE,SHIFTCODE,DEPTSERIAL'||CHR(10)
     ||')'||CHR(10);
    

    insert into WPS_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values(P_COMPCODE, P_DIVCODE,lv_ProcName,lv_sqlerrm,lv_Sql,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
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


