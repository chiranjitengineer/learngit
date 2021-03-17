DROP PROCEDURE NJMCL_WEB.PROC_WPS_VB_MCH_LAPPING;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPS_VB_MCH_LAPPING ( P_COMPCODE VARCHAR2, P_DIVCODE VARCHAR2, P_YEARCODE VARCHAR2,P_FN_STDT VARCHAR2, P_FN_ENDT VARCHAR2, P_1ST_WK_ENDT VARCHAR2 DEFAULT NULL, 
                                                         P_TABLENAME varchar2 DEFAULT 'WPSVBDETAILS', P_PRODUCTIONTYPE VARCHAR2 DEFAULT NULL, 
                                                         P_DEPARTMENT VARCHAR2 DEFAULT NULL, P_SECTION VARCHAR2 DEFAULT NULL, 
                                                         P_OCCUPATION VARCHAR2 DEFAULT NULL, P_WORKERSERIAL VARCHAR2 DEFAULT NULL)
AS
----- THIS PROCEDURE WRITTEN BY AMALESH DAS ON 22.08.2019 ----
----- THIS PROCEDURE USE FOR CALCULATE VARIABLE BASIC BASED ON FORTNIGHTLY INDIVIDUAL MACHINEWISE, QUALITY WISE PRODUCTION 
----- QUALITYRATE TAKE FROM  - WPSQUALITYRATE_ON_REEDSPACE TABLE ----- 

lv_Sql      varchar2(20000) := '';
lv_ProcName varchar2(30) := 'PROC_WPS_VB_MCH_LAPPING';
lv_ParValue varchar2(200) := '';
lv_Remarks  varchar2(200) := '';
lv_FN_STDT  date := to_date(P_FN_STDT,'DD/MM/YYYY');
lv_FN_ENDT  date := to_date(P_FN_ENDT,'DD/MM/YYYY');
lv_SqlErr   varchar2(200) := '';
lv_SectionCode   varchar2(10) := '';
lv_DeptCode      varchar2(10) := '';
lv_OcpCode       varchar2(50) := '';   


