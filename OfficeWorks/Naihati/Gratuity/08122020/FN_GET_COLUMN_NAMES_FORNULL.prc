CREATE OR REPLACE FUNCTION NJMCL_WEB."FN_GET_COLUMN_NAMES_FORNULL" (p_table_name varchar2) 
return CLOB as
-- Input : Name of a Table 
-- This Function will return the Key Column Names (as per Global Temporary) separated by 
-- comma (')  

lv_sqlstr varchar2(5000);
lv_cnt number(2) := 0;
lv_err_string varchar2(5000);
lv_exception EXCEPTION ;
lv_err_number   number(6) :=0;
begin
    select count(*)
    into lv_cnt
    from tab where tname = upper(p_table_name);
    if lv_cnt = 0 then
        lv_err_string := 'Error Number : -20001 Description : Invalid Table [' || p_table_name || '] Name send in Function : fn_get_column_names';
       -- lv_err_number := -20001 ;
        RAISE  lv_exception;
       -- raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_err_string));
    end if;       
    if lv_err_number = 0 then
        lv_sqlstr := '';
        for c1 in (select SYS_COLUMNNAME,SYS_COLUMN_SEQUENCE,SYS_DATATYPE, SYS_DEFAULT from sys_tfmap where SYS_TABLENAME_TEMP = upper(p_table_name) and nvl(SYS_TABLENAME_ACTUAL,'N')<>'NONE' order by SYS_COLUMN_SEQUENCE) loop
            if nvl(lv_sqlstr,'~X~') = '~X~' then
                if c1.SYS_DATATYPE='DATE' then 
                    IF NVL(c1.SYS_DEFAULT,'~X~') <> '~X~' THEN 
                        lv_sqlstr := 'nvl('||c1.SYS_COLUMNNAME||',sysdate)';
                    else
                        lv_sqlstr := 'nvl('||c1.SYS_COLUMNNAME||',to_date(''31/01/1000'',''dd/mm/yyyy''))';
                    end if;
                elsif c1.SYS_DATATYPE='VARCHAR2' then
                    lv_sqlstr := 'nvl('||c1.SYS_COLUMNNAME||',''~QQ~'')';
                elsif c1.SYS_DATATYPE='NUMBER'  then
                    lv_sqlstr := 'nvl('||c1.SYS_COLUMNNAME||',0)';
                end if;                
            else
                if c1.SYS_DATATYPE='DATE' then
                    IF NVL(c1.SYS_DEFAULT,'~X~') <> '~X~' THEN 
                        lv_sqlstr :=  lv_sqlstr || ',' || 'nvl('||c1.SYS_COLUMNNAME||',sysdate)';
                    else
                        lv_sqlstr :=  lv_sqlstr || ',' || 'nvl('||c1.SYS_COLUMNNAME||',to_date(''31/01/1000'',''dd/mm/yyyy''))';
                    end if;                 
                elsif c1.SYS_DATATYPE='VARCHAR2' then
                    lv_sqlstr := lv_sqlstr || ',' ||  'nvl('||c1.SYS_COLUMNNAME||',''~QQ~'')';
                elsif c1.SYS_DATATYPE='NUMBER' then
                    lv_sqlstr :=  lv_sqlstr || ',' || 'nvl('||c1.SYS_COLUMNNAME||',0)';
                end if;                           
            end if;   
        end loop;
        return lv_sqlstr; 
    else
        return null;
    end if;
    exception
    when others then
     lv_err_string := lv_err_string||' : '||ltrim(trim(sqlerrm)) ;
     raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_err_string));
   --   raise_application_error(lv_err_number, lv_err_string);
end;
/
