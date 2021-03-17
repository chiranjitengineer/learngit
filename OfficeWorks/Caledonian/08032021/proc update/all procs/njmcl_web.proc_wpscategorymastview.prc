DROP PROCEDURE NJMCL_WEB.PROC_WPSCATEGORYMASTVIEW;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPSCATEGORYMASTVIEW
(
P_COMPANYCODE    VARCHAR2,
P_DIVISIONCODE   VARCHAR2,
P_REF_TABLE_NAME VARCHAR2, 
P_REF_KEY_COL1   VARCHAR2,
P_REF_KEY_COL2   VARCHAR2 DEFAULT NULL      
)
as
-- exec proc_gpscategorymastview('BJ0056','0001','GPSCATEGORYMAST') ;
--                COMPANYCODE=P_COMPANYCODE
--            AND DIVISIONCODE=P_DIVISIONCODE
--            AND MODULE = 'GPS'
--            AND REF_TABLE_NAME = LV_REF_TABLE_NAME
LV_COMPANYCODE         VARCHAR2(10 BYTE) := LTRIM(TRIM(P_COMPANYCODE)) ;   
LV_DIVISIONCODE        VARCHAR2(10 BYTE) := LTRIM(TRIM(P_DIVISIONCODE)) ;
LV_REF_TABLE_NAME      VARCHAR2(30)      := LTRIM(TRIM(P_REF_TABLE_NAME)) ;
--LV_YEARCODE            VARCHAR2(10 BYTE) := LTRIM(TRIM(P_YEARCODE)) ;
lv_CATMASTCOLS varchar2(10000) := 'SELECT ';
lv_end_sql varchar2(10000) ;
lv_table varchar2(30) := LV_REF_TABLE_NAME ;
--lv_catparams_cols varchar2(4000);
lv_catparams_cols_with_null CLOB := '';
lv_catparams_cols CLOB := '';
lv_catparams_cols_list CLOB := '';
--lv_cat_param_id varchar2(10):='P';
lv_VIEW_COL_VAL varchar2(300);
lv_totcat int;
lv_catrow int;
lv_tot_param_COL int;
lv_param_row int;
lv_endstr varchar2(2);
lv_view_name varchar2(30) := 'VW_'||lv_table ;
lv_sql CLOB  := 'CREATE OR REPLACE FORCE VIEW '||lv_view_name||chr(10)||' AS '||chr(10) ;
lv_sqlerrm  VARCHAR2(250) := '';
lv_sql_create varchar2(4000) ;
lv_comp_div_cnt int := 0;
lv_tot_comp_div_cnt int;
----------  START SUB ROUTINE ------
--------------------------------------
procedure p_create_blank_view_table( p_view_tab varchar2 DEFAULT 'VIEWTAB_GPSCATEGORYMAST', p_ref_tablename varchar2 DEFAULT 'GPSCATEGORYMAST' )
         as
           lv_sql_create varchar2(4000) := 'create table '||p_view_tab||' ('||chr(10); 
           lv_rows int;
           lv_loop int;
         begin             
           select count(*) into lv_rows from cols a where table_name = p_ref_tablename 
           and column_name not in (/*'COMPANYCODE','DIVISIONCODE',*/'USERNAME','LASTMODIFIED','SYSROWID') ;
           lv_loop := 0;   
           for c1 in (
             select column_name , DATA_TYPE , DATA_LENGTH, DATA_PRECISION, DATA_SCALE  from cols a where table_name = p_ref_tablename 
           and column_name not in (/*'COMPANYCODE','DIVISIONCODE',*/'USERNAME','LASTMODIFIED','SYSROWID')
           order by column_id      ) loop
             lv_loop := lv_loop+1;
            -- if lv_loop < lv_rows then
              if c1.DATA_TYPE = 'VARCHAR2' then
                lv_sql_create := lv_sql_create ||c1.column_name||' '||c1.data_type||'('||c1.DATA_LENGTH||') ,'||chr(10) ;
              elsif c1.DATA_TYPE = 'NUMBER' then
                if c1.DATA_PRECISION is not null then
                 lv_sql_create := lv_sql_create ||c1.column_name||' '||c1.data_type||'('||c1.DATA_PRECISION||','||c1.DATA_SCALE ||' ) ,'||chr(10) ;
                else
                 lv_sql_create := lv_sql_create ||c1.column_name||' '||c1.data_type||' ,'||chr(10) ;
                end if;
              else
                lv_sql_create := lv_sql_create ||c1.column_name||' '||c1.data_type||' ,'||chr(10) ;
              end if;                               
            end loop;
           ----       
           select count(*) into lv_rows 
           from(
              SELECT REPLACE(PARAM_NAME,CHR(32)) AS VIEW_COL,OBJECT_TYPE DATA_TYPE,MAX(DATA_TYPE)  WIDTH /*,MAX(MAXLENGTH) MAXLENGTH */  FROM SYS_SWT_TABLE_PARAMMAST
                                        WHERE 1=1 /*COMPANYCODE=P_COMPANYCODE
                                        AND DIVISIONCODE=P_DIVISIONCODE*/
                                        AND REF_TABLE_NAME = p_ref_tablename
             GROUP BY  REPLACE(PARAM_NAME,CHR(32)) , OBJECT_TYPE 
           );
            lv_loop:=0;
            for c1 in (
             SELECT REPLACE(PARAM_NAME,CHR(32)) AS VIEW_COL,OBJECT_TYPE DATA_TYPE,MAX(DATA_TYPE)  WIDTH /*,MAX(MAXLENGTH) MAXLENGTH */  FROM SYS_SWT_TABLE_PARAMMAST
                                        WHERE 1=1 /*COMPANYCODE=P_COMPANYCODE
                                        AND DIVISIONCODE=P_DIVISIONCODE*/
                                        AND REF_TABLE_NAME = p_ref_tablename
             GROUP BY  REPLACE(PARAM_NAME,CHR(32)) , OBJECT_TYPE  
             order by   VIEW_COL   ) loop
             lv_loop := lv_loop+1;
             if lv_loop < lv_rows then
              lv_sql_create := lv_sql_create ||c1.view_col||' '||c1.data_type||'('||c1.width||') ,'||chr(10) ;
             else
              lv_sql_create := lv_sql_create ||c1.view_col||' '||c1.data_type||'('||c1.width||') '||chr(10)||')' ;
             end if;                        
            end loop;
            execute immediate lv_sql_create ;
