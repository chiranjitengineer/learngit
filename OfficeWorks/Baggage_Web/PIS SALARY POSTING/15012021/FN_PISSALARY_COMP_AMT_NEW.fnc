CREATE OR REPLACE FUNCTION BAGGAGE_WEB.FN_PISSALARY_COMP_AMT_NEW
--discuss with amalesh sir and debasis dutta on 27/10/2020
--for pis posting data arrear amount include with salary amount
(
   P_COMPCODE VARCHAR2, 
   P_DIVCODE VARCHAR2, 
   P_PROCESSTYPE VARCHAR2 DEFAULT 'SALARY PROCESS',
   P_COMPONENT VARCHAR2,
   P_YEARMONTH VARCHAR2, 
   P_CATEGORYCODE VARCHAR2 DEFAULT NULL , 
   P_UNITCODE VARCHAR2 DEFAULT NULL, 
   P_GRADECODE VARCHAR2 DEFAULT NULL 
) RETURN NUMBER
AS
lv_Sql        varchar2(1000);
lv_Amt        number(11,2):=0;
lv_YearMonth  varchar2(6) := P_YEARMONTH;
lv_strtablename     varchar2(50);
LV_CNT NUMBER(10);
LV_SARR_ARRD NUMBER(10,2);
BEGIN

    SELECT COUNT(*) INTO LV_CNT FROM PISCOMPONENTMASTER
    WHERE COMPONENTCODE=P_COMPONENT
    AND NVL(COMPONENTTYPE,'OTHERS') <> 'OTHERS'
    AND NVL(PHASE,-1) > 0
    AND DIVISIONCODE=P_DIVCODE;
    
