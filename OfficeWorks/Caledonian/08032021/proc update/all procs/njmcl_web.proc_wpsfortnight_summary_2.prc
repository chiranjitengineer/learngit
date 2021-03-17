DROP PROCEDURE NJMCL_WEB.PROC_WPSFORTNIGHT_SUMMARY_2;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PROC_WPSFORTNIGHT_SUMMARY_2" 
(
    p_companycode varchar2,
    p_divisioncode varchar2,
    p_yearcode      varchar2,
    p_fromdt varchar2,
    p_todt varchar2
)
as 
    lv_sqlstr           varchar2(20000);
begin
    delete from GTT_WPSFORTNIGHTATTENDANCE_2;

    lv_sqlstr :=    ' INSERT INTO GTT_WPSFORTNIGHTATTENDANCE_2 '||CHR(10)    
            ||' SELECT '''||p_fromdt||''' FROMDT,'''||p_todt||''' TODT, D.COMPANYNAME, '||CHR(10)
            ||' A.UNITCODE UNIT, A.DEPARTMENTCODE DEPT, DECODE(A.SHIFTCODE,''1'',''A'',DECODE(A.SHIFTCODE,''2'',''B'',''C'')) SFT, A.PAGENO, B.WORKERCATEGORYCODE CATG, A.TOKENNO, B.WORKERNAME, '||CHR(10) 
            ||' B.FIXEDBASIC, B.DARATE, B.ADHOCRATE, B.ADDLBASIC_RATE, B.SPL_ALLOW_RATE, B.ESINO, '||CHR(10)
            ||' SUM(NVL(A.ATTENDANCEHOURS,0)) HRS_WORKED, SUM(NVL(A.HOLIDAYHOURS,0)) HOL_HRS, SUM(NVL(A.OVERTIMEHOURS,0)) OT_HRS, '||CHR(10) 
            ||' SUM(NVL(A.PF_ADJ,0)) PF_ADJ_EARN, SUM(NVL(A.PF_ADJ_DEDN,0)) PF_ADJ_DEDN, SUM(NVL(A.NPF_ADJ,0)) OTH_EARN, SUM(NVL(A.NPF_ADJ_DEDN,0)) OTH_DEDN '||CHR(10)   
            ||' FROM WPSATTENDANCEDAYWISE A, WPSWORKERMAST B, COMPANYMAST D '||CHR(10)  
            ||' WHERE A.COMPANYCODE = '''||p_companycode||''' '||CHR(10) 
            ||' AND A.DIVISIONCODE = '''||p_divisioncode||''' '||CHR(10)
            ||' AND A.YEARCODE = '''||p_yearcode||''' '||CHR(10) 
            ||' AND A.DATEOFATTENDANCE >= TO_DATE('''|| p_fromdt ||''',''DD/MM/YYYY'') '||CHR(10)  
            ||' AND A.DATEOFATTENDANCE <= TO_DATE('''||p_todt||''',''DD/MM/YYYY'') '||CHR(10) 
            ||' AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
            ||' AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
            ||' AND A.COMPANYCODE = D.COMPANYCODE '||CHR(10)
            ||' GROUP BY  D.COMPANYNAME, A.UNITCODE, A.DEPARTMENTCODE, A.SHIFTCODE, A.PAGENO, B.WORKERCATEGORYCODE, A.TOKENNO, B.WORKERNAME, '||CHR(10) 
            ||' B.FIXEDBASIC, B.DARATE, B.ADHOCRATE, B.ADDLBASIC_RATE, B.SPL_ALLOW_RATE, B.ESINO '||CHR(10)
            ||' ORDER BY A.TOKENNO, A.UNITCODE, A.DEPARTMENTCODE, A.SHIFTCODE    '||CHR(10);
    dbms_output.put_line(lv_sqlstr);
   execute immediate lv_sqlstr;
end;
/


