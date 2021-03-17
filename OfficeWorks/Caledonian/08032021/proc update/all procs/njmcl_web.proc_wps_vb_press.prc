DROP PROCEDURE NJMCL_WEB.PROC_WPS_VB_PRESS;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPS_VB_PRESS( P_COMPCODE VARCHAR2, P_DIVCODE VARCHAR2, P_YEARCODE VARCHAR2,P_FN_STDT VARCHAR2, P_FN_ENDT VARCHAR2, P_1ST_WK_ENDT VARCHAR2 DEFAULT NULL, 
                                                         P_TABLENAME varchar2 DEFAULT 'WPSVBDETAILS', P_PRODUCTIONTYPE VARCHAR2 DEFAULT NULL, 
                                                         P_DEPARTMENT VARCHAR2 DEFAULT NULL, P_SECTION VARCHAR2 DEFAULT NULL, 
                                                         P_OCCUPATION VARCHAR2 DEFAULT NULL, P_WORKERSERIAL VARCHAR2 DEFAULT NULL)
AS
----- THIS PROCEDURE WRITTEN BY AMALESH ON 10.08.2019 ----
----- THIS PROCEDURE USE FOR CALCULATE OCCUPATION TYPE WISE RATE AND STORE IN WPSLINEHOURLYRATE TABLE -- 

lv_Sql      varchar2(20000) := '';
lv_ProcName varchar2(30) := 'PROC_WPS_VB_PRESS';
lv_ParValue varchar2(200) := '';
lv_Remarks  varchar2(200) := '';
lv_FN_STDT  date := to_date(P_FN_STDT,'DD/MM/YYYY');
lv_FN_ENDT  date := to_date(P_FN_ENDT,'DD/MM/YYYY');
lv_SqlErr   varchar2(200) := '';
lv_SectionCode   varchar2(10) := '';
lv_DeptCode      varchar2(10) := '';
lv_OcpCode       varchar2(50) := '';   
lv_TempTable    varchar2(30) := '';  
lv_ProductionType VARCHAR2(10) := '';
lv_TempTableAttn  varchar2(30) := '';
lv_TempTableProd    varchar2(30) := '';      

Begin


    IF P_PRODUCTIONTYPE IS NOT NULL THEN
        lv_ProductionType := P_PRODUCTIONTYPE;   
        BEGIN
            SELECT DEPARTMENTCODE,SECTIONCODE into lv_DeptCode, lv_SectionCode  
            FROM WPSPRODUCTIONTYPEMAST 
            WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
              AND PRODUCTIONTYPECODE = P_PRODUCTIONTYPE;
              --lv_TempTable :='WPS_PREPROCESS_TEMP_'||lv_SectionCode;
        EXCEPTION
            WHEN OTHERS THEN lv_SectionCode := '';      
        END;   
    END IF;
    
    IF P_SECTION IS NOT NULL THEN
        BEGIN
            lv_SectionCode := P_SECTION;
            SELECT PRODUCTIONTYPECODE,DEPARTMENTCODE INTO lv_ProductionType, lv_DeptCode 
            FROM WPSPRODUCTIONTYPEMAST 
            WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
              AND SECTIONCODE = P_SECTION;
        EXCEPTION
            WHEN OTHERS THEN 
                lv_ProductionType := 'SWT' ;
                SELECT MAX(DEPARTMENTCODE) into lv_DeptCode FROM WPSSECTIONMAST WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE AND SECTIONCODE = P_SECTION;    
        END;        
    END IF;


