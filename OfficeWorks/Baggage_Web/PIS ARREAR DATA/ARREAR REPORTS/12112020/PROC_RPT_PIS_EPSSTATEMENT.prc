CREATE OR REPLACE PROCEDURE BAGGAGE_WEB.PROC_RPT_PIS_EPSSTATEMENT
(
    P_COMPANYCODE         VARCHAR2,
    P_DIVISIONCODE        VARCHAR2,
    P_YEARCODE            VARCHAR2,
    P_YEARMONTH           VARCHAR2,
    P_UNIT                VARCHAR2 DEFAULT NULL,
    P_CATEGORY            VARCHAR2 DEFAULT NULL,
    P_GRADE               VARCHAR2 DEFAULT NULL,
    P_WORKERSERIAL        VARCHAR2 DEFAULT NULL,
    P_FILE                VARCHAR2 ,
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
    LV_SQLSTR             VARCHAR2(5000);
    LV_ERRORLOG             VARCHAR2(5000);
    
    LV_TRANS_TABLE            VARCHAR2(30);
     
BEGIN
  


    LV_ERRORLOG := 'PROC_RPT_PIS_EPSSTATEMENT('''||P_COMPANYCODE||''','''||P_DIVISIONCODE||''','''||P_YEARCODE||''','''||P_YEARMONTH||''','''||P_UNIT||''','''||P_CATEGORY||''','''||P_GRADE||''','''||P_WORKERSERIAL||''','''||P_FILE||''')';
     
    DELETE FROM   PIS_ERROR_LOG
    WHERE PROC_NAME = 'PROC_RPT_PIS_EPSSTATEMENT';
    
    
    INSERT INTO PIS_ERROR_LOG
    (
        COMPANYCODE, DIVISIONCODE, ERROR_DATE, ERROR_QUERY, FORTNIGHTENDDATE, 
        FORTNIGHTSTARTDATE, ORA_ERROR_MESSG, PAR_VALUES, PROC_NAME, REMARKS
    )
    VALUES
    (
        P_COMPANYCODE,P_DIVISIONCODE,SYSDATE,LV_SQLSTR,TO_DATE(P_YEARMONTH,'YYYYMM'),
        TO_DATE(P_YEARMONTH,'YYYYMM'),'',LV_ERRORLOG,'PROC_RPT_PIS_EPSSTATEMENT','EXCEL FILE GENERATED'
    );


    SELECT TRIM(TO_CHAR(TO_DATE(P_YEARMONTH,'YYYYMM'),'MONTH')), 
    TO_CHAR(TO_DATE(P_YEARMONTH,'YYYYMM'),'YYYY') ,'Printed On : '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:ss')
    INTO LV_MONTH, LV_YEAR,LV_PRINTDATE  FROM  DUAL;


    SELECT COMPANYNAME, DIVISIONNAME 
    INTO LV_COMPANYNAME,LV_DIVISIONNAME
    FROM COMPANYMAST CM, DIVISIONMASTER DM                      
    WHERE CM.COMPANYCODE=DM.COMPANYCODE
    AND CM.COMPANYCODE=P_COMPANYCODE
    AND DM.DIVISIONCODE= P_DIVISIONCODE;
                         
  
  
    IF P_ISARREAR = 'Y' THEN
        LV_TRANS_TABLE := 'PISARREARTRANSACTION';
    ELSE
        LV_TRANS_TABLE := 'PISPAYTRANSACTION';
    END IF;

   
   
    LV_RPT_CAPTION:= 'EPS STATEMENT FOR THE MONTH OF '||LV_MONTH||', '|| LV_YEAR;

  
    IF P_ISARREAR = 'Y' THEN
        LV_TRANS_TABLE := 'PISARREARTRANSACTION';
        LV_RPT_CAPTION:= 'EPS ARREAR STATEMENT FOR THE MONTH OF '||LV_MONTH||', '|| LV_YEAR;
    ELSE
        LV_TRANS_TABLE := 'PISPAYTRANSACTION';
        LV_RPT_CAPTION:= 'EPS STATEMENT FOR THE MONTH OF '||LV_MONTH||', '|| LV_YEAR;
    END IF;

   

    AS_XLSX.CLEAR_WORKBOOK;
    AS_XLSX.NEW_SHEET;

    -- Set column Width
    AS_XLSX.SET_COLUMN_WIDTH(1,7,1);
    AS_XLSX.SET_COLUMN_WIDTH(2,10,1);
    AS_XLSX.SET_COLUMN_WIDTH(3,25,1);
    AS_XLSX.SET_COLUMN_WIDTH(4,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(5,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(6,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(7,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(8,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(9,15,1);
                                                       
    
    
    AS_XLSX.MERGECELLS(1, 1, 9, 1, 1);   
    AS_XLSX.CELL( 1, 1, LV_COMPANYNAME || ' ('|| LV_DIVISIONNAME  || ')' , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA',p_BOLD => TRUE) );              --,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )             


    AS_XLSX.MERGECELLS(1, 2, 9, 2, 1);   
    AS_XLSX.CELL( 1, 2, LV_RPT_CAPTION , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
    --AS_XLSX.FREEZE_PANE(2, 5);

    AS_XLSX.CELL( 1, 3, LV_PRINTDATE , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'right' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
    AS_XLSX.MERGECELLS(1, 3, 9, 3, 1);   

    AS_XLSX.CELL( 1, 4,'SL.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'thin', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 2, 4,'EB-NO', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', '', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 3, 4,'NAME', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', '', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 4, 4,'PENSION NO', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', '', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 5, 4,'PFGROSS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', '', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 6, 4,'PFDED', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', '', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 7, 4,'PENSIONGROSS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', '', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 8, 4,'PENSION', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', '', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 9, 4,'WORKINGDAYS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', '', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
   
    LV_ROWNUM := 4;

DELETE FROM GTT_EPSSTATEMENT WHERE 1=1;

LV_SQLSTR := NULL;
LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_EPSSTATEMENT (SLNO, TOKENNO, WORKERSERIAL, EMPLOYEENAME, PENSIONNO, PFGROSS, PFDED, PENSIONGROSS,PENSION, WORKINGDAYS)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'SELECT ROW_NUMBER() OVER (ORDER BY A.TOKENNO) SLNO,A.TOKENNO, A.WORKERSERIAL, ' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || 'A.EMPLOYEENAME, PENSIONNO, NVL(PF_GROSS,0) PFGROSS, ROUND(NVL(PF_GROSS,0)*0.0367,2) PFDED, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'A.EMPLOYEENAME, PENSIONNO, NVL(PF_GROSS,0) PFGROSS, NVL(PF_C,0) PFDED, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'NVL(PEN_GROSS,0)  PEN_GROSS,NVL(FPF,0) PENSION , NVL(ATTN_WRKD,0) WORKINGDAYS ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'FROM PISEMPLOYEEMASTER  A, --PISPAYTRANSACTION B' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(SELECT * FROM '||LV_TRANS_TABLE||' WHERE YEARMONTH = '''||P_YEARMONTH||''') B' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'WHERE A.COMPANYCODE=B.COMPANYCODE(+)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'AND A.DIVISIONCODE=B.DIVISIONCODE(+)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'AND A.WORKERSERIAL=B.WORKERSERIAL(+)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'AND (A.EMPLOYEESTATUS=''ACTIVE'' OR A.STATUSDATE >= LAST_DAY(TO_DATE('''||P_YEARMONTH||''',''YYYYMM'')))' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'AND A.COMPANYCODE='''||P_COMPANYCODE ||'''' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'AND A.DIVISIONCODE='''||P_DIVISIONCODE||'''' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || 'AND B.YEARMONTH='''||P_YEARMONTH||'''' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'AND NVL(A.EPFAPPLICABLE,''N'')=''Y''' || CHR(10);

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


IF P_ISARREAR = 'Y' THEN
    LV_SQLSTR:=LV_SQLSTR||'   AND B.TRANSACTIONTYPE=''ARREAR'''|| CHR(10);
END IF;


LV_SQLSTR := LV_SQLSTR || 'ORDER BY A.TOKENNO' || CHR(10);

DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);

