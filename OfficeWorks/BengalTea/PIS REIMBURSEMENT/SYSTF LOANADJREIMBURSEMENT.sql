EXEC PROC_CREATE_GBL_TMP_TABLES(20255,0)

SET DEFINE OFF;
Insert into SYS_TFMAP
   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
 Values
   (20255, 'LOANADJFROMREIMBURSE', 'GBL_LOANADJFROMREIMBURSE', 'CAPITALLOANBAL', 0, 
    'NUMBER', 10, 2, 'N', 'CAPITALLOANBAL', 
    TO_TIMESTAMP('19/03/2020 6:54:28.000000 PM','DD/MM/YYYY fmHH12fm:MI:SS.FF AM'), 'Y', NULL, NULL);
Insert into SYS_TFMAP
   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
 Values
   (20255, 'LOANADJFROMREIMBURSE', 'GBL_LOANADJFROMREIMBURSE', 'CAPITALREPAY', 0, 
    'NUMBER', 10, 2, 'N', 'CAPITALREPAY', 
    TO_TIMESTAMP('19/03/2020 6:54:28.000000 PM','DD/MM/YYYY fmHH12fm:MI:SS.FF AM'), 'Y', NULL, NULL);
Insert into SYS_TFMAP
   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
 Values
   (20255, 'LOANADJFROMREIMBURSE', 'GBL_LOANADJFROMREIMBURSE', 'COMPANYCODE', 1, 
    'VARCHAR2', 10, 0, 'Y', 'COMPANYCODE', 
    TO_TIMESTAMP('19/03/2020 6:54:28.000000 PM','DD/MM/YYYY fmHH12fm:MI:SS.FF AM'), 'Y', NULL, NULL);
Insert into SYS_TFMAP
   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
 Values
   (20255, 'LOANADJFROMREIMBURSE', 'GBL_LOANADJFROMREIMBURSE', 'COMPONENTCODE', 0, 
    'VARCHAR2', 10, 0, 'N', 'COMPONENTCODE', 
    TO_TIMESTAMP('19/03/2020 6:54:28.000000 PM','DD/MM/YYYY fmHH12fm:MI:SS.FF AM'), 'Y', NULL, NULL);
Insert into SYS_TFMAP
   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
 Values
   (20255, 'LOANADJFROMREIMBURSE', 'GBL_LOANADJFROMREIMBURSE', 'DIVISIONCODE', 2, 
    'VARCHAR2', 10, 0, 'Y', 'DIVISIONCODE', 
    TO_TIMESTAMP('19/03/2020 6:54:28.000000 PM','DD/MM/YYYY fmHH12fm:MI:SS.FF AM'), 'Y', NULL, NULL);
Insert into SYS_TFMAP
   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
 Values
   (20255, 'LOANADJFROMREIMBURSE', 'GBL_LOANADJFROMREIMBURSE', 'INTERESTLOANBAL', 0, 
    'NUMBER', 10, 2, 'N', 'INTERESTLOANBAL', 
    TO_TIMESTAMP('19/03/2020 6:54:28.000000 PM','DD/MM/YYYY fmHH12fm:MI:SS.FF AM'), 'Y', NULL, NULL);
Insert into SYS_TFMAP
   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
 Values
   (20255, 'LOANADJFROMREIMBURSE', 'GBL_LOANADJFROMREIMBURSE', 'INTERESTREPAY', 0, 
    'NUMBER', 10, 2, 'N', 'INTERESTREPAY', 
    TO_TIMESTAMP('19/03/2020 6:54:28.000000 PM','DD/MM/YYYY fmHH12fm:MI:SS.FF AM'), 'Y', NULL, NULL);
Insert into SYS_TFMAP
   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
 Values
   (20255, 'LOANADJFROMREIMBURSE', 'GBL_LOANADJFROMREIMBURSE', 'LOANCODE', 5, 
    'VARCHAR2', 10, 0, 'Y', 'LOANCODE', 
    TO_TIMESTAMP('19/03/2020 6:54:28.000000 PM','DD/MM/YYYY fmHH12fm:MI:SS.FF AM'), 'Y', NULL, NULL);
