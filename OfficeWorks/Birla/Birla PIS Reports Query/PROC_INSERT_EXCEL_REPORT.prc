CREATE OR REPLACE PROCEDURE BIRLANEW.PROC_INSERT_EXCEL_REPORT
(
    P_ROWINDEX NUMBER,
    P_EXCELROWTYPE VARCHAR2,
    P_EXCELROWSTYLE VARCHAR2,
    P_EXCELVALUES VARCHAR2,
    P_EXCELTAG VARCHAR2
)
AS
BEGIN


    INSERT INTO GTT_EXCEL_REPORT(ROWINDEX, EXCELROWTYPE, EXCELROWSTYLE, EXCELVALUES, EXCELTAG)
    VALUES (P_ROWINDEX, P_EXCELROWTYPE, P_EXCELROWSTYLE, P_EXCELVALUES, P_EXCELTAG);
    
END;
/