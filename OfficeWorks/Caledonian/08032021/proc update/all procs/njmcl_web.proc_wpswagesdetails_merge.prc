DROP PROCEDURE NJMCL_WEB.PROC_WPSWAGESDETAILS_MERGE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PROC_WPSWAGESDETAILS_MERGE" 
( 
p_COMPANYCODE varchar2, 
p_divisioncode varchar2, 
p_fnstdt VARCHAR2, 
p_fnendt varchar, 
p_phase_before int ,
p_prosess_table varchar2 DEFAULT 'WPSWAGESDETAILS_SWT', 
p_prosess_table_merge varchar2 DEFAULT 'WPSWAGESDETAILS_MV_SWT' ,
p_workerserial varchar2 DEFAULT NULL 
)
as
lv_sqlstr varchar2(32767);
lv_colstr varchar2(32767);
lv_select_colstr varchar2(32767) := ' SELECT COMPANYCODE, DIVISIONCODE, YEARCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERSERIAL AS 

SYSROWID, WORKERCATEGORYCODE, WORKERSERIAL, TOKENNO '; 
lv_sum_colstr varchar2(32767) := ' , MAX(DEPARTMENTCODE) DEPARTMENTCODE,SUM(ATTENDANCEHOURS) 

ATTENDANCEHOURS,SUM(OVERTIMEHOURS) OVERTIMEHOURS,SUM(STLHOURS) STLHOURS, SUM(NIGHTALLOWANCEHOURS) NIGHTALOWANCEHOURS, SUM(HOLIDAYHOURS)  HOLIDAYHOURS, SUM(LAYOFFHOURS) LAYOFFHOURS,SUM(FBKHOURS) FBKHOURS, SUM(OT_NSHRS) OT_NSHRS ';
lv_insert_colstr varchar2(32767) := 'INSERT INTO '||p_prosess_table_merge||'(COMPANYCODE, DIVISIONCODE, YEARCODE, FORTNIGHTSTARTDATE, 

FORTNIGHTENDDATE, SYSROWID, WORKERCATEGORYCODE, WORKERSERIAL, TOKENNO ,'||CHR(10) 
                                    ||' DEPARTMENTCODE, ATTENDANCEHOURS,OVERTIMEHOURS,STLHOURS, NIGHTALLOWANCEHOURS, HOLIDAYHOURS, LAYOFFHOURS,FBKHOURS,OT_NSHRS ' ;
lv_group_by_colstr varchar2(32767) := ' COMPANYCODE, DIVISIONCODE, YEARCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERCATEGORYCODE, 

WORKERSERIAL, TOKENNO ' ;
lv_fn_stdt date := to_date(p_fnstdt,'dd/mm/yyyy');
lv_fn_endt date := to_date(p_fnendt,'dd/mm/yyyy');
lv_sqlerrm varchar(2000);
lv_parvalues varchar(4000) := ' COMPANYCODE -> '||p_COMPANYCODE||' DIVISIONCODE -> '||p_divisioncode||' FNSTART -> 

'||p_fnstdt||' FNEND -> '||p_fnendt||' PHASE BEFORE ->'||to_char(p_phase_before)||' PROCESS TABLE -> '||p_prosess_table||' 

