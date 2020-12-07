CREATE OR REPLACE PROCEDURE NJMCL_WEB.PRC_PFINTERESTCALC_ONOPENING (P_COMPCODE Varchar2,
                                                P_DIVCODE  VARCHAR2, 
                                                P_TABLENAME Varchar2,
                                                P_YEARCODE Varchar2,
                                                P_INTEREST decimal, 
                                                P_ISCRYFRWD Varchar2 DEFAULT NULL,
                                                P_PFNO VARCHAR2 DEFAULT NULL,
                                                P_STLDATE VARCHAR2 DEFAULT NULL,
                                                P_CALCTYPE VARCHAR2 DEFAULT NULL
                                                )
/*
This procedure will calculate PF interest on opening balance
*/                                                
as
lv_Component varchar2(32767) := '';
lv_Sql       varchar2(32767) := '';
lv_Sql_TblCreate    varchar2(3000) := '';  
lv_sqlerrm      varchar2(1000) := ''; 
lv_remarks      varchar2(1000) := '';
lv_parvalues    varchar2(1000) := '';
lv_SqlTemp      varchar2 (2000) := '';
lv_Cols         varchar2 (1000) := '';
lv_EndDate      varchar2 (1000) := '';
lv_StartDate    varchar2 (1000) := '';
lv_YearMonth    varchar2 (1000) := '';
lv_YearCode     varchar2 (1000) := '';
lv_Year         NUMBER  := 0;
lv_MONTH        NUMBER :=12;
--lv_fn_stdt      date := to_date(P_STLDATE,'DD/MM/YYYY');
begin

     IF P_STLDATE IS NULL THEN
       SELECT TO_CHAR(ENDDATE,'DD/MM/YYYY')
       into lv_EndDate FROM FINANCIALYEAR WHERE  YEARCODE=P_YEARCODE;
       
     ELSE
        lv_EndDate:=P_STLDATE;        
         SELECT EXTRACT(MONTH FROM TO_DATE( P_STLDATE,'DD/MM/YYYY'))
         INTO lv_MONTH 
          FROM DUAL;
        IF lv_MONTH > 3 then
            lv_MONTH := lv_MONTH-3;
        else
            lv_MONTH := lv_MONTH+9;
        end if;  
    END IF;
    
    IF lv_EndDate IS NOT NULL THEN
    SELECT '01/'||EXTRACT(MONTH FROM TO_DATE( lv_EndDate,'DD/MM/YYYY'))||'/'||EXTRACT(YEAR FROM TO_DATE(lv_EndDate ,'DD/MM/YYYY'))
        INTO lv_StartDate
      FROM DUAL;      
      SELECT EXTRACT(YEAR FROM TO_DATE(lv_EndDate ,'DD/MM/YYYY'))||LPAD(EXTRACT(MONTH FROM TO_DATE(lv_EndDate ,'DD/MM/YYYY')),2,'0') 
      INTO lv_YearMonth
      FROM DUAL;
    END IF;
    
    lv_Sql := 'DELETE FROM ' ||P_TABLENAME||' '||CHR(10)  
              || ' WHERE YEARCODE ='''||P_YEARCODE||''' '||CHR(10) 
              || '   AND TRANSACTIONTYPE =''PF INTEREST CALCULATION'' '||CHR(10) 
              || '   AND PFNO NOT IN (SELECT PFNO FROM PFEMPLOYEEMASTER WHERE PFSETTLEMENTDATE IS NOT NULL) '||CHR(10);   
               if P_PFNO is not null then
                lv_Sql := lv_Sql ||' AND PFNO  = '''||P_PFNO||''' '||CHR(10); 
               end if;                                         
      
      insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PRC_PFINTERESTCALC_ONOPENING','',lv_Sql,'', '', '', 'TABLE CREATION');
      EXECUTE IMMEDIATE lv_Sql;
    
    lv_Sql := ' INSERT INTO ' ||P_TABLENAME||' '||CHR(10)  
            ||'   SELECT DISTINCT A.COMPANYCODE,A.DIVISIONCODE, YEARCODE,  ' ||lv_YearMonth||' YEARMONTH,'||CHR(10) 
            ||' TO_DATE('''||lv_StartDate||''',''DD/MM/YYYY'') STARTDATE,TO_DATE('''||lv_EndDate||''',''DD/MM/YYYY'') ENDDATE,A.PFNO,B.WORKERSERIAL,'||CHR(10)
            ||' B.TOKENNO,COMPONENTCODE, SUM(OPENING) COMPONENTAMOUNT  ,''PF INTEREST CALCULATION'' TRANSACTIONTYPE ,'||CHR(10)
            ||' B.MODULE POSTEDFROM ,DECODE(B.MODULE,''WPS'',''WORKER'',''PIS'',''STAFF'') EMPLOYMENTTYPE,''ADD'' ADDLESS,'||CHR(10)
            ||' ''T001''PFTRUSTCODE ,'||P_INTEREST||' INT_PER,'||CHR(10)
            ||' CASE WHEN NVL(ISOPERATIVE,''Y'')<>''Y'' THEN 0 ELSE ROUND((SUM(OPENING)*'||P_INTEREST||'/100)*('||lv_MONTH||' /12),2)  END AS INT_AMT ,'||CHR(10) 
            ||' CASE WHEN NVL(ISOPERATIVE,''Y'')<>''Y'' THEN SUM(OPENING) ELSE'||CHR(10)
            ||' ROUND((SUM(OPENING) + SUM(CONTR) + (SUM(OPENING)*'||P_INTEREST||'/100)*('||lv_MONTH||' /12)),2) END AS TOTAL_AMT,'||CHR(10)
            ||' B.PENSIONNO,0 AVERAGEBALANCE,B.COMPANYCODE EMPLOYEECOMPANYCODE,B.DIVISIONCODE EMPLOYEEDIVISIONCODE,B.MODULE,0 ADJ_AMT,''PF INTEREST CALCULATION'' REMARKS,'||CHR(10)
            ||' NULL VOUCHERNO,NULL VOUCHERDATE,NULL SYSTEMVOUCHERNO,NULL SYSTEMVOUCHERDATE,NULL APPLICATIONDATE ,NULL APPLICATIONNO, SYSDATE LASTMODIFIEDDATE, ''SWT'' USERNAME, SYS_GUID() SYSROWID'||CHR(10)
            
            ||' FROM  ( '||CHR(10)
            || ' SELECT COMPANYCODE, DIVISIONCODE, EMPLOYEECOMPANYCODE ,EMPLOYEEDIVISIONCODE  ,PFNO,COMPONENTCODE, YEARCODE, SUM(OPENING) OPENING, SUM(CONTR) CONTR '||CHR(10)
            || '   FROM ( '||CHR(10)
            || '           SELECT COMPANYCODE ,DIVISIONCODE ,EMPLOYEECOMPANYCODE ,EMPLOYEEDIVISIONCODE  ,PFNO,COMPONENTCODE, YEARCODE, '||CHR(10)  
            || '                   SUM(COMPONENTAMOUNT) OPENING,0 CONTR '||CHR(10)
            || '             FROM PFTRANSACTIONDETAILS '||CHR(10)
            || '             WHERE COMPANYCODE ='''||P_COMPCODE||''''||CHR(10)
            || '               AND YEARCODE ='''||P_YEARCODE||''' '||CHR(10) 
            || '               AND TRANSACTIONTYPE =''PF INTEREST OPENING BALANCE'' '||CHR(10) 
            || '             GROUP BY COMPANYCODE, DIVISIONCODE ,EMPLOYEECOMPANYCODE ,EMPLOYEEDIVISIONCODE  ,PFNO,COMPONENTCODE, EMPLOYEECOMPANYCODE , YEARCODE '||CHR(10) 
            || '             UNION ALL '||CHR(10)  
            || '            SELECT COMPANYCODE, DIVISIONCODE ,EMPLOYEECOMPANYCODE ,EMPLOYEEDIVISIONCODE  ,PFNO,COMPONENTCODE,  YEARCODE, 0 OPENING, '||CHR(10) 
            || '                   SUM(COMPONENTAMOUNT) CONTR '||CHR(10) 
            || '              FROM PFTRANSACTIONDETAILS '||CHR(10) 
            || '             WHERE COMPANYCODE ='''||P_COMPCODE||''''||CHR(10)
            || '               AND YEARCODE ='''||P_YEARCODE||''' '||CHR(10) 
            || '               AND TRANSACTIONTYPE <>''PF INTEREST OPENING BALANCE'' '||CHR(10)  
            || '               AND TRANSACTIONTYPE <>''PF INTEREST CALCULATION'' '||CHR(10)
            || '             GROUP BY COMPANYCODE, DIVISIONCODE ,EMPLOYEECOMPANYCODE ,EMPLOYEEDIVISIONCODE  ,PFNO,COMPONENTCODE, EMPLOYEECOMPANYCODE , YEARCODE '||CHR(10)
            || '      ) '||CHR(10)
            || '   GROUP BY COMPANYCODE,DIVISIONCODE , EMPLOYEECOMPANYCODE ,EMPLOYEEDIVISIONCODE  ,PFNO,COMPONENTCODE, YEARCODE '||CHR(10)            
            
            
            ||' ) A, PFEMPLOYEEMASTER B '||CHR(10)
            
            ||' WHERE A.COMPANYCODE ='''||P_COMPCODE||''''||CHR(10)
            ||' AND A.YEARCODE ='''||P_YEARCODE||''' '||CHR(10) 
            ||' AND B.PFSETTLEMENTDATE IS NULL'||CHR(10);
           
            if P_PFNO is not null then
                lv_Sql := lv_Sql ||' AND A.PFNO  = '''||P_PFNO||''' '||CHR(10); 
            end if; 
            
            lv_Sql := lv_Sql ||'  AND A.COMPANYCODE=B.COMPANYCODE'||CHR(10)
            ||' AND A.DIVISIONCODE=B.DIVISIONCODE'||CHR(10)
            ||' AND A.PFNO=B.PFNO '||CHR(10)
            ||' GROUP BY  A.COMPANYCODE,A.DIVISIONCODE, YEARCODE, A.PFNO, COMPONENTCODE,B.WORKERSERIAL,'||CHR(10)
            ||' B.TOKENNO,B.PENSIONNO,B.COMPANYCODE,B.DIVISIONCODE ,B.MODULE,ISOPERATIVE'||CHR(10)
            ||' ORDER BY PFNO, COMPONENTCODE '||CHR(10);     

            --DBMS_OUTPUT.PUT_LINE('COMPONENT : '||lv_Sql);
            insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PRC_PFINTERESTCALC_ONOPENING','',lv_Sql,'', '', '', 'TABLE CREATION');
           EXECUTE IMMEDIATE lv_Sql;  
           COMMIT;
    IF NVL(P_ISCRYFRWD,'N')<>'N'  AND NVL(P_STLDATE,'N')='N' THEN 
    
    select substr(P_YEARCODE,6) 
    into lv_YearCode from dual;
    
    lv_YearMonth :=TO_number(lv_YearCode)||LPAD(04,2,'0');  
    lv_StartDate :='01/04/'||TO_number(lv_YearCode);  
    lv_EndDate   :='30/04/'||TO_number(lv_YearCode);  
    lv_YearCode  := TO_CHAR(lv_YearCode)||'-'||(TO_NUMBER(lv_YearCode)+1);
    
    
     lv_Sql := 'DELETE FROM ' ||P_TABLENAME||' '||CHR(10)  
              || ' WHERE YEARCODE ='''||lv_YearCode||''' '||CHR(10) 
              || '   AND TRANSACTIONTYPE =''PF INTEREST OPENING BALANCE'' '||CHR(10) 
              || '   AND PFNO NOT IN (SELECT PFNO FROM PFEMPLOYEEMASTER WHERE PFSETTELMENTDATE IS NOT NULL) '||CHR(10);   
               if P_PFNO is not null then
                lv_Sql := lv_Sql ||' AND PFNO  = '''||P_PFNO||''' '||CHR(10); 
               end if;                                         
      
      insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PRC_PFINTERESTCALC_ONOPENING','',lv_Sql,'', '', '', 'TABLE CREATION');
      EXECUTE IMMEDIATE lv_Sql;
    
    
     lv_Sql := ' INSERT INTO ' ||P_TABLENAME||' '||CHR(10)        
            ||'   SELECT DISTINCT A.COMPANYCODE,A.DIVISIONCODE,'''||lv_YearCode||'''  YEARCODE,  ' ||lv_YearMonth||' YEARMONTH,'||CHR(10) 
            ||' TO_DATE('''||lv_StartDate||''',''DD/MM/YYYY'') STARTDATE,TO_DATE('''||lv_EndDate||''',''DD/MM/YYYY'') ENDDATE,A.PFNO,B.WORKERSERIAL,'||CHR(10)
            ||' B.TOKENNO,COMPONENTCODE,  CASE WHEN NVL(ISOPERATIVE,''Y'')<>''Y'' THEN SUM(OPENING) ELSE'||CHR(10)
            ||' ROUND((SUM(OPENING) +  SUM(CONTR) + (SUM(OPENING)*'||P_INTEREST||'/100)*('||lv_MONTH||' /12)),0) END AS  COMPONENTAMOUNT  ,''PF INTEREST OPENING BALANCE''  TRANSACTIONTYPE ,'||CHR(10)
            ||' B.MODULE POSTEDFROM ,DECODE(B.MODULE,''WPS'',''WORKER'',''PIS'',''STAFF'') EMPLOYMENTTYPE,''ADD'' ADDLESS,'||CHR(10)
            ||' ''T001''PFTRUSTCODE ,0 INT_PER,'||CHR(10)
            ||' 0 AS INT_AMT , 0 TOTAL_AMT,'||CHR(10)
            ||' B.PENSIONNO,0 AVERAGEBALANCE,B.COMPANYCODE EMPLOYEECOMPANYCODE,B.DIVISIONCODE EMPLOYEEDIVISIONCODE,B.MODULE,0 ADJ_AMT,''PF INTEREST OPENING BALANCE''  REMARKS,'||CHR(10)
            ||' NULL VOUCHERNO,NULL VOUCHERDATE,NULL SYSTEMVOUCHERNO,NULL SYSTEMVOUCHERDATE,NULL APPLICATIONDATE ,NULL APPLICATIONNO'||CHR(10)
            
            ||' FROM ( '||CHR(10)
            || ' SELECT COMPANYCODE, DIVISIONCODE, EMPLOYEECOMPANYCODE ,EMPLOYEEDIVISIONCODE  ,PFNO,COMPONENTCODE, YEARCODE, SUM(OPENING) OPENING, SUM(CONTR) CONTR '||CHR(10)
            || '   FROM ( '||CHR(10)
            || '           SELECT COMPANYCODE ,DIVISIONCODE ,EMPLOYEECOMPANYCODE ,EMPLOYEEDIVISIONCODE  ,PFNO,COMPONENTCODE, YEARCODE, '||CHR(10)  
            || '                   SUM(COMPONENTAMOUNT) OPENING,0 CONTR '||CHR(10)
            || '             FROM PFTRANSACTIONDETAILS '||CHR(10)
            || '             WHERE COMPANYCODE ='''||P_COMPCODE||''''||CHR(10)
            || '               AND YEARCODE ='''||P_YEARCODE||''' '||CHR(10) 
            || '               AND TRANSACTIONTYPE =''PF INTEREST OPENING BALANCE'' '||CHR(10) 
            || '             GROUP BY COMPANYCODE, DIVISIONCODE ,EMPLOYEECOMPANYCODE ,EMPLOYEEDIVISIONCODE  ,PFNO,COMPONENTCODE, EMPLOYEECOMPANYCODE , YEARCODE '||CHR(10) 
            || '             UNION ALL '||CHR(10)  
            || '            SELECT COMPANYCODE, DIVISIONCODE ,EMPLOYEECOMPANYCODE ,EMPLOYEEDIVISIONCODE  ,PFNO,COMPONENTCODE,  YEARCODE, 0 OPENING, '||CHR(10) 
            || '                   SUM(COMPONENTAMOUNT) CONTR '||CHR(10) 
            || '              FROM PFTRANSACTIONDETAILS '||CHR(10) 
            || '             WHERE COMPANYCODE ='''||P_COMPCODE||''''||CHR(10)
            || '               AND YEARCODE ='''||P_YEARCODE||''' '||CHR(10) 
            || '               AND TRANSACTIONTYPE <>''PF INTEREST OPENING BALANCE'' '||CHR(10)  
            || '               AND TRANSACTIONTYPE <>''PF INTEREST CALCULATION'' '||CHR(10)
            || '             GROUP BY COMPANYCODE, DIVISIONCODE ,EMPLOYEECOMPANYCODE ,EMPLOYEEDIVISIONCODE  ,PFNO,COMPONENTCODE, EMPLOYEECOMPANYCODE , YEARCODE '||CHR(10)
            || '      ) '||CHR(10)
            || '   GROUP BY COMPANYCODE,DIVISIONCODE , EMPLOYEECOMPANYCODE ,EMPLOYEEDIVISIONCODE  ,PFNO,COMPONENTCODE, YEARCODE '||CHR(10)            
            ||' ) A, PFEMPLOYEEMASTER B '||CHR(10)            
            ||' WHERE A.COMPANYCODE ='''||P_COMPCODE||''''||CHR(10)
            ||' AND A.YEARCODE ='''||P_YEARCODE||''' '||CHR(10) 
            ||' AND B.PFSETTLEMENTDATE IS NULL'||CHR(10);
            
            if P_PFNO is not null then
                lv_Sql := lv_Sql ||' AND A.PFNO  = '''||P_PFNO||''' '||CHR(10); 
            end if; 
            
            lv_Sql := lv_Sql ||'  AND A.COMPANYCODE=B.COMPANYCODE'||CHR(10)
            ||' AND A.DIVISIONCODE=B.DIVISIONCODE'||CHR(10)
            ||' AND A.PFNO=B.PFNO '||CHR(10)
            ||' GROUP BY  A.COMPANYCODE,A.DIVISIONCODE, YEARCODE, A.PFNO, COMPONENTCODE,B.WORKERSERIAL,'||CHR(10)
            ||' B.TOKENNO,B.PENSIONNO,B.COMPANYCODE,B.DIVISIONCODE ,B.MODULE,ISOPERATIVE'||CHR(10)
            ||' ORDER BY PFNO, COMPONENTCODE '||CHR(10);        
        insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PRC_PFINTERESTCALC_ONOPENING','',lv_Sql,'', '', '', 'TABLE CREATION');
            EXECUTE IMMEDIATE lv_Sql;  
            COMMIT;
    END IF;
   -- DBMS_OUTPUT.PUT_LINE('TEST : '||lv_Sql);
               

end;
/
