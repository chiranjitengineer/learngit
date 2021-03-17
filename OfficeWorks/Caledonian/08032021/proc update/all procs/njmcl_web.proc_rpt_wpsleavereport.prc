DROP PROCEDURE NJMCL_WEB.PROC_RPT_WPSLEAVEREPORT;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_RPT_WPSLEAVEREPORT(
                                                P_COMCODE VARCHAR2,
                                                P_DIVICODE VARCHAR2,
                                                P_DOCFROMDATE VARCHAR2,
                                                P_DOCTODATE VARCHAR2,
                                                P_LEAVECODE VARCHAR2,
                                                P_DEPTCODE VARCHAR2 DEFAULT NULL,
                                                P_TOKENNO VARCHAR2 DEFAULT NULL,
                                                P_SHIFTCODE VARCHAR2 DEFAULT NULL,
                                                P_SECTION VARCHAR2 DEFAULT NULL
                                              )
AS
LV_SQLSTR   VARCHAR2(20000):='';
BEGIN
    DELETE FROM GTT_LEAVEDATA;
    
    LV_SQLSTR:='INSERT INTO GTT_LEAVEDATA'||CHR(10)
                ||'SELECT S.TOKENNO, W.WORKERNAME,SEC.DEPARTMENTCODE,S.SECTIONCODE,S.DOCUMENTNO  APPLICATIONNO,S.DOCUMENTDATE APPLICATIONDATE,S.STLFROMDATE,S.STLTODATE,S.STLDAYS,S.FORTNIGHTSTARTDATE,C.COMPANYNAME,'||CHR(10)
                ||'     D.DIVISIONNAME,'''||REPLACE(P_LEAVECODE,'''','')||' ENTRY CHECK LIST FROM '||P_DOCFROMDATE||' TO '||P_DOCTODATE||''' REPORTCAPTION,NULL EX1,NULL EX2,NULL EX3,'||CHR(10)
                ||'     NULL EX4,NULL EX5,NULL EX6,NULL EX7,NULL EX8,NULL EX9,NULL EX10'||CHR(10)
                ||'FROM WPSSTLENTRY S,WPSWORKERMAST W,COMPANYMAST C,DIVISIONMASTER D,WPSSECTIONMAST SEC'||CHR(10)
                ||'WHERE S.COMPANYCODE='''||P_COMCODE||''' '||CHR(10)
                ||'     AND S.DIVISIONCODE='''||P_DIVICODE||''' '; 
               
                 IF P_LEAVECODE IS NOT NULL THEN 
                       LV_SQLSTR:=LV_SQLSTR||'  AND S.LEAVECODE IN ('||P_LEAVECODE||')' ;
                 END IF;     
            
                LV_SQLSTR:=LV_SQLSTR||'  AND S.DOCUMENTDATE>=TO_DATE('''||P_DOCFROMDATE||''',''DD/MM/YYYY'')'||CHR(10)
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
     
     IF P_SECTION IS NOT NULL THEN
        LV_SQLSTR:=LV_SQLSTR||' AND S.SECTIONCODE IN ('||P_SECTION||')'||CHR(10);
     END IF;
    
     LV_SQLSTR:=LV_SQLSTR||'ORDER BY S.SHIFTCODE,S.TOKENNO'||CHR(10);
     
   DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
   EXECUTE IMMEDIATE LV_SQLSTR;
       
END;
/


