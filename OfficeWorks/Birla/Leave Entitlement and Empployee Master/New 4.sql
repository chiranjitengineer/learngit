COMP VAL 3 A
COMP VAL 3 610
COMP VAL 3 A1
COMP VAL 3
COMP VAL 3
COMP VAL 3 13698
COMP VAL 3 8290
COMP VAL 3 M
COMP VAL 3 M
COMP VAL 3 ACTIVE
COMP VAL 3 16-OCT-67
COMP VAL 3 04-APR-05
COMP VAL 3 04-APR-05
COMP VAL 3 04-APR-05
COMP VAL 3
COMP VAL 3 16-OCT-25
COMP VAL 3 16-SEP-20
COMP VAL 3 16-SEP-20
COMP VAL 3 16-SEP-20
COMP VAL 3 16-SEP-20
COMP VAL 3 BANK
COMP VAL 3
COMP VAL 3 UCBA0000306
COMP VAL 3 03060110167946
COMP VAL 3 GHISA RAM VERMA
COMP VAL 3 AAPPV8374F
COMP VAL 3 100153157591
COMP VAL 3
COMP VAL 3
COMP VAL 3 9339734696
COMP VAL 3 JAGDISH PRASAD VERMA
COMP VAL 3 JAGDISH PRASAD VERMA
COMP VAL 3 GRVERMA@BIRLACORP.COM
COMP VAL 3
COMP VAL 3 N
COMP VAL 3
COMP VAL 3 B.COM(H)
COMP VAL 3 CA
COMP VAL 3
COMP VAL 3
COMP VAL 3
COMP VAL 3 Y
COMP VAL 3 Y
COMP VAL 3 Y
COMP VAL 3 N
COMP VAL 3 Y
COMP VAL 3 0
COMP VAL 3
COMP VAL 3
COMP VAL 3
COMP VAL 3 PIS
COMP VAL 3 SWT
COMP VAL 3 202009160007160010929110
COMP VAL 3
COMP VAL 3
COMP VAL 3
COMP VAL 3
COMP VAL 3 404, SURYA APARTMENTS,14/1/7 MACKENZIE LANE
COMP VAL 3 HOWRAH
COMP VAL 3 711101
COMP VAL 3 WEST BENGAL
COMP VAL 3
COMP VAL 3 WEST BENGAL
COMP VAL 3
COMP VAL 3
COMP VAL 3 HINDUISM
COMP VAL 3
COMP VAL 3 112698
COMP VAL 3  000221
COMP VAL 3 GHISA RAM VERMA
COMP VAL 3
COMP VAL 3
COMP VAL 3 02
COMP VAL 3 10
UPDATE STATEMENT  

