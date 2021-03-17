DROP PROCEDURE NJMCL_WEB.PROC_WPSMCFORMAT;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PROC_WPSMCFORMAT" 
(
    P_COMPANYCODE VARCHAR2,
    P_DIVISIONCODE VARCHAR2,
    P_YEARCODE VARCHAR2,
    P_FROMDATE VARCHAR2,
    P_TODATE VARCHAR2,
    P_TOKENNO VARCHAR2   
)
AS 
    LV_SQLSTR           VARCHAR2(20000);
BEGIN
    DELETE FROM GTT_WPSMCFORMAT;
    LV_SQLSTR :=    'INSERT INTO GTT_WPSMCFORMAT '|| CHR(10)
   ||'  SELECT A.WORKERSERIAL,W.TOKENNO, A.WORKERNAME, A.ESINO, '|| CHR(10)
   ||'  CASE WHEN A.BLOCK_DATE IS NOT NULL THEN A.BLOCK_DATE ELSE NULL END BLOCKDATE, '|| 

CHR(10)
   ||'  CASE WHEN A.DATEOFRETIREMENT IS NOT NULL THEN  MAX(A.DATEOFRETIREMENT) ELSE NULL 

END RETIREMENT,'|| CHR(10)
   ||'      NVL(X.DAYS,0) DAYS,  (NVL(B.STLDAYS,0) + NVL(B.LEAVEDAYS,0)) AS STLDAYS, '|| 

CHR(10)
   ||'    CASE WHEN SUM(NVL(ESI_CONT,0))> 0 THEN ROUND(SUM(NVL(PF_GROSS,0) + NVL(HRA,0) + 

NVL(LOWAGES,0) - NVL(STL_AMT,0)),2) ELSE 0 END ESI_GROSS, '|| CHR(10)
   ||'     NVL(LASTWORKINGDAY,NULL) LASTWORKINGDAY, SUM(W.HOLIDAYHOURS)/8 HOLIDAYDAYS,'|| 

CHR(10)
   ||'  C.COMPANYCODE,D.DIVISIONCODE,C.COMPANYNAME,C.COMPANYADDRESS,C.COMPANYADDRESS1, 

C.COMPANYADDRESS2,D.DIVISIONNAME '|| CHR(10)
   ||' FROM WPSWORKERMAST A , WPSWAGESDETAILS_MV W,COMPANYMAST C ,DIVISIONMASTER D ,'|| 

