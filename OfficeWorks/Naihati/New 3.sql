select * from wpswagesdetails
where tokenno = '84245'
and FORTNIGHTSTARTDATE = 
(
   select max(FORTNIGHTSTARTDATE) from wpswagesdetails
    where tokenno = '84245' 
)


select * from wpswagesdetails
where tokenno = '84245'
and FORTNIGHTSTARTDATE = 
(
   select max(FORTNIGHTSTARTDATE) from wpswagesdetails
    where tokenno = '84245' 
)

select * from wpswagesdetails
where FORTNIGHTSTARTDATE in 
(
    select FORTNIGHTSTARTDATE from 
    (
        select rownum slno, FORTNIGHTSTARTDATE from 
        (
            select FORTNIGHTSTARTDATE from wpswagesdetails where tokenno = '84245'  order by FORTNIGHTSTARTDATE desc
        )
    )
    where slno <= 6
)
and tokenno = '84245'
 