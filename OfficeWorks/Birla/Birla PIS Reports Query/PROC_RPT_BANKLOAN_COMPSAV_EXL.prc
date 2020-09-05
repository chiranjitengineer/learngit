CREATE OR REPLACE PROCEDURE BIRLANEW.PROC_RPT_BANKLOAN_COMPSAV_EXL
(
    P_COMPANYCODE VARCHAR2,
    P_DIVISIONCODE VARCHAR2,
    P_YEARCODE VARCHAR2,
    P_YEARMONTH VARCHAR2,
    P_UNIT VARCHAR2 DEFAULT NULL,
    P_CATEGORY VARCHAR2 DEFAULT NULL
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
    
    LV_LASTC1 GTT_PIS_BANKLOAN_COMPSAV_REP%ROWTYPE;
    
    LV_LAST_UNIT VARCHAR2(100);
    LV_LAST_CATEGORY VARCHAR2(100);
--    LV_SQLSTRNEW           VARCHAR2(9000);

BEGIN

LV_LAST_UNIT := NULL;
LV_LAST_CATEGORY := NULL;
--EXEC PROC_RPT_BANKLOAN_COMPSAV_EXL('BJ0056','0001','2020-2021','202004','','')


      --THIS LINE FOR GPS_ERROR_LOG
    LV_SQLSTR := 'PROC_RPT_BANKLOAN_COMPSAV_EXL('''||P_COMPANYCODE||''','''||P_DIVISIONCODE||''','''||P_YEARCODE||''','''||P_YEARMONTH||''')';
     
--     DELETE FROM PIS_ERROR_LOG
--     WHERE PROC_NAME='PROC_RPT_ITAXCOMPUTATION_EXL';
--     
--     insert into PIS_ERROR_LOG
--     (
--        COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS
--     )
--     values
--     (
--        P_COMPANYCODE, P_DIVISIONCODE, LV_SQLSTR, TO_DATE(P_FROMDATE,'DD/MM/YYYY'), TO_DATE(P_TODATE,'DD/MM/YYYY'),NULL , LV_SQLSTR, 'PROC_INSERT_PFFORM5', 'SCRIPT ADDED'
--     );
     
     LV_SQLSTR := NULL;
    -- EXEC PROC_RPT_ITAXCOMPUTATION_EXL('0001','0002','2019-2020','00378')
  

    SELECT COMPANYNAME, DIVISIONNAME 
    INTO LV_COMPANYNAME, LV_DIVISIONNAME
    FROM COMPANYMAST C, DIVISIONMASTER D
    WHERE D.COMPANYCODE=C.COMPANYCODE
    AND C.COMPANYCODE=P_COMPANYCODE
    AND D.DIVISIONCODE=P_DIVISIONCODE;
    
            
    DELETE FROM GTT_PIS_BANKLOAN_COMPSAV_REP WHERE 1=1;
    
    LV_SQLSTR := NULL;
    LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_PIS_BANKLOAN_COMPSAV_REP' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    COMPANYCODE, DIVISIONCODE, UNITCODE, UNITSHORTDESC, CATEGORYCODE, CATEGORYDESC, ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    DEPARTMENTCODE, DEPARTMENTDESC, TOKENNO, EMPLOYEENAME, LOANDATE, LOAN_BL, LINT_BL, ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    LNBL_BL, LOANAMOUNT, COMPSAVING, COMPSAVING_OP, COMPSAVING_YTD' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'SELECT A.COMPANYCODE, A.DIVISIONCODE, A.UNITCODE,B.UNITSHORTDESC, A.CATEGORYCODE, C.CATEGORYDESC, ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'A.DEPARTMENTCODE, D.DEPARTMENTDESC,A.TOKENNO, E.EMPLOYEENAME, F.LOANDATE, A.LOAN_BL,A.LINT_BL,A.LNBL_BL, F.LOANAMOUNT,' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'A.COMPSAVING,NVL(COMPSAVING_OP,0) COMPSAVING_OP, NVL(G.COMPSAVING_YTD,0) COMPSAVING_YTD' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'FROM ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SELECT COMPANYCODE, DIVISIONCODE, UNITCODE, CATEGORYCODE, DEPARTMENTCODE, TOKENNO,' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    LOAN_BL,LINT_BL,LNBL_BL, COMPSAVING' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    FROM PISPAYTRANSACTION' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    WHERE COMPANYCODE='''||P_COMPANYCODE||'''' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND DIVISIONCODE='''||P_DIVISIONCODE||'''' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND YEARCODE='''||P_YEARCODE||'''' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND YEARMONTH='''||P_YEARMONTH||'''' || CHR(10);


    IF P_UNIT IS NOT NULL THEN
    LV_SQLSTR := LV_SQLSTR || '    AND UNITCODE IN ('||P_UNIT||')' || CHR(10);
    END IF;

    IF P_CATEGORY IS NOT NULL THEN
    LV_SQLSTR := LV_SQLSTR || '    AND CATEGORYCODE IN ('||P_CATEGORY||')' || CHR(10);
    END IF;
    
        
    LV_SQLSTR := LV_SQLSTR || ') A, PISUNITMASTER B, PISCATEGORYMASTER C, PISDEPARTMENTMASTER D, PISEMPLOYEEMASTER E,' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, LOANCODE, LOANDATE, AMOUNT LOANAMOUNT ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    FROM LOANTRANSACTION A' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    WHERE LOANDATE = ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    (' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '        SELECT MAX(LOANDATE) FROM LOANTRANSACTION' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '        WHERE COMPANYCODE=A.COMPANYCODE' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '        AND DIVISIONCODE=A.DIVISIONCODE ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '        AND TOKENNO=A.TOKENNO' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '        AND LOANCODE=''BL''' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    )' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND LOANCODE=''BL''' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || ') F,' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SELECT COMPANYCODE, DIVISIONCODE, TOKENNO, WORKERSERIAL, SUM(COMPSAVING) COMPSAVING_YTD ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    FROM PISPAYTRANSACTION' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    WHERE YEARCODE='''||P_YEARCODE||'''' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    GROUP BY COMPANYCODE, DIVISIONCODE, TOKENNO, WORKERSERIAL' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || ') G,' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SELECT COMPANYCODE, DIVISIONCODE, TOKENNO, WORKERSERIAL, SUM(COMPSAVING) COMPSAVING_OP ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    FROM PISPAYTRANSACTION' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    WHERE TO_NUMBER(YEARMONTH) < TO_NUMBER('''||P_YEARMONTH||''')' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    GROUP BY COMPANYCODE, DIVISIONCODE, TOKENNO, WORKERSERIAL' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || ') H' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'WHERE A.COMPANYCODE=B.COMPANYCODE' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.DIVISIONCODE=B.DIVISIONCODE' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.UNITCODE=B.UNITCODE' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.COMPANYCODE=C.COMPANYCODE' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.DIVISIONCODE=C.DIVISIONCODE' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.CATEGORYCODE=C.CATEGORYCODE' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.COMPANYCODE=D.COMPANYCODE' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.DIVISIONCODE=D.DIVISIONCODE' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.DEPARTMENTCODE=D.DEPARTMENTCODE' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.COMPANYCODE=E.COMPANYCODE' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.DIVISIONCODE=E.DIVISIONCODE' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.TOKENNO=E.TOKENNO' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.COMPANYCODE=F.COMPANYCODE' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.DIVISIONCODE=F.DIVISIONCODE' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.TOKENNO=F.TOKENNO' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.COMPANYCODE=G.COMPANYCODE(+)' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.DIVISIONCODE=G.DIVISIONCODE(+)' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.TOKENNO=G.TOKENNO(+)' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.COMPANYCODE=H.COMPANYCODE(+)' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.DIVISIONCODE=H.DIVISIONCODE(+)' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.TOKENNO=H.TOKENNO(+)' || CHR(10);

    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);

    EXECUTE IMMEDIATE LV_SQLSTR ;




---START EXCEL REPORT GTT_EXCEL_REPORT

DELETE FROM GTT_EXCEL_REPORT WHERE 1=1;

    LV_ROWINDEX := 0;

    LV_EXCELROWSTYLE := NULL;
    
    LV_CHR := 'N';

FOR C1 IN 
( 
    SELECT COMPANYCODE, DIVISIONCODE, UNITCODE, UNITSHORTDESC, CATEGORYCODE, CATEGORYDESC, 
    DEPARTMENTCODE, DEPARTMENTDESC, TOKENNO, EMPLOYEENAME, LOANDATE, LOAN_BL, LINT_BL, 
    LNBL_BL, LOANAMOUNT, COMPSAVING, COMPSAVING_OP, COMPSAVING_YTD 
    FROM GTT_PIS_BANKLOAN_COMPSAV_REP 
    ORDER BY UNITCODE, CATEGORYCODE, DEPARTMENTCODE, TOKENNO
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
    
        LV_EXCELVALUES := 'STAFF/SUB_STAFF CREDIT SOCITY STATEMENT FOR THE MONTH OF '||TO_CHAR(TO_DATE(P_YEARMONTH,'YYYYMM'),'MON-YYYY');    
      
        
        LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~BORDER.BOTTOM.STYLE~THIN~HORIZONTALALIGNMENT~LEFT~VERTICALALIGNMENT~CENTER~FONT.BOLD~TRUE~FONT.SIZE~9~FONT.NAME~Tahoma';

        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
        
        LV_ROWINDEX := LV_ROWINDEX + 1;
        
   

    --END TOP HEADER
    
    
    --START COLUMN HEADER
    
    
--        LV_EXCELROWTYPE := 'COLUMNHEADER';
--        
--        
--
--        LV_EXCELVALUES := '^^^^^^^^^^^^^';
--        
--        LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':N'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~CENTERCONTINUOUS';
--
--        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
--
--        LV_ROWINDEX := LV_ROWINDEX + 1;
--
--
--
--
--
--        LV_EXCELVALUES := C1.UNITSHORTDESC||'^^^^STAFF/SUB_STAFF CREDIT SOCITY STATEMENT^^^^^^^MONTH:^'||TO_CHAR(TO_DATE(P_YEARMONTH,'YYYYMM'),'MON-YYYY')||'^';
--        
--        LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':D'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~CENTERCONTINUOUS~MERGE~E'||LV_ROWINDEX||':K'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~CENTERCONTINUOUS~MERGE~M'||LV_ROWINDEX||':N'||LV_ROWINDEX||'~';
--
--        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
--
--        LV_ROWINDEX := LV_ROWINDEX + 1;
--
--
--
--        LV_EXCELVALUES := '^^^^^^^^^^^^^';
--        
--        LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':N'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~CENTERCONTINUOUS';
--
--        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
--
--        LV_ROWINDEX := LV_ROWINDEX + 1;
--
--        
--
--        LV_EXCELVALUES := '^^^^^L.T.LOAN^^^^^^COMPULSORY SAVING^^';
--        
--        LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':E'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~CENTERCONTINUOUS~MERGE~F'||LV_ROWINDEX||':J'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~CENTERCONTINUOUS~MERGE~L'||LV_ROWINDEX||':N'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~CENTERCONTINUOUS';
--
--        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
--
--        LV_ROWINDEX := LV_ROWINDEX + 1;
--   
--
--
--        LV_EXCELVALUES := '^DEPERTMENT^EMP CODE^NAME^^LOAN DT.^P.DEDN^I.DEDN^P.BAL^ORG.^^OP.BAL^DEDN^YTD.DED';
--        
--        LV_EXCELROWSTYLE := 'RANGE~A'||LV_ROWINDEX||':N'||LV_ROWINDEX||'~BORDER.BOTTOM.STYLE~THIN~HORIZONTALALIGNMENT~CENTERCONTINUOUS~VERTICALALIGNMENT~CENTER~FONT.SIZE~10';
--
--        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
--
--        LV_ROWINDEX := LV_ROWINDEX + 1;
--   
        
    END IF;
    
    IF NVL(LV_LAST_UNIT,'NA') <> C1.UNITCODE THEN
     
        IF LV_LAST_UNIT IS NOT NULL THEN
            LV_EXCELROWTYPE := 'COLUMNVALUE';
            FOR C2 IN 
            ( 
                SELECT SUM(LOAN_BL) LOAN_BL, SUM(LINT_BL) LINT_BL, SUM(LNBL_BL) LNBL_BL , SUM(LOANAMOUNT) LOANAMOUNT 
                 , SUM(COMPSAVING_OP) COMPSAVING_OP  , SUM(COMPSAVING) COMPSAVING  , SUM(COMPSAVING_YTD) COMPSAVING_YTD 
                FROM GTT_PIS_BANKLOAN_COMPSAV_REP
                WHERE UNITCODE= LV_LAST_UNIT
                AND CATEGORYCODE=LV_LAST_CATEGORY
            )
            LOOP

                LV_EXCELVALUES :=  'TOTAL^^^^^^'||C2.LOAN_BL||'^'||C2.LINT_BL||'^'||C2.LNBL_BL||'^'||
                C2.LOANAMOUNT||'^^'||C2.COMPSAVING_OP||'^'||C2.COMPSAVING||'^'||C2.COMPSAVING_YTD;

                LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':E'||LV_ROWINDEX||'~FONT.SIZE~10~FONT.BOLD~TRUE~RANGE~F'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~FONT.SIZE~10~FONT.BOLD~TRUE~HORIZONTALALIGNMENT~RIGHT~NUMBERFORMAT~##,##,##0.00';

                PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
                LV_ROWINDEX := LV_ROWINDEX + 1;
                 

                LV_LAST_CATEGORY := NULL;


            END LOOP;
            

        END IF;
    
    
    
        LV_EXCELROWTYPE := 'COLUMNHEADER';
        
        LV_EXCELVALUES := '^^^^^^^^^^^^^';
        
        LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':N'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~CENTERCONTINUOUS';

        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

        LV_ROWINDEX := LV_ROWINDEX + 1;


        LV_EXCELVALUES := C1.UNITSHORTDESC||'^^^^STAFF/SUB_STAFF CREDIT SOCITY STATEMENT^^^^^^^MONTH:^'||TO_CHAR(TO_DATE(P_YEARMONTH,'YYYYMM'),'MON-YYYY')||'^';
        
        LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':D'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~CENTERCONTINUOUS~MERGE~E'||LV_ROWINDEX||':K'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~CENTERCONTINUOUS~MERGE~M'||LV_ROWINDEX||':N'||LV_ROWINDEX||'~';

        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

        LV_ROWINDEX := LV_ROWINDEX + 1;



        LV_EXCELVALUES := '^^^^^^^^^^^^^';
        
        LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':N'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~CENTERCONTINUOUS';

        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

        LV_ROWINDEX := LV_ROWINDEX + 1;

        

        LV_EXCELVALUES := '^^^^^L.T.LOAN^^^^^^COMPULSORY SAVING^^';
        
        LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':E'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~CENTERCONTINUOUS~MERGE~F'||LV_ROWINDEX||':J'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~CENTERCONTINUOUS~MERGE~L'||LV_ROWINDEX||':N'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~CENTERCONTINUOUS';

        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

        LV_ROWINDEX := LV_ROWINDEX + 1;
   


        LV_EXCELVALUES := '^DEPERTMENT^EMP CODE^NAME^^LOAN DT.^P.DEDN^I.DEDN^P.BAL^ORG.^^OP.BAL^DEDN^YTD.DED';
        
        LV_EXCELROWSTYLE := 'RANGE~A'||LV_ROWINDEX||':N'||LV_ROWINDEX||'~BORDER.BOTTOM.STYLE~THIN~HORIZONTALALIGNMENT~CENTERCONTINUOUS~VERTICALALIGNMENT~CENTER~FONT.SIZE~10';

        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

        LV_ROWINDEX := LV_ROWINDEX + 1;
        
    END IF;
    
    IF LV_LAST_CATEGORY IS NOT NULL AND NVL(LV_LAST_CATEGORY,'NA') <> C1.CATEGORYCODE THEN
    
        LV_EXCELROWTYPE := 'COLUMNVALUE';
        FOR C2 IN 
        ( 
            SELECT SUM(LOAN_BL) LOAN_BL, SUM(LINT_BL) LINT_BL, SUM(LNBL_BL) LNBL_BL , SUM(LOANAMOUNT) LOANAMOUNT 
             , SUM(COMPSAVING_OP) COMPSAVING_OP  , SUM(COMPSAVING) COMPSAVING  , SUM(COMPSAVING_YTD) COMPSAVING_YTD 
            FROM GTT_PIS_BANKLOAN_COMPSAV_REP
            WHERE UNITCODE= LV_LAST_UNIT
            AND CATEGORYCODE=LV_LAST_CATEGORY
        )
        LOOP

            LV_EXCELVALUES :=  'TOTAL^^^^^^'||C2.LOAN_BL||'^'||C2.LINT_BL||'^'||C2.LNBL_BL||'^'||
            C2.LOANAMOUNT||'^^'||C2.COMPSAVING_OP||'^'||C2.COMPSAVING||'^'||C2.COMPSAVING_YTD;

            LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':E'||LV_ROWINDEX||'~FONT.SIZE~10~FONT.BOLD~TRUE~RANGE~F'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~FONT.SIZE~10~FONT.BOLD~TRUE~HORIZONTALALIGNMENT~RIGHT~NUMBERFORMAT~##,##,##0.00';

            PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
            LV_ROWINDEX := LV_ROWINDEX + 1;
             

            LV_EXCELVALUES := '^^^^^^^^^^^^^';
            
            LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':N'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~CENTERCONTINUOUS';

            PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

            LV_ROWINDEX := LV_ROWINDEX + 1;


        END LOOP;


    END IF;
    
    LV_EXCELROWTYPE := 'COLUMNVALUE';
  

    LV_EXCELVALUES :=  CASE WHEN NVL(LV_LAST_CATEGORY,'NA') = C1.CATEGORYCODE THEN NULL ELSE C1.CATEGORYDESC END||'^'||C1.DEPARTMENTDESC||'^'||C1.TOKENNO||'^'||C1.EMPLOYEENAME||'^^'||
    TO_CHAR(C1.LOANDATE,'DD/MM/YYYY')||'^'||C1.LOAN_BL||'^'||C1.LINT_BL||'^'||C1.LNBL_BL||'^'||
    C1.LOANAMOUNT||'^^'||C1.COMPSAVING_OP||'^'||C1.COMPSAVING||'^'||C1.COMPSAVING_YTD;

    LV_EXCELROWSTYLE := 'RANGE~F'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~FONT.SIZE~10~HORIZONTALALIGNMENT~RIGHT~NUMBERFORMAT~##,##,##0.00';
    
    PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
    
    LV_LASTC1 :=C1;
    LV_LAST_UNIT := C1.UNITCODE;
    LV_LAST_CATEGORY := C1.CATEGORYCODE;
END LOOP;

    LV_ROWINDEX := LV_ROWINDEX + 1;
    
IF LV_LAST_UNIT IS NOT NULL THEN
    LV_EXCELROWTYPE := 'COLUMNVALUE';
    FOR C2 IN 
    ( 
        SELECT SUM(LOAN_BL) LOAN_BL, SUM(LINT_BL) LINT_BL, SUM(LNBL_BL) LNBL_BL , SUM(LOANAMOUNT) LOANAMOUNT 
         , SUM(COMPSAVING_OP) COMPSAVING_OP  , SUM(COMPSAVING) COMPSAVING  , SUM(COMPSAVING_YTD) COMPSAVING_YTD 
        FROM GTT_PIS_BANKLOAN_COMPSAV_REP
        WHERE UNITCODE= LV_LAST_UNIT
        AND CATEGORYCODE=LV_LAST_CATEGORY
    )
    LOOP

        LV_EXCELVALUES :=  'TOTAL^^^^^^'||C2.LOAN_BL||'^'||C2.LINT_BL||'^'||C2.LNBL_BL||'^'||
        C2.LOANAMOUNT||'^^'||C2.COMPSAVING_OP||'^'||C2.COMPSAVING||'^'||C2.COMPSAVING_YTD;

        LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':E'||LV_ROWINDEX||'~FONT.SIZE~10~FONT.BOLD~TRUE~RANGE~F'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~FONT.SIZE~10~FONT.BOLD~TRUE~HORIZONTALALIGNMENT~RIGHT~NUMBERFORMAT~##,##,##0.00';

        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
        LV_ROWINDEX := LV_ROWINDEX + 1;
         

        LV_LAST_CATEGORY := NULL;


    END LOOP;
END IF;
--
--    LV_ROWINDEX := LV_ROWINDEX + 1;
--    LV_EXCELROWTYPE := 'COLUMNVALUE';
--  
--    LV_EXCELVALUES := 'RUN DATE '|| TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS')||'^^^^^';
--
--    LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':F'||LV_ROWINDEX||'~FONT.BOLD~TRUE~FONT.SIZE~10';
--    
--    PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);


END;
/
