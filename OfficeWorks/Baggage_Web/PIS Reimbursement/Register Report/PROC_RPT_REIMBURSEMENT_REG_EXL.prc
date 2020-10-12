CREATE OR REPLACE PROCEDURE BAGGAGE_WEB.PROC_RPT_REIMBURSEMENT_REG_EXL
--EXEC PROC_RPT_REIMBURSEMENT_REG_EXL('0001','001','2020-2021','202004','202008','''001''','''02''','','','')
(
    P_COMPANYCODE VARCHAR2,
    P_DIVISIONCODE VARCHAR2,
    P_YEARCODE VARCHAR2,
    P_YEARMONTH_FROM VARCHAR2,
    P_YEARMONTH_TO VARCHAR2,
    P_UNITCODE VARCHAR2 DEFAULT NULL,
    P_CATEGORYCODE VARCHAR2 DEFAULT NULL,
    P_GRADECODE VARCHAR2 DEFAULT NULL,
    P_WORKERSERIAL VARCHAR2  DEFAULT NULL,
    P_COMPONENTS VARCHAR2 DEFAULT NULL 
) 
AS 
    LV_SQLSTR VARCHAR2(32000);    
       
    REPMONTH VARCHAR2(20);
    
    LV_ROWINDEX NUMBER(20);
    LV_EXCELROWTYPE VARCHAR2(50);  
    LV_EXCELROWSTYLE VARCHAR2(2000);  
    LV_EXCELVALUES VARCHAR2(2000);  
    LV_EXCELTAG VARCHAR2(2000);
    
    LV_FLAG VARCHAR2(10);
    
     
    LV_TOPHEADER  VARCHAR2(5000);  
    LV_COLUMNHEADER  VARCHAR2(5000);  
    LV_REPORTHEADER VARCHAR2(5000);  
    LV_COMPANYNAME VARCHAR2(500);  
    LV_DIVISIONNAME VARCHAR2(500);  
    LV_CHR VARCHAR2(10);
    
    LV_YEARMONTH_FROM VARCHAR2(10);
    LV_YEARMONTH_TO VARCHAR2(10);
    
    --LV_LASTC1 GTT_PIS_EPSSTATEMENT_REP%ROWTYPE;
    
    LV_LAST_UNIT VARCHAR2(100);
    LV_LAST_CATEGORY VARCHAR2(100);
    LV_LAST_TOKENNO VARCHAR2(100);
--    LV_SQLSTRNEW           VARCHAR2(9000);

    LV_ERN_COMP VARCHAR2(2000);
    LV_ERN_COMP_SUM VARCHAR2(2000);


    LV_DED_COMP VARCHAR2(2000);
    LV_DED_COMP_SUM VARCHAR2(2000);

    LV_RIM_COMP VARCHAR2(2000);
    LV_RIM_COMP_SUM VARCHAR2(2000);


    LV_ERN_COMP_NAME VARCHAR2(2000);
    LV_DED_COMP_NAME VARCHAR2(2000);
    LV_RIM_COMP_NAME VARCHAR2(2000);


    LV_ERN_COMP_CNT NUMBER(20);
    LV_DED_COMP_CNT NUMBER(20);
    LV_RIM_COMP_CNT NUMBER(20);


    LV_RIM_COMP_PVT VARCHAR2(2000);

BEGIN

--LV_ERN_COMP := NULL;

    LV_YEARMONTH_FROM := TO_CHAR(TO_DATE(P_YEARMONTH_FROM,'MON-YY'),'YYYYMM');
    LV_YEARMONTH_TO := TO_CHAR(TO_DATE(P_YEARMONTH_TO,'MON-YY'),'YYYYMM');
    
    
        SELECT COMPANYNAME, DIVISIONNAME 
        INTO LV_COMPANYNAME, LV_DIVISIONNAME
        FROM COMPANYMAST C, DIVISIONMASTER D
        WHERE D.COMPANYCODE=C.COMPANYCODE
        AND C.COMPANYCODE=P_COMPANYCODE
        AND D.DIVISIONCODE=P_DIVISIONCODE;
        
        
        

