DROP PROCEDURE NJMCL_WEB.PROC_WPSWAGESPRO_INSERT;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PROC_WPSWAGESPRO_INSERT" ( P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2, 
                                                  P_YEARCODE Varchar2,
                                                  P_FNSTDT Varchar2, 
                                                  P_FNENDT Varchar2,
                                                  P_PHASE  number, 
                                                  P_PHASE_TABLENAME Varchar2,
                                                  P_TABLENAME Varchar2,
                                                  P_WORKKERSERIAL VARCHAR2 DEFAULT NULL)
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
lv_SQLCompView      varchar2(4000) := '';
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';   

begin
    
    PROC_WPSVBPROCEES_WORKORDER(P_COMPCODE,P_DIVCODE,'SWT',P_YEARCODE,P_FNSTDT,P_FNENDT, NULL);

    lv_SqlStr := 'TRUNCATE TABLE WPSWAGESDETAILS_SWT';
    execute immediate lv_sqlStr;
    
    lv_SqlStr := 'TRUNCATE TABLE WPSWAGESDETAILS_MV_SWT';
    execute immediate lv_sqlStr;
    
    PROC_WPSVIEWCREATION ( P_COMPCODE,P_DIVCODE,'ALL',0,P_FNSTDT,P_FNENDT,P_TABLENAME);
    ----- CREATE TABLE WMPTEMPMAST FROM THE VIEW MAST
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE WPSTEMPMAST CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'CREATE TABLE WPSTEMPMAST AS SELECT * FROM MAST';
      EXCEPTION WHEN OTHERS THEN 
        EXECUTE IMMEDIATE 'CREATE TABLE WPSTEMPMAST AS SELECT * FROM MAST';
    END;
    
    ----- CREATE TABLE WMPTEMPATTN FROM THE VIEW ATTN
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE WPSTEMPATTN CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'CREATE TABLE WPSTEMPATTN AS SELECT * FROM ATTN';
      EXCEPTION WHEN OTHERS THEN 
        EXECUTE IMMEDIATE 'CREATE TABLE WPSTEMPATTN AS SELECT * FROM ATTN';
    END;    
    
    lv_SqlStr := ' DELETE FROM '||P_TABLENAME;
    BEGIN
        execute immediate lv_SqlStr;
      EXCEPTION WHEN OTHERS THEN NULL;
    END;

