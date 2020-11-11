CREATE OR REPLACE PROCEDURE KARNAFULI.PROC_GPSWAGESPROCESS_INSERT ( P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2, 
                                                  P_PROCESSTYPE Varchar2 default null,
                                                  P_YEARCODE Varchar2,
                                                  P_FNSTDT Varchar2, 
                                                  P_FNENDT Varchar2,
                                                  P_EFFECT_FNEDT    Varchar2,
                                                  P_PHASE  number, 
                                                  P_PHASE_TABLENAME Varchar2,
                                                  P_TABLENAME Varchar2,
                                                  P_USERNAME    VARCHAR2 DEFAULT 'SWT',
                                                  P_CATEGORYTYPE VARCHAR2 DEFAULT 'WORKER',
                                                  P_CATEGORYCODE    Varchar2 default NULL,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL)
as 
lv_fn_stdt DATE := TO_DATE(P_FNSTDT,'DD/MM/YYYY');
lv_fn_endt DATE := TO_DATE(P_FNENDT,'DD/MM/YYYY');
lv_TableName        varchar2(50);
lv_Remarks          varchar2(1000) := '';
lv_SqlStr           varchar2(4000);
lv_AttnComponent    varchar2(4000) := ''; 
lv_CompWithZero     varchar2(1000) := '';
lv_CompWithValue    varchar2(4000) := '';
lv_CompCol          varchar2(1000) := '';
lv_MastComponent    varchar2(4000) := '';
lv_MastComponentGroupBy    varchar2(4000) := '';
lv_MastComponent_RT varchar2(4000) := '';
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';
lv_ProcName         varchar2(30) := 'PROC_GPSWAGESPROCESS_INSERT';
lv_ProcessType      VARCHAR2(50) := '';   

begin
    
    --PROC_WPSVBPROCEES_WORKORDER(P_COMPCODE,P_DIVCODE,'SWT',P_YEARCODE,P_FNSTDT,P_FNENDT, NULL);
    --- WRITING HERE ELP AND DELP CALCULATION ----

    --- ADD ON 18/11/2019 BY AMALESH ---
    if P_PROCESSTYPE = 'DAILY' THEN
        lv_ProcessType := 'DAILY PROCESS';
    ELSIF P_PROCESSTYPE = 'CASH' THEN
        lv_ProcessType := 'CASH';
    ELSIF P_PROCESSTYPE = 'CASHOT' THEN
        lv_ProcessType := 'CASHOT';
    ELSIF P_PROCESSTYPE = 'CASHEVENING' THEN
        lv_ProcessType := 'CASHEVENING';
    ELSIF P_PROCESSTYPE = 'ARREAR' THEN
        lv_ProcessType := 'NEW DAILY PROCESS';
    ELSE
        lv_ProcessType := 'WAGES PROCESS';
    END IF;    
