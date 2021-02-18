CREATE OR REPLACE PROCEDURE FORTWILLIAM_WPS.PROC_WPSVIEWCREATION ( P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2, 
                                                  P_ViewName Varchar2,
                                                  P_Phase Number,
                                                  P_FNSTDT Varchar2, 
                                                  P_FNENDT Varchar2,
                                                  P_WAGESTABLENAME VARCHAR2 DEFAULT NULL,
                                                  P_PROCESSTYPE VARCHAR2 DEFAULT NULL)
as 
lv_fn_stdt DATE := TO_DATE(P_FNSTDT,'DD/MM/YYYY');
lv_fn_endt DATE := TO_DATE(P_FNENDT,'DD/MM/YYYY');
lv_TableName        varchar2(50);
lv_Remarks          varchar2(1000) := '';
lv_SqlStr           varchar2(4000);
lv_CompMast_Rec WPSCOMPONENTMASTER%ROWTYPE;
lv_AttnComponent    varchar2(4000) := ''; 
lv_CompWithZero     varchar2(1000) := '';
lv_CompWithValue    varchar2(4000) := '';
lv_CompCol          varchar2(1000) := '';
lv_SQLCompView      varchar2(4000) := '';
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';   
lv_PhaseTableName   varchar2(25);
begin
    if P_Phase <= 4 then
        lv_TableName := 'WPSWAGESDETAILS';    
    else
        lv_TableName := 'WPSWAGESDETAILS_MV';
    end if;
    
    if P_WAGESTABLENAME is not null then
        if P_Phase <=4 then 
            lv_TableName := 'WPSWAGESDETAILS_SWT';
        else
            lv_TableName := 'WPSWAGESDETAILS_MV_SWT';
        end if;    
    end if;
    
    lv_parvalues := 'VIEWNAME = '||P_ViewName||', FNEDTATE = '||P_FNENDT;
    --DBMS_OUTPUT.PUT_LINE('View Name: '||lv_parvalues||' XXX '||NVL(P_ViewName,'YYYY'));
    FOR C1 IN (
        SELECT A.COMPONENTCODE, A.COMPONENTSHORTNAME, A.COMPONENTNAME, A.COMPONENTTYPE, A.COMPONENTGROUP, A.PHASE, A.COMPONENTTAG, A.FORMULA, A.CALCULATIONINDEX 
        FROM WPSCOMPONENTMASTER A 
        WHERE A.COMPANYCODE = P_COMPCODE AND A.DIVISIONCODE = P_DIVCODE
        AND TAKEPARTINWAGES = 'Y' AND COLUMNINATTENDANCE = 'Y'
        ) 
    loop
       -- DBMS_OUTPUT.PUT_LINE('COMPONENT : '||lv_AttnComponent);
        if lv_AttnComponent = '' then
            lv_AttnComponent := ', SUM(NVL(A.'||C1.COMPONENTSHORTNAME||',0)) AS '|| C1.COMPONENTSHORTNAME;
            lv_CompWithZero := ', 0 AS '|| C1.COMPONENTSHORTNAME;
        else
            lv_AttnComponent := lv_AttnComponent ||', SUM(NVL(A.'||C1.COMPONENTSHORTNAME||',0)) AS '|| C1.COMPONENTSHORTNAME ;
            lv_CompWithZero := lv_CompWithZero ||', 0 AS '|| C1.COMPONENTSHORTNAME;
        end if;    
    END LOOP;
    --DBMS_OUTPUT.PUT_LINE('lv_AttnComponent: '||lv_AttnComponent);
    --DBMS_OUTPUT.PUT_LINE('lv_CompWithZero: '||lv_CompWithZero);
    FOR C2 IN (
        SELECT A.COMPONENTCODE, A.COMPONENTSHORTNAME, A.COMPONENTNAME, A.COMPONENTTYPE, A.COMPONENTGROUP, A.PHASE, A.COMPONENTTAG, A.FORMULA, A.CALCULATIONINDEX 
        FROM WPSCOMPONENTMASTER A 
        WHERE A.COMPANYCODE = P_COMPCODE AND A.DIVISIONCODE = P_DIVCODE
          AND TAKEPARTINWAGES = 'Y'
          --AND A.COMPONENTGROUP NOT IN ('LOAN')  
        ORDER BY CALCULATIONINDEX        
        ) 
    loop
        IF lv_CompWithValue = '' THEN
            lv_CompWithValue := ', SUM(NVL(A.'||C2.COMPONENTSHORTNAME||',0)) AS '|| C2.COMPONENTSHORTNAME;
            lv_CompCol := ', '|| C2.COMPONENTSHORTNAME;
        ELSE
            lv_CompWithValue := lv_CompWithValue ||', SUM(NVL(A.'||C2.COMPONENTSHORTNAME||',0)) AS '|| C2.COMPONENTSHORTNAME;
            lv_CompCol := lv_CompCol||', 0 AS '|| C2.COMPONENTSHORTNAME;
        end if;        
    END LOOP;
    --DBMS_OUTPUT.PUT_LINE('lv_Component: '||lv_CompWithValue);
    --DBMS_OUTPUT.PUT_LINE('lv_CompWithZero: '||lv_CompWithZero);
    
    if P_ViewName = 'MAST' OR NVL(P_ViewName,'ALL') = 'ALL' then
        lv_SqlStr := ' CREATE OR REPLACE VIEW MAST  '||CHR(10)
                   ||' AS '||CHR(10)
                   ||' SELECT  A.WORKERSERIAL AS WORKERSERIAL, A.TOKENNO AS TOKENNO, A.ESINO AS ESINO, A.PFNO AS PFNO, A.WORKERCATEGORYCODE AS WORKERCATEGORYCODE, '||CHR(10)
                   ||' A.WORKERNAME AS WORKERNAME, A.DEPARTMENTCODE, A.DESIGNATION AS DESIGNATION, A.SEX AS SEX, A.MARITALSTATUS AS MARITALSTATUS,  '||CHR(10)
                   ||' TRIM (A.QUARTERALLOTED) AS QUARTERALLOTED, NVL(A.PFAPPLICABLE,0) PFAPPLICABLE, NVL(A.EPFAPPLICABLE,0) EPFAPPLICABLE,  '||CHR(10)
                   ||' TRIM (NVL (A.HRAAPPLICABLE, ''N'')) AS HRAAPPLICABLE,  TRIM (NVL (A.PTAXAPPLICABLE, ''N'')) PTAXAPPLICABLE,'||CHR(10)
                   ||' TRIM (NVL (A.ESIAPPLICABLE, ''N'')) ESIAPPLICABLE, TRIM (NVL (A.WELFAREAPPLICABLE, ''N'')) WELFAREAPPLICABLE, '||CHR(10)
                   ||' A.DATEOFBIRTH AS DATEOFBIRTH, A.DATEOFJOINING AS DATEOFJOINING, A.DATEOFRETIREMENT AS DATEOFRETIREMENT, '||CHR(10)
                   ||' A.ACTIVE AS ACTIVE, '||CHR(10)
                   ||' NVL (A.FIXEDBASIC, 0) AS FIXEDBASIC, '||CHR(10)
                   ||' NVL (A.FIXEDBASIC_PEICERT, 0) AS FIXEDBASIC_PEICERT, '||CHR(10)
                   ||' NVL (A.DARATE, 0) AS DARATE, '||CHR(10)
                   ||' NVL (A.ADHOCRATE, 0) AS ADHOCRATE, '||CHR(10)
                   ||' NVL(A.SPL_ALLOW_RATE,0) AS SPL_ALLOW_RATE, '||CHR(10) 
                   ||' NVL(A.ADDLBASIC_RATE,0) AS ADDLBASIC_RATE, '||CHR(10)
                   ||' NVL(A.INCREMENTAMOUNT,0) AS INCREMENTAMOUNT, '||CHR(10)
                   ||' NVL(A.DAILYBASICRATE,0) AS DAILYBASICRATE,  '||CHR(10)
                   ||' 0 AS VPFPERCENT'||CHR(10)
                   ||' from WPSWORKERMAST A '||CHR(10)
                   ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                   ||' AND A.ACTIVE =''Y''    '||CHR(10);
       EXECUTE IMMEDIATE lv_SqlStr;
       insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'prcWPS_VIEWCREATION',lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, 'MAST');
       COMMIT;
    END IF;   
    IF P_ViewName  = 'ATTN' OR NVL(P_ViewName,'ALL') = 'ALL' then
         lv_SqlStr := 'CREATE OR REPLACE VIEW ATTN '||CHR(10)
                   || 'AS '||CHR(10) 
                   || 'SELECT A.WORKERSERIAL, A.TOKENNO,  A.WORKERCATEGORYCODE, ' ||CHR(10);
         IF INSTR(lv_TableName,'_MV') <=0 THEN          
            lv_SqlStr := lv_SqlStr ||' MAX(A.DEPARTMENTCODE) AS DEPARTMENTCODE, MAX(A.SHIFTCODE) AS SHIFTCODE, MAX(A.OCCUPATIONCODE) AS OCCUPATIONCODE, '||CHR(10);
         END IF;
         lv_SqlStr := lv_SqlStr ||' TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')  AS FORTNIGHTSTARTDATE, TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') AS FORTNIGHTENDDATE,  '||chr(10)      
                   || '/* NVL(C.STLHOURS,0)*/ SUM(NVL(STATUTORYHOURS,0)) AS STLHOURS, SUM(NVL(STLHOURS_ENCASH,0)) AS STLHOURS_ENCASH ,SUM(NVL(A.ATTENDANCEHOURS,0)) ATTENDANCEHOURS, SUM(NVL(A.OVERTIMEHOURS,0)) OVERTIMEHOURS, SUM(NVL(A.FBKHOURS,0)) AS FBKHOURS,SUM(NVL(A.LAYOFFHOURS,0)) AS LAYOFFHOURS, SUM(NVL(A.HOLIDAYHOURS,0)) AS HOLIDAYHOURS,SUM(NVL(A.NIGHTALLOWANCEHOURS,0)) AS NIGHTALLOWANCEHOURS '||chr(10)
                   || ''||lv_AttnComponent||' '||chr(10)
                   || ' FROM WPSATTENDANCEDAYWISE A, WPSWORKERMAST B '||CHR(10)
                   || '/* ,(SELECT WORKERSERIAL, SUM(STLHOURS) STLHOURS FROM WPSSTLENTRY '||CHR(10)
                   || '  WHERE COMPANYCODE =  '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                   || '  AND FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' AND FORTNIGHTENDDATE = '''||lv_fn_endt||'''  '||chr(10)
                   || ' GROUP BY WORKERSERIAL '||CHR(10)
                   || ' )  C */'||chr(10)
                   || ' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                   || '   AND A.DATEOFATTENDANCE >= '''||lv_fn_stdt||''' '||CHR(10)
                   || '   AND A.DATEOFATTENDANCE <= '''||lv_fn_endt||''' '||CHR(10)
                   || '   AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE =  B.DIVISIONCODE '||CHR(10)
                   || '   AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
                   || '   /* AND A.WORKERSERIAL = C.WORKERSERIAL (+) */ '||CHR(10);
                   
                   IF(NVL(P_PROCESSTYPE,'NA') = 'DAILY WAGES PROCESS') THEN
                   
                    lv_SqlStr := lv_SqlStr || ' GROUP BY A.WORKERSERIAL, A.TOKENNO, A.WORKERCATEGORYCODE, A.DEPARTMENTCODE, A.SHIFTCODE '||CHR(10);
                   ELSE
                   
                    lv_SqlStr := lv_SqlStr || ' GROUP BY A.WORKERSERIAL, A.TOKENNO, A.WORKERCATEGORYCODE /*, NVL(C.STLHOURS,0) */ '||CHR(10);
                   END IF;
--                   || ' GROUP BY A.WORKERSERIAL, A.TOKENNO, A.WORKERCATEGORYCODE /*, NVL(C.STLHOURS,0) */ '||CHR(10);
        --IF INSTR(lv_TableName,'_MV') <=0 THEN
        --    lv_SqlStr := lv_SqlStr ||' , A.DEPARTMENTCODE '||CHR(10);
        --END IF;
            lv_SqlStr := lv_SqlStr ||' ORDER BY A.TOKENNO '||CHR(10);
       EXECUTE IMMEDIATE lv_SqlStr;
       insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'prcWPS_VIEWCREATION',lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, 'ATTN');
       COMMIT;
    END IF;
    
    IF P_ViewName  = 'COMP' OR NVL(P_ViewName,'ALL') = 'ALL' then
         lv_SqlStr := ' CREATE OR REPLACE VIEW COMPONENT '||CHR(10)
                   || ' AS ('||CHR(10)
                   || ' SELECT '''|| lv_fn_stdt ||''' AS FORTNIGHTSTARTDATE, '''|| lv_fn_endt ||''' AS FORTNIGHTENDDATE, A.WORKERSERIAL, A.TOKENNO '||CHR(10);
         IF INSTR(lv_TableName,'_MV') <=0 THEN
            lv_SqlStr := lv_SqlStr ||' ,A.DEPARTMENTCODE '||CHR(10);
         END IF;
         lv_SqlStr := lv_SqlStr || ' '|| lv_CompWithValue ||' '||chr(10)
                   || ' FROM '||lv_TableName||' A '||CHR(10)
                   || ' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                   || '   AND A.FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' AND A.FORTNIGHTENDDATE = '''||lv_fn_endt||''' '||chr(10)
                   || ' GROUP BY A.FORTNIGHTSTARTDATE, A.FORTNIGHTENDDATE, A.WORKERSERIAL, A.TOKENNO '||CHR(10);
        IF INSTR(lv_TableName,'_MV') <=0 THEN
            lv_SqlStr := lv_SqlStr ||' , A.DEPARTMENTCODE '||CHR(10);
        END IF;
            lv_SqlStr := lv_SqlStr || ' ) '||chr(10);
       EXECUTE IMMEDIATE lv_SqlStr;
       insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'prcWPS_VIEWCREATION',lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, 'COMP');
       COMMIT;
    END IF;
    ------- VIEW FOR FORTNIGHT PARAMETER TABLE ---------
    if NVL(P_ViewName,'ALL') = 'ALL' then
        lv_SqlStr := ' CREATE OR REPLACE VIEW FNPARAM AS '||CHR(10)
                   ||' SELECT * FROM WPSFORTNIGHTWAGESPARAMETER '||CHR(10)
                   ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                   ||' AND DEPARTMENTCODE IS NULL '||CHR(10)
                   ||' AND FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' AND FORTNIGHTENDDATE = '''||lv_fn_endt||''' '||chr(10);
       EXECUTE IMMEDIATE lv_SqlStr;
       insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'prcWPS_VIEWCREATION',lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, 'FNPARAM');                   
    end if;                                  
exception
when others then
 --insert into error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) values( 'ERROR SQL',lv_sqlstr,lv_sqlstr,lv_parvalues,lv_remarks);
 lv_sqlerrm := sqlerrm ;
 --dbms_output.put_line(lv_sqlerrm);
 insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'prcWPS_VIEWCREATION',lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
end;
/
