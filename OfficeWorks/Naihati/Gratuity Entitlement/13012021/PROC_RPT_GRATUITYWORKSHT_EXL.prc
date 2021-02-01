CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_RPT_GRATUITYWORKSHT_EXL
(
    P_COMPANYCODE VARCHAR2,
    P_DIVISIONCODE VARCHAR2,
    P_YEARCODE VARCHAR2,
    P_FROMDATE VARCHAR2,
    P_TODATE VARCHAR2,
    P_UNIT VARCHAR2 DEFAULT NULL,
    P_CATEGORY VARCHAR2 DEFAULT NULL,
    P_GRADE VARCHAR2 DEFAULT NULL,
    P_WORKERSERIAL VARCHAR2 DEFAULT NULL
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
    
    LV_LASTC1 GTT_GRATUITYWORKSHEET%ROWTYPE;
    
    LV_LAST_TOKENNO VARCHAR2(100);
    LV_LAST_CATEGORY VARCHAR2(100);
--    LV_SQLSTRNEW           VARCHAR2(9000);

BEGIN

    LV_LAST_TOKENNO := NULL;
    LV_LAST_CATEGORY := NULL; 

      --THIS LINE FOR GPS_ERROR_LOG
--    LV_SQLSTR := 'PROC_RPT_GRATUITYWORKSHT_EXL('''||P_COMPANYCODE||''','''||P_DIVISIONCODE||''','''||P_YEARCODE||''','''||P_YEARMONTH||''')';
     
     
     LV_SQLSTR := NULL; 

    SELECT COMPANYNAME, DIVISIONNAME 
    INTO LV_COMPANYNAME, LV_DIVISIONNAME
    FROM COMPANYMAST C, DIVISIONMASTER D
    WHERE D.COMPANYCODE=C.COMPANYCODE
    AND C.COMPANYCODE=P_COMPANYCODE
    AND D.DIVISIONCODE=P_DIVISIONCODE;
    
            
    DELETE FROM GTT_GRATUITYWORKSHEET WHERE 1=1;
    
    LV_SQLSTR := NULL;
    LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_GRATUITYWORKSHEET' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, WORKERNAME, PFMEMBERSHIPDATE, DATEOFTERMINATION, ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    CALENDARYEAR, STRIKE_DAYS, ATTENDANCE, STL, AUTHORIZEDLEAVE, ESI, TOTAL, YESNO, GRATURITYENTILE, ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SERVICE_PERIOD, SERVICE_YEAR, GRATURITYYEARS, NONGRATURITYYEARS' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'SELECT COMPANYCODE, DIVISIONCODE, A.WORKERSERIAL, A.TOKENNO, WORKERNAME,PFMEMBERSHIPDATE,DATEOFTERMINATION,' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'CALENDARYEAR,B.STRIKE_DAYS, ATTENDANCE,STL,AUTHORIZEDLEAVE,ESI,TOTAL,YESNO,GRATURITYENTILE,' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'FN_DATEDIFF(TO_CHAR(PFMEMBERSHIPDATE,''DD/MM/YYYY''), TO_CHAR(DATEOFTERMINATION,''DD/MM/YYYY'')) SERVICE_PERIOD,' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'SERVICE_YEAR,GRATURITYYEARS,(SERVICE_YEAR - GRATURITYYEARS) NONGRATURITYYEARS' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || ' FROM ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, WORKERNAME,' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    NVL(GRATUITYJOINDATE, PFMEMBERSHIPDATE) PFMEMBERSHIPDATE,DATEOFTERMINATION,TRUNC(MONTHS_BETWEEN(DATEOFTERMINATION,NVL(GRATUITYJOINDATE, PFMEMBERSHIPDATE))/12)+1  SERVICE_YEAR ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    FROM WORKERVIEWGRATUITY' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    WHERE COMPANYCODE='''||P_COMPANYCODE||'''' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND DIVISIONCODE ='''||P_DIVISIONCODE||'''' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    --AND UNITCODE=''''' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '--    AND CATEGORYCODE=''B''' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    --AND GRADECODE=''''' || CHR(10);
    
    IF  P_WORKERSERIAL IS NOT NULL THEN
--        LV_SQLSTR := LV_SQLSTR || '    AND WORKERSERIAL IN ('|| P_WORKERSERIAL ||')' || CHR(10);
        LV_SQLSTR := LV_SQLSTR || '    AND TOKENNO IN ('|| P_WORKERSERIAL ||')' || CHR(10);
    END IF;
    
        
    IF  P_UNIT IS NOT NULL THEN
        LV_SQLSTR := LV_SQLSTR || '    AND UNITCODE IN ('|| P_UNIT ||')' || CHR(10);
    END IF;
    
    IF  P_CATEGORY IS NOT NULL THEN
        LV_SQLSTR := LV_SQLSTR || '    AND CATEGORYCODE IN ('|| P_CATEGORY ||')' || CHR(10);
    END IF;
    
    IF  P_GRADE IS NOT NULL THEN
        LV_SQLSTR := LV_SQLSTR || '    AND GRADECODE IN ('|| P_GRADE ||')' || CHR(10);
    END IF;
    
    
    LV_SQLSTR := LV_SQLSTR || '--    AND TOKENNO=''04053''' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || ') A,' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SELECT TOKENNO,WORKERSERIAL, CALENDARYEAR,ADJUSTMENT STRIKE_DAYS, ATTENDANCE,STL,AUTHORIZEDLEAVE,ESI,TOTAL,' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    CASE WHEN (TOTAL >= 240) THEN ''YES'' ELSE ''NO'' END YESNO,' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    DECODE(GRATURITYENTILE,''Y'',''YES'',''NO'') GRATURITYENTILE ' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    FROM GRATUITYENTITLEMENTYEAR' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '--    WHERE TOKENNO=''04053''' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || ') B,' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SELECT WORKERSERIAL, COUNT(GRATURITYENTILE) GRATURITYYEARS' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    FROM GRATUITYENTITLEMENTYEAR' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    WHERE GRATURITYENTILE=''Y''' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    GROUP BY WORKERSERIAL' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || ') C' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'WHERE A.WORKERSERIAL=B.WORKERSERIAL' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.WORKERSERIAL=C.WORKERSERIAL' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'ORDER BY A.TOKENNO, CALENDARYEAR' || CHR(10);

    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);

    EXECUTE IMMEDIATE LV_SQLSTR ;




---START EXCEL REPORT GTT_EXCEL_REPORT

DELETE FROM GTT_EXCEL_REPORT WHERE 1=1;

    LV_ROWINDEX := 0;

    LV_EXCELROWSTYLE := NULL;
    
    LV_CHR := 'I'; -- EXCEL CELL REF

FOR C1 IN 
( 
    SELECT *
    FROM GTT_GRATUITYWORKSHEET 
    ORDER BY TOKENNO, CALENDARYEAR
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
    
        LV_EXCELVALUES := 'GRATUITY WORKING SHEET ';    
      
        
        LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~BORDER.BOTTOM.STYLE~THIN~HORIZONTALALIGNMENT~LEFT~VERTICALALIGNMENT~CENTER~FONT.BOLD~TRUE~FONT.SIZE~9~FONT.NAME~Tahoma';

        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
        
        LV_ROWINDEX := LV_ROWINDEX + 1;
        
    END IF;
    
    
    IF NVL(LV_LAST_TOKENNO,'NA') <> C1.TOKENNO THEN
     
        IF LV_LAST_TOKENNO IS NOT NULL THEN
            LV_EXCELROWTYPE := 'COLUMNVALUE';
            FOR C2 IN 
            ( 
                SELECT TOTAL_NO, GR_TOTAL_NO,SERVICE_PERIOD, SERVICE_YEAR, GRATURITYYEARS, NONGRATURITYYEARS 
                FROM (
                    SELECT COUNT(TOKENNO) TOTAL_NO
                    FROM GTT_GRATUITYWORKSHEET
                    WHERE TOKENNO= LV_LAST_TOKENNO
                    AND YESNO='YES'
                ) A,(
                    SELECT COUNT(TOKENNO) GR_TOTAL_NO
                    FROM GTT_GRATUITYWORKSHEET
                    WHERE TOKENNO= LV_LAST_TOKENNO
                    AND GRATURITYENTILE='YES'
                ) B,
                (
                    SELECT SERVICE_PERIOD, SERVICE_YEAR, GRATURITYYEARS, NONGRATURITYYEARS
                    FROM GTT_GRATUITYWORKSHEET
                    WHERE TOKENNO= LV_LAST_TOKENNO
                    AND ROWNUM=1
                )C
                WHERE 1=1
            )
            LOOP

                LV_EXCELVALUES :=  'TOTAL~FONT.SIZE~10~FONT.BOLD~TRUE~HORIZONTALALIGNMENT~LEFT^^NO. OF YES COUNTS^^^^^'||C2.TOTAL_NO||'~FONT.SIZE~10~FONT.BOLD~TRUE~HORIZONTALALIGNMENT~LEFT~NUMBERFORMAT~##^'||C2.GR_TOTAL_NO||'~FONT.SIZE~10~FONT.BOLD~TRUE~HORIZONTALALIGNMENT~LEFT~NUMBERFORMAT~##';

                LV_EXCELROWSTYLE := 'MERGE~C'||LV_ROWINDEX||':G'||LV_ROWINDEX||'~FONT.SIZE~10~HORIZONTALALIGNMENT~CENTRE~FONT.BOLD~TRUE~RANGE~I'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~FONT.SIZE~10~FONT.BOLD~TRUE~HORIZONTALALIGNMENT~CENTRE~NUMBERFORMAT~##';

                PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
                LV_ROWINDEX := LV_ROWINDEX + 1;
                 



                LV_EXCELVALUES := 'Period of Service :^^'||C2.SERVICE_PERIOD||'^^^^^^';
                
                LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':B'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~LEFT~MERGE~C'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~HORIZONTALALIGNMENT~LEFT';

                PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

                LV_ROWINDEX := LV_ROWINDEX + 1;


                LV_EXCELVALUES := 'Service Years:^^'||C2.SERVICE_YEAR||'^^^^^^';
                
                LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':B'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~LEFT~MERGE~C'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~HORIZONTALALIGNMENT~LEFT';

                PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

                LV_ROWINDEX := LV_ROWINDEX + 1;


                LV_EXCELVALUES := 'Gratuity Years:^^'||C2.GRATURITYYEARS||'^^^^^^';
                
                LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':B'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~LEFT~MERGE~C'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~HORIZONTALALIGNMENT~LEFT';

                PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

                LV_ROWINDEX := LV_ROWINDEX + 1;


                LV_EXCELVALUES := 'Non Cont. Service Years:^^'||C2.NONGRATURITYYEARS||'^^^^^^';
                
                 LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':B'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~LEFT~MERGE~C'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~HORIZONTALALIGNMENT~LEFT';

                PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

                LV_ROWINDEX := LV_ROWINDEX + 1;



                LV_LAST_CATEGORY := NULL;


            END LOOP;
            

        END IF;
    
    
    
        LV_EXCELROWTYPE := 'COLUMNHEADER';
        
        LV_EXCELVALUES := '^^^^^^^^';
        
        LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~HORIZONTALALIGNMENT~CENTERCONTINUOUS';

        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

        LV_ROWINDEX := LV_ROWINDEX + 1;

--
--        LV_EXCELVALUES := C1.UNITSHORTDESC||'^^^^STAFF/SUB_STAFF EPS STATEMENT^^^^^MONTH:^'||TO_CHAR(TO_DATE(P_FROMDATE,'YYYYMM'),'MON-YYYY')||'^';
--        
--        LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':D'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~CENTERCONTINUOUS~MERGE~E'||LV_ROWINDEX||':I'||LV_ROWINDEX
--        ||'~HORIZONTALALIGNMENT~CENTERCONTINUOUS~MERGE~K'||LV_ROWINDEX||':L'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~CENTERCONTINUOUS';
--        
--        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
--
--        LV_ROWINDEX := LV_ROWINDEX + 1;
--


        LV_EXCELVALUES := 'Name^'||C1.WORKERNAME||'^^^^^^^';
        
        LV_EXCELROWSTYLE := 'MERGE~B'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~HORIZONTALALIGNMENT~LEFT';

        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

        LV_ROWINDEX := LV_ROWINDEX + 1;

        LV_EXCELVALUES := 'Token No^'||C1.TOKENNO||'^^^^^^^^';
        
        LV_EXCELROWSTYLE := 'MERGE~B'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~HORIZONTALALIGNMENT~LEFT';

        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

        LV_ROWINDEX := LV_ROWINDEX + 1;



        LV_EXCELVALUES := 'DOJ^'||TO_CHAR(C1.PFMEMBERSHIPDATE,'DD/MM/YYYY')||'^^^^^^^^';
        
        LV_EXCELROWSTYLE := 'MERGE~B'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~HORIZONTALALIGNMENT~LEFT';

        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

        LV_ROWINDEX := LV_ROWINDEX + 1;


        LV_EXCELVALUES := 'SUP ON^'||TO_CHAR(C1.DATEOFTERMINATION,'DD/MM/YYYY')||'^^^^^^^^';
        
        LV_EXCELROWSTYLE := 'MERGE~B'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~HORIZONTALALIGNMENT~LEFT';

        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

        LV_ROWINDEX := LV_ROWINDEX + 1;


        LV_EXCELVALUES := '^^^^^^^^^^';
        
        LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~HORIZONTALALIGNMENT~LEFT';

        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

        LV_ROWINDEX := LV_ROWINDEX + 1;


--        LV_EXCELVALUES := 'YEAR^STRIKE DAYS^ACT. WKG DAYS^STL AVAILED DAYS^AL DAYS^SL DAYS^TOTAL DAYS^240 Days YES/NO^GRATUITY ENTITLEMENT YEARS';
--     
----        LV_EXCELROWSTYLE := 'RANGE~A'||LV_ROWINDEX||':I'||LV_ROWINDEX||'~BORDER.BOTTOM.STYLE~THIN~HORIZONTALALIGNMENT~CENTERCONTINUOUS~VERTICALALIGNMENT~CENTER~FONT.SIZE~10';

--        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

--        LV_ROWINDEX := LV_ROWINDEX + 1;
--        
--        

        LV_EXCELVALUES := 'YEAR^STRIKE^ACT.^STL^AL DAYS^SL^TOTAL^240^GRATUITY';
     
        LV_EXCELROWSTYLE := 'RANGE~A'||LV_ROWINDEX||':I'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~CENTERCONTINUOUS~VERTICALALIGNMENT~CENTER~FONT.SIZE~10';

        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

        LV_ROWINDEX := LV_ROWINDEX + 1;
        
        
        LV_EXCELVALUES := '^DAYS^WKG^AVAILED^DAYS^DAYS^DAYS^Days^ENTITLEMENT';
        
        LV_EXCELROWSTYLE := 'RANGE~A'||LV_ROWINDEX||':I'||LV_ROWINDEX||'~BORDER.BOTTOM.STYLE~THIN~HORIZONTALALIGNMENT~CENTERCONTINUOUS~VERTICALALIGNMENT~CENTER~FONT.SIZE~10';

        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

        LV_ROWINDEX := LV_ROWINDEX + 1;
        
        
        LV_EXCELVALUES := '^^DAYS^DAYS^^^^YES/NO^YEARS';
     
--        LV_EXCELROWSTYLE := 'RANGE~A'||LV_ROWINDEX||':I'||LV_ROWINDEX||'~BORDER.BOTTOM.STYLE~THIN~HORIZONTALALIGNMENT~CENTERCONTINUOUS~VERTICALALIGNMENT~CENTER~FONT.SIZE~10';
        LV_EXCELROWSTYLE := 'RANGE~A'||LV_ROWINDEX||':I'||LV_ROWINDEX||'~BORDER.BOTTOM.STYLE~DOUBLE~HORIZONTALALIGNMENT~CENTERCONTINUOUS~VERTICALALIGNMENT~CENTER~FONT.SIZE~10';

        PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

        LV_ROWINDEX := LV_ROWINDEX + 1;
        
    END IF;
   
    LV_EXCELROWTYPE := 'COLUMNVALUE';

    LV_EXCELVALUES := 'YEAR^STRIKE DAYS^ACT. WKG DAYS^STL AVAILED DAYS^AL DAYS^SL DAYS^TOTAL DAYS^240 Days YES/NO^GRATUITY ENTITLEMENT YEARS';
     
    LV_EXCELVALUES := 'Y'||C1.CALENDARYEAR||'^'||C1.STRIKE_DAYS||'^'||C1.ATTENDANCE||'^'||C1.STL
    ||'^'||C1.AUTHORIZEDLEAVE||'^'||C1.ESI||'^'||C1.TOTAL||'^'||C1.YESNO||'^'||C1.GRATURITYENTILE;

    LV_EXCELROWSTYLE := 'RANGE~B'||LV_ROWINDEX||':G'||LV_ROWINDEX||'~FONT.SIZE~10~HORIZONTALALIGNMENT~RIGHT~NUMBERFORMAT~##,##,##0.00';
    
    PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
    
    LV_LASTC1 :=C1;
    LV_LAST_TOKENNO := C1.TOKENNO;
--    LV_LAST_CATEGORY := C1.CATEGORYCODE;
END LOOP;

    LV_ROWINDEX := LV_ROWINDEX + 1;
     IF LV_LAST_TOKENNO IS NOT NULL THEN
            LV_EXCELROWTYPE := 'COLUMNVALUE';
            FOR C2 IN 
            ( 
                SELECT TOTAL_NO, GR_TOTAL_NO,SERVICE_PERIOD, SERVICE_YEAR, GRATURITYYEARS, NONGRATURITYYEARS 
                FROM (
                    SELECT COUNT(TOKENNO) TOTAL_NO
                    FROM GTT_GRATUITYWORKSHEET
                    WHERE TOKENNO= LV_LAST_TOKENNO
                    AND YESNO='YES'
                ) A,(
                    SELECT COUNT(TOKENNO) GR_TOTAL_NO
                    FROM GTT_GRATUITYWORKSHEET
                    WHERE TOKENNO= LV_LAST_TOKENNO
                    AND GRATURITYENTILE='YES'
                ) B,
                (
                    SELECT SERVICE_PERIOD, SERVICE_YEAR, GRATURITYYEARS, NONGRATURITYYEARS
                    FROM GTT_GRATUITYWORKSHEET
                    WHERE TOKENNO= LV_LAST_TOKENNO
                    AND ROWNUM=1
                )C
                WHERE 1=1
            )
            LOOP

                LV_EXCELVALUES :=  'TOTAL~FONT.SIZE~10~FONT.BOLD~TRUE~HORIZONTALALIGNMENT~LEFT^^NO. OF YES COUNTS^^^^^'||C2.TOTAL_NO||'~FONT.SIZE~10~FONT.BOLD~TRUE~HORIZONTALALIGNMENT~LEFT~NUMBERFORMAT~##^'||C2.GR_TOTAL_NO||'~FONT.SIZE~10~FONT.BOLD~TRUE~HORIZONTALALIGNMENT~LEFT~NUMBERFORMAT~##';

                LV_EXCELROWSTYLE := 'MERGE~C'||LV_ROWINDEX||':G'||LV_ROWINDEX||'~FONT.SIZE~10~HORIZONTALALIGNMENT~CENTER~FONT.BOLD~TRUE~RANGE~I'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~FONT.SIZE~10~FONT.BOLD~TRUE~HORIZONTALALIGNMENT~CENTRE~NUMBERFORMAT~##';

                PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);
                LV_ROWINDEX := LV_ROWINDEX + 1;
                 



                LV_EXCELVALUES := 'Period of Service :^^'||C2.SERVICE_PERIOD||'^^^^^^';
                
                LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':B'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~LEFT~MERGE~C'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~HORIZONTALALIGNMENT~LEFT';

                PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

                LV_ROWINDEX := LV_ROWINDEX + 1;


                LV_EXCELVALUES := 'Service Years:^^'||C2.SERVICE_YEAR||'^^^^^^';
                
                LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':B'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~LEFT~MERGE~C'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~HORIZONTALALIGNMENT~LEFT';

                PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

                LV_ROWINDEX := LV_ROWINDEX + 1;


                LV_EXCELVALUES := 'Gratuity Years:^^'||C2.GRATURITYYEARS||'^^^^^^';
                
                LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':B'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~LEFT~MERGE~C'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~HORIZONTALALIGNMENT~LEFT';

                PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

                LV_ROWINDEX := LV_ROWINDEX + 1;


                LV_EXCELVALUES := 'Non Cont. Service Years:^^'||C2.NONGRATURITYYEARS||'^^^^^^';
                
                 LV_EXCELROWSTYLE := 'MERGE~A'||LV_ROWINDEX||':B'||LV_ROWINDEX||'~HORIZONTALALIGNMENT~LEFT~MERGE~C'||LV_ROWINDEX||':'||LV_CHR||LV_ROWINDEX||'~HORIZONTALALIGNMENT~LEFT';

                PROC_INSERT_EXCEL_REPORT(LV_ROWINDEX, LV_EXCELROWTYPE, LV_EXCELROWSTYLE, LV_EXCELVALUES, LV_EXCELTAG);

                LV_ROWINDEX := LV_ROWINDEX + 1;



                LV_LAST_CATEGORY := NULL;


            END LOOP;
            

        END IF;
    

END;
/