--- END ADD ON 18/11/2019 BY AMALESH ---
    
    if P_PROCESSTYPE = 'DAILY' OR P_PROCESSTYPE = 'CASH' OR P_PROCESSTYPE = 'CASHOT' THEN
        lv_SqlStr := 'TRUNCATE TABLE GPSDAILYPAYSHEETDETAILS_SWT';
    else
        lv_SqlStr := 'TRUNCATE TABLE GPSDAILYPAYSHEETDETAILS_SWT';
    end if;
    execute immediate lv_sqlStr;
    lv_SqlStr := '';
    --DBMS_OUTPUT.PUT_LINE ('1_0');
    --- BELOW PROCEDURE CALL STL DATA TRANSFER INTO ATTENDNACE TABLE --------
    --PROC_STL_DATATRANSFER_ATTN ( P_COMPCODE,P_DIVCODE,P_FNSTDT,P_FNENDT,P_WORKERSERIAL);
    
    PROC_GPSVIEWCREATION ( P_COMPCODE,P_DIVCODE,'ALL',0,P_FNSTDT,P_FNENDT,P_TABLENAME, P_PROCESSTYPE);
    ----- CREATE TABLE WMPTEMPMAST FROM THE VIEW MAST
    
    
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE GPSTEMPMAST CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'CREATE TABLE GPSTEMPMAST AS SELECT * FROM GPSMAST_VW';
      EXCEPTION WHEN OTHERS THEN 
        EXECUTE IMMEDIATE 'CREATE TABLE GPSTEMPMAST AS SELECT * FROM GPSMAST_VW';
    END;
    --DBMS_OUTPUT.PUT_LINE ('2_0');
    ----- CREATE TABLE WMPTEMPATTN FROM THE VIEW ATTN
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE GPSTEMPATTN CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'CREATE TABLE GPSTEMPATTN AS SELECT * FROM GPSATTN_VW';
      EXCEPTION WHEN OTHERS THEN 
        EXECUTE IMMEDIATE 'CREATE TABLE GPSTEMPATTN AS SELECT * FROM GPSATTN_VW';
    END; 
    --DBMS_OUTPUT.PUT_LINE ('2_1');
    ----- CREATE TABLE WMPTEMPCATE FROM THE VIEW VW_GPSCATEGORYMAST
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE GPSTEMPCAT CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'CREATE TABLE GPSTEMPCAT AS SELECT * FROM VW_GPSCATEGORYMAST';
      EXCEPTION WHEN OTHERS THEN 
        EXECUTE IMMEDIATE 'CREATE TABLE GPSTEMPCAT AS SELECT * FROM VW_GPSCATEGORYMAST';
    END;
    --DBMS_OUTPUT.PUT_LINE ('2_2');
    ------ CREATE TABLE WMPTEMPOCP FROM THE VIEW VW_GPSOCPUPATIONMAST
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE GPSTEMPOCP CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'CREATE TABLE GPSTEMPOCP AS SELECT * FROM VW_GPSOCCUPATIONMAST';
      EXCEPTION WHEN OTHERS THEN 
        EXECUTE IMMEDIATE 'CREATE TABLE GPSTEMPOCP AS SELECT * FROM VW_GPSOCCUPATIONMAST';
    END;
    --DBMS_OUTPUT.PUT_LINE ('2_3');

    lv_MastComponent := '';
    lv_MastComponent_RT := '';
    for c1 in ( SELECT COMPONENTCODE FROM GPSCOMPONENTMAST 
                 WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                   AND NVL(INCLUDEPAYROLL,'N') ='Y' AND NVL(ROLLOVERAPPLICABLE,'N') = 'Y'
              )
    LOOP
        IF LENGTH(NVL(lv_MastComponent,'N')) > 1 THEN
            lv_MastComponent := lv_MastComponent||',NVL(B.'||c1.COMPONENTCODE||',0) AS '||c1.COMPONENTCODE;
            lv_MastComponentGroupBy := lv_MastComponentGroupBy||',NVL(B.'||c1.COMPONENTCODE||',0)';
            lv_MastComponent_RT := lv_MastComponent_RT||','||c1.COMPONENTCODE||'_RT';
        ELSE
            lv_MastComponent := 'NVL(B.'||c1.COMPONENTCODE||',0) AS '||c1.COMPONENTCODE ;
            lv_MastComponentGroupBy := 'NVL(B.'||c1.COMPONENTCODE||',0)';
            lv_MastComponent_RT := c1.COMPONENTCODE||'_RT';
        END IF;    
    END LOOP;                   
    lv_Remarks := P_PROCESSTYPE||' DATA INSERT';
    
    IF lv_MastComponent_RT IS NOT NULL THEN
        lv_MastComponent_RT := lv_MastComponent_RT||', ';
        lv_MastComponent := lv_MastComponent||', ';
    END IF;
    lv_MastComponent_RT := NULL;        -- TEMPORARY PEURPOSE NEED TO DISCUSS GD
    lv_MastComponent := NULL;           -- TEMPORARY PEURPOSE NEED TO DISCUSS GD
    DBMS_OUTPUT.PUT_LINE('CATEGORY TYPE - '||NVL(P_CATEGORYTYPE,'SWT')||', CAGEGORYCODE - '||NVL(P_CATEGORYCODE,'SWT'));
    lv_SqlStr := ' INSERT INTO '||P_TABLENAME||' ( '||CHR(10)
            ||'    COMPANYCODE, DIVISIONCODE, SYSROWID, PROCESSTYPE, YEARCODE, PERIODFROM, PERIODTO, ATTENDANCEDATE, '||CHR(10)
            ||'    WORKERSERIAL, TOKENNO, CATEGORYCODE, CATEGORYTYPE, OCCUPATIONCODE,'||CHR(10)
            ||'    CLUSTERCODE, AREACLASSIFICATIONCODE, ATTNBOOKCODE, ATTN_CALCF, '||CHR(10)
            ||'    '||lv_MastComponent_RT||' '||CHR(10) 
            ||'    ATTENDANCEHOURS, OVERTIMEHOURS, HAZIRA, TOTALOUTPUT '||CHR(10) 
            ||'    ) '||CHR(10)
            ||'    SELECT A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL SYSROWID, '''||lv_ProcessType||''', '''||P_YEARCODE||''',  '''||lv_fn_stdt||''','''||lv_fn_endt||''', '''||lv_fn_stdt||''',  '||CHR(10)
            ||'    A.WORKERSERIAL, A.TOKENNO, A.CATEGORYCODE, A.CATEGORYTYPE, A.OCCUPATIONCODE,  '||CHR(10)
            ||'    A.CLUSTERCODE, A.AREACLASSIFICATIONCODE, A.ATTNBOOKCODE, DECODE(NVL(B.ATTN_CALCF,0),0,TO_NUMBER(SUBSTR(LAST_DAY('''||lv_fn_stdt||'''),1,2)),NVL(B.ATTN_CALCF,0)) ATTN_CALCF,'||CHR(10)
            ||'       '||lv_MastComponent||' '||CHR(10)            
            ||'       SUM(ATTENDANCEHOURS) ATTENDANCEHOURS, SUM(NVL(OVERTIMEHOURS,0)) OVERTIMEHOURS,  SUM(NVL(HAZIRA,0)) HAZIRA, SUM(NVL(TOTALOUTPUT,0)) TOTALOUTPUT '||CHR(10)
            ||'    FROM '||CHR(10) 
            ||'    ( '||CHR(10)
            ||'        SELECT Z.COMPANYCODE, Z.DIVISIONCODE, Z.WORKERSERIAL, Z.TOKENNO,Z.CATEGORYCODE, Z.CATEGORYTYPE, Z.OCCUPATIONCODE, '||CHR(10)
            ||'        Z.CLUSTERCODE, Z.AREACLASSIFICATIONCODE, Z.ATTNBOOKCODE,'||CHR(10)
            ||'        SUM(ATTENDANCEHOURS) ATTENDANCEHOURS, SUM(OVERTIMEHOURS) OVERTIMEHOURS, SUM(NVL(HAZIRA,0)) HAZIRA, SUM(NVL(TOTALOUTPUT,0)) TOTALOUTPUT  '||CHR(10)
            ||'        FROM (  '||CHR(10)
            ||'               SELECT A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, A.TOKENNO,A.CATEGORYCODE, A.CATEGORYTYPE, CASE WHEN ''WAGES PROCESS'' = '''||P_PROCESSTYPE||''' THEN ''SYSTEM'' ELSE A.OCCUPATIONCODE END OCCUPATIONCODE,  '||CHR(10)
            ||'               A.CLUSTERCODE, A.AREACLASSIFICATIONCODE1 AREACLASSIFICATIONCODE, A.ATTNBOOKCODE, '||CHR(10) 
            ||'               NVL(ATTENDANCEHOURS,0) ATTENDANCEHOURS, NVL(OVERTIMEHOURS,0) OVERTIMEHOURS,   '||CHR(10)  
            ||'               NVL(HAZIRA,0) HAZIRA, (NVL(OUTPUTFORTHEDAY1,0)+NVL(OUTPUTFORTHEDAY2,0)+NVL(OUTPUTFORTHEDAY3,0)+NVL(OUTPUTFORTHEDAY4,0)+NVL(OUTPUTFORTHEDAY5,0)) TOTALOUTPUT   '||CHR(10)
            ||'               FROM GPSATTENDANCEDETAILS A   '||CHR(10)
            ||'               WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10) 
            ||'                 AND A.ATTENDANCEDATE >= '''||lv_fn_stdt||''' AND A.ATTENDANCEDATE <= '''||lv_fn_endt||''' '||CHR(10);
    if P_PROCESSTYPE = 'CASH' THEN
        --- CHANGES ON 18/11/2019 BY AMALESH DUE TO ATTENDANCE TYPE CASH AND CASHOT PAID IN SAME PROCESS
         --lv_SqlStr := lv_SqlStr ||'                 AND A.ATTENDANCETYPE = ''CASH'' '||CHR(10);
         lv_SqlStr := lv_SqlStr ||'                 AND A.ATTENDANCETYPE LIKE ''%CASH%'' '||CHR(10);
         lv_SqlStr := lv_SqlStr ||'                 AND A.ATTENDANCETYPE <> ''CASHOT'' '||CHR(10);
    ELSIF P_PROCESSTYPE = 'CASHOT' THEN
        lv_SqlStr := lv_SqlStr ||'                 AND A.ATTENDANCETYPE = ''CASHOT'' '||CHR(10);
    ELSIF P_PROCESSTYPE = 'PLCASH' THEN
        lv_SqlStr := lv_SqlStr ||'                 AND A.ATTENDANCETYPE = ''CASHEVENING'' '||CHR(10);
    ELSE
        --- CHANGES ON 18/11/2019 BY AMALESH DUE TO ATTENDANCE TYPE NORMAL AND NORMALOT PAID IN SAME PROCESS
        --lv_SqlStr := lv_SqlStr ||'                 AND A.ATTENDANCETYPE = ''NORMAL'' '||CHR(10);
        lv_SqlStr := lv_SqlStr ||'                 AND A.ATTENDANCETYPE LIKE ''%NORMAL%'' '||CHR(10);
    END IF;    
    if NVL(P_CATEGORYTYPE,'SWT') <> 'SWT' THEN
        lv_SqlStr := lv_SqlStr ||'                 AND CATEGORYTYPE = '''||P_CATEGORYTYPE||''' '||CHR(10);
    END IF;            
    if NVL(P_CATEGORYCODE,'SWT') <> 'SWT' THEN
        lv_SqlStr := lv_SqlStr ||'                 AND CATEGORYCODE = '''||P_CATEGORYCODE||''' '||CHR(10); 
    END IF;     
    lv_SqlStr := lv_SqlStr ||'              ) Z '||CHR(10)
            ||'        GROUP BY COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, CATEGORYCODE, CATEGORYTYPE, OCCUPATIONCODE, '||CHR(10)
            ||'           CLUSTERCODE, AREACLASSIFICATIONCODE, ATTNBOOKCODE '||CHR(10)    
            ||'    ) A, GPSTEMPMAST B '||CHR(10) 
            ||'    WHERE A.COMPANYCODE =  '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10) 
            ||'      AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE  '||CHR(10)
            ||'      AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10);
    
      --      ||'      AND A.WORKERCATEGORYCODE IN ('||P_CATEGORYCODE||') '||CHR(10)  --- NEW ADD ON 13.11.2108     
            
--    IF NVL(P_CATEGORYCODE,'SWT') <> 'SWT' THEN
--        LV_SQLSTR := LV_SQLSTR  ||'      AND A.WORKERCATEGORYCODE IN ('||P_CATEGORYCODE||') '||CHR(10) ; --- NEW ADD ON 13.11.2108     
--    END IF;                  
            
      lv_SqlStr := lv_SqlStr   ||'    GROUP BY A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, A.TOKENNO, A.CATEGORYCODE, A.CATEGORYTYPE, A.OCCUPATIONCODE,'||CHR(10)
            ||'      A.CLUSTERCODE, A.AREACLASSIFICATIONCODE, A.ATTNBOOKCODE, NVL(B.ATTN_CALCF,0),'||CHR(10)
            ||'            '||lv_MastComponentGroupBy||' '||CHR(10)
            ||'    HAVING  SUM(NVL(HAZIRA,0))> 0 '||CHR(10);
             
    insert into GPS_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
    COMMIT;
    execute immediate lv_SqlStr;
    ---- UPDATE NOT APPLCICABLE COLUMN TO ZERO AS PER CATEGORY VS COMPONENT MAPPING FOR THE PHSE 0 OR INSERT 
    --PROC_WPS_UPDATE_NA_COMP(P_FNSTDT, P_FNENDT, P_TABLENAME,P_TABLENAME,'NO');
    --insert into GPS_ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,'','',lv_parvalues,lv_fn_stdt,lv_fn_endt, 'PROCESS INSERT SUCCESSFULLY COMPLETE');
    COMMIT;
    RETURN;
exception
when others then
 --insert into error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) values( 'ERROR SQL',lv_sqlstr,lv_sqlstr,lv_parvalues,lv_remarks);
 lv_sqlerrm := sqlerrm ;
 --dbms_output.put_line(lv_sqlerrm);
 insert into GPS_ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
 COMMIT;
end;
/