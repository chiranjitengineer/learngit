CREATE OR REPLACE PROCEDURE PRC_PIS_REIMBURSMENT_ENT (P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2,
                                                  P_YEARCODE varchar2,
                                                  P_YEARMONTH Varchar2,
                                                  P_COMPONENTCODE varchar2,
                                                  P_UNITCODE varchar2 DEFAULT NULL,
                                                  P_CATEGORYCODE varchar2 DEFAULT NULL,
                                                  P_GRADECODE varchar2 DEFAULT NULL,
                                                  P_USERNAME varchar2 DEFAULT NULL,
                                                  P_OPTMODE varchar2 DEFAULT 'A'
                                                 )
AS
lv_error_remark     varchar2(1000) := '';
lv_SqlStr           varchar2(4000);
lv_Count            number;
lv_result           varchar2(10);
lv_YearCode         varchar2(10);
lv_NumMonth         number;
lv_NumDays          number;
lv_NumWorkDays      number;
lv_FinStartDate     date;
lv_FinEndDate     date;
lv_ReimbsAmt_NwEmp  number(15,2);
lv_TokenNo          varchar2(50);
lv_CatCode          varchar2(50);
lv_Grade            varchar2(50);
lv_BasicAmt         number(15,2);
LV_PAYFORMULA       varchar2(500);
begin

 lv_result:='#SUCCESS#'; 

 lv_SqlStr := 'SELECT COUNT(*) '||CHR(10)
                ||'  FROM PISGRADECOMPONENTMAPPING '||CHR(10)
                ||'  WHERE COMPANYCODE='''||P_COMPCODE ||''' '||CHR(10)
                ||'  AND DIVISIONCODE='''||P_DIVCODE ||''' '||CHR(10)
                ||'  AND COMPONENTCODE='''||P_COMPONENTCODE||''' '||CHR(10);
     IF NVL(P_CATEGORYCODE,'NA') <> 'NA' THEN
         lv_SqlStr := lv_SqlStr || '   AND CATEGORYCODE = '''||P_CATEGORYCODE||''' '||CHR(10);
     END IF;
      IF NVL(P_GRADECODE,'NA') <> 'NA' THEN
         lv_SqlStr := lv_SqlStr || '   AND GRADECODE = '''||P_GRADECODE||''' '||CHR(10);
     END IF;
    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);   ---------------------------------------------|||||
     EXECUTE IMMEDIATE lv_SqlStr INTO lv_Count;  
  
    SELECT NVL(PAYFORMULA,'0') INTO LV_PAYFORMULA FROM PISCOMPONENTMASTER
    WHERE COMPANYCODE=P_COMPCODE
    AND DIVISIONCODE=P_DIVCODE
    AND COMPONENTCODE=P_COMPONENTCODE;
        
     LV_PAYFORMULA := REPLACE(LV_PAYFORMULA,'PISASSIGN','B');

--    if lv_Count = 0 then
--        lv_error_remark := 'Validation Failure : [No Component Mapping Found For Category ]';
--        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
--    end if;
    
     PRC_PISVIEWCREATION (P_COMPCODE,P_DIVCODE,'PISASSIGN',0,P_YEARMONTH,P_YEARMONTH, 'SALARY', 'PISPAYTRANSACTION_SWT');
     
     
    DELETE FROM GTT_PISREIMBURSEMENT_ENTITLE WHERE 1=1;

IF NVL(P_OPTMODE,'A') <> 'A' THEN

lv_SqlStr :=  'INSERT INTO GTT_PISREIMBURSEMENT_ENTITLE '|| CHR(10)
    ||' ( COMPANYCODE, DIVISIONCODE, YEARCODE, WORKERSERIAL, TOKENNO,EMPLOYEENAME,DATEOFJOIN, UNITCODE, CATEGORYCODE, GRADECODE, COMPONENTCODE, COMPONENTAMOUNT, TRANSACTIONTYPE, ADDLESS,PAYMENTMODE)' ||CHR(10)
    ||'SELECT A.COMPANYCODE, A.DIVISIONCODE, A.YEARCODE, A.WORKERSERIAL, A.TOKENNO,B.EMPLOYEENAME, TO_CHAR(B.DATEOFJOIN,''DD/MM/YYYY'') DATEOFJOIN, '||CHR(10)
    ||'A.UNITCODE, A.CATEGORYCODE, A.GRADECODE, A.COMPONENTCODE, A.COMPONENTAMOUNT, A.TRANSACTIONTYPE, A.ADDLESS, A.PAYMENTMODE '||CHR(10)
    ||'FROM PISREIMBURSEMENT_ENTITLE A, PISEMPLOYEEMASTER B'||CHR(10)
    ||'WHERE A.COMPANYCODE=B.COMPANYCODE  '||CHR(10)
    ||'AND A.DIVISIONCODE=B.DIVISIONCODE  '||CHR(10)
    ||'AND A.WORKERSERIAL=B.WORKERSERIAL  '||CHR(10)
    ||'AND B.EMPLOYEESTATUS= ''ACTIVE'' '||CHR(10)
    ||'AND A.COMPANYCODE='''||P_COMPCODE||''''||CHR(10)
    ||'AND A.DIVISIONCODE='''||P_DIVCODE||''''||CHR(10);

IF (P_UNITCODE IS NOT NULL) THEN
    lv_SqlStr := lv_SqlStr ||'AND A.UNITCODE='''||P_UNITCODE||''''||CHR(10);
END IF;

IF (P_CATEGORYCODE IS NOT NULL) THEN
    lv_SqlStr := lv_SqlStr ||'AND A.CATEGORYCODE='''||P_CATEGORYCODE||''''||CHR(10);
END IF;

IF (P_GRADECODE IS NOT NULL) THEN
    lv_SqlStr := lv_SqlStr ||'AND A.GRADECODE='''||P_GRADECODE||''''||CHR(10);
END IF;

lv_SqlStr := lv_SqlStr ||'AND A.YEARCODE='''||P_YEARCODE||''''||CHR(10)
||'AND A.COMPONENTCODE='''||P_COMPONENTCODE||''''||CHR(10)
||'AND A.TRANSACTIONTYPE=''ENTITLEMENT'''||CHR(10);

    DBMS_OUTPUT.PUT_LINE('lv_SqlStr '||CHR(10)||lv_SqlStr);  
    execute immediate lv_SqlStr;
    
