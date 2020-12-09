CREATE OR REPLACE procedure NJMCL_WEB.PROC_RPT_ECR
(
  P_COMPANYCODE VARCHAR2,
  P_DIVISIONCODE VARCHAR2,
  P_YEARCODE VARCHAR2,
  P_YEARMONTH VARCHAR2, 
  P_MODULE VARCHAR2 ,
  P_CATEGORYCODE VARCHAR2  
)
as 
--EXEC PROC_RPT_ECR('NJ0001','0002','2020-2021','202009','PIS','')
/******************************************************************************
   NAME:      DEBASREE PAUL
   PURPOSE:   ECR REPORT
   Date :     17.09.2019
   Date :     06.03.2020 by Ujjwal 
   Date :     04.04.2020 by Ujjwal for Contructor report not working 
   Date :     12.10.2020 by Chiranjit for Naihati Jute Mill 

   NOTES:
   Implementing for Gloster Jute Mills 
******************************************************************************/
    
LV_SQLSTR   VARCHAR2(20000);
LV_REPORTHEADER VARCHAR2(250);
LV_YEARMONTH VARCHAR2(250);

lv_FROMDATE VARCHAR2(11);
lv_TODATE VARCHAR2(11);
LV_DIVISION_NEW VARCHAR2(100);
lv_MonthDays    number(3) := 0;
lv_PensionAge_Male  number(2):=0;
lv_PensionAge_Female  number(2):=0;

