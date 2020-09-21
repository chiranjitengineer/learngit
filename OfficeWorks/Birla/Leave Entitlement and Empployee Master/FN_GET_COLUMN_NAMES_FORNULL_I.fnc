CREATE OR REPLACE function BIRLANEW.fn_get_column_names_FORNULL_I(p_table_name varchar2 ) 
return char as
-- Input : Name of a Table 
-- This Function will return the Key Column Names (as per Global Temporary) separated by 
-- comma (')  

lv_sqlstr varchar2(8000);
lv_cnt number(2) := 0;
lv_err_string varchar2(8000);
lv_exception EXCEPTION ;
lv_err_number   number(6) :=0;
begin
    select count(*)
    into lv_cnt
    from tab where tname = upper(p_table_name);
    if lv_cnt = 0 then
        lv_err_string := 'Error Number : -20001 Description : Invalid Table [' || p_table_name || '] Name send in Function : fn_get_column_names';
        RAISE  lv_exception;
       -- lv_err_number := -20001 ;
    end if;       
    if lv_err_number = 0 then
        lv_sqlstr := '';
        for c1 in (select SYS_COLUMNNAME,SYS_COLUMN_SEQUENCE,SYS_DATATYPE from sys_tfmap where SYS_TABLENAME_TEMP = upper(p_table_name) and nvl(SYS_TABLENAME_ACTUAL,'N')<>'NONE' order by SYS_COLUMN_SEQUENCE) loop
            if nvl(lv_sqlstr,'~X~') = '~X~' then
                if c1.SYS_DATATYPE='DATE' then 
                lv_sqlstr := 'nvl('||c1.SYS_COLUMNNAME||',NULL)  '||c1.SYS_COLUMNNAME||'  ';
                elsif c1.SYS_DATATYPE='VARCHAR2' then
                lv_sqlstr := 'nvl('||c1.SYS_COLUMNNAME||',''~QQ~'') '||c1.SYS_COLUMNNAME||'  ';
                elsif c1.SYS_DATATYPE='NUMBER'  then
                 lv_sqlstr := 'nvl('||c1.SYS_COLUMNNAME||',0)   '||c1.SYS_COLUMNNAME||' ';
                end if;
                
            else
                 if c1.SYS_DATATYPE='DATE' then
                lv_sqlstr :=  lv_sqlstr || ',' || 'nvl('||c1.SYS_COLUMNNAME||',NULL) '||c1.SYS_COLUMNNAME||' ';
                elsif c1.SYS_DATATYPE='VARCHAR2' then
                lv_sqlstr := lv_sqlstr || ',' ||  'nvl('||c1.SYS_COLUMNNAME||',''~QQ~'') '||c1.SYS_COLUMNNAME||' ';
                elsif c1.SYS_DATATYPE='NUMBER' then
                 lv_sqlstr :=  lv_sqlstr || ',' || 'nvl('||c1.SYS_COLUMNNAME||',0) '||c1.SYS_COLUMNNAME||' ';
                end if;
            
               
            end if;   
        end loop;
        return lv_sqlstr ; 
    else
        return null;
    end if;
    exception
    when others then
      lv_err_string := lv_err_string||' : '||ltrim(trim(sqlerrm)) ;
      raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_err_string));
      --raise_application_error(lv_err_number, lv_err_string);
end;
/