ELSE


    lv_SqlStr :=  'INSERT INTO GTT_PISREIMBURSEMENT_ENTITLE '|| CHR(10)
    ||' ( COMPANYCODE, DIVISIONCODE, YEARCODE, WORKERSERIAL, TOKENNO,EMPLOYEENAME,DATEOFJOIN, UNITCODE, CATEGORYCODE, GRADECODE, COMPONENTCODE, COMPONENTAMOUNT, TRANSACTIONTYPE, ADDLESS)' ||CHR(10)
    ||'   SELECT DISTINCT A.COMPANYCODE, A.DIVISIONCODE,'''||P_YEARCODE||''' YEARCODE, A.WORKERSERIAL, A.TOKENNO, A.EMPLOYEENAME, TO_CHAR(DATEOFJOIN,''DD/MM/YYYY'') DATEOFJOIN,'|| CHR(10)
    ||'  A.UNITCODE,A.CATEGORYCODE,A.GRADECODE,'''||P_COMPONENTCODE||''' COMPONENTCODE,'||LV_PAYFORMULA||' COMPONENTAMOUNT,''ENTITLEMENT'' TRANSACTIONTYPE,''ADD'' ADDLESS '|| CHR(10)
    ||'  FROM PISEMPLOYEEMASTER A,PISASSIGN B '|| CHR(10)
    ||'  WHERE A.COMPANYCODE=B.COMPANYCODE '|| CHR(10)
    ||'  AND A.DIVISIONCODE=B.DIVISIONCODE '|| CHR(10)
    ||'  AND A.WORKERSERIAL=B.WORKERSERIAL '|| CHR(10)
    ||'  AND A.EMPLOYEESTATUS=''ACTIVE'' '|| CHR(10)
    ||'  AND A.COMPANYCODE='''||P_COMPCODE ||''' '|| CHR(10)
    ||'  AND A.DIVISIONCODE='''||P_DIVCODE ||''' '|| CHR(10);
    
    IF NVL(P_CATEGORYCODE,'NA') <> 'NA' THEN
        lv_SqlStr := lv_SqlStr || '   AND A.CATEGORYCODE = '''||P_CATEGORYCODE||''' '||CHR(10);
    END IF;
    
    IF NVL(P_UNITCODE,'NA') <> 'NA' THEN
        lv_SqlStr := lv_SqlStr || '   AND A.UNITCODE = '''||P_UNITCODE||''' '||CHR(10);
    END IF;
    
    IF NVL(P_GRADECODE,'NA') <> 'NA' THEN
        lv_SqlStr := lv_SqlStr || '   AND A.GRADECODE = '''||P_GRADECODE||''' '||CHR(10);
    END IF;
    --lv_SqlStr := lv_SqlStr || '   AND A.WORKERSERIAL IN (''000581'')  '||CHR(10);
    DBMS_OUTPUT.PUT_LINE('lv_SqlStr '||CHR(10)||lv_SqlStr);  
    execute immediate lv_SqlStr;

    
    lv_SqlStr := 'DELETE FROM TEMP_REIMBURSMENT' ||CHR(10);
    
    EXECUTE IMMEDIATE lv_SqlStr;
    
    lv_SqlStr := ' INSERT INTO  TEMP_REIMBURSMENT  '||CHR(10)
    ||' SELECT DISTINCT A.WORKERSERIAL,A.DATEOFJOIN ,A.CATEGORYCODE, A.GRADECODE,B.BASIC '||CHR(10)
    ||' FROM PISEMPLOYEEMASTER A,PISASSIGN B '||CHR(10)
    ||' WHERE A.COMPANYCODE=B.COMPANYCODE '||CHR(10)
    ||' AND A.DIVISIONCODE=B.DIVISIONCODE '||CHR(10)
    ||' AND A.WORKERSERIAL=B.WORKERSERIAL '||CHR(10)
    ||' AND A.COMPANYCODE='''||P_COMPCODE ||''' '||CHR(10)
    ||' AND A.DIVISIONCODE='''||P_DIVCODE ||'''  '||CHR(10)  
    ||' AND A.EMPLOYEESTATUS=''ACTIVE'' '||CHR(10);
    
    IF NVL(P_CATEGORYCODE,'NA') <> 'NA' THEN
        lv_SqlStr := lv_SqlStr || '   AND A.CATEGORYCODE = '''||P_CATEGORYCODE||''' '||CHR(10);
    END IF;
    IF NVL(P_GRADECODE,'NA') <> 'NA' THEN
        lv_SqlStr := lv_SqlStr || '   AND A.GRADECODE = '''||P_GRADECODE||''' '||CHR(10);
    END IF;
    --lv_SqlStr := lv_SqlStr || '   AND A.workerserial=''000581'' '||CHR(10);
    -- DBMS_OUTPUT.PUT_LINE(lv_SqlStr);  
    EXECUTE IMMEDIATE lv_SqlStr;


    for c1 in 
    ( 
        SELECT * FROM TEMP_REIMBURSMENT
              --   WHERE WORKERSERIAL='000581'
    ) 
    loop
        lv_YearCode:='';          
        SELECT COUNT(*)
        INTO lv_Count
        FROM FINANCIALYEAR 
        WHERE COMPANYCODE=P_COMPCODE 
        AND DIVISIONCODE=P_DIVCODE 
        AND STARTDATE <=C1.DATEOFJOIN 
        AND ENDDATE >=C1.DATEOFJOIN ;

        IF lv_Count>0 THEN

            SELECT YEARCODE
            INTO lv_YearCode FROM FINANCIALYEAR 
            WHERE STARTDATE <=C1.DATEOFJOIN 
            AND ENDDATE >=C1.DATEOFJOIN 
            AND ROWNUM=1;

        END IF;
        
        SELECT STARTDATE , ENDDATE INTO lv_FinStartDate,lv_FinEndDate FROM FINANCIALYEAR 
        WHERE COMPANYCODE=P_COMPCODE
        AND DIVISIONCODE=P_DIVCODE
        AND YEARCODE=P_YEARCODE
        AND ROWNUM=1;                   

        --            SELECT TO_DATE('01/'|| SUBSTR(P_YEARMONTH,5,2)||'/'|| SUBSTR(P_YEARMONTH,1,4),'DD/MM/YYYY')  
        --            INTO lv_FinStartDate
        --            FROM DUAL ;
        DBMS_OUTPUT.PUT_LINE(P_YEARCODE||'lv_YearCode ' ||lv_YearCode||'  WORKERSERIAL '||C1.WORKERSERIAL );
        if P_YEARCODE=lv_YearCode then

            select TRUNC(MONTHS_BETWEEN (TO_DATE(lv_FinEndDate,'DD/MM/YY'),TO_DATE(C1.DATEOFJOIN ,'DD/MM/YY')),0)
            --select TRUNC(MONTHS_BETWEEN (TO_DATE(C1.DATEOFJOIN,'DD/MM/YY'),TO_DATE(lv_FinEndDate ,'DD/MM/YY')),0) 
            into lv_NumMonth from dual;   
            DBMS_OUTPUT.PUT_LINE(lv_NumMonth||'lv_NumMonth '||lv_FinEndDate||'   lv_FinEndDate'||C1.DATEOFJOIN||'C1.DATEOFJOIN' );    

            IF ABS(lv_NumMonth) <12 THEN

                SELECT CAST(to_char(LAST_DAY(to_date(c1.DATEOFJOIN,'dd/mm/yyyy')),'dd') AS INT),CAST(to_char(LAST_DAY(to_date(c1.DATEOFJOIN,'dd/mm/yyyy')),'dd') AS INT) -
                cast(to_char(to_date(c1.DATEOFJOIN,'dd/mm/yyyy'),'dd') as int)+1
                into lv_NumWorkDays,lv_NumDays
                FROM dual;  
                -- DBMS_OUTPUT.PUT_LINE(lv_BasicAmt||'   lv_BasicAmt  '||lv_NumMonth||' lv_NumMonth '||lv_NumDays||'lv_NumDays' ); 
                IF lv_NumWorkDays= lv_NumDays  THEN
                    lv_ReimbsAmt_NwEmp := (c1.BASIC*lv_NumMonth)/12;                       
                ELSE
                    lv_ReimbsAmt_NwEmp := ((c1.BASIC*lv_NumMonth)/12)+( (c1.BASIC /12)/( lv_NumWorkDays/lv_NumDays));
                END IF; 

                --lv_BasicAmt:=lv_BasicAmt+lv_ReimbsAmt_NwEmp;     
                -- DBMS_OUTPUT.PUT_LINE(lv_ReimbsAmt_NwEmp||'   lv_ReimbsAmt_NwEmp'||lv_BasicAmt||'lv_BasicAmt' );                                 

                lv_SqlStr :=  'UPDATE GTT_PISREIMBURSEMENT_ENTITLE SET COMPONENTAMOUNT='||lv_ReimbsAmt_NwEmp||' '|| CHR(10)
                ||' WHERE COMPANYCODE='''||P_COMPCODE||''' '||CHR(10)
                ||' AND DIVISIONCODE='''||P_DIVCODE||''' '||CHR(10)
                ||' AND YEARCODE='''||P_YEARCODE||''' '||CHR(10) 
                ||' AND WORKERSERIAL= '''||C1.WORKERSERIAL||''' '||CHR(10);
                --DBMS_OUTPUT.PUT_LINE(lv_SqlStr);                              
                execute immediate lv_SqlStr;  
            END IF;               

        end if;

    end loop;       

END IF;
 
end;
/
