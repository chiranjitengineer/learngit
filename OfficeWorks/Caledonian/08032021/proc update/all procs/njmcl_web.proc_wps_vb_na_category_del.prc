DROP PROCEDURE NJMCL_WEB.PROC_WPS_VB_NA_CATEGORY_DEL;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPS_VB_NA_CATEGORY_DEL( P_COMPCODE VARCHAR2, P_DIVCODE VARCHAR2, P_YEARCODE VARCHAR2,P_FN_STDT VARCHAR2, P_FN_ENDT VARCHAR2, P_1ST_WK_ENDT VARCHAR2 DEFAULT NULL, 
                                                         P_TABLENAME varchar2 DEFAULT 'WPSVBDETAILS', P_PRODUCTIONTYPE VARCHAR2 DEFAULT NULL, 
                                                         P_DEPARTMENT VARCHAR2 DEFAULT NULL, P_SECTION VARCHAR2 DEFAULT NULL, 
                                                         P_OCCUPATION VARCHAR2 DEFAULT NULL, P_WORKERSERIAL VARCHAR2 DEFAULT NULL)
AS
----- THIS PROCEDURE WRITTEN BY AMALESH ON 10.08.2019 ----
----- THIS PROCEDURE USE FOR CALCULATE OCCUPATION TYPE WISE RATE AND STORE IN WPSLINEHOURLYRATE TABLE -- 

lv_Sql      varchar2(20000) := '';
lv_ProcName varchar2(30) := 'PROC_WPS_VB_NA_CATEGORY_DEL';
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
    lv_Remarks := 'DELETE VBDETAILS TABLE CATEGORY NOT APPLICABLE TO VB';
    lv_Sql := ' DELETE FROM WPSVBDETAILS '||CHR(10) 
            ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'   AND FORTNIGHTSTARTDATE = '''||lv_FN_STDT||''' '||CHR(10)
            ||'   AND FORTNIGHTENDDATE = '''||lv_FN_ENDT||''' '||CHR(10)
            ||'   /*AND SECTIONCODE = '''||P_SECTION||''' */'||CHR(10)
            ||'   AND WORKERCATEGORYCODE IN ( '||CHR(10)
            ||'                                SELECT DISTINCT WORKERCATEGORYCODE FROM WPSWORKERCATEGORYVSCOMPONENT '||CHR(10)
            ||'                                WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'                                  AND EFFECTIVEDATE = ( '||CHR(10)
            ||'                                                          SELECT MAX(EFFECTIVEDATE) FROM WPSWORKERCATEGORYVSCOMPONENT '||CHR(10)
            ||'                                                          WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'                                                        )   '||CHR(10)
            ||'                                 AND COMPONENTSHORTNAME=''VBASIC''  '||CHR(10)
            ||'                                 AND APPLICABLE LIKE ''N%'' '||CHR(10)
            ||'                             ) '||CHR(10); 
    EXECUTE IMMEDIATE lv_Sql;
    INSERT INTO WPS_ERROR_LOG (COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    values ( P_COMPCODE, P_DIVCODE, lv_ProcName,'',SYSDATE, lv_Sql,lv_ParValue, lv_FN_STDT, lv_FN_ENDT, lv_Remarks); 
    COMMIT; 
    
    
exception    
    when others then
        lv_SqlErr := sqlerrm;
    INSERT INTO WPS_ERROR_LOG (COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    values ( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_SqlErr,SYSDATE, lv_Sql,lv_ParValue, lv_FN_STDT, lv_FN_ENDT, lv_Remarks);
    commit; 
End;
/


