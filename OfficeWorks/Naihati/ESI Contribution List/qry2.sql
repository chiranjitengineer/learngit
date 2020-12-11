
SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%MON%ESI%')


PROC_RPT_ESICONT_MONTHLY_NJML


SELECT * FROM PISPAYTRANSACTION
WHERE 1=1
--AND TOKENNO IN (
--'71016',
--'71546',
--'71579',
--'71580',
--'77266',
--'78001',
--'78016',
--'78091',
--'78096' 
--)
AND YEARMONTH='202011'


--PF LOAN DATA NOT FOUND FROM QRY

70143 ---

70180   ---



EXEC PROC_RPT_ESICONT_MONTHLY_NJML('NJ0001','0002','01/11/2020','30/11/2020')


                                            P_COMPANYCODE VARCHAR2,
                                            P_DIVISIONCODE VARCHAR2,
                                            P_FROMDATE VARCHAR2,
                                            P_TODATE VARCHAR2,
                                            P_TOKENNO VARCHAR2 DEFAULT NULL
                                           )
                                           
SELECT * FROM PISEMPLOYEEMASTER
WHERE 1=1
AND TOKENNO IN (
'71016',
'71546',
'71579',
'71580',
'77266',
'78001',
'78016',
'78091',
'78096' 
)                                           