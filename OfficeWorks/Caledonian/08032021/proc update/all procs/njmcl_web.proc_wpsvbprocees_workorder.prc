DROP PROCEDURE NJMCL_WEB.PROC_WPSVBPROCEES_WORKORDER;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PROC_WPSVBPROCEES_WORKORDER" (P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2,
                                                  P_USERNAME Varchar2, 
                                                  P_YEARCODE Varchar2,
                                                  P_FNSTDT Varchar2, 
                                                  P_FNENDT Varchar2,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL
                                                  )
AS
lv_fn_stdt DATE := TO_DATE(P_FNSTDT,'DD/MM/YYYY');
lv_fn_endt DATE := TO_DATE(P_FNENDT,'DD/MM/YYYY');
lv_TableName        varchar2(50);
lv_Remarks          varchar2(1000) := 'Occupation wise basic rate';
lv_SqlStr           varchar2(4000);
lv_AttnComponent    varchar2(4000) := ''; 
lv_CompWithZero     varchar2(1000) := '';
lv_CompWithValue    varchar2(4000) := '';
lv_CompCol          varchar2(1000) := '';
lv_SQLCompView      varchar2(4000) := '';
lv_parvalues        varchar2(500) := P_FNENDT||'-'||P_FNENDT;
lv_sqlerrm          varchar2(500) := '';
lv_WorkerSerial     varchar2(10) := '';
lv_TokenNo          varchar2(10) := '';
lv_AttnHrs          number := 0;
lv_OtHrs            number := 0;
lv_DueAttnHrs       number := 0;
lv_DueOTHrs         number := 0;
lv_AttnDate         date := TO_DATE(P_FNSTDT,'DD/MM/YYYY');
BEGIN


    DELETE FROM WPSVBDETAILS WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
      AND FORTNIGHTSTARTDATE = TO_DATE(P_FNSTDT,'DD/MM/YYYY')
      AND FORTNIGHTENDDATE = TO_DATE(P_FNENDT,'DD/MM/YYYY');
    COMMIT;
 
            
            
