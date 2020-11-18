CREATE OR REPLACE PROCEDURE BIRLANEW.PROC_RPT_PF_LOANDEDN_TEXT
(
    P_COMPANYCODE VARCHAR2,
    P_DIVISIONCODE VARCHAR2,
    P_YEARCODE VARCHAR2,
    P_YEARMONTH VARCHAR2,
    P_UNIT VARCHAR2 DEFAULT NULL,
    P_CATEGORY VARCHAR2 DEFAULT NULL
)
AS 
    LV_SQLSTR           VARCHAR2(32000);  
    LV_INSERTSTR VARCHAR2(4000);


    LV_DATEFM1 VARCHAR2(4000);
    LV_DATEFM2 VARCHAR2(4000);

    P_INT1  NUMBER(20);
    P_BLOCKS  NUMBER(10);
    
    LV_LASTUNIT VARCHAR2(100);
    LV_LASTCATEGORY VARCHAR2(100);
    
    g_pBoldOn VARCHAR2(20);
    g_tBoldOn VARCHAR2(20);
    g_pBoldOff VARCHAR2(20);
    g_tBoldOff VARCHAR2(20);
    g_CompOn VARCHAR2(20);
    g_CompOff VARCHAR2(20);
    g_Pg72Lines VARCHAR2(20);
    g_Pg66Lines VARCHAR2(20);
    g_Pg36Lines VARCHAR2(20);
    g_NewPage VARCHAR2(20);
    g_Normal VARCHAR2(20);
    g_Enlarge VARCHAR2(20);
    g_Condence VARCHAR2(20);
    g_CompSmall VARCHAR2(20);
    g_NormalSmall  VARCHAR2(20);
   
BEGIN


   g_pBoldOn := Chr(27)|| 'E';
   g_tBoldOn := Chr(27) || Chr(14);
   g_pBoldOff := Chr(27) || 'F';
   g_tBoldOff := Chr(27) || Chr(18);
   g_CompOn := Chr(27) || Chr(15);
   g_CompOff := Chr(27) || Chr(18);
   g_Pg72Lines := Chr(27) || 'C' || Chr(72);
   g_Pg66Lines := Chr(27) || 'C' || Chr(66);
   g_Pg36Lines := Chr(27) || 'C' || Chr(36);
   g_NewPage := Chr(12);
   g_Normal := Chr(18);
   g_Enlarge := Chr(14);
   g_Condence := Chr(15);
   g_CompSmall := Chr(27) || Chr(77) || Chr(15);
   g_NormalSmall := Chr(27) || Chr(77);




