CREATE OR REPLACE PROCEDURE ASIANTEA.PROC_RPT_PAYSLIP_ASIANTEA
(
    P_COMPANYCODE VARCHAR2,
    P_DIVISIONCODE VARCHAR2,
    P_FROMDATE     VARCHAR2,
    P_TODATE       VARCHAR2,
    P_CATEGORY       VARCHAR2 DEFAULT NULL,
    P_CLUSTER       VARCHAR2 DEFAULT NULL,
    P_ATTNBOOK       VARCHAR2 DEFAULT NULL,
    P_TOKENNO       VARCHAR2 DEFAULT NULL
)
AS 
    LV_SQLSTR           VARCHAR2(32000);  
    LV_INSERTSTR VARCHAR2(4000);


    LV_DATEFM1 VARCHAR2(4000);
    LV_DATEFM2 VARCHAR2(4000);

    P_INT1  NUMBER(20);
    P_BLOCKS  NUMBER(10);
    
    
    
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

--EXEC PROC_RPT_PAYSLIP_ASIANTEA('DY0086','Y03','15/03/2020','28/03/2020','','','','')

    DELETE FROM GTT_PAYSLIP_ASIANTEA WHERE 1=1; 
        
    LV_SQLSTR := LV_SQLSTR ||   'INSERT INTO GTT_PAYSLIP_ASIANTEA'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   '('|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   '    COMPANYCODE, COMPANYNAME, DIVISIONCODE, DIVISIONNAME, WORKERSERIAL, TOKENNO, '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   '    CATEGORYCODE, TYPEOFCATEGORY, CATEGORYDESC, ATTNBOOKCODE, ATTNBOOKDESC, OCCUPATIONCODE, '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   '    CLUSTERCODE, CLUSTERDESC, TOTALATTAKG, TOTALRICEKG, DAILYWAGES, PERIODFROM, DD, GROSSWAGES, '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   '    INCENTIVE, PF_E, LOAN_PF, RAT_EARN, OTHER_DED, DED_LIC, DED_UNION, DED_ELEC, DED_WELFARE, '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   '    TEMP_DED, GROSSDEDN, COINCF, COINBF, NETSALARY'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   ')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'SELECT A.COMPANYCODE,G.COMPANYNAME, A.DIVISIONCODE,H.DIVISIONNAME, A.WORKERSERIAL, A.TOKENNO, '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'A.CATEGORYCODE, C.TYPEOFCATEGORY,C.CATEGORYDESC, A.ATTNBOOKCODE, E.ATTNBOOKDESC, A.OCCUPATIONCODE, A.CLUSTERCODE, F.CLUSTERDESC,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'NVL(B.TOTALATTAKG,0) TOTALATTAKG, NVL(B.TOTALRICEKG,0) TOTALRICEKG, D.DAILYWAGES, D.PERIODFROM,D.DD,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'NVL(GROSSWAGES,0) GROSSWAGES,NVL(ATTN_ALLOW,0) INCENTIVE,NVL(PF_E,0) PF_E,(NVL(LOAN_PF,0)+NVL(LINT_PF,0))LOAN_PF,NVL(RAT_EARN,0) RAT_EARN,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'NVL(OTHER_DED,0) OTHER_DED, NVL(DED_LIC,0) DED_LIC,NVL(DED_UNION,0) DED_UNION,NVL(DED_ELEC,0) DED_ELEC,NVL(DED_WELFARE,0) DED_WELFARE,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'NVL(TEMP_DED,0) TEMP_DED, NVL(GROSSDEDN,0) GROSSDEDN,NVL(COINCF,0) COINCF,NVL(COINBF,0) COINBF,NVL(NETSALARY,0) NETSALARY'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'FROM GPSPAYSHEETDETAILS A, GPSRATIONDETAILS B,GPSCATEGORYMAST C,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   '('|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   '    SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, PERIODFROM, '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   '    TO_CHAR(PERIODFROM,''DY-DD'') DD, NVL(GROSSWAGES,0) DAILYWAGES'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   '    FROM GPSDAILYPAYSHEETDETAILS '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   '    WHERE 1=1'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   '    AND COMPANYCODE='''||P_COMPANYCODE||''' '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   '    AND DIVISIONCODE='''||P_DIVISIONCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   '    --AND A.TOKENNO=''10002'''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   '    AND PERIODFROM>=TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   '    AND PERIODFROM<=TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   ') D, GPSATTNBOOKMAST E, GPSCLUSTERMASTER F, COMPANYMAST G, DIVISIONMASTER H'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'WHERE 1=1'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'AND A.COMPANYCODE='''||P_COMPANYCODE||''' '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'AND A.DIVISIONCODE='''||P_DIVISIONCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   '--AND A.TOKENNO=''10002'''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'AND A.PERIODFROM>=TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'AND A.PERIODFROM<=TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'AND A.COMPANYCODE=B.COMPANYCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'AND A.DIVISIONCODE=B.DIVISIONCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'AND A.WORKERSERIAL=B.WORKERSERIAL(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'AND A.PERIODFROM=B.PERIODFROM(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'AND A.COMPANYCODE=C.COMPANYCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'AND A.DIVISIONCODE=C.DIVISIONCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'AND A.CATEGORYCODE=C.CATEGORYCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'AND A.COMPANYCODE=D.COMPANYCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'AND A.DIVISIONCODE=D.DIVISIONCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'AND A.WORKERSERIAL=D.WORKERSERIAL'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'AND A.COMPANYCODE=E.COMPANYCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'AND A.DIVISIONCODE=E.DIVISIONCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'AND A.ATTNBOOKCODE=E.ATTNBOOKCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'AND A.COMPANYCODE=F.COMPANYCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'AND A.DIVISIONCODE=F.DIVISIONCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'AND A.CLUSTERCODE=F.CLUSTERCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'AND A.COMPANYCODE=G.COMPANYCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'AND A.COMPANYCODE=H.COMPANYCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR ||   'AND A.DIVISIONCODE=H.DIVISIONCODE'|| CHR(10);

    IF P_CATEGORY IS NOT NULL THEN
        LV_SQLSTR := LV_SQLSTR ||   '           AND A.CATEGORYCODE  IN ('|| P_CATEGORY ||')' || CHR(10);
    END IF;
                    
    IF P_CLUSTER IS NOT NULL THEN
        LV_SQLSTR := LV_SQLSTR || '             AND A.CLUSTERCODE  IN ('|| P_CLUSTER ||')' || CHR(10);
    END IF;
                    
    IF P_ATTNBOOK IS NOT NULL THEN
        LV_SQLSTR := LV_SQLSTR || '             AND A.ATTNBOOKCODE  IN ('|| P_ATTNBOOK ||')' || CHR(10);
    END IF;
                    
    IF P_TOKENNO IS NOT NULL THEN
        LV_SQLSTR := LV_SQLSTR || '             AND A.TOKENNO  IN ('|| P_TOKENNO ||')' || CHR(10);
    END IF;
--                        
    LV_SQLSTR := LV_SQLSTR ||   '  ORDER BY   A.TOKENNO, D.PERIODFROM' || CHR(10);
                    
    
  --DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
  EXECUTE IMMEDIATE LV_SQLSTR;
  
    UPDATE GTT_PAYSLIP_ASIANTEA A
    SET (EMPLOYEENAME,PFNO)=
    (
        SELECT  EMPLOYEENAME,PFNO 
        FROM GPSEMPLOYEEMAST
        WHERE A.COMPANYCODE=COMPANYCODE
        AND A.DIVISIONCODE=DIVISIONCODE
        AND A.WORKERSERIAL=WORKERSERIAL
    ),
    DATEFROM=P_FROMDATE,
    DATETO = P_TODATE
    WHERE 1=1;

----------------------------------------------------------
----  start text report ---

    P_INT1  := 0;
    
    DELETE FROM GTT_PAYSLIP_DATES WHERE 1=1;
    DELETE FROM GTT_TEXT_REPORT WHERE 1=1;
--    commit;
    
    INSERT INTO GTT_PAYSLIP_DATES
    SELECT DT, TO_CHAR(DT,'DY-DD') DD FROM (
            SELECT TO_DATE(P_FROMDATE, 'DD/MM/YYYY') + ROWNUM -1 DT
            FROM DUAL
            CONNECT BY LEVEL <= TO_DATE(P_TODATE, 'DD/MM/YYYY') - TO_DATE(P_FROMDATE, 'DD/MM/YYYY') +1
            );
            
            
    FOR C1 IN ( SELECT * FROM GTT_PAYSLIP_DATES )
    LOOP
        IF P_INT1 < 7 THEN
            LV_DATEFM1 := LV_DATEFM1 || '| ' || C1.DD || ' ';
        ELSE
            LV_DATEFM2 := LV_DATEFM2 || '| ' || C1.DD || ' ';
        END IF;
        P_INT1 := P_INT1 + 1;
    END LOOP;
--    
--    DBMS_OUTPUT.PUT_LINE(LV_DATEFM1);
--    DBMS_OUTPUT.PUT_LINE(LV_DATEFM2);
    P_INT1 := 0;
    P_BLOCKS := 0;
    
--    PROC_INSERT_TEXT_REPORT(g_CompSmall);
    FOR C1 IN 
    ( 
--        SELECT * FROM GTT_PAYSLIP_ASIANTEA WHERE rownum < 3
        SELECT * FROM (
            SELECT DISTINCT TOKENNO, PFNO,EMPLOYEENAME, DIVISIONNAME,TYPEOFCATEGORY, TOTALRICEKG,CLUSTERDESC,ATTNBOOKDESC,TOTALATTAKG,
            GROSSWAGES, INCENTIVE, PF_E, LOAN_PF, RAT_EARN, OTHER_DED, DED_LIC, DED_UNION, DED_ELEC, DED_WELFARE, GROSSDEDN, COINCF, COINBF, NETSALARY 
            FROM GTT_PAYSLIP_ASIANTEA 
            ORDER BY TOKENNO
        )
--        WHERE rownum < 11
    )
    LOOP 
    
        
        IF P_BLOCKS >= 5 THEN
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(g_NewPage);
            P_BLOCKS := 0;
        END IF;
        
        P_BLOCKS := P_BLOCKS+1;

--        PROC_INSERT_TEXT_REPORT(g_CompOn);
--        PROC_INSERT_TEXT_REPORT(g_CompSmall);
--     |  LIGRIPOOKRIE TEA ESTATE|  SUN-01  | MON-02 | TUE-03 | WED-04 | THU-05 | FRI-06 | SAT-07 | WORKERTYPE     : PERMANENT                     RICE QTY:  8.14|TOTALATTAKG, NVL(B.TOTALRICEKG,0) TOTALRICEKG
--     |01/03/2020 TO 14/03/2020 |  SUN-08  | MON-09 | TUE-10 | WED-11 | THU-12 | FRI-13 | SAT-14 | DIV.NO- BOOK NO: DIVISION-1 PERM MEN-1         ATTA QTY:  8.14|
--        LV_INSERTSTR := g_CompOn||g_CompSmall||'|---------------------------------------------------------------------------------------------------------------------------------------------------------|';
        LV_INSERTSTR := g_NormalSmall||'|---------------------------------------------------------------------------------------------------------------------------------------------------------|';
       
        
        P_INT1 := P_INT1 + 1;
        PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
        
        
        
        LV_INSERTSTR := '|'||LPAD(C1.DIVISIONNAME,24)|| LPAD(LV_DATEFM1,65)||'| '||RPAD('WORKERTYPE     : ' || C1.TYPEOFCATEGORY,44)|| LPAD(' RICE QTY:',12)||LPAD(C1.TOTALRICEKG,6)||'|' ;
        P_INT1 := P_INT1 + 1;
        PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
        
        LV_INSERTSTR := '|'||LPAD(P_FROMDATE||' TO '||P_TODATE,24)|| LPAD(LV_DATEFM2,65)||'| '||RPAD('DIV.NO- BOOK NO: '||C1.CLUSTERDESC||' '|| C1.ATTNBOOKDESC,44)|| LPAD(' ATTA QTY:',12)||LPAD(C1.TOTALATTAKG,6)||'|' ;
        P_INT1 := P_INT1 + 1;
        PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
        
        LV_INSERTSTR := '|---------------------------------------------------------------------------------------------------------------------------------------------------------|';
        P_INT1 := P_INT1 + 1;
        PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
        
        LV_INSERTSTR := '| CODE  |NAME              |GROSS   |  INC   |P.F.    |P.F.    |RATION  | OTHER  |A.C.M.S |L.I.C.   |ELECTRIC|LAB.    |TOTAL      |COIN  |COIN  |   PAY   |';
        P_INT1 := P_INT1 + 1;
        PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
        
        LV_INSERTSTR := '| PF.NO.|                  |AMOUNT  |        |DEDN.   |ADV.    |AMOUNT  |  (1)   |TEMP DED|         |        |WELFARE |DEDUCTION  |B.F.  |C.F   | AMOUNT  |';
        P_INT1 := P_INT1 + 1;
        PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
        
        LV_INSERTSTR := '|---------------------------------------------------------------------------------------------------------------------------------------------------------|';
        P_INT1 := P_INT1 + 1;
        PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
--        ||g_CompOff
--        PROC_INSERT_TEXT_REPORT(g_CompOff);

        SELECT REPLACE(WM_CONCAT(DAILYWAGES),',','|') INTO LV_INSERTSTR FROM
        (
            SELECT  DT, LPAD(DECODE(NVL(DAILYWAGES, 0),0,'A', TO_CHAR(DAILYWAGES,'9999.99')),8) DAILYWAGES
            FROM GTT_PAYSLIP_DATES A, 
            (
                SELECT DAILYWAGES,PERIODFROM FROM GTT_PAYSLIP_ASIANTEA
                WHERE  TOKENNO=C1.TOKENNO
            )B
            WHERE 1=1
            AND A.DT BETWEEN TO_DATE(P_FROMDATE,'DD/MM/YYYY') AND  (TO_DATE(P_FROMDATE,'DD/MM/YYYY')+6)
            AND A.DT=B.PERIODFROM(+)
            ORDER BY DT
         );
         
        LV_INSERTSTR := '|'||LPAD(LV_INSERTSTR,89)||'|'||LPAD('  ',63)||'|';
        P_INT1 := P_INT1 + 1;
        PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
        
        SELECT REPLACE(WM_CONCAT(DAILYWAGES),',','|') INTO LV_INSERTSTR FROM
        (
            SELECT  DT, LPAD(DECODE(NVL(DAILYWAGES, 0),0,'A', TO_CHAR(DAILYWAGES,'9999.99')),8) DAILYWAGES
            FROM GTT_PAYSLIP_DATES A, 
            (
                SELECT DAILYWAGES,PERIODFROM FROM GTT_PAYSLIP_ASIANTEA
                WHERE  TOKENNO=C1.TOKENNO
            )B
            WHERE 1=1
            AND A.DT BETWEEN (TO_DATE(P_FROMDATE,'DD/MM/YYYY')+7) AND  TO_DATE(P_TODATE,'DD/MM/YYYY')
            AND A.DT=B.PERIODFROM(+)
            ORDER BY DT
         );
       
        LV_INSERTSTR := '|'||RPAD(C1.TOKENNO,7)||'|'||RPAD(C1.EMPLOYEENAME,18)||'|'||LPAD(LV_INSERTSTR,62)||'|'||LPAD('  ',63)||'|';
        P_INT1 := P_INT1 + 1;
        PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
        
         
        
    --    LV_INSERTSTR := '|'||RPAD(C1.PFNO,7)||'|'||RPAD('  ',18)||'|'||
    --    LPAD(C1.GROSSWAGES,8)||'|'||LPAD(C1.INCENTIVE,8)||'|'||LPAD(C1.PF_E,8)||'|'||LPAD(C1.LOAN_PF,8)||'|'||
    --    LPAD(C1.RAT_EARN,8)||'|'||LPAD(C1.OTHER_DED,8)||'|'||LPAD(C1.DED_UNION,8)||'|'||LPAD(C1.DED_LIC,9)||'|'||LPAD(C1.DED_ELEC,8)||'|'||
    --    LPAD(C1.DED_WELFARE,8)||'|'||LPAD(C1.GROSSDEDN,11)||'|'||LPAD(C1.COINCF,6)||'|'||LPAD(C1.COINBF,6)||'|'||LPAD(C1.NETSALARY,9)||'|';
    --    
        
        LV_INSERTSTR := '|'||RPAD(C1.PFNO,7)||'|'||RPAD('  ',18)||'|'||
        LPAD(TO_CHAR(C1.GROSSWAGES,'9999.99'),8)||'|'||LPAD(TO_CHAR(C1.INCENTIVE,'9999.99'),8)||'|'||LPAD(TO_CHAR(C1.PF_E,'9999.99'),8)||'|'||LPAD(TO_CHAR(C1.LOAN_PF,'9999.99'),8)||'|'||
        LPAD(TO_CHAR(C1.RAT_EARN,'9999.99'),8)||'|'||LPAD(TO_CHAR(C1.OTHER_DED,'9999.99'),8)||'|'||LPAD(TO_CHAR(C1.DED_UNION,'9999.99'),8)||'|'||LPAD(TO_CHAR(C1.DED_LIC,'9999.99'),9)||'|'||LPAD(TO_CHAR(C1.DED_ELEC,'9999.99'),8)||'|'||
        LPAD(TO_CHAR(C1.DED_WELFARE,'9999.99'),8)||'|'||LPAD(TO_CHAR(C1.GROSSDEDN,'9999.99'),11)||'|'||LPAD(TO_CHAR(C1.COINCF,'99.99'),6)||'|'||LPAD(TO_CHAR(C1.COINBF,'99.99'),6)||'|'||LPAD(TO_CHAR(C1.NETSALARY,'9999.99'),9)||'|';
        
        P_INT1 := P_INT1 + 1;
        PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
        
        
        
        LV_INSERTSTR := '|---------------------------------------------------------------------------------------------------------------------------------------------------------|';
        P_INT1 := P_INT1 + 1;
        PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
        LV_INSERTSTR := '|                                                                    Tear Off                                                                             |';
        P_INT1 := P_INT1 + 1;
        PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
        LV_INSERTSTR := '|---------------------------------------------------------------------------------------------------------------------------------------------------------|';
        P_INT1 := P_INT1 + 1;
        PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);

        
    END LOOP;
    
    LV_INSERTSTR := '|---------------------------------------------------------------------------------------------------------------------------------------------------------|';
    P_INT1 := P_INT1 + 1;
    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);

--commit;

-------end text report----
     
END;
/