MERGED TABLE -> '||p_prosess_table_merge||' WORKERSERIAL ->'||nvl(p_workerserial,'ALL') ;
lv_remarks varchar(2000);
--BEGIN
-- PROC_WPSWAGESDETAILS_MERGE( '0001', 'MILL', '01/11/2015', '15/11/2015', 4 ,'WPSWAGESDETAILS_SWT', 'WPSWAGESDETAILS_MV_SWT_T' ,'''''''09224'''',''''15876''''''' );
--END;
begin   
    lv_remarks := ' DELETING MERGED TABLE '; 
    lv_sqlstr := 'DELETE FROM '||p_prosess_table_merge||chr(10)
             ||' WHERE 1=1  '||CHR(10)
             ||' AND COMPANYCODE = '''||p_COMPANYCODE||''' '||CHR(10)
             ||' AND DIVISIONCODE = '''||p_divisioncode||''' '||CHR(10)
             ||' AND FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' '||CHR(10)
             ||' AND FORTNIGHTENDDATE = '''||lv_fn_endt||''' ';
             if p_workerserial is not null then
                lv_sqlstr :=  lv_sqlstr||' AND INSTR('||p_workerserial||',WORKERSERIAL) > 0 ' ;
             end if;
  --  dbms_output.put_line(lv_sqlstr);         
    execute immediate lv_sqlstr;  
    for u1 in(
            SELECT COLUMN_NAME COLUMN_NAME FROM COLS WHERE TABLE_NAME = 'WPSWAGESDETAILS_SWT'
            INTERSECT
            SELECT DISTINCT(COMPONENTSHORTNAME) COLUMN_NAME
            FROM WPSCOMPONENTMASTER 
            WHERE 1=1
            AND COMPANYCODE = p_COMPANYCODE
            AND DIVISIONCODE = p_divisioncode
            AND PHASE < p_phase_before
            AND TAKEPARTINWAGES = 'Y'
    )
    loop
     lv_sum_colstr := lv_sum_colstr||' , SUM('||u1.COLUMN_NAME||') '||u1.COLUMN_NAME||' ' ;
     lv_insert_colstr := lv_insert_colstr||' , '||u1.COLUMN_NAME ;
     lv_colstr := lv_colstr||u1.COLUMN_NAME||',' ;
    end loop;
    lv_insert_colstr := lv_insert_colstr||')';
    lv_sqlstr := lv_insert_colstr||CHR(10)||lv_select_colstr||chr(10)||lv_sum_colstr||chr(10)||' FROM 

'||p_prosess_table||chr(10)
                  ||' WHERE 1=1 '||CHR(10)
                  ||' AND COMPANYCODE = '''||p_COMPANYCODE||''' '||CHR(10)
                  ||' AND DIVISIONCODE = '''||p_divisioncode||''' '||CHR(10)
                  ||' AND FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' '||CHR(10)
                  ||' AND FORTNIGHTENDDATE = '''||lv_fn_endt||''' '; 
                  if p_workerserial is not null then
                      lv_sqlstr :=  lv_sqlstr||CHR(10)||' AND INSTR('||p_workerserial||',WORKERSERIAL) > 0 ' ;
                  end if;
                  lv_sqlstr :=  lv_sqlstr||CHR(10)||' GROUP BY '||lv_group_by_colstr ;
    --dbms_output.put_line(lv_sqlstr);   
    lv_remarks := ' INSERTING INTO MERGED TABLE';
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( p_COMPANYCODE, p_divisioncode, 'PROC_WPSWAGESDETAILS_MERGE','',lv_sqlstr,lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
--    COMMIT;    
    execute immediate lv_sqlstr ;
-- QUERY FOR NON-COMPONENT-SUM COLS
-- date XX cols 
--YEARCODE, COMPANYCODE, DIVISIONCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, DEPARTMENTCODE, OCCUPATIONCODE, WORKERSERIAL,TOKENNO, LASTMODIFIED, WORKERCATEGORYCODE, SHIFTCODE, SERIALNO, ISDATAVALID, WORKTYPECODE, PAYMODE
/*SELECT COLUMN_NAME COLUMN_NAME FROM COLS WHERE TABLE_NAME = 'WPSWAGESDETAILS_SWT'
MINUS
(
SELECT COLUMN_NAME COLUMN_NAME FROM COLS WHERE TABLE_NAME = 'WPSWAGESDETAILS_SWT'
INTERSECT
SELECT DISTINCT(COMPONENTSHORTNAME) COLUMN_NAME
FROM WPSCOMPONENTMASTER 
)
MINUS
SELECT COLUMN_NAME COLUMN_NAME FROM COLS WHERE TABLE_NAME = 'WPSWAGESDETAILS_SWT' AND DATA_TYPE IN('CHAR','VARCHAR2','DATE')
*/
COMMIT;
exception
 when others then  
    lv_sqlerrm := sqlerrm ;
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS 

) values( p_COMPANYCODE, p_divisioncode,'PROC_WPSWAGESDETAILS_MERGE',lv_sqlstr,lv_sqlstr,lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
    commit;
END;
/


