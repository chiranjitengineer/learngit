CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_ELCTY_BILL_OSTNDG
--exec PROC_ELCTY_BILL_OSTNDG('NJ0001','0002','01/08/2020','15/08/2020','''04925''','')
(
p_companycode    varchar2,
p_divisioncode   varchar2,
p_fromdate       varchar2,
p_todate         varchar2,
p_tokenno        varchar2,
p_status         varchar2 DEFAULT 'ALL'
)
as
/******************************************************************************
   NAME:      Ujjwal
   PURPOSE:   Electricity Bill Outstanding   
   Date :     26.08.2020
   Date :     30.08.2020
   Date :     12.10.2020
  
   NOTES:
   Implementing for Naihati Jute Mills 
******************************************************************************/  
lv_sqlstr varchar2(4000 byte);
lv_printon varchar2(400 byte);

lv_table varchar2(40 byte);
lv_gbl_table varchar2(40 byte);
lv_companyname varchar2(40 byte);

lv_fortnightstartdate varchar2(10 byte);
lv_fortnightenddate varchar2(10 byte);

lv_active number;
lv_alloted number;
lv_count number;

lv_sqlerrm          varchar2(500) := ''; 
lv_remarks          varchar2(500) := 'Electricity Bill Outstanding'; 
lv_parvalues        varchar2(500) := ''; 
lv_ProcName         varchar2(500) := 'PROC_ELCTY_BILL_OSTNDG'; 
begin
    
select companyname into lv_companyname from companymast where companycode=p_companycode;

select to_char(max(FORTNIGHTSTARTDATE),'dd/mm/yyyy'), to_char(max(FORTNIGHTENDDATE),'dd/mm/yyyy') into lv_fortnightstartdate, lv_fortnightenddate from wpswagedperioddeclaration
where FORTNIGHTSTARTDATE<=to_date(''||p_todate||'','dd/mm/yyyy');

lv_printon :=''||p_todate||''; 

delete from GTT_ELECTRICBILL_OUTSTANDING;
delete from  GTT_ELECTRIC_OUTTEMP;   

--PROC_ELECBLNC_WITH_BILL_EMI(p_companycode,p_divisioncode,to_char(to_date(lv_fortnightstartdate,'dd-mon-yy'),'dd/mm/yyyy'),to_char(to_date(lv_fortnightenddate,'dd-mon-yy'),'dd/mm/yyyy'),'','WPS','NO');
PROC_ELECBLNC_WITH_BILL_EMI(p_companycode,p_divisioncode,p_todate,p_todate,'','WPS','NO');

--dbms_output.put_line(p_companycode||'-'||p_divisioncode||'-'||lv_fortnightstartdate||'-'||lv_fortnightenddate);

select count(*) into lv_count from ELECTRICMETERREADING where fortnightenddate=to_date(lv_fortnightenddate,'dd/mm/yyyy');

if lv_count>0 then
     lv_sqlstr:=' insert into GTT_ELECTRIC_OUTTEMP 
    (BILLAMOUNT, ELECTRICITY, BWORSRL, COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, QUARTERNO, TOTALBILLDAYS, 
    FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, CONTRIBUTIONAMOUNT, EMIAMOUNT,READINGFROMDATE, READINGTODATE)              

             SELECT A.BILLAMOUNT,B.ELECTRICITY, a.WORKERSERIAL bworsrl,   a.COMPANYCODE, a.DIVISIONCODE, a.WORKERSERIAL, a.TOKENNO, 
            QUARTERNO,  TOTALBILLDAYS, a.FORTNIGHTSTARTDATE, a.FORTNIGHTENDDATE, CONTRIBUTIONAMOUNT, EMIAMOUNT,READINGFROMDATE, READINGTODATE  
            FROM ELECTRICMETERREADING A,WPSWAGESDETAILS_MV B
            WHERE 1=1
              AND A.COMPANYCODE='''||p_companycode||''' 
              AND A.DIVISIONCODE='''||p_divisioncode||''' 
              AND A.FORTNIGHTENDDATE=TO_DATE('''||p_todate||''',''DD/MM/YYYY'')  
              AND A.COMPANYCODE=B.COMPANYCODE(+)
              AND A.DIVISIONCODE=B.DIVISIONCODE(+)
              AND A.WORKERSERIAL=B.WORKERSERIAL(+)
              AND A.FORTNIGHTSTARTDATE=B.FORTNIGHTSTARTDATE(+)
              AND A.FORTNIGHTENDDATE= B.FORTNIGHTENDDATE(+)   ';
              
