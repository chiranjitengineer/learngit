SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%gratuity%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE='0110041401'


UPDATE  MENUMASTER_RND SET MENUTAG2='PROC_RPT_GRATUITYWORKSHT_EXL('COMPANYCODE','DIVISIONCODE','YEARCODE','01/04/2020','31/12/2020','','','','''001544''')'
WHERE MENUCODE='0110041401'

SELECT * FROM GRATUITYSETTLEMENT

SELECT COUNT(TOKENNO) TOTAL_NO, COUNT(CASE WHEN GRATURITYENTILE='YES' THEN 1 ELSE 0 END) GR_TOTAL_NO
                FROM GTT_GRATUITYWORKSHEET

EXEC PROC_RPT_GRATUITYWORKSHT_EXL('NJ0001','0002','2020-2021','01/04/2020','31/12/2020','','','','''001544''')

PROC_RPT_GRATUITYWORKSHT_EXL('COMPANYCODE','DIVISIONCODE','YEARCODE','mskFROMDATE','mskTODATE','btnUNITCODE','btnCategory','btnDepartment','btnTOKENNO')


    SELECT *  FROM GTT_GRATUITYWORKSHEET WHERE 1=1;

    SELECT *  FROM GTT_EXCEL_REPORT WHERE 1=1;

('COMPANYCODE','DIVISIONCODE','YEARCODE','txtYEARMONTH','btnUnit','btnCategory')


SELECT * FROM ROLEDETAILS
WHERE MENUCODE=''


SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG = ''

SELECT * FROM SYS_TFMAP
WHERE SYS_TABLENAME_ACTUAL=''