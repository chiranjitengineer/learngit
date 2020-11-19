CREATE OR REPLACE procedure BAGGAGE_WEB.proc_componentassinreport
(
    p_companycode varchar2, 
    p_divisioncode varchar2, 
    p_yearmonth varchar2,
    p_component varchar2,
    p_unitcode varchar2 default null,
    p_category varchar2 default null,
    p_grade varchar2 default null,
    p_option varchar2 default null,
    p_rpt_option varchar2 default 'ALL'
)
as 
lv_sqlstr varchar2(10000);
lv_rpt_opt varchar2(20);

LV_TRANS_TABLE VARCHAR2(30);
begin


LV_TRANS_TABLE := 'PISPAYTRANSACTION';


lv_rpt_opt := UPPER(nvl(p_rpt_option,'ALL'));

IF lv_rpt_opt = 'ARREAR' THEN
    LV_TRANS_TABLE := 'PISARREARTRANSACTION';
END IF;

    delete from gtt_componentassinreport WHERE 1=1; 
    lv_sqlstr :=  'INSERT INTO GTT_COMPONENTASSINREPORT '||chr(10) 
                ||'SELECT A.WORKERSERIAL, A.TOKENNO, A.EMPLOYEENAME, A.UNITCODE, A.CATEGORYCODE CAT_CD, A.GRADECODE GRD_CD, A.DEPARTMENTCODE DEPT_CD, '||chr(10)
                ||'       A.ESINO, A.PFNO, A.PENSIONNO, A.SEX, A.EMPLOYEESTATUS, A.DATEOFBIRTH, A.DATEOFJOIN, A.DATEOFCONFIRMATION, A.PFENTITLEDATE,  '||chr(10)
                ||'       A.EXTENDEDRETIREDATE, B.COMPONENTCODE, B.PHASE, B.CALCULATIONINDEX, M.COMPANYNAME, V.DIVISIONNAME, B.COMPONENTSHORTNAME,   '||chr(10)
                ||'       fn_get_compvalue(C.COMPANYCODE,C.DIVISIONCODE,C.YEARMONTH,C.WORKERSERIAL,B.COMPONENTCODE,'''||p_option||''','''||lv_rpt_opt||''') COMPVALUE, TO_CHAR(TO_DATE('''||p_yearmonth||''',''YYYYMM''),''MON-YYYY'') PRINTDATE, '||chr(10)
                ||'       NVL(B.PRINTSERIAL,0) EX1, ''Run Date '' || TO_CHAR(SYSDATE,''DD/MM/YYYY  HH:MI:SS AM'') EX2,CASE WHEN '''||p_option||'''=''PIS COMPONENT REGISTER'' THEN C.ATTN_SALD ELSE NULL END  EX3, B.COLHEADER EX4, NULL EX5, NULL EX6, NULL EX7, NULL EX8, NULL EX9, NULL EX10 '||chr(10)
                ||'  FROM PISEMPLOYEEMASTER A,  '||chr(10)
                ||'       ( SELECT DISTINCT COMPONENTCODE, COMPONENTSHORTNAME, PHASE, CALCULATIONINDEX,PRINTSERIAL,COLHEADER FROM PISCOMPONENTMASTER  '||chr(10)
                ||'          WHERE COMPANYCODE = '''||p_companycode||''' AND DIVISIONCODE = '''||p_divisioncode||''' '||chr(10)
                ||'            AND YEARMONTH = ( '||chr(10)
                ||'                             SELECT MAX(YEARMONTH) FROM PISCOMPONENTMASTER  '||chr(10)
                ||'                              WHERE COMPANYCODE = '''||p_companycode||''' AND DIVISIONCODE = '''||p_divisioncode||''' '||chr(10)
                ||'                                AND YEARMONTH<='''||p_yearmonth||''' '||chr(10)
                ||'                            ) '||chr(10);
                if lv_rpt_opt='CUSTOMS' AND p_option='PIS COMPONENT REGISTER'  then
                    lv_sqlstr:=lv_sqlstr||'            AND PRINTSERIAL IS NOT NULL '||chr(10);
                    
                elsif lv_rpt_opt='ARREAR' AND p_option='PIS COMPONENT REGISTER'  then
--                    lv_sqlstr:=lv_sqlstr||'            AND INCLUDEARREAR=''Y'' AND PRINTSERIAL IS NOT NULL '||chr(10);
                    lv_sqlstr:=lv_sqlstr||'           AND PRINTSERIAL IS NOT NULL '||chr(10);
                    
                end if;
                
                if p_option='MASTER ASSIGNMENT' then
                    lv_sqlstr:=lv_sqlstr||'            AND ROLLOVERAPPLICABLE = ''Y'' '||chr(10);
                end if;
                
                 if (lv_rpt_opt='CUSTOMS'  OR lv_rpt_opt='ARREAR')  AND p_option='PIS COMPONENT REGISTER'  then
                    lv_sqlstr:=lv_sqlstr||'       ORDER BY PRINTSERIAL) B, '||chr(10);
                ELSE
                    lv_sqlstr:=lv_sqlstr||'       ORDER BY PHASE, CALCULATIONINDEX) B, '||chr(10);
                end if;
                
               
                
                if p_option='MASTER ASSIGNMENT' then
                    lv_sqlstr:=lv_sqlstr||'       ( SELECT * FROM PISCOMPONENTASSIGNMENT '||chr(10);
                end if;
                if p_option='PIS COMPONENT REGISTER' then
                    lv_sqlstr:=lv_sqlstr||'       ( SELECT * FROM '||LV_TRANS_TABLE|| chr(10);
                end if;
                lv_sqlstr:=lv_sqlstr||'          WHERE COMPANYCODE = '''||p_companycode||''' AND DIVISIONCODE = '''||p_divisioncode||''' '||chr(10);
                if p_option='MASTER ASSIGNMENT' then
                    lv_sqlstr:=lv_sqlstr||'            AND TRANSACTIONTYPE = ''ASSIGNMENT'' '||chr(10);
                end if;
                lv_sqlstr:=lv_sqlstr||'            AND WORKERSERIAL||YEARMONTH IN ( SELECT WORKERSERIAL||MAX(YEARMONTH) '||chr(10);
                if p_option='MASTER ASSIGNMENT' then
                    lv_sqlstr:=lv_sqlstr||'                                               FROM PISCOMPONENTASSIGNMENT  WHERE 1=1'||chr(10);
                end if;
                if p_option='PIS COMPONENT REGISTER' then
                    lv_sqlstr:=lv_sqlstr||'                                               FROM '||LV_TRANS_TABLE||' WHERE 1=1'||chr(10);
                    lv_sqlstr:=lv_sqlstr||'                                               AND YEARMONTH ='''||p_yearmonth||''' '||chr(10);
                  
                    
                end if;
                lv_sqlstr:=lv_sqlstr||'                                              AND COMPANYCODE = '''||p_companycode||''' AND DIVISIONCODE = '''||p_divisioncode||''' '||chr(10);
                if p_option='MASTER ASSIGNMENT' then
                    lv_sqlstr:=lv_sqlstr||'                                                AND TRANSACTIONTYPE = ''ASSIGNMENT'' '||chr(10);
                    lv_sqlstr:=lv_sqlstr||'                                                AND YEARMONTH <='''||p_yearmonth||''' '||chr(10);
                end if;
                lv_sqlstr:=lv_sqlstr||'                                              GROUP BY WORKERSERIAL '||chr(10)
                ||'                                           ) '||chr(10);
                
                
                  
                if lv_rpt_opt='ARREAR' then
                    lv_sqlstr:=lv_sqlstr||' AND transactiontype =''ARREAR'' '||chr(10);
                end if;
                lv_sqlstr:=lv_sqlstr||' ) C, COMPANYMAST M, DIVISIONMASTER V '||chr(10)
                ||'WHERE A.COMPANYCODE = C.COMPANYCODE  '||chr(10)
                ||'  AND A.DIVISIONCODE = C.DIVISIONCODE '||chr(10)
                ||'  AND A.WORKERSERIAL = C.WORKERSERIAL  '||chr(10)
                ||'  AND A.COMPANYCODE=M.COMPANYCODE '||chr(10)
                ||'  AND A.COMPANYCODE=V.COMPANYCODE '||chr(10)
                ||'  AND A.DIVISIONCODE=V.DIVISIONCODE '||chr(10)
                ||'  AND A.COMPANYCODE = '''||p_companycode||'''  '||chr(10)
                ||'  AND A.DIVISIONCODE = '''||p_divisioncode||''' '||chr(10);
                if p_component is not null then
                    lv_sqlstr:=lv_sqlstr||'  AND B.COMPONENTCODE IN ('||p_component||') '||chr(10);
                end if;
                
                if p_unitcode is not null then
                    lv_sqlstr:=lv_sqlstr||'  AND C.UNITCODE IN ('||p_unitcode||') '||chr(10);
                end if;
                if p_category is not null then
                    lv_sqlstr:=lv_sqlstr||'  AND C.CATEGORYCODE IN ('||p_category||') '||chr(10);
                end if;
                if p_grade is not null then
                    lv_sqlstr:=lv_sqlstr||'  AND C.GRADECODE IN ('||p_grade||') '||chr(10);
                end if;
                
                
                if lv_rpt_opt='CUSTOMS' AND p_option='PIS COMPONENT REGISTER' then
                    lv_sqlstr:=lv_sqlstr||' ORDER BY A.TOKENNO, B.PRINTSERIAL'||chr(10);
                ELSE
                    lv_sqlstr:=lv_sqlstr||' ORDER BY A.TOKENNO, B.PHASE, B.CALCULATIONINDEX '||chr(10);
                end if;
                
                
    dbms_output.put_line(lv_sqlstr);
    execute  immediate lv_sqlstr;
    
    update GTT_COMPONENTASSINREPORT set
    EX10 = 'SALARY REGISTER REPORT FOR THE MONTH OF '||TO_CHAR(TO_DATE(p_yearmonth,'YYYYMM'),'MON-YYYY')||chr(10)
    where 1=1;

    if lv_rpt_opt='CUSTOMS' AND p_option='PIS COMPONENT REGISTER'  then
    
--    dbms_output.put_line(lv_rpt_opt);

    delete from GTT_COMPONENTASSINREPORT_TMP where 1=1;
    
        FOR C1 IN (
            SELECT TOKENNO, EX1 PRINTSERIAL, EX4 COLHEADER, MAX(COMPONENTCODE) COMPONENTCODE, COUNT(TOKENNO) CNT, SUM(COMPVALUE) COMPVALUE
            FROM GTT_COMPONENTASSINREPORT
            WHERE EX4 IS NOT NULL
            GROUP BY TOKENNO, EX1, EX4
            HAVING COUNT(TOKENNO)>1
        )
        LOOP
            LV_SQLSTR := null;
            LV_SQLSTR := 'insert into GTT_COMPONENTASSINREPORT_TMP (WORKERSERIAL, TOKENNO, EMPLOYEENAME, UNITCODE, CAT_CD, GRD_CD, DEPT_CD, ESINO, PFNO, PENSIONNO, SEX, EMPLOYEESTATUS, DATEOFBIRTH, DATEOFJOIN, DATEOFCONFIRMATION, PFENTITLEDATE, EXTENDEDRETIREDATE, COMPONENTCODE, PHASE, CALCULATIONINDEX, COMPANYNAME, DIVISIONNAME, COMPONENTSHORTNAME, COMPVALUE, PRINTDATE, EX1, EX2, EX3, EX4, EX5, EX6, EX7, EX8, EX9, EX10)';
            LV_SQLSTR := LV_SQLSTR || 'SELECT WORKERSERIAL, TOKENNO, EMPLOYEENAME, UNITCODE, CAT_CD, GRD_CD, DEPT_CD, ESINO, PFNO, PENSIONNO, SEX, '|| CHR(10);
            LV_SQLSTR := LV_SQLSTR || 'EMPLOYEESTATUS, DATEOFBIRTH, DATEOFJOIN, DATEOFCONFIRMATION, PFENTITLEDATE, EXTENDEDRETIREDATE, COMPONENTCODE, '|| CHR(10);
            LV_SQLSTR := LV_SQLSTR || 'PHASE, CALCULATIONINDEX, COMPANYNAME, DIVISIONNAME,'''|| C1.COLHEADER ||''' COMPONENTSHORTNAME,'|| C1.COMPVALUE ||' COMPVALUE, PRINTDATE, '|| CHR(10);
            LV_SQLSTR := LV_SQLSTR || 'EX1, EX2, EX3, EX4, EX5, EX6, EX7, EX8, EX9, EX10 FROM GTT_COMPONENTASSINREPORT A'|| CHR(10);
            LV_SQLSTR := LV_SQLSTR || 'WHERE 1=1'|| CHR(10);
            LV_SQLSTR := LV_SQLSTR || 'AND A.EX1='''||C1.PRINTSERIAL||''''||CHR(10);
            LV_SQLSTR := LV_SQLSTR || 'AND A.COMPONENTCODE='''||C1.COMPONENTCODE||''''|| CHR(10);
            LV_SQLSTR := LV_SQLSTR || 'AND A.TOKENNO='''||C1.TOKENNO||''''|| CHR(10);
            
           
            dbms_output.put_line(lv_sqlstr);
            execute  immediate lv_sqlstr;
            
        END LOOP;
                
        
                
        DELETE FROM GTT_COMPONENTASSINREPORT
        WHERE EX1 IN (
        SELECT DISTINCT EX1 FROM GTT_COMPONENTASSINREPORT_TMP
        );

        INSERT INTO GTT_COMPONENTASSINREPORT_TMP
        SELECT * FROM GTT_COMPONENTASSINREPORT;


        DELETE FROM GTT_COMPONENTASSINREPORT WHERE 1=1;

        INSERT INTO GTT_COMPONENTASSINREPORT
        SELECT * FROM GTT_COMPONENTASSINREPORT_TMP
        ORDER BY TOKENNO, EX1;

        DELETE FROM GTT_COMPONENTASSINREPORT_TMP WHERE 1=1;
        
     

    end if;
         
          
    IF lv_rpt_opt = 'ARREAR' THEN
                
        DELETE FROM GTT_COMPONENTASSINREPORT
        WHERE TOKENNO IN (
            SELECT DISTINCT TOKENNO FROM PISARREARTRANSACTION
            WHERE COMPANYCODE = p_companycode
            AND DIVISIONCODE=p_divisioncode
            AND EFFECT_YEARMONTH=p_yearmonth
            AND NVL(NETSALARY,0) =0
        );
    END IF;       
--                
--CREATE GLOBAL TEMPORARY TABLE GTT_COMPONENTASSINREPORT_TMP as
--select * from gtt_componentassinreport
   -- DELETE FROM gtt_componentassinreport WHERE EX1=0;
end ;
/