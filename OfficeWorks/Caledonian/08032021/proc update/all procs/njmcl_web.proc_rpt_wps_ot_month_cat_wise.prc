DROP PROCEDURE NJMCL_WEB.PROC_RPT_WPS_OT_MONTH_CAT_WISE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_RPT_WPS_OT_MONTH_CAT_WISE
(
    P_COMPANYCODE         VARCHAR2,
    P_DIVISIONCODE        VARCHAR2,
    P_FROMDATE            VARCHAR2,
    P_TODATE           VARCHAR2,
    P_DEPT                VARCHAR2 DEFAULT NULL,
    P_FILE                 VARCHAR2 
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
  
    LV_SQLSTR             VARCHAR2(25000);
    LV_DIVADDRESS         VARCHAR2(500);
     
BEGIN

   

    SELECT COMPANYNAME, DIVISIONNAME, DIVISIONADDRESS 
    INTO LV_COMPANYNAME,LV_DIVISIONNAME,LV_DIVADDRESS
    FROM COMPANYMAST CM, DIVISIONMASTER DM                      
    WHERE CM.COMPANYCODE=DM.COMPANYCODE
    AND CM.COMPANYCODE=P_COMPANYCODE
    AND DM.DIVISIONCODE= P_DIVISIONCODE;
   
    LV_RPT_CAPTION:= 'Department wise OT [Record no.]      '||P_FROMDATE||' to '|| P_TODATE;

    AS_XLSX.CLEAR_WORKBOOK;
    AS_XLSX.NEW_SHEET;

    -- Set column Width
    AS_XLSX.SET_COLUMN_WIDTH(1,40,1);
    AS_XLSX.SET_COLUMN_WIDTH(2,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(3,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(4,15,1);
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
    AS_XLSX.SET_COLUMN_WIDTH(17,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(18,15,1);
    
    
    AS_XLSX.MERGECELLS(1, 1, 18, 1, 1);   
    AS_XLSX.CELL( 1, 1, LV_COMPANYNAME  , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA',p_BOLD => TRUE) );              --,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )             

    AS_XLSX.MERGECELLS(1, 2, 18, 2, 1);   
    AS_XLSX.CELL( 1, 2, LV_DIVISIONNAME ||' [ '|| P_DIVISIONCODE || ']', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
    --AS_XLSX.FREEZE_PANE(2, 5);

    AS_XLSX.MERGECELLS(1, 3, 18, 3, 1);   
    AS_XLSX.CELL( 1, 3, LV_RPT_CAPTION , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
    --AS_XLSX.FREEZE_PANE(2, 5);
			
										

    AS_XLSX.CELL( 1, 4,'DEPARTMENT.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    
	AS_XLSX.CELL( 2, 4,'O.T.A', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 3, 4,'', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    
    AS_XLSX.CELL( 4, 4,'O.T.B', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 5, 4,'', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 6, 4,'TOTAL', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
   		
    AS_XLSX.CELL( 7, 4,'[FULL RATED]', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 8, 4,'', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 9, 4,'[115 RATED]', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 10, 4,'', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 11, 4,'[110 RATED]', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 12, 4,'', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 13, 4,'[100(O) RATED]', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 14, 4,'', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 15, 4,'[100 RATED]', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 16, 4,'', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 17, 4,'[157 RATED]', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 18, 4,'', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
   

	AS_XLSX.MERGECELLS(2, 4, 3, 4, 1);  
	AS_XLSX.MERGECELLS(4, 4, 5, 4, 1);   
	AS_XLSX.MERGECELLS(7, 4, 8, 4, 1);   
	AS_XLSX.MERGECELLS(9, 4, 10, 4, 1);   
	AS_XLSX.MERGECELLS(11, 4, 12, 4, 1);   
	AS_XLSX.MERGECELLS(13, 4, 14, 4, 1);   
	AS_XLSX.MERGECELLS(15, 4, 16, 4, 1);   
	AS_XLSX.MERGECELLS(17, 4, 18, 4, 1);  
	
    AS_XLSX.CELL( 1, 5,'', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 2, 5,'HRS.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 3, 5,'AMT.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 4, 5,'HRS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 5, 5,'AMT.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 6, 5,'AMOUNT', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
   
    AS_XLSX.CELL( 7, 5,'HRS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 8, 5,'AMT.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
   
    AS_XLSX.CELL( 9, 5,'HRS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 10, 5,'AMT.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
   
    AS_XLSX.CELL( 11, 5,'HRS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 12, 5,'AMT.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
   
    AS_XLSX.CELL( 13, 5,'HRS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 14, 5,'AMT.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
   
    AS_XLSX.CELL( 15, 5,'HRS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 16, 5,'AMT.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
   
    AS_XLSX.CELL( 17, 5,'HRS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 18, 5,'AMT.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    



    LV_ROWNUM := 5;

    DELETE FROM GTT_WPS_OT_MONTH_CAT_WISE WHERE 1=1;

    LV_SQLSTR := NULL;

    LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_WPS_OT_MONTH_CAT_WISE (COMPANYNAME, DIVISIONNAME, DEPARTMENTCODE, DEPARTMENTNAME, OTA_HRS, OTA_AMT, OTB_HRS, OTB_AMT, FR_HRS, FR_AMT, A115_HRS, A115_AMT, A110_HRS, A110_AMT, A100_HRS, A100_AMT, B100_HRS, B100_AMT, Q_HRS, Q_AMT)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'SELECT C.COMPANYNAME, D.DIVISIONNAME,DEPT.DEPARTMENTCODE, DEPT.DEPARTMENTNAME, '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'NVL(A.OTA_HRS,0) OTA_HRS, NVL(A.OTA_AMT,0) OTA_AMT, NVL(B.OTB_HRS,0) OTB_HRS, NVL(B.OTB_AMT,0) OTB_AMT , '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'NVL(FR_HRS,0) FR_HRS, NVL(FR_AMT,0) FR_AMT, NVL(A115_HRS,0) A115_HRS, NVL(A115_AMT,0) A115_AMT  , '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'NVL(A110_HRS,0) A110_HRS, NVL(A110_AMT,0) A110_AMT, NVL(A100_HRS,0) A100_HRS, NVL(A100_AMT,0) A100_AMT , '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'NVL(B100_HRS,0) B100_HRS, NVL(B100_AMT,0) B100_AMT, NVL(Q_HRS,0) Q_HRS, NVL(Q_AMT,0) Q_AMT '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'FROM DEPARTMENTMASTER DEPT,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '('|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SELECT COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, /*WORKERCATEGORYCODE,*/ '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SUM(/*NVL(ATTENDANCEHOURS,0)+*/NVL(OVERTIMEHOURS,0)+/*NVL(NIGHTALLOWANCEHOURS,0)+NVL(NS_ALLOW,0)+*/NVL(OT_NSHRS,0)) OTA_HRS,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SUM(/*NVL(GROSS_WAGES,0)*/ NVL(OT_AMOUNT,0) + NVL(NS_ALLOW_OT,0)) OTA_AMT FROM WPSVOUCHERDETAILS'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    WHERE 1=2 AND WORKERCATEGORYCODE=''A'''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND COMPANYCODE='''||P_COMPANYCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND DIVISIONCODE='''||P_DIVISIONCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND FORTNIGHTSTARTDATE >=TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND FORTNIGHTENDDATE <=TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    GROUP BY COMPANYCODE,DIVISIONCODE, DEPARTMENTCODE/*, WORKERCATEGORYCODE*/'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || ') A,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '('|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SELECT COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, /*WORKERCATEGORYCODE,*/ '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SUM(/*NVL(ATTENDANCEHOURS,0)+*/NVL(OVERTIMEHOURS,0)+/*NVL(NIGHTALLOWANCEHOURS,0)+NVL(NS_ALLOW,0)+*/NVL(OT_NSHRS,0)) OTB_HRS,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SUM(/*NVL(GROSS_WAGES,0)*/ NVL(OT_AMOUNT,0) + NVL(NS_ALLOW_OT,0)) OTB_AMT FROM WPSWAGESDETAILS'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    WHERE 1=1 /*WORKERCATEGORYCODE=''B''*/'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND COMPANYCODE='''||P_COMPANYCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND DIVISIONCODE='''||P_DIVISIONCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND FORTNIGHTSTARTDATE >=TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND FORTNIGHTENDDATE <=TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    GROUP BY COMPANYCODE,DIVISIONCODE, DEPARTMENTCODE/*, WORKERCATEGORYCODE*/'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || ') B, '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '('|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SELECT COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,  '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SUM(/*NVL(ATTENDANCEHOURS,0)+*/NVL(OVERTIMEHOURS,0)+/*NVL(NIGHTALLOWANCEHOURS,0)+NVL(NS_ALLOW,0)+*/NVL(OT_NSHRS,0)) FR_HRS,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SUM(/*NVL(GROSS_WAGES,0)*/ NVL(OT_AMOUNT,0) + NVL(NS_ALLOW_OT,0)) FR_AMT FROM WPSWAGESDETAILS'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    WHERE GRADECODE=''FR'''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND COMPANYCODE='''||P_COMPANYCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND DIVISIONCODE='''||P_DIVISIONCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND FORTNIGHTSTARTDATE >=TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND FORTNIGHTENDDATE <=TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    GROUP BY COMPANYCODE,DIVISIONCODE, DEPARTMENTCODE '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || ') FR,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '('|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SELECT COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,  '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SUM(/*NVL(ATTENDANCEHOURS,0)+*/NVL(OVERTIMEHOURS,0)+/*NVL(NIGHTALLOWANCEHOURS,0)+NVL(NS_ALLOW,0)+*/NVL(OT_NSHRS,0)) A115_HRS,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SUM(/*NVL(GROSS_WAGES,0)*/ NVL(OT_AMOUNT,0) + NVL(NS_ALLOW_OT,0)) A115_AMT FROM WPSWAGESDETAILS'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    WHERE GRADECODE LIKE ''115_'''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND COMPANYCODE='''||P_COMPANYCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND DIVISIONCODE='''||P_DIVISIONCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND FORTNIGHTSTARTDATE >=TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND FORTNIGHTENDDATE <=TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'GROUP BY COMPANYCODE,DIVISIONCODE, DEPARTMENTCODE '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || ') A115,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '('|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SELECT COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SUM(/*NVL(ATTENDANCEHOURS,0)+*/NVL(OVERTIMEHOURS,0)+/*NVL(NIGHTALLOWANCEHOURS,0)+NVL(NS_ALLOW,0)+*/NVL(OT_NSHRS,0)) A110_HRS,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SUM(/*NVL(GROSS_WAGES,0)*/ NVL(OT_AMOUNT,0) + NVL(NS_ALLOW_OT,0)) A110_AMT FROM WPSWAGESDETAILS'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    WHERE GRADECODE LIKE ''110_'''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND COMPANYCODE='''||P_COMPANYCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND DIVISIONCODE='''||P_DIVISIONCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND FORTNIGHTSTARTDATE >=TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND FORTNIGHTENDDATE <=TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    GROUP BY COMPANYCODE,DIVISIONCODE, DEPARTMENTCODE '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || ') A110,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '('|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SELECT COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SUM(/*NVL(ATTENDANCEHOURS,0)+*/NVL(OVERTIMEHOURS,0)+/*NVL(NIGHTALLOWANCEHOURS,0)+NVL(NS_ALLOW,0)+*/NVL(OT_NSHRS,0)) A100_HRS,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SUM(/*NVL(GROSS_WAGES,0)*/ NVL(OT_AMOUNT,0) + NVL(NS_ALLOW_OT,0)) A100_AMT FROM WPSWAGESDETAILS'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    WHERE GRADECODE=''100A'''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND COMPANYCODE='''||P_COMPANYCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND DIVISIONCODE='''||P_DIVISIONCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND FORTNIGHTSTARTDATE >=TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND FORTNIGHTENDDATE <=TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    GROUP BY COMPANYCODE,DIVISIONCODE, DEPARTMENTCODE '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || ') A100,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '('|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SELECT COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SUM(/*NVL(ATTENDANCEHOURS,0)+*/NVL(OVERTIMEHOURS,0)+/*NVL(NIGHTALLOWANCEHOURS,0)+NVL(NS_ALLOW,0)+*/NVL(OT_NSHRS,0)) B100_HRS,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SUM(/*NVL(GROSS_WAGES,0)*/ NVL(OT_AMOUNT,0) + NVL(NS_ALLOW_OT,0)) B100_AMT FROM WPSWAGESDETAILS'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    WHERE GRADECODE IN (''100B'',''100C'',''100D'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND COMPANYCODE='''||P_COMPANYCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND DIVISIONCODE='''||P_DIVISIONCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND FORTNIGHTSTARTDATE >=TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND FORTNIGHTENDDATE <=TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    GROUP BY COMPANYCODE,DIVISIONCODE, DEPARTMENTCODE '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || ') B100,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '('|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SELECT COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SUM(/*NVL(ATTENDANCEHOURS,0)+*/NVL(OVERTIMEHOURS,0)+/*NVL(NIGHTALLOWANCEHOURS,0)+NVL(NS_ALLOW,0)+*/NVL(OT_NSHRS,0)) Q_HRS,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SUM(/*NVL(GROSS_WAGES,0)*/ NVL(OT_AMOUNT,0) + NVL(NS_ALLOW_OT,0)) Q_AMT FROM WPSWAGESDETAILS'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    WHERE /*INSTR(GRADECODE,''Q'')>0*/ GRADECODE<>''FR'' AND GRADECODE NOT LIKE ''115_'' AND GRADECODE NOT LIKE ''110_'' AND GRADECODE<>''100A'' AND GRADECODE NOT IN (''100B'',''100C'',''100D'') '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND COMPANYCODE='''||P_COMPANYCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND DIVISIONCODE='''||P_DIVISIONCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND FORTNIGHTSTARTDATE >=TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND FORTNIGHTENDDATE <=TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    GROUP BY COMPANYCODE,DIVISIONCODE, DEPARTMENTCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || ') Q,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'COMPANYMAST C, DIVISIONMASTER D'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'WHERE 1=1'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.COMPANYCODE='''||P_COMPANYCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DIVISIONCODE='''||P_DIVISIONCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.COMPANYCODE=A.COMPANYCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DIVISIONCODE=A.DIVISIONCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DEPARTMENTCODE=A.DEPARTMENTCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.COMPANYCODE=B.COMPANYCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DIVISIONCODE=B.DIVISIONCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DEPARTMENTCODE=B.DEPARTMENTCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.COMPANYCODE=FR.COMPANYCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DIVISIONCODE=FR.DIVISIONCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DEPARTMENTCODE=FR.DEPARTMENTCODE(+) --------'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.COMPANYCODE=A100.COMPANYCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DIVISIONCODE=A100.DIVISIONCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DEPARTMENTCODE=A100.DEPARTMENTCODE(+)----------'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.COMPANYCODE=A115.COMPANYCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DIVISIONCODE=A115.DIVISIONCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DEPARTMENTCODE=A115.DEPARTMENTCODE(+)-------------'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.COMPANYCODE=A110.COMPANYCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DIVISIONCODE=A110.DIVISIONCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DEPARTMENTCODE=A110.DEPARTMENTCODE(+)------------'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.COMPANYCODE=B100.COMPANYCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DIVISIONCODE=B100.DIVISIONCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DEPARTMENTCODE=B100.DEPARTMENTCODE(+)---------------'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.COMPANYCODE=Q.COMPANYCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DIVISIONCODE=Q.DIVISIONCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DEPARTMENTCODE=Q.DEPARTMENTCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.COMPANYCODE=C.COMPANYCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.COMPANYCODE=D.COMPANYCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DIVISIONCODE=D.DIVISIONCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'ORDER BY DEPT.DEPARTMENTCODE'|| CHR(10);
     
     
DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);

EXECUTE IMMEDIATE LV_SQLSTR;
 
    FOR C1 IN (  
        SELECT COMPANYNAME, DIVISIONNAME, DEPARTMENTCODE, DEPARTMENTNAME, OTA_HRS, OTA_AMT, OTB_HRS, OTB_AMT, 
        (OTA_AMT+OTB_AMT) TOT_AMT,FR_HRS, FR_AMT, A115_HRS, A115_AMT, A110_HRS, A110_AMT, A100_HRS, A100_AMT, B100_HRS, B100_AMT, Q_HRS, Q_AMT
        FROM GTT_WPS_OT_MONTH_CAT_WISE     
    )
    LOOP
        LV_ROWNUM := LV_ROWNUM+1;
        
        AS_XLSX.CELL( 1, LV_ROWNUM, C1.DEPARTMENTNAME, P_BORDERID => AS_XLSX.GET_BORDER( '','thin','', 'thin' ) );
        AS_XLSX.CELL( 2, LV_ROWNUM,C1.OTA_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' )  );
        AS_XLSX.CELL( 3, LV_ROWNUM,C1.OTA_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' )  );
        AS_XLSX.CELL( 4, LV_ROWNUM,C1.OTB_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' )  );
        AS_XLSX.CELL( 5, LV_ROWNUM,C1.OTB_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 6, LV_ROWNUM,C1.TOT_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 7, LV_ROWNUM,C1.FR_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 8, LV_ROWNUM,C1.FR_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 9, LV_ROWNUM,C1.A115_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 10, LV_ROWNUM,C1.A115_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 11, LV_ROWNUM,C1.A110_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 12, LV_ROWNUM,C1.A110_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 13, LV_ROWNUM,C1.A100_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 14, LV_ROWNUM,C1.A100_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 15, LV_ROWNUM,C1.B100_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 16, LV_ROWNUM,C1.B100_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 17, LV_ROWNUM,C1.Q_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 18, LV_ROWNUM,C1.Q_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
    END LOOP;       
   
    LV_ROWNUM := LV_ROWNUM + 1;  
    
    AS_XLSX.CELL( 1, LV_ROWNUM, 'TOTAL', P_BORDERID => AS_XLSX.GET_BORDER( 'double','double','', '' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    FOR C1 IN (  
        SELECT SUM(OTA_HRS) OTA_HRS, SUM(OTA_AMT) OTA_AMT, SUM(OTB_HRS) OTB_HRS, SUM(OTB_AMT) OTB_AMT, SUM(OTA_AMT+OTB_AMT) TOT_AMT,
        SUM(FR_HRS) FR_HRS, SUM(FR_AMT) FR_AMT, SUM(A115_HRS) A115_HRS, SUM(A115_AMT) A115_AMT, SUM(A110_HRS) A110_HRS, SUM(A110_AMT) A110_AMT, SUM(A100_HRS) A100_HRS, 
        SUM(A100_AMT) A100_AMT, SUM(B100_HRS) B100_HRS, SUM(B100_AMT) B100_AMT, SUM(Q_HRS) Q_HRS, SUM(Q_AMT) Q_AMT
        FROM GTT_WPS_OT_MONTH_CAT_WISE     
    )
    LOOP
        AS_XLSX.CELL( 2, LV_ROWNUM,C1.OTA_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' )  );
        AS_XLSX.CELL( 3, LV_ROWNUM,C1.OTA_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' )  );
        AS_XLSX.CELL( 4, LV_ROWNUM,C1.OTB_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' )  );
        AS_XLSX.CELL( 5, LV_ROWNUM,C1.OTB_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 6, LV_ROWNUM,C1.TOT_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 7, LV_ROWNUM,C1.FR_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 8, LV_ROWNUM,C1.FR_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 9, LV_ROWNUM,C1.A115_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 10, LV_ROWNUM,C1.A115_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 11, LV_ROWNUM,C1.A110_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 12, LV_ROWNUM,C1.A110_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 13, LV_ROWNUM,C1.A100_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 14, LV_ROWNUM,C1.A100_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 15, LV_ROWNUM,C1.B100_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 16, LV_ROWNUM,C1.B100_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 17, LV_ROWNUM,C1.Q_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 18, LV_ROWNUM,C1.Q_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
  
    END LOOP;    
    

--
    LV_PRINTDATE := 'RUN DATE : '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS');
    LV_ROWNUM := LV_ROWNUM + 1;  
    AS_XLSX.CELL( 1, LV_ROWNUM, LV_PRINTDATE , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'left' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
    AS_XLSX.MERGECELLS(1, LV_ROWNUM, 18, LV_ROWNUM, 1);   
        
    AS_XLSX.SAVE( L_DIR, L_FILE );
END;
/