else
   lv_sqlstr:=' insert into GTT_ELECTRIC_OUTTEMP 
    (BILLAMOUNT, ELECTRICITY, BWORSRL, COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, QUARTERNO, TOTALBILLDAYS, 
    FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, CONTRIBUTIONAMOUNT, EMIAMOUNT,READINGFROMDATE, READINGTODATE)              

             SELECT A.BILLAMOUNT,B.ELECTRICITY, B.WORKERSERIAL bworsrl,   a.COMPANYCODE, a.DIVISIONCODE, a.WORKERSERIAL, a.TOKENNO, 
            QUARTERNO,  TOTALBILLDAYS, a.FORTNIGHTSTARTDATE, a.FORTNIGHTENDDATE, CONTRIBUTIONAMOUNT, EMIAMOUNT,READINGFROMDATE, READINGTODATE  
            FROM ELECTRICMETERREADING A,WPSWAGESDETAILS_MV B
              WHERE 1=1
              AND b.COMPANYCODE='''||p_companycode||''' 
              AND b.DIVISIONCODE='''||p_divisioncode||''' 
              AND nvl(B.FORTNIGHTENDDATE,A.FORTNIGHTENDDATE)=TO_DATE('''||lv_fortnightenddate||''',''DD/MM/YYYY'')  
              AND A.COMPANYCODE(+)=B.COMPANYCODE
              AND A.DIVISIONCODE(+)=B.DIVISIONCODE
              AND A.WORKERSERIAL(+)=B.WORKERSERIAL
              AND A.FORTNIGHTSTARTDATE(+)=B.FORTNIGHTSTARTDATE
              AND A.FORTNIGHTENDDATE(+)= B.FORTNIGHTENDDATE ';
end if;

   dbms_output.put_line(lv_sqlstr);      
    execute immediate(lv_sqlstr);

   
lv_sqlstr:='INSERT INTO GTT_ELECTRICBILL_OUTSTANDING
            (QRTLINENO, QUARTERNO, TOKENNO, WORKERNAME, BALANCE_OS, PERIODFROM, PERIODTO, BILLAMOUNT, TOTALAMT, INSTALLMENTAMT, 
            STATUS, SUPERANNUATIONDATE, GRATIOTYPAIDDATE, COMPANYNAME,ELECTRICITY)
                

