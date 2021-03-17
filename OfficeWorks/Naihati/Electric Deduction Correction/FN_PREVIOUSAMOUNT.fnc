CREATE OR REPLACE function NJMCL_WEB.fn_PreviousAmount
(
p_companycode varchar,
p_divisioncode varchar,
p_workerserial varchar,
p_fortnightstartdate varchar,
p_fortnightenddate varchar
) 
return number
as
-----------------------------------------------------------------------------
--CREATED BY : UJJWAL MALIK
--SCOPE : Return Previous Value of electric bill outstanding
--DATE : 29.08.2020
-----------------------------------------------------------------------------
lv_val number:=0;
lv_fortnightstartdate varchar2(10 byte);
lv_fortnightenddate varchar2(10 byte);
lv_str varchar(5000 byte);


begin       
    
--select fortnightenddate into lv_enddate from ELECTRICMETERREADING where workerserial=p_workerserial and fortnightenddate=to_date(''||p_fortnightenddate||'','dd/mm/yyyy');

select to_char(max(FORTNIGHTSTARTDATE),'dd/mm/yyyy'), to_char(max(FORTNIGHTENDDATE),'dd/mm/yyyy') into lv_fortnightstartdate, lv_fortnightenddate from wpswagedperioddeclaration
where FORTNIGHTENDDATE<to_date(''||p_fortnightenddate||'','dd/mm/yyyy');

--dbms_output.put_line(p_companycode||'-'||p_divisioncode||'-'||lv_fortnightstartdate||'-'||lv_fortnightenddate);

 lv_str:=' SELECT  C.ELEC_BAL_AMT FROM ELECTRICMETERREADING A, 
  ( 
      SELECT WORKERSERIAL, MAX(FORTNIGHTSTARTDATE) FORTNIGHTSTARTDATE  
      FROM ELECTRICMETERREADING  
      WHERE COMPANYCODE = '''||p_companycode||''' 
        AND FORTNIGHTSTARTDATE <= TO_DATE('''||lv_fortnightstartdate||''',''DD/MM/YYYY'') 
        AND WORKERSERIAL='''||p_workerserial||'''
      GROUP BY WORKERSERIAL  
  ) B,  
  (  
      SELECT WORKERSERIAL, SUM(ELEC_BAL_AMT) ELEC_BAL_AMT  
      FROM (  
--              SELECT WORKERSERIAL, SUM(NVL(CONTRIBUTIONAMOUNT,0))+SUM(NVL(PREV_DUE_AMT,0)) ELEC_BAL_AMT  
              SELECT WORKERSERIAL, SUM(NVL(CONTRIBUTIONAMOUNT,0)) ELEC_BAL_AMT  
              FROM ELECTRICMETERREADING   A
               WHERE COMPANYCODE= '''||p_companycode||'''   
                 AND DIVISIONCODE='''||p_divisioncode||'''  
                 AND FORTNIGHTSTARTDATE <= TO_DATE('''||lv_fortnightstartdate||''',''DD/MM/YYYY'')  
                 AND WORKERSERIAL='''||p_workerserial||'''        
                 GROUP BY WORKERSERIAL  
              UNION ALL  
              SELECT WORKERSERIAL,-1* SUM(NVL(DEDUCTEDAMT,0)) ELEC_BAL_AMT  
              FROM ELECTRICDEDUCTIONBREAKUP    
               WHERE COMPANYCODE='''||p_companycode||'''     
                 AND DIVISIONCODE= '''||p_divisioncode||'''
                 AND DEDUCTIONDATE <= TO_DATE('''||lv_fortnightenddate||''',''DD/MM/YYYY'')
                 AND WORKERSERIAL='''||p_workerserial||'''
              GROUP BY WORKERSERIAL        
         )   
       GROUP BY WORKERSERIAL   
  ) C  
  WHERE A.COMPANYCODE ='''||p_companycode||'''
   AND A.DIVISIONCODE = '''||p_divisioncode||'''
  AND A.WORKERSERIAL='''||p_workerserial||'''
    AND A.WORKERSERIAL=B.WORKERSERIAL   
    AND A.FORTNIGHTSTARTDATE =B.FORTNIGHTSTARTDATE   
    AND A.WORKERSERIAL = C.WORKERSERIAL(+)  '; 

-- dbms_output.put_line(lv_str);      
  execute immediate(nvl(lv_str,0)) into lv_val;
   
  lv_val :=NVL(lv_val,0);
--select BILLAMOUNT into lv_val from GBL_ELECBLNC;    
    
    return NVL(lv_val,0);
end;
/
