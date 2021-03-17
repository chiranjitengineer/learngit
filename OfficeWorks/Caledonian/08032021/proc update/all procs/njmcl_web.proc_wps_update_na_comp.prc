DROP PROCEDURE NJMCL_WEB.PROC_WPS_UPDATE_NA_COMP;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PROC_WPS_UPDATE_NA_COMP" ( P_COMPCODE VARCHAR2, P_DIVCODE VARCHAR2,p_fnstdt VARCHAR2, p_fnendt varchar, p_phase_table varchar2 , p_process_table varchar2, p_UpdateDummytable varchar2)
as
lv_updsql varchar2(32767);
lv_tab varchar2(30) := ltrim(trim(upper(p_phase_table)));
-- declare  -- for view creration from outside 
lv_colstr varchar2(32767);
lv_sqlstr varchar2(32767) :=  'CREATE OR REPLACE FORCE VIEW vw_category_comp_NA as  '||chr(10) ;
lv_fn_stdt date := to_date(p_fnstdt,'dd/mm/yyyy');
lv_fn_endt date := to_date(p_fnendt,'dd/mm/yyyy');
lv_sqlerrm varchar(2000);
lv_ProcName     varchar2(30) := 'PROC_WPS_UPDATE_NA_COMP';
begin
--------------------- view creation -------------
/*for v1 in(
select column_name cn from cols where table_name = 'WPSWORKERCATEGORYVSCOMPONENT' 
and column_name not in( 'COMPANYCODE','DIVISIONCODE'  , 'EFFECTIVEDATE', 'WORKERCATEGORYCODE' , 'LASTMODIFIED' ) ) loop
lv_sqlstr := lv_sqlstr||' select  workercategorycode , '''||v1.cn||''' COMPONENTSHORTNAME from WPSWORKERCATEGORYVSCOMPONENT  '||chr(10)
             ||' where   '||v1.cn||' = ''N'' '||chr(10) 
             ||' UNION ALL '||chr(10) ;
end loop;
lv_sqlstr := lv_sqlstr||' select  ''XX'' ,''XX'' from dual where 1=2  '||chr(10) ;
*/
--CREATE OR REPLACE VIEW vw_category_comp_NA as  
    lv_sqlstr := lv_sqlstr||' SELECT A.WORKERCATEGORYCODE, B.COMPONENTSHORTNAME '||CHR(10) 
                          ||' FROM WPSWORKERCATEGORYVSCOMPONENT A, WPSCOMPONENTMASTER B '||CHR(10)
                          ||' WHERE A.COMPONENTCODE = B.COMPONENTCODE '||CHR(10)
                          ||'   AND A.EFFECTIVEDATE = ( '||CHR(10)
                          ||'                            SELECT MAX(EFFECTIVEDATE)  '||CHR(10)
                          ||'                            FROM WPSWORKERCATEGORYVSCOMPONENT  '||CHR(10)
                          ||'                          ) '||CHR(10)
                          ||'  AND NVL(APPLICABLE,''N'') LIKE ''N%''   '||CHR(10);