SELECT SUBSTR(NVL(A.QUARTERNO,C.QUARTER),1,2) QRTLINENO, SUBSTR(NVL(A.QUARTERNO,C.QUARTER),4,4)QUARTERNO, B.TOKENNO, WORKERNAME, 
            nvl(fn_PreviousAmount(b.companycode,b.divisioncode,b.workerserial,'''||lv_fortnightstartdate||''','''||lv_fortnightenddate||'''),0) BALANCE_OS ,
            to_char(READINGFROMDATE,''MON'')  PERIODFROM,
             to_char(READINGTODATE,''MON'')  PERIODTO, 
            A.BILLAMOUNT,           
            nvl(fn_PreviousAmount(b.companycode,b.divisioncode,b.workerserial,'''||lv_fortnightstartdate||''','''||lv_fortnightenddate||'''),0)+NVL(A.BILLAMOUNT,0)-NVL(A.ELECTRICITY,0) TOTALAMT,
            CASE WHEN A.BILLAMOUNT>0 THEN A.EMIAMOUNT ELSE C.ELEC_EMI_AMT END INSTALLMENTAMT, 
            fnWorkerStatus(b.workerserial, nvl(c.quarter,0)) STATUS,
            -- change 12.10.2020 
            --to_char(DATEOFTERMINATIONADVICE,''dd/mm/yyyy'') SUPERANNUATIONDATE,
            --to_char(GRATUITYSETTELMENTDATE,''dd/mm/yyyy'') GRATIOTYPAIDDATE, 
            --to_char(DATEOFTERMINATION,''dd/mm/yyyy'') SUPERANNUATIONDATE,             
            CASE WHEN DATEOFTERMINATION<=TO_DATE('''|| p_todate || ''',''DD/MM/YYYY'') THEN to_char(DATEOFTERMINATION,''dd/mm/yyyy'') ELSE NULL END SUPERANNUATIONDATE,                       
            to_char(GRATUITYPAYMENTDATE,''dd/mm/yyyy'') GRATIOTYPAIDDATE,             
            -- end change 
            '''||lv_companyname||''' COMPANYNAME, A.ELECTRICITY
            FROM GBL_ELECBLNC C, WPSWORKERMAST B,
            ( 
            
--            SELECT A.*,B.ELECTRICITY FROM ELECTRICMETERREADING A,WPSWAGESDETAILS_MV B
--            WHERE 1=1
--              AND A.COMPANYCODE='''||p_companycode||''' 
--              AND A.DIVISIONCODE='''||p_divisioncode||''' 
--              AND A.FORTNIGHTENDDATE=TO_DATE('''||p_todate||''',''DD/MM/YYYY'')  
--              AND A.COMPANYCODE=B.COMPANYCODE(+)
--              AND A.DIVISIONCODE=B.DIVISIONCODE(+)
--              AND A.WORKERSERIAL=B.WORKERSERIAL(+)
--              AND A.FORTNIGHTSTARTDATE=B.FORTNIGHTSTARTDATE(+)
--              AND A.FORTNIGHTENDDATE= B.FORTNIGHTENDDATE(+)    

--              SELECT A.*,B.ELECTRICITY, B.WORKERSERIAL bworsrl FROM ELECTRICMETERREADING A,WPSWAGESDETAILS_MV B
--              WHERE 1=1
--              AND b.COMPANYCODE='''||p_companycode||''' 
--              AND b.DIVISIONCODE='''||p_divisioncode||''' 
--              AND nvl(B.FORTNIGHTENDDATE,A.FORTNIGHTENDDATE)=TO_DATE('''||lv_fortnightenddate||''',''DD/MM/YYYY'')  
--              AND A.COMPANYCODE(+)=B.COMPANYCODE
--              AND A.DIVISIONCODE(+)=B.DIVISIONCODE
--              AND A.WORKERSERIAL(+)=B.WORKERSERIAL
--              AND A.FORTNIGHTSTARTDATE(+)=B.FORTNIGHTSTARTDATE
--              AND A.FORTNIGHTENDDATE(+)= B.FORTNIGHTENDDATE  
                
                select * from GTT_ELECTRIC_OUTTEMP
            ) A
            WHERE 1=1
              AND C.WORKERSERIAL=B.WORKERSERIAL
--              AND C.WORKERSERIAL=A.WORKERSERIAL(+)   
                AND C.WORKERSERIAL=A.bworsrl(+) ';
                
