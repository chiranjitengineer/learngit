
select * from (
select tokenno, employeename,dateofbirth,add_months(dateofbirth,58*12) dd1, DATEOFRETIRE from pisemployeemaster
)
where dd1 > '01-jan-2021'
and dd1 < '31-may-2021'

select * from pisemployeemaster
where tokenno like '%014'


 SELECT * FROM PISEMPLOYEEMASTER 
    WHERE WORKERSERIAL IN 
    (
        SELECT WORKERSERIAL FROM(
            SELECT TOKENNO,WORKERSERIAL,(ADD_MONTHS(DATEOFBIRTH,58*12)) DTRETIRE, LAST_DAY(TO_DATE('202103','YYYYMM')) DT_TODATE FROM PISEMPLOYEEMASTER
        )
        WHERE DTRETIRE < DT_TODATE
    )
    AND EPFAPPLICABLE='Y'
    AND EMPLOYEESTATUS = 'ACTIVE'
    
    ;