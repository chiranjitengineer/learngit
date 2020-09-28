CREATE OR REPLACE PROCEDURE BAGGAGE_WEB.PROC_RPT_PIS_NETSALARYREG
(
    P_COMPANYCODE         VARCHAR2,
    P_DIVISIONCODE        VARCHAR2,
    P_YEARCODE            VARCHAR2,
    P_YEARMONTH           VARCHAR2,
    P_UNIT                VARCHAR2 DEFAULT NULL,
    P_CATEGORY            VARCHAR2 DEFAULT NULL,
    P_GRADE               VARCHAR2 DEFAULT NULL,
    P_WORKERSERIAL        VARCHAR2 DEFAULT NULL,
    P_FILE                VARCHAR2 
)
AS
    LV_RPT_CAPTION        VARCHAR2(500);
    L_DIR                 VARCHAR2(10) := 'ORA_DIR';
    L_FILE                VARCHAR2(100) := P_FILE||'.xlsx'; 
    LV_ROWNUM             NUMBER := 0;
    LV_MONTH              VARCHAR2(15); 
    LV_YEAR               VARCHAR2(15); 
    LV_COMPANYNAME        VARCHAR2(100);   
    LV_DIVISIONNAME       VARCHAR2(100);    
    LV_PRINTDATE          VARCHAR2(100);  
    LV_NETSALARY           NUMBER(10,2);  
    LV_SQLSTR             VARCHAR2(5000);
    LV_COMPADDRESS            VARCHAR2(500);
    LV_FACTADDRESS            VARCHAR2(500);
     