--            -------------
--            SELECT SUBSTR(NVL(A.QUARTERNO,C.QUARTER),1,2) QRTLINENO, SUBSTR(NVL(A.QUARTERNO,C.QUARTER),4,4)QUARTERNO, B.TOKENNO, WORKERNAME, 
--            nvl(fn_PreviousAmount(b.companycode,b.divisioncode,b.workerserial,'16/05/2020','31/05/2020'),0) BALANCE_OS ,
--            to_char(READINGFROMDATE,'MON')  PERIODFROM,
--            to_char(READINGTODATE,'MON')  PERIODTO, 
--            A.BILLAMOUNT,           
--            nvl(fn_PreviousAmount(b.companycode,b.divisioncode,b.workerserial,'16/05/2020','31/05/2020'),0)+NVL(A.BILLAMOUNT,0)-NVL(BB.ELECTRICITY,0) TOTALAMT,
--            CASE WHEN A.BILLAMOUNT>0 THEN A.EMIAMOUNT ELSE C.ELEC_EMI_AMT END INSTALLMENTAMT, 
--            fnWorkerStatus(b.workerserial, nvl(c.quarter,0)) STATUS, 
--            to_char(DATEOFTERMINATIONADVICE,'dd/mm/yyyy') SUPERANNUATIONDATE,
--            to_char(GRATUITYSETTELMENTDATE,'dd/mm/yyyy') GRATIOTYPAIDDATE, 'THE NAIHATI JUTE MILLS  COMPANY LTD.' COMPANYNAME, BB.ELECTRICITY
--            FROM GBL_ELECBLNC C, WPSWORKERMAST B,
--            (
--            SELECT * FROM ELECTRICMETERREADING A
--            WHERE 1=1
--            AND A.COMPANYCODE='NJ0001' 
--            AND A.DIVISIONCODE='0002' 
--            AND A.FORTNIGHTENDDATE=TO_DATE('15/07/2020','DD/MM/YYYY')   
--            ) A,
--            (
--            SELECT WORKERSERIAL,ELECTRICITY FROM 
--            WPSWAGESDETAILS_MV
--            WHERE 1=1
--            AND COMPANYCODE='NJ0001' 
--            AND DIVISIONCODE='0002' 
--            AND FORTNIGHTENDDATE=TO_DATE('15/07/2020','DD/MM/YYYY')  
--            )BB
--            WHERE 1=1
--            AND C.WORKERSERIAL=B.WORKERSERIAL
--            AND C.WORKERSERIAL=A.WORKERSERIAL(+)
--            AND C.WORKERSERIAL=BB.WORKERSERIAL(+)  
--            -------------
            
            if p_status <>'ALL' then   
                lv_sqlstr:=lv_sqlstr|| '  and fnWorkerStatus(b.workerserial, C.QUARTER)='''||p_status||''' ';
            end if;

            if p_tokenno is not null then 
                lv_sqlstr:=lv_sqlstr||'  AND A.TOKENNO IN('||p_tokenno||')'||chr(10);
            end if;            
       
    --sql error msg
    lv_sqlerrm := ''; --sqlerrm ;    
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS)
    values( P_COMPANYCODE, P_DIVISIONCODE, lv_ProcName,lv_sqlerrm, LV_SQLSTR, lv_parvalues,TO_DATE(p_todate,'DD/MM/YYYY'),TO_DATE(p_todate,'DD/MM/YYYY'),lv_remarks);
    --end sql error msg        
                       
    dbms_output.put_line(lv_sqlstr);      
    execute immediate(lv_sqlstr);
             
    UPDATE GTT_ELECTRICBILL_OUTSTANDING SET SUMTOTAL=(SELECT SUM(NVL(TOTALAMT,0)) FROM GTT_ELECTRICBILL_OUTSTANDING);        
    UPDATE GTT_ELECTRICBILL_OUTSTANDING SET BALANCETOTAL=(SELECT SUM(NVL(BALANCE_OS,0)) FROM GTT_ELECTRICBILL_OUTSTANDING);      
    
     --change 12102020 - ujjwal     
    UPDATE GTT_ELECTRICBILL_OUTSTANDING SET BILLAMOUNTTOTAL=(SELECT SUM(NVL(BILLAMOUNT,0)) FROM GTT_ELECTRICBILL_OUTSTANDING);
    UPDATE GTT_ELECTRICBILL_OUTSTANDING SET PAIDAMOUNTTOTAL=(SELECT SUM(NVL(ELECTRICITY,0)) FROM GTT_ELECTRICBILL_OUTSTANDING);
    --end change         
      
END;
/
