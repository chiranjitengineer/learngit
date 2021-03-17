DROP PROCEDURE NJMCL_WEB.PROC_WPSPAYMENTDETAILS;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PROC_WPSPAYMENTDETAILS" 
(
    P_COMPANYCODE VARCHAR2,
    P_DIVISIONCODE VARCHAR2,
    P_FROMDATE VARCHAR2,
    P_TODATE VARCHAR2,
    P_TOKENNO VARCHAR2,
    P_RPTOPTION VARCHAR2
)
AS 
    LV_SQLSTR           VARCHAR2(30000);
BEGIN
    DELETE FROM GTT_WPSPAYMENTDETAILS;
    LV_SQLSTR :=    ' INSERT INTO GTT_WPSPAYMENTDETAILS '|| CHR(10)        
                  ||' SELECT B.WORKERCATEGORYCODE,B.UNITCODE,B.DEPARTMENTCODE MASTDEPARTMENT,A.DEPARTMENTCODE ACTUALDEPT,'||CHR(10)
                  ||'        A.TOKENNO,B.WORKERNAME, A.ACTUALPAYBLEAMOUNT,B.BANKACNO,C.BANKCODE,M.COMPANYNAME,     '||CHR(10)     
                  ||'       ''Run Date '' ||TO_CHAR(SYSDATE,''DD/MM/RRRR'') AS RUNDATE,'||CHR(10)
                  ||'       ''For the Period From '' ||'''||P_FROMDATE||'''||'' To ''||'''||P_TODATE||'''  FROMTODATE'||CHR(10)
                  ||' FROM  WPSWAGESDETAILS_MV A, WPSWORKERMAST B,SALESBANKMASTER C,COMPANYMAST M'||CHR(10)
                  ||' WHERE A.COMPANYCODE='''||P_COMPANYCODE||'''   '||CHR(10) 
                  ||'   AND A.DIVISIONCODE='''||P_DIVISIONCODE||'''   '||CHR(10)   
                  ||'   AND A.FORTNIGHTSTARTDATE=TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'') '||CHR(10)   
                  ||'   AND A.FORTNIGHTENDDATE=TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'') '||CHR(10)   
                  ||'   AND A.COMPANYCODE=B.COMPANYCODE'||CHR(10)   
                  ||'   AND A.DIVISIONCODE=B.DIVISIONCODE'||CHR(10)   
                  ||'   AND A.WORKERSERIAL=B.WORKERSERIAL'||CHR(10)   
                  ||'   AND B.COMPANYCODE=C.COMPANYCODE(+)'||CHR(10)   
                  ||'   AND B.DIVISIONCODE=C.DIVISIONCODE(+)'||CHR(10)   
                  ||'   AND B.BANKCODE=C.BANKCODE(+)'||CHR(10)   
                  ||'   AND A.COMPANYCODE=M.COMPANYCODE  '||CHR(10) ;  
                  IF P_TOKENNO IS NOT NULL THEN
                      LV_SQLSTR := LV_SQLSTR ||' AND A.TOKENNO IN ( '||P_TOKENNO||')  '||CHR(10);
                  END IF;      
                   IF P_RPTOPTION ='Banking' THEN
                      LV_SQLSTR := LV_SQLSTR ||'  AND B.BANKACNO IS NOT NULL  '||CHR(10);
                   ELSE
                      LV_SQLSTR := LV_SQLSTR ||'  AND B.BANKACNO IS NULL  '||CHR(10);
                  END IF;                           
                  LV_SQLSTR := LV_SQLSTR   ||'ORDER BY B.WORKERCATEGORYCODE , B.UNITCODE,B.DEPARTMENTCODE,B.WORKERNAME  '||CHR(10); 

   
                 
         
  --DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
 EXECUTE IMMEDIATE LV_SQLSTR;
END;
/


