
-------------------------------------------------------------------------
--UPDATE ELECTRICMETERREADING TABLE COLUMN FROM (9,5) TO (15,5) 
-------------------------------------------------------------------------
alter table ELECTRICMETERREADING modify BILLAMOUNT number(15,5)


alter table ELECTRICMETERREADING modify PREVIOUSDUEAMOUNT number(15,5)


alter table ELECTRICMETERREADING modify CONTRIBUTIONAMOUNT number(15,5)


alter table ELECTRICMETERREADING modify EMIAMOUNT number(15,5)



-------------------------------------------------------------------------
--SELECT DATA FROM SYS_TFMAP FOR TABLE GBL_ELEMETERREAD
-------------------------------------------------------------------------

  
SELECT * FROM SYS_TFMAP
WHERE SYS_TABLENAME_TEMP = 'GBL_ELEMETERREAD'


-------------------------------------------------------------------------
--UPDATE DATA FROM SYS_TFMAP FOR TABLE GBL_ELEMETERREAD
-------------------------------------------------------------------------

UPDATE SYS_TFMAP SET 
SYS_COLUMN_LENGTH = 15
WHERE SYS_TABLENAME_TEMP='GBL_ELEMETERREAD'
AND SYS_DATATYPE='NUMBER'
AND SYS_TABLE_SEQUENCIER='20120'

--SYS_TABLE_SEQUENCIER, SYS_TABLENAME_TEMP, SYS_DATATYPE, SYS_COLUMN_LENGTH

-------------------------------------------------------------------------
--CREATE GBL TABLE 
-------------------------------------------------------------------------

EXEC PROC_CREATE_GBL_TMP_TABLES(20120,0)