EXECUTE IMMEDIATE LV_SQLSTR;
 
    FOR C1 IN (  
        SELECT SLNO, TOKENNO, EMPLOYEENAME, PENSIONNO, PFGROSS, PFDED, PENSIONGROSS,PENSION, WORKINGDAYS
        FROM GTT_EPSSTATEMENT     
    )
    LOOP

        LV_ROWNUM := LV_ROWNUM+1;
        
        
        AS_XLSX.CELL( 1, LV_ROWNUM, C1.SLNO, P_BORDERID => AS_XLSX.GET_BORDER( '','thin','', 'thin' ) );
        AS_XLSX.CELL( 2, LV_ROWNUM,C1.TOKENNO, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 3, LV_ROWNUM,C1.EMPLOYEENAME, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 4, LV_ROWNUM,C1.PENSIONNO, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 5, LV_ROWNUM,C1.PFGROSS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 6, LV_ROWNUM,C1.PFDED, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 7, LV_ROWNUM,C1.PENSIONGROSS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 8, LV_ROWNUM,C1.PENSION, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 9, LV_ROWNUM,C1.WORKINGDAYS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
       
   END LOOP;       
   
   
    FOR C1 IN (  
        SELECT  SUM(PFGROSS) PFGROSS,SUM(PFDED)  PFDED,SUM(PENSIONGROSS)  PENSIONGROSS,SUM(PENSION) PENSION,SUM(WORKINGDAYS)  WORKINGDAYS
        FROM GTT_EPSSTATEMENT     
    )
    LOOP

        LV_ROWNUM := LV_ROWNUM+1;
        
        AS_XLSX.CELL( 1, LV_ROWNUM, 'TOTAL', P_BORDERID => AS_XLSX.GET_BORDER( '','thin','', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
        AS_XLSX.CELL( 2, LV_ROWNUM,'', P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 3, LV_ROWNUM,'', P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 4, LV_ROWNUM,'', P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 5, LV_ROWNUM,C1.PFGROSS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
        AS_XLSX.CELL( 6, LV_ROWNUM,C1.PFDED, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
        AS_XLSX.CELL( 7, LV_ROWNUM,C1.PENSIONGROSS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
        AS_XLSX.CELL( 8, LV_ROWNUM,C1.PENSION, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
        AS_XLSX.CELL( 9, LV_ROWNUM,C1.WORKINGDAYS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
       
        AS_XLSX.MERGECELLS(1, LV_ROWNUM, 4, LV_ROWNUM, 1); 
        
   END LOOP;     
   
        
    AS_XLSX.SAVE( L_DIR, L_FILE );
END;
/
