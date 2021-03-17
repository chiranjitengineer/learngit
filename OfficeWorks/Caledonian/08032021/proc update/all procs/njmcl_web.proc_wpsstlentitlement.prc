DROP PROCEDURE NJMCL_WEB.PROC_WPSSTLENTITLEMENT;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPSSTLENTITLEMENT
(p_companycode  VARCHAR2, 
p_divisioncode  VARCHAR2,
p_dept          VARCHAR2,
p_token         VARCHAR2,
p_section       VARCHAR2,
p_year          VARCHAR2,
p_option        varchar2,
p_shift         VARCHAR2 default null
)
AS
lv_sqlstr VARCHAR2(4000);
lv_company varchar2(150);
lv_division varchar2(150);

begin
    SELECT COMPANYNAME into lv_company FROM COMPANYMAST WHERE COMPANYCODE=p_companycode;     
    SELECT DIVISIONNAME into lv_division FROM DIVISIONMASTER WHERE COMPANYCODE=p_companycode AND DIVISIONCODE=p_divisioncode;       

 DELETE FROM GTT_WPSSTLENTITLEMENT;   
 LV_SQLSTR:='INSERT INTO GTT_WPSSTLENTITLEMENT  
             (COMPANYCODE, DIVISIONCODE,COMPANYNAME,EX6, TOKENNO, WORKERNAME, DEPARTMENTCODE, EX1,SHIFTCODE, EX14, HOLIDAYHOURS, 
             STANDARDSTLHOURS, ADJUSTEDHOURS, STLDAYS_BF, STLDAYS, STLHRSTAKEN,   IS_RET_LEFT, CLOSING,EX5,EX7, ENTDAYS,EX8, EX13,EX12,EX15,EX9)   
           
            SELECT A.COMPANYCODE, A.DIVISIONCODE,'''||lv_company||''' AS COMPANYNAME,'''||lv_division||''' AS DIVISIONNAME, 
            TOKENNO, WORKERNAME, DEPARTMENTCODE, SECTIONCODE,SHIFTCODE,  ATTNDAYS, HOLIDAYHOURS, STANDARDSTLHOURS, ADJUSTEDHOURS, 
            STLDAYS_BF, STLDAYSTAKEN, STLHRSTAKEN,STLDAYS_BF, STLDAYS_BF+ STLDAYS CLOSING,
            ''STATUTORY LEAVE ENTITLEMENT LIST FOR THE YEAR '','||p_year||' ||'' ('||p_option||')'' EX5,STLDAYS  EX7, 
            STLDAYS ENT,DEPARTMENTNAME,GRACEDAYS,
            CASE WHEN STLDAYS>0 THEN '' * ENT'' ELSE '' * NOT ENT'' END EX15 , '||p_year||' EX9      
             FROM 
            (   
                SELECT A.COMPANYCODE,A.DIVISIONCODE,A.TOKENNO,B.WORKERNAME,A.DEPARTMENTCODE,B.SECTIONCODE, A.YEARCODE,   
                    DECODE(B.SHIFT,''1'',''B'',''2'',''G'',''3'',''R'',''B'',''B'',''G'',''G'',''R'',''R'',''BLUE'',''B'',''GREEN'',''G'',''RED'',''R'') SHIFTCODE,A.ATTNDAYS,A.HOLIDAYHOURS,  
                    A.STANDARDSTLHOURS,A.ADJUSTEDHOURS,NVL(A.STLDAYS_BF,0) STLDAYS_BF,STLDAYSTAKEN,NVL(A.STLDAYS,0) STLDAYS,
                    nvl(TOTALWORKINGDAYS,0)TOTALWORKINGDAYS , A.STLHRSTAKEN,DEPARTMENTNAME , GRACEDAYS               
                    FROM WPSSTLENTITLEMENTCALCDETAILS A,WPSWORKERMAST B,DEPARTMENTMASTER C
                WHERE A.COMPANYCODE=B.COMPANYCODE  
                    AND A.DIVISIONCODE=B.DIVISIONCODE  
                    AND A.WORKERSERIAL=B.WORKERSERIAL
                    AND A.COMPANYCODE=C.COMPANYCODE  
                    AND A.DIVISIONCODE=C.DIVISIONCODE  
                    AND A.DEPARTMENTCODE=C.DEPARTMENTCODE                        
                    --AND A.YEARCODE IN ('||p_year||') 
                    AND A.COMPANYCODE='''||p_companycode||''' 
                    AND A.DIVISIONCODE='''||p_divisioncode||'''  ';
                    
         if p_token is not null then
            lv_sqlstr :=lv_sqlstr || ' AND A.TOKENNO in ('||p_token||')  ';
         end if;
         
         if p_section is not null then
            lv_sqlstr :=lv_sqlstr || ' AND B.SECTIONCODE in ('||p_section||')  ';
         end if;
         
         if p_dept is not null then
            lv_sqlstr :=lv_sqlstr || ' AND A.DEPARTMENTCODE in ('||p_dept||')  ';
         end if;
         
         if p_year is not null then
--            lv_sqlstr :=lv_sqlstr || ' AND A.YEARCODE in ('||p_year||')  ';
                lv_sqlstr :=lv_sqlstr || ' AND A.FROMYEAR in ('||p_year||')  ';
         end if;  
         
         
          if p_shift is not null then
--            lv_sqlstr :=lv_sqlstr || ' AND A.YEARCODE in ('||p_year||')  ';
                lv_sqlstr :=lv_sqlstr || ' AND DECODE(B.SHIFT,''B'',''1'',''G'',''2'',''R'',''3'',''B'',''B'',''G'',''G'',''R'',''R'') in ('||p_shift||') ';
         end if;                                     
                                    
         lv_sqlstr :=lv_sqlstr || '    ) A  WHERE 1=1 '   ;
                        
         if p_option ='Entitled' then
           lv_sqlstr :=lv_sqlstr || ' AND STLDAYS>0  ';
         end if;
         
         if p_option ='Not Entitled' then
           lv_sqlstr :=lv_sqlstr || ' AND STLDAYS=0    ';
         end if;                                     
        
        lv_sqlstr :=lv_sqlstr || ' order by DEPARTMENTCODE,DECODE(SHIFTCODE,''B'',''1'',''G'',''2'',''R'',''3'') ,TOKENNO ';

       --   dbms_output.put_line (lv_sqlstr);
         EXECUTE  IMMEDIATE lv_sqlstr;
                  
end ;
/


