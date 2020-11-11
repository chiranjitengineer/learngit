CREATE OR REPLACE PROCEDURE PRC_PISSALARYPROCESS_ARREAR 
(
      P_COMPCODE VARCHAR2,  
      P_DIVCODE VARCHAR2,
      P_TRANTYPE VARCHAR2, 
      P_PHASE  NUMBER, 
      P_YEARMONTH_FR VARCHAR2,
      P_YEARMONTH_TO VARCHAR2,
      P_EFFECTYEARMONTH VARCHAR2, 
      P_TABLENAME VARCHAR2,
      P_PHASE_TABLENAME VARCHAR2,
      P_UNIT  VARCHAR2,
      P_CATEGORY    VARCHAR2  DEFAULT NULL,
      P_GRADE       VARCHAR2  DEFAULT NULL,
      P_DEPARTMENT  VARCHAR2  DEFAULT NULL,
      P_WORKERSERIAL VARCHAR2 DEFAULT NULL
)
AS
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
LV_SQLSTR VARCHAR2(4000);
LV_COMPANYCODE VARCHAR2(10) := LTRIM(TRIM(P_COMPCODE)) ; -- 'LJ0054'    
LV_LOCATIONCODE VARCHAR2(10) := LTRIM(TRIM(P_DIVCODE))  ; -- 0001'
LV_YEARMONTH VARCHAR2(6) :=  LTRIM(TRIM(P_EFFECTYEARMONTH)) ;      --'201705';
LV_YEARMONTH_FR VARCHAR2(6) := LTRIM(TRIM(P_YEARMONTH_FR));
LV_YEARMONTH_TO VARCHAR2(6) :=  LTRIM(TRIM(P_YEARMONTH_TO));
--lv_yearmonth_fr varchar2(6) := substr(lv_yearmonth,1,4)||'04';
--lv_yearmonth_to varchar2(6) := substr(lv_yearmonth,1,4)||lpad(substr(lv_yearmonth,-2)-1,2,'0') ;
LV_WORKERSERIAL VARCHAR2(10):=  LTRIM(TRIM(P_WORKERSERIAL)) ;           --'000040' ;
LV_TOTARRCOMP INT;
LV_ROWCNT INT:=1;
LV_CNT INT;
LV_PER NUMBER := 80;
LV_SQL VARCHAR2(4000);
LV_INSSQL_COLS VARCHAR2(10000)  ;
LV_INSSQL_VALS VARCHAR2(10000)  ;     
LV_INSSQL_COLS_1  VARCHAR2(10000)  ;
LV_INSSQL_VALS_1 VARCHAR2(10000)  ;
LV_COL_VAL VARCHAR2(10000);
LV_COLVAL_STR VARCHAR2(10000);
LV_SUM_GROSSDEDN_COLVAL VARCHAR2(10000);
LV_SUM_NETSALARY_COLVAL VARCHAR2(10000);
LV_COLVAL_SUM_STR VARCHAR2(10000);
LV_DEDCOLSUM_STR VARCHAR2(10000);
LV_DEDCOLVAL_SUM_STR VARCHAR2(10000);
LV_NETSALCOLVAL_SUM_STR VARCHAR2(10000);
LV_COLVAL_SUM_STR_VAL VARCHAR2(10000);
LV_COLVAL_NEG_STR VARCHAR2(10000);
LV_COMPARREARAMT NUMBER(19,2);
LV_YEARMONTH_TMP VARCHAR2(6) := '';
LV_INSERT_FIXED_COL VARCHAR2(10000) ;
LV_INSERT_FIXED_COL_VAL VARCHAR2(10000) ;
LV_EFFECTIVE_YM VARCHAR2(10)   ;
LV_YEARCODE VARCHAR2(10)   ;
LV_STARTDATE VARCHAR2(10);
LV_ENDDATE   VARCHAR2(10);

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

SELECT COUNT(*) INTO LV_TOTARRCOMP FROM 
( 
    SELECT  DISTINCT COMPONENTCODE COL FROM PISCOMPONENTMASTER
                     --where INCLUDEARREAR = 'Y' 
    INTERSECT 
    SELECT COLUMN_NAME COL FROM COLS WHERE TABLE_NAME = 'PISARREARTRANSACTION'   
);