UPDATE PISEMPLOYEEMASTER
 SET 
   GRADECODE = 'A',
   DEPARTMENTCODE = '610',
   DESIGNATIONCODE = 'A1',
   ESINO = '',
   PFCODE = '',
   PFNO = '13698',
   PENSIONNO = '8290',
   SEX = 'M',
   MARITIALSTATUS = 'M',
   EMPLOYEESTATUS = 'ACTIVE',
   DATEOFBIRTH = '16-OCT-67',
   DATEOFJOIN = '04-APR-05',
   DATEOFCONFIRMATION = '04-APR-05',
   PFENTITLEDATE = '04-APR-05',
   STATUSDATE = NULL ,
   DATEOFRETIRE = '16-OCT-25',
   EXTENDEDRETIREDATE = '16-SEP-20',
   PFSETTELMENTDATE = '16-SEP-20',
   GRATUITYSETTELMENTDATE = '16-SEP-20',
   DATEOFTERMINATIONADVICE = '16-SEP-20',
   PAYMODE = 'BANK',
   BANKCODE = '',
   IFSCCODE = 'UCBA0000306',
   BANKACCNUMBER = '03060110167946',
   BANKACCHOLDINGNAME = 'GHISA RAM VERMA',
   PANCARDNO = 'AAPPV8374F',
   UANNO = '100153157591',
   AADHARNO = '',
   PHONE = '',
   MOBILENO = '9339734696',
   FATHERNAME = 'JAGDISH PRASAD VERMA',
   GUARDIANNAME = 'JAGDISH PRASAD VERMA',
   EMAILID = 'GRVERMA@BIRLACORP.COM',
   SPOUSENAME = '',
   QUARTERALLOTED = 'N',
   QUARTERNO = '',
   ACADEMICQUALIFICATION = 'B.COM(H)',
   PROFESSIONQUALIFICATION = 'CA',
   PAYMENTSTATUS = '',
   PFACCODE = '',
   SNFACCODE = '',
   PFAPPLICABLE = 'Y',
   EPFAPPLICABLE = 'Y',
   PTAXAPPLICABLE = 'Y',
   BONUSAPPLICABLE = 'N',
   GRATUITYAPPLICABLE = 'Y',
   GRATUITYOPENINGYEARS = '0',
   LEAVINGSERVICE = '',
   REMARKS = '',
   COSTCENTRECODE = '',
   MODULE = 'PIS',
   USERNAME = 'SWT',
   SYSROWID = '202009160007160010929110',
   ADDRESS_PRESENT = '',
   CITY_PRESENT = '',
   PIN_PRESENT = '',
   STATE_PRESENT = '',
   ADDRESS_PERMANENT = '404, SURYA APARTMENTS,14/1/7 MACKENZIE LANE',
   CITY_PERMANENT = 'HOWRAH',
   PIN_PERMANENT = '711101',
   STATE_PERMANENT = 'WEST BENGAL',
   VOTERID = '',
   PTAXSTATE = 'WEST BENGAL',
   SUPERANUATIONNUMBER = '',
   SUPERANUATIONDATE = NULL ,
   RELIGION = 'HINDUISM',
   PRANNUMBER = '',
   GRATUITYNUMBER = '112698',
   WORKERSERIAL = ' 000221',
   EMPLOYEENAME = 'GHISA RAM VERMA',
   ATTNIDENTIFICATION = '',
   BOSSCODE = '',
   UNITCODE = '02',
   CATEGORYCODE = '10'
   where (COMPANYCODE,DIVISIONCODE,TOKENNO,SYSROWID) 
 = ( select COMPANYCODE,DIVISIONCODE,TOKENNO,SYSROWID from GBL_PISEMPLOYEEMASTER where rowid = 'AAQfQAAABAAAfQBAAA')
 
 
select FN_GET_COLUMN_NAMES_FORNULL('GBL_PISEMPLOYEEMASTER'),fn_get_mapped_column_names('GBL_PISEMPLOYEEMASTER') from dual

select fn_get_mapped_column_names('GBL_PISEMPLOYEEMASTER') from dual