-- ASSIGN EARNING COMPONENTCODE
SELECT WM_CONCAT(COMPONENTCODE) , COUNT(COMPONENTCODE) INTO LV_ERN_COMP,LV_ERN_COMP_CNT FROM 
(
    SELECT COMPONENTCODE FROM PISCOMPONENTMASTER
    WHERE COMPANYCODE =P_COMPANYCODE AND DIVISIONCODE =P_DIVISIONCODE
    AND COMPONENTTYPE='EARNING'
    AND COMPONENTCODE <> 'NETSALARY'
    AND COMPONENTCODE NOT LIKE 'SARR%'
    ORDER BY PHASE, CALCULATIONINDEX
);

-- ASSIGN EARNING COMPONENTCODE NAME
SELECT WM_CONCAT(COMPONENTSHORTNAME) INTO LV_ERN_COMP_NAME FROM 
(
    SELECT COMPONENTSHORTNAME FROM PISCOMPONENTMASTER
    WHERE COMPANYCODE =P_COMPANYCODE AND DIVISIONCODE =P_DIVISIONCODE
    AND COMPONENTTYPE='EARNING'
    AND COMPONENTCODE <> 'NETSALARY'
    AND COMPONENTCODE NOT LIKE 'SARR%'
    ORDER BY PHASE, CALCULATIONINDEX
);

-- ASSIGN EARNING COMPONENTCODE SUM
SELECT WM_CONCAT('SUM('||COMPONENTCODE||') '||COMPONENTCODE) INTO LV_ERN_COMP_SUM FROM 
(
    SELECT COMPONENTCODE FROM PISCOMPONENTMASTER
    WHERE COMPANYCODE =P_COMPANYCODE AND DIVISIONCODE =P_DIVISIONCODE
    AND COMPONENTTYPE='EARNING'
    AND COMPONENTCODE <> 'NETSALARY'
   AND COMPONENTCODE NOT LIKE 'SARR%'
    ORDER BY PHASE, CALCULATIONINDEX
);



-- ASSIGN DEDUCTION COMPONENTCODE
SELECT WM_CONCAT(COMPONENTCODE), COUNT(COMPONENTCODE)  INTO LV_DED_COMP,LV_DED_COMP_CNT FROM 
(
    SELECT COMPONENTCODE FROM PISCOMPONENTMASTER
    WHERE COMPANYCODE =P_COMPANYCODE AND DIVISIONCODE =P_DIVISIONCODE
    AND (COMPONENTTYPE='DEDUCTION' OR COMPONENTCODE IN ('TOTLOANAMT','TOTLOANINT'))
    AND (COMPONENTCODE NOT LIKE 'LINT%' AND COMPONENTCODE NOT LIKE 'LOAN%')
    AND COMPONENTCODE NOT LIKE 'SARR%'
    ORDER BY PHASE, CALCULATIONINDEX
);


-- ASSIGN DEDUCTION COMPONENTCODE
SELECT WM_CONCAT(COMPONENTSHORTNAME) INTO LV_DED_COMP_NAME FROM 
(
    SELECT COMPONENTSHORTNAME FROM PISCOMPONENTMASTER
    WHERE COMPANYCODE =P_COMPANYCODE AND DIVISIONCODE =P_DIVISIONCODE
    AND (COMPONENTTYPE='DEDUCTION' OR COMPONENTCODE IN ('TOTLOANAMT','TOTLOANINT'))
    AND (COMPONENTCODE NOT LIKE 'LINT%' AND COMPONENTCODE NOT LIKE 'LOAN%')
    AND COMPONENTCODE NOT LIKE 'SARR%'
    ORDER BY PHASE, CALCULATIONINDEX
);

-- ASSIGN DEDUCTION COMPONENTCODE SUM
SELECT WM_CONCAT('SUM('||COMPONENTCODE||') '||COMPONENTCODE) INTO LV_DED_COMP_SUM FROM 
(
    SELECT COMPONENTCODE FROM PISCOMPONENTMASTER
    WHERE COMPANYCODE =P_COMPANYCODE AND DIVISIONCODE =P_DIVISIONCODE
     AND (COMPONENTTYPE='DEDUCTION' OR COMPONENTCODE IN ('TOTLOANAMT','TOTLOANINT'))
    AND (COMPONENTCODE NOT LIKE 'LINT%' AND COMPONENTCODE NOT LIKE 'LOAN%')
    AND COMPONENTCODE NOT LIKE 'SARR%'
    ORDER BY PHASE, CALCULATIONINDEX
);


