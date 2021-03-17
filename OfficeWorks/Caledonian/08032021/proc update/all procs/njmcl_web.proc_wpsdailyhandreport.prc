DROP PROCEDURE NJMCL_WEB.PROC_WPSDAILYHANDREPORT;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PROC_WPSDAILYHANDREPORT" 
(
    p_companycode varchar2,
    p_divisioncode varchar2,
    p_fromdt varchar2,
    p_todt varchar2
)
as 
    lv_sqlstr           varchar2(20000);
begin
    delete from GTT_WPSDAILYHAND;
    lv_sqlstr :=    'insert into GTT_WPSDAILYHAND '|| chr(10)
    || '  SELECT X.COMPANYNAME,X.DEPARTMENTCODE,X.SHIFTCODE,X.SHIFTNAME, X.TOKENNO,X.WORKERNAME,X.OCCUPATIONCODE,X.LINENO,X.MACHINECODE1,NVL(X.OVERTIMEHOURS,0) OVERTIMEHOURS, '|| chr(10)
                || '          ''(''||RTRIM (XMLAGG (XMLELEMENT (E,X.ATTENDANCEHOURS || '' / '')ORDER BY X.TOKENNO,X.SPELLTYPE).EXTRACT (''//text()''), '' /'')||'')''  AS ATTENDANCEHOURS '|| chr(10)
                || '           , NULL EX1 , NULL EX2, NULL EX3, NULL EX4, NULL EX5 '|| chr(10)
                || ' FROM '|| chr(10)
                || ' ( '|| chr(10)
                || ' SELECT D.COMPANYNAME, A.DEPARTMENTCODE,A.SHIFTCODE,C.SHIFTNAME, A.TOKENNO,B.WORKERNAME,A.OCCUPATIONCODE,''LINE'' LINENO,A.MACHINECODE1, '|| chr(10)
                || '         A.SPELLTYPE,NVL(A.SPELLHOURS,A.ATTENDANCEHOURS) ATTENDANCEHOURS,A.OVERTIMEHOURS '|| chr(10)
                || '        FROM WPSATTENDANCEDAYWISE A, WPSWORKERMAST B, WPSSHIFTMAST C, COMPANYMAST D '|| chr(10)
                || '  WHERE 1=1  '|| chr(10)
                || '   AND A.COMPANYCODE='''|| p_companycode ||''' '|| chr(10)
                || '   AND A.DIVISIONCODE='''|| p_divisioncode ||''' '|| chr(10)
                || '   AND A.COMPANYCODE=B.COMPANYCODE '|| chr(10)
                || '   AND A.DIVISIONCODE=B.DIVISIONCODE '|| chr(10)
                || '   AND A.WORKERSERIAL = B.WORKERSERIAL  '|| chr(10)
                || '   AND A.TOKENNO=B.TOKENNO '|| chr(10)
                || '   AND A.DEPARTMENTCODE=B.DEPARTMENTCODE '|| chr(10)
                || '   AND A.OCCUPATIONCODE=B.OCCUPATIONCODE '|| chr(10)
                || '   AND A.COMPANYCODE=C.COMPANYCODE  '|| chr(10)
                || '   AND A.DIVISIONCODE=C.DIVISIONCODE  '|| chr(10)
                || '   AND A.SHIFTCODE=C.SHIFTCODE  '|| chr(10)
                || '   AND A.COMPANYCODE=D.COMPANYCODE '|| chr(10)
                || '   ORDER BY A.DEPARTMENTCODE,A.SHIFTCODE,A.TOKENNO,A.SPELLTYPE '|| chr(10)
                || '   )X '|| chr(10)
                || '   GROUP BY  X.COMPANYNAME,X.DEPARTMENTCODE,X.SHIFTCODE,X.SHIFTNAME, X.TOKENNO,X.WORKERNAME,X.OCCUPATIONCODE,X.LINENO, '|| chr(10)
                || '            X.MACHINECODE1,X.OVERTIMEHOURS '|| chr(10);

                 
    dbms_output.put_line(lv_sqlstr);
   --execute immediate lv_sqlstr;
end;
/