--    lv_SqlStr := 'INSERT INTO WPSATTENDANCEDAYWISE ( COMPANYCODE, DIVISIONCODE, YEARCODE, DATEOFATTENDANCE, WORKERSERIAL '||CHR(10)
--            ||' TOKENNO, DEPARTMENTCODE, SHIFTCODE, SPELTYPE, STATUTORYHOURS, ATTENDANCEHORS, ATTENDANCETAG, '||char(10)
--            ||' USERNMAE, LASTMODIFIED, SYSROWID, BOOKNO) '||CHR(10)
--            ||' SELECT A.COMPANYCODE, A.DIVISIONCODE, '''||P_YEARCODE||''' YEARCODE, A.FORTNIGHTENDDATE, A.WOREKRSRIAL '||CHR(10)
--            ||' B.TOKENNO, NVL(A.DEPARTMENTCODE,B.DEPARTMENCODE) DEPARTMENTCODE, NVL(A.SHIFTCODE,'1') SHIFTCODE, ''SPELL 1'' SPELTYPE, '||CHR(10) 
--            ||' SUM(NVL(A.STLHOURS,0)) STATUTORYHOURS, 0 ATTENDANCEHORS, ''STL'' ATTENDANCETAG, '||char(10)
--            ||' ''SWT'' USERNMAE, SYSDATE LASTMODIFIED, ''STL/''||TO_CHAR(FORTNIGHTSTARTE,''DDMMYYYY'')||B.TOKENNO SYSROWID, ''STL/''||TO_CHAR(FORTNIGHTSTARTE,''DDMMYYYY'')||B.TOKENNO BOOKNO) '||CHR(10)
--            ||' FROM WPSSTLENTRY A, WPSWORKERMAST B '||CHR(10)
--            ||' WHERE A.COMPANYCODE '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
--            ||'   AND A.FORTNIGHTENDDATE = '''||lv_fn_endt||'''  '||chr(10)
--            ||'   AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
--            ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10);
--    insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_INSERT',lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, 'STL ENTRY IN ATTENDANCE');
--    execute immediate lv_SqlStr;             

    lv_SqlStr := ' INSERT INTO '||P_TABLENAME||' ( '||CHR(10)
            ||'    COMPANYCODE, DIVISIONCODE, SYSROWID, YEARCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, DEPARTMENTCODE, '||CHR(10)
            ||'    DARATE, ADHOCRATE, SPL_ALLOW_RATE, '||CHR(10) 
            ||'    ATTENDANCEHOURS, OVERTIMEHOURS, HOLIDAYHOURS, LAYOFFHOURS, FBKHOURS, STLHOURS, '||CHR(10) 
            ||'    NIGHTALLOWANCEHOURS, VBASIC,ADDLBASIC '||CHR(10) 
            ||'    ) '||CHR(10)
            ||'    SELECT B.COMPANYCODE, B.DIVISIONCODE,A.WORKERSERIAL,'''||P_YEARCODE||''',  '''||lv_fn_stdt||''','''||lv_fn_endt||''', A.WORKERSERIAL, A.TOKENNO, A.WORKERCATEGORYCODE, MAX(A.DEPARTMENTCODE),  '||CHR(10)
            ||'       NVL(B.DARATE,0) DARATE, NVL(B.ADHOCRATE,0) ADHOCRATE, NVL(B.SPL_ALLOW_RATE,0) SPL_ALLOW_RATE, '||CHR(10)   
            ||'       SUM(ATTENDANCEHOURS) ATTENDANCEHOURS, SUM(NVL(OVERTIMEHOURS,0)) OVERTIMEHOURS,  '||CHR(10)
            ||'       SUM(NVL(HOLIDAYHOURS,0))HOLIDAYHOURS, SUM(NVL(LAYOFFHOURS,0)) LAYOFFHOURS, SUM(NVL(FBKHOURS,0)) FBKHOURS, SUM(NVL(STLHOURS,0)) STLHOURS, '||CHR(10) 
            ||'       SUM(NVL(NIGHTALLOWANCEHOURS,0)) NIGHTALLOWANCEHOURS, ROUND(NVL(C.VBAMOUNT,0),2) VBASIC,ROUND(NVL(C.ADDLBASIC,0),2) ADDLBASIC '||CHR(10) 
            ||'    FROM WPSATTENDANCEDAYWISE A,  WPSWORKERMAST B, '||CHR(10)
            ||'    (    '||CHR(10)
            ||'      SELECT WORKERSERIAL, /*DEPARTMENTCODE,*/ SUM(VBAMOUNT) VBAMOUNT,SUM(NVL(ADDLBASIC,0)) ADDLBASIC FROM WPSVBDETAILS '||CHR(10)
            ||'      WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''   '||CHR(10)   
            ||'        AND FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' AND FORTNIGHTENDDATE = '''||lv_fn_endt||'''  '||chr(10)
            ||'      GROUP BY WORKERSERIAL /*, DEPARTMENTCODE*/  '||CHR(10)  
            ||'    ) C ,'||CHR(10)
            ||'    ( '||CHR(10)
            || '     SELECT Y.DATEOFATTENDANCE ,/*Y.SHIFTCODE,*/ X.WORKERSERIAL,STLHOURS,Y.SPELLTYPE FROM  '||CHR(10)
            || '     ( '||CHR(10) 
            || '        SELECT A.WORKERSERIAL, SUM(NVL(STLHOURS,0)) STLHOURS FROM WPSSTLENTRY A  '||CHR(10)
            || '         WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            || '          AND A.FORTNIGHTENDDATE = '''||lv_fn_endt||''' '||CHR(10) 
            || '          AND A.LEAVECODE = ''STL'' '||CHR(10) 
            || '        GROUP BY A.WORKERSERIAl'||CHR(10)
            || '     )X, '||CHR(10)
            || '   ( '||CHR(10) 
            
            ||'     SELECT WORKERSERIAL, MIN(DATEOFATTENDANCE) DATEOFATTENDANCE,MIN(SPELLTYPE) SPELLTYPE '||CHR(10)
            ||'     FROM (  '||CHR(10)  
            ||'             SELECT WORKERSERIAL, DATEOFATTENDANCE,MIN(SPELLTYPE) SPELLTYPE --, COUNT(WORKERSERIAL) CNT '||CHR(10)
            ||'             FROM  WPSATTENDANCEDAYWISE A    '||CHR(10)            
            ||'             WHERE A.COMPANYCODE= '''||P_COMPCODE||''' AND A.DIVISIONCODE= '''||P_DIVCODE||''' '||CHR(10)
            ||'               AND A.FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' '||CHR(10)  
            ||'               AND A.FORTNIGHTENDDATE  = '''||lv_fn_endt||''' '||CHR(10)
            ||'               AND NVL(A.ATTENDANCEHOURS,0)>0 '||CHR(10)
            ||'             GROUP BY WORKERSERIAL, DATEOFATTENDANCE  '||CHR(10)
            ||'             --HAVING COUNT(WORKERSERIAL) =1  '||CHR(10)
            ||'          )  '||CHR(10)
            ||'     GROUP BY WORKERSERIAL  '||CHR(10)            
            || '/*     SELECT WORKERSERIAL,MIN(DATEOFATTENDANCE) DATEOFATTENDANCE,MIN(SHIFTCODE) SHIFTCODE '||CHR(10)
            || '      FROM WPSATTENDANCEDAYWISE A '||CHR(10)
            || '     WHERE A.COMPANYCODE= '''||P_COMPCODE||''' AND A.DIVISIONCODE= '''||P_DIVCODE||''' '||CHR(10)
            || '       AND A.FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' '||CHR(10)  
            || '       AND A.FORTNIGHTENDDATE  = '''||lv_fn_endt||''' '||CHR(10) 
            || '       GROUP BY WORKERSERIAL '||CHR(10)
            || ' */     ) Y '||CHR(10)
            || '   WHERE X.WORKERSERIAL=Y.WORKERSERIAL '||CHR(10)        
            ||' ) D '||CHR(10)
            ||'    WHERE A.COMPANYCODE =  '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10) 
            ||'      AND A.DATEOFATTENDANCE >=  '''||lv_fn_stdt||''' AND A.DATEOFATTENDANCE <=  '''||lv_fn_endt||'''   '||CHR(10)
            ||'      AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE  '||CHR(10)
            ||'      AND A.WORKERSERIAL = B.WORKERSERIAL  '||CHR(10)
            ||'      AND A.WORKERSERIAL = C.WORKERSERIAL (+) /* AND A.DEPARTMENTCODE = C.DEPARTMENTCODE (+) */ '||CHR(10)
            || '   AND A.WORKERSERIAL = D.WORKERSERIAL (+) AND A.SPELLTYPE=D.SPELLTYPE(+) AND A.DATEOFATTENDANCE = D.DATEOFATTENDANCE (+) /* AND A.SHIFTCODE = D.SHIFTCODE (+) */ '||CHR(10)
            ||'    GROUP BY B.COMPANYCODE, B.DIVISIONCODE, A.WORKERSERIAL, A.TOKENNO, /* A.DEPARTMENTCODE,*/ A.WORKERCATEGORYCODE, '||CHR(10)
            ||'             NVL(B.DARATE,0), NVL(B.ADHOCRATE,0),  NVL(B.SPL_ALLOW_RATE,0), NVL(C.VBAMOUNT,0),NVL(C.ADDLBASIC,0)  '||CHR(10);
    insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_INSERT',lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
    execute immediate lv_SqlStr;
    ---- UPDATE NOT APPLCICABLE COLUMN TO ZERO AS PER CATEGORY VS COMPONENT MAPPING FOR THE PHSE 0 OR INSERT 
    PROC_WPS_UPDATE_NA_COMP(P_FNSTDT, P_FNENDT, P_TABLENAME,P_TABLENAME,'NO');
    insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_INSERT','','',lv_parvalues,lv_fn_stdt,lv_fn_endt, 'PROCESS INSERT SUCCESSFULLY COMPLETE');
    COMMIT;
exception
when others then
 --insert into error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) values( 'ERROR SQL',lv_sqlstr,lv_sqlstr,lv_parvalues,lv_remarks);
 lv_sqlerrm := sqlerrm ;
 --dbms_output.put_line(lv_sqlerrm);
 insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_INSERT',lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
end;
/


