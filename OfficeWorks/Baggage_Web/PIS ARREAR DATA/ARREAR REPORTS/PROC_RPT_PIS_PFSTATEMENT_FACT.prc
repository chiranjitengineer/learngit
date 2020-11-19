CREATE OR REPLACE PROCEDURE BAGGAGE_WEB.PROC_RPT_PIS_PFSTATEMENT_FACT
(
    P_COMPANYCODE         VARCHAR2,
    P_DIVISIONCODE        VARCHAR2,
    P_YEARCODE            VARCHAR2,
    P_YEARMONTH           VARCHAR2,
    P_UNIT                VARCHAR2 DEFAULT NULL,
    P_CATEGORY            VARCHAR2 DEFAULT NULL,
    P_GRADE               VARCHAR2 DEFAULT NULL,
    P_WORKERSERIAL        VARCHAR2 DEFAULT NULL,
    P_FILE                VARCHAR2,
    P_ISARREAR           VARCHAR2 DEFAULT 'N'  
)
AS
    LV_RPT_CAPTION        VARCHAR2(500);
    L_DIR                 VARCHAR2(10) := 'ORA_DIR';
    L_FILE                VARCHAR2(100) := P_FILE||'.xlsx'; 
    LV_ROWNUM             NUMBER := 0;
    LV_MONTH              VARCHAR2(15); 
    LV_YEAR              VARCHAR2(15); 
    LV_COMPANYNAME            VARCHAR2(100);   
    LV_DIVISIONNAME           VARCHAR2(100);    
    LV_PRINTDATE           VARCHAR2(100);  
    LV_TOT_PTAX             NUMBER := 0;  
    LV_TOT_TOTALEARN             NUMBER := 0; 
    LV_SQLSTR             VARCHAR2(5000);
    LV_DIVADDRESS            VARCHAR2(5000);
    LV_ERRORLOG            VARCHAR2(5000);
    
    LV_TRANS_TABLE            VARCHAR2(30);
BEGIN


    SELECT TRIM(TO_CHAR(TO_DATE(P_YEARMONTH,'YYYYMM'),'MONTH')), 
    TO_CHAR(TO_DATE(P_YEARMONTH,'YYYYMM'),'YYYY') ,'Run Date : '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:ss')
    INTO LV_MONTH, LV_YEAR,LV_PRINTDATE  FROM  DUAL;

    SELECT COMPANYNAME, DIVISIONNAME, COMPANYADDRESS 
    INTO LV_COMPANYNAME,LV_DIVISIONNAME,LV_DIVADDRESS
    FROM COMPANYMAST CM, DIVISIONMASTER DM                      
    WHERE CM.COMPANYCODE=DM.COMPANYCODE
    AND CM.COMPANYCODE=P_COMPANYCODE
    AND DM.DIVISIONCODE= P_DIVISIONCODE;
   
--    LV_RPT_CAPTION:= 'STATEMENT OF PF FOR THE MONTH OF '||LV_MONTH||', '|| LV_YEAR;
    IF P_ISARREAR = 'Y' THEN
        LV_TRANS_TABLE := 'PISARREARTRANSACTION';
        LV_RPT_CAPTION:= 'ARREAR STATEMENT OF PF FOR THE MONTH OF '||LV_MONTH||', '|| LV_YEAR;
    ELSE
        LV_TRANS_TABLE := 'PISPAYTRANSACTION';
        LV_RPT_CAPTION:= 'STATEMENT OF PF FOR THE MONTH OF '||LV_MONTH||', '|| LV_YEAR;
    END IF;


    AS_XLSX.CLEAR_WORKBOOK;
    AS_XLSX.NEW_SHEET;

    -- Set column Width
    AS_XLSX.SET_COLUMN_WIDTH(1,7,1);
    AS_XLSX.SET_COLUMN_WIDTH(2,10,1);
    AS_XLSX.SET_COLUMN_WIDTH(3,35,1);
    AS_XLSX.SET_COLUMN_WIDTH(4,20,1);
    AS_XLSX.SET_COLUMN_WIDTH(5,20,1);
    AS_XLSX.SET_COLUMN_WIDTH(6,20,1);
    AS_XLSX.SET_COLUMN_WIDTH(7,20,1);
    AS_XLSX.SET_COLUMN_WIDTH(8,20,1);
    AS_XLSX.SET_COLUMN_WIDTH(9,20,1);
