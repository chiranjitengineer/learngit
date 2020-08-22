CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_PF_LOANCHECKLIST
--EXEC PROC_PF_LOANCHECKLIST('NJ0002','0010','01/03/2020','31/03/2020','''MPL''','', '', 'PIS','PF')
(
p_companycode    varchar2,
p_divisioncode   varchar2,
p_fromdate       varchar2,
p_todate         varchar2,
p_loancode       varchar2 default null,
p_dept           varchar2 default null,-- DEPT
p_worker         varchar2 default null,-- PFNO
p_module         varchar2 ,-- WPS/PIS
p_insertModule   varchar2  -- PF/GENERAL
)
as
/******************************************************************************
   NAME:      Ujjwal
   PURPOSE:   Pf loan Check List 
   Date :     29.07.2020
   Date :     31.07.2020
  
   NOTES:
   Implementing for Naihati Jute Mills 
******************************************************************************/  
lv_sqlstr varchar2(4000 byte);
lv_printon varchar2(400 byte);

lv_table varchar2(40 byte);
lv_companyname varchar2(40 byte);

lv_print varchar2(200 byte);

begin

lv_print :='PF LOAN CHECK LIST  FROM: '||p_fromdate||' TO '||p_todate;
    
    if p_insertModule='PF' then
        lv_table :='PFLOANTRANSACTION';
    else
        lv_table :='LOANTRANSACTION';
    end if;

    if p_companycode='NJ0002' then
        lv_companyname:='THE NAIHATI JUTE MILLS CO. LTD.';
    end if;

lv_printon :=''||p_todate||'';

proc_pfloanblnc(p_companycode,p_divisioncode, p_fromdate,p_todate,p_loancode,'');



delete from GTT_PF_LOANCHECKLIST;

lv_sqlstr:='INSERT INTO  GTT_PF_LOANCHECKLIST
(
    RMODE, TOKENNO, AMOUNT, LOANCODE, LOANDATE, ACTUALLOANAMOUNT, LOANAMOUNTADJUSTED, LOANINTAMOUNTADJUSTED, 
    INTERESTAMOUNT, REMARKS, DEPARTMENTCODE, ACTUALINTERESTAMOUNT, LASTMODIFIED, SANCTIONEDAMOUNT,  WORKERTOKENNO, 
    WORKERNAME, PFLOAN_BAL, PFLOAN_INT_BAL, PFLN_CAP_DEDUCT, COMPANYNAME, DIVISIONNAME, ACTIVE, CAPITALINSTALLMENTAMT, INTERESTINSTALLMENTAMT, NOOFINSTALLMENTS, PFNO,PRINTDATE,
    CAP_EMI,INT_EMI,APPLIEDYEAR
)

SELECT   TO_CHAR(A.LOANDATE,''MMYYYY'') RMODE, A.TOKENNO, A.SANCTIONEDAMOUNT AMOUNT,A.LOANCODE, TO_CHAR(TO_DATE(NVL(A.ACTUALLOANDATE,A.LOANDATE),''DD-MON-YY''),''DD/MM/YYYY'') LOANDATE,
CASE A.ACTUALLOANAMOUNT WHEN 0 THEN A.AMOUNT  WHEN NULL THEN A.AMOUNT ELSE A.ACTUALLOANAMOUNT END ACTUALLOANAMOUNT,
A.LOANAMOUNTADJUSTED, A.LOANINTAMOUNTADJUSTED,A.INTERESTAMOUNT,'''||lv_print||''' REMARKS, A.DEPARTMENTCODE,A.ACTUALINTERESTAMOUNT,
A.LASTMODIFIED, A.SANCTIONEDAMOUNT, 
B.TOKENNO WORKERTOKENNO,B.WORKERNAME ,C.PFLOAN_BAL,C.PFLOAN_INT_BAL,C.PFLN_CAP_DEDUCT,'''||lv_companyname||''',E.DIVISIONNAME,B.ACTIVE, 
ROUND(A.CAPITALINSTALLMENTAMT,2)CAPITALINSTALLMENTAMT , ROUND(A.INTERESTINSTALLMENTAMT,2) INTERESTINSTALLMENTAMT, A.NOOFINSTALLMENTS, A.PFNO, '''||lv_print||''' PRINT,
 A.CURR_CAP_EMI CAP_EMI,A.CURR_INT_EMI  INT_EMI, /*TO_CHAR(NVL(A.ACTUALLOANDATE,A.LOANDATE),''YYYY'')*/ ROUND(DECODE(A.MODULE,''PIS'',A.NOOFINSTALLMENTS/12,A.NOOFINSTALLMENTS/25),0) APPLIEDYEAR  
