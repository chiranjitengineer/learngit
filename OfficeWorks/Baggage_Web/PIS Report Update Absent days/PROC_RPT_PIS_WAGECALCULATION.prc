CREATE OR REPLACE PROCEDURE BAGGAGE_WEB.PROC_RPT_PIS_WAGECALCULATION
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
    LV_YEAR              VARCHAR2(15); 
    LV_COMPANYNAME            VARCHAR2(100);   
    LV_DIVISIONNAME           VARCHAR2(100);    
    LV_PRINTDATE           VARCHAR2(100);  
  
    LV_SQLSTR             VARCHAR2(5000);
    LV_DIVADDRESS            VARCHAR2(5000);
     
BEGIN

    SELECT TRIM(TO_CHAR(TO_DATE(P_YEARMONTH,'YYYYMM'),'MONTH')), 
    TO_CHAR(TO_DATE(P_YEARMONTH,'YYYYMM'),'YYYY') ,'Run Date : '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:ss')
    INTO LV_MONTH, LV_YEAR,LV_PRINTDATE  FROM  DUAL;

    SELECT COMPANYNAME, DIVISIONNAME, DIVISIONADDRESS 
    INTO LV_COMPANYNAME,LV_DIVISIONNAME,LV_DIVADDRESS
    FROM COMPANYMAST CM, DIVISIONMASTER DM                      
    WHERE CM.COMPANYCODE=DM.COMPANYCODE
    AND CM.COMPANYCODE=P_COMPANYCODE
    AND DM.DIVISIONCODE= P_DIVISIONCODE;
   
    LV_RPT_CAPTION:= 'Wages Calculation For the Month of '||LV_MONTH||', '|| LV_YEAR;

    AS_XLSX.CLEAR_WORKBOOK;
    AS_XLSX.NEW_SHEET;

    -- Set column Width
    AS_XLSX.SET_COLUMN_WIDTH(1,7,1);
    AS_XLSX.SET_COLUMN_WIDTH(2,10,1);
    AS_XLSX.SET_COLUMN_WIDTH(3,35,1);
    AS_XLSX.SET_COLUMN_WIDTH(4,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(5,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(6,15,1);
    AS_XLSX.SET_COLUMN_WIDTH(7,18,1);
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
    AS_XLSX.CELL( 1, 2, LV_DIVISIONNAME ||' : '|| LV_DIVADDRESS , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
    --AS_XLSX.FREEZE_PANE(2, 5);

    AS_XLSX.MERGECELLS(1, 3, 18, 3, 1);   
    AS_XLSX.CELL( 1, 3, LV_RPT_CAPTION , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
    --AS_XLSX.FREEZE_PANE(2, 5);
			
										
--
--    AS_XLSX.CELL( 1, 4,'SL.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
--    AS_XLSX.CELL( 2, 4,'TOKEN NO.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
--    AS_XLSX.CELL( 3, 4,'EMPLOYEE NAME', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
--    AS_XLSX.CELL( 4, 4,'GRADE NAME', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
--    AS_XLSX.CELL( 5, 4,'ACTUAL BASIC', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
--    AS_XLSX.CELL( 6, 4,'ARREAR', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
--    AS_XLSX.CELL( 7, 4,'EARNED BASIC', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
--    AS_XLSX.CELL( 8, 4,'SHIFT B', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
--    AS_XLSX.CELL( 9, 4,'SHIFT C', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
--    AS_XLSX.CELL( 10, 4,'TSH B', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
--    AS_XLSX.CELL( 11, 4,'TSH C', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
--    AS_XLSX.CELL( 12, 4,'TOTAL HRS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
--    AS_XLSX.CELL( 13, 4,'SHIFT AMT', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
--    AS_XLSX.CELL( 14, 4,'WORKED DAYS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
--    AS_XLSX.CELL( 15, 4,'LEAVE DAYS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
--    AS_XLSX.CELL( 16, 4,'TOTAL DAYS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
--    AS_XLSX.CELL( 17, 4,'ATTEND AMT', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
--    AS_XLSX.CELL( 18, 4,'LOP IN MINUTES', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
--   


    AS_XLSX.CELL( 1, 4,'SL.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 2, 4,'TOKEN NO.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'none', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 3, 4,'EMPLOYEE NAME', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'none', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 4, 4,'GRADE', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'none', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 5, 4,'ACTUAL', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'none', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 6, 4,'ARREAR', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'none', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 7, 4,'EARNED', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'none', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
   
    AS_XLSX.MERGECELLS(8, 4, 9, 4, 1);   
    AS_XLSX.CELL( 8, 4,'SHIFT', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'thin', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 9, 4,'', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'thin', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.MERGECELLS(10, 4, 11, 4, 1);   
    
    AS_XLSX.CELL( 10, 4,'TOTAL SHIFT HOURS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'thin', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 11, 4,'', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'thin', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 12, 4,'TOTAL', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'none', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 13, 4,'SHIFT', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'none', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 14, 4,'NO. OF', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'none', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 15, 4,'LEAVE', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'none', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 16, 4,'TOTAL', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'none', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 17, 4,'ATTEND', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'none', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 18, 4,'LOP', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'none', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
   

    AS_XLSX.CELL( 1, 5,' ', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'thin', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 2, 5,' ', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'thin', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 3, 5,' ', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'thin', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 4, 5,' ', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'thin', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 5, 5,'BASIC', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'thin', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 6, 5,' ', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'thin', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 7, 5,'BASIC', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'thin', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 8, 5,'[B]', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'thin', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 9, 5,'[C]', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'thin', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 10, 5,'[B]', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'thin', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 11, 5,'[C]', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'thin', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 12, 5,'HOURS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'thin', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 13, 5,'AMOUNT', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'thin', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 14, 5,'DAYS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'none', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 15, 5,'DAYS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'thin', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 16, 5,'DAYS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'thin', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 17, 5,'AMOUNT', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'thin', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 18, 5,'IN', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'none', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );

    AS_XLSX.CELL( 1, 6,' ', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 2, 6,' ', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 3, 6,' ', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 4, 6,' ', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 5, 6,' ', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 6, 6,' ', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 7, 6,' ', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 8, 6,' ', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 9, 6,' ', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 10, 6,' ', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 11, 6,' ', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 12, 6,' ', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 13, 6,' ', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 14, 6,'WORKED', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 15, 6,' ', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 16, 6,' ', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 17, 6,' ', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 18, 6,'MINUTES', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'none', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
   
    LV_ROWNUM := 6;
 
DELETE FROM GTT_WAGECALCULATION WHERE 1=1;

LV_SQLSTR := NULL;
LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_WAGECALCULATION' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '     SLNO, TOKENNO, WORKERSERIAL, EMPLOYEENAME, GRADECODE, GRADEDESC, BASIC_RT, BASIC,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '     ARREAR, SHIFT_A, SHIFT_B, SHIFT_C, SHIFT_ALW, SHIFTA_HRS, SHIFTB_HRS, SHIFTC_HRS,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '     TOTAL_HRS, ATTN_ALW, ATTN_LDAY, ATTN_WRKD, TOTALDAYS, LOP' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);

LV_SQLSTR := LV_SQLSTR || 'SELECT ROW_NUMBER() OVER (ORDER BY A.TOKENNO) SLNO,A.TOKENNO, A.WORKERSERIAL, A.EMPLOYEENAME, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'B.GRADECODE, C.GRADEDESC, B.BASIC_RT, B.BASIC, 0 ARREAR, NVL(B.SHIFT_A,0) SHIFT_A, NVL(B.SHIFT_B,0) SHIFT_B,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'NVL(B.SHIFT_C,0) SHIFT_C, NVL(B.SHIFT_ALW,0) SHIFT_ALW, NVL(B.SHIFTA_HRS,0) SHIFTA_HRS, NVL(B.SHIFTB_HRS,0) SHIFTB_HRS,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'NVL(B.SHIFTC_HRS,0) SHIFTC_HRS, (NVL(B.SHIFTB_HRS,0) + NVL(B.SHIFTA_HRS,0)) TOTAL_HRS, /*NVL(B.ATTN_ALW,0)*/NVL(B.ATN_ALW,0) ATTN_ALW, NVL(B.ATTN_LDAY,0) ATTN_LDAY,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'NVL(B.ATTN_WRKD,0) ATTN_WRKD, (NVL(B.ATTN_LDAY,0)+ NVL(B.ATTN_WRKD,0)) TOTALDAYS, NVL(B.LOP,0) LOP' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'FROM PISEMPLOYEEMASTER  A, /*PISPAYTRANSACTION*/ (SELECT * FROM PISPAYTRANSACTION WHERE YEARMONTH = '''||P_YEARMONTH||''' AND  TRANSACTIONTYPE =''SALARY'' ) B, PISGRADEMASTER C' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'WHERE A.COMPANYCODE='''||P_COMPANYCODE ||'''' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '  AND A.DIVISIONCODE='''||P_DIVISIONCODE||'''' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '  AND A.YEARMONTH='''||P_YEARMONTH||'''' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '  AND B.TRANSACTIONTYPE =''SALARY'' '||CHR(10);
LV_SQLSTR := LV_SQLSTR || '  AND A.COMPANYCODE=B.COMPANYCODE(+)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '  AND A.DIVISIONCODE=B.DIVISIONCODE(+)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '  AND A.WORKERSERIAL=B.WORKERSERIAL(+) ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '  AND A.COMPANYCODE=C.COMPANYCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '  AND A.DIVISIONCODE=C.DIVISIONCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '  AND A.CATEGORYCODE = C.CATEGORYCODE AND A.GRADECODE=C.GRADECODE ' || CHR(10);


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

DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);

EXECUTE IMMEDIATE LV_SQLSTR;
 
    FOR C1 IN (  
        SELECT SLNO, TOKENNO, WORKERSERIAL, EMPLOYEENAME, GRADECODE, GRADEDESC, BASIC_RT, ARREAR, BASIC,
        SHIFT_A, SHIFT_B, SHIFT_C, SHIFT_ALW, SHIFTA_HRS, SHIFTB_HRS, SHIFTC_HRS,
        TOTAL_HRS, ATTN_ALW, ATTN_WRKD, ATTN_LDAY, TOTALDAYS, LOP
        FROM GTT_WAGECALCULATION     
    )
    LOOP
        LV_ROWNUM := LV_ROWNUM+1;
        
        AS_XLSX.CELL( 1, LV_ROWNUM, C1.SLNO, P_BORDERID => AS_XLSX.GET_BORDER( '','thin','', 'thin' ) );
        AS_XLSX.CELL( 2, LV_ROWNUM,C1.TOKENNO, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 3, LV_ROWNUM,C1.EMPLOYEENAME, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 4, LV_ROWNUM,C1.GRADEDESC, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 5, LV_ROWNUM,C1.BASIC_RT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 6, LV_ROWNUM,C1.ARREAR, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 7, LV_ROWNUM,C1.BASIC, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
       
        AS_XLSX.CELL( 8, LV_ROWNUM,C1.SHIFT_B, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 9, LV_ROWNUM,C1.SHIFT_C, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 10, LV_ROWNUM,C1.SHIFTB_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 11, LV_ROWNUM,C1.SHIFTC_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 12, LV_ROWNUM,C1.TOTAL_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 13, LV_ROWNUM,C1.SHIFT_ALW, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 14, LV_ROWNUM,C1.ATTN_WRKD, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 15, LV_ROWNUM,C1.ATTN_LDAY, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 16, LV_ROWNUM,C1.TOTALDAYS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 17, LV_ROWNUM,C1.ATTN_ALW, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 18, LV_ROWNUM,C1.LOP, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
 
    END LOOP;       
   
    LV_ROWNUM := LV_ROWNUM + 1;  
    
    AS_XLSX.CELL( 1, LV_ROWNUM, 'TOTAL', P_BORDERID => AS_XLSX.GET_BORDER( 'double','double','', '' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
    AS_XLSX.CELL( 2, LV_ROWNUM,'', P_BORDERID => AS_XLSX.GET_BORDER( 'double','double','', '' ) );
    AS_XLSX.CELL( 3, LV_ROWNUM,'', P_BORDERID => AS_XLSX.GET_BORDER( 'double','double','', '' ) );
    AS_XLSX.CELL( 4, LV_ROWNUM,'', P_BORDERID => AS_XLSX.GET_BORDER( 'double','double','', '' ) );
    AS_XLSX.MERGECELLS(1, LV_ROWNUM, 4, LV_ROWNUM, 1);  
   

    FOR C2 IN (  
        SELECT SUM(BASIC_RT) BASIC_RT, SUM(ARREAR) ARREAR, SUM(BASIC) BASIC,
        SUM(SHIFT_A) SHIFT_A, SUM(SHIFT_B) SHIFT_B, SUM(SHIFT_C) SHIFT_C, SUM(SHIFT_ALW) SHIFT_ALW, 
        SUM(SHIFTA_HRS) SHIFTA_HRS, SUM(SHIFTB_HRS) SHIFTB_HRS, SUM(SHIFTC_HRS) SHIFTC_HRS,
        SUM(TOTAL_HRS) TOTAL_HRS, SUM(ATTN_ALW) ATTN_ALW, SUM(ATTN_WRKD) ATTN_WRKD, SUM(ATTN_LDAY) ATTN_LDAY, SUM(TOTALDAYS) TOTALDAYS, SUM(LOP) LOP
        FROM GTT_WAGECALCULATION     
    )
    LOOP
        AS_XLSX.CELL( 5, LV_ROWNUM,C2.BASIC_RT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 6, LV_ROWNUM,C2.ARREAR, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 7, LV_ROWNUM,C2.BASIC, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
       
        AS_XLSX.CELL( 8, LV_ROWNUM,C2.SHIFT_B, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 9, LV_ROWNUM,C2.SHIFT_C, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 10, LV_ROWNUM,C2.SHIFTB_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 11, LV_ROWNUM,C2.SHIFTC_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 12, LV_ROWNUM,C2.TOTAL_HRS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 13, LV_ROWNUM,C2.SHIFT_ALW, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 14, LV_ROWNUM,C2.ATTN_WRKD, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 15, LV_ROWNUM,C2.ATTN_LDAY, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 16, LV_ROWNUM,C2.TOTALDAYS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 17, LV_ROWNUM,C2.ATTN_ALW, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
        AS_XLSX.CELL( 18, LV_ROWNUM,C2.LOP, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ), p_numFmtId => as_xlsx.get_numFmt( '0.00' ) );
 
    END LOOP;    
    



    LV_ROWNUM := LV_ROWNUM + 1;  
    AS_XLSX.CELL( 1, LV_ROWNUM, LV_PRINTDATE , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'left' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
    AS_XLSX.MERGECELLS(1, LV_ROWNUM, 18, LV_ROWNUM, 1);   
        
    AS_XLSX.SAVE( L_DIR, L_FILE );
END;
/