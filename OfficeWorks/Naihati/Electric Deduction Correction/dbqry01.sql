SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%elec%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE='0110040353'

SELECT * FROM ROLEDETAILS
WHERE MENUCODE=''

SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG=''

ELECTRICITY BILL OUTSTANDING


select PROC_ELCTY_BILL_OSTNDG

exec PROC_ELCTY_BILL_OSTNDG('NJ0001','0002','15/01/2021','15/01/2021','''04305''','Active Worker Presentally Alloted')


exec PROC_ELCTY_BILL_OSTNDG('NJ0001','0002','15/02/2021','15/02/2021','')

exec PROC_ELCTY_BILL_OSTNDG('NJ0001','0002','31/12/2020','31/12/2020','')

INSERT INTO EB

select * from GTT_ELECTRICBILL_OUTSTANDING
WHERE TOKENNO='00046'

select * from ELECTRICMETERREADING
where tokenno='00046'

select * from ELECTRICMETERREADING
where tokenno='00060'


SELECT DEDUCTIONDATE,WORKERSERIAL,DEDUCTEDAMT ELEC_BAL_AMT  
FROM ELECTRICDEDUCTIONBREAKUP    
WHERE COMPANYCODE='NJ0001'     
AND DIVISIONCODE= '0002'  
AND DEDUCTIONDATE <= TO_DATE('15/01/2021','DD/MM/YYYY')  
AND tokenno='00060'
                 
                 
  SELECT * FROM EB