execute immediate lv_sqlstr;
-- end ; -- end for view creration from outside
----------------------------------------- end view creation -----------
for c1 in( select distinct WORKERCATEGORYCODE cat from vw_category_comp_NA   ) loop
lv_updsql := 'UPDATE '||lv_tab||' SET ' ;
for c2 in(select column_name cn from cols where table_name = lv_tab
intersect
select COMPONENTSHORTNAME cn from vw_category_comp_NA where WORKERCATEGORYCODE = c1.cat
) loop
lv_updsql := lv_updsql||c2.cn||' = 0 , ' ;
end loop ; -- c2
lv_updsql := lv_updsql||' WORKERCATEGORYCODE=WORKERCATEGORYCODE where WORKERCATEGORYCODE = '''||c1.cat||'''';
--dbms_output.put_line(lv_updsql);
--insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) values( 'proc_wps_update_NA_comp',lv_updsql,lv_updsql,'','');
--COMMIT;
execute immediate lv_updsql ;
end loop ; -- c1
--RETURN;
---------------------  update dummy
if p_UpdateDummytable = 'YES' THEN 
    for u1 in(
    (
    select column_name cn from cols where table_name = p_phase_table and column_name not in(  'WORKTYPECODE' ,'TOKENNO', 'WORKERCATEGORYCODE', 'WORKERSERIAL','DEPARTMENTCODE')
    intersect 
    /*
    select column_name cn from cols where table_name = 'WPSWORKERCATEGORYVSCOMPONENT' 
    and column_name not in( 'COMPANYCODE','DIVISIONCODE'  , 'EFFECTIVEDATE', 'WORKERCATEGORYCODE' , 'LASTMODIFIED' )
    */
    SELECT B.COMPONENTSHORTNAME AS CN 
      FROM WPSWORKERCATEGORYVSCOMPONENT A, WPSCOMPONENTMASTER B 
      WHERE A.COMPONENTCODE = B.COMPONENTCODE 
        AND A.EFFECTIVEDATE = ( 
                                SELECT MAX(EFFECTIVEDATE) 
                                FROM WPSWORKERCATEGORYVSCOMPONENT  
                              ) 
    )
    intersect
    select column_name cn from cols where table_name = 'WPSWAGESDETAILS_SWT' and column_name not in(  'WORKTYPECODE' ,'TOKENNO', 'WORKERCATEGORYCODE','WORKERSERIAL','DEPARTMENTCODE'  )
    )
    loop
    lv_colstr := lv_colstr||u1.cn||',' ;
    end loop;
    lv_colstr := lv_colstr||' WORKERCATEGORYCODE' ;
    lv_updsql := 'update '||p_process_table||' a set ('||lv_colstr||' ) = ( select '||lv_colstr||' from '||p_phase_table||' b '||chr(10) 
                  ||' where a.WORKERSERIAL = b.WORKERSERIAL '||CHR(10);
    IF instr(p_process_table,'SWT') > 0 THEN        -- FOR NAIHATI EARNING DISTRIBUTE IN SHIFT, DEPARTMENT,SECTION, OCCUPATION,DEPTSERIAL WISE 
        lv_updsql := lv_updsql ||'  AND NVL(A.SHIFTCODE,''N'') = NVL(B.SHIFTCODE,''N'') '||CHR(10);
        lv_updsql := lv_updsql ||'  AND NVL(A.DEPARTMENTCODE,''N'') = NVL(B.DEPARTMENTCODE,''N'') '||CHR(10);
        lv_updsql := lv_updsql ||'  AND NVL(A.SECTIONCODE,''N'') = NVL(B.SECTIONCODE,''N'') '||CHR(10);                 
        lv_updsql := lv_updsql ||'  AND NVL(A.OCCUPATIONCODE,''N'') = NVL(B.OCCUPATIONCODE,''N'') '||CHR(10);
        lv_updsql := lv_updsql ||'  AND NVL(A.DEPTSERIAL,''N'') = NVL(B.DEPTSERIAL,''N'') '||CHR(10);
    END IF;                  
    lv_updsql := lv_updsql ||'  AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE )';
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE,FORTNIGHTENDDATE,REMARKS ) 
    values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',lv_updsql,'',lv_fn_stdt, lv_fn_endt, p_phase_table);
--    dbms_output.put_line(lv_updsql);
    execute immediate lv_updsql ;
   COMMIT;
end if;        
--------------------- end update dummy 
exception
when others then
 --insert into error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) values( 'ERROR SQL',lv_sqlstr,lv_sqlstr,lv_parvalues,lv_remarks);
 lv_sqlerrm := sqlerrm ;
 --dbms_output.put_line(lv_sqlerrm);
 insert into WPS_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
 values( P_COMPCODE, P_DIVCODE,lv_ProcName,lv_sqlerrm,lv_updsql,'',lv_fn_stdt,lv_fn_endt, p_phase_table);
end;
/