BEGIN

    SELECT TRIM(TO_CHAR(TO_DATE(P_YEARMONTH,'YYYYMM'),'MONTH')), 
    TO_CHAR(TO_DATE(P_YEARMONTH,'YYYYMM'),'YYYY') ,'Run Date : '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:ss')
    INTO LV_MONTH, LV_YEAR,LV_PRINTDATE  FROM  DUAL;

    SELECT COMPANYNAME, DIVISIONNAME, COMPANYADDRESS, COMPANYADDRESS1 
    INTO LV_COMPANYNAME,LV_DIVISIONNAME,LV_COMPADDRESS,LV_FACTADDRESS
    FROM COMPANYMAST CM, DIVISIONMASTER DM                      
    WHERE CM.COMPANYCODE=DM.COMPANYCODE
    AND CM.COMPANYCODE=P_COMPANYCODE
    AND DM.DIVISIONCODE= P_DIVISIONCODE;
   
    LV_RPT_CAPTION:= 'NET SALARY PAYMENT FOR THE MONTH OF '||LV_MONTH||', '|| LV_YEAR;

    AS_XLSX.CLEAR_WORKBOOK;
    AS_XLSX.NEW_SHEET;

    -- Set column Width
    AS_XLSX.SET_COLUMN_WIDTH(1,7,1);
    AS_XLSX.SET_COLUMN_WIDTH(2,20,1);
    AS_XLSX.SET_COLUMN_WIDTH(3,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(4,35,1);
    AS_XLSX.SET_COLUMN_WIDTH(5,15,1);
    
    AS_XLSX.MERGECELLS(1, 1, 5, 1, 1);   
    AS_XLSX.CELL( 1, 1, LV_COMPANYNAME  , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA',p_BOLD => TRUE) );              --,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )             

    AS_XLSX.MERGECELLS(1, 2, 5, 2, 1);   
    AS_XLSX.CELL( 1, 2, LV_COMPADDRESS , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
    --AS_XLSX.FREEZE_PANE(2, 5);

    AS_XLSX.MERGECELLS(1, 3, 5, 3, 1);   
    AS_XLSX.CELL( 1, 3, LV_FACTADDRESS , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
  

    AS_XLSX.MERGECELLS(1, 4, 5, 4, 1);   
    AS_XLSX.CELL( 1, 4, LV_RPT_CAPTION , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )


    AS_XLSX.CELL( 1, 5,'SL.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 2, 5,'CATEGORY', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 3, 5,'TOKEN NO', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 4, 5,'NAME', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 5, 5,'NET PAYMENT', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    
    LV_ROWNUM := 5;
 
DELETE FROM GTT_NETSALARY WHERE 1=1;

LV_SQLSTR := NULL;
LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_NETSALARY (SLNO, TOKENNO, WORKERSERIAL, EMPLOYEENAME, CATEGORYCODE, CATEGORYDESC, NETSALARY)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'SELECT ROW_NUMBER() OVER (ORDER BY A.TOKENNO) SLNO,A.TOKENNO, A.WORKERSERIAL,A.EMPLOYEENAME, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'B.CATEGORYCODE,C.CATEGORYDESC, B.NETSALARY' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'FROM PISEMPLOYEEMASTER  A, /*PISPAYTRANSACTION*/ (SELECT * FROM PISPAYTRANSACTION WHERE YEARMONTH = '''||P_YEARMONTH||''') B, PISCATEGORYMASTER C' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'WHERE A.COMPANYCODE=B.COMPANYCODE(+)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'AND A.DIVISIONCODE=B.DIVISIONCODE(+)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'AND A.WORKERSERIAL=B.WORKERSERIAL (+)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'AND A.COMPANYCODE=C.COMPANYCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'AND A.DIVISIONCODE=C.DIVISIONCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'AND A.CATEGORYCODE=C.CATEGORYCODE ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'AND A.COMPANYCODE='''||P_COMPANYCODE ||'''' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'AND A.DIVISIONCODE='''||P_DIVISIONCODE||'''' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || 'AND B.YEARMONTH='''||P_YEARMONTH||'''' || CHR(10);

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
 
    LV_NETSALARY := 0;

    FOR C1 IN (  
        SELECT SLNO, TOKENNO, WORKERSERIAL, EMPLOYEENAME, CATEGORYCODE, CATEGORYDESC, NETSALARY
        FROM GTT_NETSALARY   
        ORDER BY TOKENNO  
    )
    LOOP
        LV_ROWNUM := LV_ROWNUM+1;
        
        AS_XLSX.CELL( 1, LV_ROWNUM, C1.SLNO, P_BORDERID => AS_XLSX.GET_BORDER( '','thin','', 'thin' ) );
        AS_XLSX.CELL( 2, LV_ROWNUM,C1.CATEGORYDESC, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 3, LV_ROWNUM,C1.TOKENNO, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 4, LV_ROWNUM,C1.EMPLOYEENAME, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 5, LV_ROWNUM,C1.NETSALARY, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
       
        LV_NETSALARY := LV_NETSALARY + C1.NETSALARY; 
    END LOOP;       
   
    LV_ROWNUM := LV_ROWNUM + 1;  
    
    AS_XLSX.CELL( 1, LV_ROWNUM, 'TOTAL', P_BORDERID => AS_XLSX.GET_BORDER( 'double','double','', '' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 2, LV_ROWNUM,'', P_BORDERID => AS_XLSX.GET_BORDER( 'double','double','', '' ) );
    AS_XLSX.CELL( 3, LV_ROWNUM,'', P_BORDERID => AS_XLSX.GET_BORDER( 'double','double','', '' ) );
    AS_XLSX.CELL( 4, LV_ROWNUM,'', P_BORDERID => AS_XLSX.GET_BORDER( 'double','double','', '' ) );
    AS_XLSX.MERGECELLS(1, LV_ROWNUM, 4, LV_ROWNUM, 1);  
    AS_XLSX.CELL( 5, LV_ROWNUM,LV_NETSALARY, P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
   
    LV_ROWNUM := LV_ROWNUM + 1;  
    AS_XLSX.CELL( 1, LV_ROWNUM, LV_PRINTDATE , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'left' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
    AS_XLSX.MERGECELLS(1, LV_ROWNUM, 5, LV_ROWNUM, 1);   
        
    AS_XLSX.SAVE( L_DIR, L_FILE );
END;
/