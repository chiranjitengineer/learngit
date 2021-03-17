DROP PROCEDURE NJMCL_WEB.PROC_WPSDOUBLE_VB_TONULL_UPDT;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPSDOUBLE_VB_TONULL_UPDT ( P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2, 
                                                  P_YEARCODE Varchar2,
                                                  P_FNSTDT Varchar2, 
                                                  P_FNENDT Varchar2,
                                                  P_PHASE  number, 
                                                  P_PHASE_TABLENAME Varchar2,
                                                  P_TABLENAME Varchar2,
                                                  P_WORKKERSERIAL VARCHAR2 DEFAULT NULL,
                                                  P_PROCESSTYPE  VARCHAR2 DEFAULT 'WAGES PROCESS')
as 
lv_fn_stdt DATE := TO_DATE(P_FNSTDT,'DD/MM/YYYY');
lv_fn_endt DATE := TO_DATE(P_FNENDT,'DD/MM/YYYY');
lv_TableName        varchar2(50);
lv_Remarks          varchar2(1000) := '';
lv_SqlStr           varchar2(4000);
lv_SQLCompView      varchar2(4000) := '';
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';
lv_cnt              number(5):=0;   

begin
--     dbms_output.put_line('start : ');

    --- HERE NEED TO HARD CODE IN THE SYSTEM BECAUSE 
    --- FOR COP WINDING DEPARTMENT MAINTAIN TWO SECTION (0801,0805) FOR PEICE RATE ENTRY.
    --- BUT PRODUCTION ENTRY IN 0801 SECTION . SO AT THE TIME VB CALCULATION 0805 SECTION'S WOKRER CONSIDER AS 0801 SECTION.
    --- NOW DUE TO DUE TO SECTION SECTION BOOKING 0805 WORKER'S ALSO UPDATE THE SAME SAME VBAMOUNT IN INSERT PORCEDURE.
    --- SO NEED TO UPDATE VBAMOUNT AS ZERO FOR THOSE WORKER WHO WORKED IN BOTH 0801 and 0805 section
    FOR C1 IN (
                SELECT WORKERSERIAL, COUNT(*) CNT
                FROM (
                        SELECT WORKERSERIAL, DEPARTMENTCODE, SECTIONCODE
                        FROM WPSWAGESDETAILS_SWT 
                        WHERE COMPANYCODE = '0001' AND DIVISIONCODE ='0002'
                          AND FORTNIGHTSTARTDATE = lv_fn_stdt
                          AND FORTNIGHTENDDATE = lv_fn_endt
                          AND SECTIONCODE IN ('0801','0805')
                          AND VBASIC > 0
                    )
                GROUP BY WORKERSERIAL
                HAVING COUNT(*) > 1
            )
     LOOP
        lv_cnt := lv_cnt+1;
--        dbms_output.put_line('cnt : ');
        lv_SqlStr := 'UPDATE WPSWAGESDETAILS_SWT A SET VBASIC = 0 '||chr(10)
                ||'   WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
                ||'     AND FORTNIGHTSTARTDATE >= TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'') '||chr(10)
                ||'     AND FORTNIGHTENDDATE <= TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') '||chr(10)
                ||'     AND WORKERSERIAL = '''||C1.WORKERSERIAL||'''  '||chr(10)
                ||'     AND SECTIONCODE = ''0805'' '||CHR(10); 
        --EXECUTE IMMEDIATE lv_SqlStr;

        UPDATE WPSWAGESDETAILS_SWT A SET VBASIC = 0 
        WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE 
          AND FORTNIGHTSTARTDATE >= TO_DATE(P_FNSTDT,'DD/MM/YYYY')
          AND FORTNIGHTENDDATE <= TO_DATE(P_FNENDT,'DD/MM/YYYY')
          AND WORKERSERIAL = C1.WORKERSERIAL 
          AND SECTIONCODE = '0805' ; 

     END LOOP;
--     dbms_output.put_line ('update successfully');       
    COMMIT;
exception
when others then
 --insert into error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) values( 'ERROR SQL',lv_sqlstr,lv_sqlstr,lv_parvalues,lv_remarks);
 lv_sqlerrm := sqlerrm ;
 --dbms_output.put_line(lv_sqlerrm);
 insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_INSERT',lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
end;
/


