CREATE OR REPLACE PROCEDURE BAGGAGE_WEB.PROC_RPT_PIS_SALARYREGISTER
(
    P_COMPANYCODE         VARCHAR2,
    P_DIVISIONCODE        VARCHAR2,
    P_YEARCODE            VARCHAR2,
    P_YEARMONTH           VARCHAR2,
    P_UNIT                VARCHAR2 DEFAULT NULL,
    P_CATEGORY            VARCHAR2 DEFAULT NULL,
    P_GRADE               VARCHAR2 DEFAULT NULL,
    P_WORKERSERIAL        VARCHAR2 DEFAULT NULL,
    P_FILE                VARCHAR2  DEFAULT 'SWTPISSALARY_REGISTER'
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
    
    LV_HOLIDAY  VARCHAR2(200);
     
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
   
    LV_RPT_CAPTION:= 'PF STATEMENT FOR THE MONTH OF '||LV_MONTH||', '|| LV_YEAR;

     
    DELETE FROM GTT_SALARYREGISTER_EXCEL WHERE 1=1;



     

    LV_SQLSTR := NULL;
    LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_SALARYREGISTER_EXCEL'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '('|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SLNO, TOKENNO, WORKERSERIAL, EMPLOYEENAME, FATHERNAME, SEX, DATEOFJOIN, DATEOFBIRTH, DEPARTMENTCODE, '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    DEPARTMENTDESC, ESINO, PFNO,ATTENDANCE,PAYABLE_DAYS, BASIC, HRA, CONV_ALLW, MEDICAL_ALLW, ATN_INCTV, SPL_ALLW, '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    OT, MISC_EARNING, OTHERS, TOTAL_AMOUNT, ESI_E,PF_E, PTAX, TDS, CANTEEN,  INSURANCE, '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SAL_ADV, FINE, OTHERS_DED, NETSALARY'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || ')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'SELECT ROW_NUMBER() OVER (ORDER BY A.TOKENNO) SLNO, B.TOKENNO, B.WORKERSERIAL,B.EMPLOYEENAME, B.FATHERNAME,B.SEX, B.DATEOFJOIN, B.DATEOFBIRTH,B.DEPARTMENTCODE,C.DEPARTMENTDESC,B.ESINO,B.PFNO,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'A.ATTENDANCE,A.PAYABLE_DAYS, A.BASIC, A.HRA, A.CONV_ALLW, A.MEDICAL_ALLW, A.ATN_INCTV, A.SPL_ALLW, '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'A.OT, A.MISC_EARNING, A.OTHERS, A.TOTAL_AMOUNT, A.ESI_E, A.PF_E, A.PTAX, A.TDS, A.CANTEEN, A.INSURANCE, A.SAL_ADV, A.FINE, A.OTHERS_DED, A.NETSALARY'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'FROM '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '('|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    SELECT COMPANYCODE, DIVISIONCODE,UNITCODE,CATEGORYCODE,GRADECODE, TOKENNO, WORKERSERIAL, DEPARTMENTCODE,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    ATTN_SALD ATTENDANCE,ATTN_CALCF PAYABLE_DAYS, NVL(BASIC,0) BASIC, NVL(HRA,0) HRA, NVL(CONV_ALLW,0) CONV_ALLW, 0 MEDICAL_ALLW, '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    NVL(ATN_INCTV,0) ATN_INCTV, 0 SPL_ALLW, 0 OT, 0 MISC_EARNING, (NVL(CONV_ALW,0)+NVL(CHRG_HAND,0)+NVL(EDU_ALW,0)+NVL(FIX_ALW,0)+NVL(CLEAN_ALW,0)+NVL(INSP_ALW,0)+NVL(LGBK_ALW,0)+NVL(WASH_ALW,0)+NVL(PUNC_ALW,0)+NVL(PERF_ALW,0)+NVL(SHIFT_ALW,0)+NVL(CHILD_ALLW,0)+NVL(SERV_ALLW,0)+NVL(SOFT_ALLW,0)+NVL(PERS_ALLW,0)+NVL(INCENTIVE,0)+NVL(OTH_ALLW,0)) OTHERS, NVL(TOTEARN,0) TOTAL_AMOUNT, NVL(ESI_E,0) ESI_E, '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    NVL(PF_E,0) PF_E, NVL(PTAX,0) PTAX, 0 TDS, NVL(CANTEEN,0) CANTEEN, 0 INSURANCE, NVL(TOTLOANAMT,0) SAL_ADV, 0 FINE, 0 OTHERS_DED, NVL(NETSALARY,0) NETSALARY'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    FROM PISPAYTRANSACTION'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    WHERE YEARMONTH='''||P_YEARMONTH||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND COMPANYCODE='''||P_COMPANYCODE||''''|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    AND DIVISIONCODE='''||P_DIVISIONCODE||''''|| CHR(10);

    LV_SQLSTR := LV_SQLSTR || ') A, PISEMPLOYEEMASTER B, PISDEPARTMENTMASTER C'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'WHERE A.WORKERSERIAL=B.WORKERSERIAL(+)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.DEPARTMENTCODE=C.DEPARTMENTCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.COMPANYCODE=C.COMPANYCODE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND A.DIVISIONCODE=C.DIVISIONCODE'|| CHR(10);


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

--    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);

    EXECUTE IMMEDIATE LV_SQLSTR;
     

    
    UPDATE GTT_SALARYREGISTER_EXCEL
    SET EX1 = TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(P_YEARMONTH,'YYYYMM')),'DD')),
    COMPANYCODE = P_COMPANYCODE,
    DIVISIONCODE = P_DIVISIONCODE,
    YEARMONTH = P_YEARMONTH,
    YEARCODE = P_YEARCODE,
    REPORTHEADER = 'SALARY REGISTER FOR MONTH OF '||TO_CHAR(TO_DATE(P_YEARMONTH,'YYYYMM'),'MON-YY')
    WHERE 1=1;
    
    
     
    UPDATE GTT_SALARYREGISTER_EXCEL A
    SET (COMPANYNAME,DIVISIONNAME,COMPANYADDRESS,DIVISIONADDRESS, HOLYDAY_NAMES)=
    (
        SELECT COMPANYNAME, DIVISIONNAME,COMPANYADDRESS,DIVISIONADDRESS, HOLYDAY_NAMES FROM COMPANYMAST C, DIVISIONMASTER D,
        (
            SELECT WM_CONCAT(HOLIDAYDESC) HOLYDAY_NAMES FROM PISHOLIDAYMASTER
            WHERE COMPANYCODE=P_COMPANYCODE
            AND DIVISIONCODE=P_DIVISIONCODE
            AND TO_CHAR(HOLIDAYDATE,'YYYYMM')=P_YEARMONTH
            AND ISPAID='Y'
        )
        WHERE D.COMPANYCODE=C.COMPANYCODE
        AND D.COMPANYCODE=P_COMPANYCODE
        AND D.DIVISIONCODE=P_DIVISIONCODE    
    )
    WHERE 1=1;
    
    RETURN;
    ---------------START EXCEL REPORT------------------------
    
    AS_XLSX.CLEAR_WORKBOOK;
    AS_XLSX.NEW_SHEET;
    
    
    ----------------- Set column Width ----------------------
    AS_XLSX.SET_COLUMN_WIDTH(1,7,1); --SL NO
    AS_XLSX.SET_COLUMN_WIDTH(2,30,1);--NAME OF THE EMPLOYEE FATHER/HUSBAND NAME
    AS_XLSX.SET_COLUMN_WIDTH(3,10,1);--SEX	
    AS_XLSX.SET_COLUMN_WIDTH(4,30,1);--DATE OF JOINING/DATE OF BIRTH	
    AS_XLSX.SET_COLUMN_WIDTH(5,20,1);--EMP. NO/SL NO IN REGISTER EMPLOYEES
    AS_XLSX.SET_COLUMN_WIDTH(6,20,1);--DIGN./DEPT.
    AS_XLSX.SET_COLUMN_WIDTH(7,20,1);--ESI NO.
    AS_XLSX.SET_COLUMN_WIDTH(8,20,1);--P.F. NO
    AS_XLSX.SET_COLUMN_WIDTH(9,40,1);--Units of work done (If Place raised)
    AS_XLSX.SET_COLUMN_WIDTH(10,20,1);--ATTENDANCE
    AS_XLSX.SET_COLUMN_WIDTH(11,30,1);--NO OF PAYABLE DAYS/TOTAL UNIT OF WORK DONE
    AS_XLSX.SET_COLUMN_WIDTH(12,30,1);--NAME OF HOLIDAY FOR WHICH WAGES HAVE BEEN PAID
    AS_XLSX.SET_COLUMN_WIDTH(13,20,1);--BASIC/DA/VDA
    AS_XLSX.SET_COLUMN_WIDTH(14,20,1);--HRA
    AS_XLSX.SET_COLUMN_WIDTH(15,20,1);--CONV. ALLOW.
    AS_XLSX.SET_COLUMN_WIDTH(16,20,1);--MEDICAL ALLOW.
    AS_XLSX.SET_COLUMN_WIDTH(17,30,1);--ATTN INCTV./ ALLOW./BOUNUS
    AS_XLSX.SET_COLUMN_WIDTH(18,20,1);--SPL.ALL
    AS_XLSX.SET_COLUMN_WIDTH(19,20,1);--O.T
    AS_XLSX.SET_COLUMN_WIDTH(20,20,1);--MISC EARNING
    AS_XLSX.SET_COLUMN_WIDTH(21,20,1);--OTHERS
    AS_XLSX.SET_COLUMN_WIDTH(22,20,1);--TOTAL AMOUNT
    AS_XLSX.SET_COLUMN_WIDTH(23,20,1);--ESI
    AS_XLSX.SET_COLUMN_WIDTH(24,20,1);--P.F.
    AS_XLSX.SET_COLUMN_WIDTH(25,20,1);--PT
    AS_XLSX.SET_COLUMN_WIDTH(26,20,1);--TDS	
    AS_XLSX.SET_COLUMN_WIDTH(27,20,1);--CANTEEN
    AS_XLSX.SET_COLUMN_WIDTH(28,20,1);--INSURANCE
    AS_XLSX.SET_COLUMN_WIDTH(29,20,1);--SAL. ADV.
    AS_XLSX.SET_COLUMN_WIDTH(30,20,1);--FINE
    AS_XLSX.SET_COLUMN_WIDTH(31,20,1);--OTHERS
    AS_XLSX.SET_COLUMN_WIDTH(32,25,1);--TOTAL NET PAYABLE
    AS_XLSX.SET_COLUMN_WIDTH(33,25,1);--DATE OF PAYMENT
    AS_XLSX.SET_COLUMN_WIDTH(34,30,1);--SIGNATURE OF EMPLOYEE
    

    AS_XLSX.MERGECELLS(1, 1, 34, 1, 1);   
    AS_XLSX.CELL( 1, 1, LV_COMPANYNAME  , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA',p_BOLD => TRUE) );              --,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )             

    AS_XLSX.MERGECELLS(1, 2, 34, 2, 1);   
    AS_XLSX.CELL( 1, 2, LV_DIVADDRESS , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
    --AS_XLSX.FREEZE_PANE(2, 5);

    AS_XLSX.MERGECELLS(1, 3, 34, 3, 1);   
    AS_XLSX.CELL( 1, 3, LV_RPT_CAPTION , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
    --AS_XLSX.FREEZE_PANE(2, 5);


    AS_XLSX.CELL( 13, 4,'EARNINGS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'thin', 'double', 'double' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 12, p_BOLD => TRUE) );
   
    AS_XLSX.CELL( 23, 4,'DEDUCTION', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center' ), P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'thin', 'double', 'double' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 12, p_BOLD => TRUE) );
     --AS_XLSX.FREEZE_PANE(2, 5);

    AS_XLSX.MERGECELLS(13, 4, 22, 4, 1);   
    
    
    AS_XLSX.MERGECELLS(23, 4, 31, 4, 1);   
    

---------------set column headings

--SL NO	
--NAME OF THE EMPLOYEE FATHER/HUSBAND NAME
--SEX	
--DATE OF JOINING/DATE OF BIRTH	
--EMP. NO/SL NO IN REGISTER EMPLOYEES	
--DIGN./DEPT.	
--ESI NO.	
--P.F. NO
--Units of work done (If Place raised)							
--ATTENDANCE	
--NO OF PAYABLE DAYS/TOTAL UNIT OF WORK DONE	
--NAME OF HOLIDAY FOR WHICH WAGES HAVE BEEN PAID	
--BASIC/DA/VDA	
--HRA	
--CONV. ALLOW.	
--MEDICAL ALLOW.	
--ATTN INCTV./ ALLOW./BOUNUS	
--SPL.ALL	
--O.T	
--MISC EARNING	
--OTHERS	
--TOTAL AMOUNT	
--ESI	
--P.F.	
--PT	
--TDS	
--CANTEEN	
--INSURANCE	
--SAL. ADV.	
--FINE	
--OTHERS	
--TOTAL NET PAYABLE	
--DATE OF PAYMENT	
--SIGNATURE OF EMPLOYEE





-------------- 1 TO 10 ---------------------
AS_XLSX.CELL( 1, 5,'SL NO', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL( 2, 5,'NAME OF THE EMPLOYEE FATHER/HUSBAND NAME', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center', p_wrapText => true ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL( 3, 5,'SEX', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL( 4, 5,'DATE OF JOINING / DATE OF BIRTH', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center', p_wrapText => true ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL( 5, 5,'EMP. NO/SL NO IN REGISTER EMPLOYEES', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center', p_wrapText => true ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL( 6, 5,'DIGN./DEPT.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL( 7, 5,'ESI NO.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL( 8, 5,'P.F. NO', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL( 9, 5,'Units of work done (If Place raised)', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center', p_wrapText => true ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL( 10, 5,'ATTENDANCE', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );

-------------- 11 TO 20 ---------------------
AS_XLSX.CELL(11, 5,'NO OF PAYABLE DAYS / TOTAL UNIT OF WORK DONE', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center', p_wrapText => true  ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL(12, 5,'NAME OF HOLIDAY FOR WHICH WAGES HAVE BEEN PAID', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center', p_wrapText => true  ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL(13, 5,'BASIC/DA/VDA', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center', p_wrapText => true  ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL(14, 5,'HRA', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL(15, 5,'CONV. ALLOW.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL(16, 5,'MEDICAL ALLOW.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL(17, 5,'ATTN INCTV./ ALLOW./BOUNUS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center', p_wrapText => true  ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL(18, 5,'SPL.ALL', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL(19, 5,'O.T', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL(20, 5,'MISC EARNING', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );

-------------- 21 TO 30 ---------------------
AS_XLSX.CELL(21, 5,'OTHERS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL(22, 5,'TOTAL AMOUNT', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL(23, 5,'ESI', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL(24, 5,'P.F.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL(25, 5,'PT', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL(26, 5,'TDS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL(27, 5,'CANTEEN', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL(28, 5,'INSURANCE', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL(29, 5,'SAL. ADV.', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL(30, 5,'FINE', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );

-------------- 31 TO 34 ---------------------
AS_XLSX.CELL(31, 5,'OTHERS', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center' ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL(32, 5,'TOTAL NET PAYABLE', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center', p_wrapText => true  ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL(33, 5,'DATE OF PAYMENT', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center', p_wrapText => true  ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );
AS_XLSX.CELL(34, 5,'SIGNATURE OF EMPLOYEE', P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'center', p_vertical => 'center', p_wrapText => true  ),P_BORDERID => AS_XLSX.GET_BORDER( 'double', 'double', 'thin', 'thin' ),P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 10, p_BOLD => TRUE) );




---------- end column headings



    LV_ROWNUM := 5;
    
    
    
    
    FOR C1 IN (  
        SELECT SLNO, TOKENNO, WORKERSERIAL, EMPLOYEENAME, FATHERNAME, SEX, DATEOFJOIN, DATEOFBIRTH, 
        DEPARTMENTCODE, DEPARTMENTDESC, ESINO, PFNO, ATTENDANCE, PAYABLE_DAYS, HOLYDAY_NAMES, 
        BASIC, HRA, CONV_ALLW, MEDICAL_ALLW, ATN_INCTV, SPL_ALLW, OT, MISC_EARNING, OTHERS, 
        TOTAL_AMOUNT, ESI_E,PF_E, PTAX, TDS, CANTEEN, INSURANCE, SAL_ADV, FINE, OTHERS_DED, NETSALARY
        FROM GTT_SALARYREGISTER_EXCEL     
    )
    LOOP
        LV_ROWNUM := LV_ROWNUM+1;
        
               
        AS_XLSX.CELL( 1, LV_ROWNUM, C1.SLNO, P_BORDERID => AS_XLSX.GET_BORDER( '','thin','', 'thin' ) );
        AS_XLSX.CELL( 2, LV_ROWNUM,C1.EMPLOYEENAME, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 3, LV_ROWNUM,C1.SEX, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 4, LV_ROWNUM,C1.DATEOFJOIN, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 5, LV_ROWNUM,C1.TOKENNO, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 6, LV_ROWNUM,C1.DEPARTMENTDESC, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 7, LV_ROWNUM,C1.ESINO, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL( 8, LV_ROWNUM,C1.PFNO, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        ---------------------Units of work done (If Place raised)	
        ---------------------
        AS_XLSX.CELL( 10, LV_ROWNUM,C1.ATTENDANCE, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL(11, LV_ROWNUM,C1.PAYABLE_DAYS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL(12, LV_ROWNUM,C1.HOLYDAY_NAMES, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL(13, LV_ROWNUM,C1.BASIC, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL(14, LV_ROWNUM,C1.HRA, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL(15, LV_ROWNUM,C1.CONV_ALLW, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL(16, LV_ROWNUM,C1.MEDICAL_ALLW, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL(17, LV_ROWNUM,C1.ATN_INCTV, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL(18, LV_ROWNUM,C1.SPL_ALLW, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL(19, LV_ROWNUM,C1.OT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL(20, LV_ROWNUM,C1.MISC_EARNING, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL(21, LV_ROWNUM,C1.OTHERS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL(22, LV_ROWNUM,C1.TOTAL_AMOUNT, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL(23, LV_ROWNUM,C1.ESI_E, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL(24, LV_ROWNUM,C1.PF_E, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL(25, LV_ROWNUM,C1.PTAX, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL(26, LV_ROWNUM,C1.TDS, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL(27, LV_ROWNUM,C1.CANTEEN, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL(28, LV_ROWNUM,C1.INSURANCE, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL(29, LV_ROWNUM,C1.SAL_ADV, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL(30, LV_ROWNUM,C1.FINE, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL(31, LV_ROWNUM,C1.OTHERS_DED, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );
        AS_XLSX.CELL(32, LV_ROWNUM,C1.NETSALARY, P_BORDERID => AS_XLSX.GET_BORDER( 'thin', 'thin', 'thin', 'thin' ) );


          
    END LOOP;       
   
    LV_ROWNUM := LV_ROWNUM + 1;  
    
   
   

    LV_ROWNUM := LV_ROWNUM + 1;  
    AS_XLSX.CELL( 1, LV_ROWNUM, LV_PRINTDATE , P_ALIGNMENT => AS_XLSX.GET_ALIGNMENT( P_HORIZONTAL => 'left' ), P_FONTID => AS_XLSX.get_font('TAHOMA', p_fontsize => 8, p_BOLD => TRUE) );--,p_borderid => as_xlsx.get_border( 'double', 'double', 'double', 'double' )
    AS_XLSX.MERGECELLS(1, LV_ROWNUM, 9, LV_ROWNUM, 1);   
        
    AS_XLSX.SAVE( L_DIR, L_FILE );
END;
/