CHR(10)
   ||' (SELECT WORKERSERIAL,SUM(STLDAYS)STLDAYS,SUM(LEAVEDAYS) LEAVEDAYS'|| CHR(10)
   ||' FROM'|| CHR(10)
   ||' ('|| CHR(10)
   ||'  SELECT WORKERSERIAL, SUM(STLDAYS)STLDAYS, 0 AS LEAVEDAYS  '|| CHR(10)
   ||'  FROM WPSSTLENTRY'|| CHR(10)
   ||' WHERE COMPANYCODE ='''||P_COMPANYCODE||''' '|| CHR(10)
   ||'    AND   DIVISIONCODE =  '''||P_DIVISIONCODE||''''|| CHR(10)
   ||'    AND   YEARCODE = '''||P_YEARCODE||''''|| CHR(10)
   ||'    AND   STLFROMDATE >= TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'') '|| CHR(10)
   ||'    AND   STLFROMDATE <=TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'|| CHR(10)
   ||' GROUP BY WORKERSERIAL'|| CHR(10)
   ||' UNION ALL'|| CHR(10)
   ||'  SELECT WORKERSERIAL, 0 AS STLDAYS, SUM(LEAVEDAYS) LEAVEDAYS '|| CHR(10)
   ||'  FROM WPSLEAVEAPPLICATION'|| CHR(10)
   ||' WHERE COMPANYCODE ='''||P_COMPANYCODE||''' '|| CHR(10)
   ||'   AND   DIVISIONCODE = '''||P_DIVISIONCODE||''''|| CHR(10)
   ||'   AND   YEARCODE = '''||P_YEARCODE||''''|| CHR(10)
   ||'    AND   LEAVEFROM >= TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'')'|| CHR(10)
   ||'  AND   LEAVETO <= TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'|| CHR(10)
   ||'  AND  LEAVEDAYS > 0'|| CHR(10)
   ||'   AND LEAVESANCTIONEDON IS NOT NULL '|| CHR(10)
   ||'  GROUP BY WORKERSERIAL'|| CHR(10)
   ||'  )'|| CHR(10)
   ||'  GROUP BY WORKERSERIAL'|| CHR(10)
   ||'  )B,'|| CHR(10)
   ||'  ('|| CHR(10)
   ||'  SELECT X.WORKERSERIAL, COUNT(DISTINCT DATEOFATTENDANCE) DAYS, 

MAX(DATEOFATTENDANCE) LASTWORKINGDAY '|| CHR(10)
   ||'  FROM WPSATTENDANCEDAYWISE X'|| CHR(10)
   ||'  WHERE RTRIM(X.COMPANYCODE) ='''||P_COMPANYCODE||''' '|| CHR(10)
   ||'   AND RTRIM(X.DIVISIONCODE) = '''||P_DIVISIONCODE||''''|| CHR(10)
   ||'   AND X.YEARCODE = '''||P_YEARCODE||''''|| CHR(10)
   ||'     AND X.DATEOFATTENDANCE >= TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'') '|| 

CHR(10)
   ||' AND X.DATEOFATTENDANCE <= TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'|| CHR(10)
   ||'   AND 

(NVL(X.ATTENDANCEHOURS,0)+NVL(NIGHTALLOWANCEHOURS,0)+NVL(HOLIDAYHOURS,0)+NVL(LAYOFFHOURS,

0)+NVL(PFADJHOURS,0))  > 0'|| CHR(10)
   ||' GROUP BY WORKERSERIAL '|| CHR(10)
   ||'  ) X '|| CHR(10)
   ||'  WHERE RTRIM(A.COMPANYCODE) = '''||P_COMPANYCODE||''' '|| CHR(10)
   ||'  AND RTRIM(A.DIVISIONCODE) = '''||P_DIVISIONCODE||''''|| CHR(10)
   ||'    AND W.FORTNIGHTSTARTDATE >= TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'') '|| 

CHR(10)
   ||'  AND W.FORTNIGHTENDDATE <= TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'|| CHR(10)
   ||'  AND A.WORKERSERIAL = W.WORKERSERIAL(+)'|| CHR(10)
   ||'  AND A.WORKERSERIAL = X.WORKERSERIAL(+)'|| CHR(10)
   ||'  AND A.WORKERSERIAL = B.WORKERSERIAL(+)'|| CHR(10)
   ||'  AND (A.ESINO <> ''0'' OR NVL(A.ESINO,'''') <> '''' OR A.ESINO <> '''') '|| 

CHR(10)
   ||'  AND A.COMPANYCODE=C.COMPANYCODE '|| CHR(10)
   ||'      AND     A.COMPANYCODE=D.COMPANYCODE '|| CHR(10)
   ||'        AND     A.DIVISIONCODE=D.DIVISIONCODE '|| CHR(10);
      IF P_TOKENNO IS NOT NULL THEN
           LV_SQLSTR := LV_SQLSTR ||' AND W.TOKENNO IN ( '||P_TOKENNO||')  '||CHR(10);
      END IF;
    LV_SQLSTR := LV_SQLSTR ||' GROUP BY A.WORKERSERIAL,W.TOKENNO, A.ESINO, 

A.WORKERNAME,A.BLOCK_DATE,A.DATEOFRETIREMENT, '|| CHR(10)
   ||' X.DAYS, X.LASTWORKINGDAY, B.STLDAYS, B.LEAVEDAYS, C.COMPANYCODE,D.DIVISIONCODE,'|| 

CHR(10)
   ||' C.COMPANYNAME,C.COMPANYADDRESS,C.COMPANYADDRESS1, C.COMPANYADDRESS2,D.DIVISIONNAME 

'|| CHR(10)
  ||' ORDER BY TO_NUMBER(A.ESINO) '|| CHR(10);  
 --DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
 EXECUTE IMMEDIATE LV_SQLSTR;
END;
/