begin  
    
    BEGIN
        SELECT NVL(SUPERANNUATIONAGEMALE,58), NVL(SUPERANNUATIONAGEFEMALE,55) INTO lv_PensionAge_Male,lv_PensionAge_Female
        FROM WPSWAGESPARAMETER WHERE COMPANYCODE= P_COMPANYCODE AND DIVISIONCODE=P_DIVISIONCODE;
    EXCEPTION 
        WHEN OTHERS THEN
           lv_PensionAge_Male := 58;
           lv_PensionAge_Female := 55;      
    END;

    DELETE FROM  GTT_ECRREPORT;
      
    LV_SQLSTR:='SELECT TO_CHAR(TO_DATE(''' || P_YEARMONTH ||''',''YYYYMM''),''MONTH,YYYY'') FROM DUAL';
        EXECUTE IMMEDIATE LV_SQLSTR into LV_YEARMONTH;
      
    LV_SQLSTR:=   'select to_char(last_day(to_date('''||P_YEARMONTH||''',''yyyymm'')),''dd/mm/yyyy'')   from dual';
      EXECUTE IMMEDIATE LV_SQLSTR INTO  lv_TODATE;  
    LV_SQLSTR:=   'select to_char(trunc(to_date('''||P_YEARMONTH||''',''yyyymm''),''mm''),''dd/mm/yyyy'')   from dual';
      EXECUTE IMMEDIATE LV_SQLSTR into lv_FROMDATE;  
    
    lv_MonthDays := substr(lv_TODATE,1,2);
      
      
    IF P_DIVISIONCODE='0002' AND P_MODULE='PIS' THEN
     LV_DIVISION_NEW:= ' AND A.DIVISIONCODE IN (''0001'',''0002'')' ; 
    ELSE
     LV_DIVISION_NEW:= ' AND A.DIVISIONCODE IN ('''||P_DIVISIONCODE||''')' ; 
    END IF;
    --EXECUTE IMMEDIATE LV_SQLSTR INTO LV_DIVISION_NEW;
  
  
    IF NVL(P_MODULE,'NA')='ALL' THEN
      LV_REPORTHEADER:='ECR Report ' || LV_YEARMONTH ||' (WPS AND PIS AND CON)';
    ELSE
      LV_REPORTHEADER:='ECR Report ' || LV_YEARMONTH ||' ('||P_MODULE ||')';
    END IF;
  
    LV_SQLSTR:= ' INSERT INTO GTT_ECRREPORT (' ||CHR(10)
    ------ START CHANGES LOGIC AS PER SEND ON 17.10.2020 --------
--            ||' SERIAL_NO, COMPANYCODE,COMPANYNAME,DIVISIONCODE,DIVISIONNAME,UANNO,TOKENNO, WORKERNAME, PENSIONNO, PFNO,GROSSWAGES, PF_GROSS,PENSION_GROSS, DLI_GROSS, PENSION_CONTRIBUTION,EPF_EE,EE_REFUND,NCPDAYS , ' ||CHR(10)
            || 'SERIAL_NO, COMPANYCODE,COMPANYNAME,DIVISIONCODE,DIVISIONNAME,UANNO,TOKENNO, WORKERNAME, PENSIONNO, PFNO, GROSSWAGES,  PF_GROSS,  PENSION_GROSS, '||CHR(10)
            ||'  DLI_GROSS,  PENSION_CONTRIBUTION,  EPF_EE, EE_REFUND,NCPDAYS , '||CHR(10) 
------ END CHANGES LOGIC AS PER SEND ON 17.10.2020 --------
            ||' DOL,REASON,  WAGE_ARR, EE_ARR,ER_ARR,EPS_ARR, PFCATEGORY,AADHARNO,MODULE, REPORTHEADER ,PRINDATE, EX1, EX2, EX3, EX4 ) ' ||CHR(10)
            
            ||' SELECT SERIAL_NO, X.COMPANYCODE,C.COMPANYNAME,X.DIVISIONCODE,D.DIVISIONNAME,UANNO,TOKENNO, WORKERNAME, PENSIONNO, PFNO,ROUND(GROSSWAGES,0) GROSSWAGES, ' ||CHR(10)
            ||' ROUND(PF_GROSS,0) PF_GROSS,ROUND(PENSION_GROSS,0) PENSION_GROSS,ROUND(DLI_GROSS,0) DLI_GROSS,ROUND(ROUND(PENSION_GROSS,0) * 8.33/100,0) PENSION_CONTRIBUTION,' ||CHR(10)
            ||' 0 EPF_EE, 0 EE_REFUND,NCPDAYS , ' ||CHR(10) 
            ||' TO_CHAR(DOL,''DD/MM/YYYY'') DOL, CASE WHEN  DOL IS NOT NULL THEN REASON ELSE NULL END REASON,  WAGE_ARR, EE_ARR,ER_ARR,EPS_ARR, PFCATEGORY,AADHARNO,MODULE,  ' ||CHR(10)
            ||' '''||LV_REPORTHEADER||''' ,TO_CHAR(SYSDATE,''DD/MM/YYYY'') PRONTDATE,0 EX1,'''' EX2,'''' EX3,'''' EX4 ' ||CHR(10)
            ||' FROM ' ||CHR(10)
            ||' ( ' ||CHR(10);
    IF P_MODULE='WPS' OR P_MODULE='ALL' THEN
        LV_SQLSTR:=LV_SQLSTR||'     SELECT 0 SERIAL_NO,B.COMPANYCODE,B.DIVISIONCODE,B.UANNO, B.TOKENNO, WORKERNAME, PENSIONNO, PFNO, B.DATEOFBIRTH, SUM(NVL(GROSS_WAGES,0)) GROSSWAGES, SUM(NVL(PF_GROSS,0)) PF_GROSS, ' ||CHR(10) 
                ||'     CASE WHEN SUM(NVL(PENSION_GROSS,0)) >=15000 THEN 15000 ELSE SUM(NVL(PENSION_GROSS,0)) END PENSION_GROSS, CASE WHEN SUM(NVL(PF_GROSS,0)) >= 15000 THEN 15000 ELSE SUM(NVL(PF_GROSS,0)) END DLI_GROSS, SUM(NVL(FPF,0)) AS PENSION_CONTRIBUTION,0 EPF_EE,0 EE_REFUND, ' ||CHR(10)
                ||'     CASE WHEN ROUND(((SUM(NVL(ATTENDANCEHOURS,0)+NVL(NS_HRS_PFLINK,0)+NVL(HOLIDAYHOURS,0)+NVL(STLHOURS,0))))/8,0) >= '||lv_MonthDays||' THEN 0 '||chr(10)
                ||'     ELSE '||chr(10)     
                ||'       '||lv_MonthDays||' - ROUND(((SUM(NVL(ATTENDANCEHOURS,0)+NVL(NS_HRS_PFLINK,0)+NVL(HOLIDAYHOURS,0)+NVL(STLHOURS,0))))/8,0) '||chr(10)
