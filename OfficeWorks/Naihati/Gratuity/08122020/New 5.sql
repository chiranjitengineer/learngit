select * from pfemployeemaster
where tokenno in ('71580','71579','71581')

select * from pisemployeemaster
where tokenno in ('71580','71579','71581')

exec PROC_RPT_ECR('NJ0001','0002','2020-2021','202011','PIS','''40''')