nvl(AADHARNO,'~QQ~'),nvl(ACADEMICQUALIFICATION,'~QQ~'),nvl(ADDRESS_PERMANENT,'~QQ~'),nvl(ADDRESS_PRESENT,'~QQ~'),nvl(ATTNIDENTIFICATION,'~QQ~'),nvl(BANKACCHOLDINGNAME,'~QQ~'),nvl(BANKACCNUMBER,'~QQ~'),nvl(BANKCODE,'~QQ~'),nvl(BONUSAPPLICABLE,'~QQ~'),nvl(BOSSCODE,'~QQ~'),nvl(CATEGORYCODE,'~QQ~'),nvl(CITY_PERMANENT,'~QQ~'),nvl(CITY_PRESENT,'~QQ~'),nvl(COMPANYCODE,'~QQ~'),nvl(COSTCENTRECODE,'~QQ~'),nvl(DATEOFBIRTH,to_date('31/01/1000','dd/mm/yyyy')),nvl(DATEOFCONFIRMATION,to_date('31/01/1000','dd/mm/yyyy')),nvl(DATEOFJOIN,to_date('31/01/1000','dd/mm/yyyy')),nvl(DATEOFRETIRE,to_date('31/01/1000','dd/mm/yyyy')),nvl(DATEOFTERMINATIONADVICE,to_date('31/01/1000','dd/mm/yyyy')),nvl(DEPARTMENTCODE,'~QQ~'),nvl(DESIGNATIONCODE,'~QQ~'),nvl(DIVISIONCODE,'~QQ~'),nvl(EMAILID,'~QQ~'),nvl(EMPLOYEENAME,'~QQ~'),nvl(EMPLOYEESTATUS,'~QQ~'),nvl(EPFAPPLICABLE,'~QQ~'),nvl(ESINO,'~QQ~'),nvl(EXTENDEDRETIREDATE,to_date('31/01/1000','dd/mm/yyyy')),nvl(FATHERNAME,'~QQ~'),nvl(GRADECODE,'~QQ~'),nvl(GRATUITYAPPLICABLE,'~QQ~'),nvl(GRATUITYOPENINGYEARS,0),nvl(GRATUITYSETTELMENTDATE,to_date('31/01/1000','dd/mm/yyyy')),nvl(GUARDIANNAME,'~QQ~'),nvl(IFSCCODE,'~QQ~'),nvl(LEAVINGSERVICE,'~QQ~'),nvl(MARITIALSTATUS,'~QQ~'),nvl(MOBILENO,'~QQ~'),nvl(MODULE,'~QQ~'),nvl(PANCARDNO,'~QQ~'),nvl(PAYMENTSTATUS,'~QQ~'),nvl(PAYMODE,'~QQ~'),nvl(PENSIONNO,'~QQ~'),nvl(PFACCODE,'~QQ~'),nvl(PFAPPLICABLE,'~QQ~'),nvl(PFCODE,'~QQ~'),nvl(PFENTITLEDATE,to_date('31/01/1000','dd/mm/yyyy')),nvl(PFNO,'~QQ~'),nvl(PFSETTELMENTDATE,to_date('31/01/1000','dd/mm/yyyy')),nvl(PHONE,'~QQ~'),nvl(PIN_PERMANENT,'~QQ~'),nvl(PIN_PRESENT,'~QQ~'),nvl(PROFESSIONQUALIFICATION,'~QQ~'),nvl(PTAXAPPLICABLE,'~QQ~'),nvl(QUARTERALLOTED,'~QQ~'),nvl(QUARTERNO,'~QQ~'),nvl(REMARKS,'~QQ~'),nvl(SEX,'~QQ~'),nvl(SNFACCODE,'~QQ~'),nvl(SPOUSENAME,'~QQ~'),nvl(STATE_PERMANENT,'~QQ~'),nvl(STATE_PRESENT,'~QQ~'),nvl(STATUSDATE,to_date('31/01/1000','dd/mm/yyyy')),nvl(SYSROWID,'~QQ~'),nvl(TOKENNO,'~QQ~'),nvl(UANNO,'~QQ~'),nvl(UNITCODE,'~QQ~'),nvl(VOTERID,'~QQ~'),nvl(WORKERSERIAL,'~QQ~'),nvl(USERNAME,'~QQ~'),nvl(PTAXSTATE,'~QQ~'),nvl(GRATUITYNUMBER,'~QQ~'),nvl(PRANNUMBER,'~QQ~'),nvl(RELIGION,'~QQ~'),nvl(SUPERANUATIONDATE,to_date('31/01/1000','dd/mm/yyyy')),nvl(SUPERANUATIONNUMBER,'~QQ~')


AADHARNO,ACADEMICQUALIFICATION,ADDRESS_PERMANENT,ADDRESS_PRESENT,ATTNIDENTIFICATION,BANKACCHOLDINGNAME,BANKACCNUMBER,BANKCODE,BONUSAPPLICABLE,BOSSCODE,CATEGORYCODE,CITY_PERMANENT,CITY_PRESENT,COMPANYCODE,COSTCENTRECODE,DATEOFBIRTH,DATEOFCONFIRMATION,DATEOFJOIN,DATEOFRETIRE,DATEOFTERMINATIONADVICE,DEPARTMENTCODE,DESIGNATIONCODE,DIVISIONCODE,EMAILID,EMPLOYEENAME,EMPLOYEESTATUS,EPFAPPLICABLE,ESINO,EXTENDEDRETIREDATE,FATHERNAME,GRADECODE,GRATUITYAPPLICABLE,GRATUITYOPENINGYEARS,GRATUITYSETTELMENTDATE,GUARDIANNAME,IFSCCODE,LEAVINGSERVICE,MARITIALSTATUS,MOBILENO,MODULE,PANCARDNO,PAYMENTSTATUS,PAYMODE,PENSIONNO,PFACCODE,PFAPPLICABLE,PFCODE,PFENTITLEDATE,PFNO,PFSETTELMENTDATE,PHONE,PIN_PERMANENT,PIN_PRESENT,PROFESSIONQUALIFICATION,PTAXAPPLICABLE,QUARTERALLOTED,QUARTERNO,REMARKS,SEX,SNFACCODE,SPOUSENAME,STATE_PERMANENT,STATE_PRESENT,STATUSDATE,SYSROWID,TOKENNO,UANNO,UNITCODE,VOTERID,WORKERSERIAL,USERNAME,PTAXSTATE,GRATUITYNUMBER,PRANNUMBER,RELIGION,SUPERANUATIONDATE,SUPERANUATIONNUMBER