-- ASSIGN REIMBURSEMENT COMPONENTCODE
SELECT WM_CONCAT(COMPONENTCODE), COUNT(COMPONENTCODE) INTO LV_RIM_COMP , LV_RIM_COMP_CNT FROM 
(
    SELECT COMPONENTCODE FROM PISCOMPONENTMASTER
    WHERE COMPANYCODE =P_COMPANYCODE AND DIVISIONCODE =P_DIVISIONCODE
     AND ALLOWREIMBURSEMENT='Y'
     AND COMPONENTCODE NOT LIKE 'SARR%'
    ORDER BY PHASE, CALCULATIONINDEX
);

-- ASSIGN REIMBURSEMENT COMPONENTCODE
SELECT WM_CONCAT(COMPONENTSHORTNAME) INTO LV_RIM_COMP_NAME FROM 
(
    SELECT COMPONENTSHORTNAME FROM PISCOMPONENTMASTER
    WHERE COMPANYCODE =P_COMPANYCODE AND DIVISIONCODE =P_DIVISIONCODE
    AND COMPONENTCODE NOT LIKE 'SARR%'
     AND ALLOWREIMBURSEMENT='Y'
    ORDER BY PHASE, CALCULATIONINDEX
);

-- ASSIGN REIMBURSEMENT COMPONENTCODE SUM
SELECT WM_CONCAT('SUM('||COMPONENTCODE||') '||COMPONENTCODE) INTO LV_RIM_COMP_SUM FROM 
(
    SELECT COMPONENTCODE FROM PISCOMPONENTMASTER
    WHERE COMPANYCODE =P_COMPANYCODE AND DIVISIONCODE =P_DIVISIONCODE
     AND ALLOWREIMBURSEMENT='Y'
     AND COMPONENTCODE NOT LIKE 'SARR%'
    ORDER BY PHASE, CALCULATIONINDEX
);

