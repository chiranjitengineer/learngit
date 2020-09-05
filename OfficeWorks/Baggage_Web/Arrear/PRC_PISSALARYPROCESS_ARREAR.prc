CREATE OR REPLACE PROCEDURE BAGGAGE_WEB.PRC_PISSALARYPROCESS_ARREAR 
(
      P_COMPCODE Varchar2,  
      P_DIVCODE Varchar2,
      P_TRANTYPE Varchar2, 
      P_PHASE  number, 
      P_YEARMONTH_FR Varchar2,
      P_YEARMONTH_TO Varchar2,
      P_EFFECTYEARMONTH Varchar2, 
      P_TABLENAME Varchar2,
      P_PHASE_TABLENAME Varchar2,
      P_UNIT  Varchar2,
      P_CATEGORY    Varchar2  DEFAULT NULL,
      P_GRADE       Varchar2  DEFAULT NULL,
      P_DEPARTMENT  Varchar2  DEFAULT NULL,
      P_WORKERSERIAL VARCHAR2 DEFAULT NULL
)
as
/*
BEGIN
PRC_PISSALARYPROCESS_ARREAR 
(
      'JT0069',  
      '0001',
      'ARREAR', 
      0, 
      '201904',
      '201908',
      '201909', 
      '',
      '',
      'HO',
      'HO',
      'MANAGERIAL',
      '',
      '00013'
);
END;
*/
LV_SQLSTR VARCHAR2(30000);
lv_companycode varchar2(10) := LTRIM(TRIM(P_COMPCODE)) ; -- 'LJ0054'    
lv_locationcode varchar2(10) := LTRIM(TRIM(P_DIVCODE))  ; -- 0001'
lv_yearmonth varchar2(6) :=  LTRIM(TRIM(P_EFFECTYEARMONTH)) ;      --'201705';
lv_yearmonth_fr varchar2(6) := LTRIM(TRIM(P_YEARMONTH_FR));
lv_yearmonth_to varchar2(6) :=  LTRIM(TRIM(P_YEARMONTH_TO));
--lv_yearmonth_fr varchar2(6) := substr(lv_yearmonth,1,4)||'04';
--lv_yearmonth_to varchar2(6) := substr(lv_yearmonth,1,4)||lpad(substr(lv_yearmonth,-2)-1,2,'0') ;
lv_workerserial varchar2(10):=  LTRIM(TRIM(P_WORKERSERIAL)) ;           --'000040' ;
lv_totarrcomp int;
lv_rowcnt int:=1;
lv_cnt int;
lv_per number := 80;
lv_sql varchar2(30000);
lv_inssql_cols varchar2(10000)  ;
lv_inssql_vals varchar2(10000)  ;     
lv_inssql_cols_1  varchar2(10000)  ;
lv_inssql_vals_1 varchar2(10000)  ;
lv_col_val varchar2(10000);
lv_colval_str varchar2(10000);
lv_sum_grossdedn_colval varchar2(10000);
lv_sum_netsalary_colval varchar2(10000);
lv_colval_sum_str varchar2(10000);
lv_dedcolsum_str varchar2(10000);
lv_dedcolval_sum_str varchar2(10000);
lv_netsalcolval_sum_str varchar2(10000);
lv_colval_sum_str_val varchar2(10000);
lv_colval_neg_str varchar2(10000);
lv_comparrearamt number(19,2);
lv_yearmonth_tmp varchar2(6) := '';
lv_insert_fixed_col varchar2(10000) ;
lv_insert_fixed_col_val varchar2(10000) ;
lv_effective_ym varchar2(10)   ;
lv_yearcode varchar2(10)   ;
lv_startdate varchar2(10);
lv_enddate   varchar2(10);

-- to generate as arrear row with yearmonth > '201704'
--- non comp cols remaining same as '201704'
--- 
--BEGIN
--PRC_PISSALARYPROCESS_ARREAR ('LJ0054', '0001','','','201704','201704','201704','','','') ;
-- EXEC PRC_PISSALARYPROCESS_ARREAR('LJ0054', '0001','','','201704','201704','201705','','','');
--END;
--
BEGIN
--select count(distinct COMPONENTCODE) into lv_totarrcomp from piscomponentmaster where INCLUDEARREAR = 'Y' ;

