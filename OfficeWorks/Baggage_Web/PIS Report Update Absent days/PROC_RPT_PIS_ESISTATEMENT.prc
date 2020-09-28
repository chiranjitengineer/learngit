CREATE OR REPLACE PROCEDURE BAGGAGE_WEB.PROC_RPT_PIS_ESISTATEMENT
(
    P_COMPANYCODE         VARCHAR2,
    P_DIVISIONCODE        VARCHAR2,
    P_YEARCODE            VARCHAR2,
    P_YEARMONTH           VARCHAR2,
    P_UNIT                VARCHAR2 DEFAULT NULL,
    P_CATEGORY            VARCHAR2 DEFAULT NULL,
    P_GRADE               VARCHAR2 DEFAULT NULL,
    P_WORKERSERIAL        VARCHAR2 DEFAULT NULL,
    P_STATE               VARCHAR2 DEFAULT NULL ,
    P_FILE                VARCHAR2
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
    LV_DAYS             NUMBER := 0; 
    LV_ESI_E             NUMBER := 0;
    LV_ESI_C             NUMBER := 0;
    LV_ESI_GROSS             NUMBER := 0;
    LV_SQLSTR             VARCHAR2(5000);
     
BEGIN
  

    SELECT TRIM(TO_CHAR(TO_DATE(P_YEARMONTH,'YYYYMM'),'MONTH')), 
    TO_CHAR(TO_DATE(P_YEARMONTH,'YYYYMM'),'YYYY') ,'Printed On : '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:ss')
    INTO LV_MONTH, LV_YEAR,LV_PRINTDATE  FROM  DUAL;


    SELECT COMPANYNAME, DIVISIONNAME 
    INTO LV_COMPANYNAME,LV_DIVISIONNAME
    FROM COMPANYMAST CM, DIVISIONMASTER DM                      
    WHERE CM.COMPANYCODE=DM.COMPANYCODE
    AND CM.COMPANYCODE=P_COMPANYCODE
    AND DM.DIVISIONCODE= P_DIVISIONCODE;
                         
  
  
   
   
    LV_RPT_CAPTION:= 'ESI STATEMENT FOR THE MONTH OF '||LV_MONTH||', '|| LV_YEAR;


    AS_XLSX.CLEAR_WORKBOOK;
    AS_XLSX.NEW_SHEET;

    -- Set column Width
    AS_XLSX.SET_COLUMN_WIDTH(1,7,1);
    AS_XLSX.SET_COLUMN_WIDTH(2,10,1);
    AS_XLSX.SET_COLUMN_WIDTH(3,25,1);
    AS_XLSX.SET_COLUMN_WIDTH(4,15,1);
--    AS_XLSX.SET_COLUMN_WIDTH(5,25,1);
    AS_XLSX.SET_COLUMN_WIDTH(6,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(7,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(8,15,1);
                                                       
    AS_XLSX.MERGECELLS(1, 1, 8, 1, 1);   
    AS_XLSX.CELL( 1, 1, LV_COMPANYNAME || ' ('|| LV_DIVISIONNAME  || ')' , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA',p_BOLD => TRUE) );              --,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )             


    AS_XLSX.MERGECELLS(1, 2, 8, 2, 1);   
    AS_XLSX.CELL( 1, 2, LV_RPT_CAPTION , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
    --AS_XLSX.FREEZE_PANE(2, 5);

    AS_XLSX.CELL( 1, 3, LV_PRINTDATE , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'right' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
    AS_XLSX.MERGECELLS(1, 3, 8, 3, 1);   

    AS_XLSX.CELL( 1, 4,'SL.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', '', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 1, 5, '', P_BORDERID => AS_XLSX.GET_BORDER( '','double','thin', 'thin' ) );   
    --AS_XLSX.MERGECELLS(1, 4, 1, 5, 1);   
    AS_XLSX.CELL( 2, 4,'EB-NO', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', '', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 2, 5, '', P_BORDERID => AS_XLSX.GET_BORDER( '','double','thin', 'thin' ) );  
    AS_XLSX.CELL( 3, 4,'NAME', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', '', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 3, 5, '', P_BORDERID => AS_XLSX.GET_BORDER( '','double','thin', 'thin' ) ); 
    AS_XLSX.CELL( 4, 4,'ESI.NO', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', '', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 4, 5, '', P_BORDERID => AS_XLSX.GET_BORDER( '','double','thin', 'thin' ) ); 
    AS_XLSX.CELL( 5, 4,'DAYS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', '', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 5, 5, '', P_BORDERID => AS_XLSX.GET_BORDER( '','double','thin', 'thin' ) ); 
    AS_XLSX.CELL( 6, 4,'EMPLOYEE', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', '', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 6, 5,'CONT.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( '', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    --AS_XLSX.CELL( 6, 5, '', P_BORDERID => AS_XLSX.GET_BORDER( '','double','thin', 'thin' ) ); 
    AS_XLSX.CELL( 7, 4,'EMPLOYER', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', '', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 7, 5,'CONT.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( '', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
   
    AS_XLSX.CELL( 8, 4,'E.S.I', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', '', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 8, 5,'GROSS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( '', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    --AS_XLSX.MERGECELLS(8, 4, 8, 5, 1); 
    
    LV_ROWNUM := 5;

DELETE FROM GTT_ESISTATEMENT WHERE 1=1;

LV_SQLSTR := NULL;
LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_ESISTATEMENT (SLNO, TOKENNO, WORKERSERIAL, EMPLOYEENAME, ESINO, ATTN_SALD, ESI_E, ESI_C, ESI_GROSS)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'SELECT ROW_NUMBER() OVER (ORDER BY A.TOKENNO) SLNO,A.TOKENNO, A.WORKERSERIAL, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'A.EMPLOYEENAME, ESINO, NVL(ATTN_SALD,0) ATTN_SALD, NVL(ESI_E,0) ESI_E, NVL(ESI_C,0) ESI_C, NVL(ESI_GROSS,0)  ESI_GROSS' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'FROM PISEMPLOYEEMASTER  A, --PISPAYTRANSACTION B' || CHR(10);

LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    SELECT  COMPANYCODE, DIVISIONCODE, TOKENNO, WORKERSERIAL, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    NVL(ATTN_SALD,0) ATTN_SALD, NVL(ESI_E,0) ESI_E, NVL(ESI_C,0) ESI_C, NVL(ESI_GROSS,0)  ESI_GROSS' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    FROM PISPAYTRANSACTION' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    WHERE YEARMONTH ='''||P_YEARMONTH||''' ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND NVL(ESI_GROSS,0) > 0' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND (NVL(ESI_E,0)+NVL(ESI_C,0)) > 0' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ') B' || CHR(10);





LV_SQLSTR := LV_SQLSTR || 'WHERE A.COMPANYCODE=B.COMPANYCODE (+)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'AND A.DIVISIONCODE=B.DIVISIONCODE (+)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'AND A.WORKERSERIAL=B.WORKERSERIAL  (+)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'AND A.COMPANYCODE='''||P_COMPANYCODE ||'''' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'AND A.DIVISIONCODE='''||P_DIVISIONCODE ||'''' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || 'AND (NVL(ESI_E,0)+NVL(ESI_C,0)) > 0' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || 'AND B.YEARMONTH='''||P_YEARMONTH||''' and NVL(ESI_GROSS,0) > 0' || CHR(10);

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

IF P_STATE IS NOT NULL THEN
    LV_SQLSTR := LV_SQLSTR || 'AND A.PTAXSTATE  IN ('||P_STATE||')   ' || CHR(10);
END IF;

LV_SQLSTR := LV_SQLSTR || 'ORDER BY A.TOKENNO' || CHR(10);

DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);

EXECUTE IMMEDIATE LV_SQLSTR;

    FOR C1 IN (  
        SELECT SLNO, TOKENNO, WORKERSERIAL, EMPLOYEENAME, ESINO, ATTN_SALD, ESI_E, ESI_C, ESI_GROSS
        FROM GTT_ESISTATEMENT     
    )
    LOOP

        LV_ROWNUM := LV_ROWNUM+1;
        
--        AS_XLSX.CELL( 1, LV_ROWNUM, C1.SLNO, P_BORDERID => AS_XLSX.GET_BORDER( '','double','', '' ) );
--        AS_XLSX.CELL( 2, LV_ROWNUM,C1.TOKENNO, P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'double', 'double' ) );
--        AS_XLSX.CELL( 3, LV_ROWNUM,C1.EMPLOYEENAME, P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'double', 'double' ) );
--        AS_XLSX.CELL( 4, LV_ROWNUM,C1.ESINO, P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'double', 'double' ) );
--        AS_XLSX.CELL( 5, LV_ROWNUM,C1.ATTN_SALD, P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'double', 'double' ) );
--        AS_XLSX.CELL( 6, LV_ROWNUM,C1.ESI_E, P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'double', 'double' ) );
--        AS_XLSX.CELL( 7, LV_ROWNUM,C1.ESI_C, P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'double', 'double' ) );
--        AS_XLSX.CELL( 8, LV_ROWNUM,C1.ESI_GROSS, P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'double', 'double' ) );
--        
        
        AS_XLSX.CELL( 1, LV_ROWNUM, C1.SLNO, P_BORDERID => AS_XLSX.GET_BORDER( '','thin','', 'thin' ) );
        AS_XLSX.CELL( 2, LV_ROWNUM,C1.TOKENNO, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 3, LV_ROWNUM,C1.EMPLOYEENAME, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 4, LV_ROWNUM,C1.ESINO, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 5, LV_ROWNUM,C1.ATTN_SALD, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 6, LV_ROWNUM,C1.ESI_E, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 7, LV_ROWNUM,C1.ESI_C, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 8, LV_ROWNUM,C1.ESI_GROSS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        
        LV_DAYS    :=   LV_DAYS + C1.ATTN_SALD;
        LV_ESI_E      :=   LV_ESI_E + C1.ESI_E; 
        LV_ESI_C       :=   LV_ESI_C + C1.ESI_C;
        LV_ESI_GROSS   :=   LV_ESI_GROSS + C1.ESI_GROSS;
   END LOOP;       
   
   LV_ESI_C := CEIL(LV_ESI_GROSS*0.0325);
     LV_ROWNUM := LV_ROWNUM + 1;
     
        AS_XLSX.CELL( 1, LV_ROWNUM, 'TOTAL', P_BORDERID => AS_XLSX.GET_BORDER( 'double','double','', '' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
        AS_XLSX.CELL( 2, LV_ROWNUM,'', P_BORDERID => AS_XLSX.GET_BORDER( 'double','double','', '' ) );
        AS_XLSX.CELL( 3, LV_ROWNUM,'', P_BORDERID => AS_XLSX.GET_BORDER( 'double','double','', '' ) );
        AS_XLSX.CELL( 4, LV_ROWNUM,'', P_BORDERID => AS_XLSX.GET_BORDER( 'double','double','', '' ) );
        AS_XLSX.CELL( 5, LV_ROWNUM, LV_DAYS, P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
        AS_XLSX.CELL( 6, LV_ROWNUM,LV_ESI_E, P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
        AS_XLSX.CELL( 7, LV_ROWNUM,LV_ESI_C, P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
        AS_XLSX.CELL( 8, LV_ROWNUM,LV_ESI_GROSS, P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
        AS_XLSX.MERGECELLS(1, LV_ROWNUM, 4, LV_ROWNUM, 1);  
        
        
    AS_XLSX.SAVE( L_DIR, L_FILE );
END;
/
