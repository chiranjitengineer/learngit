CREATE OR REPLACE PROCEDURE FORTWILLIAM_WPS.PROC_WPSWAGESPROCESS_UPDATE (P_COMPCODE Varchar2, 
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

begin
    lv_parvalues := 'DIV = '||P_DIVCODE||', FNE = '||P_FNENDT||', PHASE = '||P_PHASE;
    lv_sql := 'drop table '||P_PHASE_TABLENAME;
    
    BEGIN 
        execute immediate lv_sql;
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    
    lv_Sql_TblCreate := 'CREATE TABLE '||P_PHASE_TABLENAME||'(WORKERSERIAL VARCHAR2(10), DEPARTMENTCODE VARCHAR2(10), SHIFTCODE VARCHAR2(10)';
            
    FOR C1 in (
            SELECT COMPONENTCODE, COMPONENTSHORTNAME, COMPONENTTYPE, AMOUNTORFORMULA, MANUALFORAMOUNT, FORMULA, CALCULATIONINDEX, PHASE, 
            NVL(TAKEPARTINWAGES,'N') AS TAKEPARTINWAGES, NVL(COLUMNINATTENDANCE,'N') AS COLUMNINATTENDANCE, 
            NVL(COMPONENTTAG,'N') AS COMPONENTTAG, NVL(COMPONENTGROUP,'N') AS COMPONENTGROUP 
            FROM WPSCOMPONENTMASTER
            WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
            AND PHASE = P_PHASE
            AND NVL(TAKEPARTINWAGES,'N') = 'Y'
            AND NVL(MISCPAYMENT,'N') = NVL2(CASE WHEN P_PROCESSTYPE ='DAILY WAGES PROCESS' THEN 'XXX' ELSE NULL END,'Y','N')
          )
    LOOP          
       -- DBMS_OUTPUT.PUT_LINE('COMPONENT : '||lv_AttnComponent);
       lv_Sql_TblCreate := lv_Sql_TblCreate ||', '||C1.COMPONENTSHORTNAME|| ' NUMBER(11,2) DEFAULT 0'; 
        IF UPPER(TRIM(C1.AMOUNTORFORMULA)) = 'FORMULA' THEN
            If InStr(C1.FORMULA, '~') > 0 Then
                --dbms_output.put_line(C1.FORMULA);
                lv_Sql:= C1.FORMULA;
                --select REPLACE('''A001''','''','''''')  FROM DUAL
                lv_Sql:= replace(lv_Sql,'''','''''');
                lv_Sql:= 'SELECT FN_REPL_FORMULA('''||lv_Sql||''') FROM DUAL'; 
                
                --BEGIN
                EXECUTE IMMEDIATE lv_Sql into lv_SqlTemp ;
                --EXCEPTION WHEN OTHERS THEN
                --    insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) values( 'ZZZ PROC_WPSWAGESPROCESS_UPDATE',lv_Sql,lv_Sql,lv_parvalues,lv_remarks);
                --    RETURN;
                --END ;
                lv_Component := lv_Component ||', SUM('||lv_SqlTemp||')  AS '||C1.COMPONENTSHORTNAME;
            ELSE
                lv_Component := lv_Component ||', SUM('||C1.FORMULA||') AS '|| C1.COMPONENTSHORTNAME;    
            END IF;
            
        ELSE
            lv_Component := lv_Component ||', SUM(NVL(ATTN.'||C1.COMPONENTSHORTNAME||',0)) AS '|| C1.COMPONENTSHORTNAME;
        END IF; 
    END loop;
    lv_Sql_TblCreate := lv_Sql_TblCreate ||')';
    --insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) values( '2 PROC_WPSWAGESPROCESS_UPDATE',lv_Sql_TblCreate,lv_Sql_TblCreate,lv_parvalues,lv_remarks);
    --BEGIN
    --execute immediate lv_Sql_TblCreate;
    --EXCEPTION WHEN OTHERS THEN
    --   insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) values( '2 PROC_WPSWAGESPROCESS_UPDATE EXCEPTION',lv_Sql_TblCreate,lv_Sql_TblCreate,lv_parvalues,lv_remarks);
    --END; 
    --- CREATE TABLE WPSCOMPONENT AS PER VIEW GENERATE BASED ON COMPONENT ----
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE WPSTEMPCOMPONENT CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'CREATE TABLE WPSTEMPCOMPONENT AS SELECT * FROM COMPONENT';
      EXCEPTION WHEN OTHERS THEN 
        EXECUTE IMMEDIATE 'CREATE TABLE WPSTEMPCOMPONENT AS SELECT * FROM COMPONENT';
    END;
    
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE '||P_PHASE_TABLENAME||' CASCADE CONSTRAINTS';
      EXCEPTION WHEN OTHERS THEN NULL;
    END;    
        
    lv_Component :=  Replace(lv_Component, 'ATTN', 'WPSTEMPATTN');
    lv_Component := Replace(lv_Component, 'MAST', 'WPSTEMPMAST');
    lv_Component := Replace(lv_Component, 'COMPONENT', 'WPSTEMPCOMPONENT');
    lv_Component := Replace(lv_Component, 'FNPARAM', 'WPSTEMPFNPARAM');
    
    lv_Sql := 'CREATE TABLE '||P_PHASE_TABLENAME||' AS '||CHR(10)
            || 'SELECT WPSTEMPATTN.WORKERSERIAL,/* WPSTEMPATTN.DEPARTMENTCODE,*/ WPSTEMPMAST.WORKERCATEGORYCODE, '||CHR(10)  
            ||' SUM(WPSTEMPATTN.ATTENDANCEHOURS) ATTENDANCEHOURS, SUM(WPSTEMPATTN.STLHOURS) STLHOURS /* STATUTORYHOURS */, SUM(WPSTEMPATTN.OVERTIMEHOURS) OVERTIMEHOURS, ' ||chr(10)
            ||' SUM(WPSTEMPATTN.HOLIDAYHOURS) HOLIDAYHOURS '||chr(10) 
            ||' '|| lv_Component ||chr(10) 
            ||' FROM WPSTEMPMAST, WPSTEMPATTN, WPSTEMPCOMPONENT /*, WPSTEMPFNPARAM */'||chr(10)   
            ||' WHERE WPSTEMPATTN.WORKERSERIAL = WPSTEMPMAST.WORKERSERIAL '||chr(10) 
            ||'   AND WPSTEMPATTN.WORKERSERIAL = WPSTEMPCOMPONENT.WORKERSERIAL  '||chr(10)
            ||' /*  AND WPSTEMPATTN.DEPARTMENTCODE = WPSTEMPCOMPONENT.DEPARTMENTCODE */'||chr(10);
    IF P_PROCESSTYPE = 'DAILY WAGES PROCESS' THEN  --- NEW ADD BY AMALESH ON 16/02/2021
            lv_Sql := lv_Sql ||'   AND WPSTEMPATTN.DEPARTMENTCODE = WPSTEMPCOMPONENT.DEPARTMENTCODE '||CHR(10)
                             ||'   AND WPSTEMPATTN.SHIFTCODE = WPSTEMPCOMPONENT.SHIFTCODE '||CHR(10);
    end if;         
    if P_WORKERSERIAL is not null then
        lv_Sql := lv_Sql ||'   AND WPSTEMPMAST.WORKERSERIAL IN ('||P_WORKERSERIAL||')' ||CHR(10); 
    end if; 
    lv_Sql := lv_Sql ||' GROUP BY WPSTEMPATTN.WORKERSERIAL,/* WPSTEMPATTN.DEPARTMENTCODE,*/ WPSTEMPMAST.WORKERCATEGORYCODE '||chr(10);        
    insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_UPDATE','',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, 'PHASE TABLE CREATION');
    EXECUTE IMMEDIATE lv_Sql;  
    COMMIT;
--    insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) values( '3 PROC_WPSWAGESPROCESS_UPDATE',lv_Sql,lv_Sql,lv_parvalues,lv_remarks);
      
    PROC_WPS_UPDATE_NA_COMP(P_FNSTDT, P_FNENDT, P_PHASE_TABLENAME,P_TABLENAME,'YES');
    lv_remarks := 'PHASE - '||P_PHASE||' SUCESSFULLY COMPLETE';
    insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_UPDATE','','',lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
commit;    
exception
    when others then
    lv_sqlerrm := sqlerrm ;
    insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_UPDATE',lv_Sql,lv_Sql,lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
    commit;
    --dbms_output.put_line('PROC - PROC_WPSWAGESPROCESS_UPDATE : ERROR !! WHILE WAGES PROCESS '||P_FNSTDT||' AND PHASE -> '||ltrim(trim(P_PHASE))||' : '||sqlerrm);
end;
/
