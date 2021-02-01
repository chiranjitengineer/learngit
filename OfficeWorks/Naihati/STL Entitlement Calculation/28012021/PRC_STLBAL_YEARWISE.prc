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
