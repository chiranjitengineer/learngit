SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%GRATUITY WO%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE=''

SELECT * FROM ROLEDETAILS
WHERE MENUCODE=''

SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG=''


PROC_RPT_GRATUITYWORKSHT_EXL('COMPANYCODE','DIVISIONCODE','YEARCODE','mskFROMDATE','mskTODATE','','','','btnTOKENNO')

SELECT * FROM 