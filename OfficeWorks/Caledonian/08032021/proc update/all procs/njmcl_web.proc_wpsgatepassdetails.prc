DROP PROCEDURE NJMCL_WEB.PROC_WPSGATEPASSDETAILS;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPSGATEPASSDETAILS (P_COMPANYCODE VARCHAR2, P_DIVISIONCODE VARCHAR2, P_FROMDATE VARCHAR2, P_TODATE VARCHAR2, P_TOKENNO VARCHAR2, P_DEPARTMENTCODE VARCHAR2, P_CATEGORYCODE VARCHAR2, P_UNITCODE VARCHAR2)
AS
LV_SQLSTR   VARCHAR2(4000)  :=  '';
BEGIN
    
    DELETE FROM GTT_WPSGATEPASSDETAILS;

    LV_SQLSTR := 'INSERT INTO GTT_WPSGATEPASSDETAILS '||CHR(10)
               ||'SELECT COM.COMPANYNAME,DIV.DIVISIONNAME,A.TOKENNO,A.WORKERNAME,B.DATEOFATTENDANCE,B.SHIFTCODE, '||CHR(10)
               ||'       B.SPELL,B.DEDUCTIONHOURS,B.REMARKS, '||CHR(10)
               ||'       CASE WHEN '''||P_FROMDATE||''' = '''||P_TODATE||''' THEN ''As on ''|| '''||P_FROMDATE||''' '||CHR(10)
               ||'            WHEN '''||P_FROMDATE||''' <> '''||P_TODATE||''' THEN ''Period from ''|| '''||P_FROMDATE||''' ||'' to ''|| '''||P_TODATE||''' '||CHR(10)
               ||'       END PERIOD, '||chr(10)
               ||'       A.SRLNO EX1,A.GROUPCODE EX2,A.WORKERCODE EX3,'''' EX4,'''' EX5 '||CHR(10)
               ||'   FROM WPSWORKERMAST A, WPSACCIDENTGATEPASSDETAILS B, COMPANYMAST COM, DIVISIONMASTER DIV '||CHR(10)
               ||'  WHERE A.COMPANYCODE = '''||P_COMPANYCODE||'''  '||CHR(10)
               ||'    AND A.DIVISIONCODE = '''||P_DIVISIONCODE||'''  '||CHR(10)
               ||'    AND A.COMPANYCODE = B.COMPANYCODE  '||CHR(10)
               ||'    AND A.DIVISIONCODE = B.DIVISIONCODE  '||CHR(10)
               ||'    AND A.COMPANYCODE = COM.COMPANYCODE '||CHR(10)
               ||'    AND A.COMPANYCODE = DIV.COMPANYCODE   '||CHR(10)
               ||'    AND A.DIVISIONCODE = DIV.DIVISIONCODE  '||CHR(10)
               ||'    AND B.TRANSACTIONTAG = ''GATE PASS'' '||CHR(10)
               ||'    AND A.TOKENNO = B.TOKENNO  '||CHR(10);
       IF NVL(P_TOKENNO,'NA')<>'NA' THEN
           LV_SQLSTR := LV_SQLSTR||'    AND A.TOKENNO IN ('||P_TOKENNO||')  '||CHR(10);
       END IF; 
       IF NVL(P_DEPARTMENTCODE,'NA')<>'NA' THEN
           LV_SQLSTR := LV_SQLSTR||'    AND A.DEPARTMENTCODE IN ('||P_DEPARTMENTCODE||')  '||CHR(10);
       END IF;
       IF NVL(P_CATEGORYCODE,'NA')<>'NA' THEN
           LV_SQLSTR := LV_SQLSTR||'    AND A.WORKERCATEGORYCODE IN ('||P_CATEGORYCODE||')  '||CHR(10);
       END IF;
       IF NVL(P_UNITCODE,'NA')<>'NA' THEN
           LV_SQLSTR := LV_SQLSTR||'    AND A.UNITCODE IN ('||P_UNITCODE||')  '||CHR(10);
       END IF;
       IF NVL(P_FROMDATE,'NA')<>'NA' AND NVL(P_TODATE,'NA')<>'NA' THEN
           LV_SQLSTR := LV_SQLSTR||'    AND B.DATEOFATTENDANCE >= TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'')  '||CHR(10)
                                 ||'    AND B.DATEOFATTENDANCE <= TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')  '||CHR(10);
       END IF;        
           LV_SQLSTR := LV_SQLSTR||'    AND NVL(A.ACTIVE,''N'') =''Y''  '||CHR(10);
       LV_SQLSTR := LV_SQLSTR ||' ORDER BY B.DATEOFATTENDANCE, A.TOKENNO '||CHR(10);
                                 
       --DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
       
       EXECUTE IMMEDIATE LV_SQLSTR;

END;
/