end;
----------- END SUB ROUTINE ----------
--------------------------------------
BEGIN
for c2 in( select column_name from cols where table_name = LV_REF_TABLE_NAME 
           and column_name not in (/*'COMPANYCODE','DIVISIONCODE',*/'USERNAME','LASTMODIFIED','SYSROWID')
           order by column_id
         ) loop
       lv_CATMASTCOLS := lv_CATMASTCOLS||c2.column_name||' ,' ;       
end loop;
lv_end_sql := lv_end_sql||' from '||lv_table ;
----DBMS_OUTPUT.PUT_LINE(lv_CATMASTCOLS);
if lv_table = 'GPSCATEGORYMAST' then
--    select count(distinct param_id) into lv_totcat FROM SYS_SWT_PARAMDETAILS 
--                WHERE COMPANYCODE=P_COMPANYCODE
--                AND DIVISIONCODE=P_DIVISIONCODE
--                AND MODULE = 'GPS'
--                AND REF_TABLE_NAME = LV_REF_TABLE_NAME
--                AND PARAM_VALUE IS NOT NULL;                
     select count(distinct CATEGORYCODE)  into lv_totcat FROM GPSCATEGORYMAST
                WHERE 1=1 /*COMPANYCODE=P_COMPANYCODE
                AND DIVISIONCODE=P_DIVISIONCODE*/                
                AND CATEGORYCODE IS NOT NULL;    
                lv_catrow := 0;
      select count(*) into lv_tot_comp_div_cnt from (
                           select distinct companycode,divisioncode from GPSCATEGORYMAST
                           );           
     FOR CD IN( SELECT DISTINCT COMPANYCODE, DIVISIONCODE FROM GPSCATEGORYMAST ) LOOP   
            lv_catrow := 0;  
            lv_comp_div_cnt := lv_comp_div_cnt+1;
            for c2 in ( select distinct categorycode FROM GPSCATEGORYMAST
                        WHERE 1=1 /*COMPANYCODE=P_COMPANYCODE
                        AND DIVISIONCODE=P_DIVISIONCODE */                
                        AND CATEGORYCODE IS NOT NULL    ) loop  
                        lv_catparams_cols := '';    
                        lv_catrow := lv_catrow + 1;
                       -- select count(distinct PARAM_NAME) into lv_tot_param_COL 
                        select count(*) into lv_tot_param_COL 
                        FROM ( 
                               SELECT PARAM_NAME ,REPLACE(PARAM_NAME,CHR(32)) AS VIEW_COL,OBJECT_TYPE DATA_TYPE,MAX(DATA_TYPE)  WIDTH /*,MAX(MAXLENGTH) MAXLENGTH */  FROM SYS_SWT_TABLE_PARAMMAST
                                        WHERE 1=1 /*COMPANYCODE=P_COMPANYCODE
                                        AND DIVISIONCODE=P_DIVISIONCODE*/
                                        AND REF_TABLE_NAME = LV_REF_TABLE_NAME
                                      GROUP BY PARAM_NAME, REPLACE(PARAM_NAME,CHR(32)) , OBJECT_TYPE    
                                    ) ;          
                        lv_param_row := 0;
                        for c1 in( SELECT PARAM_NAME ,REPLACE(PARAM_NAME,CHR(32)) AS VIEW_COL,OBJECT_TYPE DATA_TYPE,MAX(DATA_TYPE)  WIDTH /*,MAX(MAXLENGTH) MAXLENGTH */  FROM SYS_SWT_TABLE_PARAMMAST
                                        WHERE 1=1 /*COMPANYCODE=P_COMPANYCODE
                                        AND DIVISIONCODE=P_DIVISIONCODE*/
                                        AND REF_TABLE_NAME = LV_REF_TABLE_NAME
                                    GROUP BY  PARAM_NAME ,REPLACE(PARAM_NAME,CHR(32)) , OBJECT_TYPE  
                                    order by   VIEW_COL 
                                   ) loop
                                   lv_param_row := lv_param_row+1;  
                                   BEGIN  
                                    select NVL(param_value,'NULL') into lv_VIEW_COL_VAL from SYS_SWT_PARAMDETAILS where COMPANYCODE= CD.COMPANYCODE and  DIVISIONCODE = CD.DIVISIONCODE and param_id = c2.categorycode and PARAM_NAME = c1.param_name 
                                    AND EFFECTIVEDATE = ( SELECT MAX(EFFECTIVEDATE) FROM 
                                                         SYS_SWT_PARAMDETAILS WHERE REF_TABLE_NAME = LV_REF_TABLE_NAME
                                                          AND COMPANYCODE= CD.COMPANYCODE and  DIVISIONCODE = CD.DIVISIONCODE and PARAM_NAME = c1.param_name /*AND PARAM_VALUE > 0 */AND PARAM_ID = c2.categorycode);
                                    --and PARAM_VALUE > 0 ;     
                                   EXCEPTION 
                                    WHEN OTHERS THEN
                                      lv_VIEW_COL_VAL := 'NULL';
                                   END;  
                                   lv_VIEW_COL_VAL := LTRIM(TRIM(lv_VIEW_COL_VAL));
                                  --  dbms_output.put_line(c1.VIEW_COL||chr(10)|| lv_param_row|| ' TOT'|| lv_tot_param_COL || ' UNION ALL ');
                           
                                   
                                   select decode(lv_param_row, lv_tot_param_COL,' ',',' )  into lv_endstr from dual;
                                   if lv_VIEW_COL_VAL = 'NULL' then
                                    lv_catparams_cols := lv_catparams_cols||' NULL  AS '||c1.VIEW_COL||lv_endstr ;                                      
                                   else  
                                     if c1.DATA_TYPE = 'VARCHAR2' or c1.DATA_TYPE = 'DATE'  then       
                                      lv_catparams_cols := lv_catparams_cols||' '''||lv_VIEW_COL_VAL||'''  AS '||c1.VIEW_COL||lv_endstr ;
                                     else
                                      lv_catparams_cols := lv_catparams_cols||' '||lv_VIEW_COL_VAL||'  AS '||c1.VIEW_COL||lv_endstr ;
                                     -- dbms_output.put_line(c1.VIEW_COL||chr(10)||' UNION ALL ');
                                     end if; 
                                   end if  ;                       
                          end loop;
                          --- CHANGES ON 28/12/2018 -----
                          --lv_end_sql := ' FROM '||lv_table||' WHERE COMPANYCODE = '''||P_COMPANYCODE||''' AND DIVISIONCODE = '''||P_DIVISIONCODE||''' AND '||P_REF_KEY_COL1||' = '''||c2.categorycode||'''' ;            
                    -- if lv_tot_param_COL > 0 then 
                          lv_end_sql := ' FROM '||lv_table||' WHERE 1=1  AND '||P_REF_KEY_COL1||' = '''||c2.categorycode||'''  AND COMPANYCODE= '''||CD.COMPANYCODE||''' and  DIVISIONCODE = '''||CD.DIVISIONCODE||''' ' ;
                        /*  if lv_catrow <  lv_totcat then
                            lv_catparams_cols := SUBSTR(lv_catparams_cols,1,LENGTH(lv_catparams_cols)-1);
                           --dbms_output.put_line(lv_CATMASTCOLS||' '||lv_catparams_cols||lv_end_sql||chr(10)||' UNION ALL ');
                           lv_sql := lv_sql||lv_CATMASTCOLS||' '||lv_catparams_cols||lv_end_sql||chr(10)||' UNION ALL ' ;
                          else
                           --dbms_output.put_line(lv_CATMASTCOLS||' '||lv_catparams_cols||lv_end_sql);
                            if  lv_comp_div_cnt < lv_tot_comp_div_cnt then
                              lv_sql := lv_sql||lv_CATMASTCOLS||' '||lv_catparams_cols||lv_end_sql||chr(10)||' UNION ALL ';
                            else
                              lv_sql := lv_sql||lv_CATMASTCOLS||' '||lv_catparams_cols||lv_end_sql ;
                            end if;  
                             
                          end if;*/
                    --end if;    
                     if lv_tot_param_COL > 0 then    -- ab                            
                         if lv_catrow =1 and lv_comp_div_cnt = 1 then           
                           lv_sql_create := 'drop table VIEWTAB_GPSCATEGORYMAST ';
                           BEGIN
                            execute immediate lv_sql_create ;
                           EXCEPTION
                            WHEN OTHERS THEN
                             NULL;
                           END;                           
                          -- lv_sql_create := 'create table VIEWTAB_GPSCATEGORYMAST as '||lv_CATMASTCOLS||' '||lv_catparams_cols||lv_end_sql ;
                          --dbms_output.put_line(lv_sql_create); 
                          --execute immediate lv_sql_create ;    
                          p_create_blank_view_table ;  
                          lv_sql_create := 'insert into VIEWTAB_GPSCATEGORYMAST '||lv_CATMASTCOLS||' '||lv_catparams_cols||lv_end_sql ;                           
                           execute immediate lv_sql_create ;
                          --return;       
                          -- exit; -- create table xxxx as lv_sql
                         else
                           lv_sql_create := 'insert into VIEWTAB_GPSCATEGORYMAST '||lv_CATMASTCOLS||' '||lv_catparams_cols||lv_end_sql ;                           
                           execute immediate lv_sql_create ;
                           
                         end if;   
                     end if;    -- ab  
                     
            end loop;
     END LOOP; --> COMPANY DIVISION       
     lv_sql := lv_sql||' SELECT * FROM VIEWTAB_GPSCATEGORYMAST ';  
ELSIF lv_table = 'GPSOCCUPATIONMAST' then
   /*  select count(distinct OCCUPATIONCODE)  into lv_totcat FROM GPSOCCUPATIONMAST
                WHERE COMPANYCODE=P_COMPANYCODE
                AND DIVISIONCODE=P_DIVISIONCODE                
                AND OCCUPATIONCODE IS NOT NULL;    
                lv_catrow := 0;
    for c2 in ( select distinct OCCUPATIONCODE FROM GPSOCCUPATIONMAST
                WHERE COMPANYCODE=P_COMPANYCODE
                AND DIVISIONCODE=P_DIVISIONCODE                
                AND OCCUPATIONCODE IS NOT NULL    ) loop  
                lv_catparams_cols := '';    
                lv_catrow := lv_catrow + 1;
                select count(distinct PARAM_NAME) into lv_tot_param_COL 
                FROM SYS_SWT_TABLE_PARAMMAST
                            WHERE COMPANYCODE=P_COMPANYCODE
                            AND DIVISIONCODE=P_DIVISIONCODE
                            AND REF_TABLE_NAME = LV_REF_TABLE_NAME;             
                lv_param_row := 0;
                for c1 in(
                            SELECT PARAM_NAME,  REPLACE(PARAM_NAME,CHR(32)) AS VIEW_COL,LENGTH(REPLACE(PARAM_NAME,CHR(32)))  LEN,OBJECT_TYPE DATA_TYPE,DATA_TYPE WIDTH FROM SYS_SWT_TABLE_PARAMMAST
                            WHERE COMPANYCODE=P_COMPANYCODE
                            AND DIVISIONCODE=P_DIVISIONCODE
                            AND REF_TABLE_NAME = LV_REF_TABLE_NAME
                             ) loop
                           lv_param_row := lv_param_row+1;  
                           BEGIN  
                            select NVL(param_value,'NULL') into lv_VIEW_COL_VAL from SYS_SWT_PARAMDETAILS where param_id = c2.OCCUPATIONCODE and PARAM_NAME = c1.param_name ;
                           EXCEPTION 
                            WHEN OTHERS THEN
                              lv_VIEW_COL_VAL := 'NULL';
                           END;  
                           select decode(lv_param_row, lv_tot_param_COL,' ',',' )  into lv_endstr from dual;
                           if lv_VIEW_COL_VAL = 'NULL' then
                            if c1.DATA_TYPE = 'VARCHAR2' then
                             lv_catparams_cols := lv_catparams_cols||' '' ''  AS '||c1.VIEW_COL||lv_endstr ;
                            else
                             lv_catparams_cols := lv_catparams_cols||' 0  AS '||c1.VIEW_COL||lv_endstr ;
                            end if;        
                           else  
                             if c1.DATA_TYPE = 'VARCHAR2' then       
                              lv_catparams_cols := lv_catparams_cols||' '''||lv_VIEW_COL_VAL||'''  AS '||c1.VIEW_COL||lv_endstr ;
                             else
                              lv_catparams_cols := lv_catparams_cols||' '||lv_VIEW_COL_VAL||'  AS '||c1.VIEW_COL||lv_endstr ;
                             end if; 
                           end if  ;                       
                  end loop;
    --              lv_end_sql := ' from '||lv_table||' where companycode = '''||P_COMPANYCODE||''' and divisioncode = '''||P_DIVISIONCODE||''' and categorycode = '''||c2.categorycode||'''' ;
                  lv_end_sql := ' FROM '||lv_table||' WHERE COMPANYCODE = '''||P_COMPANYCODE||''' AND DIVISIONCODE = '''||P_DIVISIONCODE||''' AND '||P_REF_KEY_COL1||' = '''||c2.OCCUPATIONCODE||'''' ;            
                  if lv_catrow <  lv_totcat then
                   --dbms_output.put_line(lv_CATMASTCOLS||' '||lv_catparams_cols||lv_end_sql||chr(10)||' UNION ALL ');
                   lv_sql := lv_sql||lv_CATMASTCOLS||' '||lv_catparams_cols||lv_end_sql||chr(10)||' UNION ALL ' ;
                  else
                   --dbms_output.put_line(lv_CATMASTCOLS||' '||lv_catparams_cols||lv_end_sql);
                   lv_sql := lv_sql||lv_CATMASTCOLS||' '||lv_catparams_cols||lv_end_sql ;
                  end if;
        ----DBMS_OUTPUT.PUT_LINE (lv_sql ||' LENGTH '||LENGtH(lv_sql));                  
    end loop;*/
    ---- insert new style of occupationmast view creation query --
   select count(distinct OCCUPATIONCODE)  into lv_totcat FROM GPSOCCUPATIONMAST
                WHERE 1=1
               -- AND COMPANYCODE=P_COMPANYCODE
               -- AND DIVISIONCODE=P_DIVISIONCODE                
                AND OCCUPATIONCODE IS NOT NULL;    
                lv_catrow := 0;
    for c2 in ( select distinct COMPANYCODE,DIVISIONCODE,OCCUPATIONCODE FROM GPSOCCUPATIONMAST
                WHERE 1=1 
                --AND COMPANYCODE=P_COMPANYCODE
                --AND DIVISIONCODE=P_DIVISIONCODE                
                AND OCCUPATIONCODE IS NOT NULL    ) loop  
               -- lv_catparams_cols := ''; 
                lv_catparams_cols_with_null := '';   
                lv_catparams_cols_list := '';
                lv_catrow := lv_catrow + 1;
                select count(distinct PARAM_NAME) into lv_tot_param_COL 
                FROM SYS_SWT_TABLE_PARAMMAST
                            WHERE 1=1
                          --  AND COMPANYCODE=c2.COMPANYCODE --P_COMPANYCODE
                          --  AND DIVISIONCODE=c2.DIVISIONCODE --P_DIVISIONCODE
                            AND REF_TABLE_NAME = LV_REF_TABLE_NAME;             
                lv_param_row := 0;
                for c1 in(
                            SELECT DISTINCT PARAM_NAME,  REPLACE(PARAM_NAME,CHR(32)) AS VIEW_COL,LENGTH(REPLACE(PARAM_NAME,CHR(32)))  LEN,OBJECT_TYPE DATA_TYPE,DATA_TYPE WIDTH FROM SYS_SWT_TABLE_PARAMMAST
                            WHERE 1=1 
                           -- AND COMPANYCODE=c2.COMPANYCODE --P_COMPANYCODE
                           -- AND DIVISIONCODE=c2.DIVISIONCODE --P_DIVISIONCODE
                            AND REF_TABLE_NAME = LV_REF_TABLE_NAME
                             ) loop
                           lv_param_row := lv_param_row+1;  
                           BEGIN  
                           -- select NVL(param_value,'NULL') into lv_VIEW_COL_VAL from SYS_SWT_PARAMDETAILS where param_id = c2.OCCUPATIONCODE and PARAM_NAME = c1.param_name ;
                             select NVL(param_value,'NULL') into lv_VIEW_COL_VAL from SYS_SWT_PARAMDETAILS where COMPANYCODE=c2.COMPANYCODE and DIVISIONCODE=c2.DIVISIONCODE and param_id = c2.OCCUPATIONCODE and PARAM_NAME = c1.param_name 
                            AND EFFECTIVEDATE = ( SELECT MAX(EFFECTIVEDATE) FROM 
                                                  SYS_SWT_PARAMDETAILS WHERE  COMPANYCODE=c2.COMPANYCODE and DIVISIONCODE=c2.DIVISIONCODE and REF_TABLE_NAME = LV_REF_TABLE_NAME
                                                  AND PARAM_NAME = c1.param_name /*AND PARAM_VALUE > 0*/  AND PARAM_ID = c2.OCCUPATIONCODE) ;
                            /*and PARAM_VALUE > 0 */
                           EXCEPTION 
                            WHEN OTHERS THEN
                              lv_VIEW_COL_VAL := 'NULL';
                           END;  
                           select decode(lv_param_row, lv_tot_param_COL,' ',',' )  into lv_endstr from dual;
                           if lv_VIEW_COL_VAL = 'NULL' then
                            if c1.DATA_TYPE = 'VARCHAR2' then
                             lv_catparams_cols_list := lv_catparams_cols_list||c1.VIEW_COL||lv_endstr;
                            -- lv_catparams_cols := lv_catparams_cols||''''||RPAD(CHR(32),c1.WIDTH,CHR(32)) ||'''  AS '||c1.VIEW_COL||lv_endstr ;                             
                             lv_catparams_cols_with_null := lv_catparams_cols_with_null||'  CAST( RPAD(CHR(32),'||c1.WIDTH||',CHR(32)) AS VARCHAR2('||c1.WIDTH||') )   AS '||c1.VIEW_COL||lv_endstr ;
                            else
                             lv_catparams_cols_list := lv_catparams_cols_list||c1.VIEW_COL||lv_endstr; 
                          --   lv_catparams_cols := lv_catparams_cols||' 0  AS '||c1.VIEW_COL||lv_endstr ;
                             lv_catparams_cols_with_null := lv_catparams_cols_with_null||' TO_NUMBER(NULL)  AS '||c1.VIEW_COL||lv_endstr ;
                            end if;        
                           else  
                             if c1.DATA_TYPE = 'VARCHAR2' then   
                              lv_catparams_cols_list := lv_catparams_cols_list||c1.VIEW_COL||lv_endstr;    
                           --   lv_catparams_cols := lv_catparams_cols||' '''||TRIM(lv_VIEW_COL_VAL)||'''  AS '||c1.VIEW_COL||lv_endstr ;
                              lv_catparams_cols_with_null := lv_catparams_cols_with_null||' '''||TRIM(lv_VIEW_COL_VAL)||'''  AS '||c1.VIEW_COL||lv_endstr ;
                             else
                              lv_catparams_cols_list := lv_catparams_cols_list||c1.VIEW_COL||lv_endstr;
                           --   lv_catparams_cols := lv_catparams_cols||' '||lv_VIEW_COL_VAL||'  AS '||c1.VIEW_COL||lv_endstr ;
                              lv_catparams_cols_with_null := lv_catparams_cols_with_null||' '||lv_VIEW_COL_VAL||'  AS '||c1.VIEW_COL||lv_endstr ;
                             end if; 
                           end if  ;                       
                  end loop;
    --              lv_end_sql := ' from '||lv_table||' where companycode = '''||P_COMPANYCODE||''' and divisioncode = '''||P_DIVISIONCODE||''' and categorycode = '''||c2.categorycode||'''' ;
                  lv_end_sql := ' FROM '||lv_table||' WHERE COMPANYCODE = '''||c2.COMPANYCODE||''' AND DIVISIONCODE = '''||c2.DIVISIONCODE||''' AND '||P_REF_KEY_COL1||' = '''||c2.OCCUPATIONCODE||'''' ;            
               /*   if lv_catrow <  lv_totcat then
                   --dbms_output.put_line(lv_CATMASTCOLS||' '||lv_catparams_cols||lv_end_sql||chr(10)||' UNION ALL ');
                   lv_sql := lv_sql||lv_CATMASTCOLS||' '||lv_catparams_cols||lv_end_sql||chr(10)||' UNION ALL ' ;
                  else
                   --dbms_output.put_line(lv_CATMASTCOLS||' '||lv_catparams_cols||lv_end_sql);
                   lv_sql := lv_sql||lv_CATMASTCOLS||' '||lv_catparams_cols||lv_end_sql ;
                  end if; */
       -- --DBMS_OUTPUT.PUT_LINE (lv_sql ||' LENGTH '||LENGtH(lv_sql));  
      if lv_tot_param_COL > 0 then    -- ab   
         if lv_catrow =1 then           
           lv_sql_create := 'drop table VIEWTAB_GPSOCCUPATIONMAST ';
           BEGIN
            execute immediate lv_sql_create ;
           EXCEPTION
            WHEN OTHERS THEN
             NULL;
           END;         
         
         --lv_sql_create := 'create table VIEWTAB_GPSOCCUPATIONMAST as '||lv_CATMASTCOLS||' '||lv_catparams_cols||lv_end_sql ;
         --dbms_output.put_line(lv_sql_create);
         
         --execute immediate lv_sql_create ; 
         --delete VIEWTAB_GPSOCCUPATIONMAST;
         --commit;
         p_create_blank_view_table( 'VIEWTAB_GPSOCCUPATIONMAST', 'GPSOCCUPATIONMAST' );
         lv_sql_create := 'insert into VIEWTAB_GPSOCCUPATIONMAST('||substr( lv_CATMASTCOLS,7)||' '||lv_catparams_cols_list||') '||lv_CATMASTCOLS||' '||lv_catparams_cols_with_null||lv_end_sql ; 
         execute immediate lv_sql_create ;
         --  p_create_blank_view_table( 'VIEWTAB_GPSOCCUPATIONMAST', 'GPSOCCUPATIONMAST' ); -- currently commented due to  mismatch in insert colist and select collist
          -- dbms_output.put_line('CREATE '||lv_sql_create);       
          -- exit; -- create table xxxx as lv_sql
         else           
           --lv_sql_create := 'insert into VIEWTAB_GPSOCCUPATIONMAST '||lv_CATMASTCOLS||' '||lv_catparams_cols||lv_end_sql ;
           lv_sql_create := 'insert into VIEWTAB_GPSOCCUPATIONMAST('||substr( lv_CATMASTCOLS,7)||' '||lv_catparams_cols_list||') '||lv_CATMASTCOLS||' '||lv_catparams_cols_with_null||lv_end_sql ;
          -- dbms_output.put_line('INSERT '||lv_sql_create);
            execute immediate lv_sql_create ;
         end if;   
      end if;    -- ab            
    end loop;
    lv_sql := lv_sql||' SELECT * FROM VIEWTAB_GPSOCCUPATIONMAST ';   
   -- end insert occupationmast view creation query --
end if;
insert into GPS_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY) values( P_COMPANYCODE, P_DIVISIONCODE, 'PROC_GPSCATEGORYMASTVIEW',NULL,lv_Sql);
COMMIT;
--dbms_output.put_line(' XXX '||lv_sql);
execute immediate lv_sql ;
exception
when others then
 lv_sqlerrm := sqlerrm ;
 insert into GPS_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY) values( P_COMPANYCODE, P_DIVISIONCODE, 'PROC_GPSCATEGORYMASTVIEW',lv_sqlerrm,lv_Sql);
 --dbms_output.put_line(sqlerrm ||lv_sql);
end;
/


