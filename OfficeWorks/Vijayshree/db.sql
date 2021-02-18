SELECT WPSWORKERMAST.COMPANYCODE,WPSWORKERMAST.DIVISIONCODE,WPSWORKERMAST.WORKERSERIAL,  WORKERNAME,TOKENNO,WPSWORKERMAST.ESINO,  EMPLOYEEBIO.BIO,EMPLOYEEBIO.BIOBLOB,EMPLOYEEBIO.FINGER_ID  FROM WPSWORKERMAST LEFT OUTER JOIN EMPLOYEEBIO ON WPSWORKERMAST.WORKERSERIAL=EMPLOYEEBIO.WORKERSERIAL  WHERE WPSWORKERMAST.COMPANYCODE='0003'  AND WPSWORKERMAST.DIVISIONCODE='0032'  AND TOKENNO='HW0112Y'  ORDER BY FINGER_ID





create table EDRSDOCS
(
companycode varchar2(10),
divisioncode varchar2(10),
workerserial varchar2(10)
)


HW7394G 00827   ABBUL HASAN     right hand
XW6560  04126   IMAMUDDIN       left hand


delete from employeebio where workerserial not in ('00827','04126')


