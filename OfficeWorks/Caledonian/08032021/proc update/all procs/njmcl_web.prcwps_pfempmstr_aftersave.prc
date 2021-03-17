DROP PROCEDURE NJMCL_WEB.PRCWPS_PFEMPMSTR_AFTERSAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRCWPS_PFEMPMSTR_AFTERSAVE" 
(
LV_COMPANYCODE        VARCHAR2,
LV_DIVISIONCODE       VARCHAR2,
LV_PFNO               VARCHAR2,
LV_SETTDATE           VARCHAR2,
LV_FORM3RCPTDT        VARCHAR2,
LV_SEPADVDT           VARCHAR2,
LV_STATUSDT           VARCHAR2,
LV_FORM3CEASEDT       VARCHAR2,
LV_SEPDT              VARCHAR2,
LV_EMPSTATUS          VARCHAR2
)  
AS
lv_sqlstr   varchar2(2000);
BEGIN

 lv_sqlstr :=' UPDATE PFEMPLOYEEMASTER  
                    SET (PFSETTLEMENTDATE,FORM3RECEIPTDATE,SEPARATIONADVICEDATE,STATUSDATE,FORM3CEASEDATE,SEPARATIONDATE,EMPLOYEESTATUS)
                    =(select TO_DATE('''||LV_SETTDATE||''',''DD/MM/YYYY''),TO_DATE('''||LV_FORM3RCPTDT||''',''DD/MM/YYYY''),TO_DATE('''||LV_SEPADVDT||''',''DD/MM/YYYY''),
                    TO_DATE('''||LV_STATUSDT||''',''DD/MM/YYYY''),TO_DATE('''||LV_FORM3CEASEDT||''',''DD/MM/YYYY''),TO_DATE('''||LV_SEPDT||''',''DD/MM/YYYY''),'''||LV_EMPSTATUS||''' from dual)
               WHERE COMPANYCODE='''||LV_COMPANYCODE||'''
                     AND DIVISIONCODE='''||LV_DIVISIONCODE||'''
                     AND PFNO='''||LV_PFNO||''' ';
              
     -- dbms_output.put_line(lv_sqlstr);
         execute immediate lv_sqlstr;

END;
/