--EXEC PROC_RPT_PF_LOANDEDN_TEXT('DY0086','Y03','15/03/2020','28/03/2020','','','','')

    DELETE FROM GTT_PIS_PF_LOANDEDN_REP WHERE 1=1;
    
    LV_SQLSTR := NULL;
    LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_PIS_PF_LOANDEDN_REP' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    COMPANYCODE, DIVISIONCODE, UNITCODE, UNITSHORTDESC, CATEGORYCODE, CATEGORYDESC, ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    DEPARTMENTCODE,DEPARTMENTDESC, TOKENNO, PFNO, EMPLOYEENAME,PF_GROSS, PF_E, VPF, PF_C, FPF, LOAN_PFL, ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    LINT_PFL, LNBL_PFL, LOANDATE, LOANAMOUNT, PF_E_YTD, VPF_YTD, PF_C_YTD, FPF_YTD' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'SELECT A.COMPANYCODE, A.DIVISIONCODE, A.UNITCODE,B.UNITSHORTDESC, A.CATEGORYCODE, C.CATEGORYDESC, ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'A.DEPARTMENTCODE, D.DEPARTMENTDESC,A.TOKENNO,E.PFNO, E.EMPLOYEENAME,NVL(A.PF_GROSS,0), NVL(A.PF_E,0),NVL(A.VPF,0),NVL(A.PF_C,0),NVL(A.FPF,0), NVL(A.LOAN_PFL,0), ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'NVL(A.LINT_PFL,0), NVL(A.LNBL_PFL,0), F.LOANDATE, NVL(F.LOANAMOUNT,0), NVL(G.PF_E_YTD,0) , NVL(G.VPF_YTD,0)  , NVL(G.PF_C_YTD,0) , NVL(G.FPF_YTD,0) ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'FROM ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SELECT COMPANYCODE, DIVISIONCODE, UNITCODE, CATEGORYCODE, DEPARTMENTCODE, TOKENNO,' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    PF_E,VPF,PF_C,FPF, LOAN_PFL, LINT_PFL, LNBL_PFL,PF_GROSS' || CHR(10);
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
    LV_SQLSTR := LV_SQLSTR || '    SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, LOANCODE, LOANDATE, ACTUALLOANAMOUNT LOANAMOUNT ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    FROM PFLOANTRANSACTION A' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    WHERE LOANDATE = ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    (' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '        SELECT MAX(LOANDATE) FROM PFLOANTRANSACTION' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '        WHERE COMPANYCODE=A.COMPANYCODE' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '        AND DIVISIONCODE=A.DIVISIONCODE ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '        AND TOKENNO=A.TOKENNO' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '        AND LOANCODE=A.LOANCODE' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    )' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND LOANCODE=''PFL''' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || ') F,' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SELECT COMPANYCODE, DIVISIONCODE, TOKENNO, WORKERSERIAL, SUM(PF_E) PF_E_YTD , SUM(VPF) VPF_YTD  , SUM(PF_C) PF_C_YTD , SUM(FPF) FPF_YTD ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    FROM PISPAYTRANSACTION' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    WHERE YEARCODE='''||P_YEARCODE||'''' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    GROUP BY COMPANYCODE, DIVISIONCODE, TOKENNO, WORKERSERIAL' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || ') G' || CHR(10);
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
    LV_SQLSTR := LV_SQLSTR || 'AND A.COMPANYCODE=F.COMPANYCODE(+)' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.DIVISIONCODE=F.DIVISIONCODE(+)' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.TOKENNO=F.TOKENNO(+)' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.COMPANYCODE=G.COMPANYCODE(+)' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.DIVISIONCODE=G.DIVISIONCODE(+)' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.TOKENNO=G.TOKENNO(+)' || CHR(10);

    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
    EXECUTE IMMEDIATE LV_SQLSTR ;
    

----------------------------------------------------------
----  start text report ---

    P_INT1  := 0;
    
    DELETE FROM GTT_TEXT_REPORT WHERE 1=1;
--    commit;
    
   
    P_INT1 := 0;
    P_BLOCKS := 0;
    
--    PROC_INSERT_TEXT_REPORT(g_CompSmall);
    FOR C1 IN 
    ( 
--        SELECT * FROM GTT_PAYSLIP_ASIANTEA WHERE rownum < 3
        SELECT * FROM (
            SELECT ROW_NUMBER() OVER (PARTITION BY UNITCODE, CATEGORYCODE ORDER BY UNITCODE, CATEGORYCODE) SLNO,  COMPANYCODE, DIVISIONCODE, UNITCODE, UNITSHORTDESC, CATEGORYCODE, CATEGORYDESC, DEPARTMENTCODE, 
            DEPARTMENTDESC, TOKENNO, PFNO, EMPLOYEENAME, PF_GROSS, PF_E, VPF, PF_C, FPF, LOAN_PFL, LINT_PFL, LNBL_PFL, LOANDATE, LOANAMOUNT, PF_E_YTD, VPF_YTD, PF_C_YTD, FPF_YTD
            FROM GTT_PIS_PF_LOANDEDN_REP 
            ORDER BY UNITCODE, CATEGORYCODE, DEPARTMENTCODE, TOKENNO
        )
--        WHERE rownum < 11
    )
    LOOP 
    
        
        IF P_BLOCKS >= 50 THEN
        
            LV_INSERTSTR := g_CompOn||g_Condence||'|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|';
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
          
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(g_NewPage);
            P_BLOCKS := 0;
        END IF;
        
        P_BLOCKS := P_BLOCKS+1;

          
        IF P_BLOCKS = 1 THEN     


            LV_INSERTSTR := g_CompOn||g_Condence||FMTALIGN(C1.UNITSHORTDESC,30,'C')||' '|| FMTALIGN('STAFF(BIRLA INDUSTRIES) P.F. & LOAN DEDN. STATEMENT ',100,'C')||
            FMTALIGN('MONTH - '||TO_CHAR(TO_DATE(P_YEARMONTH,'YYYYMM'),'MON-YYYY'),50,'C') ;
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
            
            
            LV_INSERTSTR := '|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|';
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);

            LV_INSERTSTR := '                                                              GROSS         M.CONTR            YTD            EMPLOYER                                                   INTEREST |';
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);

            LV_INSERTSTR := ' SLN  DEP             EMPLN   PF.NO   NAME                   AMOUNT      PF       VPF      PF      VPF      CONTR    YTD      LOAN.DT     ORG.LN         PBAL     PDED   BAL DEDN.|';
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);

            LV_INSERTSTR := '|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|';
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
            LV_INSERTSTR := '  UNIT - ['||C1.UNITCODE||'] '||C1.UNITSHORTDESC||'        CATEGORY - ['||C1.CATEGORYCODE||'] '||C1.CATEGORYDESC;
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
            
            LV_INSERTSTR := '|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|';
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
            
            LV_LASTUNIT := C1.UNITCODE;
            LV_LASTCATEGORY := C1.CATEGORYCODE;
        END IF;
        --LV_INSERTSTR := '|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|';

        IF LV_LASTCATEGORY <> C1.CATEGORYCODE  OR LV_LASTUNIT <> C1.UNITCODE THEN
            FOR C2 IN 
            ( 
        --        SELECT * FROM GTT_PAYSLIP_ASIANTEA WHERE rownum < 3
                SELECT * FROM (
                    SELECT SUM(PF_GROSS) PF_GROSS, SUM(PF_E) PF_E, SUM(VPF)VPF, SUM(PF_C) PF_C, SUM(FPF) FPF, 
                    SUM(LOAN_PFL) LOAN_PFL, SUM(LINT_PFL) LINT_PFL, SUM(LNBL_PFL) LNBL_PFL,  
                    SUM(LOANAMOUNT) LOANAMOUNT, SUM(PF_E_YTD) PF_E_YTD, SUM(VPF_YTD) VPF_YTD, SUM(PF_C_YTD) PF_C_YTD, SUM(FPF_YTD) FPF_YTD 
                    FROM GTT_PIS_PF_LOANDEDN_REP 
                    WHERE UNITCODE = LV_LASTUNIT
                    AND CATEGORYCODE = LV_LASTCATEGORY
                    --ORDER BY UNITCODE, CATEGORYCODE, DEPARTMENTCODE, TOKENNO
                )
        --        WHERE rownum < 11
            )
            LOOP
             
            LV_INSERTSTR := g_CompOn||g_Condence||'|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|';
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
          
            
                LV_INSERTSTR := '          '||FMTALIGN('GROUP',46,'L')||' '||
                                FMTALIGN(C2.PF_GROSS,12,'R',2)||' '||
                                FMTALIGN(' ',6,'R',2)||' '||
                                FMTALIGN(C2.VPF,10,'R',2)||' '||
                                FMTALIGN(' ',6,'R',2)||' '||
                                FMTALIGN(C2.VPF_YTD,10,'R',2)||' '||
                                FMTALIGN(' ',5,'R',2)||' '||
--                                FMTALIGN((C2.PF_C_YTD+C2.FPF_YTD),12,'R',2)||' '||
                                FMTALIGN((C2.PF_C_YTD),12,'R',2)||' '||
                                FMTALIGN(' ',10,'R',2)||' '||
                                FMTALIGN(C2.LOANAMOUNT,12,'R',2)||' '||
                                FMTALIGN(' ',8,'R',2)||' '||
                                FMTALIGN(C2.LOAN_PFL,10,'R',2)||' '||
                                FMTALIGN(' ',9,'R',2);
                P_INT1 := P_INT1 + 1;
                PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
                LV_INSERTSTR := '          '||FMTALIGN('TOTAL',48,'L')||' '||
                                FMTALIGN(' ',8,'R',2)||' '||
                                FMTALIGN(C2.PF_E,10,'R',2)||' '||
                                FMTALIGN(' ',6,'R',2)||' '||
                                FMTALIGN(C2.PF_E_YTD,10,'R',2)||' '||
                                FMTALIGN(' ',6,'R',2)||' '||
--                                FMTALIGN((C2.PF_C+C2.FPF),10,'R',2)||' '||
                                FMTALIGN((C2.PF_C),10,'R',2)||' '||
                                FMTALIGN(' ',9,'R',2)||' '||
                                FMTALIGN(' ',11,'R',2)||' '||
                                FMTALIGN(' ',9,'R',2)||' '||
                                FMTALIGN(C2.LNBL_PFL,12,'R',2)||' '||
                                FMTALIGN(' ',6,'R',2)||' '||
                                FMTALIGN(C2.LINT_PFL,11,'R',2);
                P_INT1 := P_INT1 + 1;
                PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
            END LOOP;
             
            LV_INSERTSTR := '|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|';
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
            
             LV_INSERTSTR := '|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|';
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
            LV_INSERTSTR := '  UNIT - ['||C1.UNITCODE||'] '||C1.UNITSHORTDESC||'        CATEGORY - ['||C1.CATEGORYCODE||'] '||C1.CATEGORYDESC;
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
            
            LV_INSERTSTR := '|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|';
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
            
            
        END IF; 
        
        LV_INSERTSTR := FMTALIGN(C1.SLNO,4,'R')||' '||
                        FMTALIGN(C1.DEPARTMENTDESC,15,'L')||' '||
                        FMTALIGN(C1.TOKENNO,7,'L')||' '||
                        FMTALIGN(C1.PFNO,7,'L')||' '||
                        FMTALIGN(C1.EMPLOYEENAME,21,'L')||' '||
                        FMTALIGN(C1.PF_GROSS,10,'R',2)||' '||
                        FMTALIGN(C1.PF_E,8,'R',2)||' '||
                        FMTALIGN(C1.VPF,8,'R',2)||' '||
                        FMTALIGN(C1.PF_E_YTD,8,'R',2)||' '||
                        FMTALIGN(C1.VPF_YTD,8,'R',2)||' '||
                        FMTALIGN((C1.PF_C+C1.FPF),8,'R',2)||' '||
                        FMTALIGN((C1.PF_C_YTD+C1.FPF_YTD),9,'R',2)||' '||
                        FMTALIGN(TO_CHAR(C1.LOANDATE,'DD/MM/YYYY'),11,'R',2)||' '||
                        FMTALIGN(C1.LOANAMOUNT,11,'R',2)||' '||
                        FMTALIGN(C1.LNBL_PFL,10,'R',2)||' '||
                        FMTALIGN(C1.LOAN_PFL,8,'R',2)||' '||
                        FMTALIGN(C1.LINT_PFL,9,'R',2);
                        
                        
                        
         P_INT1 := P_INT1 + 1;
        PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
     
        LV_LASTUNIT := C1.UNITCODE;
        LV_LASTCATEGORY := C1.CATEGORYCODE;
        
    END LOOP;
    
     LV_INSERTSTR := g_CompOn||g_Condence||'|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|';
     P_INT1 := P_INT1 + 1;
    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);



        IF LV_LASTCATEGORY IS NOT NULL  AND LV_LASTUNIT IS NOT NULL THEN
            FOR C2 IN 
            ( 
        --        SELECT * FROM GTT_PAYSLIP_ASIANTEA WHERE rownum < 3
                SELECT * FROM (
                    SELECT SUM(PF_GROSS) PF_GROSS, SUM(PF_E) PF_E, SUM(VPF)VPF, SUM(PF_C) PF_C, SUM(FPF) FPF, 
                    SUM(LOAN_PFL) LOAN_PFL, SUM(LINT_PFL) LINT_PFL, SUM(LNBL_PFL) LNBL_PFL,  
                    SUM(LOANAMOUNT) LOANAMOUNT, SUM(PF_E_YTD) PF_E_YTD, SUM(VPF_YTD) VPF_YTD, SUM(PF_C_YTD) PF_C_YTD, SUM(FPF_YTD) FPF_YTD 
                    FROM GTT_PIS_PF_LOANDEDN_REP 
                    WHERE UNITCODE = LV_LASTUNIT
                    AND CATEGORYCODE = LV_LASTCATEGORY
                    --ORDER BY UNITCODE, CATEGORYCODE, DEPARTMENTCODE, TOKENNO
                )
        --        WHERE rownum < 11
            )
            LOOP
             
            LV_INSERTSTR := '|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|';
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
          
            
                LV_INSERTSTR := '          '||FMTALIGN('GROUP',46,'L')||' '||
                                FMTALIGN(C2.PF_GROSS,12,'R',2)||' '||
                                FMTALIGN(' ',6,'R',2)||' '||
                                FMTALIGN(C2.VPF,10,'R',2)||' '||
                                FMTALIGN(' ',6,'R',2)||' '||
                                FMTALIGN(C2.VPF_YTD,10,'R',2)||' '||
                                FMTALIGN(' ',5,'R',2)||' '||
                                FMTALIGN((C2.PF_C_YTD+C2.FPF_YTD),12,'R',2)||' '||
                                FMTALIGN(' ',10,'R',2)||' '||
                                FMTALIGN(C2.LOANAMOUNT,12,'R',2)||' '||
                                FMTALIGN(' ',8,'R',2)||' '||
                                FMTALIGN(C2.LOAN_PFL,10,'R',2)||' '||
                                FMTALIGN(' ',9,'R',2);
                P_INT1 := P_INT1 + 1;
                PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
                LV_INSERTSTR := '          '||FMTALIGN('TOTAL',48,'L')||' '||
                                FMTALIGN(' ',8,'R',2)||' '||
                                FMTALIGN(C2.PF_E,10,'R',2)||' '||
                                FMTALIGN(' ',6,'R',2)||' '||
                                FMTALIGN(C2.PF_E_YTD,10,'R',2)||' '||
                                FMTALIGN(' ',6,'R',2)||' '||
                                FMTALIGN((C2.PF_C+C2.FPF),10,'R',2)||' '||
                                FMTALIGN(' ',9,'R',2)||' '||
                                FMTALIGN(' ',11,'R',2)||' '||
                                FMTALIGN(' ',9,'R',2)||' '||
                                FMTALIGN(C2.LNBL_PFL,12,'R',2)||' '||
                                FMTALIGN(' ',6,'R',2)||' '||
                                FMTALIGN(C2.LINT_PFL,11,'R',2);
                P_INT1 := P_INT1 + 1;
                PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
            END LOOP;
             
            LV_INSERTSTR := '|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|';
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
            
        END IF; 
        
        
        

    FOR C1 IN 
    ( 
--        SELECT * FROM GTT_PAYSLIP_ASIANTEA WHERE rownum < 3
        SELECT * FROM (
            SELECT SUM(PF_GROSS) PF_GROSS, SUM(PF_E) PF_E, SUM(VPF)VPF, SUM(PF_C) PF_C, SUM(FPF) FPF, 
            SUM(LOAN_PFL) LOAN_PFL, SUM(LINT_PFL) LINT_PFL, SUM(LNBL_PFL) LNBL_PFL,  
            SUM(LOANAMOUNT) LOANAMOUNT, SUM(PF_E_YTD) PF_E_YTD, SUM(VPF_YTD) VPF_YTD, SUM(PF_C_YTD) PF_C_YTD, SUM(FPF_YTD) FPF_YTD 
            FROM GTT_PIS_PF_LOANDEDN_REP 
            --ORDER BY UNITCODE, CATEGORYCODE, DEPARTMENTCODE, TOKENNO
        )
--        WHERE rownum < 11
    )
    LOOP
        LV_INSERTSTR := '          '||FMTALIGN('GRAND',46,'L')||' '||
                        FMTALIGN(C1.PF_GROSS,12,'R',2)||' '||
                        FMTALIGN(' ',6,'R',2)||' '||
                        FMTALIGN(C1.VPF,10,'R',2)||' '||
                        FMTALIGN(' ',6,'R',2)||' '||
                        FMTALIGN(C1.VPF_YTD,10,'R',2)||' '||
                        FMTALIGN(' ',5,'R',2)||' '||
                        FMTALIGN((C1.PF_C_YTD+C1.FPF_YTD),12,'R',2)||' '||
                        FMTALIGN(' ',10,'R',2)||' '||
                        FMTALIGN(C1.LOANAMOUNT,12,'R',2)||' '||
                        FMTALIGN(' ',8,'R',2)||' '||
                        FMTALIGN(C1.LOAN_PFL,10,'R',2)||' '||
                        FMTALIGN(' ',9,'R',2);
        P_INT1 := P_INT1 + 1;
        PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
        LV_INSERTSTR := '          '||FMTALIGN('TOTAL',48,'L')||' '||
                        FMTALIGN(' ',8,'R',2)||' '||
                        FMTALIGN(C1.PF_E,10,'R',2)||' '||
                        FMTALIGN(' ',6,'R',2)||' '||
                        FMTALIGN(C1.PF_E_YTD,10,'R',2)||' '||
                        FMTALIGN(' ',6,'R',2)||' '||
                        FMTALIGN((C1.PF_C+C1.FPF),10,'R',2)||' '||
                        FMTALIGN(' ',9,'R',2)||' '||
                        FMTALIGN(' ',11,'R',2)||' '||
                        FMTALIGN(' ',9,'R',2)||' '||
                        FMTALIGN(C1.LNBL_PFL,12,'R',2)||' '||
                        FMTALIGN(' ',6,'R',2)||' '||
                        FMTALIGN(C1.LINT_PFL,11,'R',2);
        P_INT1 := P_INT1 + 1;
        PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
    END LOOP;
    
     
     LV_INSERTSTR := '|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|';
     P_INT1 := P_INT1 + 1;
    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
--commit;

-------end text report----
     
END;
/