--                ||'     CASE WHEN SUM(PF_GROSS)>=15000 THEN 0 ' ||CHR(10) 
--                ||'          WHEN SUM(NVL(ATTENDANCEHOURS,0)+NVL(NIGHTALLOWANCEHOURS,0)+NVL(HOLIDAYHOURS,0)+NVL(STLHOURS,0)) >208 THEN 0 ' ||CHR(10) 
--                ||'     ELSE TO_NUMBER(TO_CHAR(TO_DATE('''||lv_TODATE||''',''DD/MM/YYYY''),''DD'')) - ROUND(((SUM(NVL(ATTENDANCEHOURS,0)+NVL(NIGHTALLOWANCEHOURS,0)+NVL(HOLIDAYHOURS,0)+NVL(STLHOURS,0))))/8,0)    ' ||CHR(10)
                ||'     END NCPDAYS, ' ||CHR(10)
                ||'     B.DATEOFTERMINATIONADVICE DOL, ' ||CHR(10)
                ||'     CASE WHEN B.DATEOFTERMINATIONADVICE IS NULL OR B.DATEOFTERMINATIONADVICE > TO_DATE('''||lv_TODATE||''',''DD/MM/YYYY'') THEN '''' ' ||CHR(10) 
                ||'     ELSE   WORKERSTATUS  ' ||CHR(10)
                ||'     END REASON,  ' ||CHR(10)
                ||'     0 WAGE_ARR, 0 EE_ARR, 0 ER_ARR, 0 EPS_ARR,        ' ||CHR(10)
                ||'     CASE WHEN  B.PFAPPLICABLE=''Y'' AND B.EPFAPPLICABLE=''Y'' THEN ''2''       ' ||CHR(10)
                ||'          WHEN  B.PFAPPLICABLE=''Y'' AND B.EPFAPPLICABLE=''N'' THEN ''1''      ' ||CHR(10)
                ||'          ELSE ''3''      ' ||CHR(10)
                ||'     END AS PFCATEGORY,               ' ||CHR(10)
                ||'     B.ADHARCARDNO AADHARNO,''WPS'' MODULE ' ||CHR(10)
                ||'     FROM (  ' ||CHR(10)
                ||'             SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL,NVL(GROSS_WAGES,0) GROSS_WAGES, NVL(PF_GROSS,0) PF_GROSS, NVL(PENSION_GROSS,0) PENSION_GROSS, NVL(FPF,0) FPF, NVL(PF_CONT,0) PF_CONT,  ' ||CHR(10)
                ||'             NVL(ATTENDANCEHOURS,0) ATTENDANCEHOURS, NVL(NS_HRS_PFLINK,0) NS_HRS_PFLINK, NVL(HOLIDAYHOURS,0) HOLIDAYHOURS, 0 STLHOURS  ' ||CHR(10)
                ||'             FROM WPSWAGESDETAILS_MV   ' ||CHR(10)
                ||'             WHERE COMPANYCODE= '''||P_COMPANYCODE||''' AND DIVISIONCODE='''||P_DIVISIONCODE||'''  ' ||CHR(10)
                ||'               AND YEARCODE ='''||P_YEARCODE||'''   ' ||CHR(10)
                ||'               AND FORTNIGHTSTARTDATE >= TO_DATE('''||lv_FROMDATE||''',''DD/MM/YYYY'') AND FORTNIGHTENDDATE <=  TO_DATE('''||lv_TODATE||''',''DD/MM/YYYY'')  ' ||CHR(10)
                ||'             UNION ALL  ' ||CHR(10)
                ||'             SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL,NVL(STLAMOUNT,0) GROSS_WAGES, NVL(PF_GROSS,0) PF_GROSS, NVL(STLAMOUNT,0) PENSION_GROSS, NVL(FPF,0) FPF, NVL(PF_E,0) PF_CONT,  ' ||CHR(10)
                ||'             0 ATTENDANCEHOURS, 0 NS_HRS_PFLINK, 0 HOLIDAYHOURS, NVL(STLHOURS,0) STLHOURS  ' ||CHR(10)
                ||'             FROM WPSSTLWAGESDETAILS  ' ||CHR(10)
                ||'             WHERE COMPANYCODE= '''||P_COMPANYCODE||''' AND DIVISIONCODE='''||P_DIVISIONCODE||''' ' ||CHR(10)
                ||'               AND YEARCODE ='''||P_YEARCODE||'''  ' ||CHR(10)
                ||'               AND PAYMENTDATE >= TO_DATE('''||lv_FROMDATE||''',''DD/MM/YYYY'') AND PAYMENTDATE <=  TO_DATE('''||lv_TODATE||''',''DD/MM/YYYY'') ' ||CHR(10)
                ||'          ) A, WPSWORKERMAST B  ' ||CHR(10)
                
--                ||'     FROM WPSWAGESDETAILS_MV A, WPSWORKERMAST B ' ||CHR(10)
                ||'     WHERE A.WORKERSERIAL (+)= B.WORKERSERIAL ' ||CHR(10)
                ||'         AND B.WORKERCATEGORYCODE NOT IN (''A'',''O'',''R'') '||CHR(10)               ---- RETIRED CATEGORY WORKER NOT DISPLAY IN THE REPORT
                ||'         AND B.DATEOFJOINING <= TO_DATE('''||lv_TODATE||''',''DD/MM/YYYY'') '||CHR(10)
                ||'         AND (B.DATEOFTERMINATION IS NULL OR B.DATEOFTERMINATION >= TO_DATE('''||lv_FROMDATE||''',''DD/MM/YYYY''))'||CHR(10);
--                ||'       AND A.YEARCODE='''||P_YEARCODE||''' ' ||CHR(10)
--                ||'       AND A.COMPANYCODE='''||P_COMPANYCODE||''' ' ||CHR(10);
--                ||'     '|| LV_DIVISION_NEW ||'   ' ||CHR(10);
    if P_CATEGORYCODE is not null then   
             LV_SQLSTR:=LV_SQLSTR|| '     AND B.WORKERCATEGORYCODE IN ('||P_CATEGORYCODE||')    ' ||CHR(10); 
    end if;             
--    LV_SQLSTR:=LV_SQLSTR||'     AND A.FORTNIGHTSTARTDATE >= TO_DATE('''||lv_FROMDATE||''',''DD/MM/YYYY'') AND A.FORTNIGHTENDDATE <=  TO_DATE('''||lv_TODATE||''',''DD/MM/YYYY'')' ||CHR(10)
--      LV_SQLSTR:=LV_SQLSTR||'     AND PFNO IS NOT NULL          ' ||CHR(10);
      LV_SQLSTR:=LV_SQLSTR||'     AND PFMEMBERSHIPDATE<=TO_DATE('''||lv_TODATE||''',''DD/MM/YYYY'') ' ||CHR(10)
                ||'     AND (PFSETTELMENTDATE IS NULL OR PFSETTELMENTDATE >TO_DATE('''||lv_TODATE||''',''DD/MM/YYYY'')) ' ||CHR(10)                        
                ||'     GROUP BY B.COMPANYCODE,B.DIVISIONCODE,B.UANNO, B.TOKENNO, WORKERNAME, PENSIONNO, PFNO, B.DATEOFBIRTH,B.PFCATEGORY,B.ADHARCARDNO,B.DATEOFTERMINATIONADVICE,WORKERSTATUS,B.PFAPPLICABLE,B.EPFAPPLICABLE  ' ||CHR(10);
--                ||'     HAVING SUM(PF_CONT) > 0 '||CHR(10);
    end if;           
    IF P_MODULE='ALL' THEN
        LV_SQLSTR:=LV_SQLSTR||'     UNION ALL  ' ||CHR(10);
    END IF;               
    IF P_MODULE='ALL' OR P_MODULE='PIS' THEN
    LV_SQLSTR:=LV_SQLSTR||'     SELECT 0 SERIAL_NO,B.COMPANYCODE,B.DIVISIONCODE, B.UANNO, B.TOKENNO, B.EMPLOYEENAME WORKERNAME, B.PENSIONNO, B.PFNO,  B.DATEOFBIRTH, NVL(A.GROSSEARN,0) GROSSWAGES, NVL(A.PF_GROSS,0) PF_GROSS, ' ||CHR(10)
            ||'     CASE WHEN NVL(A.PEN_GROSS,0) >15000 THEN 15000 ELSE NVL(A.PEN_GROSS,0) END PENSION_GROSS, CASE WHEN PF_GROSS >= 15000 THEN 15000 ELSE PF_GROSS END DLI_GROSS, NVL(A.FPF,0) PENSION_CONTRIBUTION,0 EPF_EE,0 EE_REFUND, ' ||CHR(10)
            ||'     /*CASE WHEN NVL(PF_GROSS,0)>=15000 THEN 0  ELSE CASE WHEN (ATTN_CALCF - ATTN_SALD)>0 THEN  (ATTN_CALCF - ATTN_SALD) ELSE 0 END END ELSE 0 END END*/ ATTN_WPAY   NCPDAYS,  ' ||CHR(10)
--            ||'     B.STATUSDATE DOL, ' ||CHR(10)
            ||'     CASE WHEN B.STATUSDATE >= TO_DATE('''||lv_FROMDATE||''',''DD/MM/YYYY'') AND B.STATUSDATE <=  TO_DATE('''||lv_TODATE||''',''DD/MM/YYYY'')  THEN B.STATUSDATE ELSE NULL END DOL, '||CHR(10)
            ||'     CASE WHEN B.STATUSDATE IS NULL OR B.STATUSDATE > TO_DATE('''||lv_TODATE||''',''DD/MM/YYYY'') THEN '''' ' ||CHR(10) 
            ||'     ELSE   EMPLOYEESTATUS  ' ||CHR(10)
            ||'     END REASON, ' ||CHR(10)
            ||'     0 WAGE_ARR, 0 EE_ARR, 0 ER_ARR, 0 EPS_ARR, ' ||CHR(10) 
            ||'     CASE WHEN  B.PFAPPLICABLE=''Y'' AND B.EPFAPPLICABLE=''Y'' THEN ''2''       ' ||CHR(10)
            ||'          WHEN  B.PFAPPLICABLE=''Y'' AND B.EPFAPPLICABLE=''N'' THEN ''1''      ' ||CHR(10)
            ||'     ELSE ''3''      ' ||CHR(10)
            ||'     END AS PFCATEGORY,               ' ||CHR(10)
            ||'     B.AADHARNO,''PIS'' MODULE ' ||CHR(10)
            ||'     FROM PISPAYTRANSACTION A, PISEMPLOYEEMASTER B ' ||CHR(10)
            ||'     WHERE A.WORKERSERIAL (+)= B.WORKERSERIAL ' ||CHR(10)
            ||'       AND A.YEARCODE='''||P_YEARCODE||''' ' ||CHR(10)
            ||'       AND A.COMPANYCODE='''||P_COMPANYCODE||''' ' ||CHR(10)
            ||'       AND B.DATEOFCONFIRMATION <= TO_DATE('''||lv_TODATE||''',''DD/MM/YYYY'') '||CHR(10)
            ||'       AND (B.STATUSDATE IS NULL OR B.STATUSDATE >= TO_DATE('''||lv_FROMDATE||''',''DD/MM/YYYY'')) '||CHR(10);
--            ||'       '|| LV_DIVISION_NEW ||'   ' ||CHR(10)    ;
                
    if P_CATEGORYCODE is not null then   
        LV_SQLSTR:=LV_SQLSTR||'       AND B.CATEGORYCODE IN ('||P_CATEGORYCODE||')    ' ||CHR(10); 
    end if;       
    LV_SQLSTR:=LV_SQLSTR||'       AND A.YEARMONTH>=  TO_NUMBER(TO_CHAR(TO_DATE('''||lv_FROMDATE||''',''DD/MM/YYYY''),''YYYYMM'')) AND A.YEARMONTH<=TO_NUMBER(TO_CHAR(TO_DATE('''||lv_TODATE||''',''DD/MM/YYYY''),''YYYYMM'')) ' ||CHR(10)
--            ||'       AND PF_E>0 AND PFNO IS NOT NULL   ' ||CHR(10) 
--            ||'       AND PFENTITLEDATE<=TO_DATE('''||lv_TODATE||''',''DD/MM/YYYY'')  AND (PFSETTELMENTDATE IS NULL OR PFSETTELMENTDATE >TO_DATE('''||lv_TODATE||''',''DD/MM/YYYY''))  ' ||CHR(10) 
            ||'     /*GROUP BY B.COMPANYCODE,B.DIVISIONCODE,B.UANNO, B.TOKENNO, B.EMPLOYEENAME, PENSIONNO, PFNO, ' ||CHR(10)
            ||'              B.AADHARNO,B.STATUSDATE,B.EMPLOYEESTATUS,A.ATTN_WPAY, A.ATTN_SALD,B.PFAPPLICABLE,B.EPFAPPLICABLE,PF_GROSS */ ' ||CHR(10);
    end if;           
    IF P_MODULE='ALL' THEN
        LV_SQLSTR:=LV_SQLSTR||'     UNION ALL  ' ||CHR(10);
    END IF;               
    IF P_MODULE='ALL' OR P_MODULE='CON' THEN           
    LV_SQLSTR:=LV_SQLSTR||'     SELECT  0 SERIAL_NO,B.COMPANYCODE,B.DIVISIONCODE, B.UANNO,TOKENNO, /*B.SUBCONTRACTORNO,*/ B.SUBCONTRACTORNAME WORKERNAME, B.PENSIONNO, B.PFNO,  B.DATEOFBIRTH, ' ||CHR(10)
            ||'     SUM(NVL(A.GROSS_EARN,0)) GROSSWAGES, SUM(NVL(A.PFGROSS,0)) PF_GROSS,                          ' ||CHR(10)
            ||'     SUM(NVL(A.PENSIONGROSS,0)) PENSION_GROSS,  CASE WHEN PFGROSS >= 15000 THEN 15000 ELSE PFGROSS END DLI_GROSS, SUM(NVL(A.EPF,0)) PENSION_CONTRIBUTION,0 EPF_EE,0 EE_REFUND,  ' ||CHR(10)
            ||'     CASE WHEN SUM(PFGROSS)>=15000 THEN 0   ' ||CHR(10)
            ||'          WHEN A.SALARYDAYS >=26 THEN 0   ' ||CHR(10)
            ||'          ELSE (26 - A.SALARYDAYS)            ' ||CHR(10)
            ||'     END NCPDAYS,  ' ||CHR(10)
            ||'     B.STATUSDATE DOL,  ' ||CHR(10)
            ||'     CASE WHEN B.STATUSDATE IS NULL OR B.STATUSDATE > TO_DATE('''||lv_TODATE||''',''DD/MM/YYYY'') THEN ''''  ' ||CHR(10)
            ||'     ELSE   EMPLOYEESTATUS   ' ||CHR(10)
            ||'     END REASON,  ' ||CHR(10)
            ||'     0 WAGE_ARR, 0 EE_ARR, 0 ER_ARR, 0 EPS_ARR,  ' ||CHR(10)
            ||'     CASE WHEN  B.PFAPPLICABLE=''Y'' AND B.PENSIONAPPLICABLE=''Y'' THEN ''2''        ' ||CHR(10)
            ||'          WHEN  B.PFAPPLICABLE=''Y'' AND B.PENSIONAPPLICABLE=''N'' THEN ''1''       ' ||CHR(10)
            ||'     ELSE ''3''       ' ||CHR(10)
            ||'     END AS PFCATEGORY,                ' ||CHR(10)
            ||'     B.ADHARCARDNO AADHARNO,''CON'' MODULE  ' ||CHR(10) 
            ||'     FROM CONWAGESDETAILS A, WPSSUBCONTRACTORMASTER B  ' ||CHR(10)
            ||'     WHERE A.WORKERSERIAL=B.WORKERSERIAL  ' ||CHR(10)             
            ||'       AND A.COMPANYCODE='''||P_COMPANYCODE||''' ' ||CHR(10)
            ||'       '|| LV_DIVISION_NEW ||'   ' ||CHR(10)  ;  
      if P_CATEGORYCODE is not null then   
         LV_SQLSTR:=LV_SQLSTR||'       AND B.CATEGORYCODE IN ('||P_CATEGORYCODE||')    ' ||CHR(10); 
      end if;      
      LV_SQLSTR:=LV_SQLSTR||'       AND A.YEARCODE='''||P_YEARCODE||'''  ' ||CHR(10)
                ||'       AND A.YEARMONTH=  TO_CHAR(TO_DATE('''||lv_FROMDATE||''',''DD/MM/YYYY''),''YYYYMM'')' ||CHR(10)
                ||'       AND A.YEARMONTH<=TO_NUMBER(TO_CHAR(TO_DATE('''||lv_TODATE||''',''DD/MM/YYYY''),''YYYYMM'')) ' ||CHR(10) ;           
     LV_SQLSTR:=LV_SQLSTR||'       AND PF_E>0 AND PFNO IS NOT NULL   ' ||CHR(10)
                ||'       AND PFJOINDATE<=TO_DATE('''||lv_TODATE||''',''DD/MM/YYYY'')         ' ||CHR(10)
                ||'       AND (PFSETTLEMENTDATE IS NULL OR PFSETTLEMENTDATE >TO_DATE('''||lv_TODATE||''',''DD/MM/YYYY''))  ' ||CHR(10)
                ||'       ' ||CHR(10)
                ||'     GROUP BY YEARMONTH,B.COMPANYCODE,B.DIVISIONCODE,B.UANNO, B.SUBCONTRACTORNO, B.SUBCONTRACTORNAME, PENSIONNO, PFNO,TOKENNO, B.DATEOFBIRTH, ' ||CHR(10)
                ||'          B.ADHARCARDNO,B.STATUSDATE,B.EMPLOYEESTATUS,A.SALARYDAYS ,B.PFAPPLICABLE,B.PENSIONAPPLICABLE,PFGROSS ' ||CHR(10);
    end if;                                            
    LV_SQLSTR:=LV_SQLSTR||' ) X, COMPANYMAST C,DIVISIONMASTER D' ||CHR(10)
            ||' WHERE X.COMPANYCODE=C.COMPANYCODE' ||CHR(10)
            ||'   AND X.COMPANYCODE=D.COMPANYCODE' ||CHR(10)   
            ||'   AND X.DIVISIONCODE=D.DIVISIONCODE' ||CHR(10)
            ||'   AND ROUND(MONTHS_BETWEEN(TO_DATE('''||lv_TODATE||''',''DD/MM/YYYY''),DATEOFBIRTH)/12,6)<= '||lv_PensionAge_Male||' '||CHR(10);       -- AGE CONDITION ADD ON 22.10.2020

     dbms_output.put_line(lv_sqlstr);
     EXECUTE IMMEDIATE LV_SQLSTR;   
    
END;
/