Begin


    SELECT DEPARTMENTCODE,SECTIONCODE into lv_DeptCode, lv_SectionCode FROM WPSPRODUCTIONTYPEMAST 
    WHERE COMPANYCODE = P_COMPCODE
    AND DIVISIONCODE = P_DIVCODE
    AND PRODUCTIONTYPECODE = P_PRODUCTIONTYPE ;

     lv_Remarks := 'DELETE FROM WPSLINEHOURLYRATE, PRODUCTION TYPE ' ||  P_PRODUCTIONTYPE;
     
     lv_Sql := ' DELETE FROM WPSLINEHOURLYRATE '||chr(10)  
             ||'WHERE COMPANYCODE = ''' ||P_COMPCODE|| ''' '||chr(10)  
             ||'AND DIVISIONCODE = ''' ||P_DIVCODE|| ''' '||chr(10)  
             ||'AND PRODUCTIONTYPE = ''' ||P_PRODUCTIONTYPE|| ''' '||chr(10)  
             ||'AND FORTNIGHTSTARTDATE = ''' ||lv_FN_STDT|| ''' '||chr(10)  
             ||'AND FORTNIGHTENDDATE = ''' ||lv_FN_ENDT|| ''' '||chr(10)  
             ||'AND TRANTYPE = ''VB'' ';  
    
    EXECUTE IMMEDIATE lv_Sql;
             
    INSERT INTO WPS_ERROR_LOG (COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    values ( P_COMPCODE, P_DIVCODE, lv_ProcName,'',SYSDATE, lv_Sql,lv_ParValue, lv_FN_STDT, lv_FN_ENDT, lv_Remarks); 
    COMMIT; 
     
     lv_Remarks := 'INSERT INTO WPSLINEHOURLYRATE, PRODUCTION TYPE ' ||  P_PRODUCTIONTYPE;
     
     lv_Sql := '   INSERT INTO WPSLINEHOURLYRATE  '||chr(10) 
             ||'   (   '||chr(10) 
             ||'       COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, PRODUCTIONTYPE,  SHIFTCODE, MACHINECODE1, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, SECTIONCODE,  '||chr(10)  
             ||'        VBHOURLYRATE,TOTALHOURS, TOTALBASIC, LASTMODIFIED,TRANTYPE, USERNAME, SYSROWID  '||chr(10) 
             ||'   )   '||chr(10) 
             ||'   SELECT  X.COMPANYCODE, X.DIVISIONCODE, X.DEPARTMENTCODE, X.PRODUCTIONTYPE, X.SHIFTCODE, X.MACHINECODE, ''' || lv_FN_STDT || ''' FORTNIGHTSTARTDATE, '||chr(10) 
             ||'   ''' || lv_FN_ENDT || ''' FORTNIGHTENDDATE, ''' || lv_SectionCode || ''' SECTIONCODE,  '||chr(10) 
             ||'   ROUND(SUM(VBAMOUNT)/NVL(ATTN.TOT_HRS,1),5) VBHOURLYRATE,NVL(ATTN.TOT_HRS,1) TOTALHOURS, SUM(VBAMOUNT) TOTALBASIC,  '||chr(10) 
             ||'   SYSDATE LASTMODIFIED,''VB'' TRANTYPE, ''SWT'' USERNAME, SYS_GUID() SYSROWID  '||chr(10) 
             ||'    FROM  '||chr(10) 
             ||'    (    '||chr(10) 
             ||'       SELECT A.COMPANYCODE, A.DIVISIONCODE, A.DEPARTMENTCODE, A.PRODUCTIONTYPE,  A.SHIFTCODE, A.MACHINECODE, A.QUALITYCODE,   '||chr(10) 
             ||'       SUM(NVL(TOTALPRODUCTION,0)) PRODUCTION, SUM(NVL(WORKINGHOURS,0)) WORKINGHOURS,  '||chr(10) 
             ||'       ROUND(ROUND(SUM(NVL(TOTALPRODUCTION,0))/NVL(B.UNITQUANTITY,1),2) *B.QUALITYRATE* NVL(B.PERCENTAGEOFRATE,100)*0.01,2) VBAMOUNT  '||chr(10) 
             ||'       FROM (/*WPSPRODUCTIONSUMMARY A, */  '||chr(10)

             ||'       SELECT COMPANYCODE, DIVISIONCODE, STARTDATE, ENDDATE, YEARCODE,PRODUCTIONTYPE, DEPARTMENTCODE, SHIFTCODE, WORKERSERIAL, '||CHR(10) 
             ||'       MACHINECODE, QUALITYCODE, TOTALPRODUCTION*YARDSQTY TOTALPRODUCTION, WORKINGHOURS  '||CHR(10)
             ||'       FROM WPSPRODUCTIONSUMMARY  '||CHR(10)
             ||'       WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
             ||'         AND YEARCODE = '''||P_YEARCODE||'''  '||chr(10)    
             ||'         AND STARTDATE >= '''||lv_FN_STDT||'''   '||CHR(10)
             ||'         AND STARTDATE <= '''||lv_FN_ENDT||'''  '||CHR(10)
             ||'         AND PRODUCTIONTYPE = '''||P_PRODUCTIONTYPE||''' '||CHR(10)
             ||'       ) A,    '||CHR(10)
             ||'       (    '||chr(10) 
             ||'        SELECT X.PRODUCTIONTYPE, X.QUALITYCODE, CASE WHEN NVL(X.UNITQUANTITY,1) = 0 THEN 1 ELSE NVL(X.UNITQUANTITY,1) END UNITQUANTITY,  '||chr(10)   
             ||'        CASE WHEN NVL(X.PERCENTAGEOFRATE,0)=0 THEN 100 ELSE X.PERCENTAGEOFRATE END PERCENTAGEOFRATE, X.QUALITYRATE    '||chr(10) 
             ||'        FROM  WPSQUALITYRATE_ON_REEDSPACE X,    '||chr(10) 
             ||'        (    '||chr(10) 
             ||'            SELECT PRODUCTIONTYPE, QUALITYCODE, MAX(EFFECTIVEDATE) EFFECTIVEDATE  '||chr(10)   
             ||'            FROM WPSQUALITYRATE_ON_REEDSPACE    '||chr(10) 
             ||'            WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)   
             ||'              AND PRODUCTIONTYPE = '''||P_PRODUCTIONTYPE||'''  '||chr(10)
             ||'            GROUP BY PRODUCTIONTYPE, QUALITYCODE    '||chr(10) 
             ||'        ) Y    '||chr(10) 
             ||'        WHERE X.COMPANYCODE = '''||P_COMPCODE||''' AND X.DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)   
             ||'          AND X.PRODUCTIONTYPE = Y.PRODUCTIONTYPE     '||chr(10) 
             ||'          AND X.QUALITYCODE = Y.QUALITYCODE AND X.EFFECTIVEDATE = Y.EFFECTIVEDATE  '||chr(10)   
             ||'       ) B    '||chr(10) 
             ||'       WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)  
             ||'       AND A.YEARCODE = '''||P_YEARCODE||'''  '||chr(10)
             ||'       AND A.STARTDATE >= '''||lv_FN_STDT||''' '|| CHR(10) 
             ||'       AND A.STARTDATE <= '''||lv_FN_ENDT||'''  '|| CHR(10) 
             ||'       AND A.PRODUCTIONTYPE = B.PRODUCTIONTYPE     '||chr(10)
             ||'       AND A.QUALITYCODE = B.QUALITYCODE     '||chr(10)  
             ||'       AND A.TOTALPRODUCTION > 0  '||chr(10) 
             ||'       GROUP BY A.COMPANYCODE, A.DIVISIONCODE , A.DEPARTMENTCODE, A.PRODUCTIONTYPE,  A.MACHINECODE, A.SHIFTCODE,  '||chr(10) 
             ||'       A.WORKERSERIAL,A.QUALITYCODE, B.UNITQUANTITY, B.QUALITYRATE, B.PERCENTAGEOFRATE  '||chr(10) 
             ||'   )X,  '||chr(10)
             ||'  (  '||chr(10)
             ||'       SELECT SHIFTCODE, MACHINECODE1, SUM(NVL(ATTENDANCEHOURS,0)) ATTN_HRS, SUM(NVL(ATTENDANCEHOURS,0)+NVL(OVERTIMEHOURS,0)) TOT_HRS  '||chr(10)
             ||'       FROM WPSATTENDANCEDAYWISE A, WPSOCCUPATIONMAST B   '||chr(10)
             ||'       WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE ='''||P_DIVCODE||'''  '||chr(10)
             ||'         AND A.YEARCODE = '''||P_YEARCODE||'''  '||chr(10)
             ||'         AND A.DATEOFATTENDANCE >= '''||lv_FN_STDT||''' AND A.DATEOFATTENDANCE <= '''||lv_FN_ENDT||'''  '||chr(10)
             ||'         AND A.SECTIONCODE ='''||lv_SectionCode||'''  '||chr(10)
             ||'         AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE  '||chr(10)
             ||'         AND A.DEPARTMENTCODE = B.DEPARTMENTCODE AND A.SECTIONCODE = B.SECTIONCODE   '||chr(10)
             ||'         AND B.WORKERTYPECODE = ''P''  '||chr(10)
             ||'       GROUP BY SHIFTCODE, MACHINECODE1  '||chr(10)
             ||'  ) ATTN   '||chr(10)
             ||' WHERE X.SHIFTCODE = ATTN.SHIFTCODE AND X.MACHINECODE = ATTN.MACHINECODE1   '||CHR(10)         
             ||' GROUP BY X.COMPANYCODE, X.DIVISIONCODE, X.DEPARTMENTCODE, X.PRODUCTIONTYPE, X.SHIFTCODE, X.MACHINECODE,NVL(ATTN.TOT_HRS,1) '||chr(10); 
             
    EXECUTE IMMEDIATE lv_Sql;
    INSERT INTO WPS_ERROR_LOG (COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    values ( P_COMPCODE, P_DIVCODE, lv_ProcName,'',SYSDATE, lv_Sql,lv_ParValue, lv_FN_STDT, lv_FN_ENDT, lv_Remarks);
    commit;
    
    PROC_VB_WORKER_MACHINEWISE ( P_COMPCODE, P_DIVCODE, P_YEARCODE, P_FN_STDT, P_FN_ENDT,NULL,'WPSVBDETAILS',P_PRODUCTIONTYPE,NULL, NULL,NULL,NULL);

    
exception    
    when others then
        lv_SqlErr := sqlerrm;
    INSERT INTO WPS_ERROR_LOG (COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    values ( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_SqlErr,SYSDATE, lv_Sql,lv_ParValue, lv_FN_STDT, lv_FN_ENDT, lv_Remarks);
    commit; 
End;
/


