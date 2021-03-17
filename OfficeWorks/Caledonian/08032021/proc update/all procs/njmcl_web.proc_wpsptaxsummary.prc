DROP PROCEDURE NJMCL_WEB.PROC_WPSPTAXSUMMARY;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PROC_WPSPTAXSUMMARY" 
(
    p_companycode varchar2,
    p_divisioncode varchar2,
    p_yearmonth varchar2
)
as 
    lv_sqlstr           varchar2(4000);
    lv_yearmonth        varchar2(6);
    lv_FNSdate          varchar2(10);                
    lv_FNEdate          varchar2(10);
begin

    
    SELECT MIN(TO_CHAR(FORTNIGHTSTARTDATE,'DD/MM/RRRR')) 
      INTO lv_FNSdate
      FROM WPSWAGEDPERIODDECLARATION
     WHERE YEARMONTH=p_yearmonth;  
     
     SELECT MAX(TO_CHAR(FORTNIGHTSTARTDATE,'DD/MM/RRRR')) 
      INTO lv_FNEdate
      FROM WPSWAGEDPERIODDECLARATION
     WHERE YEARMONTH=p_yearmonth;

    delete from GTT_WPSPTAXSUMMARY;
    lv_sqlstr :=   'insert into GTT_WPSPTAXSUMMARY '|| chr(10)
    || 'SELECT STATENAME, SLABAMOUNTFROM, SLABAMOUNTTO, PTAX, NOOFHEAD, PTAXAMOUNT, COMPANYNAME, DIVISIONNAME,  '|| chr(10)
    || ' PRINTDATE, ROWNUM EX1, EX2, EX3, EX4, EX5  '|| chr(10)
    || 'FROM(  '|| chr(10)
    || 'SELECT STATENAME, SLABAMOUNTFROM, SLABAMOUNTTO, PTAX, COUNT(WORKERSERIAL) NOOFHEAD, PTAX * COUNT(WORKERSERIAL) PTAXAMOUNT,   '|| chr(10)
    || '       C.COMPANYNAME, D.DIVISIONNAME, TO_CHAR(TO_DATE('''||p_yearmonth||''',''YYYYMM''),''MON-YYYY'') PRINTDATE,  '|| chr(10)
    || '       NULL EX1, SUM(NVL(PTAX_GROSS,0)) EX2, NULL EX3, NULL EX4, NULL EX5 '|| chr(10)
    || 'FROM (  '|| chr(10)
    || 'SELECT A.WORKERSERIAL, NVL(A.PTAX_GROSS,0) PTAX_GROSS, NVL(A.PTAX,0) PTAX,  '|| chr(10)
    || '       B.STATENAME, B.SLABAMOUNTFROM, B.SLABAMOUNTTO  '|| chr(10)
    || 'FROM (  '|| chr(10)
    || '    SELECT WORKERSERIAL, SUM(NVL(A.GROSS_PTAX,0)) PTAX_GROSS,  '|| chr(10)
    || '          SUM(NVL(A.P_TAX,0)) PTAX  '|| chr(10)
    || '    FROM WPSWAGESDETAILS_MV A  '|| chr(10)
    || '    WHERE A.COMPANYCODE ='''||p_companycode||'''  '|| chr(10)
    || '      AND A.DIVISIONCODE ='''||p_divisioncode||''' '|| chr(10)
    || '       AND A.FORTNIGHTSTARTDATE>=TO_DATE(''' || lv_FNSdate || ''',''DD/MM/YYYY'')  '|| chr(10)
    || '       AND A.FORTNIGHTSTARTDATE<=TO_DATE(''' || lv_FNEdate || ''',''DD/MM/YYYY'')  '|| chr(10)
    || '      GROUP BY A.WORKERSERIAL  '|| chr(10)
    || '    ) A,WPSWORKERMAST C,  '|| chr(10)
    || '    (   '|| chr(10)
    || '    SELECT STATENAME, SLABAMOUNTFROM, SLABAMOUNTTO, PTAXAMOUNT   '|| chr(10)
    || '    FROM PTAXSLAB   '|| chr(10)
    || '    WHERE STATENAME||WITHEFFECTFROM = ( SELECT MAX(STATENAME||WITHEFFECTFROM)   '|| chr(10)
    || '                                        FROM PTAXSLAB    '|| chr(10)
    || '                                        WHERE TO_CHAR(WITHEFFECTFROM,''YYYYMM'') <= '''||p_yearmonth||'''   '|| chr(10)
    || '                                      )  '|| chr(10)
    || '    ) B           '|| chr(10)
    || '     WHERE  NVL(A.PTAX,0) =  B.PTAXAMOUNT (+)     '|| chr(10)
    || '     AND A.WORKERSERIAL = C.WORKERSERIAL  '|| chr(10)
    || ')A, COMPANYMAST C, DIVISIONMASTER D   '|| chr(10)
    || 'WHERE C.COMPANYCODE='''||p_companycode||'''  '|| chr(10)
    || '  AND D.COMPANYCODE ='''||p_companycode||''' '|| chr(10)
    || '  AND D.DIVISIONCODE ='''||p_divisioncode||''' '|| chr(10)
    || 'GROUP BY COMPANYNAME, D.DIVISIONNAME,STATENAME, SLABAMOUNTFROM, SLABAMOUNTTO, PTAX   '|| chr(10)
    || ')ORDER BY STATENAME, PTAX  '|| chr(10) ;
--                || 'SELECT STATENAME, SLABAMOUNTFROM, SLABAMOUNTTO, PTAX, NOOFHEAD, PTAXAMOUNT, COMPANYNAME, DIVISIONNAME, PRINTDATE, ROWNUM EX1, EX2, EX3, EX4, EX5 '|| chr(10)
--                || 'FROM ( '|| chr(10)
--                || 'SELECT STATENAME, SLABAMOUNTFROM, SLABAMOUNTTO, PTAX, COUNT(TOKENNO) NOOFHEAD, PTAX * COUNT(TOKENNO) PTAXAMOUNT, '|| chr(10)
--                || '       C.COMPANYNAME, D.DIVISIONNAME, TO_CHAR(TO_DATE('''||p_yearmonth||''',''YYYYMM''),''MON-YYYY'') PRINTDATE, NULL EX1, SUM(NVL(PTAX_GROSS,0)) EX2, NULL EX3, NULL EX4, NULL EX5 '|| chr(10)
--                || 'FROM (  '|| chr(10)
--                || '        SELECT A.TOKENNO, C.WORKERNAME EMPLOYEENAME, NVL(A.GROSS_PTAX,0) PTAX_GROSS, NVL(A.P_TAX,0) PTAX, B.STATENAME, B.SLABAMOUNTFROM, B.SLABAMOUNTTO '|| chr(10)
--                || '        FROM WPSWAGESDETAILS_MV A, WPSWORKERMAST C,  '|| chr(10)
--                || '        ( '|| chr(10)
--                || '            SELECT STATENAME, SLABAMOUNTFROM, SLABAMOUNTTO, PTAXAMOUNT  '|| chr(10)
--                || '            FROM PTAXSLAB  '|| chr(10)
--                || '            WHERE STATENAME||WITHEFFECTFROM = ( SELECT MAX(STATENAME||WITHEFFECTFROM)  '|| chr(10)
--                || '                                                FROM PTAXSLAB  '|| chr(10)
--                || '                                                WHERE TO_CHAR(WITHEFFECTFROM,''YYYYMM'') <= '''||p_yearmonth||''' '|| chr(10)
--                || '                                              ) '|| chr(10)
--                || '        ) B                                            '|| chr(10)
--                || '        WHERE A.COMPANYCODE = '''||p_companycode||''' '|| chr(10)
--                || '          AND A.DIVISIONCODE = '''||p_divisioncode||''' '|| chr(10)
--                --|| '          AND A.EFFECT_YEARMONTH='''||p_yearmonth||''' '|| chr(10)
--                --|| '          AND TRANSACTIONTYPE IN (''SALARY'',''SALARY ARREAR'',''FINAL SETTLEMENT'') '|| chr(10)
--                ||'           AND A.FORTNIGHTSTARTDATE>=TO_DATE(''' || lv_FNSdate || ''',''DD/MM/YYYY'') '|| CHR(10)
--                ||'           AND A.FORTNIGHTSTARTDATE<=TO_DATE(''' || lv_FNSdate || ''',''DD/MM/YYYY'') '|| CHR(10)
--                || '          AND NVL(A.P_TAX,0) =  B.PTAXAMOUNT (+) '|| chr(10)
--                || '          AND A.WORKERSERIAL = C.WORKERSERIAL '|| chr(10)
--                || '    ) A, COMPANYMAST C, DIVISIONMASTER D '|| chr(10)
--                || 'WHERE C.COMPANYCODE='''||p_companycode||''' '|| chr(10)
--                || '  AND D.COMPANYCODE='''||p_companycode||''' '|| chr(10)
--                || '  AND D.DIVISIONCODE='''||p_divisioncode||''' '|| chr(10)
--                || 'GROUP BY  STATENAME, SLABAMOUNTFROM, SLABAMOUNTTO, PTAX, C.COMPANYNAME, D.DIVISIONNAME '|| chr(10)
--                || 'ORDER BY STATENAME, PTAX) '|| chr(10);
                
   --DBMS_OUTPUT.PUT_LINE(lv_sqlstr);
   execute immediate lv_sqlstr;
end;
/