select count(*) into lv_totarrcomp from ( select  distinct COMPONENTCODE COL from piscomponentmaster
                     --where INCLUDEARREAR = 'Y' 
                      intersect 
                      select column_name col from cols where table_name = 'PISARREARTRANSACTION'   
                      );


/*LV_SQLSTR := 'UPDATE PISARREARTRANSACTION_TEMP SET ' ;
for c1 in ( select distinct COMPONENTCODE from piscomponentmaster
where INCLUDEARREAR = 'Y' ) loop
  if lv_rowcnt < lv_totarrcomp then
   LV_SQLSTR := LV_SQLSTR||c1.COMPONENTCODE||' = '||c1.COMPONENTCODE||'+ ('||c1.COMPONENTCODE||'*('||lv_per||'/100)) , '||chr(10) ;
  else
   LV_SQLSTR := LV_SQLSTR||c1.COMPONENTCODE||' = '||c1.COMPONENTCODE||'+ ('||c1.COMPONENTCODE||'*('||lv_per||'/100))'||chr(10) ;
  end if;
  lv_rowcnt:=lv_rowcnt+1;
end loop;
  LV_SQLSTR := LV_SQLSTR||' WHERE COMPANYCODE = '''||lv_companycode||''' '||chr(10)
                        ||' AND DIVISIONCODE = '''||lv_locationcode||'''  '||chr(10)
                        ||' AND YEARMONTH = '''||lv_yearmonth||'''  '||chr(10)  
                        ||' AND WORKERSERIAL = '''||lv_workerserial||'''  '||chr(10) ;
 ---DBMS_output.put_line( LV_SQLSTR );
 --execute immediate LV_SQLSTR ; */
 
-- yearmonth , WORHER loop

DELETE GTT_PISARREARTRANSACTION;
 
        DELETE FROM PISARREARTRANSACTION
         WHERE companycode = NVL2(lv_companycode,lv_companycode ,companycode )
           and divisioncode = NVL2(lv_locationcode,lv_locationcode ,divisioncode )
           and WORKERSERIAL = NVL2(lv_workerserial,lv_workerserial ,WORKERSERIAL )
           AND UNITCODE =  NVL2(P_UNIT , P_UNIT , UNITCODE)
           
           --comment on 02/09/2020 *************************************************************
           AND CATEGORYCODE = NVL2(P_CATEGORY , P_CATEGORY , CATEGORYCODE )
           AND GRADECODE  =  NVL2(P_GRADE , P_GRADE , GRADECODE)
           and DEPARTMENTCODE =  NVL2(P_DEPARTMENT,P_DEPARTMENT,DEPARTMENTCODE)
           --comment on 02/09/2020 *************************************************************
          -- and ( YEARMONTH BETWEEN  lv_yearmonth_fr AND lv_yearmonth_to or YEARMONTH = lv_yearmonth  ) 
           AND EFFECT_YEARMONTH = lv_yearmonth
           and TRANSACTIONTYPE <> 'NEW SALARY'  ;      


----DBMS_OUTPUT.PUT_LINE('ABC' || lv_yearmonth_fr || ',' || lv_yearmonth_to || ',' || lv_companycode  || ',' || lv_locationcode  || ',' || lv_workerserial) ;

--DBMS_OUTPUT.PUT_LINE(' WORKER WISE YEARMONTH WISE INSERT INTO GTT QUERY :- ') ;   
 