FROM '||lv_table||' A, 
WORKERVIEW B,GBL_PFLOANBLNC C,COMPANYMAST D,DIVISIONMASTER E 
WHERE A.COMPANYCODE = '''||p_companycode||''' 
        AND A.DIVISIONCODE = '''||p_divisioncode||''' 
        AND NVL(A.ACTUALLOANDATE,A.LOANDATE) >= TO_DATE ('''||p_fromdate||''', ''DD/MM/YYYY'') 
        AND NVL(A.ACTUALLOANDATE,A.LOANDATE) <= TO_DATE ('''||p_todate||''', ''DD/MM/YYYY'')    
--      AND B.COMPANYCODE = '''||p_companycode||''' 
--      AND B.DIVISIONCODE = '''||p_divisioncode||''' 
        AND A.WORKERSERIAL = B.WORKERSERIAL 
        AND A.TOKENNO= C.TOKENNO (+)
        AND A.WORKERSERIAL=C.WORKERSERIAL (+)
        AND A.LOANCODE=C.LOANCODE (+)
        AND A.COMPANYCODE=D.COMPANYCODE 
        AND A.COMPANYCODE=E.COMPANYCODE 
        AND A.DIVISIONCODE=E.DIVISIONCODE ';

       if p_loancode is not null then 
            lv_sqlstr:=lv_sqlstr||'  AND A.LOANCODE IN('||p_loancode||')'||chr(10);
       end if;
      
       if p_dept is not null then 
            lv_sqlstr:=lv_sqlstr||'  AND A.DEPARTMENTCODE IN('||p_dept||')'||chr(10);
       end if;
      
       if p_worker is not null then 
             lv_sqlstr:=lv_sqlstr||'  AND A.PFNO IN('||p_worker||')'||chr(10);
       end if;
       
       lv_sqlstr:=lv_sqlstr||'ORDER BY A.APPLICATIONNO, B.TOKENNO'||chr(10);
      
      --dbms_output.put_line(lv_sqlstr);
      execute immediate(lv_sqlstr);
         
      
      
   --  UPDATE GTT_PF_LOANCHECKLIST SET SRLNO =  rtrim(TO_CHAR(TO_DATE(LOANDATE, 'DD-MM-YYYY'), 'Month'))||''''||to_char(TO_DATE(LOANDATE,'DD-MM-YYYY'),'YY') ;    
      
--    INSERT INTO GTT_PF_LOANCHECKLIST(RMODE, WORKERNAME, LOANDATE,CAPITALINSTALLMENTAMT,INTERESTINSTALLMENTAMT) 
--    SELECT  2 RMODE, 'TOTAL' TOTAL, LOANDATE, SUM(CAPITALINSTALLMENTAMT)CAPITALINSTALLMENTAMT,SUM(INTERESTINSTALLMENTAMT)INTERESTINSTALLMENTAMT 
--    FROM GTT_PF_LOANCHECKLIST  
--    GROUP BY LOANDATE;   
--
--    INSERT INTO GTT_PF_LOANCHECKLIST(TOKENNO,PFNO, RMODE, WORKERNAME, LOANDATE,LOANCODE, CAPITALINSTALLMENTAMT,INTERESTINSTALLMENTAMT)     
--    SELECT MAX(NOOF)NOOF, SUM(PFNO)PFNO, MAX(RMODE)RMODE, MAX(TOTAL)TOTAL, 
--    LOANDATE,LOANCODE, SUM(CAPITALINSTALLMENTAMT)CAPITALINSTALLMENTAMT,SUM(INTERESTINSTALLMENTAMT)INTERESTINSTALLMENTAMT 
--    FROM 
--        ( 
--        SELECT DISTINCT NOOF, PFNO, RMODE, TOTAL, 
--        rtrim(TO_CHAR(TO_DATE(LOANDATE, 'DD-MON-YY'), 'Month'))||''''||to_char(TO_DATE(LOANDATE,'DD-MON-YY'),'YY')LOANDATE,LOANCODE, 
--        CAPITALINSTALLMENTAMT, INTERESTINSTALLMENTAMT 
--        FROM (      
--            SELECT 'NO OF EMP' NOOF, COUNT(*) PFNO, 3 RMODE, 'MONTH TOTAL' TOTAL,
--            LOANDATE , TO_CHAR(TO_DATE(LOANDATE,'DD-MON-YY'),'MM/YYYY') LOANCODE,  
--            SUM(CAPITALINSTALLMENTAMT)CAPITALINSTALLMENTAMT,SUM(INTERESTINSTALLMENTAMT)INTERESTINSTALLMENTAMT 
--            FROM GTT_PF_LOANCHECKLIST  
--            WHERE RMODE=1
--            GROUP BY LOANDATE           
--            )            
--        ) 
--    GROUP BY LOANCODE,LOANDATE  ;    
         
   -- COMMIT;
END;
/