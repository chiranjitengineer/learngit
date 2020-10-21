SELECT * FROM MENUMASTER_RND
WHERE MENUDESC LIKE 'PF Loan Entry'

GPS/Pages/Transaction/pgPFLoanEntry.aspx

PF ACCOUNTS/Pages/Transaction/pgPFLoanEntry.aspx

SELECT * FROM pfloanmaster


update menumaster_rnd
set URLSRC='GPS/Pages/Transaction/pgPFLoanEntry_New.aspx'
where menucode='011002010101'

5954

EXEC PROC_PFLOANBLNC_NEW('JT0069','0002','21/10/2020','21/10/2020','PF','')

SELECT * FROM GBL_PFLOANBLNC

  