CREATE OR REPLACE PROCEDURE INFRA_WPS.PROC_WPSWORKERCATEGORY_UPDT ( P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2, 
                                                  P_YEARCODE Varchar2,
                                                  P_FNSTDT Varchar2, 
                                                  P_FNENDT Varchar2,
                                                  P_PHASE  number, 
                                                  P_PHASE_TABLENAME Varchar2,
                                                  P_TABLENAME Varchar2,
                                                  P_WORKKERSERIAL VARCHAR2 DEFAULT NULL,
                                                  P_PROCESSTYPE VARCHAR2 DEFAULT NULL)
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
     dbms_output.put_line('start : ');
    FOR C1 IN (
                SELECT WORKERSERIAL, COUNT(*) CNT
                FROM (
                        SELECT DISTINCT WORKERSERIAL, WORKERCATEGORYCODE 
                        FROM WPSATTENDANCEDAYWISE
                        WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                          AND YEARCODE = P_YEARCODE
                          AND DATEOFATTENDANCE >= TO_DATE(P_FNSTDT,'DD/MM/YYYY')
                          AND DATEOFATTENDANCE <= TO_DATE(P_FNENDT,'DD/MM/YYYY')
                    )
                GROUP BY WORKERSERIAL
                HAVING COUNT(*) > 1
            )
     LOOP
        lv_cnt := lv_cnt+1;
        dbms_output.put_line('cnt : ');
        lv_SqlStr := 'UPDATE WPSATTENDANCEDAYWISE A SET A.WORKERCATEGORYCODE = ( SELECT WORKERCATEGORYCODE FROM WPSWORKERMAST B '||chr(10)
                ||'                                                              WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
                ||'                                                                AND WORKERSERIAL = '''||C1.WORKERSERIAL||'''  '||chr(10) 
                ||'                                                            ) '||chr(10)
                ||'WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10) 
                ||'  AND YEARCODE = '''||P_YEARCODE||''' '||chr(10)
                ||'  AND DATEOFATTENDANCE >= TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'') '||chr(10)
                ||'  AND DATEOFATTENDANCE <= TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') '||chr(10)
                ||'  AND WORKERSERIAL = '''||C1.WORKERSERIAL||''' '||chr(10);
--          AND A.WORKERCATEGORYCODE <> ( SELECT WORKERCATEGORYCODE FROM WPSWORKERMAST B
--                                                                   WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
--                                                                  AND WORKERSERIAL = B.WORKERSERIAL
--                                       );                                                                                           
     
     dbms_output.put_line('cnt11 :'||lv_SqlStr);
     EXECUTE IMMEDIATE lv_SqlStr;
     END LOOP;
     dbms_output.put_line ('update successfully');       
    COMMIT;
exception
when others then
 --insert into error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) values( 'ERROR SQL',lv_sqlstr,lv_sqlstr,lv_parvalues,lv_remarks);
 lv_sqlerrm := sqlerrm ;
 --dbms_output.put_line(lv_sqlerrm);
 insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSWAGESPROCESS_INSERT',lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
end;
/
