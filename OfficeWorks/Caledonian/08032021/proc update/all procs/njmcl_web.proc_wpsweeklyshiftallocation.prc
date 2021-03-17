DROP PROCEDURE NJMCL_WEB.PROC_WPSWEEKLYSHIFTALLOCATION;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PROC_WPSWEEKLYSHIFTALLOCATION" 
(
    p_companycode varchar2,
    p_divisioncode varchar2,
    p_fromdt varchar2,
    p_todt varchar2
)
as 
    lv_sqlstr           varchar2(20000);
begin
    delete from GTT_WPSWEEKLYSHIFTALLOCATION;
    lv_sqlstr :=    'insert into GTT_WPSWEEKLYSHIFTALLOCATION '|| chr(10)
          || ' SELECT  B.DEPARTMENTCODE,C.DEPARTMENTNAME,A.TOKENNNO,B.WORKERNAME,A.DATEOFATTENDANCE DATEOFATTENDANCE,    '|| chr(10)
          || '       A.SHIFTCODE,D.SHIFTNAME,E.COMPANYNAME, ''' || p_fromdt || '''||'' to ''||''' || p_todt || ''' EX1, NULL EX2,NULL EX3,NULL EX4,NULL EX5 '|| chr(10)
          || ' FROM WPSDAILYATTENDANCEALLOCATION A, WPSWORKERMAST B, WPSDEPARTMENTMASTER C, WPSSHIFTMAST D, COMPANYMAST E '|| chr(10)
          || 'WHERE A.COMPANYCODE='''|| p_companycode ||''' '|| chr(10)
          || '  AND A.DIVISIONCODE='''|| p_divisioncode ||''' '|| chr(10)
          || '  AND A.DATEOFATTENDANCE BETWEEN TO_DATE(''' || p_fromdt || ''',''DD/MM/YYYY'') '|| chr(10)
          || '                         AND TO_DATE(''' || p_todt || ''',''DD/MM/YYYY'') '|| chr(10)
          || '  AND A.COMPANYCODE=B.COMPANYCODE '|| chr(10)
          || '  AND A.DIVISIONCODE=B.DIVISIONCODE '|| chr(10)
          || '  AND A.TOKENNNO=B.TOKENNO '|| chr(10)
          || '  AND A.WORKERSERIAL=B.WORKERSERIAL '|| chr(10)
          || '  AND A.COMPANYCODE=C.COMPANYCODE '|| chr(10)
          || '  AND A.DIVISIONCODE=C.DIVISIONCODE '|| chr(10)
          || '  AND A.DEPARTMENTCODE=C.DEPARTMENTCODE '|| chr(10)
          || '  AND A.COMPANYCODE=D.COMPANYCODE '|| chr(10)
          || '  AND A.DIVISIONCODE=D.DIVISIONCODE '|| chr(10)
          || '  AND A.SHIFTCODE=D.SHIFTCODE '|| chr(10)
          || '  AND A.COMPANYCODE=E.COMPANYCODE '|| chr(10)
          || '  ORDER BY DEPARTMENTCODE,A.TOKENNNO,TO_CHAR(A.DATEOFATTENDANCE,''DD/MM/YYYY''),A.SHIFTCODE '|| chr(10);
 
                 
    --dbms_output.put_line(lv_sqlstr);
   execute immediate lv_sqlstr;
end;
/