/*
    LV_SQLSTR := 'UPDATE PISARREARTRANSACTION_TEMP SET ' ;
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
    --execute immediate LV_SQLSTR ; 
 */
 
-- yearmonth , WORHER loop

    DELETE GTT_PISARREARTRANSACTION;
 
    DELETE FROM PISARREARTRANSACTION
    WHERE COMPANYCODE = NVL2(LV_COMPANYCODE,LV_COMPANYCODE ,COMPANYCODE )
    AND DIVISIONCODE = NVL2(LV_LOCATIONCODE,LV_LOCATIONCODE ,DIVISIONCODE )
    AND WORKERSERIAL = NVL2(LV_WORKERSERIAL,LV_WORKERSERIAL ,WORKERSERIAL )
    AND UNITCODE =  NVL2(P_UNIT , P_UNIT , UNITCODE)
    AND CATEGORYCODE = NVL2(P_CATEGORY , P_CATEGORY , CATEGORYCODE )
    AND GRADECODE  =  NVL2(P_GRADE , P_GRADE , GRADECODE)
    AND DEPARTMENTCODE =  NVL2(P_DEPARTMENT,P_DEPARTMENT,DEPARTMENTCODE)
    -- and ( YEARMONTH BETWEEN  lv_yearmonth_fr AND lv_yearmonth_to or YEARMONTH = lv_yearmonth  ) 
    AND EFFECT_YEARMONTH = LV_YEARMONTH
    AND WORKERSERIAL = NVL2(LV_WORKERSERIAL,LV_WORKERSERIAL ,WORKERSERIAL ) 
    AND TRANSACTIONTYPE <> 'NEW SALARY'  ;      


----DBMS_OUTPUT.PUT_LINE('ABC' || lv_yearmonth_fr || ',' || lv_yearmonth_to || ',' || lv_companycode  || ',' || lv_locationcode  || ',' || lv_workerserial) ;

--DBMS_OUTPUT.PUT_LINE(' WORKER WISE YEARMONTH WISE INSERT INTO GTT QUERY :- ') ;   
 