lv_SqlStr := ' INSERT INTO WPSVBDETAILS (COMPANYCODE, DIVISIONCODE, PRODUCTIONDATE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE,  '||CHR(10) 
        ||' DEPARTMENTCODE, PRODUCTIONTYPE, SHIFTCODE, WORKERSERIAL, TOKENNO, WORKTYPECODE, OCCUPATIONCODE,  '||CHR(10) 
        ||' QUALITYCODE, MAINQUALITYCODE, QUALITYRATE, MACHINECODE, LOOMCODE, PRODUCTIONHOURS, PRODUCTION,  '||CHR(10) 
        ||' VBRATE,VBAMOUNT , LINENO, HELPERNO, SARDERNO, LINETAG, DEPTOCCPCODE,LASTMODIFIED) '||CHR(10) 
        
        ||' SELECT '''||P_COMPCODE||'''  COMPANYCODE, '''||P_DIVCODE||''' DIVISIONCODE, NULL PRODUCTIONDATE, TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')  FORTNIGHTSTARTDATE,  '||CHR(10) 
        ||'         TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')  FORTNIGHTENDDATE, NULL DEPARTMENTCODE, NULL PRODUCTIONTYPE, NULL SHIFTCODE,  '||CHR(10) 
        ||'         WORKERSERIAL, TOKENNO, NULL WORKTYPECODE, NULL OCCUPATIONCODE, NULL QUALITYCODE, NULL MAINQUALITYCODE,  '||CHR(10) 
        ||'         NULL QUALITYRATE, NULL MACHINECODE,  NULL  LOOMCODE, 0 PRODUCTIONHOURS,  NULL  PRODUCTION,  '||CHR(10) 
        ||'         0 VBRATE, SUM(VBAMOUNT) VBAMOUNT,  NULL  LINENO,  NULL  HELPERNO,  NULL  SARDERNO,  NULL  LINETAG,  NULL  DEPTOCCPCODE, SYSDATE LASTMODIFIED FROM  '||CHR(10) 
        ||' (  '||CHR(10) 
        ||' SELECT  FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, A.WORKERSERIAL,A.TOKENNO, /* A.WORKERTYPECODE,*/   '||CHR(10) 
        ||'         A.DEPARTMENTCODE,A.OCCUPATIONCODE,SUM(NVL(ATTENDANCEHOURS,0)) ATTENDANCEHOURS, '||CHR(10) 
        ||'         RATE VBRATE ,SUM(NVL(ATTENDANCEHOURS,0))* DECODE(NVL(C.FIXEDBASIC,0),0,NVL(RATE,0),NVL(C.FIXEDBASIC,0)) VBAMOUNT '||CHR(10)
        ||'         -- SHIFTCODE,SPELLTYPE,DATEOFATTENDANCE, WORKERCATEGORYCODE,  '||CHR(10) 
        ||' FROM WPSATTENDANCEDAYWISE A,WPSOCCUPATIONMAST B,WPSWORKERMAST C  '||CHR(10) 
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
        ||'   AND A.DATEOFATTENDANCE >= TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')  '||CHR(10)
        ||'   AND A.DATEOFATTENDANCE <= TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')  '||CHR(10)
        ||'   AND A.WORKERCATEGORYCODE IN (''PRM'',''SPL'',''CSL'') '||CHR(10)
        ||'   AND A.COMPANYCODE=B.COMPANYCODE  '||CHR(10) 
        ||'   AND A.DIVISIONCODE=B.DIVISIONCODE  '||CHR(10) 
        ||'   AND A.OCCUPATIONCODE=B.OCCUPATIONCODE  '||CHR(10) 
        ||'   AND A.DEPARTMENTCODE=B.DEPARTMENTCODE  '||CHR(10) 
        ||'   /* AND A.WORKERTYPECODE=B.WORKERTYPECODE */ '||CHR(10)
        
        ||'   AND A.COMPANYCODE=C.COMPANYCODE  '||CHR(10) 
        ||'   AND A.DIVISIONCODE=C.DIVISIONCODE  '||CHR(10)
        ||'   AND A.WORKERSERIAL=C.WORKERSERIAL  '||CHR(10) 
        --||'   --AND B.WORKERTYPECODE='''P''' '||CHR(10) 
        ||'   AND NVL(ATTENDANCEHOURS,0)>0  '||CHR(10) 
        --||'   --AND A.TOKENNO='SP7268'  '||CHR(10) 
        ||' GROUP BY A.WORKERSERIAL,A.TOKENNO,A.DEPARTMENTCODE,A.OCCUPATIONCODE,/*A.WORKERTYPECODE,*/  '||CHR(10) 
        ||'         --SHIFTCODE,SPELLTYPE,DATEOFATTENDANCE,WORKERCATEGORYCODE,  '||CHR(10) 
        ||'         A.FORTNIGHTSTARTDATE, A.FORTNIGHTENDDATE,RATE,NVL(C.FIXEDBASIC,0) '||CHR(10)  
        ||' HAVING SUM(NVL(ATTENDANCEHOURS,0))*NVL(RATE,0) >0  '||CHR(10) 
        ||' ) GROUP BY WORKERSERIAL, TOKENNO  '||CHR(10)  ;  
    --dbms_output.put_line (lv_SqlStr);
    insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSVBPROCEES_WORKORDER',lv_sqlerrm,SYSDATE,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
                              
    execute immediate lv_SqlStr;
    COMMIT;
    
    lv_SqlStr := ' INSERT INTO WPSVBDETAILS (COMPANYCODE, DIVISIONCODE, PRODUCTIONDATE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE,  '||CHR(10) 
        ||' DEPARTMENTCODE, PRODUCTIONTYPE, SHIFTCODE, WORKERSERIAL, TOKENNO, WORKTYPECODE, OCCUPATIONCODE,  '||CHR(10) 
        ||' QUALITYCODE, MAINQUALITYCODE, QUALITYRATE, MACHINECODE, LOOMCODE, PRODUCTIONHOURS, PRODUCTION,  '||CHR(10) 
        ||' VBRATE,ADDLBASIC , LINENO, HELPERNO, SARDERNO, LINETAG, DEPTOCCPCODE,LASTMODIFIED) '||CHR(10) 
        
        ||' SELECT '''||P_COMPCODE||'''  COMPANYCODE, '''||P_DIVCODE||''' DIVISIONCODE, NULL PRODUCTIONDATE, TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')  FORTNIGHTSTARTDATE,  '||CHR(10) 
        ||'         TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')  FORTNIGHTENDDATE, NULL DEPARTMENTCODE, NULL PRODUCTIONTYPE, NULL SHIFTCODE,  '||CHR(10) 
        ||'         WORKERSERIAL, TOKENNO, NULL WORKTYPECODE, NULL OCCUPATIONCODE, NULL QUALITYCODE, NULL MAINQUALITYCODE,  '||CHR(10) 
        ||'         NULL QUALITYRATE, NULL MACHINECODE,  NULL  LOOMCODE, 0 PRODUCTIONHOURS,  NULL  PRODUCTION,  '||CHR(10) 
        ||'         0 VBRATE, SUM(ADDLBASIC) ADDLBASIC,  NULL  LINENO,  NULL  HELPERNO,  NULL  SARDERNO,  NULL  LINETAG,  NULL  DEPTOCCPCODE, SYSDATE LASTMODIFIED FROM  '||CHR(10) 
        ||' (  '||CHR(10) 
        ||' SELECT  FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, A.WORKERSERIAL,A.TOKENNO, /* A.WORKERTYPECODE,*/   '||CHR(10) 
        ||'         A.DEPARTMENTCODE,A.OCCUPATIONCODE,SUM(NVL(ATTENDANCEHOURS,0)) ATTENDANCEHOURS, '||CHR(10) 
        ||'         NVL(ADDLBASIC_RATE,0.3195) ADDLBASIC_RATE ,SUM(NVL(ATTENDANCEHOURS,0))*  NVL(ADDLBASIC_RATE,0.3195) ADDLBASIC '||CHR(10)
        ||'         -- SHIFTCODE,SPELLTYPE,DATEOFATTENDANCE, WORKERCATEGORYCODE,  '||CHR(10) 
        ||' FROM WPSATTENDANCEDAYWISE A,WPSOCCUPATIONMAST B,WPSWORKERMAST C  '||CHR(10) 
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
        ||'   AND A.DATEOFATTENDANCE >= TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')  '||CHR(10)
        ||'   AND A.DATEOFATTENDANCE <= TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')  '||CHR(10)
        ||'   AND A.WORKERCATEGORYCODE IN (''PRM'',''SPL'',''CSL'') '||CHR(10)
        ||'   AND B.WORKERTYPECODE IN (''P'') '||CHR(10)
        ||'   AND A.COMPANYCODE=B.COMPANYCODE  '||CHR(10) 
        ||'   AND A.DIVISIONCODE=B.DIVISIONCODE  '||CHR(10) 
        ||'   AND A.OCCUPATIONCODE=B.OCCUPATIONCODE  '||CHR(10) 
        ||'   AND A.DEPARTMENTCODE=B.DEPARTMENTCODE  '||CHR(10) 
        --||'   AND A.WORKERTYPECODE=B.WORKERTYPECODE  '||CHR(10)
        ||'   AND A.COMPANYCODE=C.COMPANYCODE  '||CHR(10) 
        ||'   AND A.DIVISIONCODE=C.DIVISIONCODE  '||CHR(10)
        ||'   AND A.WORKERSERIAL=C.WORKERSERIAL  '||CHR(10) 
        --||'   --AND B.WORKERTYPECODE='''P''' '||CHR(10) 
        ||'   AND NVL(ATTENDANCEHOURS,0)>0  '||CHR(10) 
        --||'   --AND A.TOKENNO='SP7268'  '||CHR(10) 
        ||' GROUP BY A.WORKERSERIAL,A.TOKENNO,A.DEPARTMENTCODE,A.OCCUPATIONCODE,/*A.WORKERTYPECODE,*/  '||CHR(10) 
        ||'         --SHIFTCODE,SPELLTYPE,DATEOFATTENDANCE,WORKERCATEGORYCODE,  '||CHR(10) 
        ||'         A.FORTNIGHTSTARTDATE, A.FORTNIGHTENDDATE,RATE,NVL(ADDLBASIC_RATE,0.3195) '||CHR(10)  
        ||' HAVING SUM(NVL(ATTENDANCEHOURS,0))*NVL(ADDLBASIC_RATE,0.3195) >0  '||CHR(10) 
        ||' ) GROUP BY WORKERSERIAL, TOKENNO  '||CHR(10)  ; 
        
        --dbms_output.put_line (lv_SqlStr);
    insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSVBPROCEES_WORKORDER',lv_sqlerrm,SYSDATE,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
    execute immediate lv_SqlStr;
    COMMIT;
    
    lv_SqlStr := ' INSERT INTO WPSVBDETAILS (COMPANYCODE, DIVISIONCODE,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE,LASTMODIFIED,WORKERSERIAL,TOKENNO,HRS_RATE)  '||CHR(10)
        ||' SELECT DISTINCT '''||P_COMPCODE||'''  COMPANYCODE, '''||P_DIVCODE||''' DIVISIONCODE, TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')  FORTNIGHTSTARTDATE,TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')  FORTNIGHTENDDATE, SYSDATE LASTMODIFIED,  '||CHR(10)  
        ||'        A.WORKERSERIAL,A.TOKENNO,NVL(A.INCREMENTAMOUNT,0)/208 + NVL(A.ADDLBASIC_RATE,0) +  '||CHR(10) 
        ||'        DECODE(B.WORKERTYPECODE,''P'',NVL(B.RATE,0),''T'',0)  '||CHR(10) 
        ||'        +NVL(A.DAILYBASICRATE,0)+NVL(A.DARATE,0)/208   HRS_RATE    '||CHR(10)   
        ||'   FROM WPSWORKERMAST A,WPSOCCUPATIONMAST B, ( (SELECT WORKERSERIAL '||CHR(10) 
        ||'                                            FROM WPSSTLENTRY '||CHR(10) 
        ||'                                           WHERE COMPANYCODE='''||P_COMPCODE||''' '||CHR(10) 
        ||'                                             AND DIVISIONCODE='''||P_DIVCODE||''' '||CHR(10) 
        ||'                                             AND LEAVECODE = ''STL'' '||CHR(10)
        ||'                                             AND FORTNIGHTSTARTDATE=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')    '||CHR(10)  
        ||'                                             AND FORTNIGHTENDDATE=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') '||CHR(10) 
        ||'                                             GROUP BY WORKERSERIAL  '||CHR(10) 
        ||'                                             HAVING SUM(NVL(STLHOURS,0))>0 '||CHR(10) 
        ||'                                          MINUS '||CHR(10) 
        ||'                                          SELECT WORKERSERIAL '||CHR(10) 
        ||'                                            FROM WPSATTENDANCEDAYWISE '||CHR(10) 
        ||'                                           WHERE COMPANYCODE='''||P_COMPCODE||''' '||CHR(10) 
        ||'                                             AND DIVISIONCODE='''||P_DIVCODE||''' '||CHR(10) 
        ||'                                             AND DATEOFATTENDANCE>=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')  '||CHR(10)    
        ||'                                             AND DATEOFATTENDANCE<=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') '||CHR(10) 
        ||'                                             GROUP BY WORKERSERIAL  '||CHR(10) 
        ||'                                                HAVING SUM(NVL(ATTENDANCEHOURS,0))>0 '||CHR(10) 
        ||'                                          ) UNION ALL SELECT WORKERSERIAL '||CHR(10) 
        ||'                                            FROM WPSATTENDANCEDAYWISE '||CHR(10) 
        ||'                                           WHERE COMPANYCODE='''||P_COMPCODE||''' '||CHR(10) 
        ||'                                             AND DIVISIONCODE='''||P_DIVCODE||''' '||CHR(10) 
        ||'                                             AND DATEOFATTENDANCE>=TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')  '||CHR(10)    
        ||'                                             AND DATEOFATTENDANCE<=TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'') '||CHR(10) 
        ||'                                             GROUP BY WORKERSERIAL  '||CHR(10) 
        ||'                                             HAVING (SUM(NVL(ATTENDANCEHOURS,0))=0 AND ( SUM(NVL(FBKHOURS,0))>0 OR SUM(NVL(OVERTIMEHOURS,0))>0 OR SUM(NVL(HOLIDAYHOURS,0))>0 ) )'||CHR(10) 
        ||'                                          )C '||CHR(10) 
        ||'WHERE A.COMPANYCODE='''||P_COMPCODE||''' '||CHR(10) 
        ||'  AND A.DIVISIONCODE='''||P_DIVCODE||''' '||CHR(10) 
        ||'  AND A.COMPANYCODE=B.COMPANYCODE '||CHR(10) 
        ||'  AND A.DIVISIONCODE=B.DIVISIONCODE  '||CHR(10) 
        ||'  AND A.DEPARTMENTCODE=B.DEPARTMENTCODE '||CHR(10) 
        ||'  AND A.OCCUPATIONCODE=B.OCCUPATIONCODE '||CHR(10) 
        ||'  AND A.WORKERSERIAL=C.WORKERSERIAL '||CHR(10) ;
    
    lv_remarks:='HRS_RATE CALULATION' ;   
    insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSVBPROCEES_WORKORDER',lv_sqlerrm,SYSDATE,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
    execute immediate lv_SqlStr;
                
exception
when others then
 --insert into error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) values( 'ERROR SQL',lv_sqlstr,lv_sqlstr,lv_parvalues,lv_remarks);
 lv_sqlerrm := sqlerrm ;
 --dbms_output.put_line(lv_sqlerrm);
 insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPSVBPROCEES_WORKORDER',lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);


END ;
/


