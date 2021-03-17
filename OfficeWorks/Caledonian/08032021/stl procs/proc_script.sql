DROP PROCEDURE NJMCL_WEB.PRCMONTHLYPFDTATRFR_WITHSTL;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRCMONTHLYPFDTATRFR_WITHSTL" (
                                                            p_COMPANYCODE           VARCHAR2,
                                                            p_DIVISIONCODE          VARCHAR2,
                                                            p_YEARCODE              VARCHAR2,
                                                            p_PERIODFROM            VARCHAR2,
                                                            p_PERIODTO              VARCHAR2,
                                                            p_MODULE                VARCHAR2 DEFAULT 'ALL'
                                                        )
AS
lv_sqlstr           VARCHAR2(20000);
lv_sqlerrm          VARCHAR2(20000);
lv_YearMonthFrom    VARCHAR2(10);
lv_YearMonthTo      VARCHAR2(10);
lv_PFTrustCompCode  varchar2(10) := 'NJ0002';
lv_PFTrustDivCode   varchar2(10) := '0010';
BEGIN
    
    lv_YearMonthFrom := TO_CHAR(TO_DATE(p_PERIODFROM,'DD/MM/YYYY'),'YYYYMM'); 
    lv_YearMonthTo := TO_CHAR(TO_DATE(p_PERIODTO,'DD/MM/YYYY'),'YYYYMM');
    
    -- Delete Data From PFTRANSACTIONDETAILS
    
    BEGIN
        SELECT COMPANYCODE, DIVISIONCODE INTO lv_PFTrustCompCode, lv_PFTrustDivCode 
        FROM PFTRUSTMASTER;
    EXCEPTION
        WHEN OTHERS THEN
        lv_PFTrustCompCode  := 'NJ0002';
        lv_PFTrustDivCode   := '0010';                 
    END;
    IF p_MODULE = 'ALL' THEN        
        DELETE FROM PFTRANSACTIONDETAILS 
        WHERE YEARMONTH >= lv_YearMonthFrom
          AND YEARMONTH <= lv_YearMonthTo
          AND TRANSACTIONTYPE ='SALARY';
    ELSIF p_MODULE = 'WPS' THEN
        DELETE FROM PFTRANSACTIONDETAILS 
        WHERE STARTDATE >= TO_DATE(p_PERIODFROM,'DD/MM/YYYY')
          AND ENDDATE <= TO_DATE(p_PERIODTO,'DD/MM/YYYY')
          AND TRANSACTIONTYPE ='SALARY'
          AND MODULE='WPS';
    ELSE
        DELETE FROM PFTRANSACTIONDETAILS 
        WHERE YEARMONTH >= lv_YearMonthFrom
          AND YEARMONTH <= lv_YearMonthTo
          AND TRANSACTIONTYPE ='SALARY'
          AND MODULE = p_MODULE;        
    END IF;   
    
    -- PIS
    IF p_MODULE = 'ALL' OR p_MODULE = 'PIS' THEN
        INSERT INTO PFTRANSACTIONDETAILS 
        (
            COMPANYCODE, DIVISIONCODE, YEARCODE,YEARMONTH, STARTDATE,
            ENDDATE, PFNO, WORKERSERIAL, 
            TOKENNO,  COMPONENTCODE, COMPONENTAMOUNT, 
            TRANSACTIONTYPE,  POSTEDFROM, EMPLOYMENTTYPE, ADDLESS, PFTRUSTCODE, INT_PER, INT_AMT, TOTAL_AMT, 
            PENSIONNO, AVERAGEBALANCE, EMPLOYEECOMPANYCODE, EMPLOYEEDIVISIONCODE, MODULE,  REMARKS
        )
        SELECT 'NJ0002' COMPANYCODE,'0010' DIVISIONCODE, YEARCODE,YEARMONTH,TO_DATE('01/' || SUBSTR(YEARMONTH,5,2) || ',' || SUBSTR(YEARMONTH,1,4) || '','DD/MM/YYYY') STARTDATE,
               LAST_DAY(TO_DATE('01/' || SUBSTR(YEARMONTH,5,2) || ',' || SUBSTR(YEARMONTH,1,4) || '','DD/MM/YYYY')) ENDDATE,B.PFNO, A.WORKERSERIAL, 
               A.TOKENNO, 'PF_E' COMPONENTCODE, NVL(A.PF_E,0) COMPONENTAMOUNT, 
               'SALARY' TRANSACTIONTYPE, 'PIS' POSTEDFROM,'STAFF' EMPLOYMENTTYPE,'ADD' ADDLESS,'T001' PFTRUSTCODE,0 INT_PER,0 INT_AMT, NVL(A.PF_E,0) TOTAL_AMT, 
               B.PENSIONNO,0 AVERAGEBALANCE,A.COMPANYCODE EMPLOYEECOMPANYCODE,A.DIVISIONCODE EMPLOYEEDIVISIONCODE,'PIS' MODULE,'DATE MIGRATE'  REMARKS
        FROM PISPAYTRANSACTION A,
             PISEMPLOYEEMASTER B
        where A.COMPANYCODE = p_COMPANYCODE
          AND A.DIVISIONCODE = p_DIVISIONCODE
          AND A.yearmonth >= lv_YearMonthFrom
          AND A.yearmonth <= lv_YearMonthTo
          and NVL(A.PF_E,0) > 0
          AND A.COMPANYCODE = B.COMPANYCODE
          AND A.DIVISIONCODE = B.DIVISIONCODE
          AND A.WORKERSERIAL = B.WORKERSERIAL;
        
        INSERT INTO PFTRANSACTIONDETAILS 
        (
            COMPANYCODE, DIVISIONCODE, YEARCODE,YEARMONTH, STARTDATE,
            ENDDATE, PFNO, WORKERSERIAL, 
            TOKENNO, COMPONENTCODE, COMPONENTAMOUNT, 
            TRANSACTIONTYPE,  POSTEDFROM, EMPLOYMENTTYPE, ADDLESS, PFTRUSTCODE, INT_PER, INT_AMT, TOTAL_AMT, 
            PENSIONNO, AVERAGEBALANCE, EMPLOYEECOMPANYCODE, EMPLOYEEDIVISIONCODE, MODULE,  REMARKS
        )
        SELECT 'NJ0002' COMPANYCODE,'0010' DIVISIONCODE, YEARCODE,YEARMONTH,TO_DATE('01/' || SUBSTR(YEARMONTH,5,2) || ',' || SUBSTR(YEARMONTH,1,4) || '','DD/MM/YYYY') STARTDATE,
               LAST_DAY(TO_DATE('01/' || SUBSTR(YEARMONTH,5,2) || ',' || SUBSTR(YEARMONTH,1,4) || '','DD/MM/YYYY')) ENDDATE,B.PFNO, A.WORKERSERIAL, 
               A.TOKENNO, 'PF_C' COMPONENTCODE, NVL(A.PF_C,0) COMPONENTAMOUNT, 
               'SALARY' TRANSACTIONTYPE, 'PIS' POSTEDFROM,'STAFF' EMPLOYMENTTYPE,'ADD' ADDLESS,'T001' PFTRUSTCODE,0 INT_PER,0 INT_AMT, NVL(A.PF_C,0) TOTAL_AMT, 
               B.PENSIONNO,0 AVERAGEBALANCE,A.COMPANYCODE EMPLOYEECOMPANYCODE,A.DIVISIONCODE EMPLOYEEDIVISIONCODE,'PIS' MODULE,'DATE MIGRATE'  REMARKS
        FROM PISPAYTRANSACTION A,
             pisemployeeMASTER B
        where A.COMPANYCODE = p_COMPANYCODE
          AND A.DIVISIONCODE = p_DIVISIONCODE
          AND A.yearmonth >= lv_YearMonthFrom
          AND A.yearmonth <= lv_YearMonthTo
          and NVL(A.PF_C,0) > 0
          AND A.COMPANYCODE = B.COMPANYCODE
          AND A.DIVISIONCODE = B.DIVISIONCODE
          AND A.WORKERSERIAL = B.WORKERSERIAL;
        
        INSERT INTO PFTRANSACTIONDETAILS 
        (
            COMPANYCODE, DIVISIONCODE, YEARCODE,YEARMONTH, STARTDATE,
            ENDDATE, PFNO, WORKERSERIAL, 
            TOKENNO,  COMPONENTCODE, COMPONENTAMOUNT, 
            TRANSACTIONTYPE,  POSTEDFROM, EMPLOYMENTTYPE, ADDLESS, PFTRUSTCODE, INT_PER, INT_AMT, TOTAL_AMT, 
            PENSIONNO, AVERAGEBALANCE, EMPLOYEECOMPANYCODE, EMPLOYEEDIVISIONCODE, MODULE,  REMARKS
        )
        SELECT 'NJ0002' COMPANYCODE,'0010' DIVISIONCODE, YEARCODE,YEARMONTH,TO_DATE('01/' || SUBSTR(YEARMONTH,5,2) || ',' || SUBSTR(YEARMONTH,1,4) || '','DD/MM/YYYY') STARTDATE,
               LAST_DAY(TO_DATE('01/' || SUBSTR(YEARMONTH,5,2) || ',' || SUBSTR(YEARMONTH,1,4) || '','DD/MM/YYYY')) ENDDATE,B.PFNO, A.WORKERSERIAL, 
               A.TOKENNO, 'VPF' COMPONENTCODE, NVL(A.VPF,0) COMPONENTAMOUNT, 
               'SALARY' TRANSACTIONTYPE, 'PIS' POSTEDFROM,'STAFF' EMPLOYMENTTYPE,'ADD' ADDLESS,'T001' PFTRUSTCODE,0 INT_PER,0 INT_AMT,NVL(A.VPF,0) TOTAL_AMT, 
               B.PENSIONNO,0 AVERAGEBALANCE,A.COMPANYCODE EMPLOYEECOMPANYCODE,A.DIVISIONCODE EMPLOYEEDIVISIONCODE,'PIS' MODULE,'DATE MIGRATE'  REMARKS
        FROM PISPAYTRANSACTION A,
             PISEMPLOYEEMASTER B
        WHERE A.COMPANYCODE = p_COMPANYCODE
          AND A.DIVISIONCODE = p_DIVISIONCODE
          AND A.yearmonth >= lv_YearMonthFrom
          AND A.yearmonth <= lv_YearMonthTo
          and NVL(A.VPF,0) > 0
          AND A.COMPANYCODE = B.COMPANYCODE
          AND A.DIVISIONCODE = B.DIVISIONCODE
          AND A.WORKERSERIAL = B.WORKERSERIAL;
    END IF;    
    -- WPS
    IF p_MODULE = 'ALL' OR p_MODULE = 'WPS' THEN
        lv_sqlstr := 'INSERT INTO PFTRANSACTIONDETAILS '||CHR(10) 
                   ||' (    '||CHR(10)
                   ||' COMPANYCODE, DIVISIONCODE, YEARCODE,YEARMONTH, STARTDATE, '||CHR(10)
                   ||' ENDDATE, PFNO, WORKERSERIAL, '||CHR(10) 
                   ||' TOKENNO,  COMPONENTCODE, COMPONENTAMOUNT, '||CHR(10) 
                   ||' TRANSACTIONTYPE,  POSTEDFROM, EMPLOYMENTTYPE, ADDLESS, PFTRUSTCODE, INT_PER, INT_AMT, TOTAL_AMT, '||CHR(10) 
                   ||' PENSIONNO, AVERAGEBALANCE, EMPLOYEECOMPANYCODE, EMPLOYEEDIVISIONCODE, MODULE,  REMARKS '||CHR(10)
                   ||' ) '||CHR(10)
          -- changes 19.08.2020          
                   ||' SELECT  COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, STARTDATE, ENDDATE, PFNO, WORKERSERIAL, TOKENNO, COMPONENTCODE, SUM(NVL(COMPONENTAMOUNT,0))COMPONENTAMOUNT, TRANSACTIONTYPE, '||CHR(10)
                   ||' POSTEDFROM, EMPLOYMENTTYPE, ADDLESS, PFTRUSTCODE, INT_PER, SUM(NVL(INT_AMT,0))INT_AMT, SUM(NVL(TOTAL_AMT,0))TOTAL_AMT, PENSIONNO, AVERAGEBALANCE, EMPLOYEECOMPANYCODE, '||CHR(10)
                   ||' EMPLOYEEDIVISIONCODE, MODULE, REMARKS FROM (  '||CHR(10)
          -- end  changes 19.08.2020                  
                   ||' SELECT  '''||lv_PFTrustCompCode||''' COMPANYCODE,'''||lv_PFTrustDivCode||''' DIVISIONCODE,'''||p_YEARCODE||''' YEARCODE,TO_CHAR(FORTNIGHTSTARTDATE,''YYYYMM'') YEARMONTH,FORTNIGHTSTARTDATE STARTDATE, '||chr(10)
                   ||' FORTNIGHTENDDATE ENDDATE,B.PFNO, A.WORKERSERIAL, '||chr(10) 
                   ||' A.TOKENNO, ''PF_E'' COMPONENTCODE,PF_CONT COMPONENTAMOUNT, '||chr(10) 
                   ||' ''SALARY'' TRANSACTIONTYPE, ''WPS'' POSTEDFROM,''WORKER'' EMPLOYMENTTYPE,''ADD'' ADDLESS,''T001'' PFTRUSTCODE,0 INT_PER,0 INT_AMT,PF_CONT TOTAL_AMT, '||chr(10) 
                   ||'  B.PENSIONNO,0 AVERAGEBALANCE,A.COMPANYCODE EMPLOYEECOMPANYCODE,A.DIVISIONCODE EMPLOYEEDIVISIONCODE,''WPS'' MODULE,''DATA TRANSAFER FROM SALARY''  REMARKS '||CHR(10)
                   ||' FROM WPSWAGESDETAILS_MV A, '||CHR(10)
                   ||' WPSWORKERMAST B '||CHR(10)
                   ||' where A.COMPANYCODE = '''||p_COMPANYCODE||''' '||CHR(10)
                   ||'   AND A.DIVISIONCODE = '''||p_DIVISIONCODE||'''  '||CHR(10)
                   ||'   AND A.FORTNIGHTSTARTDATE >= TO_DATE('''||p_PERIODFROM||''',''DD/MM/YYYY'') '||CHR(10)
                   ||'   AND A.FORTNIGHTSTARTDATE <= TO_DATE('''||p_PERIODTO||''',''DD/MM/YYYY'') '||CHR(10)
                   ||'   AND A.COMPANYCODE = B.COMPANYCODE '||CHR(10)
                   ||'   AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
                   ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
                   ||'   AND PF_CONT > 0 '||CHR(10);
        -- changes 19.08.2020           
        lv_sqlstr := lv_sqlstr ||' UNION ALL '||CHR(10)
                   ||' SELECT  '''||lv_PFTrustCompCode||''' COMPANYCODE,'''||lv_PFTrustDivCode||''' DIVISIONCODE,'''||p_YEARCODE||''' YEARCODE,TO_CHAR(PAYMENTDATE,''YYYYMM'') YEARMONTH,TO_DATE('''||p_PERIODFROM||''',''DD/MM/YYYY'') STARTDATE, '||chr(10)
                   ||' TO_DATE('''||p_PERIODTO||''',''DD/MM/YYYY'') ENDDATE,B.PFNO, A.WORKERSERIAL, '||chr(10) 
                   ||' A.TOKENNO, ''PF_E'' COMPONENTCODE,PF_E COMPONENTAMOUNT, '||chr(10) 
                   ||' ''SALARY'' TRANSACTIONTYPE, ''WPS'' POSTEDFROM,''WORKER'' EMPLOYMENTTYPE,''ADD'' ADDLESS,''T001'' PFTRUSTCODE,0 INT_PER,0 INT_AMT,PF_E TOTAL_AMT, '||chr(10) 
                   ||'  B.PENSIONNO,0 AVERAGEBALANCE,A.COMPANYCODE EMPLOYEECOMPANYCODE,A.DIVISIONCODE EMPLOYEEDIVISIONCODE,''WPS'' MODULE,''DATA TRANSAFER FROM SALARY''  REMARKS '||CHR(10)
                   ||' FROM WPSSTLWAGESDETAILS A, '||CHR(10)
                   ||' WPSWORKERMAST B '||CHR(10)
                   ||' where A.COMPANYCODE = '''||p_COMPANYCODE||''' '||CHR(10)
                   ||'   AND A.DIVISIONCODE = '''||p_DIVISIONCODE||'''  '||CHR(10)
                   ||'   AND A.PAYMENTDATE >= TO_DATE('''||p_PERIODFROM||''',''DD/MM/YYYY'') '||CHR(10)
                   ||'   AND A.PAYMENTDATE <= TO_DATE('''||p_PERIODTO||''',''DD/MM/YYYY'') '||CHR(10)
                   ||'   AND A.COMPANYCODE = B.COMPANYCODE '||CHR(10)
                   ||'   AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
                   ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
                   ||'   AND PF_E > 0  '||CHR(10)                  
                   ||' )'||CHR(10)
                   ||' GROUP BY COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, STARTDATE, ENDDATE, PFNO, WORKERSERIAL, TOKENNO, COMPONENTCODE, TRANSACTIONTYPE, '||CHR(10)
                   ||' POSTEDFROM, EMPLOYMENTTYPE, ADDLESS, PFTRUSTCODE, INT_PER, INT_AMT,  PENSIONNO, AVERAGEBALANCE, EMPLOYEECOMPANYCODE, '||CHR(10)
                   ||' EMPLOYEEDIVISIONCODE, MODULE, REMARKS  '||CHR(10);
          --end changes 19.08.2020         
        
        dbms_output.put_line(lv_sqlstr);
        EXECUTE IMMEDIATE  lv_sqlstr;
        
        lv_sqlstr := 'INSERT INTO PFTRANSACTIONDETAILS '||CHR(10) 
                   ||' (    '||CHR(10)
                   ||' COMPANYCODE, DIVISIONCODE, YEARCODE,YEARMONTH, STARTDATE, '||CHR(10)
                   ||' ENDDATE, PFNO, WORKERSERIAL, '||CHR(10) 
                   ||' TOKENNO,  COMPONENTCODE, COMPONENTAMOUNT, '||CHR(10) 
                   ||' TRANSACTIONTYPE,  POSTEDFROM, EMPLOYMENTTYPE, ADDLESS, PFTRUSTCODE, INT_PER, INT_AMT, TOTAL_AMT, '||CHR(10) 
                   ||' PENSIONNO, AVERAGEBALANCE, EMPLOYEECOMPANYCODE, EMPLOYEEDIVISIONCODE, MODULE,  REMARKS '||CHR(10)
                   ||' ) '||CHR(10)
          -- changes 19.08.2020          
                   ||' SELECT  COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, STARTDATE, ENDDATE, PFNO, WORKERSERIAL, TOKENNO, COMPONENTCODE, SUM(NVL(COMPONENTAMOUNT,0))COMPONENTAMOUNT, TRANSACTIONTYPE, '||CHR(10)
                   ||' POSTEDFROM, EMPLOYMENTTYPE, ADDLESS, PFTRUSTCODE, INT_PER, SUM(NVL(INT_AMT,0))INT_AMT, SUM(NVL(TOTAL_AMT,0))TOTAL_AMT, PENSIONNO, AVERAGEBALANCE, EMPLOYEECOMPANYCODE, '||CHR(10)
                   ||' EMPLOYEEDIVISIONCODE, MODULE, REMARKS FROM (  '||CHR(10)
          -- end  changes 19.08.2020       
                   ||' SELECT  '''||lv_PFTrustCompCode||''' COMPANYCODE,'''||lv_PFTrustDivCode||''' DIVISIONCODE,'''||p_YEARCODE||''' YEARCODE,TO_CHAR(FORTNIGHTSTARTDATE,''YYYYMM'') YEARMONTH,FORTNIGHTSTARTDATE STARTDATE, '||chr(10)
                   ||' FORTNIGHTENDDATE ENDDATE,B.PFNO, A.WORKERSERIAL, '||chr(10) 
                   ||' A.TOKENNO, ''PF_C'' COMPONENTCODE, NVL(A.PF_COM,0) COMPONENTAMOUNT, '||chr(10) 
                   ||' ''SALARY'' TRANSACTIONTYPE, ''WPS'' POSTEDFROM,''WORKER'' EMPLOYMENTTYPE,''ADD'' ADDLESS,''T001'' PFTRUSTCODE,0 INT_PER,0 INT_AMT,NVL(A.PF_COM,0) TOTAL_AMT, '||chr(10) 
                   ||'  B.PENSIONNO,0 AVERAGEBALANCE,A.COMPANYCODE EMPLOYEECOMPANYCODE,A.DIVISIONCODE EMPLOYEEDIVISIONCODE,''WPS'' MODULE,''DATA TRANSAFER FROM SALARY''  REMARKS '||CHR(10)
                   ||' FROM WPSWAGESDETAILS_MV A, '||CHR(10)
                   ||' WPSWORKERMAST B '||CHR(10)
                   ||' where A.COMPANYCODE = '''||p_COMPANYCODE||''' '||CHR(10)
                   ||'   AND A.DIVISIONCODE = '''||p_DIVISIONCODE||'''  '||CHR(10)
                   ||'   AND A.FORTNIGHTSTARTDATE >= TO_DATE('''||p_PERIODFROM||''',''DD/MM/YYYY'') '||CHR(10)
                   ||'   AND A.FORTNIGHTSTARTDATE <= TO_DATE('''||p_PERIODTO||''',''DD/MM/YYYY'') '||CHR(10)
                   ||'   AND A.COMPANYCODE = B.COMPANYCODE '||CHR(10)
                   ||'   AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
                   ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
                   ||'   AND NVL(A.PF_COM,0) > 0 '||CHR(10);
          -- changes 19.08.2020              
          lv_sqlstr := lv_sqlstr ||' UNION ALL '||CHR(10)
                   ||' SELECT  '''||lv_PFTrustCompCode||''' COMPANYCODE,'''||lv_PFTrustDivCode||''' DIVISIONCODE,'''||p_YEARCODE||''' YEARCODE,TO_CHAR(PAYMENTDATE,''YYYYMM'') YEARMONTH,TO_DATE('''||p_PERIODFROM||''',''DD/MM/YYYY'') STARTDATE, '||chr(10)
                   ||'  TO_DATE('''||p_PERIODTO||''',''DD/MM/YYYY'') ENDDATE,B.PFNO, A.WORKERSERIAL, '||chr(10) 
                   ||' A.TOKENNO, ''PF_C'' COMPONENTCODE,PF_C COMPONENTAMOUNT, '||chr(10) 
                   ||' ''SALARY'' TRANSACTIONTYPE, ''WPS'' POSTEDFROM,''WORKER'' EMPLOYMENTTYPE,''ADD'' ADDLESS,''T001'' PFTRUSTCODE,0 INT_PER,0 INT_AMT,PF_C TOTAL_AMT, '||chr(10) 
                   ||'  B.PENSIONNO,0 AVERAGEBALANCE,A.COMPANYCODE EMPLOYEECOMPANYCODE,A.DIVISIONCODE EMPLOYEEDIVISIONCODE,''WPS'' MODULE,''DATA TRANSAFER FROM SALARY''  REMARKS '||CHR(10)
                   ||' FROM WPSSTLWAGESDETAILS A, '||CHR(10)
                   ||' WPSWORKERMAST B '||CHR(10)
                   ||' where A.COMPANYCODE = '''||p_COMPANYCODE||''' '||CHR(10)
                   ||'   AND A.DIVISIONCODE = '''||p_DIVISIONCODE||'''  '||CHR(10)
                   ||'   AND A.PAYMENTDATE >= TO_DATE('''||p_PERIODFROM||''',''DD/MM/YYYY'') '||CHR(10)
                   ||'   AND A.PAYMENTDATE <= TO_DATE('''||p_PERIODTO||''',''DD/MM/YYYY'') '||CHR(10)
                   ||'   AND A.COMPANYCODE = B.COMPANYCODE '||CHR(10)
                   ||'   AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
                   ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
                   ||'   AND PF_C > 0 '||CHR(10)
                   ||' )'||CHR(10)
                   ||' GROUP BY COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, STARTDATE, ENDDATE, PFNO, WORKERSERIAL, TOKENNO, COMPONENTCODE, TRANSACTIONTYPE, '||CHR(10)
                   ||' POSTEDFROM, EMPLOYMENTTYPE, ADDLESS, PFTRUSTCODE, INT_PER, INT_AMT,  PENSIONNO, AVERAGEBALANCE, EMPLOYEECOMPANYCODE, '||CHR(10)
                   ||' EMPLOYEEDIVISIONCODE, MODULE, REMARKS  '||CHR(10);   
           -- end  changes 19.08.2020      
                   
      -- dbms_output.put_line(lv_sqlstr);
        EXECUTE IMMEDIATE  lv_sqlstr;

        lv_sqlstr := 'INSERT INTO PFTRANSACTIONDETAILS '||CHR(10) 
                   ||' (    '||CHR(10)
                   ||' COMPANYCODE, DIVISIONCODE, YEARCODE,YEARMONTH, STARTDATE, '||CHR(10)
                   ||' ENDDATE, PFNO, WORKERSERIAL, '||CHR(10) 
                   ||' TOKENNO,  COMPONENTCODE, COMPONENTAMOUNT, '||CHR(10) 
                   ||' TRANSACTIONTYPE,  POSTEDFROM, EMPLOYMENTTYPE, ADDLESS, PFTRUSTCODE, INT_PER, INT_AMT, TOTAL_AMT, '||CHR(10) 
                   ||' PENSIONNO, AVERAGEBALANCE, EMPLOYEECOMPANYCODE, EMPLOYEEDIVISIONCODE, MODULE,  REMARKS '||CHR(10)
                   ||' ) '||CHR(10)
--          -- changes 19.08.2020          
--                   ||' SELECT COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, STARTDATE, ENDDATE, PFNO, WORKERSERIAL, TOKENNO, COMPONENTCODE, SUM(NVL(COMPONENTAMOUNT,0))COMPONENTAMOUNT, TRANSACTIONTYPE, '||CHR(10)
--                   ||' POSTEDFROM, EMPLOYMENTTYPE, ADDLESS, PFTRUSTCODE, INT_PER, SUM(NVL(INT_AMT,0))INT_AMT, SUM(NVL(TOTAL_AMT,0))TOTAL_AMT, PENSIONNO, AVERAGEBALANCE, EMPLOYEECOMPANYCODE, '||CHR(10)
--                   ||' EMPLOYEEDIVISIONCODE, MODULE, REMARKS FROM (  '||CHR(10)
--          -- end  changes 19.08.2020  
                   ||' SELECT  '''||lv_PFTrustCompCode||''' COMPANYCODE,'''||lv_PFTrustDivCode||''' DIVISIONCODE,'''||p_YEARCODE||''' YEARCODE,TO_CHAR(FORTNIGHTSTARTDATE,''YYYYMM'') YEARMONTH,FORTNIGHTSTARTDATE STARTDATE, '||chr(10)
                   ||' FORTNIGHTENDDATE ENDDATE,B.PFNO, A.WORKERSERIAL, '||chr(10) 
                   ||' A.TOKENNO, ''VPF'' COMPONENTCODE, NVL(A.VPF,0) COMPONENTAMOUNT, '||chr(10) 
                   ||' ''SALARY'' TRANSACTIONTYPE, ''WPS'' POSTEDFROM,''WORKER'' EMPLOYMENTTYPE,''ADD'' ADDLESS,''T001'' PFTRUSTCODE,0 INT_PER,0 INT_AMT,NVL(A.VPF,0) TOTAL_AMT, '||chr(10) 
                   ||'  B.PENSIONNO,0 AVERAGEBALANCE,A.COMPANYCODE EMPLOYEECOMPANYCODE,A.DIVISIONCODE EMPLOYEEDIVISIONCODE,''WPS'' MODULE,''DATA TRANSAFER FROM SALARY''  REMARKS '||CHR(10)
                   ||' FROM WPSWAGESDETAILS_MV A, '||CHR(10)
                   ||' WPSWORKERMAST B '||CHR(10)
                   ||' where A.COMPANYCODE = '''||p_COMPANYCODE||''' '||CHR(10)
                   ||'   AND A.DIVISIONCODE = '''||p_DIVISIONCODE||'''  '||CHR(10)
                   ||'   AND A.FORTNIGHTSTARTDATE >= TO_DATE('''||p_PERIODFROM||''',''DD/MM/YYYY'') '||CHR(10)
                   ||'   AND A.FORTNIGHTSTARTDATE <= TO_DATE('''||p_PERIODTO||''',''DD/MM/YYYY'') '||CHR(10)
                   ||'   AND A.COMPANYCODE = B.COMPANYCODE '||CHR(10)
                   ||'   AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
                   ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
                   ||'   AND NVL(A.VPF,0) > 0 '||CHR(10);
          -- changes 19.08.2020              
--          lv_sqlstr := lv_sqlstr ||' UNION ALL '||CHR(10)
--                   ||' SELECT  '''||lv_PFTrustCompCode||''' COMPANYCODE,'''||lv_PFTrustDivCode||''' DIVISIONCODE,'''||p_YEARCODE||''' YEARCODE,TO_CHAR(PAYMENTDATE,''YYYYMM'') YEARMONTH,TO_DATE('''||p_PERIODFROM||''',''DD/MM/YYYY'') STARTDATE, '||chr(10)
--                   ||'  TO_DATE('''||p_PERIODTO||''',''DD/MM/YYYY'') ENDDATE,B.PFNO, A.WORKERSERIAL, '||chr(10) 
--                   ||' A.TOKENNO, ''VPF'' COMPONENTCODE,VPF COMPONENTAMOUNT, '||chr(10) 
--                   ||' ''SALARY'' TRANSACTIONTYPE, ''WPS'' POSTEDFROM,''WORKER'' EMPLOYMENTTYPE,''ADD'' ADDLESS,''T001'' PFTRUSTCODE,0 INT_PER,0 INT_AMT,VPF TOTAL_AMT, '||chr(10) 
--                   ||'  B.PENSIONNO,0 AVERAGEBALANCE,A.COMPANYCODE EMPLOYEECOMPANYCODE,A.DIVISIONCODE EMPLOYEEDIVISIONCODE,''WPS'' MODULE,''DATA TRANSAFER FROM SALARY''  REMARKS '||CHR(10)
--                   ||' FROM WPSSTLWAGESDETAILS A, '||CHR(10)
--                   ||' WPSWORKERMAST B '||CHR(10)
--                   ||' where A.COMPANYCODE = '''||p_COMPANYCODE||''' '||CHR(10)
--                   ||'   AND A.DIVISIONCODE = '''||p_DIVISIONCODE||'''  '||CHR(10)
--                   ||'   AND A.PAYMENTDATE >= TO_DATE('''||p_PERIODFROM||''',''DD/MM/YYYY'') '||CHR(10)
--                   ||'   AND A.PAYMENTDATE <= TO_DATE('''||p_PERIODTO||''',''DD/MM/YYYY'') '||CHR(10)
--                   ||'   AND A.COMPANYCODE = B.COMPANYCODE '||CHR(10)
--                   ||'   AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
--                   ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
--                   ||'   AND VPF > 0 '||CHR(10)
--                   ||' )'||CHR(10)
--                   ||' GROUP BY COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, STARTDATE, ENDDATE, PFNO, WORKERSERIAL, TOKENNO, COMPONENTCODE, TRANSACTIONTYPE, '||CHR(10)
--                   ||' POSTEDFROM, EMPLOYMENTTYPE, ADDLESS, PFTRUSTCODE, INT_PER, INT_AMT,  PENSIONNO, AVERAGEBALANCE, EMPLOYEECOMPANYCODE, '||CHR(10)
--                   ||' EMPLOYEEDIVISIONCODE, MODULE, REMARKS  '||CHR(10);   
           -- end  changes 19.08.2020     
                      
       -- dbms_output.put_line(lv_sqlstr);
        EXECUTE IMMEDIATE  lv_sqlstr;        
              
         if p_MODULE = 'ALL' then
            UPDATE WPSWAGEDPERIODDECLARATION
               SET FINALISEDANDLOCK='Y'
             WHERE FORTNIGHTSTARTDATE>=TO_DATE(p_PERIODFROM,'DD/MM/RRRR')
               AND FORTNIGHTENDDATE<=TO_DATE(p_PERIODTO,'DD/MM/RRRR');
        end if;
    end if;
     --dbms_output.put_line(p_PFNO);
--exception
--    when others then
--    lv_sqlerrm := sqlerrm ;
----    dbms_output.put_line(lv_sqlerrm);
--    --insert into error_log(PROC_NAME,ERROR_QUERY ) values( 'REFUNDABLE LOAN DATA',lv_sqlstr);
--    commit;
END;
/


DROP PROCEDURE NJMCL_WEB.PRCWPS_STLENTITLE_PROCESS_NJML;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.prcWPS_STLENTITLE_PROCESS_NJML( P_COMPCODE varchar2, 
                                                       P_DIVCODE varchar2, 
                                                       P_YEAR varchar2, 
                                                       P_USER varchar2,
                                                       p_StandardSTLHours number,
                                                       p_AdjustmentSTLHours number default 0,
                                                       p_Workerserial varchar2 default null,
                                                       p_HoursforOnedaySTL number default 160
                                                   )
as
lv_ProcName             varchar2(30):= 'prcWPS_STLENTITLE_PROCESS_NJML';
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '';
lv_Remarks              varchar2(1000) := '';
lv_ParValues            varchar2(500) := '';
lv_SqlErrm              varchar2(500) := '';
lv_FNStartDate          date;
lv_FNEndDate            date;
lv_Cnt                  number:=0;
lv_PrevYear             varchar2(4); --2016
lv_B4PrevYear           varchar2(4); --2015
lv_PrevB4PrevYear       varchar2(4); --2014
lv_fn_stdt              date;
lv_fn_endt              date;
lv_Cur_fn_stdt              date;
lv_Cur_fn_endt              date;

lv_Yr_endt              date;
lv_YearCode             varchar2(10);
lv_Sql                  varchar2(10000);
lv_ApplicableStndhrs    number :=1920;
lv_StndSTLDays          number :=Round(p_StandardSTLHours/8,0);
lv_AdjSTLDays           number :=0;

--EXEC prcWPS_STLENTITLE_PROCESS_NJML('CJ0048','0003','2017','SWT',1920, 0,'', 160 )
begin
    ---- FOLLOWING POINTS CONSIDER IN THIS PROCEDURE FOR STL ENTILEMENT CALCULATION --------
    ---- 1. Previous year STL consider in the same year in column prev. year STL 
    ---- 2. When wokrer join in the current calendar year then STL consider working days 20 in enverymonth.
    
    lv_result:='#SUCCESS#';
    lv_Remarks := 'STLENTITLE PROCESS';
    lv_PrevYear := substr(P_YEAR,1,2)|| to_number(substr(P_YEAR,3))-1;
    lv_B4PrevYear := substr(P_YEAR,1,2)|| to_number(substr(P_YEAR,3))-2;
    lv_PrevB4PrevYear := substr(P_YEAR,1,2)|| to_number(substr(P_YEAR,3))-3;
    
    lv_fn_stdt := to_date('01/01/'||P_YEAR,'DD/MM/YYYY');
    lv_fn_endt := to_date('15/01/'||P_YEAR,'DD/MM/YYYY');
    lv_Yr_endt := to_date('31/12/'||P_YEAR,'DD/MM/YYYY');
    
    lv_Cur_fn_stdt := to_date('01/01/'||TO_CHAR(P_YEAR+1),'DD/MM/YYYY');
    lv_Cur_fn_endt := to_date('15/01/'||TO_CHAR(P_YEAR+1),'DD/MM/YYYY');
       
    lv_ApplicableStndhrs := p_StandardSTLHours - p_AdjustmentSTLHours;
    
    lv_ParValues := 'YEAR - '||P_YEAR||',STANDARD HRS - '||p_StandardSTLHours||', Adj Hrs - '||p_AdjustmentSTLHours;
        
    SELECT YEARCODE INTO lv_YearCode 
    FROM FINANCIALYEAR 
    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
    AND STARTDATE <= lv_fn_stdt AND ENDDATE >= lv_fn_stdt;

    lv_sql := 'DELETE FROM WPSSTLTRANSACTION WHERE TRANSACTIONTYPE <>''OPENING'' AND FROMYEAR='||P_YEAR||' '||chr(10);
--    DBMS_OUTPUT.PUT_LINE (lv_Sql);
    
    --execute immediate lv_Sql;
        

    lv_Sql := 'DELETE FROM WPSSTLENTITLEMENTCALCDETAILS '||chr(10) 
        ||' WHERE FORTNIGHTSTARTDATE='''||lv_Cur_fn_stdt||''' AND FORTNIGHTENDDATE='''||lv_Cur_fn_endt||''' '||chr(10);
    
--    DBMS_OUTPUT.PUT_LINE (lv_Sql);
    
    execute immediate lv_Sql;


    lv_Remarks := 'STL ENTITLEMENT CALCULATION PROCESS'; 
--    DBMS_OUTPUT.PUT_LINE ('1_1');

    lv_Sql := ' INSERT INTO WPSSTLENTITLEMENTCALCDETAILS ( '||CHR(10)
        ||' COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, CATEGORYCODE, FROMYEAR, YEARCODE, '||CHR(10) 
        ||' FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, DEPARTMENTCODE, SHIFTCODE, '||CHR(10) 
        ||' ATTNHOURS, FESTHOURS, HOLIDAYHOURS, TOTALHOURS, STLHRSTAKEN, STLDAYSTAKEN, '||CHR(10) 
        ||' STANDARDSTLHOURS, ADJUSTEDHOURS, APPLICABLESTANDHOURS, STLDAYS, STLHOURS, STLDAYS_BF, '||CHR(10) 
        ||' TRANSACTIONTYPE, ADDLESS, USERNAME, LASTMODIFIED, SYSROWID, STLHOURSTAKEN_CURYEAR) '||CHR(10)
        ||' SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, '''||TO_CHAR(P_YEAR)||''' FROMYEAR, '''||lv_YearCode||''' YEARCODE, '||CHR(10)
        ||' '''||lv_Cur_fn_stdt||''' FORTNIGHTSTARTDATE, '''||lv_Cur_fn_endt||''' FORTNIGHTENDDATE, DEPARTMENTCODE, ''1'' SHIFTCODE, '||CHR(10)
        ||' ATTN_HRS ATTNHOURS, 0 FESTHOURS, HOL_HRS HOLIDAYHOURS, (ATTN_HRS) TOTALHOURS, STL_HRS, STL_DAYS STLDAYSTAKEN, '||CHR(10)
        ||' STNDHRS STANDARDSTLHOURS, '||p_AdjustmentSTLHours||' ADJUSTEDHOURS, '||lv_ApplicableStndhrs||' APPLICABLESTANDHOURS, ENT_DAYS STLDAYS, ENT_DAYS*8 STLHOURS, PREV_ENT_STLDAYS STLDAYS_BF, '||CHR(10);
 --    DBMS_OUTPUT.PUT_LINE ('1_2');        
     lv_Sql := lv_Sql ||' ''ENTITLEMENT'' TRANSACTIONTYPE, ''ADD'' ADDLESS, '''||P_USER||''' USERNAME, SYSDATE LASTMODIFIED, WORKERSERIAL||''-''||TO_CHAR(SYSDATE,''YYYYMMDDHHMISS'') SYSROWID '||CHR(10)
        ||' , 0 STLHOURSTAKEN_CURYEAR '||CHR(10) 
        ||' FROM ( '||CHR(10)
        ||' SELECT B.COMPANYCODE, B.DIVISIONCODE, A.WORKERSERIAL, B.TOKENNO, B.WORKERCATEGORYCODE, B.DEPARTMENTCODE, B.DATEOFJOINING, '||CHR(10)
        ||' SUM(PREV_STLDAYS) PREV_STLDAYS, SUM(PRV_STLHRS) PRV_STLHRS, '||CHR(10)
        ||' SUM(ATTN_HRS) ATTN_HRS, SUM(HOL_HRS) HOL_HRS, CASE WHEN SUM(STL_HRS) > 0 THEN case when (SUM(STL_HRS) - SUM(PRV_STLHRS_CALC)) > 0 then SUM(STL_HRS) - SUM(PRV_STLHRS_CALC) else 0 end ELSE 0 END STL_HRS, '||CHR(10)
        ||' SUM(ELIGIBLE_HRS) ELIGIBLE_HRS, SUM(ATTN_DAYS) ATTN_DAYS, SUM(STL_DAYS) STL_DAYS, SUM(HOL_DAYS) HOL_DAYS, '||CHR(10) 
        ||' SUM(ELIGIBLE_DAYS) ELIGIBLE_DAYS, '||CHR(10)
        ||' CASE WHEN SUM(STLENCASH_HRS)> 0 THEN 0 ELSE SUM(PREV_STLDAYS) - SUM(STL_DAYS) END PREV_ENT_STLDAYS, '||CHR(10)
        ||' CASE WHEN SUM(STLENCASH_HRS) > 0 THEN 0 '||CHR(10)
        ||' ELSE '||CHR(10) 
        ||'     CASE WHEN B.DATEOFJOINING <= '''||lv_fn_stdt||''' THEN '||CHR(10) 
        ||'         CASE WHEN SUM(ELIGIBLE_HRS) >='||p_StandardSTLHours||' THEN ROUND(SUM(ATTN_DAYS)/20,0) ELSE 0 END '||CHR(10)
        ||'     ELSE CASE WHEN SUM(ELIGIBLE_HRS) >= '||p_StandardSTLHours||' - ((TO_NUMBER(TO_CHAR(DATEOFJOINING,''MM''))-1)*'||  p_HoursforOnedaySTL || ') THEN ROUND(SUM(ATTN_DAYS)/20,0) '||CHR(10)
        ||'             ELSE 0 END '||CHR(10)
        ||'     END '||CHR(10)
        ||' END ENT_DAYS '||CHR(10)
        ||' , CASE WHEN B.DATEOFJOINING <= '''||lv_fn_stdt||''' THEN '||p_StandardSTLHours||' '||CHR(10)
        ||'        ELSE  ((12-TO_NUMBER(TO_CHAR(DATEOFJOINING,''MM'')))*'|| p_HoursforOnedaySTL || ') END STNDHRS '||CHR(10)
        ||' FROM (  '||CHR(10)
        ||'        select WORKERSERIAL, SUM(PREV_STLDAYS) PREV_STLDAYS, SUM(PRV_STLHRS) PRV_STLHRS, '||CHR(10) 
        ||'         SUM(PRV_STLHRS_CALC) PRV_STLHRS_CALC,SUM(ATTN_HRS) ATTN_HRS, SUM(HOL_HRS) HOL_HRS,  '||CHR(10) 
        ||'         SUM(STL_HRS) STL_HRS, SUM(STLENCASH_HRS) STLENCASH_HRS,'||CHR(10)
        ||'         (SUM(NVL(ATTN_HRS,0)) + (CASE WHEN SUM(STL_HRS) > 0 THEN CASE WHEN  (SUM(STL_HRS)- SUM(PRV_STLHRS_CALC)) > 0 THEN (SUM(STL_HRS)- SUM(PRV_STLHRS_CALC)) ELSE 0 END ELSE 0 END)) ELIGIBLE_HRS,  '||CHR(10) 
        ||'         ROUND(SUM(NVL(ATTN_HRS,0))/8,2) ATTN_DAYS,  '||CHR(10)
        ||'         ROUND(SUM(NVL(STL_HRS,0))/8,2) STL_DAYS,  '||CHR(10)
        ||'         ROUND(SUM(NVL(HOL_HRS,0))/8,2) HOL_DAYS,  '||CHR(10)
        ||'         ROUND((SUM(NVL(ATTN_HRS,0)) + (CASE WHEN  (SUM(STL_HRS)- SUM(PRV_STLHRS_CALC)) > 0 THEN (SUM(STL_HRS)- SUM(PRV_STLHRS_CALC)) ELSE 0 END ))/8,2) ELIGIBLE_DAYS  '||CHR(10)
        ||'         FROM (  '||CHR(10) 
        ||'                 SELECT WORKERSERIAL, /*FORTNIGHTSTARTDATE, */ 0 PREV_STLDAYS,  0 PRV_STLHRS, '||CHR(10)
        ||'                 0 PRV_STLHRS_CALC,SUM(NVL(ATTENDANCEHOURS,0)) ATTN_HRS, SUM(NVL(HOLIDAYHOURS,0)) HOL_HRS, '||CHR(10)
        ||'                 SUM(NVL(STLHOURS,0)+NVL(STLHOURS_ENCASH,0)) STL_HRS, SUM(NVL(STLHOURS_ENCASH,0)) STLENCASH_HRS, '||CHR(10)
        ||'                 SUM(NVL(ATTENDANCEHOURS,0)) + SUM(NVL(STLHOURS,0)+NVL(STLHOURS_ENCASH,0)) ELIGIBLE_HRS, '||CHR(10)
        ||'                 ROUND(SUM(NVL(ATTENDANCEHOURS,0))/8,2) ATTN_DAYS, '||CHR(10) 
        ||'                 ROUND(SUM(NVL(STLHOURS,0)+NVL(STLHOURS_ENCASH,0))/8,2) STL_DAYS, '||CHR(10)
        ||'                 ROUND(SUM(NVL(HOLIDAYHOURS,0))/8,2) HOL_DAYS, '||CHR(10)
        ||'                 round((SUM(NVL(ATTENDANCEHOURS,0) + NVL(STLHOURS,0)+NVL(STLHOURS_ENCASH,0)))/8,2) ELIGIBLE_DAYS '||CHR(10)
        ||'                 FROM WPSWAGESDETAILS_MV A, WPSWORKERCATEGORYMAST B '||CHR(10)  
        ||'                 WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||'                 AND A.FORTNIGHTSTARTDATE >= '''||lv_fn_stdt||''' '||CHR(10)
        ||'                 AND A.FORTNIGHTENDDATE <= '''||lv_Yr_endt||''' '||CHR(10)
        ||'                 AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE =  B.DIVISIONCODE '||CHR(10)
        ||'                 AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE '||CHR(10)
        ||'                 AND NVL(B.STLAPPLICABLE,''N'')=''Y'' '||CHR(10)
        ||'                 GROUP BY A.WORKERSERIAL/*, A.FORTNIGHTSTARTDATE */'||CHR(10)
        ||'                 UNION ALL '||CHR(10)
        ||'                 SELECT WORKERSERIAL, /*FORTNIGHTSTARTDATE,*/ SUM(NVL(STLDAYS,0)+NVL(PREV_STLDAYS,0)) PREV_STLDAYS, SUM(NVL(STLHOURS,0)+NVL(PREV_STLHRS,0)) PRV_STLHRS, '||CHR(10)
        ||'                 SUM(NVL(PREV_STLHRS,0)) PRV_STLHRS_CALC  ,0 ATTN_HRS, 0 HOL_HRS, 0 STL_HRS, 0 STLENCASH_HRS, '||CHR(10) 
        ||'                 0 ELIGIBLE_HRS, 0 ATTN_DAYS, 0 STL_DAYS, 0 HOL_DAYS, 0 ELIGIBLE_DAYS '||CHR(10)
        ||'                 FROM WPSSTLTRANSACTION '||CHR(10)
        ||'                 WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||'                 AND FORTNIGHTSTARTDATE >= '''||lv_fn_stdt||''' '||CHR(10)
        ||'                 AND FORTNIGHTENDDATE <= '''||lv_fn_endt||''' '||CHR(10)
        ||'                 GROUP BY WORKERSERIAL/*, FORTNIGHTSTARTDATE */'||CHR(10)
        ||'             ) GROUP BY WORKERSERIAL '||CHR(10)
        ||' ) A, WPSWORKERMAST B '||CHR(10)
        ||' WHERE B.COMPANYCODE = '''||P_COMPCODE||''' AND B.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||' /*AND B.ACTIVE=''Y'' */'||CHR(10)
        ||' AND B.WORKERSERIAL = A.WORKERSERIAL '||CHR(10)    
        ||' GROUP BY B.COMPANYCODE, B.DIVISIONCODE,A.WORKERSERIAL, B.TOKENNO, B.WORKERCATEGORYCODE, B.DEPARTMENTCODE,B.DATEOFJOINING '||CHR(10)        
        ||' ) '||CHR(10);

 DBMS_OUTPUT.PUT_LINE (lv_Sql);
        
         lv_Sql := '          INSERT INTO WPSSTLENTITLEMENTCALCDETAILS '||CHR(10)
                 ||'          ('||CHR(10)
                 ||'            COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, CATEGORYCODE, FROMYEAR, YEARCODE,'||CHR(10)
                 ||'            FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, DEPARTMENTCODE, SHIFTCODE,'||CHR(10)
                 ||'            ATTNHOURS, FESTHOURS, HOLIDAYHOURS, TOTALHOURS, STLHRSTAKEN, STLDAYSTAKEN,'||CHR(10)
                 ||'            STANDARDSTLHOURS, ADJUSTEDHOURS, APPLICABLESTANDHOURS, STLDAYS, STLHOURS, STLDAYS_BF,'||CHR(10)
                 ||'            TRANSACTIONTYPE, ADDLESS, USERNAME, LASTMODIFIED, SYSROWID'||CHR(10)
                 ||'          )'||CHR(10)
                 ||'         SELECT B.COMPANYCODE, B.DIVISIONCODE, B.WORKERSERIAL, B.TOKENNO, B.WORKERCATEGORYCODE, '''||TO_CHAR(P_YEAR)||''' FROMYEAR,'''||lv_YearCode||''' YEARCODE,'||CHR(10)
                 ||'                '''||lv_Cur_fn_stdt||''' FORTNIGHTSTARTDATE, '''||lv_Cur_fn_endt||''' FORTNIGHTENDDATE,B.DEPARTMENTCODE,''1'' SHIFTCODE,'||CHR(10)
                 ||'                SUM(ATTN_HRS)ATTN_HRS,0 FESTHOURS,SUM(HOL_HRS)HOL_HRS,SUM(ELIGIBLE_HRS)TOTALHOURS,SUM(STL_HRS)STL_HRS,SUM(STL_DAYS)STL_DAYS,'||CHR(10)
                 ||'                CASE WHEN B.DATEOFJOINING <= '''||lv_fn_stdt||''' THEN '||p_StandardSTLHours||''||CHR(10)
                 ||'                ELSE  ((12-TO_NUMBER(TO_CHAR( B.DATEOFJOINING,''MM'')))*'|| p_HoursforOnedaySTL || ') END STNDHRS ,0 ADJUSTEDHOURS,'||lv_ApplicableStndhrs||' APPLICABLESTANDHOURS,'||CHR(10)
                 ||'                SUM(STL_DAYS)STLDAYS,SUM(STL_HRS)STLHOURS,0 STLDAYS_BF,'||CHR(10)
                 ||'                ''ENTITLEMENT'' TRANSACTIONTYPE, ''ADD'' ADDLESS, '''||P_USER||''' USERNAME, SYSDATE LASTMODIFIED,'||CHR(10)
                 ||'                 B.WORKERSERIAL||''-''||TO_CHAR(SYSDATE,''YYYYMMDDHHMISS'') SYSROWID'||CHR(10)
                 ||'--                SUM(PREV_STLDAYS)PREV_STLDAYS,SUM(PRV_STLHRS)PRV_STLHRS,'||CHR(10)
                 ||'--                SUM(PRV_STLHRS_CALC)PRV_STLHRS_CALC'||CHR(10)
                 ||'--                ,SUM(STLENCASH_HRS)STLENCASH_HRS,'||CHR(10)
                 ||'--                SUM(ATTN_DAYS)ATTN_DAYS,SUM(HOL_DAYS)HOL_DAYS'||CHR(10)
                 ||'--               SUM(ELIGIBLE_HRS)ELIGIBLE_HRS,SUM(ELIGIBLE_DAYS)ELIGIBLE_DAYS'||CHR(10)
                 ||'                FROM('||CHR(10)
                 ||'                     SELECT WORKERSERIAL,  0 PREV_STLDAYS,  0 PRV_STLHRS,'||CHR(10)
                 ||'                     0 PRV_STLHRS_CALC,SUM(NVL(ATTENDANCEHOURS,0)) ATTN_HRS, SUM(NVL(HOLIDAYHOURS,0)) HOL_HRS,'||CHR(10)
                 ||'                     0 STL_HRS, 0 STLENCASH_HRS,'||CHR(10)
                 ||'                     ROUND(SUM(NVL(ATTENDANCEHOURS,0))/8,2) ATTN_DAYS,'||CHR(10)
                 ||'                     0 STL_DAYS,'||CHR(10)
                 ||'                     ROUND(SUM(NVL(HOLIDAYHOURS,0))/8,2) HOL_DAYS,'||CHR(10)
                 ||'                     SUM(NVL(FEWORKINGDAYS,0)*8) ELIGIBLE_HRS,'||CHR(10)
                 ||'                     SUM(NVL(FEWORKINGDAYS,0)) ELIGIBLE_DAYS,'||CHR(10)
                 ||'                     SUM(NVL(FEWORKINGDAYS,0)) STLELIGIBLEDAYS'||CHR(10)
                 ||'                     FROM WPSWAGESDETAILS_MV A, WPSWORKERCATEGORYMAST B '||CHR(10)
                 ||'                     WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''''||CHR(10)
                 ||'                     AND A.FORTNIGHTSTARTDATE >= '''||lv_fn_stdt||''''||CHR(10)
                 ||'                     AND A.FORTNIGHTENDDATE <= '''||lv_Yr_endt||''''||CHR(10)
                 ||'                     AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE =  B.DIVISIONCODE '||CHR(10)
                 ||'                     AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE'||CHR(10)
                 ||'                     AND NVL(B.STLAPPLICABLE,''N'')=''Y'''||CHR(10)
                 ||'                     GROUP BY A.WORKERSERIAL'||CHR(10)
                 ||'                     UNION ALL'||CHR(10)
                 ||'                     SELECT WORKERSERIAL,  0 PREV_STLDAYS,  0 PRV_STLHRS,'||CHR(10)
                 ||'                     0 PRV_STLHRS_CALC,0 ATTN_HRS, 0 HOL_HRS,'||CHR(10)
                 ||'                     SUM(NVL(STLHOURS,0)) STL_HRS, 0 STLENCASH_HRS,'||CHR(10)
                 ||'                     0 ATTN_DAYS,'||CHR(10)
                 ||'                     SUM(NVL(STLDAYS,0)) STL_DAYS,'||CHR(10)
                 ||'                     0 HOL_DAYS,'||CHR(10)
                 ||'                     SUM(NVL(STLHOURS,0)) ELIGIBLE_HRS,'||CHR(10)
                 ||'                     SUM(NVL(STLDAYS,0)) ELIGIBLE_DAYS,'||CHR(10)
                 ||'                     0 STLELIGIBLEDAYS'||CHR(10)
                 ||'                     FROM WPSSTLWAGESDETAILS A, WPSWORKERCATEGORYMAST B'||CHR(10)
                 ||'                     WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''''||CHR(10)
                 ||'                     AND A.PAYMENTDATE >= '''||lv_fn_stdt||''''||CHR(10)
                 ||'                     AND A.PAYMENTDATE <= '''||lv_Yr_endt||''''||CHR(10)
                 ||'                     AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE =  B.DIVISIONCODE'||CHR(10)
                 ||'                     AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE'||CHR(10)
                 ||'                     AND NVL(B.STLAPPLICABLE,''N'')=''Y'''||CHR(10)
                 ||'                     GROUP BY A.WORKERSERIAL'||CHR(10)
                 ||'                )A, WPSWORKERMAST B'||CHR(10)
                 ||'                WHERE B.COMPANYCODE = '''||P_COMPCODE||''' AND B.DIVISIONCODE = '''||P_DIVCODE||''''||CHR(10)
                 ||'                AND B.WORKERSERIAL = A.WORKERSERIAL'||CHR(10)
                 ||'                GROUP BY B.COMPANYCODE, B.DIVISIONCODE, B.WORKERSERIAL, B.TOKENNO, B.WORKERCATEGORYCODE, B.DEPARTMENTCODE, B.DATEOFJOINING'||CHR(10)
                 ||'                HAVING (SUM(ELIGIBLE_DAYS)+'||p_AdjustmentSTLHours||')>('||lv_StndSTLDays||')'||CHR(10);
        
        
         
     DBMS_OUTPUT.PUT_LINE (lv_Sql);
       
     INSERT INTO WPS_ERROR_LOG(PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS)
        VALUES (lv_ProcName, null, sysdate, lv_Sql, lv_ParValues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
          
     execute immediate lv_Sql;
     
     lv_Sql := ' INSERT INTO WPSSTLTRANSACTION_0912  '||chr(10)
             ||'  (COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, FROMYEAR, YEARCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, '||chr(10) 
             ||'  STLDAYS, STLHOURS, TRANSACTIONTYPE, ADDLESS, USERNAME, PREV_STLHRS, PREV_STLDAYS) '||chr(10)
             ||'  SELECT '''||P_COMPCODE||''' COMPANYCODE,'''||P_DIVCODE||''' DIVISIONCODE,WORKERSERIAL,TOKENNO,'''||P_YEAR||''','''||lv_YearCode||''' YEARCODE, '||chr(10) 
             ||'         FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, '||chr(10) 
             ||'        /*  STLDAYS, STLDAYS * 8 STLHOURS,*/ '||chr(10)
             ||'         CASE WHEN STLDAYS > 0 AND STLDAYS_BF < 0 THEN STLDAYS+STLDAYS_BF ELSE STLDAYS END STLDAYS, '||chr(10)
             ||'         CASE WHEN STLDAYS > 0 AND STLDAYS_BF < 0 THEN STLDAYS+STLDAYS_BF ELSE STLDAYS END * 8 STLHOURS, '||chr(10) 
             ||'        ''ENTITLEMENT'' TRANSACTIONTYPE,''ADD'' ADDLESS, '''||P_USER||''', '||chr(10)
             ||'        CASE WHEN STLDAYS > 0 AND STLDAYS_BF < 0 THEN 0 ELSE STLDAYS_BF END *8 STLHRS_BF, '||chr(10)
             ||'        CASE WHEN STLDAYS > 0 AND STLDAYS_BF < 0 THEN 0 ELSE STLDAYS_BF END STLDAYS_BF '||chr(10)
             ||'        /*STLDAYS_BF * 8, STLDAYS_BF */ '||chr(10)
             ||'    FROM WPSSTLENTITLEMENTCALCDETAILS '||CHR(10)
             ||'    WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
             ||'      AND FORTNIGHTSTARTDATE = '''||lv_Cur_fn_stdt||''' AND FORTNIGHTENDDATE = '''||lv_Cur_fn_endt||''' '||chr(10)
             ||'      AND ( NVL(STLDAYS,0) > 0 OR NVL(STLDAYS_BF,0) <> 0) '||CHR(10); 
             --||'      AND (NVL(STLDAYS,0)+NVL(STLDAYS_BF,0)) > 0 '||chr(10);
     dbms_output.put_line(lv_Sql);
     lv_Remarks := 'WPSSTLTRANSACTION INSERT';
     INSERT INTO WPS_ERROR_LOG(PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS)
        VALUES (lv_ProcName, null, sysdate, lv_Sql, lv_ParValues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
     execute immediate lv_Sql;
    COMMIT;
    
    
    
EXCEPTION 
    WHEN OTHERS THEN
     lv_sqlerrm := sqlerrm ;
 --dbms_output.put_line(lv_sqlerrm);
    insert into WPS_ERROR_LOG(PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    values( lv_ProcName,lv_sqlerrm, sysdate, lv_Sql, lv_ParValues,lv_fn_stdt,lv_fn_endt, lv_Remarks);
 COMMIT;
        
end;
/


DROP PROCEDURE NJMCL_WEB.PRCWPS_STLENT_PROCESS_YRWISE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PRCWPS_STLENT_PROCESS_YRWISE( P_COMPCODE varchar2, 
                                                       P_DIVCODE varchar2, 
                                                       P_YEAR varchar2, 
                                                       P_USER varchar2,
                                                       p_StandardSTLHours number,
                                                       p_AdjustmentSTLHours number default 0,
                                                       p_Workerserial varchar2 default null,
                                                       p_StandardSTLHours1 number default 1920,
                                                       p_HoursforOnedaySTL number default 160
                                                   )
as
lv_ProcName             varchar2(30):= 'prcWPS_STLENT_PROCESS_YRWISE';
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '';
lv_Remarks              varchar2(1000) := '';
lv_ParValues            varchar2(500) := '';
lv_SqlErrm              varchar2(500) := '';
lv_FNStartDate          date;
lv_FNEndDate            date;
lv_Cnt                  number:=0;
lv_PrevYear             varchar2(4); --2016
lv_B4PrevYear           varchar2(4); --2015
lv_PrevB4PrevYear       varchar2(4); --2014
lv_fn_stdt              date;
lv_fn_endt              date;
lv_Cur_fn_stdt              date;
lv_Cur_fn_endt              date;

lv_Yr_endt              date;
lv_YearCode             varchar2(10);
lv_Sql                  varchar2(10000);
lv_ApplicableStndhrs    number :=1920;
lv_ApplicableStndDays    number :=240;
lv_StndSTLDays          number :=Round(p_StandardSTLHours/8,0);
lv_AdjSTLDays           number :=0;
lv_MaxSTLDays           number :=15; -- added on 28/01/2021
lv_STLTakenConsiderYear varchar2(4) := '0';      


--EXEC  prcWPS_STLENT_PROCESS_YRWISE('NJ0001','0002','2020','SWT',1920, 0,'', 160 )
begin
    ---- FOLLOWING POINTS CONSIDER IN THIS PROCEDURE FOR STL ENTILEMENT CALCULATION --------
    ---- 1. Previous year STL consider in the same year in column prev. year STL 
    ---- 2. When wokrer join in the current calendar year then STL consider working days 20 in enverymonth.
    
     dbms_output.put_line(P_YEAR);
    
    if to_number(P_YEAR) < 2021 then
    
        dbms_output.put_line(P_YEAR);
    
        lv_error_remark := 'Validation Failure : [STL Entitlement not applicable for the year '||P_YEAR||']';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
--    return;
    
begin
    lv_result:='#SUCCESS#';
    lv_Remarks := 'STLENTITLE PROCESS';
    lv_PrevYear := substr(P_YEAR,1,2)|| to_number(substr(P_YEAR,3))-1;
    lv_B4PrevYear := substr(P_YEAR,1,2)|| to_number(substr(P_YEAR,3))-2;
    lv_PrevB4PrevYear := substr(P_YEAR,1,2)|| to_number(substr(P_YEAR,3))-3;
    
    lv_STLTakenConsiderYear := lv_B4PrevYear;
    
    lv_fn_stdt := to_date('01/01/'||lv_PrevYear,'DD/MM/YYYY');
    lv_fn_endt := to_date('15/01/'||lv_PrevYear,'DD/MM/YYYY');
    lv_Yr_endt := to_date('31/12/'||lv_PrevYear,'DD/MM/YYYY');
    
--    lv_fn_stdt := to_date('01/01/'||P_YEAR,'DD/MM/YYYY');
--    lv_fn_endt := to_date('15/01/'||P_YEAR,'DD/MM/YYYY');
--    lv_Yr_endt := to_date('31/12/'||P_YEAR,'DD/MM/YYYY');
    
    lv_Cur_fn_stdt := to_date('01/01/'||TO_CHAR(P_YEAR),'DD/MM/YYYY');
    lv_Cur_fn_endt := to_date('15/01/'||TO_CHAR(P_YEAR),'DD/MM/YYYY');
       
    lv_ApplicableStndhrs := p_StandardSTLHours - p_AdjustmentSTLHours;
    lv_ApplicableStndDays := (p_StandardSTLHours/8) - p_AdjustmentSTLHours;
    
    lv_ParValues := 'YEAR - '||P_YEAR||',STANDARD HRS - '||p_StandardSTLHours||', Adj Hrs - '||p_AdjustmentSTLHours;
        
    SELECT YEARCODE INTO lv_YearCode 
    FROM FINANCIALYEAR 
    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
    AND STARTDATE <= lv_fn_stdt AND ENDDATE >= lv_fn_stdt;

    lv_YearCode := P_YEAR;
    
    lv_sql := 'DELETE FROM WPSSTLTRANSACTION WHERE TRANSACTIONTYPE <>''OPENING'' AND FROMYEAR='||lv_PrevYear||' '||chr(10);
--    DBMS_OUTPUT.PUT_LINE (lv_Sql);
    
    execute immediate lv_Sql;
        

    lv_Sql := 'DELETE FROM WPSSTLENTITLEMENTCALCDETAILS '||chr(10) 
        ||' WHERE FORTNIGHTSTARTDATE='''||lv_Cur_fn_stdt||''' AND FORTNIGHTENDDATE='''||lv_Cur_fn_endt||''' '||chr(10);
    
--    DBMS_OUTPUT.PUT_LINE (lv_Sql);
    
    execute immediate lv_Sql;


    lv_Remarks := 'STL ENTITLEMENT CALCULATION PROCESS'; 
--    DBMS_OUTPUT.PUT_LINE ('1_1');


    lv_Sql := 'INSERT INTO WPSSTLENTITLEMENTCALCDETAILS'||CHR(10)
            ||' ( '||CHR(10)
            ||' COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, CATEGORYCODE, FROMYEAR, YEARCODE,'||CHR(10)
            ||' FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, DEPARTMENTCODE, SHIFTCODE,'||CHR(10)
            ||' ATTNHOURS, FESTHOURS, HOLIDAYHOURS, TOTALHOURS, STLHRSTAKEN, STLDAYSTAKEN,'||CHR(10)
            ||' STANDARDSTLHOURS, ADJUSTEDHOURS, APPLICABLESTANDHOURS, STLDAYS, STLHOURS, STLDAYS_BF,'||CHR(10)
            ||' TRANSACTIONTYPE, ADDLESS, USERNAME, LASTMODIFIED, SYSROWID,GRACEDAYS, ATTNDAYS '||CHR(10)
            ||' )'||CHR(10)
            ||' SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, '''||lv_PrevYear||'''  FROMYEAR, '''||lv_YearCode||''' YEARCODE,'||CHR(10)
            ||' '''||lv_Cur_fn_stdt||''' FORTNIGHTSTARTDATE, '''||lv_Cur_fn_endt||''' FORTNIGHTENDDATE, DEPARTMENTCODE, ''1'' SHIFTCODE,'||CHR(10)
            ||' ATTN_HRS ATTNHOURS, 0 FESTHOURS, HOL_HRS HOLIDAYHOURS, (ELIGIBLE_HRS) TOTALHOURS, STL_HRS, STL_DAYS STLDAYSTAKEN,'||CHR(10)
            ||' STNDDAYS*8 STANDARDSTLHOURS, 0 ADJUSTEDHOURS, '||lv_ApplicableStndhrs||' APPLICABLESTANDHOURS, CASE WHEN ENT_DAYS > '||lv_MaxSTLDays||' THEN '||lv_MaxSTLDays||' ELSE ENT_DAYS END STLDAYS, CASE WHEN ENT_DAYS > '||lv_MaxSTLDays||' THEN '||lv_MaxSTLDays||'*8 ELSE ENT_DAYS*8 END STLHOURS, PREV_ENT_STLDAYS STLDAYS_BF,'||CHR(10)
            ||' ''ENTITLEMENT'' TRANSACTIONTYPE, ''ADD'' ADDLESS, '''||P_USER||''' USERNAME, SYSDATE LASTMODIFIED, WORKERSERIAL||''-''||TO_CHAR(SYSDATE,''YYYYMMDDHHMISS'') SYSROWID,GRACEDAYS , ATTN_DAYS'||CHR(10)
            ||' FROM ('||CHR(10)
            ||'SELECT'||CHR(10)
            ||' B.COMPANYCODE, B.DIVISIONCODE, A.WORKERSERIAL, B.TOKENNO, B.WORKERCATEGORYCODE, B.DEPARTMENTCODE, B.TERMINATIONDATE,'||CHR(10)
            ||' SUM(PREV_STLDAYS) PREV_STLDAYS, SUM(PRV_STLHRS) PRV_STLHRS,'||CHR(10)
            ||' SUM(ATTN_HRS) ATTN_HRS, SUM(HOL_HRS) HOL_HRS, CASE WHEN SUM(STL_HRS) > 0 THEN case when (SUM(STL_HRS) - SUM(PRV_STLHRS_CALC)) > 0 then SUM(STL_HRS) - SUM(PRV_STLHRS_CALC) else 0 end ELSE 0 END STL_HRS,'||CHR(10)
            ||' SUM(ELIGIBLE_HRS) ELIGIBLE_HRS, SUM(ATTN_DAYS) ATTN_DAYS, SUM(STL_DAYS) STL_DAYS, SUM(HOL_DAYS) HOL_DAYS,'||CHR(10)
            ||' SUM(ELIGIBLE_DAYS) ELIGIBLE_DAYS, SUM(GRACEDAYS)  GRACEDAYS, '||CHR(10)
            ||' 0 PREV_ENT_STLDAYS,'||CHR(10)
            ||'     CASE WHEN B.TERMINATIONDATE IS  NULL THEN'||CHR(10)
            ||'         CASE WHEN ROUND(SUM(ELIGIBLE_DAYS+NVL(GRACEDAYS,0)),0) >= '||lv_ApplicableStndDays||' THEN ROUND(SUM(ATTN_DAYS)/20,0) ELSE 0 END'||CHR(10)
            ||'          WHEN B.TERMINATIONDATE BETWEEN '''||lv_fn_stdt||'''  AND '''||lv_Yr_endt||''' AND SUM(ELIGIBLE_DAYS+NVL(GRACEDAYS,0)) >= '||lv_ApplicableStndDays||'-((TO_NUMBER(TO_CHAR(TERMINATIONDATE,''MM''))-TO_NUMBER(TO_CHAR(TO_DATE('''||lv_fn_stdt||''',''DD/MM/YYYY''),''MM'')-1))*'||  round(p_HoursforOnedaySTL/8) || ')  THEN'||CHR(10)
            ||'          ROUND(SUM(ATTN_DAYS)/20,0)'||CHR(10)
            ||'          ELSE 0'||CHR(10)
            ||'     END'||CHR(10)
            ||'     ENT_DAYS'||CHR(10)
            ||' , CASE WHEN B.TERMINATIONDATE IS  NULL  THEN '||lv_ApplicableStndDays||''||CHR(10)
            ||'        WHEN B.TERMINATIONDATE BETWEEN '''||lv_fn_stdt||'''  AND '''||lv_Yr_endt||''' THEN'||CHR(10)
            ||'        ((TO_NUMBER(TO_CHAR(TERMINATIONDATE,''MM''))-TO_NUMBER(TO_CHAR(TO_DATE('''||lv_fn_stdt||''',''DD/MM/YYYY''),''MM'')-1))*'||  round(p_HoursforOnedaySTL/8,2) || ')'||CHR(10)
            ||'        ELSE 0 END'||CHR(10)
            ||'        STNDDAYS'||CHR(10)
            ||' FROM ('||CHR(10)
            ||'         select WORKERSERIAL, SUM(PREV_STLDAYS) PREV_STLDAYS, SUM(PRV_STLHRS) PRV_STLHRS,'||CHR(10)
            ||'         SUM(PRV_STLHRS_CALC) PRV_STLHRS_CALC,SUM(ATTN_HRS) ATTN_HRS, SUM(HOL_HRS) HOL_HRS,'||CHR(10)
            ||'         SUM(STL_HRS) STL_HRS, SUM(STLENCASH_HRS) STLENCASH_HRS,'||CHR(10)
            ||'         SUM(ELIGIBLE_HRS) ELIGIBLE_HRS,'||CHR(10)
            ||'         SUM(FEWORKINGDAYS) ATTN_DAYS,'||CHR(10)
            ||'         ROUND(SUM(NVL(STL_HRS,0))/8,2) STL_DAYS,'||CHR(10)
            ||'         ROUND(SUM(NVL(HOL_HRS,0))/8,2) HOL_DAYS,'||CHR(10)
            ||'         SUM(ELIGIBLE_DAYS) ELIGIBLE_DAYS ,'||CHR(10)
            ||'         SUM(FEWORKINGDAYS) FEWORKINGDAYS'||CHR(10)
            ||'         FROM ('||CHR(10)
            ||'                 SELECT WORKERSERIAL,  0 PREV_STLDAYS,  0 PRV_STLHRS,'||CHR(10)
            ||'                 0 PRV_STLHRS_CALC,SUM(NVL(ATTENDANCEHOURS,0)) ATTN_HRS, SUM(NVL(HOLIDAYHOURS,0)) HOL_HRS,'||CHR(10)
            ||'                 0 STL_HRS, 0 STLENCASH_HRS,'||CHR(10)
            ||'                 SUM(NVL(FEWORKINGDAYS*8,0))  ELIGIBLE_HRS,'||CHR(10)
            ||'                 ROUND(SUM(NVL(ATTENDANCEHOURS,0))/8,2) ATTN_DAYS,'||CHR(10)
            ||'                 0 STL_DAYS,'||CHR(10)
            ||'                 ROUND(SUM(NVL(HOLIDAYHOURS,0))/8,2) HOL_DAYS,'||CHR(10)
            ||'                 SUM(NVL(ATN_DAYS,0)) ELIGIBLE_DAYS,'||CHR(10)
            ||'                 SUM(NVL(ATN_DAYS,0)) FEWORKINGDAYS'||CHR(10)
            ||'                 FROM WPSWAGESDETAILS_MV A, WPSWORKERCATEGORYMAST B'||CHR(10)
            ||'                 WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''''||CHR(10)
            ||'                 AND A.FORTNIGHTSTARTDATE >= '''||lv_fn_stdt||''''||CHR(10)
            ||'                 AND A.FORTNIGHTENDDATE <= '''||lv_Yr_endt||''''||CHR(10)
            ||'                 AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE =  B.DIVISIONCODE'||CHR(10)
            ||'                 AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE'||CHR(10)
            ||'                 AND NVL(B.STLAPPLICABLE,''N'')=''Y'''||CHR(10)
            ||'                 GROUP BY A.WORKERSERIAL'||CHR(10)
            ||'                 UNION ALL'||CHR(10)
            ||'                 SELECT WORKERSERIAL, /*FORTNIGHTSTARTDATE, */ 0 PREV_STLDAYS,  0 PRV_STLHRS,'||CHR(10)
            ||'                 0 PRV_STLHRS_CALC,0 ATTN_HRS, 0 HOL_HRS,'||CHR(10)
            ||'                 SUM(NVL(LEAVEHOURS,0)) STL_HRS, 0 STLENCASH_HRS,'||CHR(10)
            ||'                 SUM(NVL(LEAVEHOURS,0)) ELIGIBLE_HRS,'||CHR(10)
            ||'                 0 ATTN_DAYS,'||CHR(10)
            ||'                  SUM(NVL(LEAVEDAYS,0)) STL_DAYS,'||CHR(10)
            ||'                 0 HOL_DAYS,'||CHR(10)
            ||'                 SUM(NVL(LEAVEDAYS,0)) ELIGIBLE_DAYS ,'||CHR(10)
            ||'                 0 FEWORKINGDAYS'||CHR(10)
            ||'                 FROM WPSSTLENTRYDETAILS A '||chr(10) 
            ||'                 WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''''||CHR(10)
            ||'                   AND A.PAYMENTDATE >= '''||lv_fn_stdt||''''||CHR(10)
            ||'                   AND A.PAYMENTDATE <= '''||lv_Yr_endt||''''||CHR(10)
            ||'                   AND A.YEAR='''||lv_STLTakenConsiderYear||''' AND NVL(ISSANCTIONED,''N'')=''Y'' '||chr(10)
            ||'                 GROUP BY A.WORKERSERIAL'||CHR(10)
            ||'             )'||CHR(10)
            ||'              GROUP BY WORKERSERIAL'||CHR(10)
            ||' ) A, WPSWORKERMAST B, WPSWORKERSTLGRACEPERIODDAYS C'||CHR(10)
            ||' WHERE B.COMPANYCODE = '''||P_COMPCODE||''' AND B.DIVISIONCODE = '''||P_DIVCODE||''''||CHR(10)
            ||' AND B.WORKERSERIAL = A.WORKERSERIAL AND B.WORKERSERIAL = C.WORKERSERIAL(+)'||CHR(10)
            ||' GROUP BY B.COMPANYCODE, B.DIVISIONCODE,A.WORKERSERIAL, B.TOKENNO, B.WORKERCATEGORYCODE, B.DEPARTMENTCODE,B.TERMINATIONDATE'||CHR(10)
            ||' ) WHERE NVL(ATTN_DAYS,0) > 0'||CHR(10);
 DBMS_OUTPUT.PUT_LINE (lv_Sql);
        
        
       
     INSERT INTO WPS_ERROR_LOG(PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS)
        VALUES (lv_ProcName, null, sysdate, lv_Sql, lv_ParValues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
          
     execute immediate lv_Sql;
     
     lv_Sql := ' INSERT INTO WPSSTLTRANSACTION'||chr(10)
             ||'  (COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, FROMYEAR, YEARCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, '||chr(10) 
             ||'  STLDAYS, STLHOURS, TRANSACTIONTYPE, ADDLESS, USERNAME, PREV_STLHRS, PREV_STLDAYS,SYSROWID) '||chr(10)
             ||'  SELECT '''||P_COMPCODE||''' COMPANYCODE,'''||P_DIVCODE||''' DIVISIONCODE,WORKERSERIAL,TOKENNO,'''||lv_PrevYear||''','''||lv_YearCode||''' YEARCODE, '||chr(10) 
             ||'         FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, '||chr(10) 
             ||'        /*  STLDAYS, STLDAYS * 8 STLHOURS,*/ '||chr(10)
             ||'         CASE WHEN STLDAYS > 0 AND STLDAYS_BF < 0 THEN STLDAYS+STLDAYS_BF ELSE STLDAYS END STLDAYS, '||chr(10)
             ||'         CASE WHEN STLDAYS > 0 AND STLDAYS_BF < 0 THEN STLDAYS+STLDAYS_BF ELSE STLDAYS END * 8 STLHOURS, '||chr(10) 
             ||'        ''ENT'' TRANSACTIONTYPE,''ADD'' ADDLESS, '''||P_USER||''', '||chr(10)
             ||'        0 STLHRS_BF, '||chr(10)
             ||'        0 STLDAYS_BF '||chr(10)
             ||'        /*STLDAYS_BF * 8, STLDAYS_BF */ '||chr(10)
             ||'        , FN_GENERATE_SYSROWID  SYSROWID'||chr(10)
             ||'    FROM WPSSTLENTITLEMENTCALCDETAILS '||CHR(10)
             ||'    WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
             ||'      AND FORTNIGHTSTARTDATE = '''||lv_Cur_fn_stdt||''' AND FORTNIGHTENDDATE = '''||lv_Cur_fn_endt||''' '||chr(10)
             ||'      AND NVL(STLDAYS,0) > 0 '||CHR(10); 
             --||'      AND (NVL(STLDAYS,0)+NVL(STLDAYS_BF,0)) > 0 '||chr(10);
     dbms_output.put_line(lv_Sql);
     lv_Remarks := 'WPSSTLTRANSACTION INSERT';
     INSERT INTO WPS_ERROR_LOG(PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS)
        VALUES (lv_ProcName, null, sysdate, lv_Sql, lv_ParValues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
     execute immediate lv_Sql;
    COMMIT;
    
    
    
EXCEPTION 
    WHEN OTHERS THEN
     lv_sqlerrm := sqlerrm ;
 --dbms_output.put_line(lv_sqlerrm);
    insert into WPS_ERROR_LOG(PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    values( lv_ProcName,lv_sqlerrm, sysdate, lv_Sql, lv_ParValues,lv_fn_stdt,lv_fn_endt, lv_Remarks);
 COMMIT;
 end;
        
end;
/


DROP PROCEDURE NJMCL_WEB.PRCWPS_STLENT_PROCESS_YRWISE1;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PRCWPS_STLENT_PROCESS_YRWISE1( P_COMPCODE varchar2, 
                                                       P_DIVCODE varchar2, 
                                                       P_YEAR varchar2, 
                                                       P_USER varchar2,
                                                       p_StandardSTLHours number,
                                                       p_AdjustmentSTLHours number default 0,
                                                       p_Workerserial varchar2 default null,
                                                       p_HoursforOnedaySTL number default 160
                                                   )
as
lv_ProcName             varchar2(30):= 'prcWPS_STLENT_PROCESS_YRWISE';
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '';
lv_Remarks              varchar2(1000) := '';
lv_ParValues            varchar2(500) := '';
lv_SqlErrm              varchar2(500) := '';
lv_FNStartDate          date;
lv_FNEndDate            date;
lv_Cnt                  number:=0;
lv_PrevYear             varchar2(4); --2016
lv_B4PrevYear           varchar2(4); --2015
lv_PrevB4PrevYear       varchar2(4); --2014
lv_fn_stdt              date;
lv_fn_endt              date;
lv_Cur_fn_stdt              date;
lv_Cur_fn_endt              date;

lv_Yr_endt              date;
lv_YearCode             varchar2(10);
lv_Sql                  varchar2(10000);
lv_ApplicableStndhrs    number :=1920;
lv_StndSTLDays          number :=Round(p_StandardSTLHours/8,0);
lv_AdjSTLDays           number :=0;

--EXEC  prcWPS_STLENT_PROCESS_YRWISE('NJ0001','0002','2020','SWT',1920, 0,'', 160 )
begin
    ---- FOLLOWING POINTS CONSIDER IN THIS PROCEDURE FOR STL ENTILEMENT CALCULATION --------
    ---- 1. Previous year STL consider in the same year in column prev. year STL 
    ---- 2. When wokrer join in the current calendar year then STL consider working days 20 in enverymonth.
    
    lv_result:='#SUCCESS#';
    lv_Remarks := 'STLENTITLE PROCESS';
    lv_PrevYear := substr(P_YEAR,1,2)|| to_number(substr(P_YEAR,3))-1;
    lv_B4PrevYear := substr(P_YEAR,1,2)|| to_number(substr(P_YEAR,3))-2;
    lv_PrevB4PrevYear := substr(P_YEAR,1,2)|| to_number(substr(P_YEAR,3))-3;
    
    lv_fn_stdt := to_date('01/01/'||P_YEAR,'DD/MM/YYYY');
    lv_fn_endt := to_date('15/01/'||P_YEAR,'DD/MM/YYYY');
    lv_Yr_endt := to_date('31/12/'||P_YEAR,'DD/MM/YYYY');
    
    lv_Cur_fn_stdt := to_date('01/01/'||TO_CHAR(P_YEAR+1),'DD/MM/YYYY');
    lv_Cur_fn_endt := to_date('15/01/'||TO_CHAR(P_YEAR+1),'DD/MM/YYYY');
       
    lv_ApplicableStndhrs := p_StandardSTLHours - p_AdjustmentSTLHours;
    
    lv_ParValues := 'YEAR - '||P_YEAR||',STANDARD HRS - '||p_StandardSTLHours||', Adj Hrs - '||p_AdjustmentSTLHours;
        
    SELECT YEARCODE INTO lv_YearCode 
    FROM FINANCIALYEAR 
    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
    AND STARTDATE <= lv_fn_stdt AND ENDDATE >= lv_fn_stdt;

    lv_sql := 'DELETE FROM WPSSTLTRANSACTION WHERE TRANSACTIONTYPE <>''OPENING'' AND FROMYEAR='||P_YEAR||' '||chr(10);
--    DBMS_OUTPUT.PUT_LINE (lv_Sql);
    
    execute immediate lv_Sql;
        

    lv_Sql := 'DELETE FROM WPSSTLENTITLEMENTCALCDETAILS '||chr(10) 
        ||' WHERE FORTNIGHTSTARTDATE='''||lv_Cur_fn_stdt||''' AND FORTNIGHTENDDATE='''||lv_Cur_fn_endt||''' '||chr(10);
    
--    DBMS_OUTPUT.PUT_LINE (lv_Sql);
    
    execute immediate lv_Sql;


    lv_Remarks := 'STL ENTITLEMENT CALCULATION PROCESS'; 
--    DBMS_OUTPUT.PUT_LINE ('1_1');


    lv_Sql := 'INSERT INTO WPSSTLENTITLEMENTCALCDETAILS'||CHR(10)
            ||' ( '||CHR(10)
            ||' COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, CATEGORYCODE, FROMYEAR, YEARCODE,'||CHR(10)
            ||' FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, DEPARTMENTCODE, SHIFTCODE,'||CHR(10)
            ||' ATTNHOURS, FESTHOURS, HOLIDAYHOURS, TOTALHOURS, STLHRSTAKEN, STLDAYSTAKEN,'||CHR(10)
            ||' STANDARDSTLHOURS, ADJUSTEDHOURS, APPLICABLESTANDHOURS, STLDAYS, STLHOURS, STLDAYS_BF,'||CHR(10)
            ||' TRANSACTIONTYPE, ADDLESS, USERNAME, LASTMODIFIED, SYSROWID'||CHR(10)
            ||' )'||CHR(10)
            ||' SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, '''||TO_CHAR(P_YEAR)||'''  FROMYEAR, '''||lv_YearCode||''' YEARCODE,'||CHR(10)
            ||' '''||lv_Cur_fn_stdt||''' FORTNIGHTSTARTDATE, '''||lv_Cur_fn_endt||''' FORTNIGHTENDDATE, DEPARTMENTCODE, ''1'' SHIFTCODE,'||CHR(10)
            ||' ATTN_HRS ATTNHOURS, 0 FESTHOURS, HOL_HRS HOLIDAYHOURS, (ELIGIBLE_HRS) TOTALHOURS, STL_HRS, STL_DAYS STLDAYSTAKEN,'||CHR(10)
            ||' STNDHRS STANDARDSTLHOURS, 0 ADJUSTEDHOURS, '||lv_ApplicableStndhrs||' APPLICABLESTANDHOURS, ENT_DAYS STLDAYS, ENT_DAYS*8 STLHOURS, PREV_ENT_STLDAYS STLDAYS_BF,'||CHR(10)
            ||' ''ENTITLEMENT'' TRANSACTIONTYPE, ''ADD'' ADDLESS, '''||P_USER||''' USERNAME, SYSDATE LASTMODIFIED, WORKERSERIAL||''-''||TO_CHAR(SYSDATE,''YYYYMMDDHHMISS'') SYSROWID'||CHR(10)
            ||' FROM ('||CHR(10)
            ||'SELECT'||CHR(10)
            ||' B.COMPANYCODE, B.DIVISIONCODE, A.WORKERSERIAL, B.TOKENNO, B.WORKERCATEGORYCODE, B.DEPARTMENTCODE, B.TERMINATIONDATE,'||CHR(10)
            ||' SUM(PREV_STLDAYS) PREV_STLDAYS, SUM(PRV_STLHRS) PRV_STLHRS,'||CHR(10)
            ||' SUM(ATTN_HRS) ATTN_HRS, SUM(HOL_HRS) HOL_HRS, CASE WHEN SUM(STL_HRS) > 0 THEN case when (SUM(STL_HRS) - SUM(PRV_STLHRS_CALC)) > 0 then SUM(STL_HRS) - SUM(PRV_STLHRS_CALC) else 0 end ELSE 0 END STL_HRS,'||CHR(10)
            ||' SUM(ELIGIBLE_HRS) ELIGIBLE_HRS, SUM(ATTN_DAYS) ATTN_DAYS, SUM(STL_DAYS) STL_DAYS, SUM(HOL_DAYS) HOL_DAYS,'||CHR(10)
            ||' SUM(ELIGIBLE_DAYS) ELIGIBLE_DAYS,'||CHR(10)
            ||' 0 PREV_ENT_STLDAYS,'||CHR(10)
            ||'     CASE WHEN B.TERMINATIONDATE IS  NULL THEN'||CHR(10)
            ||'         CASE WHEN SUM(ELIGIBLE_HRS) >='||lv_ApplicableStndhrs||' THEN ROUND(SUM(FEWORKINGDAYS)/20,0) ELSE 0 END'||CHR(10)
            ||'          WHEN B.TERMINATIONDATE BETWEEN '''||lv_fn_stdt||'''  AND '''||lv_Yr_endt||''' AND SUM(ELIGIBLE_HRS) >= '||lv_ApplicableStndhrs||'-((TO_NUMBER(TO_CHAR(TERMINATIONDATE,''MM''))-TO_NUMBER(TO_CHAR(TO_DATE('''||lv_fn_stdt||''',''DD/MM/YYYY''),''MM'')-1))*'||  p_HoursforOnedaySTL || ')  THEN'||CHR(10)
            ||'          ROUND(SUM(FEWORKINGDAYS)/20,0)'||CHR(10)
            ||'          ELSE 0'||CHR(10)
            ||'     END'||CHR(10)
            ||'     ENT_DAYS'||CHR(10)
            ||' , CASE WHEN B.TERMINATIONDATE IS  NULL  THEN '||lv_ApplicableStndhrs||''||CHR(10)
            ||'        WHEN B.TERMINATIONDATE BETWEEN '''||lv_fn_stdt||'''  AND '''||lv_Yr_endt||''' THEN'||CHR(10)
            ||'        ((TO_NUMBER(TO_CHAR(TERMINATIONDATE,''MM''))-TO_NUMBER(TO_CHAR(TO_DATE('''||lv_fn_stdt||''',''DD/MM/YYYY''),''MM'')-1))*'||  p_HoursforOnedaySTL || ')'||CHR(10)
            ||'        ELSE 0 END'||CHR(10)
            ||'        STNDHRS'||CHR(10)
            ||' FROM ('||CHR(10)
            ||'         select WORKERSERIAL, SUM(PREV_STLDAYS) PREV_STLDAYS, SUM(PRV_STLHRS) PRV_STLHRS,'||CHR(10)
            ||'         SUM(PRV_STLHRS_CALC) PRV_STLHRS_CALC,SUM(ATTN_HRS) ATTN_HRS, SUM(HOL_HRS) HOL_HRS,'||CHR(10)
            ||'         SUM(STL_HRS) STL_HRS, SUM(STLENCASH_HRS) STLENCASH_HRS,'||CHR(10)
            ||'         SUM(ELIGIBLE_HRS) ELIGIBLE_HRS,'||CHR(10)
            ||'         ROUND(SUM(NVL(ATTN_HRS,0))/8,2) ATTN_DAYS,'||CHR(10)
            ||'         ROUND(SUM(NVL(STL_HRS,0))/8,2) STL_DAYS,'||CHR(10)
            ||'         ROUND(SUM(NVL(HOL_HRS,0))/8,2) HOL_DAYS,'||CHR(10)
            ||'         SUM(ELIGIBLE_DAYS) ELIGIBLE_DAYS ,'||CHR(10)
            ||'         SUM(FEWORKINGDAYS)FEWORKINGDAYS'||CHR(10)
            ||'         FROM ('||CHR(10)
            ||'                 SELECT WORKERSERIAL,  0 PREV_STLDAYS,  0 PRV_STLHRS,'||CHR(10)
            ||'                 0 PRV_STLHRS_CALC,SUM(NVL(ATTENDANCEHOURS,0)) ATTN_HRS, SUM(NVL(HOLIDAYHOURS,0)) HOL_HRS,'||CHR(10)
            ||'                 0 STL_HRS, 0 STLENCASH_HRS,'||CHR(10)
            ||'                 SUM(NVL(FEWORKINGDAYS*8,0))  ELIGIBLE_HRS,'||CHR(10)
            ||'                 ROUND(SUM(NVL(ATTENDANCEHOURS,0))/8,2) ATTN_DAYS,'||CHR(10)
            ||'                 0 STL_DAYS,'||CHR(10)
            ||'                 ROUND(SUM(NVL(HOLIDAYHOURS,0))/8,2) HOL_DAYS,'||CHR(10)
            ||'                 SUM(NVL(FEWORKINGDAYS,0)) ELIGIBLE_DAYS,'||CHR(10)
            ||'                 SUM(NVL(FEWORKINGDAYS,0)) FEWORKINGDAYS'||CHR(10)
            ||'                 FROM WPSWAGESDETAILS_MV A, WPSWORKERCATEGORYMAST B'||CHR(10)
            ||'                 WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''''||CHR(10)
            ||'                 AND A.FORTNIGHTSTARTDATE >= '''||lv_fn_stdt||''''||CHR(10)
            ||'                 AND A.FORTNIGHTENDDATE <= '''||lv_Yr_endt||''''||CHR(10)
            ||'                 AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE =  B.DIVISIONCODE'||CHR(10)
            ||'                 AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE'||CHR(10)
            ||'                 AND NVL(B.STLAPPLICABLE,''N'')=''Y'''||CHR(10)
            ||'                 GROUP BY A.WORKERSERIAL'||CHR(10)
            ||'                 UNION ALL'||CHR(10)
            ||'                 SELECT WORKERSERIAL, /*FORTNIGHTSTARTDATE, */ 0 PREV_STLDAYS,  0 PRV_STLHRS,'||CHR(10)
            ||'                 0 PRV_STLHRS_CALC,0 ATTN_HRS, 0 HOL_HRS,'||CHR(10)
            ||'                 SUM(NVL(STLHOURS,0)) STL_HRS, 0 STLENCASH_HRS,'||CHR(10)
            ||'                 SUM(NVL(STLHOURS,0)) ELIGIBLE_HRS,'||CHR(10)
            ||'                 0 ATTN_DAYS,'||CHR(10)
            ||'                  SUM(NVL(STLDAYS,0)) STL_DAYS,'||CHR(10)
            ||'                 0 HOL_DAYS,'||CHR(10)
            ||'                 SUM(NVL(STLDAYS,0)) ELIGIBLE_DAYS ,'||CHR(10)
            ||'                 0 FEWORKINGDAYS'||CHR(10)
            ||'                 FROM WPSSTLWAGESDETAILS A, WPSWORKERCATEGORYMAST B'||CHR(10)
            ||'                 WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''''||CHR(10)
            ||'                 AND A.PAYMENTDATE >= '''||lv_fn_stdt||''''||CHR(10)
            ||'                 AND A.PAYMENTDATE <= '''||lv_Yr_endt||''''||CHR(10)
            ||'                 AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE =  B.DIVISIONCODE'||CHR(10)
            ||'                 AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE'||CHR(10)
            ||'                 AND NVL(B.STLAPPLICABLE,''N'')=''Y'''||CHR(10)
            ||'                 GROUP BY A.WORKERSERIAL'||CHR(10)
            ||'             )'||CHR(10)
            ||'              GROUP BY WORKERSERIAL'||CHR(10)
            ||' ) A, WPSWORKERMAST B'||CHR(10)
            ||' WHERE B.COMPANYCODE = '''||P_COMPCODE||''' AND B.DIVISIONCODE = '''||P_DIVCODE||''''||CHR(10)
            ||' AND B.WORKERSERIAL = A.WORKERSERIAL'||CHR(10)
            ||' GROUP BY B.COMPANYCODE, B.DIVISIONCODE,A.WORKERSERIAL, B.TOKENNO, B.WORKERCATEGORYCODE, B.DEPARTMENTCODE,B.TERMINATIONDATE'||CHR(10)
            ||' )'||CHR(10);
 DBMS_OUTPUT.PUT_LINE (lv_Sql);
        
        
       
     INSERT INTO WPS_ERROR_LOG(PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS)
        VALUES (lv_ProcName, null, sysdate, lv_Sql, lv_ParValues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
          
--     execute immediate lv_Sql;
     
     lv_Sql := ' INSERT INTO WPSSTLTRANSACTION'||chr(10)
             ||'  (COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, FROMYEAR, YEARCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, '||chr(10) 
             ||'  STLDAYS, STLHOURS, TRANSACTIONTYPE, ADDLESS, USERNAME, PREV_STLHRS, PREV_STLDAYS) '||chr(10)
             ||'  SELECT '''||P_COMPCODE||''' COMPANYCODE,'''||P_DIVCODE||''' DIVISIONCODE,WORKERSERIAL,TOKENNO,'''||P_YEAR||''','''||lv_YearCode||''' YEARCODE, '||chr(10) 
             ||'         FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, '||chr(10) 
             ||'        /*  STLDAYS, STLDAYS * 8 STLHOURS,*/ '||chr(10)
             ||'         CASE WHEN STLDAYS > 0 AND STLDAYS_BF < 0 THEN STLDAYS+STLDAYS_BF ELSE STLDAYS END STLDAYS, '||chr(10)
             ||'         CASE WHEN STLDAYS > 0 AND STLDAYS_BF < 0 THEN STLDAYS+STLDAYS_BF ELSE STLDAYS END * 8 STLHOURS, '||chr(10) 
             ||'        ''ENTITLEMENT'' TRANSACTIONTYPE,''ADD'' ADDLESS, '''||P_USER||''', '||chr(10)
             ||'        0 STLHRS_BF, '||chr(10)
             ||'        0 STLDAYS_BF '||chr(10)
             ||'        /*STLDAYS_BF * 8, STLDAYS_BF */ '||chr(10)
             ||'    FROM WPSSTLENTITLEMENTCALCDETAILS '||CHR(10)
             ||'    WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
             ||'      AND FORTNIGHTSTARTDATE = '''||lv_Cur_fn_stdt||''' AND FORTNIGHTENDDATE = '''||lv_Cur_fn_endt||''' '||chr(10)
             ||'      AND ( NVL(STLDAYS,0) > 0 OR NVL(STLDAYS_BF,0) <> 0) '||CHR(10); 
             --||'      AND (NVL(STLDAYS,0)+NVL(STLDAYS_BF,0)) > 0 '||chr(10);
     dbms_output.put_line(lv_Sql);
     lv_Remarks := 'WPSSTLTRANSACTION INSERT';
     INSERT INTO WPS_ERROR_LOG(PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS)
        VALUES (lv_ProcName, null, sysdate, lv_Sql, lv_ParValues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
--     execute immediate lv_Sql;
    COMMIT;
    
    
    
EXCEPTION 
    WHEN OTHERS THEN
     lv_sqlerrm := sqlerrm ;
 --dbms_output.put_line(lv_sqlerrm);
    insert into WPS_ERROR_LOG(PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    values( lv_ProcName,lv_sqlerrm, sysdate, lv_Sql, lv_ParValues,lv_fn_stdt,lv_fn_endt, lv_Remarks);
 COMMIT;
        
end;
/


DROP PROCEDURE NJMCL_WEB.PRC_STLBAL_INCLUDE_ENCASH;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PRC_STLBAL_INCLUDE_ENCASH ( P_COMPCODE VARCHAR2, P_DIVCODE VARCHAR2, P_ASONDATE VARCHAR2, P_TOKENNO VARCHAR2 DEFAULT NULL, P_ENCASHMENT VARCHAR2 DEFAULT 'N') 
AS
lv_Sql          varchar2(2000);
lv_Workerserial varchar2(10);
lv_AsOnDate     date := to_date(P_ASONDATE,'DD/MM/YYYY');
lv_StartOfTheYear   VARCHAR2(10);
lv_ReturnValue  number := 0;
lv_CheckYear    varchar2(4) := substr(P_ASONDATE,7,4);
BEGIN
    
--    BEGIN
--        SELECT WORKERSERIAL INTO lv_Workerserial FROM WPSWORKERMAST WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE AND TOKENNO = P_TOKENNO;
--    EXCEPTION
--        WHEN OTHERS THEN lv_Workerserial := '';
--        lv_ReturnValue := 0;
--        RETURN lv_ReturnValue;             
--    END;    

--    lv_StartOfTheYear := '01/01/'||substr(P_ASONDATE,7,4);

--    lv_Sql := ' SELECT A.WORKERSERIAL, A.TOKENNO, SUM(B.STLHRS) STLHRS_BAL '||chr(10)
--        ||' FROM WPSWORKERMAST A, '||chr(10) 
--        ||' (  '||chr(10)

--    lv_Sql := ' SELECT SUM(B.STLHRS) STLHRS FROM'||CHR(10)
--        ||' ( '||CHR(10) 
--        ||'     SELECT WORKERSERIAL, SUM(NVL(STLHOURS,0)+ NVL(PREV_STLHRS,0)) STLHRS  '||chr(10) 
--        ||'     FROM WPSSTLTRANSACTION   '||chr(10)
--        ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10) 
--        ||'       AND TO_CHAR(FORTNIGHTSTARTDATE,''YYYY'')= '''||lv_CheckYear||'''  '||chr(10)
--        ||'       AND WORKERSERIAL = '''||lv_Workerserial||''' '||CHR(10)
--        ||'     GROUP BY WORKERSERIAL  '||chr(10)
--        ||'     UNION ALL  '||chr(10)
--        ||'     SELECT WORKERSERIAL, -1 * SUM(STLHOURS) STLHRS  '||chr(10)
--        ||'     FROM WPSSTLENTRY  '||chr(10)
--        ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
--        ||'       AND FORTNIGHTSTARTDATE >= TO_DATE('''||lv_StartOfTheYear||''',''DD/MM/YYYY'')   '||chr(10)
--        ||'       AND FORTNIGHTENDDATE <=  TO_DATE('''||P_ASONDATE||''',''DD/MM/YYYY'')  '||chr(10)
--        ||'       AND LEAVECODE = ''STL''  '||chr(10)
--        ||'       AND WORKERSERIAL = '''||lv_Workerserial||''' '||CHR(10)
--        ||'     GROUP BY WORKERSERIAL  '||chr(10);
--     IF NVL(P_ENCASHMENT,'N') = 'Y' THEN
--     lv_Sql := lv_Sql ||'     UNION ALL  '||chr(10)
--        ||'     SELECT WORKERSERIAL, ROUND(SUM(NVL(ATTENDANCEHOURS,0))/160,0)*8 STL_ENTITLE  '||chr(10)
--        ||'     FROM WPSWAGESDETAILS_MV  '||chr(10)
--        ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
--        ||'      AND FORTNIGHTSTARTDATE >= TO_DATE('''||lv_StartOfTheYear||''',''DD/MM/YYYY'')  '||chr(10)
--        ||'       AND FORTNIGHTENDDATE <  TO_DATE('''||P_ASONDATE||''',''DD/MM/YYYY'')  '||chr(10)
--        ||'       AND WORKERSERIAL = '''||lv_Workerserial||''' '||CHR(10)
--        ||'     GROUP BY WORKERSERIAL   '||chr(10);
--     END IF;   
        
--     lv_Sql := lv_Sql ||' ) B  '||chr(10);
--        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
--        ||'   AND A.WORKERSERIAL = B.WORKERSERIAL  '||chr(10)
--        ||' GROUP BY A.WORKERSERIAL, A.TOKENNO    '||chr(10);
--    DBMS_OUTPUT.PUT_LINE (lv_Sql);

DELETE FROM GBL_STLBAL;

    lv_Sql := '     INSERT INTO GBL_STLBAL ( COMPANYCODE, DIVISIONCODE, LEAVECODE, YEAR, ASONDATE, WORKERSERIAL, TOKENNO, '||chr(10) 
          ||'     ENTITLE_DAYS, PREV_STLDAYS, STLTAKEN_DAYS, STLBAL_DAYS) '||chr(10) 
          ||'     SELECT A.COMPANYCODE, A.DIVISIONCODE, ''STL'' LEAVECODE, B.YEARCODE,  '||chr(10)
          ||'     TO_DATE('''||P_ASONDATE||''',''DD/MM/YYYY'') ASONDATE, B.WORKERSERIAL, A.TOKENNO, '||chr(10)
          ||'     SUM(STLDAYS) ENTITLE_DAYS, SUM(PREV_STLDAYS) PREV_STLDAYS, SUM(STLDAYS_TAKEN) STLTAKEN_DAYS,  '||chr(10)
          ||'     (SUM(STLDAYS) + SUM(PREV_STLDAYS) - SUM(STLDAYS_TAKEN)) STLBAL_DAYS '||chr(10)
          ||'     FROM WPSWORKERMAST A, '||chr(10)
          ||'     (   '||chr(10)
          ||'         SELECT WORKERSERIAL,YEARCODE, STLDAYS,PREV_STLDAYS, 0 STLDAYS_TAKEN '||chr(10)
          ||'         FROM WPSSTLTRANSACTION  '||chr(10)
          ||'         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
          ||'         AND YEARCODE ='''||lv_CheckYear||''' ' ||chr(10);
          IF P_TOKENNO IS NOT NULL THEN
                      lv_Sql := lv_Sql || '         AND TOKENNO = '''||P_TOKENNO||''' ' ||chr(10);
          END IF;
          lv_Sql := lv_Sql || '         UNION ALL '||chr(10)
          ||'         SELECT WORKERSERIAL,'''||lv_CheckYear||''' YEARCODE, 0  STLDAYS,0 PREV_STLDAYS, SUM(LEAVEDAYS) STLDAYS_TAKEN '||chr(10)
          ||'         FROM WPSSTLENTRYDETAILS  '||chr(10)
          ||'         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
          ||'         AND TO_CHAR(LEAVEDATE,''YYYY'') = '''||lv_CheckYear||'''  '||chr(10)
          ||'         AND LEAVECODE=''STL'''||CHR(10);
          IF P_TOKENNO IS NOT NULL THEN
                      lv_Sql := lv_Sql || '         AND TOKENNO = '''||P_TOKENNO||''' ' ||chr(10);
          END IF;
          lv_Sql := lv_Sql || '         GROUP BY WORKERSERIAL    '||chr(10)
          ||'     ) B '||chr(10)
          ||'     WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
          ||'      AND A.WORKERSERIAL = B.WORKERSERIAL '||chr(10)
          ||'      GROUP BY A.COMPANYCODE, A.DIVISIONCODE, B.YEARCODE, B.WORKERSERIAL, A.TOKENNO  '||chr(10);       
    
          DBMS_OUTPUT.PUT_LINE (lv_Sql);
        execute immediate lv_Sql;

--    begin 
--        execute immediate lv_Sql into lv_ReturnValue;
--    exception
--        when others then lv_ReturnValue := 0;    
--    end;         

END;
/


DROP PROCEDURE NJMCL_WEB.PRC_STLBAL_YEARWISE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PRC_STLBAL_YEARWISE
( 
    P_COMPCODE VARCHAR2, 
    P_DIVCODE VARCHAR2, 
    P_ASONDATE VARCHAR2, 
    P_TOKENNO VARCHAR2 DEFAULT NULL, 
    P_ENCASHMENT VARCHAR2 DEFAULT 'N'
) 
AS
lv_Sql          varchar2(2000);
lv_Workerserial varchar2(10);
lv_AsOnDate     date := to_date(P_ASONDATE,'DD/MM/YYYY');
lv_StartOfTheYear   VARCHAR2(10);
lv_ReturnValue  number := 0;
lv_CheckYear    varchar2(4) := substr(P_ASONDATE,7,4);
lv_CheckYear_Start  varchar2(4) := lv_CheckYear-3;
lv_CheckYear_End    varchar2(4) := lv_CheckYear-1;
BEGIN
    
 --DBMS_OUTPUT.PUT_LINE (lv_CheckYear);
 --DBMS_OUTPUT.PUT_LINE (lv_CheckYear_Start);
-- DBMS_OUTPUT.PUT_LINE (lv_CheckYear_End);
--    BEGIN
--        SELECT WORKERSERIAL INTO lv_Workerserial FROM WPSWORKERMAST WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE AND TOKENNO = P_TOKENNO;
--    EXCEPTION
--        WHEN OTHERS THEN lv_Workerserial := '';
--        lv_ReturnValue := 0;
--        RETURN lv_ReturnValue;             
--    END;    

--    lv_StartOfTheYear := '01/01/'||substr(P_ASONDATE,7,4);

--    lv_Sql := ' SELECT A.WORKERSERIAL, A.TOKENNO, SUM(B.STLHRS) STLHRS_BAL '||chr(10)
--        ||' FROM WPSWORKERMAST A, '||chr(10) 
--        ||' (  '||chr(10)

--    lv_Sql := ' SELECT SUM(B.STLHRS) STLHRS FROM'||CHR(10)
--        ||' ( '||CHR(10) 
--        ||'     SELECT WORKERSERIAL, SUM(NVL(STLHOURS,0)+ NVL(PREV_STLHRS,0)) STLHRS  '||chr(10) 
--        ||'     FROM WPSSTLTRANSACTION   '||chr(10)
--        ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10) 
--        ||'       AND TO_CHAR(FORTNIGHTSTARTDATE,''YYYY'')= '''||lv_CheckYear||'''  '||chr(10)
--        ||'       AND WORKERSERIAL = '''||lv_Workerserial||''' '||CHR(10)
--        ||'     GROUP BY WORKERSERIAL  '||chr(10)
--        ||'     UNION ALL  '||chr(10)
--        ||'     SELECT WORKERSERIAL, -1 * SUM(STLHOURS) STLHRS  '||chr(10)
--        ||'     FROM WPSSTLENTRY  '||chr(10)
--        ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
--        ||'       AND FORTNIGHTSTARTDATE >= TO_DATE('''||lv_StartOfTheYear||''',''DD/MM/YYYY'')   '||chr(10)
--        ||'       AND FORTNIGHTENDDATE <=  TO_DATE('''||P_ASONDATE||''',''DD/MM/YYYY'')  '||chr(10)
--        ||'       AND LEAVECODE = ''STL''  '||chr(10)
--        ||'       AND WORKERSERIAL = '''||lv_Workerserial||''' '||CHR(10)
--        ||'     GROUP BY WORKERSERIAL  '||chr(10);
--     IF NVL(P_ENCASHMENT,'N') = 'Y' THEN
--     lv_Sql := lv_Sql ||'     UNION ALL  '||chr(10)
--        ||'     SELECT WORKERSERIAL, ROUND(SUM(NVL(ATTENDANCEHOURS,0))/160,0)*8 STL_ENTITLE  '||chr(10)
--        ||'     FROM WPSWAGESDETAILS_MV  '||chr(10)
--        ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
--        ||'      AND FORTNIGHTSTARTDATE >= TO_DATE('''||lv_StartOfTheYear||''',''DD/MM/YYYY'')  '||chr(10)
--        ||'       AND FORTNIGHTENDDATE <  TO_DATE('''||P_ASONDATE||''',''DD/MM/YYYY'')  '||chr(10)
--        ||'       AND WORKERSERIAL = '''||lv_Workerserial||''' '||CHR(10)
--        ||'     GROUP BY WORKERSERIAL   '||chr(10);
--     END IF;   
        
--     lv_Sql := lv_Sql ||' ) B  '||chr(10);
--        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
--        ||'   AND A.WORKERSERIAL = B.WORKERSERIAL  '||chr(10)
--        ||' GROUP BY A.WORKERSERIAL, A.TOKENNO    '||chr(10);
--    DBMS_OUTPUT.PUT_LINE (lv_Sql);

DELETE FROM GBL_STLBAL;

    lv_Sql := '     INSERT INTO GBL_STLBAL ( COMPANYCODE, DIVISIONCODE, LEAVECODE, YEAR, ASONDATE, WORKERSERIAL, TOKENNO, '||chr(10) 
          ||'     ENTITLE_DAYS, PREV_STLDAYS, STLTAKEN_DAYS, STLBAL_DAYS) '||chr(10) 
          ||'     SELECT A.COMPANYCODE, A.DIVISIONCODE, ''STL'' LEAVECODE, B.YEARCODE,  '||chr(10)
          ||'     TO_DATE('''||P_ASONDATE||''',''DD/MM/YYYY'') ASONDATE, B.WORKERSERIAL, A.TOKENNO, '||chr(10)
          ||'     SUM(STLDAYS) ENTITLE_DAYS, SUM(PREV_STLDAYS) PREV_STLDAYS, SUM(STLDAYS_TAKEN) STLTAKEN_DAYS,  '||chr(10)
          ||'     (SUM(STLDAYS) + SUM(PREV_STLDAYS) - SUM(STLDAYS_TAKEN)) STLBAL_DAYS '||chr(10)
          ||'     FROM WPSWORKERMAST A, '||chr(10)
          ||'     (   '||chr(10)
          ||'         SELECT WORKERSERIAL,FROMYEAR YEARCODE, STLDAYS,PREV_STLDAYS, 0 STLDAYS_TAKEN '||chr(10)
          ||'         FROM WPSSTLTRANSACTION  '||chr(10)
          ||'         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
          ||'         AND FROMYEAR BETWEEN '''||lv_CheckYear_Start||''' AND '''||lv_CheckYear_End||''''||chr(10);
          --||'         AND YEARCODE ='''||lv_CheckYear||''' ' ||chr(10);
          IF P_TOKENNO IS NOT NULL THEN
                      lv_Sql := lv_Sql || '         AND TOKENNO = '''||P_TOKENNO||''' ' ||chr(10);
          END IF;
          lv_Sql := lv_Sql || '         UNION ALL '||chr(10)
          ||'         SELECT WORKERSERIAL,/*'''||lv_CheckYear||'''*/YEAR YEARCODE, 0  STLDAYS,0 PREV_STLDAYS, SUM(LEAVEDAYS) STLDAYS_TAKEN '||chr(10)
          ||'         FROM WPSSTLENTRYDETAILS  '||chr(10)
          ||'         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
         -- ||'         AND TO_CHAR(LEAVEDATE,''YYYY'') = '''||lv_CheckYear||'''  '||chr(10)
          ||'         AND PAYMENTDATE<=TO_DATE('''||P_ASONDATE||''',''DD/MM/YYYY'')'||CHR(10)
          ||'         AND YEAR BETWEEN '''||lv_CheckYear_Start||''' AND '''||lv_CheckYear_End||''''||chr(10)
          ||'         AND LEAVECODE=''STL'' AND LEAVEDAYS>0'||CHR(10);
          IF P_TOKENNO IS NOT NULL THEN
                      lv_Sql := lv_Sql || '         AND TOKENNO = '''||P_TOKENNO||''' ' ||chr(10);
          END IF;
          lv_Sql := lv_Sql || '         GROUP BY WORKERSERIAL,YEAR    '||chr(10)
          ||'     ) B '||chr(10)
          ||'     WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
          ||'      AND A.WORKERSERIAL = B.WORKERSERIAL '||chr(10)
          ||'      GROUP BY A.COMPANYCODE, A.DIVISIONCODE, B.YEARCODE, B.WORKERSERIAL, A.TOKENNO  '||chr(10);       
    
          DBMS_OUTPUT.PUT_LINE (lv_Sql);
        execute immediate lv_Sql;

--    begin 
--        execute immediate lv_Sql into lv_ReturnValue;
--    exception
--        when others then lv_ReturnValue := 0;    
--    end;         

END;
/


DROP PROCEDURE NJMCL_WEB.PRC_STLBAL_YEARWISE_BK;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PRC_STLBAL_YEARWISE_bk 
( 
    P_COMPCODE VARCHAR2, 
    P_DIVCODE VARCHAR2, 
    P_ASONDATE VARCHAR2, 
    P_TOKENNO VARCHAR2 DEFAULT NULL, 
    P_ENCASHMENT VARCHAR2 DEFAULT 'N'
) 
AS
lv_Sql          varchar2(2000);
lv_Workerserial varchar2(10);
lv_AsOnDate     date := to_date(P_ASONDATE,'DD/MM/YYYY');
lv_StartOfTheYear   VARCHAR2(10);
lv_ReturnValue  number := 0;
lv_CheckYear    varchar2(4) := substr(P_ASONDATE,7,4);
lv_CheckYear_Start  varchar2(4) := lv_CheckYear-3;
lv_CheckYear_End    varchar2(4) := lv_CheckYear-1;
BEGIN
    
 --DBMS_OUTPUT.PUT_LINE (lv_CheckYear);
 --DBMS_OUTPUT.PUT_LINE (lv_CheckYear_Start);
-- DBMS_OUTPUT.PUT_LINE (lv_CheckYear_End);
--    BEGIN
--        SELECT WORKERSERIAL INTO lv_Workerserial FROM WPSWORKERMAST WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE AND TOKENNO = P_TOKENNO;
--    EXCEPTION
--        WHEN OTHERS THEN lv_Workerserial := '';
--        lv_ReturnValue := 0;
--        RETURN lv_ReturnValue;             
--    END;    

--    lv_StartOfTheYear := '01/01/'||substr(P_ASONDATE,7,4);

--    lv_Sql := ' SELECT A.WORKERSERIAL, A.TOKENNO, SUM(B.STLHRS) STLHRS_BAL '||chr(10)
--        ||' FROM WPSWORKERMAST A, '||chr(10) 
--        ||' (  '||chr(10)

--    lv_Sql := ' SELECT SUM(B.STLHRS) STLHRS FROM'||CHR(10)
--        ||' ( '||CHR(10) 
--        ||'     SELECT WORKERSERIAL, SUM(NVL(STLHOURS,0)+ NVL(PREV_STLHRS,0)) STLHRS  '||chr(10) 
--        ||'     FROM WPSSTLTRANSACTION   '||chr(10)
--        ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10) 
--        ||'       AND TO_CHAR(FORTNIGHTSTARTDATE,''YYYY'')= '''||lv_CheckYear||'''  '||chr(10)
--        ||'       AND WORKERSERIAL = '''||lv_Workerserial||''' '||CHR(10)
--        ||'     GROUP BY WORKERSERIAL  '||chr(10)
--        ||'     UNION ALL  '||chr(10)
--        ||'     SELECT WORKERSERIAL, -1 * SUM(STLHOURS) STLHRS  '||chr(10)
--        ||'     FROM WPSSTLENTRY  '||chr(10)
--        ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
--        ||'       AND FORTNIGHTSTARTDATE >= TO_DATE('''||lv_StartOfTheYear||''',''DD/MM/YYYY'')   '||chr(10)
--        ||'       AND FORTNIGHTENDDATE <=  TO_DATE('''||P_ASONDATE||''',''DD/MM/YYYY'')  '||chr(10)
--        ||'       AND LEAVECODE = ''STL''  '||chr(10)
--        ||'       AND WORKERSERIAL = '''||lv_Workerserial||''' '||CHR(10)
--        ||'     GROUP BY WORKERSERIAL  '||chr(10);
--     IF NVL(P_ENCASHMENT,'N') = 'Y' THEN
--     lv_Sql := lv_Sql ||'     UNION ALL  '||chr(10)
--        ||'     SELECT WORKERSERIAL, ROUND(SUM(NVL(ATTENDANCEHOURS,0))/160,0)*8 STL_ENTITLE  '||chr(10)
--        ||'     FROM WPSWAGESDETAILS_MV  '||chr(10)
--        ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
--        ||'      AND FORTNIGHTSTARTDATE >= TO_DATE('''||lv_StartOfTheYear||''',''DD/MM/YYYY'')  '||chr(10)
--        ||'       AND FORTNIGHTENDDATE <  TO_DATE('''||P_ASONDATE||''',''DD/MM/YYYY'')  '||chr(10)
--        ||'       AND WORKERSERIAL = '''||lv_Workerserial||''' '||CHR(10)
--        ||'     GROUP BY WORKERSERIAL   '||chr(10);
--     END IF;   
        
--     lv_Sql := lv_Sql ||' ) B  '||chr(10);
--        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
--        ||'   AND A.WORKERSERIAL = B.WORKERSERIAL  '||chr(10)
--        ||' GROUP BY A.WORKERSERIAL, A.TOKENNO    '||chr(10);
--    DBMS_OUTPUT.PUT_LINE (lv_Sql);

DELETE FROM GBL_STLBAL;

    lv_Sql := '     INSERT INTO GBL_STLBAL ( COMPANYCODE, DIVISIONCODE, LEAVECODE, YEAR, ASONDATE, WORKERSERIAL, TOKENNO, '||chr(10) 
          ||'     ENTITLE_DAYS, PREV_STLDAYS, STLTAKEN_DAYS, STLBAL_DAYS) '||chr(10) 
          ||'     SELECT A.COMPANYCODE, A.DIVISIONCODE, ''STL'' LEAVECODE, B.YEARCODE,  '||chr(10)
          ||'     TO_DATE('''||P_ASONDATE||''',''DD/MM/YYYY'') ASONDATE, B.WORKERSERIAL, A.TOKENNO, '||chr(10)
          ||'     SUM(STLDAYS) ENTITLE_DAYS, SUM(PREV_STLDAYS) PREV_STLDAYS, SUM(STLDAYS_TAKEN) STLTAKEN_DAYS,  '||chr(10)
          ||'     (SUM(STLDAYS) + SUM(PREV_STLDAYS) - SUM(STLDAYS_TAKEN)) STLBAL_DAYS '||chr(10)
          ||'     FROM WPSWORKERMAST A, '||chr(10)
          ||'     (   '||chr(10)
          ||'         SELECT WORKERSERIAL,FROMYEAR YEARCODE, STLDAYS,PREV_STLDAYS, 0 STLDAYS_TAKEN '||chr(10)
          ||'         FROM WPSSTLTRANSACTION  '||chr(10)
          ||'         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
          ||'         AND FROMYEAR BETWEEN '''||lv_CheckYear_Start||''' AND '''||lv_CheckYear_End||''''||chr(10);
          --||'         AND YEARCODE ='''||lv_CheckYear||''' ' ||chr(10);
          IF P_TOKENNO IS NOT NULL THEN
                      lv_Sql := lv_Sql || '         AND TOKENNO = '''||P_TOKENNO||''' ' ||chr(10);
          END IF;
          lv_Sql := lv_Sql || '         UNION ALL '||chr(10)
          ||'         SELECT WORKERSERIAL,/*'''||lv_CheckYear||'''*/YEAR YEARCODE, 0  STLDAYS,0 PREV_STLDAYS, SUM(LEAVEDAYS) STLDAYS_TAKEN '||chr(10)
          ||'         FROM WPSSTLENTRYDETAILS  '||chr(10)
          ||'         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
         -- ||'         AND TO_CHAR(LEAVEDATE,''YYYY'') = '''||lv_CheckYear||'''  '||chr(10)
          ||'         AND PAYMENTDATE<=TO_DATE('''||P_ASONDATE||''',''DD/MM/YYYY'')'||CHR(10)
          ||'         AND YEAR BETWEEN '''||lv_CheckYear_Start||''' AND '''||lv_CheckYear_End||''''||chr(10)
          ||'         AND LEAVECODE=''STL'' AND LEAVEDAYS>0'||CHR(10);
          IF P_TOKENNO IS NOT NULL THEN
                      lv_Sql := lv_Sql || '         AND TOKENNO = '''||P_TOKENNO||''' ' ||chr(10);
          END IF;
          lv_Sql := lv_Sql || '         GROUP BY WORKERSERIAL,YEAR    '||chr(10)
          ||'     ) B '||chr(10)
          ||'     WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
          ||'      AND A.WORKERSERIAL = B.WORKERSERIAL '||chr(10)
          ||'      GROUP BY A.COMPANYCODE, A.DIVISIONCODE, B.YEARCODE, B.WORKERSERIAL, A.TOKENNO  '||chr(10);       
    
          DBMS_OUTPUT.PUT_LINE (lv_Sql);
        execute immediate lv_Sql;

--    begin 
--        execute immediate lv_Sql into lv_ReturnValue;
--    exception
--        when others then lv_ReturnValue := 0;    
--    end;         

END;
/


DROP PROCEDURE NJMCL_WEB.PRC_STLBAL_YEARWISE_REP;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PRC_STLBAL_YEARWISE_REP
( 
    P_COMPCODE VARCHAR2, P_DIVCODE VARCHAR2, P_ASONDATE VARCHAR2, P_TOKENNO VARCHAR2 DEFAULT NULL, P_ENCASHMENT VARCHAR2 DEFAULT 'N'
) 
AS
lv_Sql          varchar2(2000);
lv_Workerserial varchar2(10);
lv_AsOnDate     date := to_date(P_ASONDATE,'DD/MM/YYYY');
lv_StartOfTheYear   VARCHAR2(10);
lv_ReturnValue  number := 0;
lv_CheckYear    varchar2(4) := substr(P_ASONDATE,7,4);
BEGIN
    
--    BEGIN
--        SELECT WORKERSERIAL INTO lv_Workerserial FROM WPSWORKERMAST WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE AND TOKENNO = P_TOKENNO;
--    EXCEPTION
--        WHEN OTHERS THEN lv_Workerserial := '';
--        lv_ReturnValue := 0;
--        RETURN lv_ReturnValue;             
--    END;    

--    lv_StartOfTheYear := '01/01/'||substr(P_ASONDATE,7,4);

--    lv_Sql := ' SELECT A.WORKERSERIAL, A.TOKENNO, SUM(B.STLHRS) STLHRS_BAL '||chr(10)
--        ||' FROM WPSWORKERMAST A, '||chr(10) 
--        ||' (  '||chr(10)

--    lv_Sql := ' SELECT SUM(B.STLHRS) STLHRS FROM'||CHR(10)
--        ||' ( '||CHR(10) 
--        ||'     SELECT WORKERSERIAL, SUM(NVL(STLHOURS,0)+ NVL(PREV_STLHRS,0)) STLHRS  '||chr(10) 
--        ||'     FROM WPSSTLTRANSACTION   '||chr(10)
--        ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10) 
--        ||'       AND TO_CHAR(FORTNIGHTSTARTDATE,''YYYY'')= '''||lv_CheckYear||'''  '||chr(10)
--        ||'       AND WORKERSERIAL = '''||lv_Workerserial||''' '||CHR(10)
--        ||'     GROUP BY WORKERSERIAL  '||chr(10)
--        ||'     UNION ALL  '||chr(10)
--        ||'     SELECT WORKERSERIAL, -1 * SUM(STLHOURS) STLHRS  '||chr(10)
--        ||'     FROM WPSSTLENTRY  '||chr(10)
--        ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
--        ||'       AND FORTNIGHTSTARTDATE >= TO_DATE('''||lv_StartOfTheYear||''',''DD/MM/YYYY'')   '||chr(10)
--        ||'       AND FORTNIGHTENDDATE <=  TO_DATE('''||P_ASONDATE||''',''DD/MM/YYYY'')  '||chr(10)
--        ||'       AND LEAVECODE = ''STL''  '||chr(10)
--        ||'       AND WORKERSERIAL = '''||lv_Workerserial||''' '||CHR(10)
--        ||'     GROUP BY WORKERSERIAL  '||chr(10);
--     IF NVL(P_ENCASHMENT,'N') = 'Y' THEN
--     lv_Sql := lv_Sql ||'     UNION ALL  '||chr(10)
--        ||'     SELECT WORKERSERIAL, ROUND(SUM(NVL(ATTENDANCEHOURS,0))/160,0)*8 STL_ENTITLE  '||chr(10)
--        ||'     FROM WPSWAGESDETAILS_MV  '||chr(10)
--        ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
--        ||'      AND FORTNIGHTSTARTDATE >= TO_DATE('''||lv_StartOfTheYear||''',''DD/MM/YYYY'')  '||chr(10)
--        ||'       AND FORTNIGHTENDDATE <  TO_DATE('''||P_ASONDATE||''',''DD/MM/YYYY'')  '||chr(10)
--        ||'       AND WORKERSERIAL = '''||lv_Workerserial||''' '||CHR(10)
--        ||'     GROUP BY WORKERSERIAL   '||chr(10);
--     END IF;   
        
--     lv_Sql := lv_Sql ||' ) B  '||chr(10);
--        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
--        ||'   AND A.WORKERSERIAL = B.WORKERSERIAL  '||chr(10)
--        ||' GROUP BY A.WORKERSERIAL, A.TOKENNO    '||chr(10);
--    DBMS_OUTPUT.PUT_LINE (lv_Sql);

DELETE FROM GBL_STLBAL;

    lv_Sql := '     INSERT INTO GBL_STLBAL ( COMPANYCODE, DIVISIONCODE, LEAVECODE, YEAR, ASONDATE, WORKERSERIAL, TOKENNO, '||chr(10) 
          ||'     ENTITLE_DAYS, PREV_STLDAYS, STLTAKEN_DAYS, STLBAL_DAYS) '||chr(10) 
          ||'     SELECT A.COMPANYCODE, A.DIVISIONCODE, ''STL'' LEAVECODE, B.YEARCODE,  '||chr(10)
          ||'     TO_DATE('''||P_ASONDATE||''',''DD/MM/YYYY'') ASONDATE, B.WORKERSERIAL, A.TOKENNO, '||chr(10)
          ||'     SUM(STLDAYS) ENTITLE_DAYS, SUM(PREV_STLDAYS) PREV_STLDAYS, SUM(STLDAYS_TAKEN) STLTAKEN_DAYS,  '||chr(10)
          ||'     (SUM(STLDAYS) + SUM(PREV_STLDAYS) - SUM(STLDAYS_TAKEN)) STLBAL_DAYS '||chr(10)
          ||'     FROM WPSWORKERMAST A, '||chr(10)
          ||'     (   '||chr(10)
          ||'         SELECT WORKERSERIAL,FROMYEAR YEARCODE, STLDAYS,PREV_STLDAYS, 0 STLDAYS_TAKEN '||chr(10)
          ||'         FROM WPSSTLTRANSACTION  '||chr(10)
          ||'         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10);
          --||'         AND YEARCODE ='''||lv_CheckYear||''' ' ||chr(10);
          IF P_TOKENNO IS NOT NULL THEN
                      lv_Sql := lv_Sql || '         AND TOKENNO = '''||P_TOKENNO||''' ' ||chr(10);
          END IF;
          lv_Sql := lv_Sql || '         UNION ALL '||chr(10)
          ||'         SELECT WORKERSERIAL,/*'''||lv_CheckYear||'''*/YEAR YEARCODE, 0  STLDAYS,0 PREV_STLDAYS, SUM(LEAVEDAYS) STLDAYS_TAKEN '||chr(10)
          ||'         FROM WPSSTLENTRYDETAILS  '||chr(10)
          ||'         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
          ||'         AND  LEAVEDATE  <= TO_DATE('''||P_ASONDATE||''',''DD/MM/YYYY'')  '||chr(10)
          ||'         AND LEAVECODE=''STL'' AND LEAVEDAYS>0'||CHR(10);
          IF P_TOKENNO IS NOT NULL THEN
                      lv_Sql := lv_Sql || '         AND TOKENNO = '''||P_TOKENNO||''' ' ||chr(10);
          END IF;
          lv_Sql := lv_Sql || '         GROUP BY WORKERSERIAL,YEAR    '||chr(10)
          ||'     ) B '||chr(10)
          ||'     WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
          ||'      AND A.WORKERSERIAL = B.WORKERSERIAL '||chr(10)
          ||'      GROUP BY A.COMPANYCODE, A.DIVISIONCODE, B.YEARCODE, B.WORKERSERIAL, A.TOKENNO  '||chr(10);       
    
          DBMS_OUTPUT.PUT_LINE (lv_Sql);
        execute immediate lv_Sql;

--    begin 
--        execute immediate lv_Sql into lv_ReturnValue;
--    exception
--        when others then lv_ReturnValue := 0;    
--    end;         

END;
/


DROP PROCEDURE NJMCL_WEB.PRC_STLDETAILS_UPDT;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PRC_STLDETAILS_UPDT (P_COMPCODE VARCHAR2, P_DIVCODE VARCHAR2, P_EFF_FROM_DT VARCHAR2, P_EFF_TO_DT VARCHAR2)
AS
lv_DATE DATE := TO_DATE(P_EFF_FROM_DT,'DD/MM/YYYY');
lv_WORKERSERIAL VARCHAR2(10) := '';
lv_LeaveDays    number(5) := 0;
lv_IsSanction   varchar2(1) := '';
BEGIN
--    FOR C1 IN ( SELECT * FROM WPSSTLENTRY 
--                WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE  = P_DIVCODE
--                  AND FORTNIGHTSTARTDATE >= TO_DATE(P_EFF_FROM_DT,'DD/MM/YYYY')
--                  AND FORTNIGHTENDDATE <= TO_DATE(P_EFF_TO_DT,'DD/MM/YYYY')
--              )

    FOR C1 IN ( SELECT A.* FROM WPSSTLENTRY A,
                (
                    SELECT DOCUMENTNO --, WORKERSERIAL, TOKENNO, STLFROMDATE, STLTODATE,  STLTODATE - STLFROMDATE+1 DIFFDAYS, STLDAYS 
                    FROM WPSSTLENTRY 
                    WHERE FORTNIGHTSTARTDATE >= TO_DATE(P_EFF_FROM_DT,'DD/MM/YYYY')
                      AND FORTNIGHTENDDATE <= TO_DATE(P_EFF_TO_DT,'DD/MM/YYYY')
                      AND COMPANYCODE = P_COMPCODE AND DIVISIONCODE  = P_DIVCODE
                    MINUS
                    SELECT DISTINCT DOCUMENTNO FROM WPSSTLENTRYDETAILS
                    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE  = P_DIVCODE                
                ) B
                WHERE A.COMPANYCODE = P_COMPCODE AND A.DIVISIONCODE  = P_DIVCODE
                  AND A.FORTNIGHTSTARTDATE >= TO_DATE(P_EFF_FROM_DT,'DD/MM/YYYY')
                  AND A.FORTNIGHTENDDATE <= TO_DATE(P_EFF_TO_DT,'DD/MM/YYYY')
                  AND A.DOCUMENTNO = B.DOCUMENTNO
              )

    LOOP
        lv_WORKERSERIAL := C1.WORKERSERIAL;
        lv_DATE := C1.STLFROMDATE;
        lv_IsSanction := 'Y';
        lv_LeaveDays := 1;
        WHILE (lv_WORKERSERIAL = C1.WORKERSERIAL AND lv_DATE <= C1.STLTODATE)
            loop    
                IF lv_LeaveDays > C1.STLDAYS THEN
                    lv_IsSanction := 'N';
                END IF;
                    
                insert into WPSSTLENTRYDETAILS (COMPANYCODE, DIVISIONCODE, YEARCODE, YEAR, LEAVECODE, DOCUMENTNO, DOCUMENTDATE, 
                FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, DEPARTMENTCODE, 
                OCCUPATIONCODE, SHIFTCODE, LEAVEFROMDATE, LEAVETODATE, LEAVEDATE, LEAVEHOURS, LEAVEDAYS, STLRATE, 
                ISSANCTIONED, TRANSACTIONTYPE, ADDLESS, USERNAME, LASTMODIFIEDDATE, SYSROWID)
                values (C1.COMPANYCODE, C1.DIVISIONCODE, C1.YEARCODE, C1.YEAR, 'STL' , C1.DOCUMENTNO, C1.DOCUMENTDATE, 
                C1.FORTNIGHTSTARTDATE, C1.FORTNIGHTENDDATE, C1.WORKERSERIAL, C1.TOKENNO, C1.WORKERCATEGORYCODE, C1.DEPARTMENTCODE, 
                C1.OCCUPATIONCODE, C1.SHIFTCODE, C1.STLFROMDATE, C1.STLTODATE, lv_DATE , 8 , 1 , C1.STLRATE, 
                lv_IsSanction , C1.TRANSACTIONTYPE, C1.ADDLESS, C1.USERNAME, SYSDATE, C1.SYSROWID);
                
                lv_LeaveDays := lv_LeaveDays +1;    
                lv_DATE := lv_DATE+1;               
            end loop;
        
        
    END LOOP;   
                     
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE ('ERR. -'||sqlerrm||' ***** '||lv_WORKERSERIAL);
END;
/


DROP PROCEDURE NJMCL_WEB.PROC_RPTPAYSLIP_STL_NJMCL;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_RPTPAYSLIP_STL_NJMCL
--exec PROC_RPTPAYSLIP_STL_NJMCL ('NJ0001', '0002', '01/02/2020','15/02/2020','''19'',''20''','''2'',''3''','''01'',''02''','''B'',''P''','''06738'',''00023''')
(
    P_COMPANYCODE       VARCHAR2,
    P_DIVISIONCODE      VARCHAR2,
    P_FORTNIGHTSTDATE   VARCHAR2,
    P_FORTNIGHTENDDATE  VARCHAR2,
    P_DEPT              VARCHAR2,
    P_SHIFT             VARCHAR2,
    P_SECTION           VARCHAR2,    
    P_CATEGORY          VARCHAR2,
    P_TOKEN             VARCHAR2,
    P_SLIPFROM          VARCHAR2,
    P_SLIPTO            VARCHAR2
)
AS 
/******************************************************************************
   NAME:      Ujjwal
   PURPOSE:   STL Pay slip - njmcl
   Date :     24.06.2020
   Modified : 15.07.2020 by Ujjwal
            
   NOTES:
   Implementing for Naihati Jute Mills 
******************************************************************************/

    LV_SQLSTR           VARCHAR2(32000); 
    LV_INSERTSTR VARCHAR2(4000); 
    LV_COMPANYNAME VARCHAR2(100);
    LV_SRL NUMBER(5); 
    LV_CATEGORYCODE VARCHAR2(100); 
    LV_DEPARTMENTNAME  VARCHAR2(100);
    LV_CNT      NUMBER(10);
    LV_PAGENO  NUMBER(10);    
    P_INT1  NUMBER(20);
    P_SLNO NUMBER:=0;
    P_RECORDNO NUMBER:=0;
    p_lsttoken varchar2(20);
    lv_SlipNo varchar2(100);
    
    lv_dept varchar2(20);
    lv_shift varchar2(20);    
    lv_lstDept varchar2(20);    
    lv_section varchar2(20);
    lv_newPage varchar2(20);    
    lv_count number:=0;
    LV_LASTC1 GTT_PAYSLIP_NJMCL%rowtype; 
    
    lv_CountRecd number:=0;
    lv_lstCountRecd number:=0;
    lv_recdCount number:=0;
     
    lv_sqlerrm          varchar2(500) := ''; 
    lv_remarks          varchar2(500) := 'Generate Payslip(STL) '; 
    lv_parvalues        varchar2(500) := ''; 
    lv_ProcName         varchar2(500) := 'PROC_RPTPAYSLIP_STL_NJMCL'; 

BEGIN   
      
        if P_SLIPFROM is not null and P_SLIPTO is not null then
        
        --nvl(P_SLIPFROM,0)>0 AND nvl(P_SLIPTO,0)>0 then           
            lv_SlipNo:= ' (SLIPNO>= '||P_SLIPFROM ||' AND SLIPNO<= '||P_SLIPTO ||')';        
        else
            if nvl(P_SLIPFROM,0)>0 then
                lv_SlipNo:= ' SLIPNO>= '||P_SLIPFROM;
            end if;
            
            if nvl(P_SLIPTO,0)>0 then
                lv_SlipNo:= ' SLIPNO<= '||P_SLIPTO;
            end if;
        end if;
        
    
        DELETE FROM GTT_TEXT_PAYSLIPNJMCL;
        DELETE FROM GTT_PAYSLIP_NJMCL;
                         
        LV_SQLSTR := ' INSERT INTO GTT_PAYSLIP_NJMCL
            (SLIPNO, COMPANYCODE, DIVISIONCODE, FORTNIGHTENDDATE, DEPT, SRLNO, RECORDNO, WORKERNAME, EBDESIG, DSGCD, CT,ESINO,ATNHRS,
            STLDAYS,STLPERIOD,OTHR,DA,HRA, PBF,FPF,PF, ESI, P_TAX, PCO, GRERNG, GRDEDN, NETPAY,DEPARTMENTCODE,WORKERCATEGORYCODE,  WORKERCATEGORYNAME, SECTION, SHIFT) ';
  
    if lv_SlipNo is not null then
        lv_sqlstr := lv_sqlstr||chr(10)||'  SELECT * FROM (  ';         
    end if;
     
    lv_sqlstr := lv_sqlstr||chr(10)||'    
            SELECT ROW_NUMBER() OVER(ORDER BY DEPARTMENTCODE,SECTIONCODE, SHIFTCODE,TO_NUMBER(SRLNO), RECORDNO) SLIPNO,COMPANYCODE, DIVISIONCODE,
                TO_CHAR(PAYMENTDATE,''DD-MM-YY'')PAYMENTDATE, DEPT, SRLNO, RECORDNO, WORKERNAME,EBDESIG, DSGCD, CT, ESINO, ATNHRS, 
                STLDAYS, STLPERIOD, OTHR, DA, HRA,  PBF, FPF, PF,ESI, P_TAX,PCO,GRERNG, GRDEDN,NETPAY,DEPARTMENTCODE, WORKERCATEGORYCODE,  
                WORKERCATEGORYNAME, SECTIONCODE, SHIFTCODE
            FROM VW_WPSPAYSLIP_STL 
            WHERE COMPANYCODE='''||P_COMPANYCODE||'''
                AND DIVISIONCODE='''||P_DIVISIONCODE||'''
                AND PAYMENTDATE>=TO_DATE('''||P_FORTNIGHTSTDATE||''',''DD/MM/YYYY'')
                AND PAYMENTDATE<=TO_DATE('''||P_FORTNIGHTENDDATE||''',''DD/MM/YYYY'')         
                
       --       AND RECORDNO IN (''04202'',''04189'',''00060'',''05101'') 
       --       AND RECORDNO IN (''00053'',''95063'',''95013'',''95021'')  
       --   AND RECORDNO IN (''61257'',''61294'',''61296'')  
       --   AND RECORDNO IN (''64853'',''01507'',''01441'')  
       --   and departmentcode in (''01'',''04'')     
               ' ;
                
            if p_dept is not null then
               lv_sqlstr := lv_sqlstr||chr(10)||' AND DEPARTMENTCODE IN ('||p_dept||')'; 
            end if;        
           
            if p_section is not null then
               lv_sqlstr := lv_sqlstr||chr(10)||' AND SECTIONCODE IN ('||p_section||')'; 
            end if;        
           
            if p_category is not null then
               lv_sqlstr := lv_sqlstr||chr(10)||' AND WORKERCATEGORYCODE IN ('||p_category||')'; 
            end if;
           
            if p_shift is not null then
               lv_sqlstr := lv_sqlstr||chr(10)||' AND  decode(SHIFTCODE,''A'',''1'',''B'',''2'',''C'',''3'',''1'') IN ('||p_shift||')'; 
            end if;
           
            if p_token is not null then
               lv_sqlstr := lv_sqlstr||chr(10)||' AND RECORDNO IN ('||p_token||')'; 
            end if;
        
            if lv_SlipNo is not null then
                lv_sqlstr := lv_sqlstr||chr(10)||' ) where  '||lv_SlipNo;
            end if;                   
                  
            
            lv_sqlerrm := ''; --sqlerrm ;    
            insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS)
            values( P_COMPANYCODE, P_DIVISIONCODE, lv_ProcName,lv_sqlerrm, LV_SQLSTR, lv_parvalues,TO_DATE(P_FORTNIGHTSTDATE,'DD/MM/YYYY'),TO_DATE(P_FORTNIGHTENDDATE,'DD/MM/YYYY'),lv_remarks);
            
                  
       --DBMS_OUTPUT.PUT_LINE(' '||LV_SQLSTR);   
        EXECUTE IMMEDIATE LV_SQLSTR;        
        
        /*******************Check Data Exist*******************************/
        SELECT COUNT(*) INTO LV_CNT  FROM GTT_PAYSLIP_NJMCL ;
        
        IF LV_CNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20111,'NO DATA FOUND !!!!!');
            RETURN;        
        END IF;
        /*******************End Check Data Exist***************************/           
              
                        
        DELETE FROM GTT_TEXT_REPORT;
        
        LV_PAGENO := 0;
        P_INT1 := 0;
        LV_SRL := 0;
        
        p_lsttoken:=null;        
      
        
        FOR C1 IN (SELECT * FROM GTT_PAYSLIP_NJMCL ORDER BY SLIPNO)
        LOOP
        
         P_RECORDNO:=P_RECORDNO+1;           
        
            IF lv_dept IS NULL THEN
                lv_dept := C1.DEPARTMENTCODE ;
            END IF;
            
            IF lv_shift IS NULL THEN
                lv_shift := C1.SHIFT;
            END IF;
                  
            lv_CountRecd :=lv_CountRecd +1;        
          
         --   if NVL(lv_dept,'NA') <> C1.DEPARTMENTCODE or NVL(lv_shift,'NA') <> C1.SHIFT then                          
                
                
                select count(*) into lv_recdCount from GTT_TEXT_PAYSLIPNJMCL WHERE TOKEN=LV_LASTC1.RECORDNO;
                   
            
--                if lv_recdCount<1 then 
--                                    
--                    ----DBMS_OUTPUT.PUT_LINE('REC 11 : '||lv_recdCount|| '....................'||LV_LASTC1.RECORDNO);  
--                
--                    ---0001)  
--                    LV_INSERTSTR := ' ';
--                    IF LV_LASTC1.ATREWARD>0 THEN
--                        LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',1)||fnAlignZeroVal(LV_LASTC1.ATREWARD_HEAD, 24, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ATREWARD, 5, 'C',2)||']';     
--                    ELSE
--                        LV_INSERTSTR := LPAD(' ',32);                            
--                    END IF;       
--                                                
--                    P_SLNO:=P_SLNO+1;                     
--                        INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                        VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);  
--                        
--                    
--                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.DEPT, 8, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SRLNO, 5, 'C')||' '||fnAlignZeroVal(LV_LASTC1.RECORDNO, 8, 'C')||
--                    ' '||fnAlignZeroVal(LV_LASTC1.WORKERNAME, 19, 'L')||' '||fnAlignZeroVal(LV_LASTC1.EBDESIG, 10, 'L')||' '||fnAlignZeroVal(LV_LASTC1.DSGCD, 3, 'L')||
--                    ' '||fnAlignZeroVal(LV_LASTC1.CT, 2, 'C')||' '||fnAlignZeroVal(LV_LASTC1.FORTNIGHTENDDATE, 10, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SLIPNO, 5, 'R'); 
--                                       
--                    P_SLNO:=P_SLNO+1;                             
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
--                               
--                                
--                    --       0002)    
--                    LV_INSERTSTR := ' '; 
--                    P_SLNO:=P_SLNO+1;                     
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);  
--                                                   
--                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ESINO, 8, 'L')||' '||fnAlignZeroVal(LV_LASTC1.ATNDAY, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.ATNHRS, 8, 'R',2)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.NSHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBHR, 3, 'R',2)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.STLDAYS, 4, 'R',1)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.STLPERIOD, 13, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.YTDDAYS, 11, 'R',1) ; 
--
--                    P_SLNO:=P_SLNO+1;                             
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
--                                 
--                   
--                    --       0003)   
--                     LV_INSERTSTR := ' '; 
--                    IF LV_LASTC1.FBWG>0 THEN
--                        LV_INSERTSTR := LPAD(' ',49);                              
--                    ELSE
--                        IF LV_LASTC1.FBWG1>0 THEN
--                            LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',38)||fnAlignZeroVal(LV_LASTC1.ELECTRIC_HEAD, 10, 'L');
--                        ELSE
--                            LV_INSERTSTR := LPAD(' ',49);     
--                        END IF;                              
--                    END IF;                                                     
--                                                                     
--                    P_SLNO:=P_SLNO+1;                     
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);  
--                     
--                              
--                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.BASIC, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.SE, 6, 'C')||' '||fnAlignZeroVal(LV_LASTC1.DA, 8, 'R',2)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.FIXER, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLWG, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBWG, 6, 'R',2)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.NSA, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.OT_AMOUNT, 8, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.INCENTIVE, 5, 'R',2)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.HRA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PBF, 3, 'R',2) ; 
--               
--                    P_SLNO:=P_SLNO+1;                             
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
--                                                
--                                      
--                    --       0004) 
--                    LV_INSERTSTR := ' '; 
--                    P_SLNO:=P_SLNO+1;                     
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);  
--                    
--                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ADJERNG, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LOC, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF, 7, 'R')||
--                    ' '||fnAlignZeroVal(LV_LASTC1.FPF, 5, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ESI, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_RCV, 6, 'R')||
--                    ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_RCV, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ADJDEDN, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.HRENT, 6, 'R')||
--                    ' '||fnAlignZeroVal(LV_LASTC1.P_TAX,4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LWF, 5, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PCO, 4, 'R') ; 
--                    
--                    P_SLNO:=P_SLNO+1;                             
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
--                         
--
--                    --       0005) 
--                       LV_INSERTSTR := ' ';               
--                       LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',4)||fnAlignZeroVal(LV_LASTC1.TSA_HEAD, 5, 'L')||LPAD(' ',61)||''||fnAlignZeroVal(LV_LASTC1.NETPAY_HEAD, 9, 'L');                  
--                                                                     
--                    P_SLNO:=P_SLNO+1;                     
--                        INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                        VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO); 
--                    
--                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.TSA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PF_OWN_YTD, 8, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_BAL, 8, 'R',1)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_BAL, 8, 'R')||' '||fnAlignZeroVal(LV_LASTC1.INST, 2, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GR_FOR_BONUS, 8, 'R',2)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.GRD, 1, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GRERNG, 9, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.GRDEDN, 8, 'R',2)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.NETPAY, 9, 'R',2);
--                                                        
--                    P_SLNO:=P_SLNO+1;                             
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
--                                    
--                    lv_newPage:= PKG_PRINT_TEXT.P_NEWPAGE;
--                    lv_CountRecd:=0;
--                    
--                    P_SLNO:=P_SLNO+1;                    
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) 
--                    VALUES(P_SLNO,'***',lv_newPage);
--                          
--                    LV_LASTC1 := NULL   ;
--                    LV_COUNT:=0; 
--                    
--                end if;                   
            --end if;                              
         
      
          
            if p_lsttoken is NOT null and LV_COUNT=1 and p_lsttoken<>c1.recordno then     
                LV_COUNT:=-1;                              
                                      
--                --DBMS_OUTPUT.PUT_LINE('REC 2 : '||LV_LASTC1.RECORDNO);  
--                --DBMS_OUTPUT.PUT_LINE('REC 2 : '||C1.RECORDNO);  
                                
                --      0001)    
                LV_INSERTSTR := ' ';
                IF LV_LASTC1.ATREWARD>0 THEN
                    LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',1)||fnAlignZeroVal(LV_LASTC1.ATREWARD_HEAD, 24, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ATREWARD, 5, 'C',2)||']';     
                ELSE
                    LV_INSERTSTR := LPAD(' ',32);                            
                END IF;
                
                IF C1.ATREWARD>0 THEN
                   LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',55)||fnAlignZeroVal(C1.ATREWARD_HEAD, 24, 'R')||' '||fnAlignZeroVal(C1.ATREWARD, 5, 'C',2)||']';                                    
                END IF;        
                                            
                P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);                                                      
                
                          
                LV_INSERTSTR := fnAlignZeroVal(LV_LASTC1.DEPT, 8, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SRLNO, 5, 'C')||' '||fnAlignZeroVal(LV_LASTC1.RECORDNO, 8, 'C')||
                ' '||fnAlignZeroVal(LV_LASTC1.WORKERNAME, 19, 'L')||' '||fnAlignZeroVal(LV_LASTC1.EBDESIG, 10, 'L')||' '||fnAlignZeroVal(LV_LASTC1.DSGCD, 3, 'L')||
                ' '||fnAlignZeroVal(LV_LASTC1.CT, 2, 'C')||' '||fnAlignZeroVal(LV_LASTC1.FORTNIGHTENDDATE, 10, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SLIPNO, 5, 'R'); 
                                
                LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',2)||fnAlignZeroVal(C1.DEPT, 8, 'C')||' '||fnAlignZeroVal(C1.SRLNO, 5, 'C')||' '||fnAlignZeroVal(C1.RECORDNO, 8, 'C')||
                ' '||fnAlignZeroVal(C1.WORKERNAME, 19, 'L')||' '||fnAlignZeroVal(C1.EBDESIG, 10, 'L')||' '||fnAlignZeroVal(C1.DSGCD, 3, 'L')||
                ' '||fnAlignZeroVal(C1.CT, 2, 'C')||' '||fnAlignZeroVal(C1.FORTNIGHTENDDATE, 10, 'C')||' '||fnAlignZeroVal(C1.SLIPNO, 5, 'R'); 
                           
                P_SLNO:=P_SLNO+1;                     
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT,LV_LASTC1.RECORDNO||':'||C1.RECORDNO);
                             

                --       0002)        
                LV_INSERTSTR := ' '; 
                P_SLNO:=P_SLNO+1;                     
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO); 
                                           
                LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ESINO, 8, 'L')||' '||fnAlignZeroVal(LV_LASTC1.ATNDAY, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.ATNHRS, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NSHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBHR, 3, 'R',2)||
                --' '||fnAlignZeroVal(LV_LASTC1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.STLDAYS, 4, 'R',1)||
                --' '||fnAlignZeroVal(LV_LASTC1.STLPERIOD, 13, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.YTDDAYS, 11, 'R',1) ; 
                ' '||fnAlignZeroVal(LV_LASTC1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.STLDAYS, 5, 'R',1)||
                ' '||fnAlignZeroVal(LV_LASTC1.STLPERIOD, 12, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.YTDDAYS, 11, 'R',1) ; 

                LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',2)||fnAlignZeroVal(C1.ESINO, 8, 'L')||' '||fnAlignZeroVal(C1.ATNDAY, 5, 'R',1)||' '||fnAlignZeroVal(C1.ATNHRS, 8, 'R',2)||
                ' '||fnAlignZeroVal(C1.NSHR, 4, 'R',2)||' '||fnAlignZeroVal(C1.HOLHR, 4, 'R',2)||' '||fnAlignZeroVal(C1.FBHR, 3, 'R',2)||
--                ' '||fnAlignZeroVal(C1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(C1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(C1.STLDAYS, 4, 'R',1)||
--                ' '||fnAlignZeroVal(C1.STLPERIOD, 13, 'R',2)||' '||fnAlignZeroVal(C1.YTDDAYS, 11, 'R',1) ;
                ' '||fnAlignZeroVal(C1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(C1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(C1.STLDAYS, 5, 'R',1)||
                ' '||fnAlignZeroVal(C1.STLPERIOD, 12, 'R',2)||' '||fnAlignZeroVal(C1.YTDDAYS, 11, 'R',1) ;  
                                                       
                P_SLNO:=P_SLNO+1;                             
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                         
                         
                --       0003)  
                LV_INSERTSTR := ' '; 
                IF LV_LASTC1.FBWG>0 THEN
                    LV_INSERTSTR := LPAD(' ',49);                              
                ELSE
                    IF LV_LASTC1.FBWG1>0 THEN
                        LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',38)||fnAlignZeroVal(LV_LASTC1.ELECTRIC_HEAD, 10, 'L');
                    ELSE
                        LV_INSERTSTR := LPAD(' ',49);     
                    END IF;                              
                END IF;
                
                IF C1.FBWG>0 THEN
                 LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',32);                                
                ELSE
                    IF LV_LASTC1.FBWG1>0 THEN
                        LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',69)||fnAlignZeroVal(LV_LASTC1.ELECTRIC_HEAD, 10, 'L');           
                    ELSE
                        LV_INSERTSTR := LPAD(' ',49);     
                    END IF;                                                        
                END IF;                                         
                                                                 
                P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);                  
                 
                        
                LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.BASIC, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.SE, 6, 'C')||' '||fnAlignZeroVal(LV_LASTC1.DA, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.FIXER, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLWG, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBWG1, 6, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NSA, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.OT_AMOUNT, 8, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.INCENTIVE, 5, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.HRA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PBF, 3, 'R',2) ; 
                  
                LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',2)||fnAlignZeroVal(C1.BASIC, 7, 'R',2)||' '||fnAlignZeroVal(C1.SE,6, 'C')||' '||fnAlignZeroVal(C1.DA, 8, 'R',2)||
                ' '||fnAlignZeroVal(C1.FIXER, 6, 'R',2)||' '||fnAlignZeroVal(C1.HOLWG, 6, 'R',2)||' '||fnAlignZeroVal(C1.FBWG1, 6, 'R',2)||
                ' '||fnAlignZeroVal(C1.NSA, 6, 'R',2)||' '||fnAlignZeroVal(C1.OT_AMOUNT, 8, 'R',2)||' '||fnAlignZeroVal(C1.INCENTIVE, 5, 'R',2)||
                ' '||fnAlignZeroVal(C1.HRA, 7, 'R',2)||' '||fnAlignZeroVal(C1.PBF, 3, 'R',2) ; 
                                         
                P_SLNO:=P_SLNO+1;                             
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                                        
                              
                --       0004) 
                LV_INSERTSTR := ' '; 
                P_SLNO:=P_SLNO+1;                     
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO); 
                
                LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ADJERNG, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LOC, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF, 7, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.FPF, 5, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ESI, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_RCV, 6, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_RCV, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ADJDEDN, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.HRENT, 6, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.P_TAX,4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LWF, 4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PCO, 4, 'R') ; 

                LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',3)||fnAlignZeroVal(C1.ADJERNG, 6, 'R')||' '||fnAlignZeroVal(C1.LOC, 6, 'R')||' '||fnAlignZeroVal(C1.PF, 7, 'R')||
                ' '||fnAlignZeroVal(C1.FPF, 5, 'R')||' '||fnAlignZeroVal(C1.ESI, 6, 'R')||' '||fnAlignZeroVal(C1.PF_LN_RCV, 6, 'R')||
                ' '||fnAlignZeroVal(C1.PL_INT_RCV, 6, 'R')||' '||fnAlignZeroVal(C1.ADJDEDN, 6, 'R')||' '||fnAlignZeroVal(C1.HRENT, 6, 'R')||
                ' '||fnAlignZeroVal(C1.P_TAX, 4, 'R')||' '||fnAlignZeroVal(C1.LWF, 4, 'R')||' '||fnAlignZeroVal(C1.PCO, 4, 'R') ; 
                                                
                P_SLNO:=P_SLNO+1;                             
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                 

                --       0005)  
                 LV_INSERTSTR := ' ';               
                   LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',4)||fnAlignZeroVal(LV_LASTC1.TSA_HEAD, 5, 'L')||LPAD(' ',61)||''||fnAlignZeroVal(LV_LASTC1.NETPAY_HEAD, 9, 'L');                  
                   LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',5)||fnAlignZeroVal(C1.TSA_HEAD, 5, 'L')||LPAD(' ',61)||''||fnAlignZeroVal(LV_LASTC1.NETPAY_HEAD, 9, 'L');                                   
                                                                 
                P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);                  
                
                
                LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.TSA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PF_OWN_YTD, 8, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_BAL, 8, 'R',1)||
                ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_BAL, 8, 'R')||' '||fnAlignZeroVal(LV_LASTC1.INST, 2, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GR_FOR_BONUS, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.GRD, 1, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GRERNG, 9, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.GRDEDN, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NETPAY, 9, 'R',2) ;
               
                LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',3)||fnAlignZeroVal(C1.TSA, 7, 'R',2)||' '||fnAlignZeroVal(C1.PF_OWN_YTD, 8, 'R',1)||' '||fnAlignZeroVal(C1.PF_LN_BAL, 8, 'R',1)||
                ' '||fnAlignZeroVal(C1.PL_INT_BAL, 8, 'R')||' '||fnAlignZeroVal(C1.INST, 2, 'R')||' '||fnAlignZeroVal(C1.GR_FOR_BONUS, 8, 'R',2)||
                ' '||fnAlignZeroVal(C1.GRD, 1, 'R')||' '||fnAlignZeroVal(C1.GRERNG, 9, 'R',2)||' '||fnAlignZeroVal(C1.GRDEDN, 8, 'R',2)||
                ' '||fnAlignZeroVal(C1.NETPAY, 9, 'R',2) ;               
                                                      
                P_SLNO:=P_SLNO+1;                             
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                    
                --'CHANGE -
--                LV_INSERTSTR := ' '; 
--                P_SLNO:=P_SLNO+1;                     
--                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);                 
--                       
                P_SLNO:=P_SLNO+1;                
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) VALUES(P_SLNO,'***','');           

                P_SLNO:=P_SLNO+1;                
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) VALUES(P_SLNO,'***','');       

         
            end if;   
            
                p_lsttoken:=P_RECORDNO;
                            
                if lv_count=1 then
                   p_lsttoken:=null;
                end if;

                lv_count:=lv_count+1;
                LV_LASTC1:=c1;    
                            
                lv_dept:=C1.DEPARTMENTCODE;
                lv_shift:=C1.SHIFT;
                   
--            if lv_CountRecd=12 then    
--                lv_newPage:= PKG_PRINT_TEXT.P_NEWPAGE;
--                
--                P_SLNO:=P_SLNO+1;   
--                
--                -- INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) VALUES(P_SLNO,'***',lv_newPage);
--                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) VALUES(P_SLNO,'***','');
--                                                
--                lv_CountRecd:=0;
--            else                 
--                 if mod(lv_CountRecd,2)=0 and lv_CountRecd<>0 then 
--                 
--                 P_SLNO:=P_SLNO+1;              
--                     INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINETEXT) 
--                       VALUES(P_SLNO,'');      
--                       
--                        --'CHANGE -
--            -- LV_INSERTSTR := ' '; 
--                P_SLNO:=P_SLNO+1;                     
----                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
----                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);      
--                     INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINETEXT) 
--                       VALUES(P_SLNO,''); 
--                       
--                 end if;   
--            end if;                           
             
            
         END LOOP;         
        
        if lv_count=1 then       
            
--            --DBMS_OUTPUT.PUT_LINE('REC 3 : '||LV_LASTC1.RECORDNO);  
--            --DBMS_OUTPUT.PUT_LINE('REC F : '||LV_LASTC1.PBF); 
--            --DBMS_OUTPUT.PUT_LINE('REC O : '||LV_LASTC1.PCO); 
                          
            ---0001)     
            LV_INSERTSTR := ' ';
                IF LV_LASTC1.ATREWARD>0 THEN
                    LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',1)||fnAlignZeroVal(LV_LASTC1.ATREWARD_HEAD, 24, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ATREWARD, 5, 'C',2)||']';     
                ELSE
                    LV_INSERTSTR := LPAD(' ',32);                            
                END IF;               
        
                                            
                P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);  
                    
                                         
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.DEPT, 8, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SRLNO, 5, 'C')||' '||fnAlignZeroVal(LV_LASTC1.RECORDNO, 8, 'C')||
                ' '||fnAlignZeroVal(LV_LASTC1.WORKERNAME, 19, 'L')||' '||fnAlignZeroVal(LV_LASTC1.EBDESIG, 10, 'L')||' '||fnAlignZeroVal(LV_LASTC1.DSGCD, 3, 'L')||
                ' '||fnAlignZeroVal(LV_LASTC1.CT, 2, 'C')||' '||fnAlignZeroVal(LV_LASTC1.FORTNIGHTENDDATE, 10, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SLIPNO, 5, 'R'); 

            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                   
                   
            --       0002)    
            LV_INSERTSTR := ' '; 
            P_SLNO:=P_SLNO+1;                     
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                                           
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ESINO, 8, 'L')||' '||fnAlignZeroVal(LV_LASTC1.ATNDAY, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.ATNHRS, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NSHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBHR, 3, 'R',2)||
--                ' '||fnAlignZeroVal(LV_LASTC1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.STLDAYS, 4, 'R',1)||
--                ' '||fnAlignZeroVal(LV_LASTC1.STLPERIOD, 13, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.YTDDAYS, 11, 'R',1) ;
                ' '||fnAlignZeroVal(LV_LASTC1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.STLDAYS, 5, 'R',1)||
                ' '||fnAlignZeroVal(LV_LASTC1.STLPERIOD, 12, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.YTDDAYS, 11, 'R',1) ;  

            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                     
                    
            --       0003)   
              LV_INSERTSTR := ' '; 
                IF LV_LASTC1.FBWG>0 THEN
                    LV_INSERTSTR := LPAD(' ',49);                              
                ELSE
                    IF LV_LASTC1.FBWG1>0 THEN
                        LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',38)||fnAlignZeroVal(LV_LASTC1.ELECTRIC_HEAD, 10, 'L');
                    ELSE
                        LV_INSERTSTR := LPAD(' ',49);     
                    END IF;                              
                END IF;                                                     
                                                                 
                P_SLNO:=P_SLNO+1;                     
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);   
                 
                      
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.BASIC, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.SE, 6, 'C')||' '||fnAlignZeroVal(LV_LASTC1.DA, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.FIXER, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLWG, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBWG, 6, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NSA, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.OT_AMOUNT, 8, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.INCENTIVE, 5, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.HRA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PBF, 3, 'R',2) ; 
              

            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                                    
                          
            --       0004) 
            LV_INSERTSTR := ' '; 
            P_SLNO:=P_SLNO+1;                     
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
            
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ADJERNG, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LOC, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF, 7, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.FPF, 5, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ESI, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_RCV, 6, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_RCV, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ADJDEDN, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.HRENT, 6, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.P_TAX,4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LWF, 4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PCO, 4, 'R',2) ; 
                
            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
             
          
            --       0005) 
               LV_INSERTSTR := ' ';               
               LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',4)||fnAlignZeroVal(LV_LASTC1.TSA_HEAD, 5, 'L')||LPAD(' ',61)||''||fnAlignZeroVal(LV_LASTC1.NETPAY_HEAD, 9, 'L');                  
                                                                 
               P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO); 
                    
            
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.TSA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PF_OWN_YTD, 8, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_BAL, 8, 'R',1)||
                ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_BAL, 8, 'R')||' '||fnAlignZeroVal(LV_LASTC1.INST, 2, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GR_FOR_BONUS, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.GRD, 1, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GRERNG, 9, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.GRDEDN, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NETPAY, 9, 'R',2) ;

            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                                    
            lv_newPage:= PKG_PRINT_TEXT.P_NEWPAGE;
            lv_CountRecd:=0;
                         
--            P_SLNO:=P_SLNO+1;   
--            --INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) VALUES(P_SLNO,'***',lv_newPage);                        
--            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) VALUES(P_SLNO,'***','');

            P_SLNO:=P_SLNO+1;                
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) VALUES(P_SLNO,'***','');           

            P_SLNO:=P_SLNO+1;                
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) VALUES(P_SLNO,'***','');    
    
            LV_LASTC1 := NULL   ;
            LV_COUNT:=-1; 
                        
        end if;                  
             
        COMMIT;
END;
/


DROP PROCEDURE NJMCL_WEB.PROC_RPTPAYSLIP_STL_NJMCL11072;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_RPTPAYSLIP_STL_NJMCL11072
--exec PROC_RPTPAYSLIP_STL_NJMCL ('NJ0001', '0002', '01/02/2020','15/02/2020','''19'',''20''','''2'',''3''','''01'',''02''','''B'',''P''','''06738'',''00023''')
(
    P_COMPANYCODE       VARCHAR2,
    P_DIVISIONCODE      VARCHAR2,
    P_FORTNIGHTSTDATE   VARCHAR2,
    P_FORTNIGHTENDDATE  VARCHAR2,
    P_DEPT              VARCHAR2,
    P_SHIFT             VARCHAR2,
    P_SECTION           VARCHAR2,    
    P_CATEGORY          VARCHAR2,
    P_TOKEN             VARCHAR2
)
AS 
/******************************************************************************
   NAME:      Ujjwal
   PURPOSE:   STL Pay slip - njmcl
   Date :     24.06.2020
            
   NOTES:
   Implementing for Naihati Jute Mills 
******************************************************************************/

    LV_SQLSTR           VARCHAR2(32000); 
    LV_INSERTSTR VARCHAR2(4000); 
    LV_COMPANYNAME VARCHAR2(100);
    LV_SRL NUMBER(5); 
    LV_CATEGORYCODE VARCHAR2(100); 
    LV_DEPARTMENTNAME  VARCHAR2(100);
    LV_CNT      NUMBER(10);
    LV_PAGENO  NUMBER(10);    
    P_INT1  NUMBER(20);
    P_SLNO NUMBER:=0;
    P_RECORDNO NUMBER:=0;
    p_lsttoken varchar2(20);
    
    lv_dept varchar2(20);
    lv_shift varchar2(20);    
    lv_lstDept varchar2(20);
    
    lv_section varchar2(20);
    lv_newPage varchar2(20);
    
    lv_count number:=0;
    LV_LASTC1 GTT_PAYSLIP_NJMCL%rowtype; 
    
    lv_CountRecd number:=0;
    lv_lstCountRecd number:=0;
    lv_recdCount number:=0;
 
BEGIN              
        DELETE FROM GTT_TEXT_PAYSLIPNJMCL;
        DELETE FROM GTT_PAYSLIP_NJMCL;
                         
        LV_SQLSTR := ' INSERT INTO GTT_PAYSLIP_NJMCL
            (SLIPNO, COMPANYCODE, DIVISIONCODE, FORTNIGHTENDDATE, DEPT, SRLNO, RECORDNO, WORKERNAME, EBDESIG, DSGCD, CT,ESINO,ATNHRS,
            STLDAYS,STLPERIOD,OTHR,DA,HRA, PBF,FPF,PF, ESI, P_TAX, PCO, GRERNG, GRDEDN, NETPAY,DEPARTMENTCODE,WORKERCATEGORYCODE,  WORKERCATEGORYNAME, SECTION, SHIFT)
            
            SELECT ROW_NUMBER() OVER(ORDER BY DEPARTMENTCODE,SECTIONCODE, SHIFTCODE, RECORDNO) SLIPNO,COMPANYCODE, DIVISIONCODE,
                TO_CHAR(PAYMENTDATE,''DD-MM-YY'')PAYMENTDATE, DEPT, SRLNO, RECORDNO, WORKERNAME,EBDESIG, DSGCD, CT, ESINO, ATNHRS, 
                STLDAYS, STLPERIOD, OTHR, DA, HRA,  PBF, FPF, PF,ESI, P_TAX,PCO,GRERNG, GRDEDN,NETPAY,DEPARTMENTCODE, WORKERCATEGORYCODE,  
                WORKERCATEGORYNAME, SECTIONCODE, SHIFTCODE
            FROM VW_WPSPAYSLIP_STL 
            WHERE COMPANYCODE='''||P_COMPANYCODE||'''
                AND DIVISIONCODE='''||P_DIVISIONCODE||'''
                AND PAYMENTDATE>=TO_DATE('''||P_FORTNIGHTSTDATE||''',''DD/MM/YYYY'')
                AND PAYMENTDATE<=TO_DATE('''||P_FORTNIGHTENDDATE||''',''DD/MM/YYYY'')         
                
       --       AND RECORDNO IN (''04202'',''04189'',''00060'',''05101'') 
       --       AND RECORDNO IN (''00053'',''95063'',''95013'',''95021'')  
       --   AND RECORDNO IN (''61257'',''61294'',''61296'')  
       --   AND RECORDNO IN (''64853'',''01507'',''01441'')  
       --   and departmentcode in (''01'',''04'')     
               ' ;
                
        if p_dept is not null then
           lv_sqlstr := lv_sqlstr||chr(10)||' AND DEPARTMENTCODE IN ('||p_dept||')'; 
        end if;        
       
        if p_section is not null then
           lv_sqlstr := lv_sqlstr||chr(10)||' AND SECTIONCODE IN ('||p_section||')'; 
        end if;        
       
        if p_category is not null then
           lv_sqlstr := lv_sqlstr||chr(10)||' AND WORKERCATEGORYCODE IN ('||p_category||')'; 
        end if;
       
        if p_shift is not null then
           lv_sqlstr := lv_sqlstr||chr(10)||' AND  decode(SHIFTCODE,''A'',''1'',''B'',''2'',''C'',''3'',''1'') IN ('||p_shift||')'; 
        end if;
       
        if p_token is not null then
           lv_sqlstr := lv_sqlstr||chr(10)||' AND RECORDNO IN ('||p_token||')'; 
        end if;
                          
      
       DBMS_OUTPUT.PUT_LINE('query : '||LV_SQLSTR);   
        EXECUTE IMMEDIATE LV_SQLSTR;        
        
        /*******************Check Data Exist*******************************/
        SELECT COUNT(*) INTO LV_CNT  FROM GTT_PAYSLIP_NJMCL ;
        
        IF LV_CNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20111,'NO DATA FOUND !!!!!');
            RETURN;        
        END IF;
        /*******************End Check Data Exist***************************/           
              
                        
        DELETE FROM GTT_TEXT_REPORT;
        
        LV_PAGENO := 0;
        P_INT1 := 0;
        LV_SRL := 0;
        
        p_lsttoken:=null;        
      
        
        FOR C1 IN (SELECT * FROM GTT_PAYSLIP_NJMCL ORDER BY SLIPNO)
        LOOP
        
        P_RECORDNO:=P_RECORDNO+1;           
        
            IF lv_dept IS NULL THEN
                lv_dept := C1.DEPARTMENTCODE ;
            END IF;
            
            IF lv_shift IS NULL THEN
                lv_shift := C1.SHIFT;
            END IF;
                  
            lv_CountRecd :=lv_CountRecd +1;        
          
            if NVL(lv_dept,'NA') <> C1.DEPARTMENTCODE or NVL(lv_shift,'NA') <> C1.SHIFT then
                          
                
                
                select count(*) into lv_recdCount from GTT_TEXT_PAYSLIPNJMCL WHERE TOKEN=LV_LASTC1.RECORDNO;
                   
            
                if lv_recdCount<1 then 
                                    
                    --DBMS_OUTPUT.PUT_LINE('REC 11 : '||lv_recdCount|| '....................'||LV_LASTC1.RECORDNO);  
                
                    ---0001)  
                    LV_INSERTSTR := ' ';
                    IF LV_LASTC1.ATREWARD>0 THEN
                        LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',1)||fnAlignZeroVal(LV_LASTC1.ATREWARD_HEAD, 24, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ATREWARD, 5, 'C',2)||']';     
                    ELSE
                        LV_INSERTSTR := LPAD(' ',32);                            
                    END IF;       
                                                
                    P_SLNO:=P_SLNO+1;                     
                        INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                        VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);  
                        
                    
                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.DEPT, 8, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SRLNO, 5, 'C')||' '||fnAlignZeroVal(LV_LASTC1.RECORDNO, 8, 'C')||
                    ' '||fnAlignZeroVal(LV_LASTC1.WORKERNAME, 19, 'L')||' '||fnAlignZeroVal(LV_LASTC1.EBDESIG, 10, 'L')||' '||fnAlignZeroVal(LV_LASTC1.DSGCD, 3, 'L')||
                    ' '||fnAlignZeroVal(LV_LASTC1.CT, 2, 'C')||' '||fnAlignZeroVal(LV_LASTC1.FORTNIGHTENDDATE, 10, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SLIPNO, 5, 'R'); 
                                       
                    P_SLNO:=P_SLNO+1;                             
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                               
                                
                    --       0002)    
                    LV_INSERTSTR := ' '; 
                    P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);  
                                                   
                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ESINO, 8, 'L')||' '||fnAlignZeroVal(LV_LASTC1.ATNDAY, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.ATNHRS, 8, 'R',2)||
                    ' '||fnAlignZeroVal(LV_LASTC1.NSHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBHR, 3, 'R',2)||
                    ' '||fnAlignZeroVal(LV_LASTC1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.STLDAYS, 4, 'R',1)||
                    ' '||fnAlignZeroVal(LV_LASTC1.STLPERIOD, 13, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.YTDDAYS, 11, 'R',1) ; 

                    P_SLNO:=P_SLNO+1;                             
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                                 
                   
                    --       0003)   
                     LV_INSERTSTR := ' '; 
                    IF LV_LASTC1.FBWG>0 THEN
                        LV_INSERTSTR := LPAD(' ',49);                              
                    ELSE
                        IF LV_LASTC1.FBWG1>0 THEN
                            LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',38)||fnAlignZeroVal(LV_LASTC1.ELECTRIC_HEAD, 10, 'L');
                        ELSE
                            LV_INSERTSTR := LPAD(' ',49);     
                        END IF;                              
                    END IF;                                                     
                                                                     
                    P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);  
                     
                              
                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.BASIC, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.SE, 6, 'C')||' '||fnAlignZeroVal(LV_LASTC1.DA, 8, 'R',2)||
                    ' '||fnAlignZeroVal(LV_LASTC1.FIXER, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLWG, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBWG, 6, 'R',2)||
                    ' '||fnAlignZeroVal(LV_LASTC1.NSA, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.OT_AMOUNT, 8, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.INCENTIVE, 5, 'R',2)||
                    ' '||fnAlignZeroVal(LV_LASTC1.HRA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PBF, 3, 'R',2) ; 
               
                    P_SLNO:=P_SLNO+1;                             
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                                                
                                      
                    --       0004) 
                    LV_INSERTSTR := ' '; 
                    P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);  
                    
                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ADJERNG, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LOC, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF, 7, 'R')||
                    ' '||fnAlignZeroVal(LV_LASTC1.FPF, 5, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ESI, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_RCV, 6, 'R')||
                    ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_RCV, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ADJDEDN, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.HRENT, 6, 'R')||
                    ' '||fnAlignZeroVal(LV_LASTC1.P_TAX,4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LWF, 5, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PCO, 4, 'R') ; 
                    
                    P_SLNO:=P_SLNO+1;                             
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                         

                    --       0005) 
                       LV_INSERTSTR := ' ';               
                       LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',4)||fnAlignZeroVal(LV_LASTC1.TSA_HEAD, 5, 'L')||LPAD(' ',61)||''||fnAlignZeroVal(LV_LASTC1.NETPAY_HEAD, 9, 'L');                  
                                                                     
                    P_SLNO:=P_SLNO+1;                     
                        INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                        VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO); 
                    
                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.TSA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PF_OWN_YTD, 8, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_BAL, 8, 'R',1)||
                    ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_BAL, 8, 'R')||' '||fnAlignZeroVal(LV_LASTC1.INST, 2, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GR_FOR_BONUS, 8, 'R',2)||
                    ' '||fnAlignZeroVal(LV_LASTC1.GRD, 1, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GRERNG, 9, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.GRDEDN, 8, 'R',2)||
                    ' '||fnAlignZeroVal(LV_LASTC1.NETPAY, 9, 'R',2);
                                                        
                    P_SLNO:=P_SLNO+1;                             
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                                    
                    lv_newPage:= PKG_PRINT_TEXT.P_NEWPAGE;
                    lv_CountRecd:=0;
                    
                    P_SLNO:=P_SLNO+1;                    
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) 
                    VALUES(P_SLNO,'***',lv_newPage);
                          
                    LV_LASTC1 := NULL   ;
                    LV_COUNT:=0; 
                    
                end if;                   
            end if;                              
         
      
            if p_lsttoken is NOT null and LV_COUNT=1 and p_lsttoken<>c1.recordno then     
                LV_COUNT:=-1;                              
                                      
--                DBMS_OUTPUT.PUT_LINE('REC 2 : '||LV_LASTC1.RECORDNO);  
--                DBMS_OUTPUT.PUT_LINE('REC 2 : '||C1.RECORDNO);  
                                
                --      0001)    
                LV_INSERTSTR := ' ';
                IF LV_LASTC1.ATREWARD>0 THEN
                    LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',1)||fnAlignZeroVal(LV_LASTC1.ATREWARD_HEAD, 24, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ATREWARD, 5, 'C',2)||']';     
                ELSE
                    LV_INSERTSTR := LPAD(' ',32);                            
                END IF;
                
                IF C1.ATREWARD>0 THEN
                   LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',55)||fnAlignZeroVal(C1.ATREWARD_HEAD, 24, 'R')||' '||fnAlignZeroVal(C1.ATREWARD, 5, 'C',2)||']';                                    
                END IF;        
                                            
                P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);                                                      
                
                          
                LV_INSERTSTR := fnAlignZeroVal(LV_LASTC1.DEPT, 8, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SRLNO, 5, 'C')||' '||fnAlignZeroVal(LV_LASTC1.RECORDNO, 8, 'C')||
                ' '||fnAlignZeroVal(LV_LASTC1.WORKERNAME, 19, 'L')||' '||fnAlignZeroVal(LV_LASTC1.EBDESIG, 10, 'L')||' '||fnAlignZeroVal(LV_LASTC1.DSGCD, 3, 'L')||
                ' '||fnAlignZeroVal(LV_LASTC1.CT, 2, 'C')||' '||fnAlignZeroVal(LV_LASTC1.FORTNIGHTENDDATE, 10, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SLIPNO, 5, 'R'); 
                                
                LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',2)||fnAlignZeroVal(C1.DEPT, 8, 'C')||' '||fnAlignZeroVal(C1.SRLNO, 5, 'C')||' '||fnAlignZeroVal(C1.RECORDNO, 8, 'C')||
                ' '||fnAlignZeroVal(C1.WORKERNAME, 19, 'L')||' '||fnAlignZeroVal(C1.EBDESIG, 10, 'L')||' '||fnAlignZeroVal(C1.DSGCD, 3, 'L')||
                ' '||fnAlignZeroVal(C1.CT, 2, 'C')||' '||fnAlignZeroVal(C1.FORTNIGHTENDDATE, 10, 'C')||' '||fnAlignZeroVal(C1.SLIPNO, 5, 'R'); 
                           
                P_SLNO:=P_SLNO+1;                     
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT,LV_LASTC1.RECORDNO||':'||C1.RECORDNO);
                             

                --       0002)        
                LV_INSERTSTR := ' '; 
                P_SLNO:=P_SLNO+1;                     
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO); 
                                           
                LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ESINO, 8, 'L')||' '||fnAlignZeroVal(LV_LASTC1.ATNDAY, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.ATNHRS, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NSHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBHR, 3, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.STLDAYS, 4, 'R',1)||
                ' '||fnAlignZeroVal(LV_LASTC1.STLPERIOD, 13, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.YTDDAYS, 11, 'R',1) ; 

                LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',2)||fnAlignZeroVal(C1.ESINO, 8, 'L')||' '||fnAlignZeroVal(C1.ATNDAY, 5, 'R',1)||' '||fnAlignZeroVal(C1.ATNHRS, 8, 'R',2)||
                ' '||fnAlignZeroVal(C1.NSHR, 4, 'R',2)||' '||fnAlignZeroVal(C1.HOLHR, 4, 'R',2)||' '||fnAlignZeroVal(C1.FBHR, 3, 'R',2)||
                ' '||fnAlignZeroVal(C1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(C1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(C1.STLDAYS, 4, 'R',1)||
                ' '||fnAlignZeroVal(C1.STLPERIOD, 13, 'R',2)||' '||fnAlignZeroVal(C1.YTDDAYS, 11, 'R',1) ; 
                                                       
                P_SLNO:=P_SLNO+1;                             
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                         
                         
                --       0003)  
                LV_INSERTSTR := ' '; 
                IF LV_LASTC1.FBWG>0 THEN
                    LV_INSERTSTR := LPAD(' ',49);                              
                ELSE
                    IF LV_LASTC1.FBWG1>0 THEN
                        LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',38)||fnAlignZeroVal(LV_LASTC1.ELECTRIC_HEAD, 10, 'L');
                    ELSE
                        LV_INSERTSTR := LPAD(' ',49);     
                    END IF;                              
                END IF;
                
                IF C1.FBWG>0 THEN
                 LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',32);                                
                ELSE
                    IF LV_LASTC1.FBWG1>0 THEN
                        LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',69)||fnAlignZeroVal(LV_LASTC1.ELECTRIC_HEAD, 10, 'L');           
                    ELSE
                        LV_INSERTSTR := LPAD(' ',49);     
                    END IF;                                                        
                END IF;                                         
                                                                 
                P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);                  
                 
                        
                LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.BASIC, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.SE, 6, 'C')||' '||fnAlignZeroVal(LV_LASTC1.DA, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.FIXER, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLWG, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBWG1, 6, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NSA, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.OT_AMOUNT, 8, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.INCENTIVE, 5, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.HRA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PBF, 3, 'R',2) ; 
                  
                LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',2)||fnAlignZeroVal(C1.BASIC, 7, 'R',2)||' '||fnAlignZeroVal(C1.SE,6, 'C')||' '||fnAlignZeroVal(C1.DA, 8, 'R',2)||
                ' '||fnAlignZeroVal(C1.FIXER, 6, 'R',2)||' '||fnAlignZeroVal(C1.HOLWG, 6, 'R',2)||' '||fnAlignZeroVal(C1.FBWG1, 6, 'R',2)||
                ' '||fnAlignZeroVal(C1.NSA, 6, 'R',2)||' '||fnAlignZeroVal(C1.OT_AMOUNT, 8, 'R',2)||' '||fnAlignZeroVal(C1.INCENTIVE, 5, 'R',2)||
                ' '||fnAlignZeroVal(C1.HRA, 7, 'R',2)||' '||fnAlignZeroVal(C1.PBF, 3, 'R',2) ; 
                                         
                P_SLNO:=P_SLNO+1;                             
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                                        
                              
                --       0004) 
                LV_INSERTSTR := ' '; 
                P_SLNO:=P_SLNO+1;                     
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO); 
                
                LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ADJERNG, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LOC, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF, 7, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.FPF, 5, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ESI, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_RCV, 6, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_RCV, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ADJDEDN, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.HRENT, 6, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.P_TAX,4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LWF, 4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PCO, 4, 'R') ; 

                LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',3)||fnAlignZeroVal(C1.ADJERNG, 6, 'R')||' '||fnAlignZeroVal(C1.LOC, 6, 'R')||' '||fnAlignZeroVal(C1.PF, 7, 'R')||
                ' '||fnAlignZeroVal(C1.FPF, 5, 'R')||' '||fnAlignZeroVal(C1.ESI, 6, 'R')||' '||fnAlignZeroVal(C1.PF_LN_RCV, 6, 'R')||
                ' '||fnAlignZeroVal(C1.PL_INT_RCV, 6, 'R')||' '||fnAlignZeroVal(C1.ADJDEDN, 6, 'R')||' '||fnAlignZeroVal(C1.HRENT, 6, 'R')||
                ' '||fnAlignZeroVal(C1.P_TAX, 4, 'R')||' '||fnAlignZeroVal(C1.LWF, 4, 'R')||' '||fnAlignZeroVal(C1.PCO, 4, 'R') ; 
                                                
                P_SLNO:=P_SLNO+1;                             
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                 

                --       0005)  
                 LV_INSERTSTR := ' ';               
                   LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',4)||fnAlignZeroVal(LV_LASTC1.TSA_HEAD, 5, 'L')||LPAD(' ',61)||''||fnAlignZeroVal(LV_LASTC1.NETPAY_HEAD, 9, 'L');                  
                   LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',5)||fnAlignZeroVal(C1.TSA_HEAD, 5, 'L')||LPAD(' ',61)||''||fnAlignZeroVal(LV_LASTC1.NETPAY_HEAD, 9, 'L');                                   
                                                                 
                P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);                  
                
                
                LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.TSA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PF_OWN_YTD, 8, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_BAL, 8, 'R',1)||
                ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_BAL, 8, 'R')||' '||fnAlignZeroVal(LV_LASTC1.INST, 2, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GR_FOR_BONUS, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.GRD, 1, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GRERNG, 9, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.GRDEDN, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NETPAY, 9, 'R',2) ;
               
                LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',3)||fnAlignZeroVal(C1.TSA, 7, 'R',2)||' '||fnAlignZeroVal(C1.PF_OWN_YTD, 8, 'R',1)||' '||fnAlignZeroVal(C1.PF_LN_BAL, 8, 'R',1)||
                ' '||fnAlignZeroVal(C1.PL_INT_BAL, 8, 'R')||' '||fnAlignZeroVal(C1.INST, 2, 'R')||' '||fnAlignZeroVal(C1.GR_FOR_BONUS, 8, 'R',2)||
                ' '||fnAlignZeroVal(C1.GRD, 1, 'R')||' '||fnAlignZeroVal(C1.GRERNG, 9, 'R',2)||' '||fnAlignZeroVal(C1.GRDEDN, 8, 'R',2)||
                ' '||fnAlignZeroVal(C1.NETPAY, 9, 'R',2) ;               
                                                      
                P_SLNO:=P_SLNO+1;                             
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                    
                --'CHANGE -
--                LV_INSERTSTR := ' '; 
--                P_SLNO:=P_SLNO+1;                     
--                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);                 
--                                
            end if;   
            
                p_lsttoken:=P_RECORDNO;
                            
                if lv_count=1 then
                   p_lsttoken:=null;
                end if;

                lv_count:=lv_count+1;
                LV_LASTC1:=c1;    
                            
                lv_dept:=C1.DEPARTMENTCODE;
                lv_shift:=C1.SHIFT;
                   
            if lv_CountRecd=12 then    
                lv_newPage:= PKG_PRINT_TEXT.P_NEWPAGE;
                
                P_SLNO:=P_SLNO+1;   
                
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) 
                VALUES(P_SLNO,'***',lv_newPage);
                                                
                lv_CountRecd:=0;
            else                 
                 if mod(lv_CountRecd,2)=0 and lv_CountRecd<>0 then             
                     INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINETEXT) 
                       VALUES(P_SLNO,'');      
                       
                        --'CHANGE -
            -- LV_INSERTSTR := ' '; 
                P_SLNO:=P_SLNO+1;                     
--                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);      
                     INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINETEXT) 
                       VALUES(P_SLNO,''); 
                       
                 end if;   
            end if;           
                
           
            
         END LOOP;         
        
        if lv_count=1 then       
            
--            DBMS_OUTPUT.PUT_LINE('REC 3 : '||LV_LASTC1.RECORDNO);  
--            DBMS_OUTPUT.PUT_LINE('REC F : '||LV_LASTC1.PBF); 
--            DBMS_OUTPUT.PUT_LINE('REC O : '||LV_LASTC1.PCO); 
                          
            ---0001)     
            LV_INSERTSTR := ' ';
                IF LV_LASTC1.ATREWARD>0 THEN
                    LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',1)||fnAlignZeroVal(LV_LASTC1.ATREWARD_HEAD, 24, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ATREWARD, 5, 'C',2)||']';     
                ELSE
                    LV_INSERTSTR := LPAD(' ',32);                            
                END IF;               
        
                                            
                P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);  
                    
                                         
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.DEPT, 8, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SRLNO, 5, 'C')||' '||fnAlignZeroVal(LV_LASTC1.RECORDNO, 8, 'C')||
                ' '||fnAlignZeroVal(LV_LASTC1.WORKERNAME, 19, 'L')||' '||fnAlignZeroVal(LV_LASTC1.EBDESIG, 10, 'L')||' '||fnAlignZeroVal(LV_LASTC1.DSGCD, 3, 'L')||
                ' '||fnAlignZeroVal(LV_LASTC1.CT, 2, 'C')||' '||fnAlignZeroVal(LV_LASTC1.FORTNIGHTENDDATE, 10, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SLIPNO, 5, 'R'); 

            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                   
                   
            --       0002)    
            LV_INSERTSTR := ' '; 
            P_SLNO:=P_SLNO+1;                     
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                                           
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ESINO, 8, 'L')||' '||fnAlignZeroVal(LV_LASTC1.ATNDAY, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.ATNHRS, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NSHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBHR, 3, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.STLDAYS, 4, 'R',1)||
                ' '||fnAlignZeroVal(LV_LASTC1.STLPERIOD, 13, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.YTDDAYS, 11, 'R',1) ; 

            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                     
                    
            --       0003)   
              LV_INSERTSTR := ' '; 
                IF LV_LASTC1.FBWG>0 THEN
                    LV_INSERTSTR := LPAD(' ',49);                              
                ELSE
                    IF LV_LASTC1.FBWG1>0 THEN
                        LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',38)||fnAlignZeroVal(LV_LASTC1.ELECTRIC_HEAD, 10, 'L');
                    ELSE
                        LV_INSERTSTR := LPAD(' ',49);     
                    END IF;                              
                END IF;                                                     
                                                                 
                P_SLNO:=P_SLNO+1;                     
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);   
                 
                      
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.BASIC, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.SE, 6, 'C')||' '||fnAlignZeroVal(LV_LASTC1.DA, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.FIXER, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLWG, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBWG, 6, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NSA, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.OT_AMOUNT, 8, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.INCENTIVE, 5, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.HRA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PBF, 3, 'R',2) ; 
              

            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                                    
                          
            --       0004) 
            LV_INSERTSTR := ' '; 
            P_SLNO:=P_SLNO+1;                     
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
            
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ADJERNG, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LOC, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF, 7, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.FPF, 5, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ESI, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_RCV, 6, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_RCV, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ADJDEDN, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.HRENT, 6, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.P_TAX,4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LWF, 4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PCO, 4, 'R',2) ; 
                
            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
             
          
            --       0005) 
               LV_INSERTSTR := ' ';               
               LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',4)||fnAlignZeroVal(LV_LASTC1.TSA_HEAD, 5, 'L')||LPAD(' ',61)||''||fnAlignZeroVal(LV_LASTC1.NETPAY_HEAD, 9, 'L');                  
                                                                 
               P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO); 
                    
            
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.TSA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PF_OWN_YTD, 8, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_BAL, 8, 'R',1)||
                ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_BAL, 8, 'R')||' '||fnAlignZeroVal(LV_LASTC1.INST, 2, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GR_FOR_BONUS, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.GRD, 1, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GRERNG, 9, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.GRDEDN, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NETPAY, 9, 'R',2) ;

            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                                    
            lv_newPage:= PKG_PRINT_TEXT.P_NEWPAGE;
            lv_CountRecd:=0;
                         
            P_SLNO:=P_SLNO+1;   
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) 
            VALUES(P_SLNO,'***',lv_newPage);                        

            LV_LASTC1 := NULL   ;
            LV_COUNT:=-1; 
                        
        end if;                  
             
        COMMIT;
END;
/


DROP PROCEDURE NJMCL_WEB.PROC_RPTPAYSLIP_STL_NJMCL_1107;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_RPTPAYSLIP_STL_NJMCL_1107
--exec PROC_RPTPAYSLIP_STL_NJMCL ('NJ0001', '0002', '01/02/2020','15/02/2020','''19'',''20''','''2'',''3''','''01'',''02''','''B'',''P''','''06738'',''00023''')
(
    P_COMPANYCODE       VARCHAR2,
    P_DIVISIONCODE      VARCHAR2,
    P_FORTNIGHTSTDATE   VARCHAR2,
    P_FORTNIGHTENDDATE  VARCHAR2,
    P_DEPT              VARCHAR2,
    P_SHIFT             VARCHAR2,
    P_SECTION           VARCHAR2,    
    P_CATEGORY          VARCHAR2,
    P_TOKEN             VARCHAR2
)
AS 
/******************************************************************************
   NAME:      Ujjwal
   PURPOSE:   STL Pay slip - njmcl
   Date :     24.06.2020
            
   NOTES:
   Implementing for Naihati Jute Mills 
******************************************************************************/

    LV_SQLSTR           VARCHAR2(32000); 
    LV_INSERTSTR VARCHAR2(4000); 
    LV_COMPANYNAME VARCHAR2(100);
    LV_SRL NUMBER(5); 
    LV_CATEGORYCODE VARCHAR2(100); 
    LV_DEPARTMENTNAME  VARCHAR2(100);
    LV_CNT      NUMBER(10);
    LV_PAGENO  NUMBER(10);    
    P_INT1  NUMBER(20);
    P_SLNO NUMBER:=0;
    P_RECORDNO NUMBER:=0;
    p_lsttoken varchar2(20);
    
    lv_dept varchar2(20);
    lv_shift varchar2(20);    
    lv_lstDept varchar2(20);
    
    lv_section varchar2(20);
    lv_newPage varchar2(20);
    
    lv_count number:=0;
    LV_LASTC1 GTT_PAYSLIP_NJMCL%rowtype; 
    
    lv_CountRecd number:=0;
    lv_lstCountRecd number:=0;
    lv_recdCount number:=0;
 
BEGIN              
        DELETE FROM GTT_TEXT_PAYSLIPNJMCL;
        DELETE FROM GTT_PAYSLIP_NJMCL;
                         
        LV_SQLSTR := ' INSERT INTO GTT_PAYSLIP_NJMCL
            (SLIPNO, COMPANYCODE, DIVISIONCODE, FORTNIGHTENDDATE, DEPT, SRLNO, RECORDNO, WORKERNAME, EBDESIG, DSGCD, CT,ESINO,ATNHRS,STLDAYS,
            OTHR,DA,HRA, PBF,FPF,PF, ESI, P_TAX, PCO, GRERNG, GRDEDN, NETPAY,DEPARTMENTCODE,WORKERCATEGORYCODE,  WORKERCATEGORYNAME, SECTION, SHIFT)
            
            SELECT ROW_NUMBER() OVER(ORDER BY DEPARTMENTCODE,SECTIONCODE, SHIFTCODE, RECORDNO) SLIPNO,COMPANYCODE, DIVISIONCODE,
                TO_CHAR(PAYMENTDATE,''DD-MM-YY'')PAYMENTDATE, DEPT, SRLNO, RECORDNO, WORKERNAME,EBDESIG, DSGCD, CT, ESINO, ATNHRS, 
                STLDAYS, OTHR, DA, HRA,  PBF, FPF, PF,ESI, P_TAX,PCO,GRERNG, GRDEDN,NETPAY,DEPARTMENTCODE, WORKERCATEGORYCODE,  
                WORKERCATEGORYNAME, SECTIONCODE, SHIFTCODE
            FROM VW_WPSPAYSLIP_STL 
            WHERE COMPANYCODE='''||P_COMPANYCODE||'''
                AND DIVISIONCODE='''||P_DIVISIONCODE||'''
                AND PAYMENTDATE>=TO_DATE('''||P_FORTNIGHTSTDATE||''',''DD/MM/YYYY'')
                AND PAYMENTDATE<=TO_DATE('''||P_FORTNIGHTENDDATE||''',''DD/MM/YYYY'')         
                
       --       AND RECORDNO IN (''04202'',''04189'',''00060'',''05101'') 
       --       AND RECORDNO IN (''00053'',''95063'',''95013'',''95021'')  
       --   AND RECORDNO IN (''61257'',''61294'',''61296'')  
       --   AND RECORDNO IN (''64853'',''01507'',''01441'')  
       --   and departmentcode in (''01'',''04'')     
               ' ;
                
        if p_dept is not null then
           lv_sqlstr := lv_sqlstr||chr(10)||' AND DEPARTMENTCODE IN ('||p_dept||')'; 
        end if;        
       
        if p_section is not null then
           lv_sqlstr := lv_sqlstr||chr(10)||' AND SECTIONCODE IN ('||p_section||')'; 
        end if;        
       
        if p_category is not null then
           lv_sqlstr := lv_sqlstr||chr(10)||' AND WORKERCATEGORYCODE IN ('||p_category||')'; 
        end if;
       
        if p_shift is not null then
           lv_sqlstr := lv_sqlstr||chr(10)||' AND  decode(SHIFTCODE,''A'',''1'',''B'',''2'',''C'',''3'',''1'') IN ('||p_shift||')'; 
        end if;
       
        if p_token is not null then
           lv_sqlstr := lv_sqlstr||chr(10)||' AND RECORDNO IN ('||p_token||')'; 
        end if;
                          
      
       DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);   
        EXECUTE IMMEDIATE LV_SQLSTR;        
        
        /*******************Check Data Exist*******************************/
        SELECT COUNT(*) INTO LV_CNT  FROM GTT_PAYSLIP_NJMCL ;
        
        IF LV_CNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20111,'NO DATA FOUND !!!!!');
            RETURN;        
        END IF;
        /*******************End Check Data Exist***************************/           
              
                        
        DELETE FROM GTT_TEXT_REPORT;
        
        LV_PAGENO := 0;
        P_INT1 := 0;
        LV_SRL := 0;
        
        p_lsttoken:=null;        
      
        
        FOR C1 IN (SELECT * FROM GTT_PAYSLIP_NJMCL ORDER BY SLIPNO)
        LOOP
        
        P_RECORDNO:=P_RECORDNO+1;           
        
            IF lv_dept IS NULL THEN
                lv_dept := C1.DEPARTMENTCODE ;
            END IF;
            
            IF lv_shift IS NULL THEN
                lv_shift := C1.SHIFT;
            END IF;
                  
            lv_CountRecd :=lv_CountRecd +1;        
          
            if NVL(lv_dept,'NA') <> C1.DEPARTMENTCODE or NVL(lv_shift,'NA') <> C1.SHIFT then
                          
                
                
                select count(*) into lv_recdCount from GTT_TEXT_PAYSLIPNJMCL WHERE TOKEN=LV_LASTC1.RECORDNO;
                   
            
                if lv_recdCount<1 then 
                                    
                    --DBMS_OUTPUT.PUT_LINE('REC 11 : '||lv_recdCount|| '....................'||LV_LASTC1.RECORDNO);  
                
                    ---0001)  
                    LV_INSERTSTR := ' ';
                    IF LV_LASTC1.ATREWARD>0 THEN
                        LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',1)||fnAlignZeroVal(LV_LASTC1.ATREWARD_HEAD, 24, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ATREWARD, 5, 'C',2)||']';     
                    ELSE
                        LV_INSERTSTR := LPAD(' ',32);                            
                    END IF;       
                                                
                    P_SLNO:=P_SLNO+1;                     
                        INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                        VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);  
                        
                    
                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.DEPT, 8, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SRLNO, 5, 'C')||' '||fnAlignZeroVal(LV_LASTC1.RECORDNO, 8, 'C')||
                    ' '||fnAlignZeroVal(LV_LASTC1.WORKERNAME, 19, 'L')||' '||fnAlignZeroVal(LV_LASTC1.EBDESIG, 10, 'L')||' '||fnAlignZeroVal(LV_LASTC1.DSGCD, 3, 'L')||
                    ' '||fnAlignZeroVal(LV_LASTC1.CT, 2, 'C')||' '||fnAlignZeroVal(LV_LASTC1.FORTNIGHTENDDATE, 10, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SLIPNO, 5, 'R'); 
                                       
                    P_SLNO:=P_SLNO+1;                             
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                               
                                
                    --       0002)    
                    LV_INSERTSTR := ' '; 
                    P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);  
                                                   
                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ESINO, 8, 'L')||' '||fnAlignZeroVal(LV_LASTC1.ATNDAY, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.ATNHRS, 8, 'R',2)||
                    ' '||fnAlignZeroVal(LV_LASTC1.NSHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBHR, 3, 'R',2)||
                    ' '||fnAlignZeroVal(LV_LASTC1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.STLDAYS, 4, 'R',1)||
                    ' '||fnAlignZeroVal(LV_LASTC1.STLPERIOD, 13, 'R')||' '||fnAlignZeroVal(LV_LASTC1.YTDDAYS, 11, 'R',1) ; 

                    P_SLNO:=P_SLNO+1;                             
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                                 
                   
                    --       0003)   
                     LV_INSERTSTR := ' '; 
                    IF LV_LASTC1.FBWG>0 THEN
                        LV_INSERTSTR := LPAD(' ',49);                              
                    ELSE
                        IF LV_LASTC1.FBWG1>0 THEN
                            LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',38)||fnAlignZeroVal(LV_LASTC1.ELECTRIC_HEAD, 10, 'L');
                        ELSE
                            LV_INSERTSTR := LPAD(' ',49);     
                        END IF;                              
                    END IF;                                                     
                                                                     
                    P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);  
                     
                              
                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.BASIC, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.SE, 6, 'C')||' '||fnAlignZeroVal(LV_LASTC1.DA, 8, 'R',2)||
                    ' '||fnAlignZeroVal(LV_LASTC1.FIXER, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLWG, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBWG, 6, 'R',2)||
                    ' '||fnAlignZeroVal(LV_LASTC1.NSA, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.OT_AMOUNT, 8, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.INCENTIVE, 5, 'R',2)||
                    ' '||fnAlignZeroVal(LV_LASTC1.HRA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PBF, 3, 'R',2) ; 
               
                    P_SLNO:=P_SLNO+1;                             
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                                                
                                      
                    --       0004) 
                    LV_INSERTSTR := ' '; 
                    P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);  
                    
                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ADJERNG, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LOC, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF, 7, 'R')||
                    ' '||fnAlignZeroVal(LV_LASTC1.FPF, 5, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ESI, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_RCV, 6, 'R')||
                    ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_RCV, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ADJDEDN, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.HRENT, 6, 'R')||
                    ' '||fnAlignZeroVal(LV_LASTC1.P_TAX,4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LWF, 5, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PCO, 4, 'R') ; 
                    
                    P_SLNO:=P_SLNO+1;                             
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                         

                    --       0005) 
                       LV_INSERTSTR := ' ';               
                       LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',4)||fnAlignZeroVal(LV_LASTC1.TSA_HEAD, 5, 'L')||LPAD(' ',61)||''||fnAlignZeroVal(LV_LASTC1.NETPAY_HEAD, 9, 'L');                  
                                                                     
                    P_SLNO:=P_SLNO+1;                     
                        INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                        VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO); 
                    
                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.TSA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PF_OWN_YTD, 8, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_BAL, 8, 'R',1)||
                    ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_BAL, 8, 'R')||' '||fnAlignZeroVal(LV_LASTC1.INST, 2, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GR_FOR_BONUS, 8, 'R',2)||
                    ' '||fnAlignZeroVal(LV_LASTC1.GRD, 1, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GRERNG, 9, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.GRDEDN, 8, 'R',2)||
                    ' '||fnAlignZeroVal(LV_LASTC1.NETPAY, 9, 'R',2);
                                                        
                    P_SLNO:=P_SLNO+1;                             
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                                    
                    lv_newPage:= PKG_PRINT_TEXT.P_NEWPAGE;
                    lv_CountRecd:=0;
                    
                    P_SLNO:=P_SLNO+1;                    
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) 
                    VALUES(P_SLNO,'***',lv_newPage);
                          
                    LV_LASTC1 := NULL   ;
                    LV_COUNT:=0; 
                    
                end if;                   
            end if;                              
         
      
            if p_lsttoken is NOT null and LV_COUNT=1 and p_lsttoken<>c1.recordno then     
                LV_COUNT:=-1;                              
                                      
--                DBMS_OUTPUT.PUT_LINE('REC 2 : '||LV_LASTC1.RECORDNO);  
--                DBMS_OUTPUT.PUT_LINE('REC 2 : '||C1.RECORDNO);  
                                
                --      0001)    
                LV_INSERTSTR := ' ';
                IF LV_LASTC1.ATREWARD>0 THEN
                    LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',1)||fnAlignZeroVal(LV_LASTC1.ATREWARD_HEAD, 24, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ATREWARD, 5, 'C',2)||']';     
                ELSE
                    LV_INSERTSTR := LPAD(' ',32);                            
                END IF;
                
                IF C1.ATREWARD>0 THEN
                   LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',55)||fnAlignZeroVal(C1.ATREWARD_HEAD, 24, 'R')||' '||fnAlignZeroVal(C1.ATREWARD, 5, 'C',2)||']';                                    
                END IF;        
                                            
                P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);                                                      
                
                          
                LV_INSERTSTR := fnAlignZeroVal(LV_LASTC1.DEPT, 8, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SRLNO, 5, 'C')||' '||fnAlignZeroVal(LV_LASTC1.RECORDNO, 8, 'C')||
                ' '||fnAlignZeroVal(LV_LASTC1.WORKERNAME, 19, 'L')||' '||fnAlignZeroVal(LV_LASTC1.EBDESIG, 10, 'L')||' '||fnAlignZeroVal(LV_LASTC1.DSGCD, 3, 'L')||
                ' '||fnAlignZeroVal(LV_LASTC1.CT, 2, 'C')||' '||fnAlignZeroVal(LV_LASTC1.FORTNIGHTENDDATE, 10, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SLIPNO, 5, 'R'); 
                                
                LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',2)||fnAlignZeroVal(C1.DEPT, 8, 'C')||' '||fnAlignZeroVal(C1.SRLNO, 5, 'C')||' '||fnAlignZeroVal(C1.RECORDNO, 8, 'C')||
                ' '||fnAlignZeroVal(C1.WORKERNAME, 19, 'L')||' '||fnAlignZeroVal(C1.EBDESIG, 10, 'L')||' '||fnAlignZeroVal(C1.DSGCD, 3, 'L')||
                ' '||fnAlignZeroVal(C1.CT, 2, 'C')||' '||fnAlignZeroVal(C1.FORTNIGHTENDDATE, 10, 'C')||' '||fnAlignZeroVal(C1.SLIPNO, 5, 'R'); 
                           
                P_SLNO:=P_SLNO+1;                     
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT,LV_LASTC1.RECORDNO||':'||C1.RECORDNO);
                             

                --       0002)        
                LV_INSERTSTR := ' '; 
                P_SLNO:=P_SLNO+1;                     
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO); 
                                           
                LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ESINO, 8, 'L')||' '||fnAlignZeroVal(LV_LASTC1.ATNDAY, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.ATNHRS, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NSHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBHR, 3, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.STLDAYS, 4, 'R',1)||
                ' '||fnAlignZeroVal(LV_LASTC1.STLPERIOD, 13, 'R')||' '||fnAlignZeroVal(LV_LASTC1.YTDDAYS, 11, 'R',1) ; 

                LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',2)||fnAlignZeroVal(C1.ESINO, 8, 'L')||' '||fnAlignZeroVal(C1.ATNDAY, 5, 'R',1)||' '||fnAlignZeroVal(C1.ATNHRS, 8, 'R',2)||
                ' '||fnAlignZeroVal(C1.NSHR, 4, 'R',2)||' '||fnAlignZeroVal(C1.HOLHR, 4, 'R',2)||' '||fnAlignZeroVal(C1.FBHR, 3, 'R',2)||
                ' '||fnAlignZeroVal(C1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(C1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(C1.STLDAYS, 4, 'R',1)||
                ' '||fnAlignZeroVal(C1.STLPERIOD, 13, 'R')||' '||fnAlignZeroVal(C1.YTDDAYS, 11, 'R',1) ; 
                                                       
                P_SLNO:=P_SLNO+1;                             
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                         
                         
                --       0003)  
                LV_INSERTSTR := ' '; 
                IF LV_LASTC1.FBWG>0 THEN
                    LV_INSERTSTR := LPAD(' ',49);                              
                ELSE
                    IF LV_LASTC1.FBWG1>0 THEN
                        LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',38)||fnAlignZeroVal(LV_LASTC1.ELECTRIC_HEAD, 10, 'L');
                    ELSE
                        LV_INSERTSTR := LPAD(' ',49);     
                    END IF;                              
                END IF;
                
                IF C1.FBWG>0 THEN
                 LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',32);                                
                ELSE
                    IF LV_LASTC1.FBWG1>0 THEN
                        LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',69)||fnAlignZeroVal(LV_LASTC1.ELECTRIC_HEAD, 10, 'L');           
                    ELSE
                        LV_INSERTSTR := LPAD(' ',49);     
                    END IF;                                                        
                END IF;                                         
                                                                 
                P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);                  
                 
                        
                LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.BASIC, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.SE, 6, 'C')||' '||fnAlignZeroVal(LV_LASTC1.DA, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.FIXER, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLWG, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBWG1, 6, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NSA, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.OT_AMOUNT, 8, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.INCENTIVE, 5, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.HRA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PBF, 3, 'R',2) ; 
                  
                LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',2)||fnAlignZeroVal(C1.BASIC, 7, 'R',2)||' '||fnAlignZeroVal(C1.SE,6, 'C')||' '||fnAlignZeroVal(C1.DA, 8, 'R',2)||
                ' '||fnAlignZeroVal(C1.FIXER, 6, 'R',2)||' '||fnAlignZeroVal(C1.HOLWG, 6, 'R',2)||' '||fnAlignZeroVal(C1.FBWG1, 6, 'R',2)||
                ' '||fnAlignZeroVal(C1.NSA, 6, 'R',2)||' '||fnAlignZeroVal(C1.OT_AMOUNT, 8, 'R',2)||' '||fnAlignZeroVal(C1.INCENTIVE, 5, 'R',2)||
                ' '||fnAlignZeroVal(C1.HRA, 7, 'R',2)||' '||fnAlignZeroVal(C1.PBF, 3, 'R',2) ; 
                                         
                P_SLNO:=P_SLNO+1;                             
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                                        
                              
                --       0004) 
                LV_INSERTSTR := ' '; 
                P_SLNO:=P_SLNO+1;                     
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO); 
                
                LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ADJERNG, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LOC, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF, 7, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.FPF, 5, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ESI, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_RCV, 6, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_RCV, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ADJDEDN, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.HRENT, 6, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.P_TAX,4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LWF, 4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PCO, 4, 'R') ; 

                LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',3)||fnAlignZeroVal(C1.ADJERNG, 6, 'R')||' '||fnAlignZeroVal(C1.LOC, 6, 'R')||' '||fnAlignZeroVal(C1.PF, 7, 'R')||
                ' '||fnAlignZeroVal(C1.FPF, 5, 'R')||' '||fnAlignZeroVal(C1.ESI, 6, 'R')||' '||fnAlignZeroVal(C1.PF_LN_RCV, 6, 'R')||
                ' '||fnAlignZeroVal(C1.PL_INT_RCV, 6, 'R')||' '||fnAlignZeroVal(C1.ADJDEDN, 6, 'R')||' '||fnAlignZeroVal(C1.HRENT, 6, 'R')||
                ' '||fnAlignZeroVal(C1.P_TAX, 4, 'R')||' '||fnAlignZeroVal(C1.LWF, 4, 'R')||' '||fnAlignZeroVal(C1.PCO, 4, 'R') ; 
                                                
                P_SLNO:=P_SLNO+1;                             
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                 

                --       0005)  
                 LV_INSERTSTR := ' ';               
                   LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',4)||fnAlignZeroVal(LV_LASTC1.TSA_HEAD, 5, 'L')||LPAD(' ',61)||''||fnAlignZeroVal(LV_LASTC1.NETPAY_HEAD, 9, 'L');                  
                   LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',5)||fnAlignZeroVal(C1.TSA_HEAD, 5, 'L')||LPAD(' ',61)||''||fnAlignZeroVal(LV_LASTC1.NETPAY_HEAD, 9, 'L');                                   
                                                                 
                P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);                  
                
                
                LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.TSA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PF_OWN_YTD, 8, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_BAL, 8, 'R',1)||
                ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_BAL, 8, 'R')||' '||fnAlignZeroVal(LV_LASTC1.INST, 2, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GR_FOR_BONUS, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.GRD, 1, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GRERNG, 9, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.GRDEDN, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NETPAY, 9, 'R',2) ;
               
                LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',3)||fnAlignZeroVal(C1.TSA, 7, 'R',2)||' '||fnAlignZeroVal(C1.PF_OWN_YTD, 8, 'R',1)||' '||fnAlignZeroVal(C1.PF_LN_BAL, 8, 'R',1)||
                ' '||fnAlignZeroVal(C1.PL_INT_BAL, 8, 'R')||' '||fnAlignZeroVal(C1.INST, 2, 'R')||' '||fnAlignZeroVal(C1.GR_FOR_BONUS, 8, 'R',2)||
                ' '||fnAlignZeroVal(C1.GRD, 1, 'R')||' '||fnAlignZeroVal(C1.GRERNG, 9, 'R',2)||' '||fnAlignZeroVal(C1.GRDEDN, 8, 'R',2)||
                ' '||fnAlignZeroVal(C1.NETPAY, 9, 'R',2) ;               
                                                      
                P_SLNO:=P_SLNO+1;                             
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                    
                --'CHANGE -
--                LV_INSERTSTR := ' '; 
--                P_SLNO:=P_SLNO+1;                     
--                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);                 
--                                
            end if;   
            
                p_lsttoken:=P_RECORDNO;
                            
                if lv_count=1 then
                   p_lsttoken:=null;
                end if;

                lv_count:=lv_count+1;
                LV_LASTC1:=c1;    
                            
                lv_dept:=C1.DEPARTMENTCODE;
                lv_shift:=C1.SHIFT;
                   
            if lv_CountRecd=12 then    
                lv_newPage:= PKG_PRINT_TEXT.P_NEWPAGE;
                
                P_SLNO:=P_SLNO+1;   
                
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) 
                VALUES(P_SLNO,'***',lv_newPage);
                                                
                lv_CountRecd:=0;
            else                 
                 if mod(lv_CountRecd,2)=0 and lv_CountRecd<>0 then             
                     INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINETEXT) 
                       VALUES(P_SLNO,'');      
                       
                        --'CHANGE -
            -- LV_INSERTSTR := ' '; 
                P_SLNO:=P_SLNO+1;                     
--                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);      
                     INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINETEXT) 
                       VALUES(P_SLNO,''); 
                       
                 end if;   
            end if;           
                
           
            
         END LOOP;         
        
        if lv_count=1 then       
            
--            DBMS_OUTPUT.PUT_LINE('REC 3 : '||LV_LASTC1.RECORDNO);  
--            DBMS_OUTPUT.PUT_LINE('REC F : '||LV_LASTC1.PBF); 
--            DBMS_OUTPUT.PUT_LINE('REC O : '||LV_LASTC1.PCO); 
                          
            ---0001)     
            LV_INSERTSTR := ' ';
                IF LV_LASTC1.ATREWARD>0 THEN
                    LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',1)||fnAlignZeroVal(LV_LASTC1.ATREWARD_HEAD, 24, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ATREWARD, 5, 'C',2)||']';     
                ELSE
                    LV_INSERTSTR := LPAD(' ',32);                            
                END IF;               
        
                                            
                P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);  
                    
                                         
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.DEPT, 8, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SRLNO, 5, 'C')||' '||fnAlignZeroVal(LV_LASTC1.RECORDNO, 8, 'C')||
                ' '||fnAlignZeroVal(LV_LASTC1.WORKERNAME, 19, 'L')||' '||fnAlignZeroVal(LV_LASTC1.EBDESIG, 10, 'L')||' '||fnAlignZeroVal(LV_LASTC1.DSGCD, 3, 'L')||
                ' '||fnAlignZeroVal(LV_LASTC1.CT, 2, 'C')||' '||fnAlignZeroVal(LV_LASTC1.FORTNIGHTENDDATE, 10, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SLIPNO, 5, 'R'); 

            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                   
                   
            --       0002)    
            LV_INSERTSTR := ' '; 
            P_SLNO:=P_SLNO+1;                     
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                                           
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ESINO, 8, 'L')||' '||fnAlignZeroVal(LV_LASTC1.ATNDAY, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.ATNHRS, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NSHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBHR, 3, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.STLDAYS, 4, 'R',1)||
                ' '||fnAlignZeroVal(LV_LASTC1.STLPERIOD, 13, 'R')||' '||fnAlignZeroVal(LV_LASTC1.YTDDAYS, 11, 'R',1) ; 

            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                     
                    
            --       0003)   
              LV_INSERTSTR := ' '; 
                IF LV_LASTC1.FBWG>0 THEN
                    LV_INSERTSTR := LPAD(' ',49);                              
                ELSE
                    IF LV_LASTC1.FBWG1>0 THEN
                        LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',38)||fnAlignZeroVal(LV_LASTC1.ELECTRIC_HEAD, 10, 'L');
                    ELSE
                        LV_INSERTSTR := LPAD(' ',49);     
                    END IF;                              
                END IF;                                                     
                                                                 
                P_SLNO:=P_SLNO+1;                     
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);   
                 
                      
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.BASIC, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.SE, 6, 'C')||' '||fnAlignZeroVal(LV_LASTC1.DA, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.FIXER, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLWG, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBWG, 6, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NSA, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.OT_AMOUNT, 8, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.INCENTIVE, 5, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.HRA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PBF, 3, 'R',2) ; 
              

            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                                    
                          
            --       0004) 
            LV_INSERTSTR := ' '; 
            P_SLNO:=P_SLNO+1;                     
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
            
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ADJERNG, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LOC, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF, 7, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.FPF, 5, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ESI, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_RCV, 6, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_RCV, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ADJDEDN, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.HRENT, 6, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.P_TAX,4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LWF, 4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PCO, 4, 'R',2) ; 
                
            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
             
          
            --       0005) 
               LV_INSERTSTR := ' ';               
               LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',4)||fnAlignZeroVal(LV_LASTC1.TSA_HEAD, 5, 'L')||LPAD(' ',61)||''||fnAlignZeroVal(LV_LASTC1.NETPAY_HEAD, 9, 'L');                  
                                                                 
               P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO); 
                    
            
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.TSA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PF_OWN_YTD, 8, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_BAL, 8, 'R',1)||
                ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_BAL, 8, 'R')||' '||fnAlignZeroVal(LV_LASTC1.INST, 2, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GR_FOR_BONUS, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.GRD, 1, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GRERNG, 9, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.GRDEDN, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NETPAY, 9, 'R',2) ;

            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                                    
            lv_newPage:= PKG_PRINT_TEXT.P_NEWPAGE;
            lv_CountRecd:=0;
                         
            P_SLNO:=P_SLNO+1;   
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) 
            VALUES(P_SLNO,'***',lv_newPage);                        

            LV_LASTC1 := NULL   ;
            LV_COUNT:=-1; 
                        
        end if;                  
             
        COMMIT;
END;
/


DROP PROCEDURE NJMCL_WEB.PROC_RPTPAYSLIP_STL_NJMCL_1407;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_RPTPAYSLIP_STL_NJMCL_1407
--exec PROC_RPTPAYSLIP_STL_NJMCL ('NJ0001', '0002', '01/02/2020','15/02/2020','''19'',''20''','''2'',''3''','''01'',''02''','''B'',''P''','''06738'',''00023''')
(
    P_COMPANYCODE       VARCHAR2,
    P_DIVISIONCODE      VARCHAR2,
    P_FORTNIGHTSTDATE   VARCHAR2,
    P_FORTNIGHTENDDATE  VARCHAR2,
    P_DEPT              VARCHAR2,
    P_SHIFT             VARCHAR2,
    P_SECTION           VARCHAR2,    
    P_CATEGORY          VARCHAR2,
    P_TOKEN             VARCHAR2
)
AS 
/******************************************************************************
   NAME:      Ujjwal
   PURPOSE:   STL Pay slip - njmcl
   Date :     24.06.2020
            
   NOTES:
   Implementing for Naihati Jute Mills 
******************************************************************************/

    LV_SQLSTR           VARCHAR2(32000); 
    LV_INSERTSTR VARCHAR2(4000); 
    LV_COMPANYNAME VARCHAR2(100);
    LV_SRL NUMBER(5); 
    LV_CATEGORYCODE VARCHAR2(100); 
    LV_DEPARTMENTNAME  VARCHAR2(100);
    LV_CNT      NUMBER(10);
    LV_PAGENO  NUMBER(10);    
    P_INT1  NUMBER(20);
    P_SLNO NUMBER:=0;
    P_RECORDNO NUMBER:=0;
    p_lsttoken varchar2(20);
    
    lv_dept varchar2(20);
    lv_shift varchar2(20);    
    lv_lstDept varchar2(20);
    
    lv_section varchar2(20);
    lv_newPage varchar2(20);
    
    lv_count number:=0;
    LV_LASTC1 GTT_PAYSLIP_NJMCL%rowtype; 
    
    lv_CountRecd number:=0;
    lv_lstCountRecd number:=0;
    lv_recdCount number:=0;
 
BEGIN              
        DELETE FROM GTT_TEXT_PAYSLIPNJMCL;
        DELETE FROM GTT_PAYSLIP_NJMCL;
                         
        LV_SQLSTR := ' INSERT INTO GTT_PAYSLIP_NJMCL
            (SLIPNO, COMPANYCODE, DIVISIONCODE, FORTNIGHTENDDATE, DEPT, SRLNO, RECORDNO, WORKERNAME, EBDESIG, DSGCD, CT,ESINO,ATNHRS,
            STLDAYS,STLPERIOD,OTHR,DA,HRA, PBF,FPF,PF, ESI, P_TAX, PCO, GRERNG, GRDEDN, NETPAY,DEPARTMENTCODE,WORKERCATEGORYCODE,  WORKERCATEGORYNAME, SECTION, SHIFT)
            
            SELECT ROW_NUMBER() OVER(ORDER BY DEPARTMENTCODE,SECTIONCODE, SHIFTCODE, RECORDNO) SLIPNO,COMPANYCODE, DIVISIONCODE,
                TO_CHAR(PAYMENTDATE,''DD-MM-YY'')PAYMENTDATE, DEPT, SRLNO, RECORDNO, WORKERNAME,EBDESIG, DSGCD, CT, ESINO, ATNHRS, 
                STLDAYS, STLPERIOD, OTHR, DA, HRA,  PBF, FPF, PF,ESI, P_TAX,PCO,GRERNG, GRDEDN,NETPAY,DEPARTMENTCODE, WORKERCATEGORYCODE,  
                WORKERCATEGORYNAME, SECTIONCODE, SHIFTCODE
            FROM VW_WPSPAYSLIP_STL 
            WHERE COMPANYCODE='''||P_COMPANYCODE||'''
                AND DIVISIONCODE='''||P_DIVISIONCODE||'''
                AND PAYMENTDATE>=TO_DATE('''||P_FORTNIGHTSTDATE||''',''DD/MM/YYYY'')
                AND PAYMENTDATE<=TO_DATE('''||P_FORTNIGHTENDDATE||''',''DD/MM/YYYY'')         
                
       --       AND RECORDNO IN (''04202'',''04189'',''00060'',''05101'') 
       --       AND RECORDNO IN (''00053'',''95063'',''95013'',''95021'')  
       --   AND RECORDNO IN (''61257'',''61294'',''61296'')  
       --   AND RECORDNO IN (''64853'',''01507'',''01441'')  
       --   and departmentcode in (''01'',''04'')     
               ' ;
                
        if p_dept is not null then
           lv_sqlstr := lv_sqlstr||chr(10)||' AND DEPARTMENTCODE IN ('||p_dept||')'; 
        end if;        
       
        if p_section is not null then
           lv_sqlstr := lv_sqlstr||chr(10)||' AND SECTIONCODE IN ('||p_section||')'; 
        end if;        
       
        if p_category is not null then
           lv_sqlstr := lv_sqlstr||chr(10)||' AND WORKERCATEGORYCODE IN ('||p_category||')'; 
        end if;
       
        if p_shift is not null then
           lv_sqlstr := lv_sqlstr||chr(10)||' AND  decode(SHIFTCODE,''A'',''1'',''B'',''2'',''C'',''3'',''1'') IN ('||p_shift||')'; 
        end if;
       
        if p_token is not null then
           lv_sqlstr := lv_sqlstr||chr(10)||' AND RECORDNO IN ('||p_token||')'; 
        end if;
                          
      
       DBMS_OUTPUT.PUT_LINE('query : '||LV_SQLSTR);   
        EXECUTE IMMEDIATE LV_SQLSTR;        
        
        /*******************Check Data Exist*******************************/
        SELECT COUNT(*) INTO LV_CNT  FROM GTT_PAYSLIP_NJMCL ;
        
        IF LV_CNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20111,'NO DATA FOUND !!!!!');
            RETURN;        
        END IF;
        /*******************End Check Data Exist***************************/           
              
                        
        DELETE FROM GTT_TEXT_REPORT;
        
        LV_PAGENO := 0;
        P_INT1 := 0;
        LV_SRL := 0;
        
        p_lsttoken:=null;        
      
        
        FOR C1 IN (SELECT * FROM GTT_PAYSLIP_NJMCL ORDER BY SLIPNO)
        LOOP
        
        P_RECORDNO:=P_RECORDNO+1;           
        
            IF lv_dept IS NULL THEN
                lv_dept := C1.DEPARTMENTCODE ;
            END IF;
            
            IF lv_shift IS NULL THEN
                lv_shift := C1.SHIFT;
            END IF;
                  
            lv_CountRecd :=lv_CountRecd +1;        
          
         --   if NVL(lv_dept,'NA') <> C1.DEPARTMENTCODE or NVL(lv_shift,'NA') <> C1.SHIFT then                          
                
                
                select count(*) into lv_recdCount from GTT_TEXT_PAYSLIPNJMCL WHERE TOKEN=LV_LASTC1.RECORDNO;
                   
            
--                if lv_recdCount<1 then 
--                                    
--                    --DBMS_OUTPUT.PUT_LINE('REC 11 : '||lv_recdCount|| '....................'||LV_LASTC1.RECORDNO);  
--                
--                    ---0001)  
--                    LV_INSERTSTR := ' ';
--                    IF LV_LASTC1.ATREWARD>0 THEN
--                        LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',1)||fnAlignZeroVal(LV_LASTC1.ATREWARD_HEAD, 24, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ATREWARD, 5, 'C',2)||']';     
--                    ELSE
--                        LV_INSERTSTR := LPAD(' ',32);                            
--                    END IF;       
--                                                
--                    P_SLNO:=P_SLNO+1;                     
--                        INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                        VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);  
--                        
--                    
--                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.DEPT, 8, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SRLNO, 5, 'C')||' '||fnAlignZeroVal(LV_LASTC1.RECORDNO, 8, 'C')||
--                    ' '||fnAlignZeroVal(LV_LASTC1.WORKERNAME, 19, 'L')||' '||fnAlignZeroVal(LV_LASTC1.EBDESIG, 10, 'L')||' '||fnAlignZeroVal(LV_LASTC1.DSGCD, 3, 'L')||
--                    ' '||fnAlignZeroVal(LV_LASTC1.CT, 2, 'C')||' '||fnAlignZeroVal(LV_LASTC1.FORTNIGHTENDDATE, 10, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SLIPNO, 5, 'R'); 
--                                       
--                    P_SLNO:=P_SLNO+1;                             
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
--                               
--                                
--                    --       0002)    
--                    LV_INSERTSTR := ' '; 
--                    P_SLNO:=P_SLNO+1;                     
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);  
--                                                   
--                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ESINO, 8, 'L')||' '||fnAlignZeroVal(LV_LASTC1.ATNDAY, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.ATNHRS, 8, 'R',2)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.NSHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBHR, 3, 'R',2)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.STLDAYS, 4, 'R',1)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.STLPERIOD, 13, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.YTDDAYS, 11, 'R',1) ; 
--
--                    P_SLNO:=P_SLNO+1;                             
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
--                                 
--                   
--                    --       0003)   
--                     LV_INSERTSTR := ' '; 
--                    IF LV_LASTC1.FBWG>0 THEN
--                        LV_INSERTSTR := LPAD(' ',49);                              
--                    ELSE
--                        IF LV_LASTC1.FBWG1>0 THEN
--                            LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',38)||fnAlignZeroVal(LV_LASTC1.ELECTRIC_HEAD, 10, 'L');
--                        ELSE
--                            LV_INSERTSTR := LPAD(' ',49);     
--                        END IF;                              
--                    END IF;                                                     
--                                                                     
--                    P_SLNO:=P_SLNO+1;                     
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);  
--                     
--                              
--                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.BASIC, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.SE, 6, 'C')||' '||fnAlignZeroVal(LV_LASTC1.DA, 8, 'R',2)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.FIXER, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLWG, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBWG, 6, 'R',2)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.NSA, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.OT_AMOUNT, 8, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.INCENTIVE, 5, 'R',2)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.HRA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PBF, 3, 'R',2) ; 
--               
--                    P_SLNO:=P_SLNO+1;                             
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
--                                                
--                                      
--                    --       0004) 
--                    LV_INSERTSTR := ' '; 
--                    P_SLNO:=P_SLNO+1;                     
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);  
--                    
--                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ADJERNG, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LOC, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF, 7, 'R')||
--                    ' '||fnAlignZeroVal(LV_LASTC1.FPF, 5, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ESI, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_RCV, 6, 'R')||
--                    ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_RCV, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ADJDEDN, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.HRENT, 6, 'R')||
--                    ' '||fnAlignZeroVal(LV_LASTC1.P_TAX,4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LWF, 5, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PCO, 4, 'R') ; 
--                    
--                    P_SLNO:=P_SLNO+1;                             
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
--                         
--
--                    --       0005) 
--                       LV_INSERTSTR := ' ';               
--                       LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',4)||fnAlignZeroVal(LV_LASTC1.TSA_HEAD, 5, 'L')||LPAD(' ',61)||''||fnAlignZeroVal(LV_LASTC1.NETPAY_HEAD, 9, 'L');                  
--                                                                     
--                    P_SLNO:=P_SLNO+1;                     
--                        INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                        VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO); 
--                    
--                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.TSA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PF_OWN_YTD, 8, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_BAL, 8, 'R',1)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_BAL, 8, 'R')||' '||fnAlignZeroVal(LV_LASTC1.INST, 2, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GR_FOR_BONUS, 8, 'R',2)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.GRD, 1, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GRERNG, 9, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.GRDEDN, 8, 'R',2)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.NETPAY, 9, 'R',2);
--                                                        
--                    P_SLNO:=P_SLNO+1;                             
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
--                                    
--                    lv_newPage:= PKG_PRINT_TEXT.P_NEWPAGE;
--                    lv_CountRecd:=0;
--                    
--                    P_SLNO:=P_SLNO+1;                    
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) 
--                    VALUES(P_SLNO,'***',lv_newPage);
--                          
--                    LV_LASTC1 := NULL   ;
--                    LV_COUNT:=0; 
--                    
--                end if;                   
            --end if;                              
         
      
            if p_lsttoken is NOT null and LV_COUNT=1 and p_lsttoken<>c1.recordno then     
                LV_COUNT:=-1;                              
                                      
--                DBMS_OUTPUT.PUT_LINE('REC 2 : '||LV_LASTC1.RECORDNO);  
--                DBMS_OUTPUT.PUT_LINE('REC 2 : '||C1.RECORDNO);  
                                
                --      0001)    
                LV_INSERTSTR := ' ';
                IF LV_LASTC1.ATREWARD>0 THEN
                    LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',1)||fnAlignZeroVal(LV_LASTC1.ATREWARD_HEAD, 24, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ATREWARD, 5, 'C',2)||']';     
                ELSE
                    LV_INSERTSTR := LPAD(' ',32);                            
                END IF;
                
                IF C1.ATREWARD>0 THEN
                   LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',55)||fnAlignZeroVal(C1.ATREWARD_HEAD, 24, 'R')||' '||fnAlignZeroVal(C1.ATREWARD, 5, 'C',2)||']';                                    
                END IF;        
                                            
                P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);                                                      
                
                          
                LV_INSERTSTR := fnAlignZeroVal(LV_LASTC1.DEPT, 8, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SRLNO, 5, 'C')||' '||fnAlignZeroVal(LV_LASTC1.RECORDNO, 8, 'C')||
                ' '||fnAlignZeroVal(LV_LASTC1.WORKERNAME, 19, 'L')||' '||fnAlignZeroVal(LV_LASTC1.EBDESIG, 10, 'L')||' '||fnAlignZeroVal(LV_LASTC1.DSGCD, 3, 'L')||
                ' '||fnAlignZeroVal(LV_LASTC1.CT, 2, 'C')||' '||fnAlignZeroVal(LV_LASTC1.FORTNIGHTENDDATE, 10, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SLIPNO, 5, 'R'); 
                                
                LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',2)||fnAlignZeroVal(C1.DEPT, 8, 'C')||' '||fnAlignZeroVal(C1.SRLNO, 5, 'C')||' '||fnAlignZeroVal(C1.RECORDNO, 8, 'C')||
                ' '||fnAlignZeroVal(C1.WORKERNAME, 19, 'L')||' '||fnAlignZeroVal(C1.EBDESIG, 10, 'L')||' '||fnAlignZeroVal(C1.DSGCD, 3, 'L')||
                ' '||fnAlignZeroVal(C1.CT, 2, 'C')||' '||fnAlignZeroVal(C1.FORTNIGHTENDDATE, 10, 'C')||' '||fnAlignZeroVal(C1.SLIPNO, 5, 'R'); 
                           
                P_SLNO:=P_SLNO+1;                     
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT,LV_LASTC1.RECORDNO||':'||C1.RECORDNO);
                             

                --       0002)        
                LV_INSERTSTR := ' '; 
                P_SLNO:=P_SLNO+1;                     
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO); 
                                           
                LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ESINO, 8, 'L')||' '||fnAlignZeroVal(LV_LASTC1.ATNDAY, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.ATNHRS, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NSHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBHR, 3, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.STLDAYS, 4, 'R',1)||
                ' '||fnAlignZeroVal(LV_LASTC1.STLPERIOD, 13, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.YTDDAYS, 11, 'R',1) ; 

                LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',2)||fnAlignZeroVal(C1.ESINO, 8, 'L')||' '||fnAlignZeroVal(C1.ATNDAY, 5, 'R',1)||' '||fnAlignZeroVal(C1.ATNHRS, 8, 'R',2)||
                ' '||fnAlignZeroVal(C1.NSHR, 4, 'R',2)||' '||fnAlignZeroVal(C1.HOLHR, 4, 'R',2)||' '||fnAlignZeroVal(C1.FBHR, 3, 'R',2)||
                ' '||fnAlignZeroVal(C1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(C1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(C1.STLDAYS, 4, 'R',1)||
                ' '||fnAlignZeroVal(C1.STLPERIOD, 13, 'R',2)||' '||fnAlignZeroVal(C1.YTDDAYS, 11, 'R',1) ; 
                                                       
                P_SLNO:=P_SLNO+1;                             
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                         
                         
                --       0003)  
                LV_INSERTSTR := ' '; 
                IF LV_LASTC1.FBWG>0 THEN
                    LV_INSERTSTR := LPAD(' ',49);                              
                ELSE
                    IF LV_LASTC1.FBWG1>0 THEN
                        LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',38)||fnAlignZeroVal(LV_LASTC1.ELECTRIC_HEAD, 10, 'L');
                    ELSE
                        LV_INSERTSTR := LPAD(' ',49);     
                    END IF;                              
                END IF;
                
                IF C1.FBWG>0 THEN
                 LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',32);                                
                ELSE
                    IF LV_LASTC1.FBWG1>0 THEN
                        LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',69)||fnAlignZeroVal(LV_LASTC1.ELECTRIC_HEAD, 10, 'L');           
                    ELSE
                        LV_INSERTSTR := LPAD(' ',49);     
                    END IF;                                                        
                END IF;                                         
                                                                 
                P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);                  
                 
                        
                LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.BASIC, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.SE, 6, 'C')||' '||fnAlignZeroVal(LV_LASTC1.DA, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.FIXER, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLWG, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBWG1, 6, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NSA, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.OT_AMOUNT, 8, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.INCENTIVE, 5, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.HRA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PBF, 3, 'R',2) ; 
                  
                LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',2)||fnAlignZeroVal(C1.BASIC, 7, 'R',2)||' '||fnAlignZeroVal(C1.SE,6, 'C')||' '||fnAlignZeroVal(C1.DA, 8, 'R',2)||
                ' '||fnAlignZeroVal(C1.FIXER, 6, 'R',2)||' '||fnAlignZeroVal(C1.HOLWG, 6, 'R',2)||' '||fnAlignZeroVal(C1.FBWG1, 6, 'R',2)||
                ' '||fnAlignZeroVal(C1.NSA, 6, 'R',2)||' '||fnAlignZeroVal(C1.OT_AMOUNT, 8, 'R',2)||' '||fnAlignZeroVal(C1.INCENTIVE, 5, 'R',2)||
                ' '||fnAlignZeroVal(C1.HRA, 7, 'R',2)||' '||fnAlignZeroVal(C1.PBF, 3, 'R',2) ; 
                                         
                P_SLNO:=P_SLNO+1;                             
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                                        
                              
                --       0004) 
                LV_INSERTSTR := ' '; 
                P_SLNO:=P_SLNO+1;                     
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO); 
                
                LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ADJERNG, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LOC, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF, 7, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.FPF, 5, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ESI, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_RCV, 6, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_RCV, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ADJDEDN, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.HRENT, 6, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.P_TAX,4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LWF, 4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PCO, 4, 'R') ; 

                LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',3)||fnAlignZeroVal(C1.ADJERNG, 6, 'R')||' '||fnAlignZeroVal(C1.LOC, 6, 'R')||' '||fnAlignZeroVal(C1.PF, 7, 'R')||
                ' '||fnAlignZeroVal(C1.FPF, 5, 'R')||' '||fnAlignZeroVal(C1.ESI, 6, 'R')||' '||fnAlignZeroVal(C1.PF_LN_RCV, 6, 'R')||
                ' '||fnAlignZeroVal(C1.PL_INT_RCV, 6, 'R')||' '||fnAlignZeroVal(C1.ADJDEDN, 6, 'R')||' '||fnAlignZeroVal(C1.HRENT, 6, 'R')||
                ' '||fnAlignZeroVal(C1.P_TAX, 4, 'R')||' '||fnAlignZeroVal(C1.LWF, 4, 'R')||' '||fnAlignZeroVal(C1.PCO, 4, 'R') ; 
                                                
                P_SLNO:=P_SLNO+1;                             
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                 

                --       0005)  
                 LV_INSERTSTR := ' ';               
                   LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',4)||fnAlignZeroVal(LV_LASTC1.TSA_HEAD, 5, 'L')||LPAD(' ',61)||''||fnAlignZeroVal(LV_LASTC1.NETPAY_HEAD, 9, 'L');                  
                   LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',5)||fnAlignZeroVal(C1.TSA_HEAD, 5, 'L')||LPAD(' ',61)||''||fnAlignZeroVal(LV_LASTC1.NETPAY_HEAD, 9, 'L');                                   
                                                                 
                P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);                  
                
                
                LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.TSA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PF_OWN_YTD, 8, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_BAL, 8, 'R',1)||
                ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_BAL, 8, 'R')||' '||fnAlignZeroVal(LV_LASTC1.INST, 2, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GR_FOR_BONUS, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.GRD, 1, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GRERNG, 9, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.GRDEDN, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NETPAY, 9, 'R',2) ;
               
                LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',3)||fnAlignZeroVal(C1.TSA, 7, 'R',2)||' '||fnAlignZeroVal(C1.PF_OWN_YTD, 8, 'R',1)||' '||fnAlignZeroVal(C1.PF_LN_BAL, 8, 'R',1)||
                ' '||fnAlignZeroVal(C1.PL_INT_BAL, 8, 'R')||' '||fnAlignZeroVal(C1.INST, 2, 'R')||' '||fnAlignZeroVal(C1.GR_FOR_BONUS, 8, 'R',2)||
                ' '||fnAlignZeroVal(C1.GRD, 1, 'R')||' '||fnAlignZeroVal(C1.GRERNG, 9, 'R',2)||' '||fnAlignZeroVal(C1.GRDEDN, 8, 'R',2)||
                ' '||fnAlignZeroVal(C1.NETPAY, 9, 'R',2) ;               
                                                      
                P_SLNO:=P_SLNO+1;                             
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                    
                --'CHANGE -
--                LV_INSERTSTR := ' '; 
--                P_SLNO:=P_SLNO+1;                     
--                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);                 
--                                
            end if;   
            
                p_lsttoken:=P_RECORDNO;
                            
                if lv_count=1 then
                   p_lsttoken:=null;
                end if;

                lv_count:=lv_count+1;
                LV_LASTC1:=c1;    
                            
                lv_dept:=C1.DEPARTMENTCODE;
                lv_shift:=C1.SHIFT;
                   
            if lv_CountRecd=12 then    
                --lv_newPage:= PKG_PRINT_TEXT.P_NEWPAGE;
                lv_newPage:= '';
                
                P_SLNO:=P_SLNO+1;   
                
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) 
                VALUES(P_SLNO,'',lv_newPage);
                                                
                lv_CountRecd:=0;
            else                 
                 if mod(lv_CountRecd,2)=0 and lv_CountRecd<>0 then             
                     INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINETEXT) 
                       VALUES(P_SLNO,'');      
                       
                        --'CHANGE -
            -- LV_INSERTSTR := ' '; 
                P_SLNO:=P_SLNO+1;                     
--                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);      
                     INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINETEXT) 
                       VALUES(P_SLNO,''); 
                       
                 end if;   
            end if;           
                
           
            
         END LOOP;         
        
        if lv_count=1 then       
            
--            DBMS_OUTPUT.PUT_LINE('REC 3 : '||LV_LASTC1.RECORDNO);  
--            DBMS_OUTPUT.PUT_LINE('REC F : '||LV_LASTC1.PBF); 
--            DBMS_OUTPUT.PUT_LINE('REC O : '||LV_LASTC1.PCO); 
                          
            ---0001)     
            LV_INSERTSTR := ' ';
                IF LV_LASTC1.ATREWARD>0 THEN
                    LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',1)||fnAlignZeroVal(LV_LASTC1.ATREWARD_HEAD, 24, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ATREWARD, 5, 'C',2)||']';     
                ELSE
                    LV_INSERTSTR := LPAD(' ',32);                            
                END IF;               
        
                                            
                P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);  
                    
                                         
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.DEPT, 8, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SRLNO, 5, 'C')||' '||fnAlignZeroVal(LV_LASTC1.RECORDNO, 8, 'C')||
                ' '||fnAlignZeroVal(LV_LASTC1.WORKERNAME, 19, 'L')||' '||fnAlignZeroVal(LV_LASTC1.EBDESIG, 10, 'L')||' '||fnAlignZeroVal(LV_LASTC1.DSGCD, 3, 'L')||
                ' '||fnAlignZeroVal(LV_LASTC1.CT, 2, 'C')||' '||fnAlignZeroVal(LV_LASTC1.FORTNIGHTENDDATE, 10, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SLIPNO, 5, 'R'); 

            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                   
                   
            --       0002)    
            LV_INSERTSTR := ' '; 
            P_SLNO:=P_SLNO+1;                     
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                                           
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ESINO, 8, 'L')||' '||fnAlignZeroVal(LV_LASTC1.ATNDAY, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.ATNHRS, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NSHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBHR, 3, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.STLDAYS, 4, 'R',1)||
                ' '||fnAlignZeroVal(LV_LASTC1.STLPERIOD, 13, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.YTDDAYS, 11, 'R',1) ; 

            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                     
                    
            --       0003)   
              LV_INSERTSTR := ' '; 
                IF LV_LASTC1.FBWG>0 THEN
                    LV_INSERTSTR := LPAD(' ',49);                              
                ELSE
                    IF LV_LASTC1.FBWG1>0 THEN
                        LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',38)||fnAlignZeroVal(LV_LASTC1.ELECTRIC_HEAD, 10, 'L');
                    ELSE
                        LV_INSERTSTR := LPAD(' ',49);     
                    END IF;                              
                END IF;                                                     
                                                                 
                P_SLNO:=P_SLNO+1;                     
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);   
                 
                      
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.BASIC, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.SE, 6, 'C')||' '||fnAlignZeroVal(LV_LASTC1.DA, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.FIXER, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLWG, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBWG, 6, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NSA, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.OT_AMOUNT, 8, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.INCENTIVE, 5, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.HRA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PBF, 3, 'R',2) ; 
              

            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                                    
                          
            --       0004) 
            LV_INSERTSTR := ' '; 
            P_SLNO:=P_SLNO+1;                     
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
            
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ADJERNG, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LOC, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF, 7, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.FPF, 5, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ESI, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_RCV, 6, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_RCV, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ADJDEDN, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.HRENT, 6, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.P_TAX,4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LWF, 4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PCO, 4, 'R',2) ; 
                
            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
             
          
            --       0005) 
               LV_INSERTSTR := ' ';               
               LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',4)||fnAlignZeroVal(LV_LASTC1.TSA_HEAD, 5, 'L')||LPAD(' ',61)||''||fnAlignZeroVal(LV_LASTC1.NETPAY_HEAD, 9, 'L');                  
                                                                 
               P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO); 
                    
            
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.TSA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PF_OWN_YTD, 8, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_BAL, 8, 'R',1)||
                ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_BAL, 8, 'R')||' '||fnAlignZeroVal(LV_LASTC1.INST, 2, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GR_FOR_BONUS, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.GRD, 1, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GRERNG, 9, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.GRDEDN, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NETPAY, 9, 'R',2) ;

            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                                    
            --lv_newPage:= PKG_PRINT_TEXT.P_NEWPAGE;
            lv_newPage:= '';
            
            lv_CountRecd:=0;
                         
            P_SLNO:=P_SLNO+1;   
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) 
            VALUES(P_SLNO,'',lv_newPage);                        

            LV_LASTC1 := NULL   ;
            LV_COUNT:=-1; 
                        
        end if;                  
             
        COMMIT;
END;
/


DROP PROCEDURE NJMCL_WEB.PROC_RPT_STLCHCKLIST;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_RPT_STLCHCKLIST(P_COMPANYCODE VARCHAR2,P_DIVISIONCODE VARCHAR2,P_YERACODE VARCHAR2,P_STARTDATE VARCHAR2,P_ENDDATE VARCHAR2,P_DEPT VARCHAR2,P_SEC VARCHAR2,P_TOKENNO VARCHAR2)
AS
lv_SqlStr VARCHAR2(30000):='';
BEGIN

    DELETE FROM GTT_RPT_STLCHCKLIST;
    
    lv_SqlStr:='INSERT INTO GTT_RPT_STLCHCKLIST
               SELECT A.COMPANYCODE,A.DIVISIONCODE,A.DEPARTMENTCODE,A.SECTIONCODE,DECODE(SHIFTCODE,1,''A'',2,''B'',3,''C'','''') SHIFTCODE,A.TOKENNO,STLFROMDATE,
                    STLTODATE,STLDAYS,STLRATE,WORKERNAME,COMPANYNAME, CASE WHEN A.LEAVEENCASHMENT=''Y'' THEN ''ENCASHMENT'' ELSE NULL END REMARKS
              FROM WPSSTLENTRY A, WPSWORKERMAST B,COMPANYMAST C
              WHERE A.COMPANYCODE='''||P_COMPANYCODE||'''
                    AND A.DIVISIONCODE='''||P_DIVISIONCODE||'''
                    AND A.YEARCODE='''||P_YERACODE||'''
                    AND A.PAYMENTDATE  >=TO_DATE('''||P_STARTDATE||''',''DD/MM/YYYY'')
                    AND A.PAYMENTDATE  <=TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'')'||CHR(10);
IF P_DEPT IS NOT NULL THEN
lv_SqlStr:=lv_SqlStr||'                    AND A.DEPARTMENTCODE  IN ('||P_DEPT||')'||CHR(10);
END IF;
IF P_SEC IS NOT NULL THEN
lv_SqlStr:=lv_SqlStr||'                    AND A.SECTIONCODE  IN ('||P_SEC||')'||CHR(10);
END IF;
IF P_TOKENNO IS NOT NULL THEN
lv_SqlStr:=lv_SqlStr||'                    AND A.TOKENNO  IN ('||P_TOKENNO||')'||CHR(10);
END IF;

lv_SqlStr:=lv_SqlStr||'                    AND A.COMPANYCODE=B.COMPANYCODE
                    AND A.DIVISIONCODE=B.DIVISIONCODE
                    AND A.WORKERSERIAL=B.WORKERSERIAL
                    AND A.COMPANYCODE=C.COMPANYCODE
                    ORDER BY A.DOCUMENTNO';
                    
   DBMS_OUTPUT.PUT_LINE(lv_SqlStr);
   EXECUTE IMMEDIATE lv_SqlStr;
END;
/


DROP PROCEDURE NJMCL_WEB.PROC_RPT_STLLEAVEBALANCE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_RPT_STLLEAVEBALANCE(P_COMPANYCODE VARCHAR2,P_DIVISIONCODE VARCHAR2,P_YEARCODE VARCHAR2,P_TODATE VARCHAR2)
AS
LV_strSQL       VARCHAR2(20000):='';
BEGIN
    
    DELETE FROM GTT_RPT_STLLEAVEBALANCE;
    
    LV_strSQL:='INSERT INTO GTT_RPT_STLLEAVEBALANCE
                    SELECT A.COMPANYCODE,A.DIVISIONCODE,TOKENNO,WORKERNAME,PFNO,0 WAGES,0 LVDAYS,
                    TO_CHAR(DATEOFBIRTH,''YYYY'') DATEOFBIRTH,TO_CHAR(DATEOFJOINING,''DD-MM-YYYY'')DATEOFJOINING,
                    COMPANYNAME,''LEAVE DAYS BALANCE AS ON:-'||P_TODATE||''' REPORTHEADER,COMPANYCITY
                FROM WPSWORKERMAST A,COMPANYMAST B
                WHERE A.COMPANYCODE='''||P_COMPANYCODE||'''
                    AND A.DIVISIONCODE='''||P_DIVISIONCODE||'''
                    AND A.ACTIVE=''Y''
                    AND A.COMPANYCODE=B.COMPANYCODE
                ORDER BY TOKENNO';
                
   EXECUTE IMMEDIATE LV_strSQL;
END;
/


DROP PROCEDURE NJMCL_WEB.PROC_RPT_STLREPORT;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_RPT_STLREPORT(
                                                P_COMCODE VARCHAR2,
                                                P_DIVICODE VARCHAR2,
                                                P_DOCFROMDATE VARCHAR2,
                                                P_DOCTODATE VARCHAR2,
                                                P_DEPTCODE VARCHAR2 DEFAULT NULL,
                                                P_TOKENNO VARCHAR2 DEFAULT NULL,
                                                P_SHIFTCODE VARCHAR2 DEFAULT NULL
                                              )
AS
LV_SQLSTR   VARCHAR2(20000):='';
BEGIN
    DELETE FROM GTT_STLDATA;
    
    LV_SQLSTR:='INSERT INTO GTT_STLDATA'||CHR(10)
                ||'SELECT S.TOKENNO, W.WORKERNAME,S.STLFROMDATE,S.STLTODATE,S.STLDAYS,S.FORTNIGHTSTARTDATE,C.COMPANYNAME,'||CHR(10)
                ||'     D.DIVISIONNAME,S.SHIFTCODE,S.DOCUMENTNO EX1,S.SECTIONCODE EX2,''STL ENTRY CHECK LIST FROM '||P_DOCFROMDATE||' TO '||P_DOCTODATE||''' EX3,'||CHR(10)
                ||'     SEC.DEPARTMENTCODE EX4,NULL EX5,NULL EX6,NULL EX7,NULL EX8,NULL EX9,NULL EX10'||CHR(10)
                ||'FROM WPSSTLENTRY S,WPSWORKERMAST W,COMPANYMAST C,DIVISIONMASTER D,WPSSECTIONMAST SEC'||CHR(10)
                ||'WHERE S.COMPANYCODE='''||P_COMCODE||''' '||CHR(10)
                ||'     AND S.DIVISIONCODE='''||P_DIVICODE||''' '||CHR(10)
                ||'     AND S.LEAVECODE=''STL'''||CHR(10)
                ||'     AND S.DOCUMENTDATE>=TO_DATE('''||P_DOCFROMDATE||''',''DD/MM/YYYY'')'||CHR(10)
                ||'     AND S.DOCUMENTDATE<=TO_DATE('''||P_DOCTODATE||''',''DD/MM/YYYY'')'||CHR(10)
                ||'     AND S.COMPANYCODE=W.COMPANYCODE'||CHR(10)
                ||'     AND S.DIVISIONCODE=W.DIVISIONCODE'||CHR(10)
                ||'     AND S.WORKERSERIAL=W.WORKERSERIAL'||CHR(10)
                ||'     AND S.COMPANYCODE=C.COMPANYCODE'||CHR(10)
                ||'     AND S.COMPANYCODE=D.COMPANYCODE'||CHR(10)
                ||'     AND S.DIVISIONCODE=D.DIVISIONCODE'||CHR(10)
                ||'     AND S.COMPANYCODE=SEC.COMPANYCODE'||CHR(10)
                ||'     AND S.DIVISIONCODE=SEC.DIVISIONCODE'||CHR(10)
                ||'     AND S.SECTIONCODE=SEC.SECTIONCODE'||CHR(10);
     IF P_DEPTCODE IS NOT NULL THEN
        LV_SQLSTR:=LV_SQLSTR||' AND S.DEPARTMENTCODE IN ('||P_DEPTCODE||')'||CHR(10);
     END IF;
     IF P_TOKENNO IS NOT NULL THEN
        LV_SQLSTR:=LV_SQLSTR||' AND S.TOKENNO IN ('||P_TOKENNO||')'||CHR(10);
     END IF;
     IF P_SHIFTCODE IS NOT NULL THEN
        LV_SQLSTR:=LV_SQLSTR||' AND S.SHIFTCODE IN ('||P_SHIFTCODE||')'||CHR(10);
     END IF;
     LV_SQLSTR:=LV_SQLSTR||'ORDER BY S.SHIFTCODE,S.TOKENNO'||CHR(10);
     
     --DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
    EXECUTE IMMEDIATE LV_SQLSTR;
       
END;
/


DROP PROCEDURE NJMCL_WEB.PROC_RPT_STL_DUES;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_RPT_STL_DUES(P_COMPANYCODE VARCHAR2,P_DIVISIONCODE VARCHAR2,P_YEARCODE VARCHAR2,P_DATE VARCHAR2)
AS
LV_strSQL   VARCHAR2(20000):='';
BEGIN
    
    DELETE FROM GTT_RPT_STL_DUES;
    
    LV_strSQL:='INSERT INTO GTT_RPT_STL_DUES
                SELECT PFNO,TOKENNO,WORKERNAME,ESINO,0 JAN,0 FRB,0 MAR,0 APR,0 MAY,0 JUN,0 JUL,0 AUG,0 SEP,0 OCT, 0 NOV,0 DEC,
                    0 TOTWDAY,0 SLDAY,0 TAVL,0 STL,''B'' EARN,COMPANYNAME,''WORKING DAYS AND STL DUE FOR THE CALENDERYER - '||TO_CHAR(TO_DATE(P_DATE,'DD/MM/YYYY'),'YYYY')||''' REPORTHEADER
                FROM WPSWORKERMAST A,COMPANYMAST B
                WHERE A.COMPANYCODE='''||P_COMPANYCODE||'''
                    AND A.DIVISIONCODE='''||P_DIVISIONCODE||'''
                    AND A.ACTIVE=''Y''
                    AND A.COMPANYCODE=B.COMPANYCODE';
                    
   DBMS_OUTPUT.PUT_LINE(LV_strSQL);                    
   EXECUTE IMMEDIATE LV_strSQL;

END;
/


DROP PROCEDURE NJMCL_WEB.PROC_RPT_STL_SANCTION_FORM;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_RPT_STL_SANCTION_FORM(P_COMPANYCODE VARCHAR2,P_DIVISIONCODE VARCHAR2,P_STARTDATE VARCHAR2,P_ENDDATE VARCHAR2,P_TOKENNO VARCHAR2)
AS
lv_sqlstr varchar2(30000):='';
lv_years varchar2(100):='';
BEGIN

    DELETE FROM GTT_WPSSTLDETAILS;
    
    DELETE FROM GTT_RPT_STL_SANCTION_FORM;
    
    lv_sqlstr:='INSERT INTO GTT_WPSSTLDETAILS
                SELECT COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO,DOCUMENTDATE,DEPARTMENTCODE, SHIFTCODE,PAYMENTDATE,LEAVEFROMDATE,SUM(LEAVEDAYS) DAYS,PAYMENTDATE,STLSERIALNO
                FROM WPSSTLENTRYDETAILS
                WHERE COMPANYCODE='''||P_COMPANYCODE||'''
                    AND DIVISIONCODE='''||P_DIVISIONCODE||'''
                    AND PAYMENTDATE>=TO_DATE('''||P_STARTDATE||''',''DD/MM/YYYY'')
                    AND PAYMENTDATE<=TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'')'||CHR(10);
IF P_TOKENNO IS NOT NULL THEN
lv_sqlstr:=lv_sqlstr||'                    AND TOKENNO IN ('||P_TOKENNO||')'||CHR(10);
END IF;
lv_sqlstr:=lv_sqlstr||'                GROUP BY COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO,DOCUMENTDATE,DEPARTMENTCODE,SHIFTCODE,PAYMENTDATE,LEAVEFROMDATE,PAYMENTDATE,STLSERIALNO';

EXECUTE IMMEDIATE lv_sqlstr;

    FOR C1 IN (SELECT * FROM GTT_WPSSTLDETAILS)
    LOOP
        PRC_STLBAL_YEARWISE(C1.COMPANYCODE,C1.DIVISIONCODE,TO_CHAR(C1.PAYMENTDATE-1,'DD/MM/YYYY'),C1.TOKENNO);
        
        
                INSERT INTO GTT_RPT_STL_SANCTION_FORM
                        SELECT A.COMPANYCODE,A.DIVISIONCODE,A.WORKERSERIAL,A.TOKENNO ||CASE WHEN A.LEAVEENCASHMENT='Y' THEN '(R)' END ,TO_CHAR(A.DOCUMENTDATE,'DD/MM/YYYY') DOCUMENTDATE,A.DEPARTMENTCODE,
                        DECODE(A.SHIFTCODE,1,'A',2,'B',3,'C','') SHIFTCODE,TO_CHAR(A.PAYMENTDATE,'DD/MM/YYYY') PAYMENTDATE,
                        TO_CHAR(A.LEAVEFROMDATE,'DD/MM/YYYY') LEAVEFROMDATE,A.DAYS,A.DOCUMENTNO,
            B.YEAR,B.ENTITLE_DAYS ENTITLE_DAYS,B.STLTAKEN_DAYS,/*B.STLBAL_DAYS*/NVL(B.ENTITLE_DAYS,0)-NVL(B.STLTAKEN_DAYS,0) STLBAL_DAYS,
            C.TOTALWORKINGDAYS,C.STLELIGIBLEDAYS,A.SECTIONCODE,
            E.WORKERNAME,E.PFNO,NULL EBNO, F.COMPANYNAME,F.COMPANYCITY,G.DIVISIONNAME,A.YEAR,A.STLRATE,STL.SANCTIONDAYS
        FROM(
            SELECT COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO,DOCUMENTDATE,DEPARTMENTCODE,SHIFTCODE,PAYMENTDATE,LEAVEFROMDATE, 
            STLSERIALNO DOCUMENTNO,WM_CONCAT(YEAR) YEAR,SUM(DAYS) DAYS,STLRATE,SECTIONCODE,LEAVEENCASHMENT
            FROM
            (
                SELECT D.COMPANYCODE,D.DIVISIONCODE,D.WORKERSERIAL,D.TOKENNO,D.DOCUMENTDATE,D.DEPARTMENTCODE,D.SHIFTCODE,
                D.PAYMENTDATE,D.LEAVEFROMDATE,D.STLSERIALNO,D.YEAR,SUM(D.LEAVEDAYS) DAYS,E.STLRATE,E.SECTIONCODE,E.LEAVEENCASHMENT 
                FROM WPSSTLENTRYDETAILS D, WPSSTLENTRY E
                WHERE   D.COMPANYCODE=C1.COMPANYCODE
                    AND D.DIVISIONCODE=C1.DIVISIONCODE
                    AND D.TOKENNO=C1.TOKENNO
                    AND D.PAYMENTDATE=C1.PAYMENTDATE
                    AND D.COMPANYCODE=E.COMPANYCODE
                    AND D.DIVISIONCODE=E.DIVISIONCODE
                    AND D.WORKERSERIAL=E.WORKERSERIAL
                    AND D.TOKENNO=E.TOKENNO
                    AND D.DOCUMENTNO=E.DOCUMENTNO
                    AND D.PAYMENTDATE=E.PAYMENTDATE
                GROUP BY D.COMPANYCODE,D.DIVISIONCODE,D.WORKERSERIAL,D.TOKENNO,D.DOCUMENTDATE,
                D.DEPARTMENTCODE,D.SHIFTCODE,D.PAYMENTDATE,D.LEAVEFROMDATE,D.PAYMENTDATE,D.YEAR,D.STLSERIALNO,
                E.STLRATE,E.SECTIONCODE ,E.LEAVEENCASHMENT
                ORDER BY D.YEAR
            ) GROUP BY COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO,DOCUMENTDATE,
            DEPARTMENTCODE,SHIFTCODE,PAYMENTDATE,LEAVEFROMDATE,PAYMENTDATE,STLSERIALNO,STLRATE,SECTIONCODE,LEAVEENCASHMENT
        ) A , GBL_STLBAL B,WPSSTLENTITLEMENTCALCDETAILS C,WPSWORKERMAST E,COMPANYMAST F,DIVISIONMASTER G,
        (
         SELECT TOKENNO,WORKERSERIAL,YEAR,SUM(LEAVEDAYS) SANCTIONDAYS
         FROM WPSSTLENTRYDETAILS  B 
         WHERE B.COMPANYCODE =C1.COMPANYCODE AND DIVISIONCODE = C1.DIVISIONCODE
         AND B.PAYMENTDATE=C1.PAYMENTDATE
         AND B.LEAVECODE='STL' AND LEAVEDAYS>0
         AND B.TOKENNO =C1.TOKENNO
         AND B.WORKERSERIAL =C1.WORKERSERIAL
         AND B.STLSERIALNO=C1.STLSERIALNO
         GROUP BY TOKENNO,WORKERSERIAL,YEAR
        )STL
        WHERE A.COMPANYCODE=B.COMPANYCODE
            AND A.DIVISIONCODE=B.DIVISIONCODE
            AND A.WORKERSERIAL=B.WORKERSERIAL
            AND B.COMPANYCODE=C.COMPANYCODE(+)
            AND B.DIVISIONCODE=C.DIVISIONCODE(+)
            AND B.WORKERSERIAL=C.WORKERSERIAL(+)
            AND B.YEAR=C.FROMYEAR(+)
            AND A.COMPANYCODE=E.COMPANYCODE
            AND A.DIVISIONCODE=E.DIVISIONCODE
            AND A.WORKERSERIAL=E.WORKERSERIAL
            AND A.COMPANYCODE=F.COMPANYCODE
            AND A.COMPANYCODE=G.COMPANYCODE
            AND A.DIVISIONCODE=G.DIVISIONCODE
            AND B.WORKERSERIAL=STL.WORKERSERIAL(+)
            AND B.TOKENNO=STL.TOKENNO(+)
            AND B.YEAR=STL.YEAR(+);
            
    
    END LOOP;


END;
/


DROP PROCEDURE NJMCL_WEB.PROC_RPT_STL_SANCTION_FORM_NEW;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_RPT_STL_SANCTION_FORM_NEW(P_COMPANYCODE VARCHAR2,P_DIVISIONCODE VARCHAR2,P_STARTDATE VARCHAR2,P_ENDDATE VARCHAR2,P_TOKENNO VARCHAR2)
AS
lv_sqlstr varchar2(30000):='';
lv_years varchar2(100):='';
BEGIN

    DELETE FROM GTT_WPSSTLDETAILS;
    
    DELETE FROM GTT_RPT_STL_SANCTION_FORM;
    
    lv_sqlstr:='INSERT INTO GTT_WPSSTLDETAILS
                SELECT COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO,DOCUMENTDATE,DEPARTMENTCODE, SHIFTCODE,PAYMENTDATE,LEAVEFROMDATE,SUM(LEAVEDAYS) DAYS,PAYMENTDATE
                FROM WPSSTLENTRYDETAILS
                WHERE COMPANYCODE='''||P_COMPANYCODE||'''
                    AND DIVISIONCODE='''||P_DIVISIONCODE||'''
                    AND PAYMENTDATE>=TO_DATE('''||P_STARTDATE||''',''DD/MM/YYYY'')
                    AND PAYMENTDATE<=TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'')'||CHR(10);
IF P_TOKENNO IS NOT NULL THEN
lv_sqlstr:=lv_sqlstr||'                    AND TOKENNO IN ('||P_TOKENNO||')'||CHR(10);
END IF;
lv_sqlstr:=lv_sqlstr||'                GROUP BY COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO,DOCUMENTDATE,DEPARTMENTCODE,SHIFTCODE,PAYMENTDATE,LEAVEFROMDATE,PAYMENTDATE';

EXECUTE IMMEDIATE lv_sqlstr;

    FOR C1 IN (SELECT * FROM GTT_WPSSTLDETAILS)
    LOOP
        PRC_STLBAL_YEARWISE(C1.COMPANYCODE,C1.DIVISIONCODE,TO_CHAR(C1.PAYMENTDATE-1,'DD/MM/YYYY'),C1.TOKENNO);
        
        SELECT WM_CONCAT(YEAR) INTO lv_years FROM GBL_STLBAL ORDER BY YEAR;
        
        INSERT INTO GTT_RPT_STL_SANCTION_FORM
                        SELECT A.COMPANYCODE,A.DIVISIONCODE,A.WORKERSERIAL,A.TOKENNO,TO_CHAR(A.DOCUMENTDATE,'DD/MM/YYYY') DOCUMENTDATE,A.DEPARTMENTCODE,DECODE(A.SHIFTCODE,1,'A',2,'B',3,'C','') SHIFTCODE,TO_CHAR(A.PAYMENTDATE,'DD/MM/YYYY') PAYMENTDATE,TO_CHAR(A.LEAVEFROMDATE,'DD/MM/YYYY') LEAVEFROMDATE,A.DAYS,A.DOCUMENTNO,
            B.YEAR,B.ENTITLE_DAYS,B.STLTAKEN_DAYS,B.STLBAL_DAYS,C.TOTALWORKINGDAYS,C.STLELIGIBLEDAYS,A.SECTIONCODE,
            E.WORKERNAME,E.PFNO,NULL EBNO, F.COMPANYNAME,F.COMPANYCITY,G.DIVISIONNAME,A.YEAR,A.STLRATE
        FROM(
            SELECT COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO,DOCUMENTDATE,DEPARTMENTCODE,SHIFTCODE,PAYMENTDATE,LEAVEFROMDATE, 
            STLSERIALNO DOCUMENTNO,WM_CONCAT(YEAR) YEAR,SUM(DAYS) DAYS,STLRATE,SECTIONCODE
            FROM
            (
                SELECT D.COMPANYCODE,D.DIVISIONCODE,D.WORKERSERIAL,D.TOKENNO,D.DOCUMENTDATE,D.DEPARTMENTCODE,D.SHIFTCODE,
                D.PAYMENTDATE,D.LEAVEFROMDATE,D.STLSERIALNO,D.YEAR,SUM(D.LEAVEDAYS) DAYS,E.STLRATE,E.SECTIONCODE 
                FROM WPSSTLENTRYDETAILS D, WPSSTLENTRY E
                WHERE   D.COMPANYCODE=C1.COMPANYCODE
                    AND D.DIVISIONCODE=C1.DIVISIONCODE
                    AND D.TOKENNO=C1.TOKENNO
                    AND D.PAYMENTDATE=C1.PAYMENTDATE
                    AND D.COMPANYCODE=E.COMPANYCODE
                    AND D.DIVISIONCODE=E.DIVISIONCODE
                    AND D.WORKERSERIAL=E.WORKERSERIAL
                    AND D.TOKENNO=E.TOKENNO
                    AND D.DOCUMENTNO=E.DOCUMENTNO
                    AND D.PAYMENTDATE=E.PAYMENTDATE
                GROUP BY D.COMPANYCODE,D.DIVISIONCODE,D.WORKERSERIAL,D.TOKENNO,D.DOCUMENTDATE,
                D.DEPARTMENTCODE,D.SHIFTCODE,D.PAYMENTDATE,D.LEAVEFROMDATE,D.PAYMENTDATE,D.YEAR,D.STLSERIALNO,
                E.STLRATE,E.SECTIONCODE 
                ORDER BY D.YEAR
            ) GROUP BY COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO,DOCUMENTDATE,
            DEPARTMENTCODE,SHIFTCODE,PAYMENTDATE,LEAVEFROMDATE,PAYMENTDATE,STLSERIALNO,STLRATE,SECTIONCODE
        ) A , GBL_STLBAL B,WPSSTLENTITLEMENTCALCDETAILS C,WPSWORKERMAST E,COMPANYMAST F,DIVISIONMASTER G
        WHERE A.COMPANYCODE=B.COMPANYCODE
            AND A.DIVISIONCODE=B.DIVISIONCODE
            AND A.WORKERSERIAL=B.WORKERSERIAL
            AND B.COMPANYCODE=C.COMPANYCODE(+)
            AND B.DIVISIONCODE=C.DIVISIONCODE(+)
            AND B.WORKERSERIAL=C.WORKERSERIAL(+)
            AND B.YEAR=C.FROMYEAR(+)
            AND A.COMPANYCODE=E.COMPANYCODE
            AND A.DIVISIONCODE=E.DIVISIONCODE
            AND A.WORKERSERIAL=E.WORKERSERIAL
            AND A.COMPANYCODE=F.COMPANYCODE
            AND A.COMPANYCODE=G.COMPANYCODE
            AND A.DIVISIONCODE=G.DIVISIONCODE;
        
        
        
--        SELECT A.COMPANYCODE,A.DIVISIONCODE,A.WORKERSERIAL,A.TOKENNO,TO_CHAR(A.DOCUMENTDATE,'DD/MM/YYYY') DOCUMENTDATE,A.DEPARTMENTCODE,DECODE(A.SHIFTCODE,1,'A',2,'B',3,'C','') SHIFTCODE,TO_CHAR(A.PAYMENTDATE,'DD/MM/YYYY') PAYMENTDATE,TO_CHAR(A.LEAVEFROMDATE,'DD/MM/YYYY') LEAVEFROMDATE,A.DAYS,A.DOCUMENTNO,
--            B.YEAR,B.ENTITLE_DAYS,B.STLTAKEN_DAYS,B.STLBAL_DAYS,C.TOTALWORKINGDAYS,C.STLELIGIBLEDAYS,D.SECTIONCODE,
--            E.WORKERNAME,E.PFNO,NULL EBNO, F.COMPANYNAME,F.COMPANYCITY,G.DIVISIONNAME,A.YEAR,STLRATE
--        FROM(
--            SELECT COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO,DOCUMENTDATE,DEPARTMENTCODE,SHIFTCODE,PAYMENTDATE,LEAVEFROMDATE, WM_CONCAT(DOCUMENTNO) DOCUMENTNO,WM_CONCAT(YEAR) YEAR,SUM(DAYS) DAYS
--            FROM
--            (
--                SELECT COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO,DOCUMENTDATE,DEPARTMENTCODE,SHIFTCODE,PAYMENTDATE,LEAVEFROMDATE,DOCUMENTNO DOCUMENTNO,YEAR,SUM(LEAVEDAYS) DAYS 
--                FROM WPSSTLENTRYDETAILS 
--                WHERE COMPANYCODE=C1.COMPANYCODE
--                    AND DIVISIONCODE=C1.DIVISIONCODE
--        --            AND PAYMENTDATE>=TO_DATE('01/03/2020','DD/MM/YYYY')
--        --            AND PAYMENTDATE<=TO_DATE('31/03/2020','DD/MM/YYYY')
--                    AND TOKENNO=C1.TOKENNO
--                    AND PAYMENTDATE=C1.PAYMENTDATE
--                GROUP BY COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO,DOCUMENTDATE,DEPARTMENTCODE,SHIFTCODE,PAYMENTDATE,LEAVEFROMDATE,PAYMENTDATE,DOCUMENTNO,YEAR
--                ORDER BY YEAR
--            ) GROUP BY COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO,DOCUMENTDATE,DEPARTMENTCODE,SHIFTCODE,PAYMENTDATE,LEAVEFROMDATE,PAYMENTDATE
--        ) A , GBL_STLBAL B,WPSSTLENTITLEMENTCALCDETAILS C,WPSSTLENTRY D,WPSWORKERMAST E,COMPANYMAST F,DIVISIONMASTER G
--        WHERE A.COMPANYCODE=B.COMPANYCODE
--            AND A.DIVISIONCODE=B.DIVISIONCODE
--            AND A.WORKERSERIAL=B.WORKERSERIAL
--            AND B.COMPANYCODE=C.COMPANYCODE(+)
--            AND B.DIVISIONCODE=C.DIVISIONCODE(+)
--            AND B.WORKERSERIAL=C.WORKERSERIAL(+)
--            AND B.YEAR=C.FROMYEAR(+)
--            AND A.COMPANYCODE=D.COMPANYCODE
--            AND A.DIVISIONCODE=D.DIVISIONCODE
--            AND A.WORKERSERIAL=D.WORKERSERIAL
--            AND SUBSTR(A.DOCUMENTNO,0,14)=D.DOCUMENTNO
--            AND A.COMPANYCODE=E.COMPANYCODE
--            AND A.DIVISIONCODE=E.DIVISIONCODE
--            AND A.WORKERSERIAL=E.WORKERSERIAL
--            AND A.COMPANYCODE=F.COMPANYCODE
--            AND A.COMPANYCODE=G.COMPANYCODE
--            AND A.DIVISIONCODE=G.DIVISIONCODE;
    
    END LOOP;


END;
/


DROP PROCEDURE NJMCL_WEB.PROC_RPT_STL_SANCTION_FORM_OLD;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_RPT_STL_SANCTION_FORM_OLD(P_COMPANYCODE VARCHAR2,P_DIVISIONCODE VARCHAR2,P_STARTDATE VARCHAR2,P_ENDDATE VARCHAR2,P_TOKENNO VARCHAR2)
AS
lv_sqlstr varchar2(30000):='';
lv_years varchar2(100):='';
BEGIN

    DELETE FROM GTT_WPSSTLDETAILS;
    
    DELETE FROM GTT_RPT_STL_SANCTION_FORM;
    
    lv_sqlstr:='INSERT INTO GTT_WPSSTLDETAILS
                SELECT COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO,DOCUMENTDATE,DEPARTMENTCODE, SHIFTCODE,PAYMENTDATE,LEAVEFROMDATE,SUM(LEAVEDAYS) DAYS,PAYMENTDATE
                FROM WPSSTLENTRYDETAILS
                WHERE COMPANYCODE='''||P_COMPANYCODE||'''
                    AND DIVISIONCODE='''||P_DIVISIONCODE||'''
                    AND PAYMENTDATE>=TO_DATE('''||P_STARTDATE||''',''DD/MM/YYYY'')
                    AND PAYMENTDATE<=TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'')'||CHR(10);
IF P_TOKENNO IS NOT NULL THEN
lv_sqlstr:=lv_sqlstr||'                    AND TOKENNO IN ('||P_TOKENNO||')'||CHR(10);
END IF;
lv_sqlstr:=lv_sqlstr||'                GROUP BY COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO,DOCUMENTDATE,DEPARTMENTCODE,SHIFTCODE,PAYMENTDATE,LEAVEFROMDATE,PAYMENTDATE';

EXECUTE IMMEDIATE lv_sqlstr;

    FOR C1 IN (SELECT * FROM GTT_WPSSTLDETAILS)
    LOOP
        PRC_STLBAL_YEARWISE(C1.COMPANYCODE,C1.DIVISIONCODE,TO_CHAR(C1.PAYMENTDATE-1,'DD/MM/YYYY'),C1.TOKENNO);
        
        SELECT WM_CONCAT(YEAR) INTO lv_years FROM GBL_STLBAL ORDER BY YEAR;
        
        INSERT INTO GTT_RPT_STL_SANCTION_FORM
        SELECT A.COMPANYCODE,A.DIVISIONCODE,A.WORKERSERIAL,A.TOKENNO,TO_CHAR(A.DOCUMENTDATE,'DD/MM/YYYY') DOCUMENTDATE,A.DEPARTMENTCODE,DECODE(A.SHIFTCODE,1,'A',2,'B',3,'C','') SHIFTCODE,TO_CHAR(A.PAYMENTDATE,'DD/MM/YYYY') PAYMENTDATE,TO_CHAR(A.LEAVEFROMDATE,'DD/MM/YYYY') LEAVEFROMDATE,A.DAYS,A.DOCUMENTNO,
            B.YEAR,B.ENTITLE_DAYS,B.STLTAKEN_DAYS,B.STLBAL_DAYS,C.TOTALWORKINGDAYS,C.STLELIGIBLEDAYS,D.SECTIONCODE,
            E.WORKERNAME,E.PFNO,NULL EBNO, F.COMPANYNAME,F.COMPANYCITY,G.DIVISIONNAME,A.YEAR,STLRATE
        FROM(
            SELECT COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO,DOCUMENTDATE,DEPARTMENTCODE,SHIFTCODE,PAYMENTDATE,LEAVEFROMDATE, WM_CONCAT(DOCUMENTNO) DOCUMENTNO,WM_CONCAT(YEAR) YEAR,SUM(DAYS) DAYS
            FROM
            (
                SELECT COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO,DOCUMENTDATE,DEPARTMENTCODE,SHIFTCODE,PAYMENTDATE,LEAVEFROMDATE,DOCUMENTNO DOCUMENTNO,YEAR,SUM(LEAVEDAYS) DAYS 
                FROM WPSSTLENTRYDETAILS 
                WHERE COMPANYCODE=C1.COMPANYCODE
                    AND DIVISIONCODE=C1.DIVISIONCODE
        --            AND PAYMENTDATE>=TO_DATE('01/03/2020','DD/MM/YYYY')
        --            AND PAYMENTDATE<=TO_DATE('31/03/2020','DD/MM/YYYY')
                    AND TOKENNO=C1.TOKENNO
                    AND PAYMENTDATE=C1.PAYMENTDATE
                GROUP BY COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO,DOCUMENTDATE,DEPARTMENTCODE,SHIFTCODE,PAYMENTDATE,LEAVEFROMDATE,PAYMENTDATE,DOCUMENTNO,YEAR
                ORDER BY YEAR
            ) GROUP BY COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO,DOCUMENTDATE,DEPARTMENTCODE,SHIFTCODE,PAYMENTDATE,LEAVEFROMDATE,PAYMENTDATE
        ) A , GBL_STLBAL B,WPSSTLENTITLEMENTCALCDETAILS C,WPSSTLENTRY D,WPSWORKERMAST E,COMPANYMAST F,DIVISIONMASTER G
        WHERE A.COMPANYCODE=B.COMPANYCODE
            AND A.DIVISIONCODE=B.DIVISIONCODE
            AND A.WORKERSERIAL=B.WORKERSERIAL
            AND B.COMPANYCODE=C.COMPANYCODE(+)
            AND B.DIVISIONCODE=C.DIVISIONCODE(+)
            AND B.WORKERSERIAL=C.WORKERSERIAL(+)
            AND B.YEAR=C.FROMYEAR(+)
            AND A.COMPANYCODE=D.COMPANYCODE
            AND A.DIVISIONCODE=D.DIVISIONCODE
            AND A.WORKERSERIAL=D.WORKERSERIAL
            AND SUBSTR(A.DOCUMENTNO,0,14)=D.DOCUMENTNO
            AND A.COMPANYCODE=E.COMPANYCODE
            AND A.DIVISIONCODE=E.DIVISIONCODE
            AND A.WORKERSERIAL=E.WORKERSERIAL
            AND A.COMPANYCODE=F.COMPANYCODE
            AND A.COMPANYCODE=G.COMPANYCODE
            AND A.DIVISIONCODE=G.DIVISIONCODE;
    
    END LOOP;


END;
/


DROP PROCEDURE NJMCL_WEB.PROC_RPT_WPSSTLDETAILS;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_RPT_WPSSTLDETAILS 
( 
    P_COMPCODE VARCHAR2, 
    P_DIVCODE VARCHAR2, 
    P_PERIODFROM VARCHAR2, 
    P_PERIODTO VARCHAR2 DEFAULT NULL, 
    P_DEPTCODE VARCHAR2 DEFAULT 'N', 
    P_CATGCODE VARCHAR2 DEFAULT 'N', 
    P_UNITCODE VARCHAR2 DEFAULT 'N', 
    P_SHIFTCODE VARCHAR2 DEFAULT 'N', 
    P_TOKENNO VARCHAR2 DEFAULT 'N'
) 
AS
LV_SQL          VARCHAR2(20000);
LV_WORKERSERIAL VARCHAR2(10);
LV_STARTOFTHEYEAR   VARCHAR2(10);
LV_RETURNVALUE  NUMBER := 0;
LV_AVLSTR VARCHAR2(500);
LV_BALSTR VARCHAR2(500);
LV_PVTSTR VARCHAR2(500);
LV_CURR_YR VARCHAR(10);
BEGIN

    DELETE FROM GTT_STLDETAILS WHERE 1=1;
    
    LV_CURR_YR := SUBSTR(P_PERIODFROM,-4);
    --EXEC PROC_RPT_WPSSTLDETAILS('NJ0001','0002','22/01/2020','15/07/2020')
    
--    PRC_STLBAL_YEARWISE ('NJ0001','0002','22/01/2020')
    PRC_STLBAL_YEARWISE (P_COMPCODE,P_DIVCODE, TO_CHAR((TO_DATE(P_PERIODFROM,'DD/MM/YYYY')-1),'DD/MM/YYYY'));
        
    DELETE FROM STLBAL_TMP WHERE 1=1;
    
    INSERT INTO STLBAL_TMP
    select * from GBL_STLBAL;
    
    if (substr(P_PERIODFROM,1,5) = '01/01') then
        PRC_STLBAL_YEARWISE (P_COMPCODE,P_DIVCODE, P_PERIODFROM);
        
        INSERT INTO STLBAL_TMP
        select COMPANYCODE, DIVISIONCODE, LEAVECODE, YEAR, ASONDATE, WORKERSERIAL, 
        TOKENNO, ENTITLE_DAYS, PREV_STLDAYS, STLTAKEN_DAYS, (STLTAKEN_DAYS+STLBAL_DAYS) STLBAL_DAYS 
        from GBL_STLBAL a where a.year not in ( select distinct year from STLBAL_TMP);
    end if;
    
    
    SELECT WM_CONCAT(''''||YEAR||''' AS YR_'||YEAR) INTO LV_PVTSTR
    FROM 
    (
        SELECT DISTINCT YEAR FROM GBL_STLBAL
        ORDER BY YEAR
    );
    
    SELECT WM_CONCAT('NVL(A.YR_'||YEAR||',0) AVL_YR_'||YEAR)  INTO LV_AVLSTR
    FROM 
    (
        SELECT DISTINCT YEAR FROM GBL_STLBAL
        ORDER BY YEAR
    );
    
    SELECT WM_CONCAT('(NVL(A.YR_'||YEAR||',0)  - NVL(B.YR_'||YEAR||',0)) BAL_YR_'||YEAR)   INTO LV_BALSTR
    FROM 
    (
        SELECT DISTINCT YEAR FROM GBL_STLBAL
        ORDER BY YEAR
    );
    
    
    DBMS_OUTPUT.PUT_LINE ('LV_PVTSTR -------'||CHR(10)||LV_PVTSTR);
    DBMS_OUTPUT.PUT_LINE ('LV_AVLSTR -------'||CHR(10)||LV_AVLSTR);
    DBMS_OUTPUT.PUT_LINE ('LV_BALSTR -------'||CHR(10)||LV_BALSTR);
    
    PRC_STLBAL_YEARWISE (P_COMPCODE,P_DIVCODE, P_PERIODTO);


    LV_SQL := LV_SQL || 'INSERT INTO GTT_STLDETAILS'|| CHR(10);
    LV_SQL := LV_SQL || '('|| CHR(10);
    LV_SQL := LV_SQL || '   TOKENNO, PREV_YR_STLBAL_1, PREV_YR_STLBAL_2, CURR_YR_STLBAL1, STL_AVAILED_YR1, STL_AVAILED_YR2, STL_AVAILED_YR3'|| CHR(10);
    LV_SQL := LV_SQL || ')'|| CHR(10);
    LV_SQL := LV_SQL || 'SELECT A.TOKENNO'|| CHR(10);
--    LV_SQL := LV_SQL || ', NVL(A.YR_2017,0) AVL_YR_2017, NVL(A.YR_2018,0) AVL_YR_2018,NVL(A.YR_2019,0) AVL_YR_2019  '|| CHR(10);
--    LV_SQL := LV_SQL || ', (NVL(B.YR_2017,0) - NVL(A.YR_2017,0)) BAL_YR_2017, '|| CHR(10);
--    LV_SQL := LV_SQL || '(NVL(B.YR_2018,0) - NVL(A.YR_2018,0)) BAL_YR_2018,'|| CHR(10);
--    LV_SQL := LV_SQL || '(NVL(B.YR_2019,0) - NVL(A.YR_2019,0)) BAL_YR_2019'|| CHR(10);

    LV_SQL := LV_SQL || ','||LV_AVLSTR|| CHR(10)|| ','||LV_BALSTR|| CHR(10);
    LV_SQL := LV_SQL || 'FROM '|| CHR(10);
    LV_SQL := LV_SQL || '('|| CHR(10);
    LV_SQL := LV_SQL || '    SELECT * FROM '|| CHR(10);
    LV_SQL := LV_SQL || '    ('|| CHR(10);
    LV_SQL := LV_SQL || '       SELECT TOKENNO,''STLBAL_DAYS'' CAPTION, STLBAL_DAYS, YEAR'|| CHR(10);
    LV_SQL := LV_SQL || '       FROM  STLBAL_TMP'|| CHR(10);
    LV_SQL := LV_SQL || '    )'|| CHR(10);
    LV_SQL := LV_SQL || '    PIVOT '|| CHR(10);
    LV_SQL := LV_SQL || '    ('|| CHR(10);
    LV_SQL := LV_SQL || '       SUM(STLBAL_DAYS)'|| CHR(10);
--    LV_SQL := LV_SQL || '       FOR YEAR IN (''2017'' AS YR_2017,''2018'' AS YR_2018,''2019'' AS YR_2019 )'|| CHR(10);
    LV_SQL := LV_SQL || '       FOR YEAR IN ('||LV_PVTSTR||')'|| CHR(10);
    LV_SQL := LV_SQL || '    )'|| CHR(10);
    LV_SQL := LV_SQL || ') A,'|| CHR(10);
    LV_SQL := LV_SQL || '('|| CHR(10);
    LV_SQL := LV_SQL || 'SELECT * FROM '|| CHR(10);
    LV_SQL := LV_SQL || '    ('|| CHR(10);
    LV_SQL := LV_SQL || '       SELECT TOKENNO,''STLBAL_DAYS'' CAPTION, STLBAL_DAYS, YEAR'|| CHR(10);
    LV_SQL := LV_SQL || '       FROM GBL_STLBAL'|| CHR(10);
    LV_SQL := LV_SQL || '    )'|| CHR(10);
    LV_SQL := LV_SQL || '    PIVOT '|| CHR(10);
    LV_SQL := LV_SQL || '    ('|| CHR(10);
    LV_SQL := LV_SQL || '       SUM(STLBAL_DAYS)'|| CHR(10);
--    LV_SQL := LV_SQL || '       FOR YEAR IN (''2017'' AS YR_2017,''2018'' AS YR_2018,''2019'' AS YR_2019 )'|| CHR(10);
    LV_SQL := LV_SQL || '       FOR YEAR IN ('||LV_PVTSTR||')'|| CHR(10);
    LV_SQL := LV_SQL || '    )'|| CHR(10);
    LV_SQL := LV_SQL || ') B'|| CHR(10);
    LV_SQL := LV_SQL || 'WHERE A.TOKENNO=B.TOKENNO'|| CHR(10);
    LV_SQL := LV_SQL || ''|| CHR(10);



    DBMS_OUTPUT.PUT_LINE (lv_Sql);
    EXECUTE IMMEDIATE LV_SQL;
    
    UPDATE GTT_STLDETAILS SET
    COMPANYCODE=P_COMPCODE,
    DIVISIONCODE=P_DIVCODE,
    TOTAL_STLBAL = (PREV_YR_STLBAL_1+PREV_YR_STLBAL_2+CURR_YR_STLBAL1), 
    STLBAL_DAYS1 = (PREV_YR_STLBAL_1 - STL_AVAILED_YR1) , 
    STLBAL_DAYS2 = (PREV_YR_STLBAL_2 - STL_AVAILED_YR2), 
    STLBAL_DAYS3 = (CURR_YR_STLBAL1 - STL_AVAILED_YR3), 
    TOTAL_STLBAL_DAYS = (NVL(STLBAL_DAYS1,0)+NVL(STLBAL_DAYS2,0)+NVL(STLBAL_DAYS3,0)),
    YR3 = TO_NUMBER(LV_CURR_YR)-1,
    YR2 = TO_NUMBER(LV_CURR_YR)-2,
    YR1 = TO_NUMBER(LV_CURR_YR)-3,
    REPORTHEADER = 'PERIOD '||P_PERIODFROM||' TO '||P_PERIODTO
    WHERE 1=1;


    UPDATE GTT_STLDETAILS SET
    TOTAL_STL_AVAILED = (STL_AVAILED_YR1+STL_AVAILED_YR2+STL_AVAILED_YR3), 
    TOTAL_STLBAL_DAYS = (NVL(STLBAL_DAYS1,0)+NVL(STLBAL_DAYS2,0)+NVL(STLBAL_DAYS3,0))
    WHERE 1=1;


    UPDATE GTT_STLDETAILS A SET
    WORKDAYS_CURR_YR = 
    (
        SELECT ATTNDAYS FROM 
        WPSSTLENTITLEMENTCALCDETAILS
        WHERE COMPANYCODE=P_COMPCODE
        AND DIVISIONCODE=P_DIVCODE
        AND TOKENNO=A.TOKENNO
--        AND TO_CHAR(FORTNIGHTSTARTDATE,'YYYY')=A.YR3
--        AND TO_CHAR(FORTNIGHTENDDATE,'YYYY')=A.YR3
        AND FROMYEAR=A.YR3
    )
    WHERE 1=1;



UPDATE GTT_STLDETAILS A SET
(COMPANYNAME, DIVISIONNAME, WORKERNAME) = 
(
    SELECT C.COMPANYNAME, D.DIVISIONNAME , W.WORKERNAME 
    FROM WPSWORKERMAST W, COMPANYMAST C, DIVISIONMASTER D
    WHERE W.COMPANYCODE=C.COMPANYCODE
    AND W.COMPANYCODE=D.COMPANYCODE
    AND W.DIVISIONCODE	= D.DIVISIONCODE
    AND W.COMPANYCODE=A.COMPANYCODE
    AND W.DIVISIONCODE	= A.DIVISIONCODE 
    AND W.TOKENNO	= A.TOKENNO 
)
WHERE 1=1;
 


END;
/


DROP PROCEDURE NJMCL_WEB.PROC_STLDUECALENDERYEAR;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_STLDUECALENDERYEAR
(
P_COMPANYCODE VARCHAR2,
P_DIVISIONCODE VARCHAR2,                                            
P_YEAR VARCHAR2                              
)

AS

LV_SQLSTR      VARCHAR2(30000);
LV_LASTYEAR VARCHAR2(4);

BEGIN

--EXEC PROC_STLDUECALENDERYEAR ('NJ0001', '0002','2020')

LV_LASTYEAR:= TO_NUMBER(P_YEAR)-1;


   LV_SQLSTR := 'PROC_STLDUECALENDERYEAR('''||P_COMPANYCODE||''','''||P_DIVISIONCODE||''','''||P_YEAR||''')';
   
     insert into WPS_error_log
     (
        
       COMPANYCODE, DIVISIONCODE, ERROR_DATE, ERROR_QUERY, FORTNIGHTENDDATE, FORTNIGHTSTARTDATE, ORA_ERROR_MESSG, PAR_VALUES, PROC_NAME, REMARKS
     )
     values
     (
        P_COMPANYCODE, P_DIVISIONCODE, sysdate, LV_SQLSTR, SYSDATE, SYSDATE,NULL , LV_SQLSTR, 'PROC_STLDUECALENDERYEAR', 'SCRIPT ADDED'
     );


 DELETE FROM GTT_STLDUECALENDERYEAR;
  
        LV_SQLSTR:=   'INSERT INTO GTT_STLDUECALENDERYEAR( SER, COMPANYCODE, DIVISIONCODE,COMPANYNAME, PFNO,TOKENNO,WORKERNAME,ESINO,                                             '|| CHR(10)
                    ||'JAN, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV, DEC, TDAY, STLDAY, STLAVL, STL,CATEGORYCODE,EX1,EX2 )                                               '|| CHR(10)
                    ||'SELECT  LPAD(ROW_NUMBER()OVER(ORDER BY D.TOKENNO),4,0) SER, D.COMPANYCODE, D.DIVISIONCODE,C.COMPANYNAME, D.PFNO,D.TOKENNO,D.WORKERNAME,D.ESINO,                                                      '|| CHR(10)
                    ||'JAN, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV, DEC, to_char(TDAY,''fm999.0'')TDAY,  '|| CHR(10)
                    ||'FN_GET_STL_S_L_DAYS(D.COMPANYCODE, D.DIVISIONCODE,D.WORKERSERIAL,'|| P_YEAR      || ') AS STLDAY,           '|| CHR(10)
                    ||'FN_GET_STL_AVL_DAYS(D.COMPANYCODE, D.DIVISIONCODE,D.WORKERSERIAL,'|| LV_LASTYEAR || ') AS STLAVL,           '|| CHR(10)
                    ||'FN_GET_STL_ERN_DAYS(D.COMPANYCODE, D.DIVISIONCODE,D.WORKERSERIAL,'|| P_YEAR      || ') AS STL,              '|| CHR(10)
                    ||'D.WORKERCATEGORYCODE,            '|| CHR(10)
                    ||'''Working Days and STL Due for the calendar year - '|| P_YEAR || ' '' EX1 ,''Printdate:-'' || TO_CHAR(SYSDATE,''DD/MM/YYYY'') EX2  FROM                                                                '|| CHR(10)
                    ||'(                                                                                                                                                          '|| CHR(10)
                    ||'SELECT SER, A.COMPANYCODE, A.DIVISIONCODE,PFNO, A.TOKENNO,WORKERNAME, ESINO,                                                                               '|| CHR(10)
                    ||'to_char(JAN,''fm999.0'')JAN,to_char(FEB,''fm999.0'')FEB,to_char(MAR,''fm999.0'')MAR,to_char(APR,''fm999.0'')APR,                                           '|| CHR(10)
                    ||'to_char(MAY,''fm999.0'')MAY,to_char(JUN,''fm999.0'')JUN,to_char(JUL,''fm999.0'')JUL,to_char(AUG,''fm999.0'')AUG,                                           '|| CHR(10)
                    ||'to_char(SEP,''fm999.0'')SEP,to_char(OCT,''fm999.0'')OCT,to_char(NOV,''fm999.0'')NOV,to_char(DEC,''fm999.0'')DEC,                                           '|| CHR(10)
                    ||'TDAY ,MAX(B.OCCUPATIONCODE)OCCUPATIONCODE,TO_CHAR(DATEOFJOINING,''DD/MM/YYYY'')DATEOFJOINING,A.WORKERCATEGORYCODE,A.WORKERSERIAL FROM                                     '|| CHR(10)
                    ||'(                                                                                                                                                          '|| CHR(10)
                    ||'SELECT ROW_NUMBER()OVER(ORDER BY COMPANYCODE) SER, COMPANYCODE, DIVISIONCODE,WORKERSERIAL, PFNO, TOKENNO, WORKERNAME,ESINO,                                    '|| CHR(10)
                    ||'JAN, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV, DEC,                                                                                                '|| CHR(10)
                    ||'SUM(NVL(JAN,0)+ NVL(FEB,0)+NVL(MAR,0)+ NVL(APR,0)+ NVL(MAY,0)+NVL(JUN,0)+ NVL(JUL,0)+ NVL(AUG,0)+NVL(SEP,0)+ NVL(OCT,0) + NVL(NOV,0) + NVL(DEC,0))TDAY,    '|| CHR(10)
                    ||'DATEOFJOINING,A.WORKERCATEGORYCODE                                                                                                                         '|| CHR(10)
                    ||'FROM                                                                                                                                                       '|| CHR(10)
                    ||'(                                                                                                                                                          '|| CHR(10)
                    ||'SELECT A.COMPANYCODE, A.DIVISIONCODE,A.WORKERSERIAL,PFNO,B.TOKENNO,WORKERNAME,ESINO,                                                                       '|| CHR(10)
                    ||'SUBSTR(TO_CHAR(TO_DATE(TO_CHAR(TO_DATE(A.FORTNIGHTENDDATE,''DD/MM/YYYY''),''MM''), ''MM''), ''MONTH''),1,3)  MONTHNAME, to_char(SUM(ATN_DAYS),''fm999.0'') ATN_DAYS, '|| CHR(10)
                    ||'DATEOFJOINING, B.WORKERCATEGORYCODE FROM                                                                                                                   '|| CHR(10)
                    ||'(                                                                                                                                                          '|| CHR(10)
                    ||'SELECT  DISTINCT  COMPANYCODE, DIVISIONCODE,FORTNIGHTENDDATE,  WORKERSERIAL,NVL(ATN_DAYS,0)+ROUND(NVL(PFADJHOURS,0)/8,1) ATN_DAYS                                              '|| CHR(10)
                    ||'FROM WPSWAGESDETAILS_MV                                                                                                                                    '|| CHR(10)
                    ||'WHERE 1=1 /*NVL(ATTENDANCEHOURS,0)>0 */                                                                                                                            '|| CHR(10)
                    ||'AND COMPANYCODE='''||P_COMPANYCODE||'''                                                                                                                    '|| CHR(10)
                    ||'AND DIVISIONCODE='''||P_DIVISIONCODE||'''                                                                                                                  '|| CHR(10)
                    ||'AND TO_CHAR(FORTNIGHTENDDATE,''yyyy'') ='''||P_YEAR||'''                                                                                               '|| CHR(10)
                    ||')                                                                                                                                                          '|| CHR(10)
                    ||'A, WPSWORKERMAST B                                                                                                                                         '|| CHR(10)
                    ||'WHERE      A.COMPANYCODE=B.COMPANYCODE                                                                                                                     '|| CHR(10)
                    ||'AND A.DIVISIONCODE=B.DIVISIONCODE                                                                                                                          '|| CHR(10)
                    ||'AND A.WORKERSERIAL=B.WORKERSERIAL                                                                                                                          '|| CHR(10)
                    ||'GROUP BY A.COMPANYCODE, A.DIVISIONCODE,A.WORKERSERIAL,PFNO,B.TOKENNO,WORKERNAME,ESINO,                                                                     '|| CHR(10)
                    ||'SUBSTR(TO_CHAR(TO_DATE(TO_CHAR(TO_DATE(A.FORTNIGHTENDDATE,''DD/MM/YYYY''),''MM''), ''MM''), ''MONTH''),1,3), DATEOFJOINING,B.WORKERCATEGORYCODE            '|| CHR(10)
                    ||')                                                                                                                                                          '|| CHR(10)
                    ||'PIVOT                                                                                                                                                      '|| CHR(10)
                    ||'(                                                                                                                                                          '|| CHR(10)
                    ||'SUM(ATN_DAYS)                                                                                                                                              '|| CHR(10)
                    ||'FOR MONTHNAME IN (''JAN'' JAN,''FEB'' FEB,''MAR'' MAR,''APR'' APR,''MAY'' MAY,''JUN'' JUN,''JUL''JUL,''AUG''AUG,''SEP''SEP,''OCT''OCT,''NOV''NOV,''DEC''DEC)'|| CHR(10)
                    ||')  A                                                                                                                                                       '|| CHR(10)
                    ||'GROUP BY COMPANYCODE, DIVISIONCODE,WORKERSERIAL,PFNO,TOKENNO,WORKERNAME, ESINO,  JAN, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV, DEC,               '|| CHR(10)
                    ||'DATEOFJOINING,WORKERCATEGORYCODE ORDER BY 1                                                                                                                '|| CHR(10)
                    ||')                                                                                                                                                          '|| CHR(10)
                    ||'A,WPSWAGESDETAILS_MV B                                                                                                                                     '|| CHR(10)
                    ||'WHERE A.COMPANYCODE=B.COMPANYCODE                                                                                                                          '|| CHR(10)
                    ||'AND A.DIVISIONCODE=B.DIVISIONCODE                                                                                                                          '|| CHR(10)
                    ||'AND A.WORKERSERIAL=B.WORKERSERIAL                                                                                                                          '|| CHR(10)
                    ||'GROUP BY SER,A.COMPANYCODE, A.DIVISIONCODE, PFNO, A.TOKENNO,WORKERNAME, ESINO,                                                                             '|| CHR(10)
                    ||'JAN, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV, DEC,TDAY,DATEOFJOINING, A.WORKERCATEGORYCODE  ,A.WORKERSERIAL                                                      '|| CHR(10)
                    ||')                                                                                                                                                          '|| CHR(10)
                    --||'A, WPSOCCUPATIONMAST B,COMPANYMAST C,(SELECT * FROM WPSWORKERMAST WHERE ACTIVE=''Y'' AND WORKERCATEGORYCODE  IN(''R'',''P'',''B'') )D                      '|| CHR(10)
                    ||'A, WPSOCCUPATIONMAST B,COMPANYMAST C,(SELECT * FROM WPSWORKERMAST WHERE  WORKERCATEGORYCODE  IN(''P'',''B'') )D                      '|| CHR(10)
                    ||'WHERE A.COMPANYCODE=B.COMPANYCODE(+)                                                                                                                       '|| CHR(10)
                    ||'AND A.DIVISIONCODE=B.DIVISIONCODE(+)                                                                                                                       '|| CHR(10)
                    ||'AND A.OCCUPATIONCODE=B.OCCUPATIONCODE(+)                                                                                                                   '|| CHR(10)
                    ||'AND D.COMPANYCODE=C.COMPANYCODE(+)                                                                                                                         '|| CHR(10)
                    ||'AND A.COMPANYCODE(+)=D.COMPANYCODE'|| CHR(10)
                    ||'AND A.DIVISIONCODE(+)=D.DIVISIONCODE'|| CHR(10)
                    ||'AND A.WORKERSERIAL(+)=D.WORKERSERIAL'|| CHR(10)
                    --||'AND WORKERCATEGORYCODE IN(''B'',''P'',''S'')'|| CHR(10)
                    ||'GROUP BY SER, D.COMPANYCODE, D.DIVISIONCODE, C.COMPANYNAME,D.PFNO, D.TOKENNO, D.WORKERNAME,D.ESINO,                                                                '|| CHR(10)
                    ||'JAN, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV, DEC, TDAY ,D.DATEOFJOINING, D.WORKERCATEGORYCODE ,D.WORKERSERIAL                                                       '|| CHR(10)
                    ||'ORDER BY D.TOKENNO                                                                                                                                               '|| CHR(10);

        DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);            
        EXECUTE IMMEDIATE LV_SQLSTR; 
        
        DELETE FROM GTT_STLDUECALENDERYEAR WHERE  NVL(STLDAY,0)+NVL(STLAVL,0)+NVL(STL,0) +NVL(TDAY,0)=0;    
     
END;
/


DROP PROCEDURE NJMCL_WEB.PROC_STLREG;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_STLREG(P_COMPANYCODE VARCHAR2,P_DIVISIONCODE VARCHAR2,P_DATEOFATTN VARCHAR2,P_DEPARTMENT VARCHAR2,P_WORKER VARCHAR2,P_SHIFT VARCHAR2)
as 
 lv_sqlstr varchar2(10000);
BEGIN

    DELETE FROM GTT_STLREG;
    
    lv_sqlstr:='INSERT INTO GTT_STLREG(TOKENNO,WORKERNAME,STLFROMDATE,STLTODATE,'||CHR(10)
                ||' STLDAYS,FORTNIGHTENDDATE,SHIFTCODE,COMPANYNAME,COMPANYADDRESS,CAPTION)'||CHR(10)
               ||'SELECT A.TOKENNO,W.WORKERNAME,A.STLFROMDATE,A.STLTODATE,A.STLDAYS,'||CHR(10)
               ||'  A.FORTNIGHTENDDATE,A.SHIFTCODE,C.COMPANYNAME,C.COMPANYADDRESS,'||CHR(10)
               ||'  ''STL ENTRY REGISTER - FOR '||P_DATEOFATTN||''' CAPTION'||CHR(10)
               ||'FROM WPSSTLENTRY A,WPSWORKERMAST W,COMPANYMAST C'||CHR(10)
               ||'WHERE A.COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
               ||'    AND A.DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
               ||'    AND TO_DATE('''||P_DATEOFATTN||''',''DD/MM/YYYY'') BETWEEN A.STLFROMDATE AND A.STLTODATE'||CHR(10)
               ||'    AND A.LEAVECODE=''STL'''||CHR(10)
               ||'    AND A.COMPANYCODE=W.COMPANYCODE'||CHR(10)
               ||'    AND A.DIVISIONCODE=W.DIVISIONCODE'||CHR(10)
               ||'    AND A.WORKERSERIAL=W.WORKERSERIAL'||CHR(10)
               ||'    AND A.COMPANYCODE=C.COMPANYCODE'||CHR(10);
   IF P_DEPARTMENT IS NOT NULL THEN
    lv_sqlstr:=lv_sqlstr||'A.DEPARTMENTCODE IN('||P_DEPARTMENT||')'||CHR(10);
   END IF;
   IF P_WORKER IS NOT NULL THEN
    lv_sqlstr:=lv_sqlstr||'A.TOKENNO IN('||P_WORKER||')'||CHR(10);
   END IF;
   IF P_SHIFT IS NOT NULL THEN
    lv_sqlstr:=lv_sqlstr||'A.SHIFTCODE IN('||P_SHIFT||')'||CHR(10);
   END IF;
   
   -- dbms_output.put_line(lv_sqlstr);
       execute immediate lv_sqlstr;
         
END;
/


DROP PROCEDURE NJMCL_WEB.PROC_STL_DATATRANSFER_ATTN;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PROC_STL_DATATRANSFER_ATTN" ( P_COMPCODE VARCHAR2,P_DIVCODE VARCHAR2,
                                               P_FNSTDT VARCHAR2,
                                               P_FNENDT VARCHAR2,
                                               P_WORKERSERIAL VARCHAR2 DEFAULT NULL)
AS 
lv_Component varchar2(32767) := '';
lv_Sql       varchar2(32767) := '';
lv_sqlerrm      varchar2(1000) := ''; 
lv_remarks      varchar2(1000) := '';
lv_parvalues    varchar2(1000) := '';
lv_SqlTemp      varchar2 (2000) := '';
lv_Cols         varchar2 (1000) := '';
lv_fn_stdt      date := to_date(P_FNSTDT,'DD/MM/YYYY');
lv_fn_endt      date := to_date(P_FNENDT,'DD/MM/YYYY');
lv_ProcName     varchar2(30) := 'PROC_STL_DATATRANSFER_ATTN';
lv_YearCode     varchar2(10) := '';
lv_DDMMYYYY     varchar2(10) := REPLACE(P_FNENDT,'/','');

begin                                  
    lv_parvalues := P_FNSTDT ||' - '||P_FNENDT;
--    DBMS_OUTPUT.PUT_LINE('TEST 0');
    select YEARCODE INTO lv_YearCode 
    from financialyear 
    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
      AND STARTDATE <= TO_DATE(P_FNSTDT,'DD/MM/YYYY')
      AND ENDDATE >= TO_DATE(P_FNENDT,'DD/MM/YYYY'); 
--    DBMS_OUTPUT.PUT_LINE('TEST 1');   
   
   if nvl(P_WORKERSERIAL,'AMALESH') = 'AMALESH' then
        DELETE FROM WPSATTENDANCEDAYWISE
        WHERE COMPANYCODE = P_COMPCODE
          AND DIVISIONCODE = P_DIVCODE
          AND DATEOFATTENDANCE >= to_date(P_FNSTDT,'DD/MM/YYYY')
          AND DATEOFATTENDANCE <= to_date(P_FNENDT,'DD/MM/YYYY')
          and ATTENDANCETAG = 'STL';
    ELSE
        DELETE FROM WPSATTENDANCEDAYWISE
        WHERE COMPANYCODE = P_COMPCODE
          AND DIVISIONCODE = P_DIVCODE
          AND DATEOFATTENDANCE >= lv_fn_stdt
          AND DATEOFATTENDANCE <= lv_fn_endt
          and ATTENDANCETAG = 'STL'
          AND WORKERSERIAL IN ( P_WORKERSERIAL );        
    END IF;
    
    lv_remarks := 'DATA INSERT INTO WPSATTENDANCEDAYWISE FROM WPSSTLTABLE';
    lv_Sql := ' INSERT INTO WPSATTENDANCEDAYWISE ( COMPANYCODE, DIVISIONCODE, YEARCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE,'||CHR(10) 
            ||' DATEOFATTENDANCE,  DEPARTMENTCODE, SECTIONCODE, OCCUPATIONCODE, SHIFTCODE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, ATTENDANCEHOURS, '||CHR(10) 
            ||' STATUTORYHOURS, BOOKNO, ATTENDANCETAG, REMARKS, '||CHR(10)
            ||' LASTMODIFIED, USERNAME, SYSROWID, MODULE, SPELLTYPE) '||CHR(10)
            ||' SELECT '''||P_COMPCODE||''' CMPANYCODE, '''||P_DIVCODE||''' DIVISIONCODE, '''||lv_YEARCODE||''' YEARCODE, TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'') FORTNIGHTSTARTDATE, TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') FORTNIGHTENDDATE, '||CHR(10)
            ||' TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') DATEOFATTENDANCE, MAX(DEPARTMENTCODE) DEPARTMENTCODE,MAX(SECTIONCODE) SECTIONCODE, MAX(OCCUPATIONCODE) OCCUPATIONCODE, nvl(MAX(SHIFTCODE),''1'') SHIFTCODE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, 0 ATTENDANCEHOURS, '||CHR(10)
            ||' SUM(NVL(STLHOURS,0)) STATUTORYHOURS,''STL/''||'''||lv_DDMMYYYY||'''||''/''||WORKERSERIAL BOOKNO, ''STL'' ATTENDANCETAG, ''STL DATA TRANSFER INTO ATTENDANCE'' REMARKS,  '||CHR(10)
            ||' SYSDATE, ''SWT'' USERNAME, '''||lv_DDMMYYYY||'''||WORKERSERIAL||''STL'' SYSROWID,''WPS'' MODULE, ''SPELL 1'' SPELLTYPE '||CHR(10) 
            ||' FROM WPSSTLENTRY '||CHR(10)
            ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'   AND FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'') '||CHR(10)
            ||'   AND FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') '||CHR(10)
            ||'   AND LEAVECODE = ''STL'' '||CHR(10);
    if nvl(P_WORKERSERIAL,'AMALESH') <> 'AMALESH' then
       lv_Sql := lv_Sql ||'    AND WORKERSERIAL ='''||P_WORKERSERIAL||''' '||CHR(10); 
    end if;                 
    lv_Sql := lv_Sql ||' GROUP BY WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE'||CHR(10);
                  
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
    EXECUTE IMMEDIATE lv_Sql;  
    COMMIT;
EXCEPTION    
    when others then
    lv_sqlerrm := sqlerrm ;
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE,lv_ProcName,lv_Sql,lv_Sql,lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
    commit;                    
                                        
end;
/


DROP PROCEDURE NJMCL_WEB.PROC_WPSSTLENTITLEMENT;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPSSTLENTITLEMENT
(p_companycode  VARCHAR2, 
p_divisioncode  VARCHAR2,
p_dept          VARCHAR2,
p_token         VARCHAR2,
p_section       VARCHAR2,
p_year          VARCHAR2,
p_option        varchar2,
p_shift         VARCHAR2 default null
)
AS
lv_sqlstr VARCHAR2(4000);
lv_company varchar2(150);
lv_division varchar2(150);

begin
    SELECT COMPANYNAME into lv_company FROM COMPANYMAST WHERE COMPANYCODE=p_companycode;     
    SELECT DIVISIONNAME into lv_division FROM DIVISIONMASTER WHERE COMPANYCODE=p_companycode AND DIVISIONCODE=p_divisioncode;       

 DELETE FROM GTT_WPSSTLENTITLEMENT;   
 LV_SQLSTR:='INSERT INTO GTT_WPSSTLENTITLEMENT  
             (COMPANYCODE, DIVISIONCODE,COMPANYNAME,EX6, TOKENNO, WORKERNAME, DEPARTMENTCODE, EX1,SHIFTCODE, EX14, HOLIDAYHOURS, 
             STANDARDSTLHOURS, ADJUSTEDHOURS, STLDAYS_BF, STLDAYS, STLHRSTAKEN,   IS_RET_LEFT, CLOSING,EX5,EX7, ENTDAYS,EX8, EX13,EX12,EX15,EX9)   
           
            SELECT A.COMPANYCODE, A.DIVISIONCODE,'''||lv_company||''' AS COMPANYNAME,'''||lv_division||''' AS DIVISIONNAME, 
            TOKENNO, WORKERNAME, DEPARTMENTCODE, SECTIONCODE,SHIFTCODE,  ATTNDAYS, HOLIDAYHOURS, STANDARDSTLHOURS, ADJUSTEDHOURS, 
            STLDAYS_BF, STLDAYSTAKEN, STLHRSTAKEN,STLDAYS_BF, STLDAYS_BF+ STLDAYS CLOSING,
            ''STATUTORY LEAVE ENTITLEMENT LIST FOR THE YEAR '','||p_year||' ||'' ('||p_option||')'' EX5,STLDAYS  EX7, 
            STLDAYS ENT,DEPARTMENTNAME,GRACEDAYS,
            CASE WHEN STLDAYS>0 THEN '' * ENT'' ELSE '' * NOT ENT'' END EX15 , '||p_year||' EX9      
             FROM 
            (   
                SELECT A.COMPANYCODE,A.DIVISIONCODE,A.TOKENNO,B.WORKERNAME,A.DEPARTMENTCODE,B.SECTIONCODE, A.YEARCODE,   
                    DECODE(B.SHIFT,''1'',''B'',''2'',''G'',''3'',''R'',''B'',''B'',''G'',''G'',''R'',''R'',''BLUE'',''B'',''GREEN'',''G'',''RED'',''R'') SHIFTCODE,A.ATTNDAYS,A.HOLIDAYHOURS,  
                    A.STANDARDSTLHOURS,A.ADJUSTEDHOURS,NVL(A.STLDAYS_BF,0) STLDAYS_BF,STLDAYSTAKEN,NVL(A.STLDAYS,0) STLDAYS,
                    nvl(TOTALWORKINGDAYS,0)TOTALWORKINGDAYS , A.STLHRSTAKEN,DEPARTMENTNAME , GRACEDAYS               
                    FROM WPSSTLENTITLEMENTCALCDETAILS A,WPSWORKERMAST B,DEPARTMENTMASTER C
                WHERE A.COMPANYCODE=B.COMPANYCODE  
                    AND A.DIVISIONCODE=B.DIVISIONCODE  
                    AND A.WORKERSERIAL=B.WORKERSERIAL
                    AND A.COMPANYCODE=C.COMPANYCODE  
                    AND A.DIVISIONCODE=C.DIVISIONCODE  
                    AND A.DEPARTMENTCODE=C.DEPARTMENTCODE                        
                    --AND A.YEARCODE IN ('||p_year||') 
                    AND A.COMPANYCODE='''||p_companycode||''' 
                    AND A.DIVISIONCODE='''||p_divisioncode||'''  ';
                    
         if p_token is not null then
            lv_sqlstr :=lv_sqlstr || ' AND A.TOKENNO in ('||p_token||')  ';
         end if;
         
         if p_section is not null then
            lv_sqlstr :=lv_sqlstr || ' AND B.SECTIONCODE in ('||p_section||')  ';
         end if;
         
         if p_dept is not null then
            lv_sqlstr :=lv_sqlstr || ' AND A.DEPARTMENTCODE in ('||p_dept||')  ';
         end if;
         
         if p_year is not null then
--            lv_sqlstr :=lv_sqlstr || ' AND A.YEARCODE in ('||p_year||')  ';
                lv_sqlstr :=lv_sqlstr || ' AND A.FROMYEAR in ('||p_year||')  ';
         end if;  
         
         
          if p_shift is not null then
--            lv_sqlstr :=lv_sqlstr || ' AND A.YEARCODE in ('||p_year||')  ';
                lv_sqlstr :=lv_sqlstr || ' AND DECODE(B.SHIFT,''B'',''1'',''G'',''2'',''R'',''3'',''B'',''B'',''G'',''G'',''R'',''R'') in ('||p_shift||') ';
         end if;                                     
                                    
         lv_sqlstr :=lv_sqlstr || '    ) A  WHERE 1=1 '   ;
                        
         if p_option ='Entitled' then
           lv_sqlstr :=lv_sqlstr || ' AND STLDAYS>0  ';
         end if;
         
         if p_option ='Not Entitled' then
           lv_sqlstr :=lv_sqlstr || ' AND STLDAYS=0    ';
         end if;                                     
        
        lv_sqlstr :=lv_sqlstr || ' order by DEPARTMENTCODE,DECODE(SHIFTCODE,''B'',''1'',''G'',''2'',''R'',''3'') ,TOKENNO ';

       --   dbms_output.put_line (lv_sqlstr);
         EXECUTE  IMMEDIATE lv_sqlstr;
                  
end ;
/


DROP PROCEDURE NJMCL_WEB.PROC_WPSSTLPROCESS;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPSSTLPROCESS(P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2, 
                                                  P_YEARCODE Varchar2,
                                                  P_FN_STDT Varchar2, 
                                                  P_FN_ENDT Varchar2,
                                                  P_PHASE  number  DEFAULT NULL, 
                                                  P_PHASE_TABLENAME VARCHAR2  DEFAULT NULL,
                                                  P_TABLENAME Varchar2  DEFAULT NULL,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL,
                                                  P_PROCESSTYPE  VARCHAR2 DEFAULT 'STL PROCESS')                                                 
as
lv_Component varchar2(32767) := '';
lv_Sql       varchar2(32767) := '';
lv_ComponentNew  varchar2(32767) := '';
lv_Sql_TblCreate    varchar2(3000) := '';  
lv_sqlerrm      varchar2(1000) := ''; 
lv_ProcName     varchar2(30) := 'PROC_WPSSTLPROCESS';
lv_remarks      varchar2(1000) := '';
lv_parvalues    varchar2(1000) := '';
lv_SqlTemp      varchar2 (2000) := '';
lv_Cols         varchar2 (1000) := '';
lv_fn_stdt      date := to_date(P_FN_STDT,'DD/MM/YYYY');
lv_fn_endt      date := to_date(P_FN_STDT,'DD/MM/YYYY');
lv_mn_stdt      date := to_date('01/'||substr(P_FN_STDT,4),'DD/MM/YYYY');
lv_MinimumPayableAmt    number := 0;            -- use for Minimum payment amount which defined in the WPSWAGESPARAMETER TABLE 
lv_RoundOffRs           number := 0;            -- use for Round Off Rs. which defined in the WPSWAGESPARAMETER TABLE
lv_ESI_E_Perc           number := 0.75;         -- USE FOR ESI EMPLOYEE CONTRIBUTION
lv_ProcessType  varchar2(50):= 'FORTNIGHTLY';   -- use for wage process Fortnightly or Monthly which defined in the WPSWAGESPARAMETER TABLE MAINLY REQUIRE FOR P.TAX CALCULATION 
lv_WagesAsOn    number(11,2) := 0;
lv_TempVal      number(11,2) :=0;
lv_TempDednAmt  number(11,2) := 0;
lv_TempDednAmt_Prev number(11,2) :=0;
lv_intCnt       number(5) :=0;
lv_GrossWages   number(11,2) := 0;
lv_PREV_FN_PTAXGROSS        NUMBER(11,2):= 0;
lv_PREV_FN_PTAX             NUMBER(11,2):= 0;
lv_PREV_FN_PFGROSS          NUMBER(11,2):=0;
lv_PREV_FN_ESIGROSS         NUMBER(11,2) := 0;
lv_PREV_FN_ESI_E            NUMBER(11,2):=0;
lv_PREV_FN_PF_E             NUMBER(11,2):=0;
lv_PREV_FN_VPF              number(11,2) := 0;
lv_VPF_PERCENT              number(11,2) :=0;
lv_ESICOMPANYPERCENT        number(11,2) :=0;
lv_PENSION_PERCENTAGE number(11,2) :=0;
lv_MAXIMUMPENSIONGROSS number(11,2) :=0;
lv_TotalDedn    number(11,2) := 0;
lv_CoinBf       number(11,2) := 0;
lv_CoinCf       number(11,2) := 0;
lv_strWorkerSerial  varchar2(10) :='';
lv_SrlNo        number   :=1;                    -- varaible use for serially which No. execute; 
lv_RowType_Prev_Data    GTT_WPS_PREV_FNDATA%ROWTYPE;
lv_RoundoffType varchar2(1) :='';
lv_EMI_DEDN_TYPE    varchar2(20):='PARTIAL';
lv_PFLN_CAP_STOP    varchar2(1) :='N';
lv_PFLN_INT_STOP    varchar2(1) :='N';
lv_CNT          number(11,2) := 0;
lv_SqlStr        varchar2(32767) := '';
lv_PolicyNo     varchar2(50) := ''; 
lv_PF_PERCENT   number(5) := 10;
lv_MAX_PFGROSS  number(11,2) := 0;
lv_MAX_PF_CONT  number(11,2) :=0;
lv_fn_LastDailyWagesDT  date := to_date(P_FN_ENDT,'DD/MM/YYYY'); --- NEW ADD ON 21.04.2020 FOR DAILY WAGES AND WEEKLY STL PAYMENT
lv_YYYYMM       varchar2(6) := to_char(lv_fn_stdt,'YYYYMM');   --- NEW ADD ON 21.04.2020 FOR DAILY WAGES AND WEEKLY STL PAYMENT 

lv_TempTable    varchar2(50) := 'WPSSTLRATE_TEMP'; 
lv_PF_E_Amt number(11,2) := 0; 
lv_ESI_Amt number(11,2) := 0; 
lv_FPF_Amt number(11,2) := 0; 
begin
    
    

    SELECT nvl(MINIMUMSALARYPAYABLE,0) MINIMUMSALARYPAYABLE, nvl(ROUNDOFFRS,0) ROUNDOFFRS, 
    nvl(PROCESSTYPE,'FORTNIGHTLY') PROCESSTYPE,ROUNDOFFTYPE, nvl(ESIEMLPLOYEEPERCENT,0) ESIEMLPLOYEEPERCENT,
    NVL(PFEMLPLOYEEPERCENT,0) PFEMLPLOYEEPERCENT,  NVL(MAXIMUMPFGROSS,0) MAXIMUMPFGROSS,  NVL(MAXIMUMPF,0) MAXIMUMPF,
    PENSION_PERCENTAGE,MAXIMUMPENSIONGROSS,ESICOMPANYPERCENT
    INTO lv_MinimumPayableAmt, lv_RoundOffRs, lv_ProcessType , lv_RoundoffType, lv_ESI_E_Perc,
    lv_PF_PERCENT, lv_MAX_PFGROSS, lv_MAX_PF_CONT,
    lv_PENSION_PERCENTAGE,lv_MAXIMUMPENSIONGROSS,lv_ESICOMPANYPERCENT
    FROM WPSWAGESPARAMETER WHERE COMPANYCODE= P_COMPCODE AND DIVISIONCODE = P_DIVCODE;

    PROC_WPSWORKERRATE(P_COMPCODE,P_DIVCODE,P_FN_STDT,'GBL_WORKERRATE_ASON',P_PROCESSTYPE);
    
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE '||lv_TempTable;
    EXCEPTION
        WHEN OTHERS THEN NULL;    
    END;
    lv_Remarks := '0 STL HOURLY TABLE CREATION';
    lv_Sql := ' CREATE TABLE '||lv_TempTable||' AS '||CHR(10)
            ||' SELECT B.WORKERSERIAL, B.BASIC, A.DA, A.ADHOC, A.TSA, (ROUND(B.BASIC/48,5) + ROUND((NVL(A.DA,0)+NVL(A.ADHOC,0)+NVL(A.TSA,0))/208,5)) STL_HRS_RATE '||chr(10)
            ||' FROM GBL_WORKERRATE_ASON A,  '||chr(10)
            ||' (  '||chr(10)
            ||'     SELECT WORKERSERIAL, NVL(MAX(STLRATE),0) BASIC  '||chr(10)
            ||'     FROM WPSSTLENTRY  '||chr(10)
            ||'     WHERE COMPANYCODE ='''||P_COMPCODE||''' AND DIVISIONCODE ='''||P_DIVCODE||'''  '||chr(10)
            ||'       AND PAYMENTDATE='''||lv_FN_STDT||'''  '||chr(10)
            ||'     GROUP BY WORKERSERIAL  '||chr(10)
            ||' ) B  '||chr(10)
            ||' WHERE A.WORKERSERIAL = B.WORKERSERIAL  '||chr(10);
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
    COMMIT;
    EXECUTE IMMEDIATE lv_Sql;
    COMMIT;
                
    
    lv_Remarks := '1 DELETE FROM  WPSSTLWAGESDETAILS';
    lv_Sql := ' DELETE FROM WPSSTLWAGESDETAILS '||chr(10)
            ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  AND YEARCODE='''||P_YEARCODE||''''||chr(10)
            ||'   AND PAYMENTDATE >= '''||lv_FN_STDT||''' '||chr(10)
            ||'   AND PAYMENTDATE <= '''||lv_FN_ENDT||''' '||chr(10);
    EXECUTE IMMEDIATE lv_Sql;
    COMMIT;
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);

    --- START BELOW BLOCK CONSIDER FOR PREVIOUS PAYMENT WIHCH CONSIDER IN CURRENT WAGES PAYMENT FOR REFERES IN DEDUCTION STATEMENT
    DELETE FROM GTT_WPS_PREV_FNDATA;
    lv_Sql := ' INSERT INTO GTT_WPS_PREV_FNDATA (WORKERSERIAL, PF_GROSS, PENSION_GROSS, PF_CONT, PF_COM, FPF, VPF, '||chr(10) 
        ||' ESI_GROSS, ESI_CONT, ESI_COMP_CONT, GROSS_PTAX, P_TAX ) '||chr(10)
        ||' SELECT WORKERSERIAL, SUM(PF_GROSS) PF_GROSS, SUM(PENSION_GROSS) PENSION_GROSS, SUM(PF_CONT) PF_CONT, SUM(PF_COM) PF_COM, SUM(FPF) FPF, SUM(VPF) VPF, '||chr(10) 
        ||' SUM(ESI_GROSS) ESI_GROSS, SUM(ESI_CONT) ESI_CONT, SUM(ESI_COMP_CONT) ESI_COMP_CONT, SUM(GROSS_PTAX) GROSS_PTAX, SUM(P_TAX) P_TAX '||chr(10)
        ||' FROM ('||chr(10)
        ||'      SELECT WORKERSERIAL, NVL(PF_GROSS,0) PF_GROSS, NVL(PENSION_GROSS,0) PENSION_GROSS, NVL(PF_CONT,0) PF_CONT, NVL(PF_COM,0) PF_COM, NVL(FPF,0) FPF, NVL(VPF,0) VPF, '||chr(10) 
        ||'      NVL(ESI_GROSS,0) ESI_GROSS, NVL(ESI_CONT,0) ESI_CONT, NVL(ESI_COMP_CONT,0) ESI_COMP_CONT, NVL(GROSS_PTAX,0) GROSS_PTAX, NVL(P_TAX,0) P_TAX  '||chr(10)
        ||'      FROM WPSWAGESDETAILS_MV  '||chr(10)
        ||'      WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
        ||'        AND FORTNIGHTSTARTDATE >= '''||lv_mn_stdt||'''   '||chr(10)
        ||'        AND FORTNIGHTSTARTDATE <  TO_DATE('''||P_FN_STDT||''',''DD/MM/YYYY'')  '||chr(10) 
--        ||'        AND FORTNIGHTENDDATE = to_date(''15/''||substr('''||P_FN_ENDT||''',4,7),''dd/mm/yyyy'')  '||chr(10)
        ||'      UNION ALL '||chr(10)          
        ||'      SELECT WORKERSERIAL, NVL(PF_GROSS,0) PF_GROSS,  NVL(PENSION_GROSS,0) PENSION_GROSS, NVL(PF_E,0) PF_CONT, NVL(PF_C,0) PF_COM, NVL(FPF,0) FPF, 0 VPF, '||chr(10) 
        ||'      NVL(ESI_GROSS,0) ESI_GROSS, NVL(ESI_E,0) ESI_CONT, NVL(ESI_C,0) ESI_COMP_CONT, NVL(GROSS_PTAX,0) GROSS_PTAX, NVL(P_TAX,0) P_TAX '||chr(10)
        ||'      FROM WPSSTLWAGESDETAILS '||chr(10)
        ||'      WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
        ||'        AND YEARCODE = '''||P_YEARCODE||'''   '||chr(10)
        ||'        AND PAYMENTDATE >= '''||lv_mn_stdt||'''   '||chr(10)
        ||'        AND PAYMENTDATE < TO_DATE('''||P_FN_STDT||''',''DD/MM/YYYY'') '||chr(10)
        --||'        AND PAYMENTDATE <= to_date('''||lv_fn_LastDailyWagesDT||''') '||chr(10)
        ||'      ) GROUP BY WORKERSERIAL '||CHR(10);
    lv_remarks := '2 PREVIOUS WAGES PAYMENT DATA INSERT INTO GTT_WPS_PREV_FNDATA';      
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
    COMMIT;
    EXECUTE IMMEDIATE lv_Sql;    
    COMMIT;
    
    
    
        DELETE FROM WPSSTLWAGESDETAILS_SWT;
        
        COMMIT;
        
        lv_remarks := '3 INSERT INTO  WPSSTLWAGESDETAILS_SWT   STL DATA';    
--        BELOW QUERY CHANGES BY AMALESH ON 03.06.2020  
--        lv_Sql := 'INSERT INTO  WPSSTLWAGESDETAILS_SWT '||CHR(10)
--        ||'SELECT STL.COMPANYCODE,STL.DIVISIONCODE,STL.YEARCODE,STL.DOCUMENTDATE,STL.WORKERSERIAL,STL.TOKENNO,WORKERCATEGORYCODE,'||CHR(10)
--        ||'SHIFTCODE,DEPARTMENTCODE,SECTIONCODE,OCCUPATIONCODE,'||CHR(10)
--        ||'0 ATTENDANCEHOURS,SUM(STLHOURS)STLHOURS,0 OVERTIMEHOURS,SUM(STLHOURS_RATE) STLAMOUNT,SUM(STLDAYS)STLDAYS,0 OTHER_EARN,'||CHR(10)
--        ||'0 BASIC,0 DA,0 ADHOC,0 HRA,0 HRS_RATE,'||CHR(10)
--        ||'SUM(STLHOURS_RATE) PF_GROSS,SUM(STLHOURS_RATE) ESI_GROSS,SUM(STLHOURS_RATE) GROSS_PTAX,'||CHR(10)
--        ||'SUM(STLHOURS_RATE) GROSS_WAGES,SUM(STL_A.PF_GROSS) TOTAL_EARN,'||CHR(10)
--        ||'SUM(ROUND((NVL(STL_A.PF_GROSS,0)+NVL(LD.PF_GROSS,0))*'||lv_PF_PERCENT||'*0.01,0)-NVL(LD.PF_CONT,0)) PF_E,'||CHR(10)
--        ||'SUM(CASE WHEN LD.PF_GROSS>0 THEN  (ceil((NVL(STL_A.PF_GROSS,0)+NVL(LD.PF_GROSS,0))*0.01*'||lv_ESI_E_Perc||'))-LD.ESI_CONT  ELSE  ceil(NVL(STL_A.PF_GROSS,0)*0.01*'||lv_ESI_E_Perc||')-LD.ESI_CONT END) ESI_E,'||CHR(10)
--        ||'SUM(CASE WHEN (NVL(STL_A.PF_GROSS,0)+NVL(LD.PF_GROSS,0))<='||lv_MAXIMUMPENSIONGROSS||' THEN  (ceil((NVL(STL_A.PF_GROSS,0)+NVL(LD.PF_GROSS,0))*0.01*'||lv_PENSION_PERCENTAGE||'))-NVL(LD.FPF,0) ELSE  ceil(NVL('||lv_MAXIMUMPENSIONGROSS||',0)*0.01*'||lv_PENSION_PERCENTAGE||') -NVL(LD.FPF,0) END) FPF,'||CHR(10)
--        ||'0 PF_C,'||CHR(10)
--        ||'SUM(CASE WHEN LD.PF_GROSS>0 THEN  (ceil((NVL(STL_A.PF_GROSS,0)+NVL(LD.PF_GROSS,0))*0.01*'||lv_ESICOMPANYPERCENT||'))-LD.ESI_CONT  ELSE  ceil(NVL(STL_A.PF_GROSS,0)*0.01*'||lv_ESICOMPANYPERCENT||')-LD.ESI_CONT END) ESI_C,'||CHR(10)
--        ||'0 OTHER_DEDN,'||CHR(10)
--        ||'0 COINBF,0 COINCF,0 TOTAL_DEDN,0 NETPAY,''STL'' TRANTYPE,STLFROMDATE LEAVEFROM,STLTODATE LEAVETO,''SWT'' USERNAME,'||CHR(10)
--        ||'SYSDATE LASTMODIFIED,FN_GENERATE_SYSROWID,'||CHR(10)
--        ||'0 PENSION_GROSS,'||CHR(10)
--        ||'SUM(NVL((CASE WHEN '''||lv_ProcessType||''' =''MONTHLY'' THEN '||CHR(10)
--        ||'(SELECT NVL(PTAXAMOUNT,0) FROM PTAXSLAB'||CHR(10)
--        ||'                    WHERE 1=1'||CHR(10)
--        ||'                      AND STATENAME = ''WEST BENGAL'''||CHR(10)
--        ||'                      AND WITHEFFECTFROM = ( SELECT MAX(WITHEFFECTFROM) FROM PTAXSLAB WHERE STATENAME = ''WEST BENGAL'' AND WITHEFFECTFROM <= '''||lv_FN_STDT||''')'||CHR(10)
--        ||'                      AND SLABAMOUNTFROM <= NVL(STL_A.PF_GROSS,0)'||CHR(10)
--        ||'                      AND SLABAMOUNTTO >= NVL(STL_A.PF_GROSS,0) AND ROWNUM=1'||CHR(10)
--        ||')ELSE'||CHR(10)
--        ||'(SELECT NVL(PTAXAMOUNT,0) FROM PTAXSLAB'||CHR(10)
--        ||'                    WHERE 1=1'||CHR(10)
--        ||'                      AND STATENAME = ''WEST BENGAL'''||CHR(10)
--        ||'                      AND WITHEFFECTFROM = ( SELECT MAX(WITHEFFECTFROM) FROM PTAXSLAB WHERE STATENAME = ''WEST BENGAL'' AND WITHEFFECTFROM <= '''||lv_FN_STDT||''')'||CHR(10)
--        ||'                      AND SLABAMOUNTFROM <= (NVL(STL_A.PF_GROSS,0)+NVL(LD.GROSS_PTAX,0)) '||CHR(10)
--        ||'                      AND SLABAMOUNTTO >= (NVL(STL_A.PF_GROSS,0)+NVL(LD.GROSS_PTAX,0))  AND ROWNUM=1'||CHR(10)
--        ||')-NVL(LD.P_TAX,0) END),0)) P_TAX'||CHR(10)
--        ||'FROM WPSSTLENTRY STL,GTT_WPS_PREV_FNDATA LD,'||CHR(10)
--        ||'('||CHR(10)
--        ||'SELECT COMPANYCODE,DIVISIONCODE,YEARCODE,YEAR,FORTNIGHTSTARTDATE,FORTNIGHTENDDATE,DOCUMENTDATE,WORKERSERIAL,'||CHR(10)
--        ||'ROUND(NVL(STLHOURS,0)*(NVL(STLRATE,0)/48),2) STLHOURS_RATE,'||CHR(10)
--        ||'ROUND(NVL(STLHOURS,0)*(NVL(STLRATE,0)/48),2) PF_GROSS'||CHR(10)
--        ||'FROM WPSSTLENTRY'||CHR(10)
--        ||'WHERE 1=1'||CHR(10)
--        ||'AND COMPANYCODE='''||P_COMPCODE||''''||CHR(10)
--        ||'AND DIVISIONCODE='''||P_DIVCODE||''''||CHR(10)
--        ||'AND YEARCODE='''||P_YEARCODE||''' --AND WORKERSERIAL=''002253'''||CHR(10)
--        ||'AND DOCUMENTDATE>= '''||lv_FN_STDT||''''||CHR(10)
--        ||'AND DOCUMENTDATE<=  '''||lv_FN_ENDT||''''||CHR(10)
--        ||')STL_A'||CHR(10)
--        ||'WHERE 1=1 AND STL.WORKERSERIAL=LD.WORKERSERIAL(+) '||CHR(10)
--        ||'AND STL.COMPANYCODE=STL_A.COMPANYCODE(+)'||CHR(10)
--        ||'AND STL.DIVISIONCODE=STL_A.DIVISIONCODE(+)'||CHR(10)
--        ||'AND STL.YEARCODE=STL_A.YEARCODE(+)'||CHR(10)
--        ||'AND STL.FORTNIGHTSTARTDATE=STL_A.FORTNIGHTSTARTDATE(+)'||CHR(10)
--        ||'AND STL.FORTNIGHTENDDATE=STL_A.FORTNIGHTENDDATE(+)'||CHR(10)
--        ||'AND STL.DOCUMENTDATE=STL_A.DOCUMENTDATE(+)'||CHR(10)
--        ||'AND STL.WORKERSERIAL=STL_A.WORKERSERIAL(+)'||CHR(10)
--        ||'AND STL.YEAR=STL_A.YEAR(+)'||CHR(10)
--        ||'AND STL.COMPANYCODE='''||P_COMPCODE||''' '||CHR(10)
--        ||'AND STL.DIVISIONCODE='''||P_DIVCODE||''''||CHR(10)
--        ||'AND STL.YEARCODE='''||P_YEARCODE||''' --AND WORKERSERIAL=''002253'''||CHR(10)
--        ||'AND STL.DOCUMENTDATE>= '''||lv_FN_STDT||''''||CHR(10)
--        ||'AND STL.DOCUMENTDATE<=  '''||lv_FN_ENDT||''''||CHR(10)
--        ||'GROUP BY '||CHR(10)
--        ||'STL.COMPANYCODE,STL.DIVISIONCODE,STL.YEARCODE,STL.DOCUMENTDATE,STL.WORKERSERIAL,STL.TOKENNO,WORKERCATEGORYCODE,'||CHR(10)
--        ||'SHIFTCODE,DEPARTMENTCODE,SECTIONCODE,OCCUPATIONCODE,STLFROMDATE,STLTODATE'||CHR(10);
       
    lv_Sql := ' INSERT INTO  WPSSTLWAGESDETAILS_SWT ( '||chr(10)
            ||' COMPANYCODE, DIVISIONCODE, YEARCODE, PAYMENTDATE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, '||chr(10) 
            ||' SHIFTCODE, DEPARTMENTCODE, SECTIONCODE, OCCUPATIONCODE, DEPTSERIAL, SERIALNO, STLHOURS, STLDAYS, STLAMOUNT,  OTHER_EARN,  '||chr(10) 
            ||' HRS_RATE, PF_GROSS, ESI_GROSS, GROSS_PTAX, GROSS_WAGES, TOTAL_EARN, PF_E, ESI_E, FPF, PF_C, ESI_C, OTHER_DEDN, COINBF, COINCF, TOTAL_DEDN, NETPAY,  '||chr(10) 
            ||' TRANTYPE, LEAVEFROM, LEAVETO, USERNAME, LASTMODIFIED, SYSROWID, PENSION_GROSS, P_TAX, LEAVEENCASHMENT ) '||chr(10)

            ||' SELECT S.COMPANYCODE, S.DIVISIONCODE, S.YEARCODE, S.PAYMENTDATE, S.WORKERSERIAL, M.TOKENNO, M.WORKERCATEGORYCODE, '||chr(10) 
            ||' S.SHIFTCODE, S.DEPARTMENTCODE, S.SECTIONCODE, S.OCCUPATIONCODE, S.DEPTSERIAL, S.SERIALNO, S.STLHOURS, S.STLDAYS, S.STLAMOUNT, 0 OTHER_EARN,  '||chr(10) 
            ||' S.HRS_RATE, S.STLAMOUNT PF_GROSS, S.STLAMOUNT ESI_GROSS, S.STLAMOUNT GROSS_PTAX, S.STLAMOUNT GROSS_WAGES, S.STLAMOUNT TOTAL_EARN,  '||chr(10)
            ||' (ROUND((S.STLAMOUNT+NVL(P.PF_GROSS,0))*'||lv_PF_PERCENT||'*0.01,0)- NVL(P.PF_CONT,0)) PF_E, '||CHR(10)
--            ||' (ROUND((S.STLAMOUNT+NVL(P.ESI_GROSS,0))*'||lv_ESI_E_Perc||'*0.01,0)- NVL(P.ESI_CONT,0)) ESI_E, '||chr(10)
            ||' (CEIL(TRUNC(ROUND(S.STLAMOUNT+NVL(P.ESI_GROSS,0),0)*'||lv_ESI_E_Perc||'*0.01,2))-NVL(P.ESI_CONT,0)) ESI_E, '||CHR(10)
--            ||' CASE WHEN (NVL(S.STLAMOUNT,0)+NVL(P.PF_GROSS,0))<= '||lv_MAXIMUMPENSIONGROSS||' THEN  (ceil((NVL(S.STLAMOUNT,0)+NVL(P.PF_GROSS,0))*0.01*8.33))-NVL(P.FPF,0) ELSE  ceil(NVL('||lv_MAXIMUMPENSIONGROSS||',0)*0.01*'||lv_PENSION_PERCENTAGE||') -NVL(P.FPF,0) END FPF, '||CHR(10)
            ||' CASE WHEN NVL(M.EPFAPPLICABLE,''N'') =''N'' THEN 0 ELSE CASE WHEN (NVL(S.STLAMOUNT,0)+NVL(P.PF_GROSS,0))<= '||lv_MAXIMUMPENSIONGROSS||' THEN  (ROUND(ROUND((NVL(S.STLAMOUNT,0)+NVL(P.PF_GROSS,0)),0)*0.01*8.33,0))-NVL(P.FPF,0) ELSE  ROUND(NVL('||lv_MAXIMUMPENSIONGROSS||',0)*0.01*'||lv_PENSION_PERCENTAGE||',0) -NVL(P.FPF,0) END END FPF, '||CHR(10)
            ||' 0 PF_C, CASE WHEN NVL(P.PF_GROSS,0)>0 THEN  (ceil((NVL(S.STLAMOUNT,0)+NVL(P.PF_GROSS,0))*0.01*3.25))-NVL(P.ESI_CONT,0)  ELSE  ceil(NVL(S.STLAMOUNT,0)*0.01*3.25)- NVL(P.ESI_CONT,0) END ESI_C, '||chr(10) 
            ||' 0 OTHER_DEDN, 0 COINBF, 0 COINCF, 0 TOTAL_DEDN, 0 NETPAY,  '||chr(10)
            ||' ''STL'' TRANTYPE, STLFROMDATE LEAVEFROM, STLTODATE LEAVETO, ''SWT'' USERNAME, SYSDATE LASTMODIFIED, SYS_GUID() SYSROWID, 0 PENSION_GROSS, 0 P_TAX, LEAVEENCASHMENT '||chr(10)
            ||' FROM WPSWORKERMAST M, GTT_WPS_PREV_FNDATA P, '||chr(10)
            ||' ( '||chr(10)
            ||'     SELECT A.COMPANYCODE, A.DIVISIONCODE, A.YEARCODE, A.PAYMENTDATE, A.WORKERSERIAL, '||chr(10) 
            ||'     A.SHIFTCODE, A.DEPARTMENTCODE, A.SECTIONCODE, MAX(A.OCCUPATIONCODE) OCCUPATIONCODE, MAX(A.STLSERIALNO) DEPTSERIAL, MAX(A.STLSERIALNO) SERIALNO '||chr(10)
            ||'     ,A.STLFROMDATE, A.STLTODATE, NVL(A.LEAVEENCASHMENT,''N'') LEAVEENCASHMENT,'||chr(10)
            ||'     SUM(STLDAYS) STLDAYS, SUM(STLHOURS) STLHOURS, B.STL_HRS_RATE HRS_RATE, ROUND((B.STL_HRS_RATE*SUM(STLHOURS)),2) STLAMOUNT '||chr(10)
            ||'     FROM WPSSTLENTRY A, '||lv_TempTable||' B  '||chr(10)
            ||'     WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
            ||'       AND A.PAYMENTDATE >= '''||lv_FN_STDT||''' AND A.PAYMENTDATE <='''||lv_FN_ENDT||''' '||chr(10)
            ||'       AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
            ||'     GROUP BY A.COMPANYCODE, A.DIVISIONCODE, A.YEARCODE, A.PAYMENTDATE, A.WORKERSERIAL,  '||chr(10)
            ||'     A.SHIFTCODE, A.DEPARTMENTCODE, A.SECTIONCODE, A.STLFROMDATE, A.STLTODATE, B.STL_HRS_RATE, NVL(A.LEAVEENCASHMENT,''N'') '||chr(10)
            ||' ) S  '||chr(10)
            ||' WHERE M.COMPANYCODE = '''||P_COMPCODE||''' AND M.DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
            ||'   AND M.COMPANYCODE = S.COMPANYCODE AND M.DIVISIONCODE = S.DIVISIONCODE AND M.WORKERSERIAL = S.WORKERSERIAL '||chr(10)
            ||'   AND S.WORKERSERIAL = P.WORKERSERIAL (+) '||chr(10);
        
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
    COMMIT;
    EXECUTE IMMEDIATE lv_Sql;    
    COMMIT;

    lv_Remarks := '4_1 UPDATE DEDUCTION HEADS TO ZERO FROM LEAVEENCASMENT IN WPSSTLWAGESDETAILS_SWT';
    lv_Sql := ' UPDATE WPSSTLWAGESDETAILS_SWT SET PF_E = 0,FPF=0, PF_C=0, ESI_E=0, ESI_C=0, P_TAX=0,PF_GROSS = 0, ESI_GROSS =0 , GROSS_PTAX =0 '||CHR(10)
        ||' , TRANTYPE =''STL ENCASHMENT'' WHERE NVL(LEAVEENCASHMENT,''N'') =''Y'' '||chr(10);
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
    COMMIT;
    EXECUTE IMMEDIATE lv_Sql;    
    COMMIT;


    lv_Remarks := '4_2 UPDATE PF_C,TOTAL_DEDN,NETPAY  WPSSTLWAGESDETAILS_SWT';
    lv_Sql := 'UPDATE WPSSTLWAGESDETAILS_SWT SET PF_C=PF_E-FPF,TOTAL_DEDN=NVL(PF_E,0)+NVL(ESI_E,0)+NVL(P_TAX,0)+NVL(OTHER_DEDN,0),NETPAY=TOTAL_EARN-(NVL(PF_E,0)+NVL(ESI_E,0)+NVL(P_TAX,0)+NVL(OTHER_DEDN,0))'||chr(10);
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
    COMMIT;
    EXECUTE IMMEDIATE lv_Sql;    
    COMMIT;
   
    lv_Remarks := '5 INESERT IN WPSSTLWAGESDETAILS ';

     lv_Sql := 'INSERT INTO WPSSTLWAGESDETAILS'||chr(10)
         ||'('||chr(10)
         ||'COMPANYCODE, DIVISIONCODE, YEARCODE, PAYMENTDATE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, SHIFTCODE,'||chr(10)
         ||'DEPARTMENTCODE, SECTIONCODE, OCCUPATIONCODE, DEPTSERIAL, SERIALNO, ATTENDANCEHOURS, STLHOURS, OVERTIMEHOURS, STLAMOUNT, '||chr(10)
         ||'STLDAYS, OTHER_EARN, BASIC, DA, ADHOC, HRA, HRS_RATE, PF_GROSS, ESI_GROSS, GROSS_PTAX, GROSS_WAGES, '||chr(10)
         ||'TOTAL_EARN, PF_E, ESI_E, FPF, PF_C, ESI_C, OTHER_DEDN, COINBF, COINCF, TOTAL_DEDN, NETPAY, TRANTYPE, '||chr(10)
         ||'LEAVEFROM, LEAVETO, USERNAME, LASTMODIFIED, SYSROWID, PENSION_GROSS, P_TAX, LEAVEENCASHMENT'||chr(10)
         ||')'||chr(10)
         ||'SELECT '||chr(10)
         ||'COMPANYCODE, DIVISIONCODE, YEARCODE,PAYMENTDATE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, SHIFTCODE,'||chr(10)
         ||'DEPARTMENTCODE, SECTIONCODE, OCCUPATIONCODE, DEPTSERIAL, SERIALNO, 0 ATTENDANCEHOURS, STLHOURS, 0 OVERTIMEHOURS, STLAMOUNT, '||chr(10)
         ||'STLDAYS, OTHER_EARN, 0 BASIC, 0 DA, 0 ADHOC, 0 HRA, HRS_RATE, PF_GROSS, ESI_GROSS, GROSS_PTAX, GROSS_WAGES, '||chr(10)
         ||'TOTAL_EARN, PF_E, ESI_E, FPF, PF_C, ESI_C, OTHER_DEDN, COINBF, COINCF, TOTAL_DEDN, NETPAY, TRANTYPE, '||chr(10)
         ||'LEAVEFROM, LEAVETO, USERNAME, LASTMODIFIED, SYSROWID, PENSION_GROSS, P_TAX, LEAVEENCASHMENT'||chr(10)
         ||'FROM WPSSTLWAGESDETAILS_SWT'||chr(10)
         ||'WHERE COMPANYCODE= '''||P_COMPCODE||''''||chr(10)
         ||'AND DIVISIONCODE= '''||P_DIVCODE||''''||chr(10)
         ||'AND YEARCODE= '''||P_YEARCODE||''''||chr(10)
         ||'AND PAYMENTDATE >= '''||lv_FN_STDT||''''||chr(10)
         ||'AND PAYMENTDATE <= '''||lv_FN_ENDT||''''||chr(10);
    if P_WORKERSERIAL is not null then
        lv_Sql := lv_Sql ||' AND WORKERSERIAL IN ('||P_WORKERSERIAL||')' ||CHR(10); 
    end if; 
         
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
    COMMIT;
    EXECUTE IMMEDIATE lv_Sql; 
    COMMIT;
    
    
--exception    
--    when others then
--        lv_sqlerrm := sqlerrm;
--    insert into wps_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
--    values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_remarks);
--    commit; 
end;
/


DROP PROCEDURE NJMCL_WEB.PROC_WPS_STL_IMPORT;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPS_STL_IMPORT (P_COMPCODE VARCHAR2,
                                                       P_DIVCODE VARCHAR2,
                                                       P_YEARCODE VARCHAR2,
                                                       P_PAYMENTDATE VARCHAR2,
                                                       P_OVERWRITE_DATA_EXIST VARCHAR2 DEFAULT 'N')


AS 

   lv_cnt                  number;
   lv_row_cnt              number;
   lv_result               varchar2(10);
   lv_error_remark         varchar2(4000) := '' ;
    
   LV_WORKERSERIAL varchar2(15);
   LV_WORKERNAME varchar2(100);
   LV_WORKERCATEGORYCODE varchar2(10);
   LV_DEPARTMENTCODE varchar2(10);
   LV_SECTIONCODE varchar2(10);
   LV_DEPARTMENTNAME varchar2(50);
   LV_OCCUPATIONCODE varchar2(10);
   lv_MinOcpCode     varchar2(10);   
   LV_SHIFTCODE varchar2(1);
   lv_DATE DATE;
   lv_IsSanction   varchar2(1) := '';
   lv_LeaveDays    number(5) := 0;
   
   lv_NoofHoursInday  number(5) := 0;
   lv_DY    number(5) := 0;
    
   lv_DocumentNo           varchar2(100) := '';
   lv_FortnightStartDate   VARCHAR2(10) := '';
   lv_FortnightEndDate     VARCHAR2(10) := '';
   lv_OFFDAY               varchar2(10) :='';
   LV_FORTNIGHTAPPLICABLEDATE  VARCHAR2(10) := '';
   lv_LASTMAX_DATE DATE;
BEGIN

lv_result:='#SUCCESS#';

    if P_PAYMENTDATE is null then
        lv_error_remark := 'Validation Failure : [Payment Date Cannot be blank.]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
    select count(*)
    into lv_cnt
    from WPSSTLRAWDATA
    WHERE 1=1--COMPANYCODE=P_COMPCODE AND DIVISIONCODE=P_DIVCODE 
    AND PAYMENTDATE=P_PAYMENTDATE;
    
    DELETE FROM WPSSTLRAWDATA WHERE TOKENNO IS NULL;
       
    if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [No row found.Upload Again]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
     SELECT TO_CHAR(FORTNIGHTSTARTDATE,'DD/MM/YYYY'),  TO_CHAR(FORTNIGHTENDDATE,'DD/MM/YYYY') 
    INTO lv_FortnightStartDate, lv_FortnightEndDate FROM WPSWAGEDPERIODDECLARATION
    WHERE TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY') BETWEEN FORTNIGHTSTARTDATE AND FORTNIGHTENDDATE
    AND COMPANYCODE = P_COMPCODE
    AND DIVISIONCODE = P_DIVCODE
    AND YEARCODE = P_YEARCODE;
    
     if lv_FortnightStartDate IS NULL then
        lv_error_remark := 'Validation Failure : [Fortnight StartDate cannot be blank]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
     if lv_FortnightEndDate IS NULL then
        lv_error_remark := 'Validation Failure : [Fortnight EndDate cannot be blank]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
       SELECT COUNT(*) into lv_cnt FROM 
       WPSWAGEDPERIODDECLARATION WHERE COMPANYCODE=P_COMPCODE AND DIVISIONCODE =P_DIVCODE AND FORTNIGHTSTARTDATE=TO_DATE(lv_FortnightStartDate,'DD/MM/YYYY') AND FINALISEDANDLOCK='Y';
 
--COMMENT ON 22-08-2020      
        if lv_cnt>0 then
        lv_error_remark := 'Validation Failure : [Wages already finalized so STL data can not be modified/Uploaded]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
       end if;
--END COMMENT ON 22-08-2020 
       
       lv_row_cnt :=1;
    
     IF NVL(P_OVERWRITE_DATA_EXIST,'N')='Y' THEN
               
               SELECT COUNT(*) into lv_cnt 
               FROM WPSSTLENTRY WHERE 
               DOCUMENTDATE=TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY');
               --TOKENNO=C122.TOKENNO
               --AND (STLFROMDATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               --AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY') 
               --OR STLTODATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               --AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY')) 
               --AND LEAVECODE = 'STL'
               --AND YEARCODE=C122.STLTAKENFROMYEAR;
               
              if lv_cnt>0 then
                --IF DATA EXIST WHILE UPLOADING THEN DELETE THE PREVIOUS DATA IF P_OVERWRITE_DATA_EXIST='Y'
                DELETE FROM WPSSTLENTRYDETAILS WHERE DOCUMENTNO IN
                (
                SELECT DISTINCT DOCUMENTNO FROM WPSSTLENTRY WHERE 
               -- TOKENNO=C122.TOKENNO
               -- AND (STLFROMDATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               -- AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY') 
               -- OR STLTODATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               -- AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY')) 
               -- AND LEAVECODE = 'STL'
               -- AND YEARCODE=C122.STLTAKENFROMYEAR
               DOCUMENTDATE=TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY')
                );
                
                DELETE FROM WPSSTLENTRY WHERE 
               -- TOKENNO=C122.TOKENNO
               -- AND (STLFROMDATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               -- AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY') 
               -- OR STLTODATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               -- AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY')) 
               -- AND LEAVECODE = 'STL'
               -- AND YEARCODE=C122.STLTAKENFROMYEAR;
               DOCUMENTDATE=TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY');
                
                DELETE FROM WPSLEAVEAPPLICATION WHERE 
               -- TOKENNO=C122.TOKENNO
               -- AND (LEAVEFROM BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               -- AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY') 
               -- OR LEAVETO BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               -- AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY')) 
               -- AND LEAVECODE = 'STL'
               -- AND YEARCODE=C122.STLTAKENFROMYEAR;
               LEAVEAPPLIEDON=TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY');
            end if;
     END IF;
   
   FOR C122 IN 
     (
        select *
        from WPSSTLRAWDATA
        WHERE 1=1--COMPANYCODE=P_COMPCODE AND DIVISIONCODE=P_DIVCODE 
        AND PAYMENTDATE=P_PAYMENTDATE
     )
       LOOP  
       
       DELETE FROM GBL_WPSSTLENTRY;
       
       DELETE FROM GBL_WPSSTLENTRYDETAILS;
       
       
       SELECT count(*)
            into lv_cnt
            FROM WPSWORKERMAST A,WPSDEPARTMENTMASTER B
            WHERE A.COMPANYCODE = P_COMPCODE
            AND A.DIVISIONCODE = P_DIVCODE
            AND A.TOKENNO =C122.TOKENNO 
            AND A.COMPANYCODE=B.COMPANYCODE
            AND A.DEPARTMENTCODE=B.DEPARTMENTCODE;
       
        if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [Invalid Tokenno at line no '||lv_row_cnt||']';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        end if;
            
       SELECT A.WORKERSERIAL, A.WORKERNAME, A.WORKERCATEGORYCODE ,/*A.DEPARTMENTCODE*/C122.DEPARTMENTCODE,C122.SECTIONCODE,B.DEPARTMENTNAME DEPARTMENTDESC,A.OCCUPATIONCODE,nvl(c122.SHIFTCODE,'1')
             INTO LV_WORKERSERIAL,LV_WORKERNAME,LV_WORKERCATEGORYCODE,LV_DEPARTMENTCODE,LV_SECTIONCODE,LV_DEPARTMENTNAME,LV_OCCUPATIONCODE,LV_SHIFTCODE
            FROM WPSWORKERMAST A,WPSDEPARTMENTMASTER B
            WHERE A.COMPANYCODE = P_COMPCODE
            AND A.DIVISIONCODE = P_DIVCODE
            AND A.TOKENNO =C122.TOKENNO 
            AND A.COMPANYCODE=B.COMPANYCODE
            AND A.DEPARTMENTCODE=B.DEPARTMENTCODE;
            
       
       if NVL(C122.STLHOURS,0)<=0 then
        lv_error_remark := 'Validation Failure : [Hours Cannot be less than Zero at line no '||lv_row_cnt||']';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
       end if;
       
       if NVL(C122.STLDAYS,0)<=0 then
        lv_error_remark := 'Validation Failure : [Days Cannot be less than Zero at line no '||lv_row_cnt||']';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
       end if;
       
       if (NVL(C122.STLDAYS,0)*8)<>NVL(C122.STLHOURS,0) then
        lv_error_remark := 'Validation Failure : [Applicable days and Applicable Hours must be matched at line no '||lv_row_cnt||']';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
       end if;
       
       
       SELECT COUNT(*) into lv_cnt FROM 
       WPSSTLENTRY WHERE COMPANYCODE=P_COMPCODE AND DIVISIONCODE=P_DIVCODE AND TOKENNO=C122.TOKENNO AND YEAR=substr(lv_FortnightStartDate, -4) AND LEAVEENCASHMENT='Y';
        if lv_cnt>0 then
        lv_error_remark := 'Validation Failure : [Encashment already has been done at line no '||lv_row_cnt||']';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
       end if;
       
       SELECT COUNT(*) into lv_cnt FROM 
       WPSATTENDANCEDAYWISE WHERE COMPANYCODE=P_COMPCODE AND DIVISIONCODE=P_DIVCODE AND TOKENNO=C122.TOKENNO AND STATUSCODE='P' AND DATEOFATTENDANCE BETWEEN  TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY');
       
        if lv_cnt>0 then
        lv_error_remark := 'Validation Failure : [Data present in normal attendance. at line no '||lv_row_cnt||']';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
       end if;
       
       SELECT COUNT(*) into lv_cnt 
       FROM WPSSTLENTRY WHERE 
       TOKENNO=C122.TOKENNO
       AND (STLFROMDATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
       AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY') 
       OR STLTODATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
       AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY')) 
       AND LEAVECODE = 'STL'
       AND YEARCODE=C122.STLTAKENFROMYEAR;
               
        if lv_cnt>0 then
            lv_error_remark := 'Validation Failure : [STL Data Already Exist at line no '||lv_row_cnt||']';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF;
                
       SELECT TO_CHAR(TO_DATE(''||lv_FortnightStartDate||'','DD/MM/RRRR') ,'DD/MM/YYYY')
       INTO LV_FORTNIGHTAPPLICABLEDATE
       FROM DUAL;
          
       select fn_autogen_params(P_COMPCODE,P_DIVCODE,P_YEARCODE,'WPS STL ENTRY',LV_FORTNIGHTAPPLICABLEDATE)
       into lv_DocumentNo
       from dual;
                
       if lv_DocumentNo IS NULL then
        lv_error_remark := 'Validation Failure : [Unable to generated Autogenerated Number at line no '||lv_row_cnt||']';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
       END IF;
       
        INSERT INTO GBL_WPSSTLENTRY
        (
        COMPANYCODE, DIVISIONCODE, YEARCODE, YEAR, DOCUMENTNO, DOCUMENTDATE, 
        FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERSERIAL, REMARKS, LEAVECODE, 
        TOKENNO, WORKERCATEGORYCODE, DEPARTMENTCODE, OCCUPATIONCODE, SHIFTCODE, 
        STLFROMDATE, STLTODATE, STLHOURS, STLDAYS, STLRATE, USERNAME, SYSROWID, 
        SECTIONCODE, TRANSACTIONTYPE, ADDLESS, LEAVEENCASHMENT
        )
        SELECT P_COMPCODE,P_DIVCODE,P_YEARCODE,/*TO_CHAR(TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY'),'YYYY')*/C122.STLTAKENFROMYEAR,/*C122.DOCUMENTNO*/lv_DocumentNo,TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY'),
        TO_DATE(lv_FortnightStartDate,'DD/MM/YYYY'),TO_DATE(lv_FortnightEndDate,'DD/MM/YYYY'),LV_WORKERSERIAL,NULL,'STL',
        C122.TOKENNO,LV_WORKERCATEGORYCODE,LV_DEPARTMENTCODE,LV_OCCUPATIONCODE,LV_SHIFTCODE,
        TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY'),TO_DATE(C122.STLTODATE,'DD/MM/YYYY'),C122.STLHOURS,C122.STLDAYS,C122.RATE,'SWT',FN_GENERATE_SYSROWID,
        LV_SECTIONCODE,'AVAILED','LESS','N' FROM DUAL;
       
       --------- start add on 11.08.2020 due to based on master data occupation not match with  department and section which upload through excel
       for c11 in (
--                   select distinct departmentcode, sectioncode, occupationcode GBL_WPSSTLENTRY
--                   minus
--                   select departmentcode, sectioncode, occupationcode from WPSOCCUPATIONMAST WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE= P_DIVCODE
                   SELECT DISTINCT DEPARTMENTCODE, SECTIONCODE, OCCUPATIONCODE
                   FROM GBL_WPSSTLENTRY
                   WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                     AND DEPARTMENTCODE||SECTIONCODE||OCCUPATIONCODE NOT IN ( SELECT DEPARTMENTCODE||SECTIONCODE||OCCUPATIONCODE FROM WPSOCCUPATIONMAST
                                                                               WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                                                                             )                       
                  )
       loop
            select min(OCCUPATIONCODE) INTO lv_MinOcpCode FROM WPSOCCUPATIONMAST
            WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
              AND DEPARTMENTCODE = c11.DEPARTMENTCODE AND SECTIONCODE = c11.SECTIONCODE;
              
            UPDATE  GBL_WPSSTLENTRY SET OCCUPATIONCODE = lv_MinOcpCode 
            WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
              AND DEPARTMENTCODE = c11.DEPARTMENTCODE AND SECTIONCODE = c11.SECTIONCODE;  
       end loop;            
       
       --------- end add on 11.08.2020 due to based on master data occupation not match with  department and section which upload through excel
       
        INSERT INTO WPSSTLENTRY
        (
        COMPANYCODE, DIVISIONCODE, YEARCODE, YEAR, DOCUMENTNO, DOCUMENTDATE, 
        FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERSERIAL, REMARKS, LEAVECODE, 
        TOKENNO, WORKERCATEGORYCODE, DEPARTMENTCODE, OCCUPATIONCODE, SHIFTCODE, 
        STLFROMDATE, STLTODATE, STLHOURS, STLDAYS, STLRATE, USERNAME, SYSROWID, 
        SECTIONCODE, TRANSACTIONTYPE, ADDLESS, LEAVEENCASHMENT,STLSERIALNO,PAYMENTDATE
        )
        SELECT 
        COMPANYCODE, DIVISIONCODE, YEARCODE, YEAR, DOCUMENTNO, DOCUMENTDATE, 
        FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERSERIAL, REMARKS, LEAVECODE, 
        TOKENNO, WORKERCATEGORYCODE, DEPARTMENTCODE, OCCUPATIONCODE, SHIFTCODE, 
        STLFROMDATE, STLTODATE, STLHOURS, STLDAYS, STLRATE, USERNAME, SYSROWID, 
        SECTIONCODE, TRANSACTIONTYPE, ADDLESS, LEAVEENCASHMENT,C122.SERIALNO, DOCUMENTDATE AS PAYMENTDATE
        FROM GBL_WPSSTLENTRY;
       

      
        ---
        SELECT MAX(LEAVEDATE)  INTO lv_LASTMAX_DATE 
        FROM WPSSTLENTRYDETAILS
        WHERE COMPANYCODE=P_COMPCODE
           AND DIVISIONCODE=P_DIVCODE
           AND YEARCODE=P_YEARCODE
           AND TOKENNO=C122.TOKENNO
           AND PAYMENTDATE=TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY')
           AND LEAVEDAYS>0;
        
        --
         IF lv_LASTMAX_DATE IS NULL THEN
          lv_DATE := TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY');
         ELSE
         lv_DATE := lv_LASTMAX_DATE+1;
         END IF;
        --lv_DATE := TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY');
        lv_IsSanction := 'Y';
        lv_LeaveDays := 1;
        lv_NoofHoursInday := 8;
        lv_DY    := 1;
        WHILE (lv_DATE <= TO_DATE(C122.STLTODATE,'DD/MM/YYYY'))
            loop    
                IF lv_LeaveDays > C122.STLDAYS THEN
                    lv_IsSanction := 'N';
                    lv_NoofHoursInday := 0;
                    lv_DY    := 0;
                END IF;
                 
                   
                insert into GBL_WPSSTLENTRYDETAILS (COMPANYCODE, DIVISIONCODE, YEARCODE, YEAR, LEAVECODE, DOCUMENTNO, DOCUMENTDATE, 
                FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, DEPARTMENTCODE, 
                OCCUPATIONCODE, SHIFTCODE, LEAVEFROMDATE, LEAVETODATE, LEAVEDATE, LEAVEHOURS, LEAVEDAYS, STLRATE, 
                ISSANCTIONED, TRANSACTIONTYPE, ADDLESS, USERNAME, LASTMODIFIEDDATE, SYSROWID,STLSERIALNO)
                
                values (P_COMPCODE, P_DIVCODE, P_YEARCODE, C122.STLTAKENFROMYEAR, 'STL' , lv_DocumentNo, TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY'), 
                TO_DATE(lv_FortnightStartDate,'DD/MM/YYYY'), TO_DATE(lv_FortnightEndDate,'DD/MM/YYYY'), LV_WORKERSERIAL, C122.TOKENNO, LV_WORKERCATEGORYCODE, LV_DEPARTMENTCODE, 
                LV_OCCUPATIONCODE, LV_SHIFTCODE, TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY'), TO_DATE(C122.STLTODATE,'DD/MM/YYYY'), lv_DATE , lv_NoofHoursInday , lv_DY , C122.RATE, 
                lv_IsSanction , 'AVAILED', 'LESS','SWT', SYSDATE, FN_GENERATE_SYSROWID,C122.SERIALNO);
                
                lv_LeaveDays := lv_LeaveDays +1;    
                lv_DATE := lv_DATE+1;               
            end loop;
            
       --------- start add on 11.08.2020 due to based on master data occupation not match with  department and section which upload through excel
       for c51 in (
--                   select distinct departmentcode, sectioncode, occupationcode GBL_WPSSTLENTRYDETAILS
--                   minus
--                   select departmentcode, sectioncode, occupationcode from WPSOCCUPATIONMAST WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE= P_DIVCODE
                   SELECT DISTINCT DEPARTMENTCODE, SECTIONCODE, OCCUPATIONCODE
                   FROM GBL_WPSSTLENTRYDETAILS
                   WHERE COMPANYCODE =P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                     AND DEPARTMENTCODE||SECTIONCODE||OCCUPATIONCODE NOT IN ( SELECT DEPARTMENTCODE||SECTIONCODE||OCCUPATIONCODE FROM WPSOCCUPATIONMAST
                                                                               WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                                                                             )                       

                  )
       loop
            select min(OCCUPATIONCODE) INTO lv_MinOcpCode FROM WPSOCCUPATIONMAST
            WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
              AND DEPARTMENTCODE = c51.DEPARTMENTCODE AND SECTIONCODE = c51.SECTIONCODE;
              
            UPDATE  GBL_WPSSTLENTRY SET OCCUPATIONCODE = lv_MinOcpCode 
            WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
              AND DEPARTMENTCODE = c51.DEPARTMENTCODE AND SECTIONCODE = c51.SECTIONCODE;  
       end loop;            
       
       --------- end add on 11.08.2020 due to based on master data occupation not match with  department and section which upload through excel
              
       
                INSERT INTO WPSSTLENTRYDETAILS
                (
                SECTIONCODE, LASTMODIFIEDDATE, ISSANCTIONED, LEAVEHOURS, WORKERCATEGORYCODE, 
                OCCUPATIONCODE, LEAVETODATE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, STLRATE, ADDLESS, 
                USERNAME, DOCUMENTDATE, TRANSACTIONTYPE, LEAVEFROMDATE, LEAVEDAYS, SYSROWID, SHIFTCODE, 
                COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, DOCUMENTNO, 
                DEPARTMENTCODE, LEAVEDATE, YEARCODE, YEAR,LEAVECODE, PAYMENTDATE,STLSERIALNO
                )
                SELECT 
                SECTIONCODE, LASTMODIFIEDDATE, ISSANCTIONED, LEAVEHOURS, WORKERCATEGORYCODE, 
                OCCUPATIONCODE, LEAVETODATE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, STLRATE, ADDLESS, 
                USERNAME, DOCUMENTDATE, TRANSACTIONTYPE, LEAVEFROMDATE, LEAVEDAYS, FN_GENERATE_SYSROWID, SHIFTCODE, 
                COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, DOCUMENTNO, 
                DEPARTMENTCODE, LEAVEDATE, YEARCODE, YEAR,LEAVECODE, DOCUMENTDATE AS PAYMENTDATE,STLSERIALNO
                FROM GBL_WPSSTLENTRYDETAILS;
                
                INSERT INTO WPSLEAVEAPPLICATION
                    (COMPANYCODE, DIVISIONCODE, YEARCODE, WORKERSERIAL, TOKENNO, WOKERCATEGORYCODE, 
                    LEAVECODE, LEAVEAPPLIEDON, LEAVEFROM, LEAVETO, LEAVESANCTIONEDON, 
                    LEAVEDATE,LEAVEDAYS, LEAVEHOURS, LEAVEENCASHED, CALENDARYEAR)
                SELECT COMPANYCODE, DIVISIONCODE, YEARCODE,WORKERSERIAL, TOKENNO,WORKERCATEGORYCODE,
                    LEAVECODE,DOCUMENTDATE,LEAVEFROMDATE,LEAVETODATE,/*DOCUMENTDATE*/ FORTNIGHTENDDATE,
                    LEAVEDATE,LEAVEDAYS,LEAVEHOURS,0,YEAR
                FROM GBL_WPSSTLENTRYDETAILS;
--               
                
               
              
       UPDATE WPSLEAVEAPPLICATION 
       SET LEAVEDAYS=0,LEAVEHOURS=0
     WHERE COMPANYCODE=P_COMPCODE
       AND DIVISIONCODE=P_DIVCODE
       AND LEAVEAPPLIEDON = TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY')
       AND WORKERSERIAL=LV_WORKERSERIAL
       AND EXISTS --LEAVEDATE IN
       (   SELECT HOLIDAYDATE
             FROM WPSHOLIDAYMASTER 
            WHERE COMPANYCODE=P_COMPCODE
              AND DIVISIONCODE=P_DIVCODE 
              AND ISPAID='Y'
              AND WPSLEAVEAPPLICATION.LEAVEDATE=WPSHOLIDAYMASTER.HOLIDAYDATE
       );
       
      SELECT TRIM(DAYOFFDAY)
        INTO lv_OFFDAY
        FROM WPSWORKERMAST 
       WHERE COMPANYCODE=P_COMPCODE
         AND DIVISIONCODE=P_DIVCODE
         AND WORKERSERIAL=LV_WORKERSERIAL;
       
       UPDATE WPSLEAVEAPPLICATION 
          SET LEAVEDAYS=0,LEAVEHOURS=0
        WHERE COMPANYCODE=P_COMPCODE
          AND DIVISIONCODE=P_DIVCODE
          AND LEAVEAPPLIEDON =  TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY')
          AND WORKERSERIAL=LV_WORKERSERIAL
          AND EXISTS 
            (
            SELECT TO_DATE(DATES,'DD/MM/YYYY') DATES  FROM --count(TO_CHAR(DATES,'DAY'))
            (
            WITH d AS
            (
            SELECT TRUNC ( TO_DATE( C122.STLFROMDATE,'DD/MM/YYYY')) -1  AS dt
            FROM dual
            )
            SELECT dt + LEVEL  DATES
            FROM d
            CONNECT BY LEVEL <=  ( TO_DATE(C122.STLTODATE,'DD/MM/YYYY') - TO_DATE( C122.STLFROMDATE,'DD/MM/YYYY') + 1 )
            )
            where TO_DATE(WPSLEAVEAPPLICATION.LEAVEDATE,'DD/MM/YYYY')=TO_DATE(DATES,'DD/MM/YYYY')
              --  AND trim(trim(TO_CHAR(DATES,'DAY'))) = UPPER(TRIM(lv_OFFDAY))
              AND ltrim(trim(TO_CHAR(WPSLEAVEAPPLICATION.LEAVEDATE,'DAY'))) = UPPER(LTRIM(TRIM(lv_OFFDAY)))
       );
       
       lv_row_cnt :=lv_row_cnt+1;
       END LOOP;

END;
/


DROP PROCEDURE NJMCL_WEB.PROC_WPS_STL_IMPORT_1109;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPS_STL_IMPORT_1109 (P_COMPCODE VARCHAR2,
                                                       P_DIVCODE VARCHAR2,
                                                       P_YEARCODE VARCHAR2,
                                                       P_PAYMENTDATE VARCHAR2,
                                                       P_OVERWRITE_DATA_EXIST VARCHAR2 DEFAULT 'N')


AS 

   lv_cnt                  number;
   lv_row_cnt              number;
   lv_result               varchar2(10);
   lv_error_remark         varchar2(4000) := '' ;
    
   LV_WORKERSERIAL varchar2(15);
   LV_WORKERNAME varchar2(100);
   LV_WORKERCATEGORYCODE varchar2(10);
   LV_DEPARTMENTCODE varchar2(10);
   LV_SECTIONCODE varchar2(10);
   LV_DEPARTMENTNAME varchar2(50);
   LV_OCCUPATIONCODE varchar2(10);
   lv_MinOcpCode     varchar2(10);   
   LV_SHIFTCODE varchar2(1);
   lv_DATE DATE;
   lv_IsSanction   varchar2(1) := '';
   lv_LeaveDays    number(5) := 0;
   
   lv_NoofHoursInday  number(5) := 0;
   lv_DY    number(5) := 0;
    
   lv_DocumentNo           varchar2(100) := '';
   lv_FortnightStartDate   VARCHAR2(10) := '';
   lv_FortnightEndDate     VARCHAR2(10) := '';
   lv_OFFDAY               varchar2(10) :='';
   LV_FORTNIGHTAPPLICABLEDATE  VARCHAR2(10) := '';
   lv_LASTMAX_DATE DATE;
BEGIN

lv_result:='#SUCCESS#';

    if P_PAYMENTDATE is null then
        lv_error_remark := 'Validation Failure : [Payment Date Cannot be blank.]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
    select count(*)
    into lv_cnt
    from WPSSTLRAWDATA_ENCASH_110920
    WHERE 1=1--COMPANYCODE=P_COMPCODE AND DIVISIONCODE=P_DIVCODE 
    AND PAYMENTDATE=P_PAYMENTDATE;
    
    DELETE FROM WPSSTLRAWDATA_ENCASH_110920 WHERE TOKENNO IS NULL;
       
    if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [No row found.Upload Again]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
     SELECT TO_CHAR(FORTNIGHTSTARTDATE,'DD/MM/YYYY'),  TO_CHAR(FORTNIGHTENDDATE,'DD/MM/YYYY') 
    INTO lv_FortnightStartDate, lv_FortnightEndDate FROM WPSWAGEDPERIODDECLARATION
    WHERE TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY') BETWEEN FORTNIGHTSTARTDATE AND FORTNIGHTENDDATE
    AND COMPANYCODE = P_COMPCODE
    AND DIVISIONCODE = P_DIVCODE
    AND YEARCODE = P_YEARCODE;
    
     if lv_FortnightStartDate IS NULL then
        lv_error_remark := 'Validation Failure : [Fortnight StartDate cannot be blank]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
     if lv_FortnightEndDate IS NULL then
        lv_error_remark := 'Validation Failure : [Fortnight EndDate cannot be blank]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
       SELECT COUNT(*) into lv_cnt FROM 
       WPSWAGEDPERIODDECLARATION WHERE COMPANYCODE=P_COMPCODE AND DIVISIONCODE =P_DIVCODE AND FORTNIGHTSTARTDATE=TO_DATE(lv_FortnightStartDate,'DD/MM/YYYY') AND FINALISEDANDLOCK='Y';
 
--COMMENT ON 22-08-2020      
--        if lv_cnt>0 then
--        lv_error_remark := 'Validation Failure : [Wages already finalized so STL data can not be modified/Uploaded]';
--        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
--       end if;
--END COMMENT ON 22-08-2020 
       
       lv_row_cnt :=1;
    
     IF NVL(P_OVERWRITE_DATA_EXIST,'N')='Y' THEN
               
               SELECT COUNT(*) into lv_cnt 
               FROM WPSSTLENTRY WHERE 
               DOCUMENTDATE=TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY');
               --TOKENNO=C122.TOKENNO
               --AND (STLFROMDATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               --AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY') 
               --OR STLTODATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               --AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY')) 
               --AND LEAVECODE = 'STL'
               --AND YEARCODE=C122.STLTAKENFROMYEAR;
               
              if lv_cnt>0 then
                --IF DATA EXIST WHILE UPLOADING THEN DELETE THE PREVIOUS DATA IF P_OVERWRITE_DATA_EXIST='Y'
                DELETE FROM WPSSTLENTRYDETAILS WHERE DOCUMENTNO IN
                (
                SELECT DISTINCT DOCUMENTNO FROM WPSSTLENTRY WHERE 
               -- TOKENNO=C122.TOKENNO
               -- AND (STLFROMDATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               -- AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY') 
               -- OR STLTODATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               -- AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY')) 
               -- AND LEAVECODE = 'STL'
               -- AND YEARCODE=C122.STLTAKENFROMYEAR
               DOCUMENTDATE=TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY')
                );
                
                DELETE FROM WPSSTLENTRY WHERE 
               -- TOKENNO=C122.TOKENNO
               -- AND (STLFROMDATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               -- AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY') 
               -- OR STLTODATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               -- AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY')) 
               -- AND LEAVECODE = 'STL'
               -- AND YEARCODE=C122.STLTAKENFROMYEAR;
               DOCUMENTDATE=TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY');
                
                DELETE FROM WPSLEAVEAPPLICATION WHERE 
               -- TOKENNO=C122.TOKENNO
               -- AND (LEAVEFROM BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               -- AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY') 
               -- OR LEAVETO BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               -- AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY')) 
               -- AND LEAVECODE = 'STL'
               -- AND YEARCODE=C122.STLTAKENFROMYEAR;
               LEAVEAPPLIEDON=TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY');
            end if;
     END IF;
   
   FOR C122 IN 
     (
        select *
        from WPSSTLRAWDATA_ENCASH_110920
        WHERE 1=1--COMPANYCODE=P_COMPCODE AND DIVISIONCODE=P_DIVCODE 
        AND PAYMENTDATE=P_PAYMENTDATE
     )
       LOOP  
       
       DELETE FROM GBL_WPSSTLENTRY;
       
       DELETE FROM GBL_WPSSTLENTRYDETAILS;
       
       
       SELECT count(*)
            into lv_cnt
            FROM WPSWORKERMAST A,WPSDEPARTMENTMASTER B
            WHERE A.COMPANYCODE = P_COMPCODE
            AND A.DIVISIONCODE = P_DIVCODE
            AND A.TOKENNO =C122.TOKENNO 
            AND A.COMPANYCODE=B.COMPANYCODE
            AND A.DEPARTMENTCODE=B.DEPARTMENTCODE;
       
        if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [Invalid Tokenno at line no '||lv_row_cnt||']';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        end if;
            
       SELECT A.WORKERSERIAL, A.WORKERNAME, A.WORKERCATEGORYCODE ,/*A.DEPARTMENTCODE*/C122.DEPARTMENTCODE,C122.SECTIONCODE,B.DEPARTMENTNAME DEPARTMENTDESC,A.OCCUPATIONCODE,nvl(c122.SHIFTCODE,'1')
             INTO LV_WORKERSERIAL,LV_WORKERNAME,LV_WORKERCATEGORYCODE,LV_DEPARTMENTCODE,LV_SECTIONCODE,LV_DEPARTMENTNAME,LV_OCCUPATIONCODE,LV_SHIFTCODE
            FROM WPSWORKERMAST A,WPSDEPARTMENTMASTER B
            WHERE A.COMPANYCODE = P_COMPCODE
            AND A.DIVISIONCODE = P_DIVCODE
            AND A.TOKENNO =C122.TOKENNO 
            AND A.COMPANYCODE=B.COMPANYCODE
            AND A.DEPARTMENTCODE=B.DEPARTMENTCODE;
            
       
       if NVL(C122.STLHOURS,0)<=0 then
        lv_error_remark := 'Validation Failure : [Hours Cannot be less than Zero at line no '||lv_row_cnt||']';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
       end if;
       
       if NVL(C122.STLDAYS,0)<=0 then
        lv_error_remark := 'Validation Failure : [Days Cannot be less than Zero at line no '||lv_row_cnt||']';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
       end if;
       
       if (NVL(C122.STLDAYS,0)*8)<>NVL(C122.STLHOURS,0) then
        lv_error_remark := 'Validation Failure : [Applicable days and Applicable Hours must be matched at line no '||lv_row_cnt||']';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
       end if;
       
       
       SELECT COUNT(*) into lv_cnt FROM 
       WPSSTLENTRY WHERE COMPANYCODE=P_COMPCODE AND DIVISIONCODE=P_DIVCODE AND TOKENNO=C122.TOKENNO AND YEAR=substr(lv_FortnightStartDate, -4) AND LEAVEENCASHMENT='Y';
        if lv_cnt>0 then
        lv_error_remark := 'Validation Failure : [Encashment already has been done at line no '||lv_row_cnt||']';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
       end if;
       
       SELECT COUNT(*) into lv_cnt FROM 
       WPSATTENDANCEDAYWISE WHERE COMPANYCODE=P_COMPCODE AND DIVISIONCODE=P_DIVCODE AND TOKENNO=C122.TOKENNO AND STATUSCODE='P' AND DATEOFATTENDANCE BETWEEN  TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY');
       
        if lv_cnt>0 then
        lv_error_remark := 'Validation Failure : [Data present in normal attendance. at line no '||lv_row_cnt||']';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
       end if;
       
       SELECT COUNT(*) into lv_cnt 
       FROM WPSSTLENTRY WHERE 
       TOKENNO=C122.TOKENNO
       AND (STLFROMDATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
       AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY') 
       OR STLTODATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
       AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY')) 
       AND LEAVECODE = 'STL'
       AND YEARCODE=C122.STLTAKENFROMYEAR;
               
        if lv_cnt>0 then
            lv_error_remark := 'Validation Failure : [STL Data Already Exist at line no '||lv_row_cnt||']';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF;
                
       SELECT TO_CHAR(TO_DATE(''||lv_FortnightStartDate||'','DD/MM/RRRR') ,'DD/MM/YYYY')
       INTO LV_FORTNIGHTAPPLICABLEDATE
       FROM DUAL;
          
       select fn_autogen_params(P_COMPCODE,P_DIVCODE,P_YEARCODE,'WPS STL ENTRY',LV_FORTNIGHTAPPLICABLEDATE)
       into lv_DocumentNo
       from dual;
                
       if lv_DocumentNo IS NULL then
        lv_error_remark := 'Validation Failure : [Unable to generated Autogenerated Number at line no '||lv_row_cnt||']';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
       END IF;
       
        INSERT INTO GBL_WPSSTLENTRY
        (
        COMPANYCODE, DIVISIONCODE, YEARCODE, YEAR, DOCUMENTNO, DOCUMENTDATE, 
        FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERSERIAL, REMARKS, LEAVECODE, 
        TOKENNO, WORKERCATEGORYCODE, DEPARTMENTCODE, OCCUPATIONCODE, SHIFTCODE, 
        STLFROMDATE, STLTODATE, STLHOURS, STLDAYS, STLRATE, USERNAME, SYSROWID, 
        SECTIONCODE, TRANSACTIONTYPE, ADDLESS, LEAVEENCASHMENT
        )
        SELECT P_COMPCODE,P_DIVCODE,P_YEARCODE,/*TO_CHAR(TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY'),'YYYY')*/C122.STLTAKENFROMYEAR,/*C122.DOCUMENTNO*/lv_DocumentNo,TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY'),
        TO_DATE(lv_FortnightStartDate,'DD/MM/YYYY'),TO_DATE(lv_FortnightEndDate,'DD/MM/YYYY'),LV_WORKERSERIAL,NULL,'STL',
        C122.TOKENNO,LV_WORKERCATEGORYCODE,LV_DEPARTMENTCODE,LV_OCCUPATIONCODE,LV_SHIFTCODE,
        TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY'),TO_DATE(C122.STLTODATE,'DD/MM/YYYY'),C122.STLHOURS,C122.STLDAYS,C122.RATE,'SWT',FN_GENERATE_SYSROWID,
        LV_SECTIONCODE,'AVAILED','LESS','N' FROM DUAL;
       
       --------- start add on 11.08.2020 due to based on master data occupation not match with  department and section which upload through excel
       for c11 in (
--                   select distinct departmentcode, sectioncode, occupationcode GBL_WPSSTLENTRY
--                   minus
--                   select departmentcode, sectioncode, occupationcode from WPSOCCUPATIONMAST WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE= P_DIVCODE
                   SELECT DISTINCT DEPARTMENTCODE, SECTIONCODE, OCCUPATIONCODE
                   FROM GBL_WPSSTLENTRY
                   WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                     AND DEPARTMENTCODE||SECTIONCODE||OCCUPATIONCODE NOT IN ( SELECT DEPARTMENTCODE||SECTIONCODE||OCCUPATIONCODE FROM WPSOCCUPATIONMAST
                                                                               WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                                                                             )                       
                  )
       loop
            select min(OCCUPATIONCODE) INTO lv_MinOcpCode FROM WPSOCCUPATIONMAST
            WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
              AND DEPARTMENTCODE = c11.DEPARTMENTCODE AND SECTIONCODE = c11.SECTIONCODE;
              
            UPDATE  GBL_WPSSTLENTRY SET OCCUPATIONCODE = lv_MinOcpCode 
            WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
              AND DEPARTMENTCODE = c11.DEPARTMENTCODE AND SECTIONCODE = c11.SECTIONCODE;  
       end loop;            
       
       --------- end add on 11.08.2020 due to based on master data occupation not match with  department and section which upload through excel
       
        INSERT INTO WPSSTLENTRY
        (
        COMPANYCODE, DIVISIONCODE, YEARCODE, YEAR, DOCUMENTNO, DOCUMENTDATE, 
        FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERSERIAL, REMARKS, LEAVECODE, 
        TOKENNO, WORKERCATEGORYCODE, DEPARTMENTCODE, OCCUPATIONCODE, SHIFTCODE, 
        STLFROMDATE, STLTODATE, STLHOURS, STLDAYS, STLRATE, USERNAME, SYSROWID, 
        SECTIONCODE, TRANSACTIONTYPE, ADDLESS, LEAVEENCASHMENT,STLSERIALNO,PAYMENTDATE
        )
        SELECT 
        COMPANYCODE, DIVISIONCODE, YEARCODE, YEAR, DOCUMENTNO, DOCUMENTDATE, 
        FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERSERIAL, REMARKS, LEAVECODE, 
        TOKENNO, WORKERCATEGORYCODE, DEPARTMENTCODE, OCCUPATIONCODE, SHIFTCODE, 
        STLFROMDATE, STLTODATE, STLHOURS, STLDAYS, STLRATE, USERNAME, SYSROWID, 
        SECTIONCODE, TRANSACTIONTYPE, ADDLESS, LEAVEENCASHMENT,C122.SERIALNO, DOCUMENTDATE AS PAYMENTDATE
        FROM GBL_WPSSTLENTRY;
       

      
        ---
        SELECT MAX(LEAVEDATE)  INTO lv_LASTMAX_DATE 
        FROM WPSSTLENTRYDETAILS
        WHERE COMPANYCODE=P_COMPCODE
           AND DIVISIONCODE=P_DIVCODE
           AND YEARCODE=P_YEARCODE
           AND TOKENNO=C122.TOKENNO
           AND PAYMENTDATE=TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY')
           AND LEAVEDAYS>0;
        
        --
         IF lv_LASTMAX_DATE IS NULL THEN
          lv_DATE := TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY');
         ELSE
         lv_DATE := lv_LASTMAX_DATE+1;
         END IF;
        --lv_DATE := TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY');
        lv_IsSanction := 'Y';
        lv_LeaveDays := 1;
        lv_NoofHoursInday := 8;
        lv_DY    := 1;
        WHILE (lv_DATE <= TO_DATE(C122.STLTODATE,'DD/MM/YYYY'))
            loop    
                IF lv_LeaveDays > C122.STLDAYS THEN
                    lv_IsSanction := 'N';
                    lv_NoofHoursInday := 0;
                    lv_DY    := 0;
                END IF;
                 
                   
                insert into GBL_WPSSTLENTRYDETAILS (COMPANYCODE, DIVISIONCODE, YEARCODE, YEAR, LEAVECODE, DOCUMENTNO, DOCUMENTDATE, 
                FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, DEPARTMENTCODE, 
                OCCUPATIONCODE, SHIFTCODE, LEAVEFROMDATE, LEAVETODATE, LEAVEDATE, LEAVEHOURS, LEAVEDAYS, STLRATE, 
                ISSANCTIONED, TRANSACTIONTYPE, ADDLESS, USERNAME, LASTMODIFIEDDATE, SYSROWID,STLSERIALNO)
                
                values (P_COMPCODE, P_DIVCODE, P_YEARCODE, C122.STLTAKENFROMYEAR, 'STL' , lv_DocumentNo, TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY'), 
                TO_DATE(lv_FortnightStartDate,'DD/MM/YYYY'), TO_DATE(lv_FortnightEndDate,'DD/MM/YYYY'), LV_WORKERSERIAL, C122.TOKENNO, LV_WORKERCATEGORYCODE, LV_DEPARTMENTCODE, 
                LV_OCCUPATIONCODE, LV_SHIFTCODE, TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY'), TO_DATE(C122.STLTODATE,'DD/MM/YYYY'), lv_DATE , lv_NoofHoursInday , lv_DY , C122.RATE, 
                lv_IsSanction , 'AVAILED', 'LESS','SWT', SYSDATE, FN_GENERATE_SYSROWID,C122.SERIALNO);
                
                lv_LeaveDays := lv_LeaveDays +1;    
                lv_DATE := lv_DATE+1;               
            end loop;
            
       --------- start add on 11.08.2020 due to based on master data occupation not match with  department and section which upload through excel
       for c51 in (
--                   select distinct departmentcode, sectioncode, occupationcode GBL_WPSSTLENTRYDETAILS
--                   minus
--                   select departmentcode, sectioncode, occupationcode from WPSOCCUPATIONMAST WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE= P_DIVCODE
                   SELECT DISTINCT DEPARTMENTCODE, SECTIONCODE, OCCUPATIONCODE
                   FROM GBL_WPSSTLENTRYDETAILS
                   WHERE COMPANYCODE =P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                     AND DEPARTMENTCODE||SECTIONCODE||OCCUPATIONCODE NOT IN ( SELECT DEPARTMENTCODE||SECTIONCODE||OCCUPATIONCODE FROM WPSOCCUPATIONMAST
                                                                               WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                                                                             )                       

                  )
       loop
            select min(OCCUPATIONCODE) INTO lv_MinOcpCode FROM WPSOCCUPATIONMAST
            WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
              AND DEPARTMENTCODE = c51.DEPARTMENTCODE AND SECTIONCODE = c51.SECTIONCODE;
              
            UPDATE  GBL_WPSSTLENTRY SET OCCUPATIONCODE = lv_MinOcpCode 
            WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
              AND DEPARTMENTCODE = c51.DEPARTMENTCODE AND SECTIONCODE = c51.SECTIONCODE;  
       end loop;            
       
       --------- end add on 11.08.2020 due to based on master data occupation not match with  department and section which upload through excel
              
       
                INSERT INTO WPSSTLENTRYDETAILS
                (
                SECTIONCODE, LASTMODIFIEDDATE, ISSANCTIONED, LEAVEHOURS, WORKERCATEGORYCODE, 
                OCCUPATIONCODE, LEAVETODATE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, STLRATE, ADDLESS, 
                USERNAME, DOCUMENTDATE, TRANSACTIONTYPE, LEAVEFROMDATE, LEAVEDAYS, SYSROWID, SHIFTCODE, 
                COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, DOCUMENTNO, 
                DEPARTMENTCODE, LEAVEDATE, YEARCODE, YEAR,LEAVECODE, PAYMENTDATE,STLSERIALNO
                )
                SELECT 
                SECTIONCODE, LASTMODIFIEDDATE, ISSANCTIONED, LEAVEHOURS, WORKERCATEGORYCODE, 
                OCCUPATIONCODE, LEAVETODATE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, STLRATE, ADDLESS, 
                USERNAME, DOCUMENTDATE, TRANSACTIONTYPE, LEAVEFROMDATE, LEAVEDAYS, FN_GENERATE_SYSROWID, SHIFTCODE, 
                COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, DOCUMENTNO, 
                DEPARTMENTCODE, LEAVEDATE, YEARCODE, YEAR,LEAVECODE, DOCUMENTDATE AS PAYMENTDATE,STLSERIALNO
                FROM GBL_WPSSTLENTRYDETAILS;
                
                INSERT INTO WPSLEAVEAPPLICATION
                    (COMPANYCODE, DIVISIONCODE, YEARCODE, WORKERSERIAL, TOKENNO, WOKERCATEGORYCODE, 
                    LEAVECODE, LEAVEAPPLIEDON, LEAVEFROM, LEAVETO, LEAVESANCTIONEDON, 
                    LEAVEDATE,LEAVEDAYS, LEAVEHOURS, LEAVEENCASHED, CALENDARYEAR)
                SELECT COMPANYCODE, DIVISIONCODE, YEARCODE,WORKERSERIAL, TOKENNO,WORKERCATEGORYCODE,
                    LEAVECODE,DOCUMENTDATE,LEAVEFROMDATE,LEAVETODATE,/*DOCUMENTDATE*/ FORTNIGHTENDDATE,
                    LEAVEDATE,LEAVEDAYS,LEAVEHOURS,0,YEAR
                FROM GBL_WPSSTLENTRYDETAILS;
--               
                
               
              
       UPDATE WPSLEAVEAPPLICATION 
       SET LEAVEDAYS=0,LEAVEHOURS=0
     WHERE COMPANYCODE=P_COMPCODE
       AND DIVISIONCODE=P_DIVCODE
       AND LEAVEAPPLIEDON = TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY')
       AND WORKERSERIAL=LV_WORKERSERIAL
       AND EXISTS --LEAVEDATE IN
       (   SELECT HOLIDAYDATE
             FROM WPSHOLIDAYMASTER 
            WHERE COMPANYCODE=P_COMPCODE
              AND DIVISIONCODE=P_DIVCODE 
              AND ISPAID='Y'
              AND WPSLEAVEAPPLICATION.LEAVEDATE=WPSHOLIDAYMASTER.HOLIDAYDATE
       );
       
      SELECT TRIM(DAYOFFDAY)
        INTO lv_OFFDAY
        FROM WPSWORKERMAST 
       WHERE COMPANYCODE=P_COMPCODE
         AND DIVISIONCODE=P_DIVCODE
         AND WORKERSERIAL=LV_WORKERSERIAL;
       
       UPDATE WPSLEAVEAPPLICATION 
          SET LEAVEDAYS=0,LEAVEHOURS=0
        WHERE COMPANYCODE=P_COMPCODE
          AND DIVISIONCODE=P_DIVCODE
          AND LEAVEAPPLIEDON =  TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY')
          AND WORKERSERIAL=LV_WORKERSERIAL
          AND EXISTS 
            (
            SELECT TO_DATE(DATES,'DD/MM/YYYY') DATES  FROM --count(TO_CHAR(DATES,'DAY'))
            (
            WITH d AS
            (
            SELECT TRUNC ( TO_DATE( C122.STLFROMDATE,'DD/MM/YYYY')) -1  AS dt
            FROM dual
            )
            SELECT dt + LEVEL  DATES
            FROM d
            CONNECT BY LEVEL <=  ( TO_DATE(C122.STLTODATE,'DD/MM/YYYY') - TO_DATE( C122.STLFROMDATE,'DD/MM/YYYY') + 1 )
            )
            where TO_DATE(WPSLEAVEAPPLICATION.LEAVEDATE,'DD/MM/YYYY')=TO_DATE(DATES,'DD/MM/YYYY')
              --  AND trim(trim(TO_CHAR(DATES,'DAY'))) = UPPER(TRIM(lv_OFFDAY))
              AND ltrim(trim(TO_CHAR(WPSLEAVEAPPLICATION.LEAVEDATE,'DAY'))) = UPPER(LTRIM(TRIM(lv_OFFDAY)))
       );
       
       lv_row_cnt :=lv_row_cnt+1;
       END LOOP;

END;
/


DROP PROCEDURE NJMCL_WEB.RPT_STL_SANCTION_FORM;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.RPT_STL_SANCTION_FORM(P_COMPANYCODE VARCHAR2,P_DIVISIONCODE VARCHAR2,P_STARTDATE VARCHAR2,P_ENDDATE VARCHAR2,P_TOKENNO VARCHAR2)
AS
lv_sqlstr varchar2(30000):='';
BEGIN

    DELETE FROM GTT_WPSSTLDETAILS;
    
    lv_sqlstr:='INSERT INTO GTT_WPSSTLDETAILS
                SELECT COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO,DOCUMENTDATE,DEPARTMENTCODE,SHIFTCODE,PAYMENTDATE,LEAVEFROMDATE,SUM(LEAVEDAYS) DAYS,DOCUMENTNO
                FROM WPSSTLENTRYDETAILS
                WHERE COMPANYCODE='''||P_COMPANYCODE||'''
                    AND DIVISIONCODE='''||P_DIVISIONCODE||'''
                    AND PAYMENTDATE>=TO_DATE('''||P_STARTDATE||''',''DD/MM/YYYY'')
                    AND PAYMENTDATE<=TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'')'||CHR(10);
IF P_TOKENNO IS NOT NULL THEN
lv_sqlstr:=lv_sqlstr||'                    AND TOKENNO IN ('||P_TOKENNO||')'||CHR(10);
END IF;
lv_sqlstr:=lv_sqlstr||'                GROUP BY COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO,DOCUMENTDATE,DEPARTMENTCODE,SHIFTCODE,PAYMENTDATE,LEAVEFROMDATE,DOCUMENTNO';

EXECUTE IMMEDIATE lv_sqlstr;


END;
/


DROP PROCEDURE NJMCL_WEB.PRCSTL_AF_MAINSAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PRCSTL_AF_MAINSAVE
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_WPSSTLENTRY%rowtype;
lv_CompanyCode          varchar2(10) :='';
lv_DivisionCode         varchar2(10) :='';
lv_YearCode             varchar2(9) :='';
lv_DocumentDate         varchar2(10) :='';
lv_OperationMode        varchar2(1) :='';
begin
    lv_result:='#SUCCESS#';
    --Master
    select count(*)
    into lv_cnt
    from GBL_WPSSTLENTRY;
    
    select *
    into lv_Master
    from GBL_WPSSTLENTRY
    WHERE ROWNUM<=1;
   
    

    if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [No row found in STL Entry]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
   DELETE FROM GBL_STLBAL;
 
   PRC_STLBAL_YEARWISE(lv_Master.COMPANYCODE,lv_Master.DIVISIONCODE,TO_CHAR(SYSDATE,'DD/MM/YYYY'),lv_Master.TOKENNO);
   
    FOR C22 
                IN(
                SELECT * FROM GBL_STLBAL
                WHERE COMPANYCODE=lv_Master.COMPANYCODE
                    AND DIVISIONCODE=lv_Master.DIVISIONCODE
                    AND TOKENNO=lv_Master.TOKENNO
                  )
            LOOP 
                --lv_error_remark := 'Validation Failure : [STL Balance Days should be Negative for '||C22.YEAR ||' ]';
               -- raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
                
               IF C22.STLBAL_DAYS<0 THEN
                lv_error_remark := 'Validation Failure : [STL Balance Days should be Negative for '||C22.YEAR ||' ]';
                raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
               END IF;
            END LOOP;
    
    
end;
/


