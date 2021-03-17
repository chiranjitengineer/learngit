DROP PROCEDURE NJMCL_WEB.PRC_CREATE_DYNAMIC_VIEW_WPS_O;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.prc_create_dynamic_view_wps_O
(
    p_compcode   varchar2, 
    p_divcode    varchar2,
    p_impexptype varchar2, 
    p_impexpqry  varchar2,
    p_yearmonth  varchar2,
    p_readonly   varchar2 default null
)
as
lv_SqlStr       varchar2(30000) := '';
lv_temp_table   varchar2(30) := 'GBL_TBL_G_DYNAMIC';
lv_tabexists    number;
lv_result       varchar2(10);
lv_error_remark varchar2(4000) := '';
lv_readonly     varchar2(10);
lv_componentCriteria varchar2(200) := '';
begin
    lv_result:='#SUCCESS#';
    
    if p_readonly is null then
        lv_readonly := 'true';
    else
        lv_readonly := p_readonly;
    end if;
    
    if p_impexptype is not null then
        if p_impexptype = 'WORKERRATE' then
            lv_componentCriteria := 'MASTERCOMPONENT=''Y''';
        end if;
        if p_impexptype = 'ATTENDANCEADJUSTMENT' then
            lv_componentCriteria := 'AMOUNTORFORMULA=''AMOUNT''';
        end if;
    end if;
    
    ----- Checking for Global Table Exists or not and recreate table
    select count(*) into lv_tabexists from user_tables where table_name = UPPER(lv_temp_table) ;
    if lv_tabexists > 0 then
        lv_sqlstr := 'DROP TABLE ' || lv_temp_table ;
        execute immediate lv_sqlstr ;
    end if;
    
    lv_SqlStr := 'CREATE GLOBAL TEMPORARY TABLE ' || lv_temp_table || CHR(10)
               ||'AS ' || CHR(10) || p_impexpqry;
    --DBMS_OUTPUT.PUT_LINE(lv_SqlStr);
    execute immediate lv_SqlStr;
    ----- Checking for Global Table Exists or not and recreate table
    
    ----- for Dynamic View for variable column as per Global Table
    lv_SqlStr := 'create or replace force view vw_auto_dynamicgrid'|| chr(10);
    lv_SqlStr := lv_SqlStr || '('|| chr(10);
    lv_SqlStr := lv_SqlStr || '   companycode,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   column_name,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   column_header,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   column_length,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   column_data,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   qry_header'|| chr(10);
    lv_SqlStr := lv_SqlStr || ')'|| chr(10);
    lv_SqlStr := lv_SqlStr || 'as'|| chr(10);
    lv_SqlStr := lv_SqlStr || 'select  '''||p_compcode||''' companycode,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ('|| chr(10);
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.column_name || '','')order by x.serialno).extract (''//text()''),'','') column_name'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select ''^'' ||cname||''^'' column_name, colno serialno from col'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x) column_name,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ('|| chr(10);
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.column_header || '','')order by x.serialno).extract (''//text()''),'','') column_header'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select initcap(cname) column_header, colno serialno from col'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x) column_header,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ('|| chr(10);          
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.column_length || '','')order by x.serialno).extract (''//text()''),'','') column_length'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select case when upper(cname) in (''COMPANYCODE'',''DIVISIONCODE'',''YEARCODE'',''SERIALNO'',''USERNAME'',''SYSROWID'',''LASTMODIFIED'',''WORKERSERIAL'',''UNITCODE'',''YEARMONTH'',''GRADECODE'',''TOTALDAYS'',''CALCULATIONDAYS'',''ADJUSTMENTDAYS'', ''DEPARTMENTDESC'', ''SPELLTYPE'',''ATTENDANCETAG'',''SHIFTCODE'',''DATEOFATTENDANCE'',''BOOKNO'',''FORTNIGHTSTARTDATE'',''FORTNIGHTENDDATE'') then 1 else'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                        decode(coltype,''VARCHAR2'',120,''DATE'',100,''NUMBER'',70,''CHAR'',50,1) end column_length, colno serialno from col '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x) column_length,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ''[''||('|| chr(10);         
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.column_data || '','')order by x.serialno).extract (''//text()''),'','') column_data'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select trim(''{ data: ^''||cname|| ''^, type: $''||'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                             decode(coltype,''VARCHAR2'',''text'',''NUMBER'',''numeric$,format:$0.00'',''text'')|| ''$''||'|| chr(10);    
    lv_SqlStr := lv_SqlStr || '                             case when cname in (select substr(columnname,instr(columnname,''.'')+1) from wpstagwisefixedcolumnshow where companycode='''||p_compcode||''' and divisioncode='''||p_divcode||''' and tagtype='''||p_impexptype||''' and cname not like ''ATTENDANCEHOURS'' and cname not like ''OVERTIMEHOURS'' and cname not like ''TOKENNO'') then '', readOnly: true, nedit'' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                                  when cname in (select substr(columnname,instr(columnname,''.'')+1) from wpstagwisefixedcolumnshow where companycode='''||p_compcode||''' and divisioncode='''||p_divcode||''' and tagtype='''||p_impexptype||''' and (cname like ''ATTENDANCEHOURS'' or cname like ''OVERTIMEHOURS'' or cname like ''TOKENNO'')) then '', readOnly: false'' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                                  when cname in (select componentshortname from wpscomponentmaster where companycode='''||p_compcode||''' and divisioncode='''||p_divcode||''' and '||lv_componentCriteria||') then '', readOnly: '||lv_readonly||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                                  when instr((select columnname from wpstagwisefixedcolumnshow where companycode='''||p_compcode||''' and divisioncode='''||p_divcode||''' and tagtype='''||p_impexptype||''' and columnname like ''%,%'' and rownum=1),cname)>0 then '', readOnly: '||lv_readonly||''' else '', readOnly: true, nedit'' end ||'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                             '' }'') column_data, colno serialno from col'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x)||'']'' column_data,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ('|| chr(10);          
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.qry_header || '','')order by x.serialno).extract (''//text()''),'','') qry_header'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select case when coltype=''DATE'' then ''TO_CHAR(''||cname||'',$DD/MM/YYYY$) ''||cname else cname end qry_header, colno serialno from col'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x) qry_header'|| chr(10);
    lv_SqlStr := lv_SqlStr || ' from dual';
    --DBMS_OUTPUT.PUT_LINE(lv_SqlStr);
    execute immediate lv_SqlStr;
    
    -- for Dynamic View for variable column as per Global Table
    
exception
when others then
    lv_error_remark := sqlerrm;
    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    --dbms_output.put_line(sqlerrm);
end;
/