for c1 in (select companycode , DIVISIONCODE , UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE , YEARMONTH , EFFECT_YEARMONTH ,WORKERSERIAL  from PISARREARTRANSACTION
           where EFFECT_YEARMONTH = lv_yearmonth  AND YEARMONTH <= lv_yearmonth_to
           /*YEARMONTH between lv_yearmonth_fr and lv_yearmonth_to*/
           AND companycode = NVL2(lv_companycode,lv_companycode ,companycode )
           and divisioncode = NVL2(lv_locationcode,lv_locationcode ,divisioncode )
           and WORKERSERIAL = NVL2(lv_workerserial,lv_workerserial ,WORKERSERIAL )
           AND UNITCODE =  NVL2(P_UNIT , P_UNIT , UNITCODE)
           
           --comment on 02/09/2020 *************************************************************
           AND CATEGORYCODE = NVL2(P_CATEGORY , P_CATEGORY , CATEGORYCODE )
           AND GRADECODE  =  NVL2(P_GRADE , P_GRADE , GRADECODE)
           and DEPARTMENTCODE =  NVL2(P_DEPARTMENT,P_DEPARTMENT,DEPARTMENTCODE)
           
           --comment on 02/09/2020 *************************************************************
           order by companycode , DIVISIONCODE , UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE , YEARMONTH , WORKERSERIAL ) loop      
       
    --  --DBMS_OUTPUT.PUT_LINE('INSIDE LOOP 1') ;       
       

       lv_inssql_cols := 'INSERT INTO GTT_PISARREARTRANSACTION( ' ;
       lv_inssql_vals  := ' VALUES( ';             
       lv_col_val := '';
       lv_colval_str := '''';
       
   
       for c3 in (
                   select column_name col from cols where table_name = 'PISARREARTRANSACTION'
                   minus
                   select distinct COMPONENTCODE from piscomponentmaster
                    -- where INCLUDEARREAR = 'Y'  
                 ) loop                    
                 lv_inssql_cols := lv_inssql_cols||c3.col||' , '||chr(10) ;
                 if ltrim(trim(c3.col)) = 'TRANSACTIONTYPE' then
                   lv_colval_str := lv_colval_str||'''''''||''MONTHLYARR''||'''''','  ;
                  else
                   lv_colval_str := lv_colval_str||'''''''||'||c3.col||'||'''''','  ;
                  end if;                           
        end loop;
        lv_colval_str := lv_colval_str||'''' ;        
        lv_sql := 'select DISTINCT '||lv_colval_str||'  from PISARREARTRANSACTION  where  companycode = '''||c1.companycode||'''  and DIVISIONCODE = '''||c1.DIVISIONCODE||''' and  UNITCODE = '''||c1.UNITCODE||''' and  DEPARTMENTCODE = '''||c1.DEPARTMENTCODE||''' and  CATEGORYCODE = '''||c1.CATEGORYCODE||''' and  GRADECODE  = '''||c1.GRADECODE||''' and YEARMONTH = '''||c1.YEARMONTH||''' and WORKERSERIAL = '''||c1.WORKERSERIAL||'''  ';
        
        DBMS_OUTPUT.PUT_LINE(  lv_sql );       
        execute immediate lv_sql into lv_col_val;
        
        lv_inssql_vals := lv_inssql_vals||lv_col_val;        
      
--        DBMS_OUTPUT.PUT_LINE(lv_inssql_vals);
          
      --  exit; 
         lv_colval_str := '';
         lv_colval_sum_str := '';
         lv_colval_neg_str := '';
         lv_rowcnt :=1;
         for c2 in ( select distinct COMPONENTCODE COL from piscomponentmaster
                     --where INCLUDEARREAR = 'Y' 
                     intersect 
                      select column_name col from cols where table_name = 'PISARREARTRANSACTION'         
         ) loop   
              if lv_rowcnt < lv_totarrcomp then
                lv_inssql_cols := lv_inssql_cols||c2.col||' , '||chr(10) ;
                lv_colval_str := lv_colval_str||''||c2.col||','  ;
                lv_colval_sum_str := lv_colval_sum_str||'''''''||SUM('||c2.col||')||'''''','  ;
                lv_colval_neg_str := lv_colval_neg_str||''||c2.col||'*-1,'  ;
              else
                lv_inssql_cols := lv_inssql_cols||c2.col||' ) '||chr(10) ;
                lv_colval_str := lv_colval_str||''||c2.col  ;
                lv_colval_sum_str := lv_colval_sum_str||'''''''||SUM('||c2.col||')||'''''''  ;
                lv_colval_neg_str := lv_colval_neg_str||''||c2.col||'*-1'  ;
              end if;  
              lv_rowcnt:=lv_rowcnt+1;
--             select c2.COMPONENTCODE into x from tab a where --- ;
--             select c2.COMPONENTCODE into y from tab b where --- ;
--             lv_comparrearamt = x-y ;
--             lv_insertsql =
--             insert into gtt_arreartab( c2.COMPONENTCODE ,
--                                   values(  lv_comparrearamt ,           
         end loop;
          
          lv_inssql_cols_1 := replace(lv_inssql_cols,'GTT_PISARREARTRANSACTION' ,'PISARREARTRANSACTION') ;
          --lv_inssql_vals_1 := replace(lv_inssql_vals ,'MONTHLYARR','ARREAR'); 
          --lv_inssql_vals_1 := replace(lv_inssql_vals ,'MONTHLYARR','TOT ARREAR');         
          lv_sql := 'select '''||lv_colval_sum_str||''' from (
                            (      
                            select '||lv_colval_str||' from PISARREARTRANSACTION where companycode = '''||c1.companycode||'''  and DIVISIONCODE = '''||c1.DIVISIONCODE||''' /*and  UNITCODE = '''||c1.UNITCODE||''' and  DEPARTMENTCODE = '''||c1.DEPARTMENTCODE||''' and  CATEGORYCODE = '''||c1.CATEGORYCODE||''' and  GRADECODE  = '''||c1.GRADECODE||'''*/ and YEARMONTH = '''||c1.YEARMONTH||''' and TRANSACTIONTYPE = ''NEW SALARY'' and WORKERSERIAL = '''||c1.WORKERSERIAL||''' 
                            union all
                            select '||lv_colval_neg_str||' from PISPAYTRANSACTION  where companycode = '''||c1.companycode||'''  and DIVISIONCODE = '''||c1.DIVISIONCODE||''' /*and  UNITCODE = '''||c1.UNITCODE||''' and  DEPARTMENTCODE = '''||c1.DEPARTMENTCODE||''' and  CATEGORYCODE = '''||c1.CATEGORYCODE||''' and  GRADECODE  = '''||c1.GRADECODE||'''*/ and YEARMONTH = '''||c1.YEARMONTH||''' and TRANSACTIONTYPE = ''SALARY'' and WORKERSERIAL = '''||c1.WORKERSERIAL||'''  
                            ) )' ;     
                            
                            
--commented on 03/09/2020 ***********************************  
--select '||lv_colval_str||' from PISARREARTRANSACTION where companycode = '''||c1.companycode||'''  and DIVISIONCODE = '''||c1.DIVISIONCODE||''' and  UNITCODE = '''||c1.UNITCODE||''' and  DEPARTMENTCODE = '''||c1.DEPARTMENTCODE||''' and  CATEGORYCODE = '''||c1.CATEGORYCODE||''' and  GRADECODE  = '''||c1.GRADECODE||''' and YEARMONTH = '''||c1.YEARMONTH||''' and TRANSACTIONTYPE = ''NEW SALARY'' and WORKERSERIAL = '''||c1.WORKERSERIAL||''' 
--                            union all
--                            select '||lv_colval_neg_str||' from PISPAYTRANSACTION  where companycode = '''||c1.companycode||'''  and DIVISIONCODE = '''||c1.DIVISIONCODE||''' and  UNITCODE = '''||c1.UNITCODE||''' and  DEPARTMENTCODE = '''||c1.DEPARTMENTCODE||''' and  CATEGORYCODE = '''||c1.CATEGORYCODE||''' and  GRADECODE  = '''||c1.GRADECODE||''' and YEARMONTH = '''||c1.YEARMONTH||''' and TRANSACTIONTYPE = ''SALARY'' and WORKERSERIAL = '''||c1.WORKERSERIAL||'''  
--                           

--commented on 03/09/2020 ***********************************                          
          DBMS_OUTPUT.PUT_LINE('insert data   '||lv_sql);   
           --RETURN;             
           
           
                
           execute immediate lv_sql into lv_colval_sum_str_val ;      
           lv_inssql_vals := lv_inssql_vals||lv_colval_sum_str_val||')' ;
           ----DBMS_OUTPUT.PUT_LINE(lv_inssql_cols||lv_inssql_vals);
           execute immediate lv_inssql_cols||lv_inssql_vals;
           
           
--           DBMS_OUTPUT.PUT_LINE(lv_inssql_cols||lv_inssql_vals) ;     
        --  --DBMS_OUTPUT.PUT_LINE('INSIDE LOOP 2') ;      
end loop; -- c1    
commit; 

--DBMS_OUTPUT.PUT_LINE(' query for consolidation from ARRIL till ARREAR PROCESSING MONTH for above arrear processed workers :- ') ;   

-- end yearmonth , WORKER loop 
-- start consolidation from ARRIL till ARREAR PROCESSING MONTH for above arrear processed workers --
insert into PISARREARTRANSACTION select * from GTT_PISARREARTRANSACTION ;
--return;
lv_effective_ym   := lv_yearmonth ; 
begin    
  for c1 in ( select distinct COMPANYCODE, DIVISIONCODE, YEARCODE, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO from GTT_PISARREARTRANSACTION WHERE transactiontype = 'MONTHLYARR') loop
  lv_yearcode := c1.yearcode ;
  lv_insert_fixed_col := 'INSERT INTO PISARREARTRANSACTION (COMPANYCODE, DIVISIONCODE, YEARCODE, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO , YEARMONTH, EFFECT_YEARMONTH,TRANSACTIONTYPE ,' ;
  lv_insert_fixed_col_val :=   ' VALUES ( '''||c1.COMPANYCODE||''','''|| c1.DIVISIONCODE||''','''||lv_yearcode||''','''||c1.UNITCODE||''','''||c1.DEPARTMENTCODE||''','''||c1.CATEGORYCODE||''','''||c1.GRADECODE||''','''||c1.WORKERSERIAL||''','''||c1.TOKENNO||''','''||lv_effective_ym||''','''||lv_effective_ym||''',''ARREAR'' , ';
  lv_inssql_cols :=''  ;
  lv_inssql_vals :=''  ; 
  lv_colval_str  :='' ;
  lv_colval_sum_str := '' ;
  lv_dedcolval_sum_str := '';
  lv_dedcolsum_str := '';
  lv_rowcnt :=1;
        
        
  select count(distinct COMPONENTCODE) into lv_totarrcomp from piscomponentmaster a where COMPANYCODE = c1.COMPANYCODE and DIVISIONCODE = c1.DIVISIONCODE and
               INCLUDEARREAR = 'Y'  
               and yearmonth = (select max(yearmonth) from PISCOMPONENTMASTER b where 
                               a.COMPANYCODE = b.companycode
                               and a.DIVISIONCODE = b.DIVISIONCODE
                               and a.COMPONENTCODE = b.COMPONENTCODE 
                               --and COMPONENTTYPE = 'DEDUCTION' 
                               AND INCLUDEARREAR = 'Y' );
  for c3 in ( SELECT distinct COMPONENTCODE COL
              FROM PISCOMPONENTMASTER a
              WHERE COMPANYCODE = c1.COMPANYCODE
              and   DIVISIONCODE = c1.DIVISIONCODE
              and COMPONENTTYPE = 'DEDUCTION' 
              AND INCLUDEARREAR = 'Y'
              and yearmonth = (select max(yearmonth) from PISCOMPONENTMASTER b where 
                               a.COMPANYCODE = b.companycode
                               and a.DIVISIONCODE = b.DIVISIONCODE
                               and a.COMPONENTCODE = b.COMPONENTCODE 
                               and COMPONENTTYPE = 'DEDUCTION' 
                               AND INCLUDEARREAR = 'Y' )  
                    
                    
                    ) loop       
      if lv_rowcnt = 1 then
        lv_dedcolval_sum_str :=  lv_dedcolval_sum_str||'''''''||SUM('||c3.col||')' ; 
        lv_dedcolsum_str := lv_dedcolsum_str||'SUM(NVL('||c3.col||',0))' ;               
      else
        lv_dedcolval_sum_str :=  lv_dedcolval_sum_str||'+SUM('||c3.col||')' ;
        lv_dedcolsum_str := lv_dedcolsum_str||'+SUM(NVL('||c3.col||',0))' ; 
      end if;                    
  lv_rowcnt := lv_rowcnt+1;
  end loop; -- c3
  lv_netsalcolval_sum_str := '''''''||( SUM(NVL(GROSSEARN,0)) - ('||lv_dedcolsum_str||'))||'''''' '; 
  lv_dedcolval_sum_str:= '''''''||('||lv_dedcolsum_str||')||'''''' ';
  ----DBMS_output.put_line(lv_netsalcolval_sum_str);
  ----DBMS_output.put_line(lv_dedcolval_sum_str);
  --return;
  lv_rowcnt :=1;
  for c2 in ( select distinct COMPONENTCODE COL from piscomponentmaster a
              where COMPANYCODE = c1.COMPANYCODE and DIVISIONCODE = c1.DIVISIONCODE and
               INCLUDEARREAR = 'Y'  
               and yearmonth = (select max(yearmonth) from PISCOMPONENTMASTER b where 
                               a.COMPANYCODE = b.companycode
                               and a.DIVISIONCODE = b.DIVISIONCODE
                               and a.COMPONENTCODE = b.COMPONENTCODE 
                               --and COMPONENTTYPE = 'DEDUCTION' 
                               AND INCLUDEARREAR = 'Y' )         
               ) loop   
              if lv_rowcnt < lv_totarrcomp then
                lv_inssql_cols := lv_inssql_cols||c2.col||' , '||chr(10) ;
                lv_colval_str := lv_colval_str||''||c2.col||','  ;
                lv_colval_sum_str := lv_colval_sum_str||'''''''||SUM('||c2.col||')||'''''','  ;                 
              else
                lv_inssql_cols := lv_inssql_cols||c2.col||'  '||chr(10) ; -- prev )
                lv_colval_str := lv_colval_str||''||c2.col  ;
                lv_colval_sum_str := lv_colval_sum_str||'''''''||SUM('||c2.col||')||'''''''  ;                 
              end if;  
              lv_rowcnt:=lv_rowcnt+1;                
         end loop;      -- c2    
   -- --DBMS_output.put_line(   lv_inssql_cols );
   -- --DBMS_output.put_line(   lv_colval_str );
    ----DBMS_output.put_line(   lv_colval_sum_str );  
    lv_sql := 'select '''||lv_colval_sum_str||','||lv_netsalcolval_sum_str||','||lv_dedcolval_sum_str||''' from GTT_PISARREARTRANSACTION where  '||chr(10)
               ||' COMPANYCODE = '''||c1.COMPANYCODE ||'''  '||chr(10)
               ||' AND DIVISIONCODE = '''||c1.DIVISIONCODE ||'''  '||chr(10)
               ||' AND UNITCODE = '''||c1.UNITCODE ||'''  '||chr(10)
               ||' AND DEPARTMENTCODE = '''||c1.DEPARTMENTCODE ||'''  '||chr(10)
               ||' AND CATEGORYCODE = '''||c1.CATEGORYCODE ||'''  '||chr(10)
               ||' AND GRADECODE = '''||c1.GRADECODE ||'''  '||chr(10)
               ||' AND WORKERSERIAL = '''||c1.WORKERSERIAL ||'''  '||chr(10)
               ||' AND  TOKENNO = '''||c1.TOKENNO ||'''  '||chr(10) ;       
    --DBMS_output.put_line( ' nEt sal - ' || lv_sql );  
    --return;  
    
    execute immediate  lv_sql into lv_colval_str   ;
   -- --DBMS_output.put_line(  lv_insert_fixed_col||lv_inssql_cols||lv_insert_fixed_col_val||lv_colval_str||')' ); 
   --DBMS_output.put_line( lv_insert_fixed_col||lv_inssql_cols||',NETSALARY,GROSSDEDN)'||lv_insert_fixed_col_val||lv_colval_str||')' ) ;
   --return;
   
--    DBMS_output.put_line(lv_insert_fixed_col);
--    DBMS_output.put_line(lv_inssql_cols);
--    DBMS_output.put_line(',NETSALARY,GROSSDEDN)');
--    DBMS_output.put_line(lv_insert_fixed_col_val);
--    DBMS_output.put_line(lv_colval_str);
    
   
   
   DBMS_OUTPUT.PUT_LINE (lv_insert_fixed_col||lv_inssql_cols||',NETSALARY,GROSSDEDN)'||lv_insert_fixed_col_val||lv_colval_str||')');   
   execute immediate lv_insert_fixed_col||lv_inssql_cols||',NETSALARY,GROSSDEDN)'||lv_insert_fixed_col_val||lv_colval_str||')' ;
    
   --DBMS_output.put_line('1111'||lv_insert_fixed_col||lv_inssql_cols||',NETSALARY,GROSSDEDN)'||lv_insert_fixed_col_val||lv_colval_str||')' );
   
   --execute immediate lv_insert_fixed_col||lv_inssql_cols||',NETSALARY,TOTALDED)'||lv_insert_fixed_col_val||lv_colval_str||')' ;
   
   --DBMS_output.put_line('1111'||lv_insert_fixed_col||lv_inssql_cols||lv_insert_fixed_col_val||lv_colval_str||')' );
    
   
  end loop; --c1
  --RETURN;
  --- update CAPREPAYAMOUNT , loanintamount , grossdeduction , netsalary ---
  for c_wrk in( select COMPANYCODE, DIVISIONCODE, YEARCODE, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO from PISARREARTRANSACTION 
                        WHERE yearmonth = lv_effective_ym
                        and transactiontype = 'ARREAR'
                        AND UNITCODE =  P_UNIT 
                        
           --comment on 02/09/2020 *************************************************************
--                        AND CATEGORYCODE =  P_CATEGORY 
--                        AND GRADECODE  =   P_GRADE  
           --comment on 02/09/2020 *************************************************************
                        -- and WORKERSERIAL = '00013' 
              ) loop               
      lv_sql := 'UPDATE PISARREARTRANSACTION set '||chr(10) ; 
      lv_cnt := 1;
      select count(*) into lv_rowcnt from LOANADJFROMARREAR
                      where   companycode  = c_wrk.COMPANYCODE
                           and   divisioncode = c_wrk.DIVISIONCODE
                           and   yearmonth    = lv_effective_ym
                           and   workerserial = c_wrk.WORKERSERIAL ;  
     
    IF lv_rowcnt > 0 THEN                             
      for c_lint in(  select LOANCODE, CAPREPAYAMOUNT, INTREPAYAMOUNT from LOANADJFROMARREAR
                      where   companycode  = c_wrk.COMPANYCODE
                           and   divisioncode = c_wrk.DIVISIONCODE
                           and   yearmonth    = lv_effective_ym
                           and   workerserial = c_wrk.WORKERSERIAL ) loop
                              
       if lv_cnt < lv_rowcnt then
        lv_sql :=  lv_sql||' LOAN_'||c_lint.LOANCODE||' = '||nvl(c_lint.CAPREPAYAMOUNT,0)||' , LINT_'||c_lint.LOANCODE||' = '||nvl(c_lint.INTREPAYAMOUNT,0)||' , GROSSDEDN = NVL(GROSSDEDN,0) + NVL('||c_lint.CAPREPAYAMOUNT||',0) + NVL('||c_lint.INTREPAYAMOUNT||',0) , NETSALARY = NETSALARY -'||nvl(c_lint.CAPREPAYAMOUNT,0)||'-'||nvl(c_lint.INTREPAYAMOUNT,0)||' , ';
       else
        lv_sql :=  lv_sql||' LOAN_'||c_lint.LOANCODE||' = '||nvl(c_lint.CAPREPAYAMOUNT,0)||' , LINT_'||c_lint.LOANCODE||' = '||nvl(c_lint.INTREPAYAMOUNT,0)||' , GROSSDEDN = NVL(GROSSDEDN,0) + NVL('||c_lint.CAPREPAYAMOUNT||',0) + NVL('||c_lint.INTREPAYAMOUNT||',0) , NETSALARY = NETSALARY -'||nvl(c_lint.CAPREPAYAMOUNT,0)||'-'||nvl(c_lint.INTREPAYAMOUNT,0)||'  '||chr(10);
       end if;
       lv_cnt:=lv_cnt+1;
      end loop;              
      lv_sql :=  lv_sql||' WHERE  COMPANYCODE = '''||c_wrk.COMPANYCODE||''' '||chr(10)
                       ||' AND    DIVISIONCODE = '''||c_wrk.DIVISIONCODE||''' '||chr(10)    
                       ||' AND    YEARCODE =     '''||c_wrk.YEARCODE||''' '||chr(10)   
                       ||' AND    YEARMONTH =     '''||lv_effective_ym||''' '||chr(10)  
                       ||' AND    TRANSACTIONTYPE =     ''ARREAR'' '||chr(10)
                       ||' AND    WORKERSERIAL =     '''||c_wrk.WORKERSERIAL||''' ' ;
     --dbms_output.put_line( ' UPDATE LOAN / DEDN '||lv_sql);         
     execute immediate  lv_sql;   
       
    END IF; 
  end loop;
  
  lv_startdate := '01/' || SUBSTR(P_EFFECTYEARMONTH,5,2) || '/' || SUBSTR(P_EFFECTYEARMONTH,1,4);   
  lv_enddate := TO_CHAR(ADD_MONTHS(to_date(lv_startdate,'dd/mm/yyyy'),1) -1,'DD/MM/YYYY');
    
  PRC_LOANBREAKUP_INSERT_WAGES 
  ( 
      P_COMPCODE ,  
      P_DIVCODE ,
      'XXXX-YYYY',
      lv_startdate, 
      lv_enddate,
      'PIS',
      'PISARREARTRANSACTION',
      'SALARY',
      NULL,
      NULL,
      NULL,
      'ARREAR'
  );
  
end;
commit;
-- end consolidation from ARRIL till ARREAR PROCESSING MONTH   --
----DBMS_output.put_line(lv_inssql_cols||lv_inssql_vals); 
END;
/
