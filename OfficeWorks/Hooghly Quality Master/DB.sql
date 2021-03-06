SALESQUALITYMASTER


SELECT * FROM SALESQUALITYMASTER


-----------------------------------------------
-- add columns  PORTER,SHOTS,OZ_YDS
-----------------------------------------------

ALTER TABLE SALESQUALITYMASTER
ADD PORTER NUMBER(15,6)


ALTER TABLE SALESQUALITYMASTER
ADD SHOTS NUMBER(15,6)


ALTER TABLE SALESQUALITYMASTER
ADD OZ_YDS NUMBER(15,6)

-----------------------------------------------
-- sys tfmap
-----------------------------------------------





SELECT * FROM SYS_TFMAP
WHERE SYS_TABLE_SEQUENCIER = '3029'
and SYS_COLUMNNAME in ('PORTER','SHOTS','OZ_YDS')

SELECT * FROM SYS_TFMAP
WHERE SYS_TABLENAME_ACTUAL = 'SALESQUALITYMASTER'


--PORTER,SHOTS,OZ_YDS
SET DEFINE OFF;
Insert into SYS_TFMAP
   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
 Values
   (3029, 'SALESQUALITYMASTER', 'GBL_SALESQUALITYMASTER', 'OZ_YDS', 32, 
    'NUMBER', 15, 6, 'N', 'txtOZ_YDS', 
    TO_TIMESTAMP('10/12/2014 12:41:26.000000 PM','DD/MM/YYYY fmHH12fm:MI:SS.FF AM'), 'Y', NULL, NULL);
Insert into SYS_TFMAP
   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
 Values
   (3029, 'SALESQUALITYMASTER', 'GBL_SALESQUALITYMASTER', 'PORTER', 30, 
    'NUMBER', 15, 6, 'N', 'txtPORTER', 
    TO_TIMESTAMP('10/12/2014 12:41:26.000000 PM','DD/MM/YYYY fmHH12fm:MI:SS.FF AM'), 'Y', NULL, NULL);
Insert into SYS_TFMAP
   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
 Values
   (3029, 'SALESQUALITYMASTER', 'GBL_SALESQUALITYMASTER', 'SHOTS', 31, 
    'NUMBER', 15, 6, 'N', 'txtSHOTS', 
    TO_TIMESTAMP('10/12/2014 12:41:26.000000 PM','DD/MM/YYYY fmHH12fm:MI:SS.FF AM'), 'Y', NULL, NULL);
COMMIT;


EXEC PROC_CREATE_GBL_TMP_TABLES(3029,0)

-----------------------------------------------
-- sys tfmap
-----------------------------------------------



select * from SALESQUALITYMASTER
where porter>0


SELECT * FROM LOANINTEREST

EXEC PRC_GEN_LOAN_INT_CALC ('BJ0056','0001','SWT',NULL,'31/01/2021','31/01/2021','PIS','NO','PISPAYTRANSACTION_SWT');


DELETE FROM PIS_ERROR_LOG

SELECT * FROM PIS_ERROR_LOG

SELECT * FROM LOANINTEREST WHERE LOANCODE <> 'BL'

( 
    P_COMPCODE VARCHAR2, 
    P_DIVCODE VARCHAR2,
    P_USER    VARCHAR2,   
    P_LOANCODE VARCHAR2, 
    P_LOANDATE VARCHAR2, 
    P_AS_ON_DT VARCHAR2,
    P_MODULE    VARCHAR2 DEFAULT 'WPS',
    P_WAGESPROCESS VARCHAR2 DEFAULT 'YES',
    P_TEMPTABLE  varchar2 DEFAULT NULL,   
    P_CATEGORY  VARCHAR2 DEFAULT NULL,
    P_GRADE     VARCHAR2 DEFAULT NULL,
    P_TOKEN VARCHAR2 DEFAULT NULL
)