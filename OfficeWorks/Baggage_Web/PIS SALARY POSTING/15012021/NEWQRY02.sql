prc_pissalary_postingdata


select * from pisarreartransaction
where unitcode='002'
and transactiontype='ARREAR'
AND YEARMONTH='202011'

select * from pisPAYtransaction
where unitcode='001'
and transactiontype='SALARY'
AND YEARMONTH='202011'


select * from pisPAYtransaction
where unitcode='002'
and transactiontype='SALARY'
--AND YEARMONTH='202010'
AND NVL(SARR_ARRE,0) > 0


EXEC prc_pissalary_postingdata('0001','002','SALARY PROCESS','202010','002','','','') 

EXEC prc_pissalary_postingdata('0001','002','ARREAR PROCESS','202010','002','','','') 



EXEC prc_pissalary_postingdata('0001','001','SALARY PROCESS','202011','001','','','') 

EXEC prc_pissalary_postingdata('0001','001','ARREAR PROCESS','202011','001','','','') 