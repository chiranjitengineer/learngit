DROP PROCEDURE NJMCL_WEB.PROC_SD_WPSDEPARTMENTTYPEMAST;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PROC_SD_WPSDEPARTMENTTYPEMAST" (p_Operation char)
as

lv_int_validated    number(1)  := 0;
lv_str_validated    varchar2(4000) := '';

lv_str_insert_qry   varchar2(4000) := '';

begin

-- Validation Part
    lv_str_validated := 'SORRY ANGSHUMAN .... NOT VALIDATED INPUT....';
    lv_int_validated := 1;
    if lv_int_validated = 1 then         
        if upper(p_Operation) = 'A' then
    -- Saving Part - Inserting 
            dbms_output.put_line(fn_get_mapped_column_names('GBL_TMP_WPSDEPARTMENTTYPEMAST1'));
            lv_str_insert_qry := 'insert into wpsdepartmenttypemast (' || fn_get_mapped_column_names('GBL_TMP_WPSDEPARTMENTTYPEMAST1') || ')' ||  ' select ' || fn_get_mapped_column_names('GBL_TMP_WPSDEPARTMENTTYPEMAST1') || ' from GBL_TMP_WPSDEPARTMENTTYPEMAST1'  ;    
            dbms_output.put_line(lv_str_insert_qry);
            execute immediate lv_str_insert_qry;
            null;   
        elsif upper(p_Operation) = 'M' then
            null;

        elsif upper(p_Operation) = 'D' then
            null;
        
        end if;
    -- Delete Part
    
    else
        raise_application_error(-20010, lv_str_validated);
    end if;

end;
/


