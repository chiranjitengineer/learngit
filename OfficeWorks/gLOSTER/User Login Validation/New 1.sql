exec PROC_CHECKLOGINVALIDATION('0001','SWT','111')

select * from login
where username='SWT'

SELECT * from MENUMASTER_rnd
WHERE MENUDESC LIKE 'User%'

UPDATE LOGIN set NOOFWRONGATTEMPT = 0
WHERE COMPANYCODE=P_COMPANYCODE
AND USERNAME=P_LOGINUSER
AND PASSWORD=P_PASSWORD;


PROC_CHECKOLDPASSWORD