DROP PROCEDURE NJMCL_WEB.PROC_WPSVIEWCREATION;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPSVIEWCREATION ( P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2, 
                                                  P_ViewName Varchar2,
                                                  P_Phase Number,
                                                  P_FNSTDT Varchar2, 
                                                  P_FNENDT Varchar2,
                                                  P_WAGESTABLENAME VARCHAR2 DEFAULT NULL,
                                                  P_PROCESSTYPE  VARCHAR2 DEFAULT 'WAGES PROCESS')
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
lv_MastComponent    varchar2(500) := '';
lv_ProcName         varchar2(30) := 'PROC_WPSVIEWCREATION';

begin
    if P_Phase <= 6 then        --4
        lv_TableName := 'WPSWAGESDETAILS';    
    else
        lv_TableName := 'WPSWAGESDETAILS_MV';
    end if;
    
    if P_WAGESTABLENAME is not null then
        if P_Phase <=6 then     --4 
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
        SELECT A.COMPONENTCODE, A.COMPONENTSHORTNAME, A.COMPONENTNAME, A.COMPONENTTYPE, A.COMPONENTGROUP, A.PHASE, A.COMPONENTTAG, 
        A.FORMULA, A.CALCULATIONINDEX, nvl(MASTERCOMPONENT,'N') MASTERCOMPONENT 
        FROM WPSCOMPONENTMASTER A 
        WHERE A.COMPANYCODE = P_COMPCODE AND A.DIVISIONCODE = P_DIVCODE
          AND TAKEPARTINWAGES = 'Y'
          AND NVL(A.COMPONENTGROUP,'AMALESH') NOT LIKE '%LOAN%'  
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
        IF C2.MASTERCOMPONENT = 'Y' THEN
            if nvl(LENGTH(lv_MastComponent),0) = 0 then
                lv_MastComponent := 'NVL(B.'||C2.COMPONENTSHORTNAME||',0) AS '||C2.COMPONENTSHORTNAME;
                --NVL('||C2.COMPONENTSHORTNAME||',0) AS '||C2.COMPONENTSHORTNAME||' ';
            ELSE
                lv_MastComponent := lv_MastComponent ||', NVL(B.'||C2.COMPONENTSHORTNAME||',0) AS '||C2.COMPONENTSHORTNAME;
            END IF;
        END IF;
    END LOOP;
    --DBMS_OUTPUT.PUT_LINE('lv_Component: '||lv_CompWithValue);
    --DBMS_OUTPUT.PUT_LINE('lv_CompWithZero: '||lv_CompWithZero);
    


   -----   worker wiser master rate taken for WPSWORKERWISERMATERRATEUPDATE BASED ON LAST EFFECTIVE DATE --------------     
   
   PROC_WPSWORKERRATE(P_COMPCODE,P_DIVCODE,P_FNSTDT,'GBL_WORKERRATE_ASON',P_PROCESSTYPE);
   
    if P_ViewName = 'MAST' OR NVL(P_ViewName,'ALL') = 'ALL' then
        if length(ltrim(rtrim(NVL(lv_MastComponent,'X')))) <=1 then
            lv_MastComponent := 'FBASIC,DA,ADHOC';
        end if;
        lv_SqlStr := ' CREATE OR REPLACE VIEW MAST  '||CHR(10)
                   ||' AS '||CHR(10)
                   ||' SELECT  A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL AS WORKERSERIAL, A.TOKENNO AS TOKENNO, A.ESINO AS ESINO, A.PFNO AS PFNO, A.WORKERCATEGORYCODE AS WORKERCATEGORYCODE, A.GRADECODE, NVL(A.WORKTYPECODE,''T'')  WORKTYPECODE,'||CHR(10)
                   ||' A.WORKERNAME AS WORKERNAME, A.DEPARTMENTCODE, A.DESIGNATION AS DESIGNATION, A.SEX AS SEX, A.MARITALSTATUS AS MARITALSTATUS,  '||CHR(10)
                   ||' TRIM (A.QUARTERALLOTED) AS QUARTERALLOTED, NVL(A.PFAPPLICABLE,0) PFAPPLICABLE, NVL(A.EPFAPPLICABLE,0) EPFAPPLICABLE,  '||CHR(10)
                   ||' TRIM (NVL (A.HRAAPPLICABLE, ''N'')) AS HRAAPPLICABLE,  TRIM (NVL (A.PTAXAPPLICABLE, ''N'')) PTAXAPPLICABLE,'||CHR(10)
                   ||' TRIM (NVL (A.ESIAPPLICABLE, ''N'')) ESIAPPLICABLE, TRIM (NVL (A.WELFAREAPPLICABLE, ''N'')) WELFAREAPPLICABLE, '||CHR(10)
                   ||' A.DATEOFBIRTH AS DATEOFBIRTH, A.DATEOFJOINING AS DATEOFJOINING, A.DATEOFRETIREMENT AS DATEOFRETIREMENT, '||CHR(10)
                   ||' A.ACTIVE AS ACTIVE, NVL(NOOFINCREMENT,0) NOOFINCREMENT,NVL(G.GRADEINCRRATE,0)GRADEINCRRATE, '||CHR(10)
                   ||' '||lv_MastComponent||' '||CHR(10) 
                   ||' FROM WPSWORKERMAST A, GBL_WORKERRATE_ASON B ,WPSGRADEMASTER G'||CHR(10)
                   ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                   ||'   AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE AND A.WORKERSERIAL = B.WORKERSERIAL'||CHR(10)
                   ||'   AND A.ACTIVE =''Y''    '||CHR(10)
                   ||'   AND A.COMPANYCODE=G.COMPANYCODE(+) AND A.DIVISIONCODE=G.DIVISIONCODE(+) AND A.GRADECODE=G.GRADECODE(+)      '||CHR(10);
       EXECUTE IMMEDIATE lv_SqlStr;
       insert into wps_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
       values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, 'MAST');
       COMMIT;
    END IF;   
    IF P_ViewName  = 'ATTN' OR NVL(P_ViewName,'ALL') = 'ALL' then
         lv_SqlStr := 'CREATE OR REPLACE VIEW ATTN '||CHR(10)
                   || 'AS '||CHR(10) 
                   || 'SELECT A.WORKERSERIAL, A.TOKENNO,  A.WORKERCATEGORYCODE, ' ||CHR(10);
         IF INSTR(lv_TableName,'_MV') <=0 THEN          
            lv_SqlStr := lv_SqlStr ||' A.SHIFTCODE, A.DEPARTMENTCODE, A.SECTIONCODE, A.OCCUPATIONCODE, A.DEPTSERIAL, O.WORKERTYPECODE, O.RATE OCP_RT,  '||CHR(10);
         END IF;
         lv_SqlStr := lv_SqlStr ||' TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')  AS FORTNIGHTSTARTDATE, TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') AS FORTNIGHTENDDATE,  '||chr(10)      
                   || ' SUM(NVL(STATUTORYHOURS,0)) AS STLHOURS, SUM(NVL(A.ATTENDANCEHOURS,0)) ATTENDANCEHOURS, SUM(NVL(A.OVERTIMEHOURS,0)) OVERTIMEHOURS, SUM(NVL(A.HOLIDAYHOURS,0)) AS HOLIDAYHOURS, '||chr(10)
                   ||'  SUM(NVL(A.NIGHTALLOWANCEHOURS,0)) AS NIGHTALLOWANCEHOURS, SUM(NVL(A.FBKHOURS,0)) AS FBKHOURS, SUM(NVL(A.LAYOFFHOURS,0)) AS LAYOFFHOURS,  '||chr(10)
                   ||'  SUM(NVL(A.OT_NSHRS,0)) OT_NSHRS, SUM(NVL(A.OTH_HRS,0)) OTH_HRS, SUM(NVL(A.STLHOURS_ENCASH,0)) AS STLHOURS_ENCASH '||chr(10)
                   || ''||lv_AttnComponent||' '||chr(10)
                   || ' FROM WPSATTENDANCEDAYWISE A, WPSWORKERMAST B '||CHR(10);
         IF INSTR(lv_TableName,'_MV') <=0 THEN
            lv_SqlStr := lv_SqlStr ||' , VW_WPSOCCUPATIONMAST O '||CHR(10);        -- WPSSECTIONMAST S 
         END IF;                  
         lv_SqlStr := lv_SqlStr || ' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                   || '   AND A.DATEOFATTENDANCE >= '''||lv_fn_stdt||''' '||CHR(10)
                   || '   AND A.DATEOFATTENDANCE <= '''||lv_fn_endt||''' '||CHR(10)
                   || '   AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE =  B.DIVISIONCODE '||CHR(10)
                   || '   AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10);
        IF INSTR(lv_TableName,'_MV') <=0 THEN
            lv_SqlStr := lv_SqlStr ||' AND A.COMPANYCODE = O.COMPANYCODE AND A.DIVISIONCODE = O.DIVISIONCODE  '||CHR(10)
                                  || ' AND A.DEPARTMENTCODE = O.DEPARTMENTCODE AND A.SECTIONCODE = O.SECTIONCODE AND A.OCCUPATIONCODE = O.OCCUPATIONCODE'||CHR(10);
        END IF;
        lv_SqlStr := lv_SqlStr || ' GROUP BY A.WORKERSERIAL, A.TOKENNO, A.WORKERCATEGORYCODE '||CHR(10);
        IF INSTR(lv_TableName,'_MV') <=0 THEN
            lv_SqlStr := lv_SqlStr ||' , A.SHIFTCODE,A.DEPARTMENTCODE,A.SECTIONCODE, A.OCCUPATIONCODE, A.DEPTSERIAL, O.WORKERTYPECODE, O.RATE '||CHR(10);
        END IF;
            lv_SqlStr := lv_SqlStr ||' ORDER BY A.TOKENNO '||CHR(10);
       EXECUTE IMMEDIATE lv_SqlStr;
       insert into WPS_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
       values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, 'ATTN');
       COMMIT;
    END IF;
    
    IF P_ViewName  = 'COMP' OR NVL(P_ViewName,'ALL') = 'ALL' then
         lv_SqlStr := ' CREATE OR REPLACE VIEW COMPONENT '||CHR(10)
                   || ' AS ('||CHR(10)
                   || ' SELECT '''|| lv_fn_stdt ||''' AS FORTNIGHTSTARTDATE, '''|| lv_fn_endt ||''' AS FORTNIGHTENDDATE, A.WORKERSERIAL, A.TOKENNO '||CHR(10);
         IF INSTR(lv_TableName,'_MV') <=0 THEN
            lv_SqlStr := lv_SqlStr ||' ,A.SHIFTCODE, A.DEPARTMENTCODE,A.SECTIONCODE, A.OCCUPATIONCODE, A.DEPTSERIAL '||CHR(10);
         END IF;
         lv_SqlStr := lv_SqlStr || ' '|| lv_CompWithValue ||' '||chr(10)
                   || ' FROM '||lv_TableName||' A '||CHR(10)
                   || ' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                   || '   AND A.FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' AND A.FORTNIGHTENDDATE = '''||lv_fn_endt||''' '||chr(10)
                   || ' GROUP BY A.FORTNIGHTSTARTDATE, A.FORTNIGHTENDDATE, A.WORKERSERIAL, A.TOKENNO '||CHR(10);
        IF INSTR(lv_TableName,'_MV') <=0 THEN
            lv_SqlStr := lv_SqlStr ||' ,A.SHIFTCODE, A.DEPARTMENTCODE,A.SECTIONCODE,A.OCCUPATIONCODE, A.DEPTSERIAL '||CHR(10);
        END IF;
            lv_SqlStr := lv_SqlStr || ' ) '||chr(10);
       EXECUTE IMMEDIATE lv_SqlStr;
       insert into WPS_error_log(COMPANYCODE,DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
       values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, 'COMP');
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
       insert into WPS_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
       values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, 'FNPARAM');                   
    end if;                                  
exception
when others then
 --insert into error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) values( 'ERROR SQL',lv_sqlstr,lv_sqlstr,lv_parvalues,lv_remarks);
 lv_sqlerrm := sqlerrm ;
 --dbms_output.put_line(lv_sqlerrm);
 insert into WPS_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
 values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
end;
/