-- ASSIGN REIMBURSEMENT COMPONENTCODE PIVOT
SELECT WM_CONCAT(''''||COMPONENTCODE||''' AS '||COMPONENTCODE) INTO LV_RIM_COMP_PVT  FROM 
(
    SELECT COMPONENTCODE FROM PISCOMPONENTMASTER
    WHERE COMPANYCODE =P_COMPANYCODE AND DIVISIONCODE =P_DIVISIONCODE
    AND ALLOWREIMBURSEMENT='Y'
    AND COMPONENTCODE NOT LIKE 'SARR%'
    ORDER BY PHASE, CALCULATIONINDEX
);



----START TABLE
LV_SQLSTR := LV_SQLSTR || 'CREATE OR REPLACE VIEW VW_REIMBURSEMENT_REG AS'|| CHR(10);
LV_SQLSTR := LV_SQLSTR || 'SELECT TO_CHAR(TO_DATE(A.YEARMONTH,''YYYYMM''),''MON-YYYY'')MON_YYYY, A.YEARMONTH,E.UNITCODE, E.TOKENNO, E.EMPLOYEENAME, E.GRADECODE, E.CATEGORYCODE,'||LV_ERN_COMP||','||LV_RIM_COMP||','||LV_DED_COMP||' FROM ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    SELECT TOKENNO,YEARMONTH,'||LV_ERN_COMP_SUM|| CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    SUM(BASIC) BASIC,SUM(SOFT_ALLW) SOFT_ALLW,SUM(SERV_ALLW) SERV_ALLW,' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    SUM(CONV_ALLW) CONV_ALLW,SUM(CHILD_ALLW) CHILD_ALLW,SUM(PERS_ALLW) PERS_ALLW,' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    SUM(HRA) HRA,SUM(OTH_ALLW) OTH_ALLW,SUM(INCENTIVE) INCENTIVE,SUM(FIX_ALW) FIX_ALW,' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    SUM(OTH_ALLW2) OTH_ALLW2,SUM(OTHER_REIM) OTHER_REIM,SUM(SARR_ARRE) SARR_ARRE,' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    SUM(FSTL_EARN) FSTL_EARN,SUM(NETSALARY) NETSALARY ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    FROM PISPAYTRANSACTION' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    WHERE COMPANYCODE='''||P_COMPANYCODE||'''' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND DIVISIONCODE='''||P_DIVISIONCODE||'''' || CHR(10);

IF P_UNITCODE IS NOT NULL THEN
LV_SQLSTR := LV_SQLSTR || '    AND UNITCODE IN ('||P_UNITCODE||')' || CHR(10);
END IF;

IF P_CATEGORYCODE IS NOT NULL THEN
LV_SQLSTR := LV_SQLSTR || '    AND CATEGORYCODE IN ('||P_CATEGORYCODE||')' || CHR(10);
END IF;
IF P_GRADECODE IS NOT NULL THEN
LV_SQLSTR := LV_SQLSTR || '    AND GRADECODE IN ('||P_GRADECODE||')' || CHR(10);
END IF;

IF P_WORKERSERIAL IS NOT NULL THEN
LV_SQLSTR := LV_SQLSTR || '    AND WORKERSERIAL IN ('||P_WORKERSERIAL||')' || CHR(10);
END IF;



--LV_SQLSTR := LV_SQLSTR || '    AND CATEGORYCODE=''02''' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND TO_NUMBER(YEARMONTH) BETWEEN '||LV_YEARMONTH_FROM||' AND '||LV_YEARMONTH_TO||'' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    GROUP BY TOKENNO,YEARMONTH' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ') A,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    SELECT * FROM ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    (' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '        ( ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '            SELECT TOKENNO, COMPONENTCODE, PAIDAMOUNT, YEARMONTH' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '            FROM PISREIMBURSEMENTDETAILS' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '        )' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '        PIVOT(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '            SUM(PAIDAMOUNT)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '            FOR COMPONENTCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '            IN ( ' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '                ''LTA'' AS LTA, ' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '                ''MEDICAL'' AS MEDICAL,' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '                ''FIX_CONV'' AS FIX_CONV,' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '                ''LOCAL_CONV'' AS LOCAL_CONV' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '                '||LV_RIM_COMP_PVT|| CHR(10);
LV_SQLSTR := LV_SQLSTR || '            )' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '        )' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    )' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ') B,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    SELECT TOKENNO,YEARMONTH,'||LV_DED_COMP_SUM|| CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    SUM(LINT_HBLN) LINT_HBLN,SUM(LINT_PF) LINT_PF,SUM(ESI_E) ESI_E,SUM(PF_E) PF_E,' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    SUM(PTAX) PTAX,SUM(ITAX) ITAX,SUM(LOAN_SADV) LOAN_SADV,SUM(LINT_SADV) LINT_SADV,' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    SUM(CANTEEN) CANTEEN,SUM(LOAN_PRLN) LOAN_PRLN,SUM(LOAN_EDLN) LOAN_EDLN,' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    SUM(LINT_PRLN) LINT_PRLN,SUM(LINT_EDLN) LINT_EDLN,SUM(LOAN_OTLN) LOAN_OTLN,' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    SUM(LINT_OTLN) LINT_OTLN,SUM(LOAN_VCLN) LOAN_VCLN,SUM(LINT_VCLN) LINT_VCLN,' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    SUM(LOAN_MGLN) LOAN_MGLN,SUM(LINT_MGLN) LINT_MGLN,SUM(LOAN_MDLN) LOAN_MDLN,' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    SUM(LINT_MDLN) LINT_MDLN,SUM(LOAN_HBLN) LOAN_HBLN,SUM(LOAN_PF) LOAN_PF,' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    SUM(SAL_SAVING) SAL_SAVING,SUM(SARR_ARRD) SARR_ARRD,SUM(FSTL_DED) FSTL_DED' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    FROM PISPAYTRANSACTION' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    WHERE COMPANYCODE='''||P_COMPANYCODE||'''' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND DIVISIONCODE='''||P_DIVISIONCODE||'''' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    AND CATEGORYCODE=''02''' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND TO_NUMBER(YEARMONTH) BETWEEN '||LV_YEARMONTH_FROM||' AND '||LV_YEARMONTH_TO||'' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    GROUP BY TOKENNO,YEARMONTH' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ') C,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    SELECT * FROM PISEMPLOYEEMASTER' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    WHERE COMPANYCODE='''||P_COMPANYCODE||'''' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND DIVISIONCODE='''||P_DIVISIONCODE||'''' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ') E' || CHR(10);

LV_SQLSTR := LV_SQLSTR || 'WHERE A.TOKENNO=B.TOKENNO(+)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'AND A.TOKENNO=C.TOKENNO(+)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'AND A.YEARMONTH=B.YEARMONTH(+)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'AND A.YEARMONTH=C.YEARMONTH(+)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'AND A.TOKENNO=E.TOKENNO' || CHR(10);


---END TABLE


    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);

    EXECUTE IMMEDIATE LV_SQLSTR ;



DELETE FROM GTT_EXCEL_REPORT WHERE 1=1;

    LV_ROWINDEX := 0;

    LV_EXCELROWSTYLE := NULL;
    
    LV_CHR :=   FN_GET_EXCEL_CELLREF(6+LV_ERN_COMP_CNT+LV_RIM_COMP_CNT+LV_DED_COMP_CNT); -- EXCEL CELL REF

FOR C1 IN 
( 
    SELECT *
    FROM VW_REIMBURSEMENT_REG 
    ORDER BY UNITCODE, CATEGORYCODE, GRADECODE, EMPLOYEENAME, YEARMONTH
)
LOOP

   
    LV_EXCELVALUES := NULL;
    LV_EXCELTAG := NULL;
        
        
    LV_ROWINDEX := LV_ROWINDEX + 1;
    
    IF LV_ROWINDEX = 1 THEN
        
    --START TOP HEADER
        LV_EXCELROWTYPE := 'TOPHEADER';
        
        LV_EXCELVALUES := LV_COMPANYNAME;    
      
        
        LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~BORDER.BOTTOM.STYLE~THIN~HORIZONTALALIGNMENT~LEFT~VERTICALALIGNMENT~CENTER~FONT.BOLD~TRUE~FONT.SIZE~10~FONT.NAME~Tahoma';

        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
        
        LV_ROWINDEX := LV_ROWINDEX + 1;
     


        LV_EXCELROWTYPE := 'REPORTHEADER';
    
        LV_EXCELVALUES := LV_DIVISIONNAME;    
      
        
        LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~BORDER.BOTTOM.STYLE~THIN~HORIZONTALALIGNMENT~LEFT~VERTICALALIGNMENT~CENTER~FONT.BOLD~TRUE~FONT.SIZE~10~FONT.NAME~Tahoma';

        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
        
        LV_ROWINDEX := LV_ROWINDEX + 1;
        
        LV_EXCELROWTYPE := 'REPORTHEADER';
    
        LV_EXCELVALUES := 'COMPONENT REGISTER WITH REIMBURSEMENT PERIOD FROM '||TO_CHAR(TO_DATE(LV_YEARMONTH_FROM,'YYYYMM'),'MON-YYYY')||' TO '||TO_CHAR(TO_DATE(LV_YEARMONTH_TO,'YYYYMM'),'MON-YYYY');    
      
        
        LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~BORDER.BOTTOM.STYLE~THIN~HORIZONTALALIGNMENT~LEFT~VERTICALALIGNMENT~CENTER~FONT.BOLD~TRUE~FONT.SIZE~9~FONT.NAME~Tahoma';

        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
        
        LV_ROWINDEX := LV_ROWINDEX + 1;
        
        
        LV_EXCELROWTYPE := 'COLUMNHEADER';
      
        LV_EXCELROWSTYLE := NULL;

        --FN_GET_EXCEL_CELLREF(6+LV_ERN_COMP_CNT+LV_RIM_COMP_CNT+LV_DED_COMP_CNT)
  
        LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':F'||LV_ROWINDEX
        ||'~MERGE~G'||LV_ROWINDEX||':'|| FN_GET_EXCEL_CELLREF(6+LV_ERN_COMP_CNT)||LV_ROWINDEX
        ||'~MERGE~'||FN_GET_EXCEL_CELLREF(6+LV_ERN_COMP_CNT+1)||LV_ROWINDEX||':'|| FN_GET_EXCEL_CELLREF(6+LV_ERN_COMP_CNT+LV_RIM_COMP_CNT)||LV_ROWINDEX
        ||'~MERGE~'||FN_GET_EXCEL_CELLREF(6+LV_ERN_COMP_CNT+LV_RIM_COMP_CNT+1)||LV_ROWINDEX||':'|| LV_CHR||LV_ROWINDEX
        ||'~RANGE~A'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~BORDER.BOTTOM.STYLE~THIN~HORIZONTALALIGNMENT~CENTERCONTINUOUS~VERTICALALIGNMENT~CENTER~FONT.BOLD~TRUE~FONT.SIZE~9~FONT.NAME~Tahoma';
        
        
        LV_EXCELVALUES := RPAD('^',6,'^')||'EARNING'||RPAD('^',LV_ERN_COMP_CNT,'^')
        ||'REIMBURSEMENT'||RPAD('^',LV_RIM_COMP_CNT,'^')||'DEDUCTION'||RPAD('^',LV_DED_COMP_CNT,'^');
        
        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
         
        LV_ROWINDEX := LV_ROWINDEX + 1;
        
        
        
        
        LV_EXCELROWTYPE := 'COLUMNHEADER';
      
        LV_EXCELROWSTYLE := NULL;
        LV_EXCELVALUES := 'MONTH-YEAR^UNIT^EMP.CODE/TOKEN NO.^EMPLOYEE NAME^GRADE^CATEGORY';
        LV_EXCELVALUES := LV_EXCELVALUES ||'^'||REPLACE(LV_ERN_COMP_NAME,',','^');
        LV_EXCELVALUES := LV_EXCELVALUES ||'^'||REPLACE(LV_RIM_COMP_NAME,',','^');
        LV_EXCELVALUES := LV_EXCELVALUES ||'^'||REPLACE(LV_DED_COMP_NAME,',','^');
        
        LV_EXCELROWSTYLE := 'RANGE~A'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~BORDER.BOTTOM.STYLE~THIN~HORIZONTALALIGNMENT~LEFT~VERTICALALIGNMENT~CENTER~FONT.BOLD~TRUE~FONT.SIZE~9~FONT.NAME~Tahoma';
            
        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
         
        LV_ROWINDEX := LV_ROWINDEX + 1;

        LV_LAST_TOKENNO := C1.TOKENNO;
    END IF;
     
    IF NVL(LV_LAST_TOKENNO,'NA') <> C1.TOKENNO THEN
    
        LV_SQLSTR := 'SELECT ''EMPLOYEE TOTAL^^^^^''';
        LV_SQLSTR := LV_SQLSTR ||'||''^''||SUM('||REPLACE(LV_ERN_COMP,',',')||''~NUMBERFORMAT~##,##,##0.00^''||SUM(');
        LV_SQLSTR := LV_SQLSTR ||')||''^''||SUM('||REPLACE(LV_RIM_COMP,',',')||''~NUMBERFORMAT~##,##,##0.00^''||SUM(');
        LV_SQLSTR := LV_SQLSTR ||')||''^''||SUM('||REPLACE(LV_DED_COMP,',',')||''~NUMBERFORMAT~##,##,##0.00^''||SUM(');
        LV_SQLSTR := LV_SQLSTR ||')||''~NUMBERFORMAT~##,##,##0.00'' FROM VW_REIMBURSEMENT_REG';
        LV_SQLSTR := LV_SQLSTR ||' WHERE TOKENNO='''||LV_LAST_TOKENNO||'''';
    --    LV_SQLSTR := LV_SQLSTR ||' WHERE TOKENNO='''||C1.TOKENNO||'''';
        
        
        DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
        
        EXECUTE IMMEDIATE LV_SQLSTR INTO LV_EXCELVALUES;
    --
        
        LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':F'||LV_ROWINDEX||'~FONT.SIZE~10~HORIZONTALALIGNMENT~CENTERCONTINUOUS~FONT.BOLD~TRUE~RANGE~G'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~FONT.SIZE~10~HORIZONTALALIGNMENT~RIGHT~FONT.BOLD~TRUE~NUMBERFORMAT~##,##,##0.00';
        
        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
        
        LV_ROWINDEX := LV_ROWINDEX + 1;
        
    END IF;
    
    LV_EXCELROWTYPE := 'COLUMNVALUE';
   
    LV_SQLSTR := 'SELECT MON_YYYY||''^''||UNITCODE||''^''||TOKENNO||''^''||EMPLOYEENAME||''^''||GRADECODE||''^''||CATEGORYCODE';
    LV_SQLSTR := LV_SQLSTR ||'||''^''||'||REPLACE(LV_ERN_COMP,',','||''~NUMBERFORMAT~##,##,##0.00^''||');
    LV_SQLSTR := LV_SQLSTR ||'||''^''||'||REPLACE(LV_RIM_COMP,',','||''~NUMBERFORMAT~##,##,##0.00^''||');
    LV_SQLSTR := LV_SQLSTR ||'||''^''||'||REPLACE(LV_DED_COMP,',','||''~NUMBERFORMAT~##,##,##0.00^''||');
    LV_SQLSTR := LV_SQLSTR ||' FROM VW_REIMBURSEMENT_REG';
    LV_SQLSTR := LV_SQLSTR ||' WHERE TOKENNO='''||C1.TOKENNO||'''';
    LV_SQLSTR := LV_SQLSTR ||' AND YEARMONTH='''||C1.YEARMONTH||'''';
    
    
    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
    
    EXECUTE IMMEDIATE LV_SQLSTR INTO LV_EXCELVALUES;

    
    LV_EXCELROWSTYLE := 'RANGE~G'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~FONT.SIZE~10~HORIZONTALALIGNMENT~RIGHT~NUMBERFORMAT~##,##,##0.00';
    
    PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
     
     LV_LAST_TOKENNO := C1.TOKENNO;
END LOOP;
 

    IF NVL(LV_LAST_TOKENNO,'NA') <> 'NA' THEN
    
        LV_ROWINDEX := LV_ROWINDEX + 1;
        
        LV_SQLSTR := 'SELECT ''EMPLOYEE TOTAL^^^^^''';
        LV_SQLSTR := LV_SQLSTR ||'||''^''||SUM('||REPLACE(LV_ERN_COMP,',',')||''~NUMBERFORMAT~##,##,##0.00^''||SUM(');
        LV_SQLSTR := LV_SQLSTR ||')||''^''||SUM('||REPLACE(LV_RIM_COMP,',',')||''~NUMBERFORMAT~##,##,##0.00^''||SUM(');
        LV_SQLSTR := LV_SQLSTR ||')||''^''||SUM('||REPLACE(LV_DED_COMP,',',')||''~NUMBERFORMAT~##,##,##0.00^''||SUM(');
        LV_SQLSTR := LV_SQLSTR ||')||''~NUMBERFORMAT~##,##,##0.00'' FROM VW_REIMBURSEMENT_REG';
        LV_SQLSTR := LV_SQLSTR ||' WHERE TOKENNO='''||LV_LAST_TOKENNO||'''';
    --    LV_SQLSTR := LV_SQLSTR ||' WHERE TOKENNO='''||C1.TOKENNO||'''';
        
        
        DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
        
        EXECUTE IMMEDIATE LV_SQLSTR INTO LV_EXCELVALUES;
    --
        
        LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':F'||LV_ROWINDEX||'~FONT.SIZE~10~HORIZONTALALIGNMENT~CENTERCONTINUOUS~FONT.BOLD~TRUE~RANGE~G'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~FONT.SIZE~10~HORIZONTALALIGNMENT~RIGHT~FONT.BOLD~TRUE~NUMBERFORMAT~##,##,##0.00';
        
        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
        
    END IF;
    

     LV_ROWINDEX := LV_ROWINDEX + 1;
     
    LV_EXCELROWTYPE := 'COLUMNVALUE';
   
    LV_SQLSTR := 'SELECT ''GRAND TOTAL^^^^^''';
    LV_SQLSTR := LV_SQLSTR ||'||''^''||SUM('||REPLACE(LV_ERN_COMP,',',')||''~NUMBERFORMAT~##,##,##0.00^''||SUM(');
    LV_SQLSTR := LV_SQLSTR ||')||''^''||SUM('||REPLACE(LV_RIM_COMP,',',')||''~NUMBERFORMAT~##,##,##0.00^''||SUM(');
    LV_SQLSTR := LV_SQLSTR ||')||''^''||SUM('||REPLACE(LV_DED_COMP,',',')||''~NUMBERFORMAT~##,##,##0.00^''||SUM(');
    LV_SQLSTR := LV_SQLSTR ||')||''~NUMBERFORMAT~##,##,##0.00'' FROM VW_REIMBURSEMENT_REG';
--    LV_SQLSTR := LV_SQLSTR ||' WHERE TOKENNO='''||C1.TOKENNO||'''';
    
    
    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
    
    EXECUTE IMMEDIATE LV_SQLSTR INTO LV_EXCELVALUES;
--
    
    LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':F'||LV_ROWINDEX||'~FONT.SIZE~10~HORIZONTALALIGNMENT~CENTERCONTINUOUS~FONT.BOLD~TRUE~RANGE~G'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~FONT.SIZE~10~HORIZONTALALIGNMENT~RIGHT~FONT.BOLD~TRUE~NUMBERFORMAT~##,##,##0.00';
    
    PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
    
    
END;
/