CREATE OR REPLACE PROCEDURE PROC_UPD_WAGES_PROCESSBYDIV
(
    P_COMPANYCODE   VARCHAR2,
    P_DIVISIONCODE  VARCHAR2,
    P_YEARCODE      VARCHAR2,
    P_FROMDATE      VARCHAR2,
    P_PERIODTO      VARCHAR2,
    P_LOANCODE      VARCHAR2 DEFAULT NULL,
    P_MODULE        VARCHAR2 DEFAULT NULL,
    P_ISEXECUTE     VARCHAR2 DEFAULT 'N'
)
AS
    LV_SQLSTR     VARCHAR2(4000); 
    LV_MODULE     VARCHAR2(100);
    LV_BALANCE    NUMBER(10);
    LV_UPD_CNT    NUMBER(10);
BEGIN 

--EXEC PROC_UPD_WAGES_PROCESSBYDIV('JT0069','0009','2019-2020','01/06/2019','31/12/2019','PF','GPS','N')
--
--EXEC PROC_UPD_WAGES_PROCESSBYDIV('JT0069','0009','2019-2020','01/06/2019','31/12/2019',NULL,'GPS','N')

    LV_BALANCE := 0;

    IF P_MODULE IS NULL THEN
        LV_MODULE := 'GPS';
    ELSE
        LV_MODULE := P_MODULE;        
    END IF;

    FOR C1 IN 
    (     
        SELECT DISTINCT DIVISIONCODE, PERIODFROM, PERIODTO, YEARCODE FROM GPSPAYSHEETDETAILS
        WHERE DIVISIONCODE=P_DIVISIONCODE 
        AND PERIODFROM >= TO_DATE(P_FROMDATE,'DD/MM/YYYY')
        AND PERIODTO <= TO_DATE(P_PERIODTO,'DD/MM/YYYY')                
        ORDER BY 1,2
    )
    LOOP   

    IF INSTR(NVL(P_LOANCODE,'NA'),'PF') > 0 THEN -- IS NOT NULL THEN --PF LOAN

    --                    SELECT NVL(SUM(AMT),0) INTO LV_BALANCE
    --                    FROM (
    --                        SELECT WORKERSERIAL, SUM(NVL(LOAN_PF,0)+NVL(LINT_PF,0)) AMT FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE=C1.DIVISIONCODE
    --                        AND PERIODFROM = C1.PERIODFROM AND PERIODTO=C1.PERIODTO
    --                        GROUP BY WORKERSERIAL
    --                        HAVING SUM(NVL(LOAN_PF,0)+NVL(LINT_PF,0)) > 0
    --                        UNION ALL 
    --                        SELECT WORKERSERIAL, -1*SUM(AMOUNT) AMT FROM PFLOANBREAKUP WHERE DIVISIONCODE = C1.DIVISIONCODE
    --                        AND EFFECTFORTNIGHT = C1.PERIODTO
    --                        AND MODULE = LV_MODULE AND TRANSACTIONTYPE IN ('CAPITAL','INTEREST')
    --                    --        AND PAIDON >= '10-JUN-2019'
    --                    --        AND PAIDON <= '23-JUN-2019'
    --                        GROUP BY WORKERSERIAL
    --                    );

    LV_SQLSTR :=CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'SELECT NVL(SUM(AMT),0) '||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'FROM '||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'('||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	SELECT WORKERSERIAL, SUM(NVL(LOAN_PF,0)+NVL(LINT_PF,0)) AMT FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE='''||C1.DIVISIONCODE||''''||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	AND PERIODFROM = '''||C1.PERIODFROM||'''  AND PERIODTO='''||C1.PERIODTO||''''||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	GROUP BY WORKERSERIAL'||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	HAVING SUM(NVL(LOAN_PF,0)+NVL(LINT_PF,0)) > 0'||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	UNION ALL '||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	SELECT WORKERSERIAL, -1*SUM(AMOUNT) AMT FROM PFLOANBREAKUP WHERE DIVISIONCODE = '''||C1.DIVISIONCODE||''''||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	AND EFFECTFORTNIGHT = '''||C1.PERIODTO||''''||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	AND MODULE = '''||LV_MODULE||''' AND TRANSACTIONTYPE IN (''CAPITAL'',''INTEREST'')'||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	AND WORKERSERIAL IN '||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	( '||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'		SELECT DISTINCT WORKERSERIAL FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE = '''||C1.DIVISIONCODE||''''||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'		AND PERIODFROM = '''||C1.PERIODFROM||'''  AND PERIODTO='''||C1.PERIODTO||''' '||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	) '||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	GROUP BY WORKERSERIAL'||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||')'||CHR(10)||CHR(10);

    SELECT NVL(COUNT(*),0) INTO LV_UPD_CNT 
    FROM PFLOANBREAKUP
    WHERE DIVISIONCODE = C1.DIVISIONCODE
    AND PAIDON >= C1.PERIODFROM
    AND PAIDON <= C1.PERIODTO 
    AND LOANCODE = P_LOANCODE;

    EXECUTE IMMEDIATE LV_SQLSTR INTO LV_BALANCE;       

    --DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);       
    --DBMS_OUTPUT.PUT_LINE('FOUND  '||LV_UPD_CNT ||' ROWS FROM PFLOANBREAKUP '||CHR(10) );

    IF LV_BALANCE <> 0 THEN

    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR); 

   
--DBMS_OUTPUT.PUT_LINE('RECORD DELETED FROM '||C1.PERIODFROM||'            '||C1.PERIODTO||'        '||P_LOANCODE||'   '||CHR(10));



    IF P_ISEXECUTE = 'Y' THEN
                                     
    --                                    DELETE FROM PFLOANBREAKUP
    --                                     WHERE DIVISIONCODE = C1.DIVISIONCODE
    --                                        AND PAIDON >= C1.PERIODFROM
    --                                        AND PAIDON <= C1.PERIODTO
    --                                        AND LOANCODE= P_LOANCODE
    --                                        AND REMARKS='SALARY';

    PRC_LOANBREAKUP_INSERT_WAGES1(P_COMPANYCODE,P_DIVISIONCODE,C1.YEARCODE,TO_CHAR(C1.PERIODFROM,'DD/MM/YYYY'),TO_CHAR(C1.PERIODTO,'DD/MM/YYYY'),'GPS', 'GPSPAYSHEETDETAILS', 'PF',P_LOANCODE);

    LV_SQLSTR := 'EXEC PRC_LOANBREAKUP_INSERT_WAGES1('''||P_COMPANYCODE||''','''||P_DIVISIONCODE||''','''||C1.YEARCODE||''','''||TO_CHAR(C1.PERIODFROM,'DD/MM/YYYY')||''','''||TO_CHAR(C1.PERIODTO,'DD/MM/YYYY')||''',''GPS'', ''GPSPAYSHEETDETAILS'',''PF'',''PF'')'||CHR(10)||CHR(10);

    COMMIT;

--    SELECT NVL(COUNT(*),0) INTO LV_UPD_CNT FROM PFLOANBREAKUP
--     WHERE DIVISIONCODE = C1.DIVISIONCODE
--        AND PAIDON >= C1.PERIODFROM
--        AND PAIDON <= C1.PERIODTO
--        AND LOANCODE=P_LOANCODE;
-- 

    END IF;
    

    --DBMS_OUTPUT.PUT_LINE('RUN WAGES PROCESS PRC_LOANBREAKUP_%INSERT_WAGES,  '||LV_UPD_CNT ||' ROWS INSERTED INTO ''||PFLOANBREAKUP'||CHR(10) );
    END IF;
    
    LV_SQLSTR := 'DIVCODE : '||C1.DIVISIONCODE ||', FROMDATE : '||C1.PERIODFROM ||', TO DATE : '||C1.PERIODTO||', LOAN CODE : '||P_LOANCODE||', BALANCE : '||LV_BALANCE||CHR(10)||CHR(10)||CHR(10);

    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);

    ELSE   -------------NON PF LOAN
    FOR C2 IN 
    (
        SELECT DISTINCT LOANCODE FROM LOANMASTER 
        WHERE COMPANYCODE=P_COMPANYCODE AND DIVISIONCODE=P_DIVISIONCODE
        ORDER BY 1
    )
    LOOP

    LV_SQLSTR :=CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'SELECT /*WORKERSERIAL,*/ NVL(SUM(AMT),0) '||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'FROM '||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'('||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	SELECT WORKERSERIAL, SUM(NVL(LOAN_'||C2.LOANCODE||',0)+NVL(LINT_'||C2.LOANCODE||',0)) AMT FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE= '''||C1.DIVISIONCODE||''' '||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	AND PERIODFROM = '''||C1.PERIODFROM||''' AND PERIODTO='''||C1.PERIODTO||''''||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	GROUP BY WORKERSERIAL'||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	HAVING SUM(NVL(LOAN_'||C2.LOANCODE||',0)+NVL(LINT_'||C2.LOANCODE||',0)) > 0'||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	UNION ALL '||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	SELECT WORKERSERIAL, -1*SUM(AMOUNT) AMT FROM LOANBREAKUP WHERE DIVISIONCODE =  '''||C1.DIVISIONCODE||''''||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	AND EFFECTFORTNIGHT = '''||C1.PERIODTO||''''||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	AND LOANCODE = '''||C2.LOANCODE||''''||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	AND MODULE = '''||LV_MODULE||''' AND TRANSACTIONTYPE IN (''CAPITAL'',''INTEREST'')'||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	AND WORKERSERIAL IN '||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	( '||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'		SELECT DISTINCT WORKERSERIAL FROM GPSPAYSHEETDETAILS WHERE DIVISIONCODE = '''||C1.DIVISIONCODE||''''||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'		AND PERIODFROM = '''||C1.PERIODFROM||'''  AND PERIODTO='''||C1.PERIODTO||''' '||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	) '||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||'	GROUP BY WORKERSERIAL'||CHR(10);
    LV_SQLSTR :=LV_SQLSTR||')'||CHR(10)||CHR(10);


    EXECUTE IMMEDIATE LV_SQLSTR INTO LV_BALANCE; 
                        

    IF LV_BALANCE <> 0 THEN

        DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);

        LV_SQLSTR := 'DIVCODE : '||C1.DIVISIONCODE ||', FROMDATE : '||C1.PERIODFROM ||', TO DATE : '||C1.PERIODTO||', LOAN CODE : '||C2.LOANCODE||', BALANCE : '||LV_BALANCE||CHR(10);

        DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);

        IF P_ISEXECUTE = 'Y' THEN
                                                           
            --DELETE FROM LOANBREAKUP
            --WHERE DIVISIONCODE = C1.DIVISIONCODE
            --AND PAIDON >= C1.PERIODFROM
            --AND PAIDON <= C1.PERIODTO
            --AND REMARKS='SALARY';
            --AND LOANCODE = C2.LOANCODE;      
     
            PRC_LOANBREAKUP_INSERT_WAGES1(P_COMPANYCODE,P_DIVISIONCODE,C1.YEARCODE,TO_CHAR(C1.PERIODFROM,'DD/MM/YYYY'),TO_CHAR(C1.PERIODTO,'DD/MM/YYYY'),'GPS', 'GPSPAYSHEETDETAILS', 'GENERAL',C2.LOANCODE);

           
            DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);                                                      
                
            LV_SQLSTR := 'EXEC PRC_LOANBREAKUP_INSERT_WAGES1('''||P_COMPANYCODE||''','''||P_DIVISIONCODE||''','''||C1.YEARCODE||''','''||TO_CHAR(C1.PERIODFROM,'DD/MM/YYYY')||''','''||TO_CHAR(C1.PERIODTO,'DD/MM/YYYY')||''',''GPS'', ''GPSPAYSHEETDETAILS'',''GENERAL'','''||C2.LOANCODE||''')'||CHR(10)||CHR(10);

            DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);

            COMMIT;

            SELECT NVL(COUNT(*),0) INTO LV_UPD_CNT 
            FROM LOANBREAKUP
            WHERE DIVISIONCODE = C1.DIVISIONCODE
            AND PAIDON >= C1.PERIODFROM
            AND PAIDON <= C1.PERIODTO
            AND LOANCODE = C2.LOANCODE;

            DBMS_OUTPUT.PUT_LINE(LV_UPD_CNT ||' ROWS INSERTED INTO LOANBREAKUP');
        END IF;  

    ELSE
        LV_SQLSTR := 'DIVCODE : '||C1.DIVISIONCODE ||', FROMDATE : '||C1.PERIODFROM ||', TO DATE : '||C1.PERIODTO||', LOAN CODE : '||C2.LOANCODE||', BALANCE : '||LV_BALANCE||CHR(10);
        DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
    END IF;    

    END LOOP;
    DBMS_OUTPUT.PUT_LINE(CHR(10)||CHR(10)||CHR(10));
    END IF;
    END LOOP;

END;
/