--    LV_CNT := 0;
    
    

    if p_processtype = 'SALARY PROCESS' THEN
       lv_strtablename := 'PISPAYTRANSACTION';    
    elsif p_processtype = 'ARREAR PROCESS' THEN
       lv_strtablename := 'PISARREARTRANSACTION';  
    elsif p_processtype = 'REIMBURSEMENT PROCESS' THEN
       lv_strtablename := 'PISREIMBURSEMENTDETAILS';
    end if;    

   
    if p_processtype = 'REIMBURSEMENT PROCESS' THEN
     --lv_Sql := 'SELECT SUM(NVL('||P_COMPONENT||',0) + DECODE('''||P_COMPONENT||''',''PF_C'',NVL(FPF,0),0) )  '||chr(10)
        lv_Sql := 'SELECT SUM(NVL(PAIDAMOUNT,0)) '||chr(10); -- Change by Bishwanath on 03/01/2020,B'coz Pension value will post separately,as per Ashish Mohota
                
        lv_Sql := lv_Sql ||' FROM ' || lv_strtablename || ' A, PISEMPLOYEEMASTER B'||chr(10);
        lv_Sql := lv_Sql ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10);
        lv_Sql := lv_Sql ||'   AND A.YEARMONTH = '''||lv_YearMonth||''' '||chr(10);
        lv_Sql := lv_Sql ||'   AND A.COMPONENTCODE = '''||P_COMPONENT||''' '||chr(10);
        
        lv_Sql := lv_Sql ||'   AND A.COMPANYCODE=B.COMPANYCODE'||chr(10);
        lv_Sql := lv_Sql ||'   AND A.DIVISIONCODE=B.DIVISIONCODE'||chr(10);
        lv_Sql := lv_Sql ||'   AND A.WORKERSERIAL=B.WORKERSERIAL'||chr(10);
        lv_Sql := lv_Sql ||'   AND A.TOKENNO=B.TOKENNO'||chr(10);
    
    IF P_CATEGORYCODE IS NOT NULL THEN
        lv_Sql := lv_Sql ||'   AND A.CATEGORYCODE = ''' || P_CATEGORYCODE || '''' ||chr(10);
    END IF;
    IF P_UNITCODE IS NOT NULL THEN
        lv_Sql := lv_Sql ||'   AND UNITCODE = ''' || P_UNITCODE || '''' ||chr(10);
    END IF;
    IF P_GRADECODE IS NOT NULL THEN
        lv_Sql := lv_Sql ||'   AND A.GRADECODE = ''' || P_GRADECODE || '''' ||chr(10);
    END IF;
    
        
    ELSE
     --lv_Sql := 'SELECT SUM(NVL('||P_COMPONENT||',0) + DECODE('''||P_COMPONENT||''',''PF_C'',NVL(FPF,0),0) )  '||chr(10)
   
            
        if LV_CNT > 0  THEN
        
        
        lv_Sql := 'SELECT SUM(NVL(SARR_ARRD,0))' ||chr(10) 
                || 'FROM PISPAYTRANSACTION A' ||chr(10) 
                ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                ||' AND YEARMONTH = '''||lv_YearMonth||''' '||chr(10);
                
        IF P_CATEGORYCODE IS NOT NULL THEN
            lv_Sql := lv_Sql ||'   AND A.CATEGORYCODE = ''' || P_CATEGORYCODE || '''' ||chr(10);
        END IF;
        IF P_UNITCODE IS NOT NULL THEN
            lv_Sql := lv_Sql ||'   AND UNITCODE = ''' || P_UNITCODE || '''' ||chr(10);
        END IF;
        IF P_GRADECODE IS NOT NULL THEN
            lv_Sql := lv_Sql ||'   AND A.GRADECODE = ''' || P_GRADECODE || '''' ||chr(10);
        END IF;
            
        
        DBMS_OUTPUT.PUT_LINE (lv_Sql);
        execute immediate lv_Sql into LV_SARR_ARRD;    
            


        
        lv_Sql := 'select sum('|| P_COMPONENT ||') from ('||chr(10);
            lv_Sql := lv_Sql || 'SELECT SUM(NVL('||P_COMPONENT||',0)) '||P_COMPONENT||chr(10) -- Change by Bishwanath on 03/01/2020,B'coz Pension value will post separately,as per Ashish Mohota
            /*||' FROM PISPAYTRANSACTION '||chr(10)*/
            ||' FROM ' || lv_strtablename || ' A'||chr(10)
            ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'   AND YEARMONTH = '''||lv_YearMonth||''' '||chr(10);
            
            IF P_CATEGORYCODE IS NOT NULL THEN
                lv_Sql := lv_Sql ||'   AND A.CATEGORYCODE = ''' || P_CATEGORYCODE || '''' ||chr(10);
            END IF;
            IF P_UNITCODE IS NOT NULL THEN
                lv_Sql := lv_Sql ||'   AND UNITCODE = ''' || P_UNITCODE || '''' ||chr(10);
            END IF;
            IF P_GRADECODE IS NOT NULL THEN
                lv_Sql := lv_Sql ||'   AND A.GRADECODE = ''' || P_GRADECODE || '''' ||chr(10);
            END IF;
            
            IF P_PROCESSTYPE = 'SALARY PROCESS' THEN
                lv_Sql := lv_Sql ||'   AND A.TRANSACTIONTYPE = ''SALARY''' ||chr(10);   
            ELSIF P_PROCESSTYPE = 'ARREAR PROCESS' THEN
                lv_Sql := lv_Sql ||'   AND A.TRANSACTIONTYPE = ''ARREAR''' ||chr(10); 
            END IF;    

            
            if p_processtype = 'SALARY PROCESS' AND LV_SARR_ARRD > 0 THEN
             
                lv_Sql := lv_Sql || 'UNION ALL'||CHR(10);
                lv_Sql := lv_Sql ||'SELECT SUM(NVL('||P_COMPONENT||',0)) '||P_COMPONENT||chr(10) -- Change by Bishwanath on 03/01/2020,B'coz Pension value will post separately,as per Ashish Mohota
                        /*||' FROM PISPAYTRANSACTION '||chr(10)*/
                        ||' FROM PISARREARTRANSACTION A'||chr(10)
                        ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                        ||'   AND YEARMONTH = '''||lv_YearMonth||''' AND TRANSACTIONTYPE=''ARREAR'''||chr(10);
                        
                IF P_CATEGORYCODE IS NOT NULL THEN
                    lv_Sql := lv_Sql ||'   AND A.CATEGORYCODE = ''' || P_CATEGORYCODE || '''' ||chr(10);
                END IF;
                IF P_UNITCODE IS NOT NULL THEN
                    lv_Sql := lv_Sql ||'   AND UNITCODE = ''' || P_UNITCODE || '''' ||chr(10);
                END IF;
                IF P_GRADECODE IS NOT NULL THEN
                    lv_Sql := lv_Sql ||'   AND A.GRADECODE = ''' || P_GRADECODE || '''' ||chr(10);
                END IF;
            
            END IF;
            lv_Sql := lv_Sql ||')'||chr(10);
        ELSE
             lv_Sql := 'SELECT SUM(NVL('||P_COMPONENT||',0)) '||chr(10) -- Change by Bishwanath on 03/01/2020,B'coz Pension value will post separately,as per Ashish Mohota
            /*||' FROM PISPAYTRANSACTION '||chr(10)*/
            ||' FROM ' || lv_strtablename || ' A'||chr(10)
            ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'   AND YEARMONTH = '''||lv_YearMonth||''' '||chr(10);
                     
            IF P_CATEGORYCODE IS NOT NULL THEN
                lv_Sql := lv_Sql ||'   AND A.CATEGORYCODE = ''' || P_CATEGORYCODE || '''' ||chr(10);
            END IF;
            IF P_UNITCODE IS NOT NULL THEN
                lv_Sql := lv_Sql ||'   AND UNITCODE = ''' || P_UNITCODE || '''' ||chr(10);
            END IF;
            IF P_GRADECODE IS NOT NULL THEN
                lv_Sql := lv_Sql ||'   AND A.GRADECODE = ''' || P_GRADECODE || '''' ||chr(10);
            END IF;
            
            IF P_PROCESSTYPE = 'SALARY PROCESS' THEN
                lv_Sql := lv_Sql ||'   AND A.TRANSACTIONTYPE = ''SALARY''' ||chr(10);   
            ELSIF P_PROCESSTYPE = 'ARREAR PROCESS' THEN
                lv_Sql := lv_Sql ||'   AND A.TRANSACTIONTYPE = ''ARREAR''' ||chr(10); 
            END IF;    
    
        END IF;
        
    end if;        

        
    
           
    DBMS_OUTPUT.PUT_LINE (lv_Sql);
    
    execute immediate lv_Sql into lv_Amt;
    return  lv_Amt;
exception
    when others then
    RETURN 0;   
        
END;
/
