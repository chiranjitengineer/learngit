SELECT * FROM MENUMASTER_RND
WHERE MENUDESC LIKE 'Gratuity%'
and projectname='WPS'

GENERAL/Pages/Common/pgGratuityEntitlement.aspx

SELECT TOKENNO, COUNT(TOKENNO) CNT FROM WORKERVIEWGRATUITY
GROUP BY TOKENNO
HAVING COUNT(TOKENNO) > 1

SELECT TOKENNO||'~'||WORKERNAME||'~'||DEPARTMENTNAME||'~'||DESIGNATION ||'~'||TO_CHAR(DATEOFJOINING,'DD/MM/YYYY') ||'~'||ESINO ||'~'||TO_CHAR(PFMEMBERSHIPDATE,'DD/MM/YYYY') ||'~'||LBNO ||'~'||TO_CHAR(DATEOFCONFIRMATION,'DD/MM/YYYY')||'~'||TO_CHAR(DATEOFRETIREMENT,'DD/MM/YYYY') ||'~'||REMARKS||'~'||ATTENDENCETYPE||'~'||WORKERSERIAL  
FROM WORKERVIEWGRATUITY WHERE COMPANYCODE='NJ0001' AND DIVISIONCODE='0002' AND (WORKERSERIAL='04053' OR TOKENNO='04053')


SELECT * FROM WORKERVIEWGRATUITY
WHERE TOKENNO LIKE '93318%'

GROUP BY TOKENNO
HAVING COUNT(TOKENNO) > 1

SELECT * FROM WPSWORKERMAST
WHERE TOKENNO LIKE '933%'

SELECT * FROM GRATUITYENTITLEMENTYEAR
WHERE TOKENNO = '04053'


CREATE TABLE GRATUITYENTITLEMENTYEAR_BK AS



SELECT DISTINCT TOKENNO FROM GRATUITYENTITLEMENTYEAR

SELECT * FROM SYS_HELP_QRY
where QRY_ID LIKE '6930'


SELECT * FROM SYS_HELP_QRY
where QRY_ID LIKE '6504'

6930

SELECT * FROM SYS_HELP_QRY
where QRY_ID LIKE '6505'



SELECT * FROM GRATUITYENTITLEMENTYEAR


SELECT DISTINCT WORKERSERIAL,TOKENNO,WORKERNAME FROM WORKERVIEWGRATUITY
WHERE COMPANYCODE=<<COMPANYCODE>>
  AND DIVISIONCODE=<<DIVISIONCODE>>
  AND MODULE=<<MODULE>>
  AND WORKERSERIAL IN 
  ( 
    SELECT DISTINCT WORKERSERIAL FROM GRATUITYENTITLEMENTYEAR
    WHERE COMPANYCODE=<<COMPANYCODE>>
      AND DIVISIONCODE=<<DIVISIONCODE>>
      AND MODULE=<<MODULE>>
  )   
  ORDER BY TOKENNO,WORKERSERIAL
  
  
SELECT DISTINCT WORKERSERIAL,TOKENNO,WORKERNAME FROM WORKERVIEWGRATUITY
WHERE COMPANYCODE='NJ0001'
  AND DIVISIONCODE='0002'
  AND MODULE='WPS'
   AND WORKERSERIAL IN ( 
    SELECT DISTINCT WORKERSERIAL FROM GRATUITYENTITLEMENTYEAR
  ) 
  ORDER BY TOKENNO,WORKERSERIAL
  
  
  
------------------------------------------------------------------


SELECT * FROM GRATUITYENTITLEMENTYEAR
WHERE TOKENNO = '04053'



delete FROM GRATUITYENTITLEMENTYEAR
WHERE TOKENNO = '00031'




SELECT GRATUITYAPPLICABLE||'~'||GRATUITYSETTELMENTDATE FROM WPSWORKERMAST WHERE COMPANYCODE = 'NJ0001' AND DIVISIONCODE = '0002' AND TOKENNO = '04053' 
UNION ALL
SELECT GRATUITYAPPLICABLE||'~'||GRATUITYSETTELMENTDATE FROM PISEMPLOYEEMASTER WHERE COMPANYCODE = 'NJ0001' AND DIVISIONCODE = '0002' AND TOKENNO = '04053' 


SELECT GRATUITYAPPLICABLE||'~'||GRATUITYSETTELMENTDATE FROM WPSWORKERMAST WHERE COMPANYCODE = 'NJ0001' AND DIVISIONCODE = '0002' AND TOKENNO = '04053'


SELECT * FROM WPSWORKERMAST WHERE COMPANYCODE = 'NJ0001' AND DIVISIONCODE = '0002' AND TOKENNO = '04053'


  
------------------------------------------------------------------
