CREATE OR REPLACE PROCEDURE BIRLANEW.PROC_RPT_UCO_NONATMLIST_TEXT
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
    
    
    LV_COMPANYNAME VARCHAR2(100);
    LV_DIVISIONNAME VARCHAR2(100);
    
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

--EXEC PROC_RPT_AXISBANKPAYROLL_TEXT('DY0086','Y03','15/03/2020','28/03/2020','','','','')

    DELETE FROM GTT_PIS_PTAXDEDN_REP WHERE 1=1;
    
    SELECT COMPANYNAME, DIVISIONNAME INTO LV_COMPANYNAME, LV_DIVISIONNAME  FROM DIVISIONMASTER A, COMPANYMAST B
    WHERE A.COMPANYCODE=B.COMPANYCODE
    AND A.COMPANYCODE=P_COMPANYCODE
    AND A.DIVISIONCODE=P_DIVISIONCODE;
    
    LV_SQLSTR := NULL;
    
--    
--CREATE GLOBAL TEMPORARY TABLE GTT_AXIXBANKPAYROLL AS
--SELECT A.TOKENNO, BANKACCNUMBER, EMPLOYEENAME, NETSALARY
--FROM PISEMPLOYEEMASTER A, 
--(
--    SELECT TOKENNO, NETSALARY FROM PISPAYTRANSACTION WHERE YEARMONTH='202009'
--)B
--WHERE A.TOKENNO=B.TOKENNO     
--AND LENGTH(BANKACCNUMBER) = 15
    
    LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_AXIXBANKPAYROLL' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    TOKENNO, BANKACCNUMBER, EMPLOYEENAME, NETSALARY ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
    
     
    LV_SQLSTR := LV_SQLSTR || 'SELECT A.TOKENNO, A.DEPARTMENTCODE BANKACCNUMBER, EMPLOYEENAME, NETSALARY'|| chr(10) ;  
    LV_SQLSTR := LV_SQLSTR || 'FROM PISEMPLOYEEMASTER A, '|| chr(10) ;  
    LV_SQLSTR := LV_SQLSTR || '('|| chr(10) ;  
    LV_SQLSTR := LV_SQLSTR || '    SELECT WORKERSERIAL, TOKENNO, NETSALARY FROM PISPAYTRANSACTION WHERE YEARMONTH='''||P_YEARMONTH||'''';
    LV_SQLSTR := LV_SQLSTR || '    AND  COMPANYCODE='''||P_COMPANYCODE||'''' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND  DIVISIONCODE='''||P_DIVISIONCODE||'''' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || ')B'|| chr(10) ;  
    LV_SQLSTR := LV_SQLSTR || 'WHERE A.WORKERSERIAL=B.WORKERSERIAL     '|| chr(10) ;  
    LV_SQLSTR := LV_SQLSTR || 'AND A.BANKACCNUMBER is null '|| chr(10) ;    
    LV_SQLSTR := LV_SQLSTR || '    AND A.COMPANYCODE='''||P_COMPANYCODE||'''' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND A.DIVISIONCODE='''||P_DIVISIONCODE||'''' || CHR(10);

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
            SELECT ROW_NUMBER() OVER ( ORDER BY TOKENNO) SLNO,  
            TOKENNO, BANKACCNUMBER ATM_NUMBER, EMPLOYEENAME, NETSALARY NETPAY
            FROM GTT_AXIXBANKPAYROLL 
            ORDER BY TOKENNO 
        )
--        WHERE rownum < 11
    )
    LOOP 
    
        
        IF P_BLOCKS >= 50 THEN
        
            LV_INSERTSTR := '|--------------------------------------------------------------------------------------------|';
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
          
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(g_NewPage);
            P_BLOCKS := 0;
        END IF;
        
        P_BLOCKS := P_BLOCKS+1;

          
        IF P_BLOCKS = 1 THEN     


--            LV_INSERTSTR := FMTALIGN(C1.UNITSHORTDESC,30,'C')||' '|| FMTALIGN('STAFF(BIRLA INDUSTRIES) P.F. & LOAN DEDN. STATEMENT ',100,'C')||
--            FMTALIGN('MONTH - '||TO_CHAR(TO_DATE(P_YEARMONTH,'YYYYMM'),'MON-YYYY'),50,'C') ;
--            P_INT1 := P_INT1 + 1;
--            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
--            
            
--            
----------------------------------------------------------------------------------------------
--SRL. NO        EMP. CODE     ATM  NUMBER           EMPLOYEE NAME                  NETPAY
----------------------------------------------------------------------------------------------




            LV_INSERTSTR := ' '||LV_COMPANYNAME;
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);

            LV_INSERTSTR := '  ';
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);


            LV_INSERTSTR := ' '||LV_DIVISIONNAME;
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);

            LV_INSERTSTR := '  ';
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);



            LV_INSERTSTR := ' UCO BANK NON ATM LIST FOR THE MONTH OF '||TO_CHAR(TO_DATE(P_YEARMONTH,'YYYYMM'),'MON-YY');
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
            

            LV_INSERTSTR := '   ';
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
            
            
            
            LV_INSERTSTR := '|--------------------------------------------------------------------------------------------|';
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
                       

            LV_INSERTSTR := ' SRL. NO        EMP. CODE     DEPARTMENT            EMPLOYEE NAME                  NETPAY    |';
            P_INT1 := P_INT1 + 1;

            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
                       
           

          
            LV_INSERTSTR := '|--------------------------------------------------------------------------------------------|';
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);

--            
--            LV_LASTUNIT := C1.UNITCODE;
--            LV_LASTCATEGORY := C1.CATEGORYCODE;
        END IF; 
        
        
        LV_INSERTSTR := '  '||FMTALIGN(C1.SLNO,14,'L')||' '||
                        FMTALIGN(C1.TOKENNO,12,'L')||' '||
                        FMTALIGN(C1.ATM_NUMBER,21,'L')||' '||
                        FMTALIGN(C1.EMPLOYEENAME,25,'L')||' '||
                        FMTALIGN(C1.NETPAY,13,'R',2)||' ' ;
                        
                        
                        
         P_INT1 := P_INT1 + 1;
        PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
     
--        LV_LASTUNIT := C1.UNITCODE;
--        LV_LASTCATEGORY := C1.CATEGORYCODE;
        
    END LOOP;
    
     LV_INSERTSTR := '|--------------------------------------------------------------------------------------------|';
     P_INT1 := P_INT1 + 1;
    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);

  FOR C1 IN 
    ( 
--        SELECT * FROM GTT_PAYSLIP_ASIANTEA WHERE rownum < 3
        SELECT * FROM (
          SELECT  SUM(NETSALARY) NETPAY 
            FROM GTT_AXIXBANKPAYROLL 
        )
--        WHERE rownum < 11
    )
    LOOP 
    
        LV_INSERTSTR := '  '||FMTALIGN(' ',14,'L')||' '||
                        FMTALIGN(' TOTAL',14,'L')||' '||
                        FMTALIGN(' ',22,'L')||' '||
                        FMTALIGN(' ',20,'L')||' '||
                        FMTALIGN(C1.NETPAY,15,'R',2)||' ' ;
                        
                        
                        
         P_INT1 := P_INT1 + 1;
        PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
     
    END LOOP;
         
    LV_INSERTSTR := '|--------------------------------------------------------------------------------------------|';
    P_INT1 := P_INT1 + 1;
    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
         
--    LV_INSERTSTR := ' ';
--    P_INT1 := P_INT1 + 1;
--    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
--         
--    LV_INSERTSTR := ' ';
--    P_INT1 := P_INT1 + 1;
--    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
--        
--    LV_INSERTSTR := ' INTEREST                                                                    TOTAL RETURN';
--    P_INT1 := P_INT1 + 1;
--    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
--        
--    LV_INSERTSTR := ' ';
--    P_INT1 := P_INT1 + 1;
--    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
--        
--    LV_INSERTSTR := ' DATE :';
--    P_INT1 := P_INT1 + 1;
--    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
--        
--    LV_INSERTSTR := ' ';
--    P_INT1 := P_INT1 + 1;
--    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
--        
--        
--              
--    LV_INSERTSTR := '                                                    SIGNATURE                    DESIGNATION';
--    P_INT1 := P_INT1 + 1;
--    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
--            
--    LV_INSERTSTR := '|--------------------------------------------------------------------------------------------|';
--    P_INT1 := P_INT1 + 1;
--    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
--         

-------end text report----
     
END;
/