Insert into SYS_TFMAP
   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
 Values
   (20255, 'LOANADJFROMREIMBURSE', 'GBL_LOANADJFROMREIMBURSE', 'LOANDATE', 6, 
    'DATE', 10, 0, 'Y', 'LOANDATE', 
    TO_TIMESTAMP('19/03/2020 6:54:28.000000 PM','DD/MM/YYYY fmHH12fm:MI:SS.FF AM'), 'Y', NULL, NULL);
Insert into SYS_TFMAP
   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
 Values
   (20255, 'NONE', 'GBL_LOANADJFROMREIMBURSE', 'OPERATIONMODE', 0, 
    'VARCHAR2', 1, 0, 'N', 'OPERATIONMODE', 
    TO_TIMESTAMP('19/03/2020 6:54:28.000000 PM','DD/MM/YYYY fmHH12fm:MI:SS.FF AM'), 'Y', NULL, NULL);
Insert into SYS_TFMAP
   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
 Values
   (20255, 'LOANADJFROMREIMBURSE', 'GBL_LOANADJFROMREIMBURSE', 'SYSROWID', 0, 
    'VARCHAR2', 50, 0, 'N', 'SYSROWID', 
    TO_TIMESTAMP('19/03/2020 6:54:28.000000 PM','DD/MM/YYYY fmHH12fm:MI:SS.FF AM'), 'Y', NULL, NULL);
Insert into SYS_TFMAP
   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
 Values
   (20255, 'LOANADJFROMREIMBURSE', 'GBL_LOANADJFROMREIMBURSE', 'TOKENNO', 3, 
    'VARCHAR2', 10, 0, 'Y', 'TOKENNO', 
    TO_TIMESTAMP('19/03/2020 6:54:28.000000 PM','DD/MM/YYYY fmHH12fm:MI:SS.FF AM'), 'Y', NULL, NULL);
Insert into SYS_TFMAP
   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
 Values
   (20255, 'LOANADJFROMREIMBURSE', 'GBL_LOANADJFROMREIMBURSE', 'USERNAME', 0, 
    'VARCHAR2', 100, 0, 'N', 'USERNAME', 
    TO_TIMESTAMP('19/03/2020 6:54:28.000000 PM','DD/MM/YYYY fmHH12fm:MI:SS.FF AM'), 'Y', NULL, NULL);
Insert into SYS_TFMAP
   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
 Values
   (20255, 'LOANADJFROMREIMBURSE', 'GBL_LOANADJFROMREIMBURSE', 'WORKERSERIAL', 4, 
    'VARCHAR2', 10, 0, 'Y', 'WORKERSERIAL', 
    TO_TIMESTAMP('19/03/2020 6:54:28.000000 PM','DD/MM/YYYY fmHH12fm:MI:SS.FF AM'), 'Y', NULL, NULL);
Insert into SYS_TFMAP
   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
 Values
   (20255, 'LOANADJFROMREIMBURSE', 'GBL_LOANADJFROMREIMBURSE', 'YEARCODE', 0, 
    'VARCHAR2', 10, 0, 'N', 'YEARCODE', 
    TO_TIMESTAMP('19/03/2020 6:54:28.000000 PM','DD/MM/YYYY fmHH12fm:MI:SS.FF AM'), 'Y', NULL, NULL);
Insert into SYS_TFMAP
   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
 Values
   (20255, 'LOANADJFROMREIMBURSE', 'GBL_LOANADJFROMREIMBURSE', 'YEARMONTH', 7, 
    'VARCHAR2', 10, 0, 'Y', 'YEARMONTH', 
    TO_TIMESTAMP('19/03/2020 6:54:28.000000 PM','DD/MM/YYYY fmHH12fm:MI:SS.FF AM'), 'Y', NULL, NULL);
COMMIT;
