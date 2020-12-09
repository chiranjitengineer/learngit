CREATE OR REPLACE procedure NJMCL_WEB.PROC_RPT_PFSTATEMENT
(
  P_COMPANYCODE VARCHAR2,
  P_DIVISIONCODE VARCHAR2,
  P_YEARCODE VARCHAR2,
  P_YEARMONTH VARCHAR2,
--  P_YEARMONTH_FROM VARCHAR2,
  --P_YEARMONTH_TO VARCHAR2,
  P_TOKENNO VARCHAR2 
)
AS 
/******************************************************************************
   NAME:      Ujjwal Malik
   PURPOSE:   PF Statement
   Date :     24.05.2020
   Date :     09.11.2020
  
   NOTES:
   Implementing for Naihati Jute Mills 
******************************************************************************/
    
LV_SQLSTR   VARCHAR2(20000);
LV_REPORTHEADER VARCHAR2(250);
LV_COM VARCHAR2(100);
LV_DIV VARCHAR2(250);
LV_YEARMONTH_FROM VARCHAR2(50);
LV_YEARMONTH_TO VARCHAR2(20);


LV_LASTDAY VARCHAR2(20);

BEGIN  
 
    LV_LASTDAY := TO_CHAR(LAST_DAY(TO_DATE(P_YEARMONTH,'MON-YY')),'DD');
    
    LV_REPORTHEADER:='Monthly PF & FPF Contribution for the Month  : ' || TRIM(P_YEARMONTH);
         
    LV_SQLSTR:='SELECT COMPANYNAME FROM COMPANYMAST WHERE COMPANYCODE= '''||P_COMPANYCODE ||'''' ;
    EXECUTE IMMEDIATE LV_SQLSTR into LV_COM;  
       
    LV_SQLSTR:='SELECT DIVISIONNAME FROM DIVISIONMASTER WHERE COMPANYCODE= '''||P_COMPANYCODE ||''' AND DIVISIONCODE='''||P_DIVISIONCODE||'''' ;
    EXECUTE IMMEDIATE LV_SQLSTR into LV_DIV;    
            
    DELETE FROM  GTT_PFCONTRIBUTION;     
                
    LV_SQLSTR:=   ' INSERT INTO GTT_PFCONTRIBUTION 
     (COMPANYCODE, COMPANYNAME, DIVISIONCODE, DIVISIONNAME, YEARCODE, WORKERTYPE, EMPLOYEECODE, EMPLOYEEPFACCNUMBER, PEN,
     CATEGORYCODE, GRADECODE, PFGROSS, PF_LOAN_CAPITAL, PF_E, PF_C, VPF, PENSIONNO,UANNO,GROSSWAGES,EX2, EMPLOYEENAME, 
     DEPARTMENTCODE, WORKINGDAYS, WITHOUTPAYDAYS, REPORTHEADER, PRINTDATE, EX1,EX3)          ' ||CHR(10)
            
          ||  '   SELECT COMPANYCODE,'''||LV_COM||''' COMPANYNAME, DIVISIONCODE,'''||LV_DIV||''' DIVISIONNAME,YEARCODE,WORKERTYPE, ' ||CHR(10)
          ||  '   WORKERCODE EMPLOYEECODE,PFNO EMPLOYEEPFACCNUMBER,SUM(PEN) PEN, CATEGORYCODE,GRADECODE,SUM(PFGROSS) PFGROSS,  ' ||CHR(10)
          ||  ' SUM(PF_LOAN_CAPITAL) PF_LOAN_CAPITAL,SUM(PF_E) PF_E, SUM(PF_C) PF_C, SUM(VPF) VPF, PENSIONNO, UANNO,GROSSEARN,PEN_GROSS, ' ||CHR(10)
          ||  ' WORKERNAME EMPLOYEENAME, DEPARTMENTCODE, SUM(WORKINGDAYS) WORKINGDAYS, /*SUM(WITHOUTPAYDAYS)*/ CASE WHEN SUM(WORKINGDAYS) >= '||LV_LASTDAY||' THEN 0 ELSE '||LV_LASTDAY||' - SUM(WORKINGDAYS) END WITHOUTPAYDAYS,  ' ||CHR(10)
          ||  ' '''||LV_REPORTHEADER||''' REPORTHEADER, TO_CHAR(SYSDATE,''DD/MM/YYYY'') PRINTDATE,  ' ||CHR(10)
          ||  ' CASE WHEN SUM(NVL(PFGROSS,0))>15000 THEN 15000 ELSE SUM(NVL(PFGROSS,0)) END EX1, TO_CHAR(LAST_DAY(TO_DATE('''||P_YEARMONTH||''',''MON-YY'')),''DD/MM/YYYY'') LASTDAY' ||CHR(10) 
          ||  ' FROM  ' ||CHR(10)
          ||  ' (  ' ||CHR(10)
          ||  ' SELECT A.COMPANYCODE,A.DIVISIONCODE,A.YEARCODE,WORKERCODE,B.PFNO,PEN,CATEGORYCODE,GRADECODE,A.MODULE WORKERTYPE,  ' ||CHR(10)
          ||  ' CASE WHEN SUM(NVL(PFGROSS,0))>15000 AND A.MODULE=''WPS'' THEN 15000 ELSE SUM(NVL(PFGROSS,0)) END PFGROSS,  ' ||CHR(10)
          ||  ' C.PF_LOAN_CAPITAL,PF_E,  PF_C,  VPF, B.PENSIONNO,B.UANNO,GROSSEARN,PEN_GROSS, B.WORKERNAME, B.DEPARTMENTCODE,WORKINGDAYS, WITHOUTPAYDAYS,TOTALEARNING ' ||CHR(10)
          --change 11112020
          --||  ' FROM VW_PFSUMMARYDATA A, VW_WPSPISMASTER B,   ' ||CHR(10)
          ||  ' FROM VW_PFSUMM_DATA_TEMP A, VW_WPSPISMASTER B,   ' ||CHR(10)
          --change 11112020
          ||  ' (  ' ||CHR(10)
          ||  ' SELECT PFNO, SUM(AMOUNT) PF_LOAN_CAPITAL  ' ||CHR(10)
          ||  ' FROM PFLOANBREAKUP  ' ||CHR(10)
          ||  '  WHERE --COMPANYCODE = '''||P_COMPANYCODE||''' AND DIVISIONCODE = '''||P_DIVISIONCODE||'''  ' ||CHR(10)                 
          ||  '  TO_NUMBER(TO_CHAR(PAIDON,''YYYYMM'')) >= TO_NUMBER(TO_CHAR(TO_DATE('''|| P_YEARMONTH||''',''MON-YY''),''YYYYMM''))  ' ||CHR(10)
          ||  ' AND TO_NUMBER(TO_CHAR(PAIDON,''YYYYMM'')) <= TO_NUMBER(TO_CHAR(TO_DATE('''||P_YEARMONTH||''',''MON-YY''),''YYYYMM''))  ' ||CHR(10)
          ||  ' AND TRANSACTIONTYPE =''CAPITAL''  ' ||CHR(10)
          ||  ' AND YEARCODE='''||P_YEARCODE||'''  ' ||CHR(10)
          ||  ' GROUP BY PFNO  ' ||CHR(10)
          ||  ' )  C  ' ||CHR(10)
          ||  ' WHERE TO_NUMBER(A.YEARMONTH) >= TO_NUMBER(TO_CHAR(TO_DATE('''|| P_YEARMONTH||''',''MON-YY''),''YYYYMM''))  ' ||CHR(10)
          ||  '   AND TO_NUMBER(A.YEARMONTH) <= TO_NUMBER(TO_CHAR(TO_DATE('''|| P_YEARMONTH||''',''MON-YY''),''YYYYMM''))  ' ||CHR(10)
          ||  ' AND A.COMPANYCODE='''||P_COMPANYCODE||'''  ' ||CHR(10)
          --||  ' AND A.DIVISIONCODE='''||P_DIVISIONCODE||'''  ' ||CHR(10)
          ||  ' AND A.YEARCODE='''||P_YEARCODE||''' ' ||CHR(10)
          ||  ' AND A.COMPANYCODE=B.COMPANYCODE  ' ||CHR(10)
          ||  ' AND A.DIVISIONCODE=B.DIVISIONCODE  ' ||CHR(10)
          ||  ' AND A.MODULE=B.WORKERTYPE  ' ||CHR(10)
          ||  ' AND A.pfno=B.pfno --A.WORKERSERIAL=B.WORKERSERIAL  ' ||CHR(10)
          ||  ' AND A.PF_E>0  ' ||CHR(10)
          ||  ' AND B.PFNO = C.PFNO (+)  ' ||CHR(10)
          ||  ' GROUP BY A.COMPANYCODE,A.DIVISIONCODE,A.YEARCODE,WORKERCODE,B.PFNO,PEN, CATEGORYCODE,GRADECODE,A.MODULE, C.PF_LOAN_CAPITAL,PF_E,PF_C,  ' ||CHR(10)  
          ||  ' VPF,PENSIONNO, UANNO,GROSSEARN,PEN_GROSS,WORKERNAME , DEPARTMENTCODE,WORKINGDAYS, WITHOUTPAYDAYS,TOTALEARNING  ' ||CHR(10)                
          ||  ' )  ' ||CHR(10) ;
          
          if P_TOKENNO is not null then
            LV_SQLSTR:= LV_SQLSTR || ' where WORKERCODE  in ('||P_TOKENNO||')';
          end if;
          
          LV_SQLSTR:= LV_SQLSTR ||  ' GROUP BY COMPANYCODE,DIVISIONCODE,YEARCODE,WORKERTYPE,WORKERCODE ,PFNO , CATEGORYCODE,GRADECODE, WORKERNAME , DEPARTMENTCODE,TOTALEARNING,PENSIONNO,UANNO,GROSSEARN,PEN_GROSS  ' ||CHR(10)
          ||  ' ORDER BY WORKERCODE  ' ||CHR(10);        
        
     
     DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);     
     EXECUTE IMMEDIATE LV_SQLSTR;
    
END;
/
