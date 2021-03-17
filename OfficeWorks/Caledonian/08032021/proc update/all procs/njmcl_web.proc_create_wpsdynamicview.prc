DROP PROCEDURE NJMCL_WEB.PROC_CREATE_WPSDYNAMICVIEW;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_CREATE_WPSDYNAMICVIEW
(
P_COMPANYCODE    VARCHAR2,  --NJ0001
P_DIVISIONCODE   VARCHAR2,  --0002
P_REF_TABLE_NAME VARCHAR2, --WPSOCCUPATIONMAST
P_REF_KEY_COL1   VARCHAR2 DEFAULT NULL  -- DEPARTMENTCODE||SECTIONCODE||OCCUPATIONCODE
)
as
LV_COMPANYCODE         VARCHAR2(10 BYTE) := LTRIM(TRIM(P_COMPANYCODE)) ;   
LV_DIVISIONCODE        VARCHAR2(10 BYTE) := LTRIM(TRIM(P_DIVISIONCODE)) ;
LV_REF_TABLE_NAME      VARCHAR2(30)      := LTRIM(TRIM(P_REF_TABLE_NAME)) ;
--LV_YEARCODE            VARCHAR2(10 BYTE) := LTRIM(TRIM(P_YEARCODE)) ;
lv_CATMASTCOLS varchar2(10000) := 'SELECT ';
lv_REF_KEY_COL1 varchar2(2000);
lv_totcat_cols varchar2(2000) ;
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
lv_sqlstr     varchar2(4000) ;
lv_comp_div_cnt int := 0;
lv_tot_comp_div_cnt int;
----------  START SUB ROUTINE ------
--------------------------------------
procedure p_create_blank_view_table( p_view_tab varchar2 DEFAULT 'VIEWTAB_WPSWORKERCATEGORYMAST', p_ref_tablename varchar2 DEFAULT 'WPSWORKERCATEGORYMAST' )
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
if P_REF_KEY_COL1 is null then 
 select distinct 'COMPANYCODE,DIVISIONCODE,'||replace(KEY_COLUMN,'~',',') , replace(KEY_COLUMN,'~',',') into lv_totcat_cols, lv_REF_KEY_COL1 from SYS_SWT_TABLE_PARAMMAST where  REF_TABLE_NAME = LV_REF_TABLE_NAME ;
else
 lv_REF_KEY_COL1 := ltrim(trim(upper(P_REF_KEY_COL1)));
end if; 

 DELETE GTT_WPSDYNAMICVIEW ;
 COMMIT;
 
 lv_sqlstr := 'select count(distinct '||replace(lv_totcat_cols,',','||')||' ) from '||LV_REF_TABLE_NAME||chr(10)
              ||' where 1=1 '||chr(10)
              ||' and '||replace(lv_REF_KEY_COL1,',',' is not null and ')||' is not null ' ;
 --dbms_output.put_line( lv_sqlstr );
 execute immediate  lv_sqlstr into lv_totcat;
 
 lv_sqlstr := 'insert into GTT_WPSDYNAMICVIEW(COMPANYCODE, DIVISIONCODE, REF_KEY_COL_CONCAT)  '||chr(10)
              ||'select distinct companycode,divisioncode,'||replace(lv_REF_KEY_COL1,',','||')||' OCCUPATIONCODE  from '||LV_REF_TABLE_NAME||chr(10)
              ||' where 1=1 '||chr(10)
              ||' and '||replace(lv_REF_KEY_COL1,',',' is not null and ')||' is not null ' ;
 
-- dbms_output.put_line( lv_sqlstr );
 execute immediate  lv_sqlstr ; 
         
                lv_catrow := 0;
    for c2 in (  select COMPANYCODE,DIVISIONCODE , REF_KEY_COL_CONCAT OCCUPATIONCODE from GTT_WPSDYNAMICVIEW   -- to be changed to GTT_WPSDYNAMICVIEW  after on commit preserve rows
                 ) loop   
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
                            AND REF_TABLE_NAME = LV_REF_TABLE_NAME
                            AND NVL(EFFECTIVEDATE,to_date('01/01/1900','DD/MM/YYYY')  ) = ( SELECT NVL(MAX(EFFECTIVEDATE),to_date('01/01/1900','DD/MM/YYYY') ) FROM 
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
                  lv_end_sql := ' FROM '||lv_table||' WHERE COMPANYCODE = '''||c2.COMPANYCODE||''' AND DIVISIONCODE = '''||c2.DIVISIONCODE||''' AND '||replace(lv_REF_KEY_COL1,',','||')||' = '''||c2.OCCUPATIONCODE||'''' ;            
      if lv_tot_param_COL > 0 then    -- ab   
         if lv_catrow =1 then           
           lv_sql_create := 'drop table VIEWTAB_'||LV_REF_TABLE_NAME;
           BEGIN
            execute immediate lv_sql_create ;
           EXCEPTION
            WHEN OTHERS THEN
             NULL;
           END;
         p_create_blank_view_table( 'VIEWTAB_'||LV_REF_TABLE_NAME, LV_REF_TABLE_NAME );
         lv_sql_create := 'insert into VIEWTAB_'||LV_REF_TABLE_NAME||'('||substr( lv_CATMASTCOLS,7)||' '||lv_catparams_cols_list||') '||lv_CATMASTCOLS||' '||lv_catparams_cols_with_null||lv_end_sql ; 
   
         execute immediate lv_sql_create ;
        
         else           
           --lv_sql_create := 'insert into VIEWTAB_GPSOCCUPATIONMAST '||lv_CATMASTCOLS||' '||lv_catparams_cols||lv_end_sql ;
           lv_sql_create := 'insert into VIEWTAB_'||LV_REF_TABLE_NAME||'('||substr( lv_CATMASTCOLS,7)||' '||lv_catparams_cols_list||') '||lv_CATMASTCOLS||' '||lv_catparams_cols_with_null||lv_end_sql ;
           --dbms_output.put_line('INSERT '||lv_sql_create);
            execute immediate lv_sql_create ;
         end if;   
      end if;    -- ab             
    end loop;
    lv_sql := lv_sql||' SELECT * FROM VIEWTAB_'||LV_REF_TABLE_NAME; 
   -- end insert occupationmast view creation query --
insert into WPS_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY) values( P_COMPANYCODE, P_DIVISIONCODE, 'PROC_CREATE_WPSDYNAMICVIEW',NULL,lv_Sql);
COMMIT;
--dbms_output.put_line(' XXX '||lv_sql);
execute immediate lv_sql ;
exception
when others then
 lv_sqlerrm := sqlerrm ;
 insert into WPS_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY) values( P_COMPANYCODE, P_DIVISIONCODE, 'PROC_CREATE_WPSDYNAMICVIEW',lv_sqlerrm,lv_Sql);
 commit;
 --dbms_output.put_line(sqlerrm ||lv_sql); 
end;
/