--    SELECT DEPARTMENTCODE,SECTIONCODE into lv_DeptCode, lv_SectionCode FROM WPSPRODUCTIONTYPEMAST 
--    WHERE COMPANYCODE = P_COMPCODE
--    AND DIVISIONCODE = P_DIVCODE
--    AND PRODUCTIONTYPECODE = P_PRODUCTIONTYPE ;

     lv_Remarks := 'DELETE FROM WPSLINEHOURLYRATE, PRODUCTION TYPE ' ||  P_PRODUCTIONTYPE;
     
     lv_Sql := ' DELETE FROM WPSLINEHOURLYRATE '||chr(10)  
             ||' WHERE COMPANYCODE = ''' ||P_COMPCODE|| ''' '||chr(10)  
             ||'   AND DIVISIONCODE = ''' ||P_DIVCODE|| ''' '||chr(10)  
             ||'   AND PRODUCTIONTYPE = ''' ||lv_ProductionType|| ''' '||chr(10)  
             ||'   AND FORTNIGHTSTARTDATE = ''' ||lv_FN_STDT|| ''' '||chr(10)  
             ||'   AND FORTNIGHTENDDATE = ''' ||lv_FN_ENDT|| ''' '||chr(10)  
             ||'   AND TRANTYPE = ''VB'' ';  
    
    EXECUTE IMMEDIATE lv_Sql;
             
    INSERT INTO WPS_ERROR_LOG (COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    values ( P_COMPCODE, P_DIVCODE, lv_ProcName,'',SYSDATE, lv_Sql,lv_ParValue, lv_FN_STDT, lv_FN_ENDT, lv_Remarks); 
    COMMIT; 
     
    lv_TempTableAttn := 'WPS_TEMP_VB_ATTN'; --_'||lv_ProductionType;
    lv_TempTableProd := 'WPS_TEMP_VB_PROD_'||lv_ProductionType;

    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE '||lv_TempTableAttn;
    EXCEPTION
        WHEN OTHERS THEN NULL;     
    END; 
    
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE '||lv_TempTableProd;
    EXCEPTION
        WHEN OTHERS THEN NULL;     
        EXECUTE IMMEDIATE 'DELETE FROM '||lv_TempTableAttn;
    END;
    lv_Remarks := lv_ProductionType||' - Temp table Creation for m/c, shift,Occupation type wise attendance hours'; 
    lv_Sql:= ' CREATE TABLE '||lv_TempTableAttn||' AS '||chr(10)
        ||' SELECT A.MACHINECODE1 MACHINECODE, A.SHIFTCODE,C.OCCUPATIONTYPE, SUM(NVL(ATTENDANCEHOURS,0)+NVL(OVERTIMEHOURS,0)) ATTN_HRS,0 TOT_HRS '||CHR(10)
        ||' FROM WPSATTENDANCEDAYWISE A, WPSSECTIONMAST B, WPSOCCUPATIONMAST C '||CHR(10)
        ||' WHERE A.COMPANYCODE ='''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||'   AND A.YEARCODE ='''||P_YEARCODE||'''  '||CHR(10)
        ||'   AND A.DATEOFATTENDANCE >= '''||lv_fn_stdt||''' AND A.DATEOFATTENDANCE <= '''||lv_fn_endt||''' '||chr(10)
        ||'   AND A.DEPARTMENTCODE = '''||lv_DeptCode||''' AND A.SECTIONCODE = '''||lv_SectionCode||''' AND A.MACHINECODE1 IS NOT NULL '||chr(10)
        ||'   AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||chr(10)
        ||'   AND A.DEPARTMENTCODE = B.DEPARTMENTCODE AND A.SECTIONCODE = B.SECTIONCODE '||chr(10)
        ||'   AND B.WORKTYPECODE = ''P'' '||chr(10)
        ||'   AND A.COMPANYCODE = C.COMPANYCODE AND A.DIVISIONCODE = C.DIVISIONCODE '||chr(10) 
        ||'   AND A.DEPARTMENTCODE = C.DEPARTMENTCODE AND A.SECTIONCODE = C.SECTIONCODE AND A.OCCUPATIONCODE = C.OCCUPATIONCODE '||chr(10)
        ||'   AND C.WORKERTYPECODE = ''P'' '||chr(10)
        ||'   GROUP BY A.MACHINECODE1, A.SHIFTCODE ,C.OCCUPATIONTYPE '||chr(10)
        ||' ORDER BY A.MACHINECODE1,A.SHIFTCODE, C.OCCUPATIONTYPE '||chr(10);
    EXECUTE IMMEDIATE lv_Sql;
             
    INSERT INTO WPS_ERROR_LOG (COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    values ( P_COMPCODE, P_DIVCODE, lv_ProcName,'',SYSDATE, lv_Sql,lv_ParValue, lv_FN_STDT, lv_FN_ENDT, lv_Remarks); 
    COMMIT; 

    -- UPDATING TOT_HRS FROM BASED ON MACHINE,SHIFT
    FOR C1 IN (
                SELECT MACHINECODE, SHIFTCODE, SUM(ATTN_HRS) TOT_HRS
                FROM WPS_TEMP_VB_ATTN --_P0006
                --where OCCUPATIONTYPE = '1ST PACKER'
                GROUP BY MACHINECODE, SHIFTCODE
            )
    LOOP
        UPDATE WPS_TEMP_VB_ATTN SET TOT_HRS = C1.TOT_HRS WHERE MACHINECODE = C1.MACHINECODE AND SHIFTCODE=C1.SHIFTCODE;
    END LOOP;        
    
    lv_Remarks := lv_ProductionType||' - Temp table Creation for m/c, shiftwise production and vbamount calculate';

    lv_Sql := ' CREATE TABLE '||lv_TempTableProd||' AS '||chr(10)
        ||' SELECT DEPARTMENTCODE, SECTIONCODE, PRODUCTIONTYPE, MACHINECODE, SHIFTCODE, SUM(PRODUCTION) PRODUCTION, ROUND(SUM(VBAMOUNT),2) VBAMOUNT '||chr(10)
        ||' FROM ( '||chr(10)
        ||'         SELECT A.DEPARTMENTCODE,'''||lv_SectionCode||''' AS SECTIONCODE, A.PRODUCTIONTYPE,A.MACHINECODE,A.SHIFTCODE, '||chr(10) 
        ||'         A.QUALITYCODE, B.QUALITYRATE, SUM(NVL(TOTALPRODUCTION,0)) PRODUCTION, '||chr(10)  
        ||'         ROUND(ROUND(SUM(NVL(TOTALPRODUCTION,0))/NVL(B.UNITQUANTITY,1),2) *B.QUALITYRATE* NVL(B.PERCENTAGEOFRATE,100)*0.01,2) VBAMOUNT '||chr(10)  
        ||'         FROM WPSPRODUCTIONSUMMARY A, '||chr(10)  
        ||'         ( '||chr(10)  
        ||'          SELECT X.PRODUCTIONTYPE, X.QUALITYCODE, CASE WHEN NVL(X.UNITQUANTITY,1) = 0 THEN 1 ELSE NVL(X.UNITQUANTITY,1) END UNITQUANTITY, '||chr(10)  
        ||'          CASE WHEN NVL(X.PERCENTAGEOFRATE,0)=0 THEN 100 ELSE X.PERCENTAGEOFRATE END PERCENTAGEOFRATE, X.QUALITYRATE '||chr(10)  
        ||'          FROM  WPSQUALITYRATE_ON_REEDSPACE X, '||chr(10)  
        ||'          ( '||chr(10)  
        ||'              SELECT PRODUCTIONTYPE, QUALITYCODE, MAX(EFFECTIVEDATE) EFFECTIVEDATE '||chr(10)  
        ||'              FROM WPSQUALITYRATE_ON_REEDSPACE '||chr(10)  
        ||'              WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''   '||chr(10)
        ||'                AND PRODUCTIONTYPE = ''' ||lv_ProductionType|| '''   '||chr(10)
        ||'              GROUP BY PRODUCTIONTYPE, QUALITYCODE   '||chr(10)
        ||'          ) Y   '||chr(10)
        ||'          WHERE X.COMPANYCODE = '''||P_COMPCODE||''' AND X.DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)  
        ||'            AND X.PRODUCTIONTYPE = Y.PRODUCTIONTYPE    '||chr(10)
        ||'            AND X.QUALITYCODE = Y.QUALITYCODE AND X.EFFECTIVEDATE = Y.EFFECTIVEDATE  '||chr(10)  
        ||'      ) B  '||chr(10)
        ||'      WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)  
        ||'        AND A.YEARCODE = '''||P_YEARCODE||'''   '||chr(10) 
        ||'        AND A.STARTDATE >= '''||lv_fn_stdt||''' AND A.STARTDATE <= '''||lv_fn_endt||'''  '||chr(10)  
        ||'        AND A.PRODUCTIONTYPE = B.PRODUCTIONTYPE  AND A.QUALITYCODE = B.QUALITYCODE  '||chr(10)
        ||'      GROUP BY A.DEPARTMENTCODE,  A.PRODUCTIONTYPE, A.MACHINECODE,A.SHIFTCODE,  '||chr(10)
        ||'         A.QUALITYCODE, B.UNITQUANTITY, B.QUALITYRATE, B.PERCENTAGEOFRATE  '||chr(10)
        ||'     )  '||chr(10)
        ||' GROUP BY DEPARTMENTCODE, SECTIONCODE, PRODUCTIONTYPE, MACHINECODE, SHIFTCODE  '||chr(10);    

    EXECUTE IMMEDIATE lv_Sql;
    INSERT INTO WPS_ERROR_LOG (COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    values ( P_COMPCODE, P_DIVCODE, lv_ProcName,'',SYSDATE, lv_Sql,lv_ParValue, lv_FN_STDT, lv_FN_ENDT, lv_Remarks); 
    COMMIT; 
    
    lv_Remarks := 'INSERT INTO WPSLINEHOURLYRATE, PRODUCTION TYPE ' ||  lv_ProductionType;
    
    lv_Sql := ' INSERT INTO WPSLINEHOURLYRATE ( COMPANYCODE, DIVISIONCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE,'||chr(10) 
        ||' PRODUCTIONTYPE, DEPARTMENTCODE, SECTIONCODE, MACHINECODE1, SHIFTCODE,   '||chr(10)  
        ||' TOTALPRODUCTION, TOTALHOURS, TOTALBASIC, VBHOURLYRATE,TRANTYPE, OCCUPATIONTYPE, '||CHR(10)
        ||' LASTMODIFIED,USERNAME, SYSROWID)  '||chr(10) 
        ||'  SELECT '''||P_COMPCODE||''' COMPANYCODE,'''||P_DIVCODE||''' DIVISIONCODE, '''||lv_fn_stdt||''' FORTNIGHTSTARTDATE, '''||lv_fn_endt||''' FORTNIGHTENDDATE, '||CHR(10)
        ||'  A.PRODUCTIONTYPE, A.DEPARTMENTCODE, A.SECTIONCODE, A.MACHINECODE, A.SHIFTCODE, '||chr(10)
        ||'  A.PRODUCTION, B.ATTN_HRS, A.VBAMOUNT, '||CHR(10)
--        ||'  CASE WHEN OCCUPATIONTYPE = ''HALF PACKER'' THEN '||CHR(10) 
--        ||'     CASE WHEN B.ATTN_HRS >0 THEN ROUND((A.VBAMOUNT/B.TOT_HRS)+0.0096,5) ELSE 0 END '||CHR(10) 
--        ||'  ELSE '||CHR(10)
--        ||'     CASE WHEN B.ATTN_HRS >0 THEN ROUND((A.VBAMOUNT/B.TOT_HRS)+0.0488,5) ELSE 0 END '||CHR(10)
        ||'  CASE WHEN LTRIM(RTRIM(OCCUPATIONTYPE)) = ''HALF PACKER'' THEN '||CHR(10) 
        ||'     CASE WHEN B.ATTN_HRS >0 THEN ROUND(((A.VBAMOUNT - ((B.TOT_HRS-B.ATTN_HRS)*0.0488))/B.TOT_HRS),4)+0.0096 ELSE 0 END '||CHR(10)
        ||'  ELSE '||CHR(10) 
        ||'     CASE WHEN B.ATTN_HRS >0 THEN ROUND(((A.VBAMOUNT - (B.ATTN_HRS*0.0488))/B.TOT_HRS),4)+0.0488 ELSE 0 END '||CHR(10)        
        ||'  END VBHOURLYRATE,''VB'' TRANTYPE, B.OCCUPATIONTYPE, '||CHR(10)
        ||'  SYSDATE LASTMODIFIED, ''SWT'' USERNAME, SYS_GUID() '||CHR(10)
        ||'  FROM '||lv_TempTableProd||' A, '||lv_TempTableAttn||' B '||chr(10)
        ||'  WHERE A.MACHINECODE=B.MACHINECODE AND A.SHIFTCODE = B.SHIFTCODE '||chr(10)
        ||'  ORDER BY A.MACHINECODE, A.SHIFTCODE '||chr(10);        
    EXECUTE IMMEDIATE lv_Sql;
    INSERT INTO WPS_ERROR_LOG (COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    values ( P_COMPCODE, P_DIVCODE, lv_ProcName,'',SYSDATE, lv_Sql,lv_ParValue, lv_FN_STDT, lv_FN_ENDT, lv_Remarks); 
    COMMIT; 
    
    ---- data transfer to vb details table based on occupation type from line rate table -----------    
    --PROC_VB_WORKER_MACHINEWISE ( P_COMPCODE, P_DIVCODE, P_YEARCODE, P_FN_STDT, P_FN_ENDT,NULL,'WPSVBDETAILS',P_PRODUCTIONTYPE,NULL, NULL,NULL,NULL);
    
    PROC_VBDETAILS_OCPTYPE_INSERT ( P_COMPCODE, P_DIVCODE, P_YEARCODE, P_FN_STDT, P_FN_ENDT,NULL,'WPSVBDETAILS',lv_ProductionType,lv_DeptCode, lv_SectionCode,NULL,NULL);
    
exception    
    when others then
        lv_SqlErr := sqlerrm;
    INSERT INTO WPS_ERROR_LOG (COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    values ( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_SqlErr,SYSDATE, lv_Sql,lv_ParValue, lv_FN_STDT, lv_FN_ENDT, lv_Remarks);
    commit; 
End;
/


