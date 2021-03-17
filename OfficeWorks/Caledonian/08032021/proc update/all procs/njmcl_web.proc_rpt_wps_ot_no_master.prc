DROP PROCEDURE NJMCL_WEB.PROC_RPT_WPS_OT_NO_MASTER;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_RPT_WPS_OT_NO_MASTER
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
    LV_YEAR              VARCHAR2(15); 
    LV_COMPANYNAME            VARCHAR2(100);   
    LV_DIVISIONNAME           VARCHAR2(100);    
    LV_PRINTDATE           VARCHAR2(100);  
  
    LV_SQLSTR             VARCHAR2(5000);
    LV_DIVADDRESS            VARCHAR2(5000);
     
BEGIN

   

    SELECT COMPANYNAME, DIVISIONNAME, DIVISIONADDRESS 
    INTO LV_COMPANYNAME,LV_DIVISIONNAME,LV_DIVADDRESS
    FROM COMPANYMAST CM, DIVISIONMASTER DM                      
    WHERE CM.COMPANYCODE=DM.COMPANYCODE
    AND CM.COMPANYCODE=P_COMPANYCODE
    AND DM.DIVISIONCODE= P_DIVISIONCODE;
   
    LV_RPT_CAPTION:= 'Department wise OT & No Master Summary for  '||P_FROMDATE||' to '|| P_TODATE;

    AS_XLSX.CLEAR_WORKBOOK;
    AS_XLSX.NEW_SHEET;

    -- Set column Width
    AS_XLSX.SET_COLUMN_WIDTH(1,40,1);
    AS_XLSX.SET_COLUMN_WIDTH(2,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(3,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(4,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(5,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(6,15,1);
    
    
    AS_XLSX.MERGECELLS(1, 1, 6, 1, 1);   
    AS_XLSX.CELL( 1, 1, LV_COMPANYNAME  , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA',p_BOLD => TRUE) );              --,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )             

    AS_XLSX.MERGECELLS(1, 2, 6, 2, 1);   
    AS_XLSX.CELL( 1, 2, LV_DIVISIONNAME ||' [ '|| P_DIVISIONCODE || ']', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
    --AS_XLSX.FREEZE_PANE(2, 5);

    AS_XLSX.MERGECELLS(1, 3, 6, 3, 1);   
    AS_XLSX.CELL( 1, 3, LV_RPT_CAPTION , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
    --AS_XLSX.FREEZE_PANE(2, 5);
			
										

    AS_XLSX.CELL( 1, 4,'DEPARTMENT.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    
	AS_XLSX.CELL( 2, 4,'O.T.A', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 3, 4,'', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    
    AS_XLSX.CELL( 4, 4,'O.T.B', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 5, 4,'', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 6, 4,'TOTAL', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
   		

	AS_XLSX.MERGECELLS(2, 4, 3, 4, 1);  
	AS_XLSX.MERGECELLS(4, 4, 5, 4, 1);  
	
    AS_XLSX.CELL( 1, 5,'', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 2, 5,'HRS.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 3, 5,'AMT.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 4, 5,'HRS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 5, 5,'AMT.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 6, 5,'AMOUNT', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
   
    LV_ROWNUM := 5;
-- 
    DELETE FROM GTT_DEPT_WISE_OT_EXCEL WHERE 1=1;

    LV_SQLSTR := NULL;
    LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_DEPT_WISE_OT_EXCEL(COMPANYNAME, DIVISIONNAME, DEPARTMENTCODE, DEPARTMENTNAME, OTA_HRS, OTA_AMT, OTB_HRS, OTB_AMT)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'SELECT C.COMPANYNAME, D.DIVISIONNAME,DEPT.DEPARTMENTCODE, DEPT.DEPARTMENTNAME, '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'NVL(A.OTA_HRS,0) OTA_HRS, NVL(A.OTA_AMT,0) OTA_AMT, NVL(B.OTB_HRS,0) OTB_HRS, NVL(B.OTB_AMT,0) OTB_AMT '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'FROM DEPARTMENTMASTER DEPT,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '('|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SELECT COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, /*WORKERCATEGORYCODE,*/ '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SUM(/*NVL(ATTENDANCEHOURS,0)+*/NVL(OVERTIMEHOURS,0)+/*NVL(NIGHTALLOWANCEHOURS,0)+NVL(NS_ALLOW,0)+*/NVL(OT_NSHRS,0)) OTA_HRS,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SUM(/*NVL(GROSS_WAGES,0)*/ NVL(OT_AMOUNT,0) + NVL(NS_ALLOW_OT,0)) OTA_AMT FROM /*WPSWAGESDETAILS*/ WPSVOUCHERDETAILS'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    WHERE 1=1 /*WORKERCATEGORYCODE=''A''*/'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND COMPANYCODE='''||P_COMPANYCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND DIVISIONCODE='''||P_DIVISIONCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND FORTNIGHTSTARTDATE >=TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND FORTNIGHTENDDATE <=TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    GROUP BY COMPANYCODE,DIVISIONCODE, DEPARTMENTCODE/*, WORKERCATEGORYCODE*/'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || ') A,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '('|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SELECT COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, /*WORKERCATEGORYCODE,*/ '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SUM(NVL(ATTENDANCEHOURS,0)+/*NVL(OVERTIMEHOURS,0)+*/NVL(NIGHTALLOWANCEHOURS,0)/*+NVL(NS_ALLOW,0)+NVL(OT_NSHRS,0)*/) OTB_HRS,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SUM(NVL(GROSS_WAGES,0)-NVL(OT_AMOUNT,0)-NVL(NS_ALLOW_OT,0)) OTB_AMT FROM /*WPSWAGESDETAILS*/ WPSVOUCHERDETAILS'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    WHERE 1=1 /*WORKERCATEGORYCODE=''A''*/'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND COMPANYCODE='''||P_COMPANYCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND DIVISIONCODE='''||P_DIVISIONCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND FORTNIGHTSTARTDATE >=TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND FORTNIGHTENDDATE <=TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    GROUP BY COMPANYCODE,DIVISIONCODE, DEPARTMENTCODE/*, WORKERCATEGORYCODE*/'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || ') B, COMPANYMAST C, DIVISIONMASTER D'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'WHERE 1=1'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.COMPANYCODE='''||P_COMPANYCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DIVISIONCODE='''||P_DIVISIONCODE||''''|| CHR(10);
    
    IF P_DEPT IS NOT NULL THEN
       LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DEPARTMENTCODE IN ('||P_DEPT||')'|| CHR(10);
    END IF;
    
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.COMPANYCODE=A.COMPANYCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DIVISIONCODE=A.DIVISIONCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DEPARTMENTCODE=A.DEPARTMENTCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.COMPANYCODE=B.COMPANYCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DIVISIONCODE=B.DIVISIONCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DEPARTMENTCODE=B.DEPARTMENTCODE(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.COMPANYCODE=C.COMPANYCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.COMPANYCODE=D.COMPANYCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DEPT.DIVISIONCODE=D.DIVISIONCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'ORDER BY DEPT.DEPARTMENTCODE'|| CHR(10);
 
DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);

EXECUTE IMMEDIATE LV_SQLSTR;
 
    FOR C1 IN (  
        SELECT COMPANYNAME, DIVISIONNAME, DEPARTMENTCODE, DEPARTMENTNAME, OTA_HRS, OTA_AMT, OTB_HRS, OTB_AMT, 
        (OTA_AMT+OTB_AMT) TOT_AMT
        FROM GTT_DEPT_WISE_OT_EXCEL     
    )
    LOOP
        LV_ROWNUM := LV_ROWNUM+1;
        
        AS_XLSX.CELL( 1, LV_ROWNUM, C1.DEPARTMENTNAME, P_BORDERID => AS_XLSX.GET_BORDER( '','thin','', 'thin' ) );
        AS_XLSX.CELL( 2, LV_ROWNUM,C1.OTA_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' )  );
        AS_XLSX.CELL( 3, LV_ROWNUM,C1.OTA_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' )  );
        AS_XLSX.CELL( 4, LV_ROWNUM,C1.OTB_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' )  );
        AS_XLSX.CELL( 5, LV_ROWNUM,C1.OTB_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 6, LV_ROWNUM,C1.TOT_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );

    END LOOP;       
   
    LV_ROWNUM := LV_ROWNUM + 1;  
    
    AS_XLSX.CELL( 1, LV_ROWNUM, 'TOTAL', P_BORDERID => AS_XLSX.GET_BORDER( 'double','double','', '' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    FOR C2 IN (  
        SELECT SUM(OTA_HRS) OTA_HRS, SUM(OTA_AMT) OTA_AMT, SUM(OTB_HRS) OTB_HRS, SUM(OTB_AMT) OTB_AMT, SUM(OTA_AMT+OTB_AMT) TOT_AMT
        FROM GTT_DEPT_WISE_OT_EXCEL     
    )
    LOOP
        AS_XLSX.CELL( 2, LV_ROWNUM,C2.OTA_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 3, LV_ROWNUM,C2.OTA_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 4, LV_ROWNUM,C2.OTB_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 5, LV_ROWNUM,C2.OTB_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 6, LV_ROWNUM,C2.TOT_AMT, P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
       
    END LOOP;    
    

--
    LV_PRINTDATE := 'RUN DATE : '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS');
    LV_ROWNUM := LV_ROWNUM + 1;  
    AS_XLSX.CELL( 1, LV_ROWNUM, LV_PRINTDATE , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'left' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
    AS_XLSX.MERGECELLS(1, LV_ROWNUM, 6, LV_ROWNUM, 1);   
        
    AS_XLSX.SAVE( L_DIR, L_FILE );
END;
/