FOR C1 IN 
(
    SELECT COMPANYCODE , DIVISIONCODE , UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE , YEARMONTH , EFFECT_YEARMONTH ,WORKERSERIAL  
    FROM PISARREARTRANSACTION
    WHERE EFFECT_YEARMONTH = LV_YEARMONTH  AND YEARMONTH <= LV_YEARMONTH_TO
    /*YEARMONTH between lv_yearmonth_fr and lv_yearmonth_to*/
    AND COMPANYCODE = NVL2(LV_COMPANYCODE,LV_COMPANYCODE ,COMPANYCODE )
    AND DIVISIONCODE = NVL2(LV_LOCATIONCODE,LV_LOCATIONCODE ,DIVISIONCODE )
    AND WORKERSERIAL = NVL2(LV_WORKERSERIAL,LV_WORKERSERIAL ,WORKERSERIAL )
    AND UNITCODE =  NVL2(P_UNIT , P_UNIT , UNITCODE)
    AND CATEGORYCODE = NVL2(P_CATEGORY , P_CATEGORY , CATEGORYCODE )
    AND GRADECODE  =  NVL2(P_GRADE , P_GRADE , GRADECODE)
    AND DEPARTMENTCODE =  NVL2(P_DEPARTMENT,P_DEPARTMENT,DEPARTMENTCODE)
    ORDER BY COMPANYCODE , DIVISIONCODE , UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE , YEARMONTH , WORKERSERIAL 
) LOOP      
       
    --  --DBMS_OUTPUT.PUT_LINE('INSIDE LOOP 1') ;       
       

       LV_INSSQL_COLS := 'INSERT INTO GTT_PISARREARTRANSACTION( ' ;
       LV_INSSQL_VALS  := ' VALUES( ';             
       LV_COL_VAL := '';
       LV_COLVAL_STR := '''';
       
   
       FOR C3 IN (
                   SELECT COLUMN_NAME COL FROM COLS WHERE TABLE_NAME = 'PISARREARTRANSACTION'
                   MINUS
                   SELECT DISTINCT COMPONENTCODE FROM PISCOMPONENTMASTER
                    -- where INCLUDEARREAR = 'Y'  
                 ) LOOP                    
                 LV_INSSQL_COLS := LV_INSSQL_COLS||C3.COL||' , '||CHR(10) ;
                 IF LTRIM(TRIM(C3.COL)) = 'TRANSACTIONTYPE' THEN
                   LV_COLVAL_STR := LV_COLVAL_STR||'''''''||''MONTHLYARR''||'''''','  ;
                  ELSE
                   LV_COLVAL_STR := LV_COLVAL_STR||'''''''||'||C3.COL||'||'''''','  ;
                  END IF;                           
        END LOOP;
        LV_COLVAL_STR := LV_COLVAL_STR||'''' ;        
        LV_SQL := 'select '||LV_COLVAL_STR||'  from PISARREARTRANSACTION  where  companycode = '''||C1.COMPANYCODE||'''  and DIVISIONCODE = '''||C1.DIVISIONCODE||''' and  UNITCODE = '''||C1.UNITCODE||''' and  DEPARTMENTCODE = '''||C1.DEPARTMENTCODE||''' and  CATEGORYCODE = '''||C1.CATEGORYCODE||''' and  GRADECODE  = '''||C1.GRADECODE||''' and YEARMONTH = '''||C1.YEARMONTH||''' and WORKERSERIAL = '''||C1.WORKERSERIAL||'''  ';
        
      --  DBMS_OUTPUT.PUT_LINE(  lv_sql );       
        EXECUTE IMMEDIATE LV_SQL INTO LV_COL_VAL;
        
        LV_INSSQL_VALS := LV_INSSQL_VALS||LV_COL_VAL;        
      
        ----DBMS_OUTPUT.PUT_LINE(lv_inssql_vals);
          
      --  exit; 
         LV_COLVAL_STR := '';
         LV_COLVAL_SUM_STR := '';
         LV_COLVAL_NEG_STR := '';
         LV_ROWCNT :=1;
         FOR C2 IN ( 
            SELECT DISTINCT COMPONENTCODE COL FROM PISCOMPONENTMASTER
            --where INCLUDEARREAR = 'Y' 
            INTERSECT 
            SELECT COLUMN_NAME COL FROM COLS WHERE TABLE_NAME = 'PISARREARTRANSACTION'         
         ) LOOP   
              IF LV_ROWCNT < LV_TOTARRCOMP THEN
                LV_INSSQL_COLS := LV_INSSQL_COLS||C2.COL||' , '||CHR(10) ;
                LV_COLVAL_STR := LV_COLVAL_STR||''||C2.COL||','  ;
                LV_COLVAL_SUM_STR := LV_COLVAL_SUM_STR||'''''''||SUM('||C2.COL||')||'''''','  ;
                LV_COLVAL_NEG_STR := LV_COLVAL_NEG_STR||''||C2.COL||'*-1,'  ;
              ELSE
                LV_INSSQL_COLS := LV_INSSQL_COLS||C2.COL||' ) '||CHR(10) ;
                LV_COLVAL_STR := LV_COLVAL_STR||''||C2.COL  ;
                LV_COLVAL_SUM_STR := LV_COLVAL_SUM_STR||'''''''||SUM('||C2.COL||')||'''''''  ;
                LV_COLVAL_NEG_STR := LV_COLVAL_NEG_STR||''||C2.COL||'*-1'  ;
              END IF;  
              LV_ROWCNT:=LV_ROWCNT+1;
--             select c2.COMPONENTCODE into x from tab a where --- ;
--             select c2.COMPONENTCODE into y from tab b where --- ;
--             lv_comparrearamt = x-y ;
--             lv_insertsql =
--             insert into gtt_arreartab( c2.COMPONENTCODE ,
--                                   values(  lv_comparrearamt ,           
         END LOOP;
          
          LV_INSSQL_COLS_1 := REPLACE(LV_INSSQL_COLS,'GTT_PISARREARTRANSACTION' ,'PISARREARTRANSACTION') ;
          --lv_inssql_vals_1 := replace(lv_inssql_vals ,'MONTHLYARR','ARREAR'); 
          --lv_inssql_vals_1 := replace(lv_inssql_vals ,'MONTHLYARR','TOT ARREAR');         
          LV_SQL := 'select '''||LV_COLVAL_SUM_STR||''' from (
                            (      
                            select '||LV_COLVAL_STR||' from PISARREARTRANSACTION where companycode = '''||C1.COMPANYCODE||'''  and DIVISIONCODE = '''||C1.DIVISIONCODE||''' and  UNITCODE = '''||C1.UNITCODE||''' and  DEPARTMENTCODE = '''||C1.DEPARTMENTCODE||''' and  CATEGORYCODE = '''||C1.CATEGORYCODE||''' and  GRADECODE  = '''||C1.GRADECODE||''' and YEARMONTH = '''||C1.YEARMONTH||''' and TRANSACTIONTYPE = ''NEW SALARY'' and WORKERSERIAL = '''||C1.WORKERSERIAL||''' 
                            union all
                            select '||LV_COLVAL_NEG_STR||' from PISPAYTRANSACTION  where companycode = '''||C1.COMPANYCODE||'''  and DIVISIONCODE = '''||C1.DIVISIONCODE||''' and  UNITCODE = '''||C1.UNITCODE||''' and  DEPARTMENTCODE = '''||C1.DEPARTMENTCODE||''' and  CATEGORYCODE = '''||C1.CATEGORYCODE||''' and  GRADECODE  = '''||C1.GRADECODE||''' and YEARMONTH = '''||C1.YEARMONTH||''' and TRANSACTIONTYPE = ''SALARY'' and WORKERSERIAL = '''||C1.WORKERSERIAL||'''  
                            ) )' ;     
          --DBMS_OUTPUT.PUT_LINE('xxx'||lv_sql);   
           --RETURN;             
           
           
                
           EXECUTE IMMEDIATE LV_SQL INTO LV_COLVAL_SUM_STR_VAL ;      
           LV_INSSQL_VALS := LV_INSSQL_VALS||LV_COLVAL_SUM_STR_VAL||')' ;
           ----DBMS_OUTPUT.PUT_LINE(lv_inssql_cols||lv_inssql_vals);
           EXECUTE IMMEDIATE LV_INSSQL_COLS||LV_INSSQL_VALS;
           
           
           ----DBMS_OUTPUT.PUT_LINE(lv_inssql_cols||lv_inssql_vals) ;     
        --  --DBMS_OUTPUT.PUT_LINE('INSIDE LOOP 2') ;      
END LOOP; -- c1    
COMMIT; 

--DBMS_OUTPUT.PUT_LINE(' query for consolidation from ARRIL till ARREAR PROCESSING MONTH for above arrear processed workers :- ') ;   

-- end yearmonth , WORKER loop 
-- start consolidation from ARRIL till ARREAR PROCESSING MONTH for above arrear processed workers --
INSERT INTO PISARREARTRANSACTION SELECT * FROM GTT_PISARREARTRANSACTION ;
--return;
LV_EFFECTIVE_YM   := LV_YEARMONTH ; 
BEGIN    
  FOR C1 IN ( 
    SELECT DISTINCT COMPANYCODE, DIVISIONCODE, YEARCODE, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO 
    FROM GTT_PISARREARTRANSACTION WHERE TRANSACTIONTYPE = 'MONTHLYARR'
  ) LOOP
  LV_YEARCODE := C1.YEARCODE ;
  LV_INSERT_FIXED_COL := 'INSERT INTO PISARREARTRANSACTION (COMPANYCODE, DIVISIONCODE, YEARCODE, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO , YEARMONTH, EFFECT_YEARMONTH,TRANSACTIONTYPE ,' ;
  LV_INSERT_FIXED_COL_VAL :=   ' VALUES ( '''||C1.COMPANYCODE||''','''|| C1.DIVISIONCODE||''','''||LV_YEARCODE||''','''||C1.UNITCODE||''','''||C1.DEPARTMENTCODE||''','''||C1.CATEGORYCODE||''','''||C1.GRADECODE||''','''||C1.WORKERSERIAL||''','''||C1.TOKENNO||''','''||LV_EFFECTIVE_YM||''','''||LV_EFFECTIVE_YM||''',''ARREAR'' , ';
  LV_INSSQL_COLS :=''  ;
  LV_INSSQL_VALS :=''  ; 
  LV_COLVAL_STR  :='' ;
  LV_COLVAL_SUM_STR := '' ;
  LV_DEDCOLVAL_SUM_STR := '';
  LV_DEDCOLSUM_STR := '';
  LV_ROWCNT :=1;
        
        
  SELECT COUNT(DISTINCT COMPONENTCODE) INTO LV_TOTARRCOMP FROM PISCOMPONENTMASTER A WHERE COMPANYCODE = C1.COMPANYCODE AND DIVISIONCODE = C1.DIVISIONCODE AND
               INCLUDEARREAR = 'Y'  
               AND YEARMONTH = (SELECT MAX(YEARMONTH) FROM PISCOMPONENTMASTER B WHERE 
                               A.COMPANYCODE = B.COMPANYCODE
                               AND A.DIVISIONCODE = B.DIVISIONCODE
                               AND A.COMPONENTCODE = B.COMPONENTCODE 
                               --and COMPONENTTYPE = 'DEDUCTION' 
                               AND INCLUDEARREAR = 'Y' );
  FOR C3 IN 
  ( 
        SELECT DISTINCT COMPONENTCODE COL
        FROM PISCOMPONENTMASTER A
        WHERE COMPANYCODE = C1.COMPANYCODE
        AND   DIVISIONCODE = C1.DIVISIONCODE
        AND COMPONENTTYPE = 'DEDUCTION' 
        AND INCLUDEARREAR = 'Y'
        AND YEARMONTH = 
        (
            SELECT MAX(YEARMONTH) FROM PISCOMPONENTMASTER B WHERE 
            A.COMPANYCODE = B.COMPANYCODE
            AND A.DIVISIONCODE = B.DIVISIONCODE
            AND A.COMPONENTCODE = B.COMPONENTCODE 
            AND COMPONENTTYPE = 'DEDUCTION' 
            AND INCLUDEARREAR = 'Y' 
        )  
    ) LOOP       
      IF LV_ROWCNT = 1 THEN
        LV_DEDCOLVAL_SUM_STR :=  LV_DEDCOLVAL_SUM_STR||'''''''||SUM('||C3.COL||')' ; 
        LV_DEDCOLSUM_STR := LV_DEDCOLSUM_STR||'SUM(NVL('||C3.COL||',0))' ;               
      ELSE
        LV_DEDCOLVAL_SUM_STR :=  LV_DEDCOLVAL_SUM_STR||'+SUM('||C3.COL||')' ;
        LV_DEDCOLSUM_STR := LV_DEDCOLSUM_STR||'+SUM(NVL('||C3.COL||',0))' ; 
      END IF;                    
  LV_ROWCNT := LV_ROWCNT+1;
  END LOOP; -- c3
  LV_NETSALCOLVAL_SUM_STR := '''''''||( SUM(NVL(GROSSEARN,0)) - ('||LV_DEDCOLSUM_STR||'))||'''''' '; 
  LV_DEDCOLVAL_SUM_STR:= '''''''||('||LV_DEDCOLSUM_STR||')||'''''' ';
  ----DBMS_output.put_line(lv_netsalcolval_sum_str);
  ----DBMS_output.put_line(lv_dedcolval_sum_str);
  --return;
  LV_ROWCNT :=1;
  FOR C2 IN ( SELECT DISTINCT COMPONENTCODE COL FROM PISCOMPONENTMASTER A
              WHERE COMPANYCODE = C1.COMPANYCODE AND DIVISIONCODE = C1.DIVISIONCODE AND
               INCLUDEARREAR = 'Y'  
               AND YEARMONTH = (SELECT MAX(YEARMONTH) FROM PISCOMPONENTMASTER B WHERE 
                               A.COMPANYCODE = B.COMPANYCODE
                               AND A.DIVISIONCODE = B.DIVISIONCODE
                               AND A.COMPONENTCODE = B.COMPONENTCODE 
                               --and COMPONENTTYPE = 'DEDUCTION' 
                               AND INCLUDEARREAR = 'Y' )         
               ) LOOP   
              IF LV_ROWCNT < LV_TOTARRCOMP THEN
                LV_INSSQL_COLS := LV_INSSQL_COLS||C2.COL||' , '||CHR(10) ;
                LV_COLVAL_STR := LV_COLVAL_STR||''||C2.COL||','  ;
                LV_COLVAL_SUM_STR := LV_COLVAL_SUM_STR||'''''''||SUM('||C2.COL||')||'''''','  ;                 
              ELSE
                LV_INSSQL_COLS := LV_INSSQL_COLS||C2.COL||'  '||CHR(10) ; -- prev )
                LV_COLVAL_STR := LV_COLVAL_STR||''||C2.COL  ;
                LV_COLVAL_SUM_STR := LV_COLVAL_SUM_STR||'''''''||SUM('||C2.COL||')||'''''''  ;                 
              END IF;  
              LV_ROWCNT:=LV_ROWCNT+1;                
         END LOOP;      -- c2    
   -- --DBMS_output.put_line(   lv_inssql_cols );
   -- --DBMS_output.put_line(   lv_colval_str );
    ----DBMS_output.put_line(   lv_colval_sum_str );  
    LV_SQL := 'select '''||LV_COLVAL_SUM_STR||','||LV_NETSALCOLVAL_SUM_STR||','||LV_DEDCOLVAL_SUM_STR||''' from GTT_PISARREARTRANSACTION where  '||CHR(10)
               ||' COMPANYCODE = '''||C1.COMPANYCODE ||'''  '||CHR(10)
               ||' AND DIVISIONCODE = '''||C1.DIVISIONCODE ||'''  '||CHR(10)
               ||' AND UNITCODE = '''||C1.UNITCODE ||'''  '||CHR(10)
               ||' AND DEPARTMENTCODE = '''||C1.DEPARTMENTCODE ||'''  '||CHR(10)
               ||' AND CATEGORYCODE = '''||C1.CATEGORYCODE ||'''  '||CHR(10)
               ||' AND GRADECODE = '''||C1.GRADECODE ||'''  '||CHR(10)
               ||' AND WORKERSERIAL = '''||C1.WORKERSERIAL ||'''  '||CHR(10)
               ||' AND  TOKENNO = '''||C1.TOKENNO ||'''  '||CHR(10) ;       
    --DBMS_output.put_line( ' nEt sal - ' || lv_sql );  
    --return;  
    
    EXECUTE IMMEDIATE  LV_SQL INTO LV_COLVAL_STR   ;
   -- --DBMS_output.put_line(  lv_insert_fixed_col||lv_inssql_cols||lv_insert_fixed_col_val||lv_colval_str||')' ); 
   --DBMS_output.put_line( lv_insert_fixed_col||lv_inssql_cols||',NETSALARY,GROSSDEDN)'||lv_insert_fixed_col_val||lv_colval_str||')' ) ;
   --return;
   
--    DBMS_output.put_line(lv_insert_fixed_col);
--    DBMS_output.put_line(lv_inssql_cols);
--    DBMS_output.put_line(',NETSALARY,GROSSDEDN)');
--    DBMS_output.put_line(lv_insert_fixed_col_val);
--    DBMS_output.put_line(lv_colval_str);
    
   
   
 
   EXECUTE IMMEDIATE LV_INSERT_FIXED_COL||LV_INSSQL_COLS||',NETSALARY,GROSSDEDN)'||LV_INSERT_FIXED_COL_VAL||LV_COLVAL_STR||')' ;
    
   --DBMS_output.put_line('1111'||lv_insert_fixed_col||lv_inssql_cols||',NETSALARY,GROSSDEDN)'||lv_insert_fixed_col_val||lv_colval_str||')' );
   
   --execute immediate lv_insert_fixed_col||lv_inssql_cols||',NETSALARY,TOTALDED)'||lv_insert_fixed_col_val||lv_colval_str||')' ;
   
   --DBMS_output.put_line('1111'||lv_insert_fixed_col||lv_inssql_cols||lv_insert_fixed_col_val||lv_colval_str||')' );
    
   
  END LOOP; --c1
  --RETURN;
  --- update CAPREPAYAMOUNT , loanintamount , grossdeduction , netsalary ---
    FOR C_WRK IN
    ( 
        SELECT COMPANYCODE, DIVISIONCODE, YEARCODE, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO FROM PISARREARTRANSACTION 
        WHERE YEARMONTH = LV_EFFECTIVE_YM
        AND TRANSACTIONTYPE = 'ARREAR'
        AND UNITCODE =  P_UNIT 
        AND CATEGORYCODE =  P_CATEGORY 
        AND GRADECODE  =   P_GRADE  
                        -- and WORKERSERIAL = '00013' 
    ) LOOP               
      LV_SQL := 'UPDATE PISARREARTRANSACTION set '||CHR(10) ; 
      LV_CNT := 1;
      SELECT COUNT(*) INTO LV_ROWCNT FROM LOANADJFROMARREAR
                      WHERE   COMPANYCODE  = C_WRK.COMPANYCODE
                           AND   DIVISIONCODE = C_WRK.DIVISIONCODE
                           AND   YEARMONTH    = LV_EFFECTIVE_YM
                           AND   WORKERSERIAL = C_WRK.WORKERSERIAL ;  
     
    IF LV_ROWCNT > 0 THEN                             
    FOR C_LINT IN (     SELECT LOANCODE, CAPREPAYAMOUNT, INTREPAYAMOUNT FROM LOANADJFROMARREAR
                        WHERE   COMPANYCODE  = C_WRK.COMPANYCODE
                        AND   DIVISIONCODE = C_WRK.DIVISIONCODE
                        AND   YEARMONTH    = LV_EFFECTIVE_YM
                        AND   WORKERSERIAL = C_WRK.WORKERSERIAL 
                   ) LOOP
                              
       IF LV_CNT < LV_ROWCNT THEN
        LV_SQL :=  LV_SQL||' LOAN_'||C_LINT.LOANCODE||' = '||NVL(C_LINT.CAPREPAYAMOUNT,0)||' , LINT_'||C_LINT.LOANCODE||' = '||NVL(C_LINT.INTREPAYAMOUNT,0)||' , GROSSDEDN = NVL(GROSSDEDN,0) + NVL('||C_LINT.CAPREPAYAMOUNT||',0) + NVL('||C_LINT.INTREPAYAMOUNT||',0) , NETSALARY = NETSALARY -'||NVL(C_LINT.CAPREPAYAMOUNT,0)||'-'||NVL(C_LINT.INTREPAYAMOUNT,0)||' , ';
       ELSE
        LV_SQL :=  LV_SQL||' LOAN_'||C_LINT.LOANCODE||' = '||NVL(C_LINT.CAPREPAYAMOUNT,0)||' , LINT_'||C_LINT.LOANCODE||' = '||NVL(C_LINT.INTREPAYAMOUNT,0)||' , GROSSDEDN = NVL(GROSSDEDN,0) + NVL('||C_LINT.CAPREPAYAMOUNT||',0) + NVL('||C_LINT.INTREPAYAMOUNT||',0) , NETSALARY = NETSALARY -'||NVL(C_LINT.CAPREPAYAMOUNT,0)||'-'||NVL(C_LINT.INTREPAYAMOUNT,0)||'  '||CHR(10);
       END IF;
       LV_CNT:=LV_CNT+1;
      END LOOP;              
      LV_SQL :=  LV_SQL||' WHERE  COMPANYCODE = '''||C_WRK.COMPANYCODE||''' '||CHR(10)
                       ||' AND    DIVISIONCODE = '''||C_WRK.DIVISIONCODE||''' '||CHR(10)    
                       ||' AND    YEARCODE =     '''||C_WRK.YEARCODE||''' '||CHR(10)   
                       ||' AND    YEARMONTH =     '''||LV_EFFECTIVE_YM||''' '||CHR(10)  
                       ||' AND    TRANSACTIONTYPE =     ''ARREAR'' '||CHR(10)
                       ||' AND    WORKERSERIAL =     '''||C_WRK.WORKERSERIAL||''' ' ;
     --dbms_output.put_line( ' UPDATE LOAN / DEDN '||lv_sql);         
     EXECUTE IMMEDIATE  LV_SQL;   
       
    END IF; 
  END LOOP;
  
  
END;
COMMIT;
-- end consolidation from ARRIL till ARREAR PROCESSING MONTH   --
----DBMS_output.put_line(lv_inssql_cols||lv_inssql_vals); 
END;
/