--    AS_XLSX.SET_COLUMN_WIDTH(10,15,1);
    
    AS_XLSX.MERGECELLS(1, 1, 9, 1, 1);   
    AS_XLSX.CELL( 1, 1, LV_COMPANYNAME  , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA',p_BOLD => TRUE) );              --,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )             

    AS_XLSX.MERGECELLS(1, 2, 9, 2, 1);   
    AS_XLSX.CELL( 1, 2, LV_DIVADDRESS , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
    --AS_XLSX.FREEZE_PANE(2, 5);

    AS_XLSX.MERGECELLS(1, 3, 9, 3, 1);   
    AS_XLSX.CELL( 1, 3, LV_RPT_CAPTION , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
    --AS_XLSX.FREEZE_PANE(2, 5);


    AS_XLSX.CELL( 6, 4,'EMPLOYEE CONT.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'thin', 'double', 'double' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
   
    AS_XLSX.CELL( 7, 4,'EMPLOYER CONT.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'thin', 'double', 'double' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 8, 4,' ', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'thin', 'double', 'double' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    --AS_XLSX.FREEZE_PANE(2, 5);

    AS_XLSX.MERGECELLS(7, 4, 8, 4, 1);   
    


    AS_XLSX.CELL( 1, 5,'SL.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 2, 5,'EMP CODE', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 3, 5,'NAME', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 4, 5,'ACTUAL BASIC', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 5, 5,'EARNED BASIC', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    --AS_XLSX.CELL( 5, 5,'EPF GROSS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
 
    AS_XLSX.CELL( 6, 5,'PF @ 12%', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 7, 5,'PF @ 3.67%', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 8, 5,'PENSION @ 8.33%', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
--    AS_XLSX.CELL( 9, 5,'GROSS EARNINGS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
   
    AS_XLSX.CELL( 9, 5,'TOTAL @ 24%', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
   



    LV_ROWNUM := 5;
 
    DELETE FROM GTT_PFSTATEMENT WHERE 1=1;



    LV_SQLSTR := NULL;
    LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_PFSTATEMENT (SLNO, TOKENNO, WORKERSERIAL, EMPLOYEENAME, BASIC_RT, BASIC,PEN_GROSS, GROSSEARN, PF_12, PF_0367, PENSION_833, TOTAL_24)' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'SELECT ROW_NUMBER() OVER (ORDER BY A.TOKENNO) SLNO,A.TOKENNO, A.WORKERSERIAL, A.EMPLOYEENAME, ' || CHR(10);
--    LV_SQLSTR := LV_SQLSTR || 'ROUND(B.BASIC_RT,0) BASIC_RT, ROUND(B.BASIC,0) BASIC, ROUND(B.PEN_GROSS,0) PEN_GROSS, ROUND(B.GROSSEARN,0) GROSSEARN, ROUND(B.BASIC*0.12,0) PF_12, ROUND(B.BASIC*0.0367,0) PF_0367,  ROUND(B.BASIC*0.0833,0) PENSION_833, ROUND(B.BASIC*0.24,0) TOTAL_24' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'ROUND(B.BASIC_RT,0) BASIC_RT, ROUND(B.BASIC,0) BASIC, ROUND(B.PEN_GROSS,0) PEN_GROSS, ROUND(B.GROSSEARN,0) GROSSEARN, ROUND(B.PF_E,0) PF_12, ROUND(B.PF_C,0) PF_0367,  ROUND(B.FPF,0) PENSION_833, ROUND(B.PF_E*2,0) TOTAL_24' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'FROM PISEMPLOYEEMASTER  A, /*PISPAYTRANSACTION*/ (SELECT * FROM '||LV_TRANS_TABLE||' WHERE YEARMONTH = '''||P_YEARMONTH||''') B' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'WHERE A.COMPANYCODE=B.COMPANYCODE(+)' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.DIVISIONCODE=B.DIVISIONCODE(+)' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.WORKERSERIAL=B.WORKERSERIAL(+)' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND (A.EMPLOYEESTATUS=''ACTIVE'' OR A.STATUSDATE >= LAST_DAY(TO_DATE('''||P_YEARMONTH||''',''YYYYMM'')))' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.COMPANYCODE='''||P_COMPANYCODE ||'''' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.DIVISIONCODE='''||P_DIVISIONCODE||'''' || CHR(10);
--    LV_SQLSTR := LV_SQLSTR || 'AND B.YEARMONTH='''||P_YEARMONTH||'''' || CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND NVL(A.PFAPPLICABLE,''N'')=''Y''' || CHR(10);

    IF P_UNIT IS NOT NULL THEN
        LV_SQLSTR := LV_SQLSTR || 'AND A.UNITCODE IN ('||P_UNIT||') ' || CHR(10);
    END IF;

    IF P_CATEGORY IS NOT NULL THEN
        LV_SQLSTR := LV_SQLSTR || 'AND A.CATEGORYCODE IN ('||P_CATEGORY||') ' || CHR(10);
    END IF;

    IF P_GRADE IS NOT NULL THEN
        LV_SQLSTR := LV_SQLSTR || 'AND A.GRADECODE  IN ('||P_GRADE||')  ' || CHR(10);
    END IF;
    IF P_WORKERSERIAL IS NOT NULL THEN
        LV_SQLSTR := LV_SQLSTR || 'AND A.WORKERSERIAL  IN ('||P_WORKERSERIAL||')   ' || CHR(10);
    END IF;

    LV_SQLSTR := LV_SQLSTR || 'ORDER BY A.TOKENNO' || CHR(10);

    --DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);

    EXECUTE IMMEDIATE LV_SQLSTR;
     
    FOR C1 IN (  
        SELECT SLNO, TOKENNO, WORKERSERIAL, EMPLOYEENAME, ROUND(BASIC_RT,0) BASIC_RT, 
        ROUND(BASIC,0) BASIC,ROUND(PEN_GROSS,0) PEN_GROSS, ROUND(GROSSEARN,0) GROSSEARN, 
        ROUND(PF_12,0) PF_12, ROUND(PF_0367,0) PF_0367, ROUND(PENSION_833,0) PENSION_833, 
        ROUND(TOTAL_24,0) TOTAL_24
        FROM GTT_PFSTATEMENT     
    )
    LOOP
        LV_ROWNUM := LV_ROWNUM+1;
        
        AS_XLSX.CELL( 1, LV_ROWNUM, C1.SLNO, P_BORDERID => AS_XLSX.GET_BORDER( '','thin','', 'thin' ) );
        AS_XLSX.CELL( 2, LV_ROWNUM,C1.TOKENNO, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 3, LV_ROWNUM,C1.EMPLOYEENAME, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 4, LV_ROWNUM,C1.BASIC_RT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 5, LV_ROWNUM,C1.BASIC, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
--        AS_XLSX.CELL( 5, LV_ROWNUM,C1.PEN_GROSS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 6, LV_ROWNUM,C1.PF_12, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 7, LV_ROWNUM,C1.PF_0367, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 8, LV_ROWNUM,C1.PENSION_833, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 9, LV_ROWNUM,C1.TOTAL_24, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
--       AS_XLSX.CELL( 9, LV_ROWNUM,C1.GROSSEARN, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        
    END LOOP;       
   
    LV_ROWNUM := LV_ROWNUM + 1;  
    
    AS_XLSX.CELL( 1, LV_ROWNUM, 'TOTAL', P_BORDERID => AS_XLSX.GET_BORDER( 'double','double','', '' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 2, LV_ROWNUM,'', P_BORDERID => AS_XLSX.GET_BORDER( 'double','double','', '' ) );
    AS_XLSX.CELL( 3, LV_ROWNUM,'', P_BORDERID => AS_XLSX.GET_BORDER( 'double','double','', '' ) );
    AS_XLSX.MERGECELLS(1, LV_ROWNUM, 3, LV_ROWNUM, 1);  
  

    FOR C2 IN (  
        SELECT ROUND(SUM(BASIC_RT),0) BASIC_RT, ROUND(SUM(BASIC),0) BASIC,
        ROUND(SUM(PEN_GROSS),0) PEN_GROSS, ROUND(SUM(GROSSEARN),0) GROSSEARN, ROUND(SUM(PF_12),0) PF_12, 
        ROUND(SUM(PF_0367),0) PF_0367, ROUND(SUM(PENSION_833),0) PENSION_833, ROUND(SUM(TOTAL_24),0) TOTAL_24 FROM GTT_PFSTATEMENT     
    )
    LOOP
        AS_XLSX.CELL( 4, LV_ROWNUM,C2.BASIC_RT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 5, LV_ROWNUM,C2.BASIC, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
--        AS_XLSX.CELL( 5, LV_ROWNUM,C2.PEN_GROSS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 6, LV_ROWNUM,C2.PF_12, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 7, LV_ROWNUM,C2.PF_0367, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 8, LV_ROWNUM,C2.PENSION_833, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
--        AS_XLSX.CELL( 9, LV_ROWNUM,C2.GROSSEARN, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 9, LV_ROWNUM,C2.TOTAL_24, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
    END LOOP;    



    LV_ROWNUM := LV_ROWNUM + 1;  
    AS_XLSX.CELL( 1, LV_ROWNUM, LV_PRINTDATE , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'left' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
    AS_XLSX.MERGECELLS(1, LV_ROWNUM, 9, LV_ROWNUM, 1);   
        
    AS_XLSX.SAVE( L_DIR, L_FILE );
END;
/