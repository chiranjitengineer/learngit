DROP PROCEDURE NJMCL_WEB.PROC_RPT_WPS_WAGES_PAID_DED;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_RPT_WPS_WAGES_PAID_DED
(
    P_COMPANYCODE         VARCHAR2,
    P_DIVISIONCODE        VARCHAR2,
    P_FROMDATE            VARCHAR2,
    P_TODATE              VARCHAR2,
    P_DEPT                VARCHAR2 DEFAULT NULL,
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
  
    LV_SQLSTR             VARCHAR2(5000);
    LV_DIVADDRESS         VARCHAR2(5000);
     
BEGIN

   

    SELECT COMPANYNAME, DIVISIONNAME, DIVISIONADDRESS 
    INTO LV_COMPANYNAME,LV_DIVISIONNAME,LV_DIVADDRESS
    FROM COMPANYMAST CM, DIVISIONMASTER DM                      
    WHERE CM.COMPANYCODE=DM.COMPANYCODE
    AND CM.COMPANYCODE=P_COMPANYCODE
    AND DM.DIVISIONCODE= P_DIVISIONCODE;
   
    LV_RPT_CAPTION:= 'Statement of Actual Wages Paid & Deduction for B.M. : '||P_FROMDATE||' to '|| P_TODATE;

    AS_XLSX.CLEAR_WORKBOOK;
    AS_XLSX.NEW_SHEET;

--
--Dept. Desc.    	R.W.HRS		O.W.HRS		O.T.HRS		R.C.ERN		R.N.ERN		O.T.ERN		O.C.ERN		O.N.ERN		RT.CONVEYANCE	TOT.ERN
--				RT.BASIC	RT.FE		RT.NBA		RT.INC		RT.OT		RT.TOTAL	RT.DA		RT.REC.NO	RT.OTB
--				
--1				2			3			4			5			6			7			8			9			10				11	

    -- Set column Width
    AS_XLSX.SET_COLUMN_WIDTH(1,40,1);
    AS_XLSX.SET_COLUMN_WIDTH(2,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(3,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(4,20,1);
    AS_XLSX.SET_COLUMN_WIDTH(5,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(6,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(7,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(8,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(9,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(10,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(11,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(12,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(13,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(14,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(15,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(16,15,1);
    
    
    AS_XLSX.MERGECELLS(1, 1, 11, 1, 1);   
    AS_XLSX.CELL( 1, 1, LV_COMPANYNAME  , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA',p_BOLD => TRUE) );              --,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )             

    AS_XLSX.MERGECELLS(1, 2, 11, 2, 1);   
    AS_XLSX.CELL( 1, 2, LV_DIVISIONNAME ||' [ '|| P_DIVISIONCODE || ']', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
    --AS_XLSX.FREEZE_PANE(2, 5);

    AS_XLSX.MERGECELLS(1, 3, 11, 3, 1);   
    AS_XLSX.CELL( 1, 3, LV_RPT_CAPTION , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
    --AS_XLSX.FREEZE_PANE(2, 5);
			
										

    
    
 AS_XLSX.CELL( 1, 4,'DEPARTMENTS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
 AS_XLSX.CELL( 2, 4,'NO OF WORKERS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
 AS_XLSX.CELL( 3, 4,'GROSS WAGES', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
 AS_XLSX.CELL( 4, 4,'STL ADJ. RECOVER', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
 AS_XLSX.CELL( 5, 4,'P.F.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
 AS_XLSX.CELL( 6, 4,'PENSION', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
 AS_XLSX.CELL( 7, 4,'E.S.I.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
 AS_XLSX.CELL( 8, 4,'PF-L-P', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
 AS_XLSX.CELL( 9, 4,'PF-L-I', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
 AS_XLSX.CELL( 10, 4,'H/RENT', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
 AS_XLSX.CELL( 11, 4,'P.TAX', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
 AS_XLSX.CELL( 12, 4,'WELFARE', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
 AS_XLSX.CELL( 13, 4,'ADJ.DED	', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
 AS_XLSX.CELL( 14, 4,'OTHERS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
 AS_XLSX.CELL( 15, 4,'P C/F', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
 AS_XLSX.CELL( 16, 4,'NET. WAGES', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
   

    LV_ROWNUM := 4;
    DELETE FROM GTT_DEPT_WAGES_PAID_DED WHERE 1=1;
 




    LV_SQLSTR := NULL;
    LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_DEPT_WAGES_PAID_DED(DEPARTMENTCODE, DEPARTMENTDESC, NOOFWORKER, GROSSWAGES, STL_ADJ_RECOVER, PF, PENSION, ESI, PF_L_P, PF_L_I, H_RENT, P_TAX, WELFARE, ADJ_DED, OTHER, P_CF, NET_WAGES)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'SELECT A.DEPARTMENTCODE, DEPARTMENTNAME,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'COUNT(TOKENNO) NOOFWORKER,SUM(NVL(GROSS_WAGES,0)) GROSSWAGES,SUM(NVL(STL_ADV,0)) STL_ADJ_RECOVER,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'SUM(NVL(PF_CONT,0)) PF,0 PENSION,SUM(NVL(A.ESI_CONT,0)) ESI,SUM(NVL(A.LOAN_PFL,0)) PF_L_P,SUM(NVL(A.LINT_PFL,0)) PF_L_I,SUM(NVL(A.HRA,0)) H_RENT,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'SUM(NVL(A.P_TAX,0)) P_TAX,0 WELFARE,0 ADJ_DED,0 OTHER,0 P_CF,(SUM(NVL(A.TOT_EARN,0)) - SUM(NVL(A.TOT_DEDUCTION,0))) NET_WAGES'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'FROM WPSWAGESDETAILS A, DEPARTMENTMASTER B'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'WHERE A.COMPANYCODE=B.COMPANYCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.DIVISIONCODE=B.DIVISIONCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.DEPARTMENTCODE=B.DEPARTMENTCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.COMPANYCODE='''||P_COMPANYCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.DIVISIONCODE='''||P_DIVISIONCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.FORTNIGHTSTARTDATE>=TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.FORTNIGHTENDDATE<=TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'|| CHR(10);
    
    IF P_DEPT IS NOT NULL THEN
       LV_SQLSTR := LV_SQLSTR || 'AND A.DEPARTMENTCODE IN ('||P_DEPT||')'|| CHR(10);
    END IF;
    
    LV_SQLSTR := LV_SQLSTR || 'GROUP BY A.DEPARTMENTCODE, DEPARTMENTNAME'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'ORDER BY A.DEPARTMENTCODE '|| CHR(10);
  
DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);

EXECUTE IMMEDIATE LV_SQLSTR;
-- 
    FOR C1 IN (  
        SELECT DEPARTMENTCODE, DEPARTMENTDESC, NOOFWORKER, GROSSWAGES, STL_ADJ_RECOVER, PF, 
        PENSION, ESI, PF_L_P, PF_L_I, H_RENT, P_TAX, WELFARE, ADJ_DED, OTHER, P_CF, NET_WAGES
        FROM GTT_DEPT_WAGES_PAID_DED     
    )
    LOOP
        LV_ROWNUM := LV_ROWNUM+1;
        
        AS_XLSX.CELL( 1, LV_ROWNUM, C1.DEPARTMENTDESC, P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( p_vertical => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'thin','thin','thin', 'thin' ) );
        AS_XLSX.CELL( 2, LV_ROWNUM,C1.NOOFWORKER, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0' )  );
        AS_XLSX.CELL( 3, LV_ROWNUM,C1.GROSSWAGES, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' )  );
        AS_XLSX.CELL( 4, LV_ROWNUM,C1.STL_ADJ_RECOVER, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' )  );
        AS_XLSX.CELL( 5, LV_ROWNUM,C1.PF, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 6, LV_ROWNUM,C1.PENSION, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 7, LV_ROWNUM,C1.ESI, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 8, LV_ROWNUM,C1.PF_L_P, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 9, LV_ROWNUM,C1.PF_L_I, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 10, LV_ROWNUM,C1.H_RENT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 11, LV_ROWNUM,C1.P_TAX, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 12, LV_ROWNUM,C1.WELFARE, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 13, LV_ROWNUM,C1.ADJ_DED, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 14, LV_ROWNUM,C1.OTHER, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 15, LV_ROWNUM,C1.P_CF, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 16, LV_ROWNUM,C1.NET_WAGES, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
       
    
    END LOOP;       
   
    LV_ROWNUM := LV_ROWNUM + 1;  
    
    AS_XLSX.CELL( 1, LV_ROWNUM, 'TOTAL', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( p_vertical => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double','double','', '' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    
    FOR C1 IN (  
        SELECT SUM(NOOFWORKER) NOOFWORKER, SUM(GROSSWAGES) GROSSWAGES,  SUM(STL_ADJ_RECOVER) STL_ADJ_RECOVER,  SUM(PF) PF, 
         SUM(PENSION) PENSION,  SUM(ESI) ESI,  SUM(PF_L_P) PF_L_P,  SUM(PF_L_I) PF_L_I,  SUM(H_RENT) H_RENT,  SUM(P_TAX) P_TAX,  
         SUM(WELFARE) WELFARE,  SUM(ADJ_DED) ADJ_DED,  SUM(OTHER) OTHER,  SUM(P_CF) P_CF,  SUM(NET_WAGES) NET_WAGES
        FROM GTT_DEPT_WAGES_PAID_DED 
    )
    LOOP
        
        --AS_XLSX.CELL( 1, LV_ROWNUM, C1.DEPARTMENTDESC, P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( p_vertical => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'thin','thin','thin', 'thin' ) );
        AS_XLSX.CELL( 2, LV_ROWNUM,C1.NOOFWORKER, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE)  );
        AS_XLSX.CELL( 3, LV_ROWNUM,C1.GROSSWAGES, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE)  );
        AS_XLSX.CELL( 4, LV_ROWNUM,C1.STL_ADJ_RECOVER, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE)  );
        AS_XLSX.CELL( 5, LV_ROWNUM,C1.PF, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
        AS_XLSX.CELL( 6, LV_ROWNUM,C1.PENSION, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
        AS_XLSX.CELL( 7, LV_ROWNUM,C1.ESI, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
        AS_XLSX.CELL( 8, LV_ROWNUM,C1.PF_L_P, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
        AS_XLSX.CELL( 9, LV_ROWNUM,C1.PF_L_I, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
        AS_XLSX.CELL( 10, LV_ROWNUM,C1.H_RENT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
        AS_XLSX.CELL( 11, LV_ROWNUM,C1.P_TAX, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
        AS_XLSX.CELL( 12, LV_ROWNUM,C1.WELFARE, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
        AS_XLSX.CELL( 13, LV_ROWNUM,C1.ADJ_DED, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
        AS_XLSX.CELL( 14, LV_ROWNUM,C1.OTHER, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
        AS_XLSX.CELL( 15, LV_ROWNUM,C1.P_CF, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
        AS_XLSX.CELL( 16, LV_ROWNUM,C1.NET_WAGES, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    
    END LOOP; 
    
       
    AS_XLSX.SAVE( L_DIR, L_FILE );
END;
/


