DROP PROCEDURE NJMCL_WEB.PROC_WPSFORTNIGHT_SUMMARY_1;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PROC_WPSFORTNIGHT_SUMMARY_1" 
(
    p_companycode varchar2,
    p_divisioncode varchar2,
    p_yearcode      varchar2,
    p_fromdt varchar2,
    p_todt varchar2,
    p_MaxHrs varchar2
)
as 
    lv_sqlstr           varchar2(20000);
begin
    delete from GTT_FORTNIGHTATTENDANCE;
lv_sqlstr :=    ' insert into GTT_FORTNIGHTATTENDANCE '||CHR(10)
        ||' SELECT '''||p_fromdt||''' FROMDT,'''||p_todt||''' TODT, D.COMPANYNAME, A.TOKENNO EBNO, A.WORKERNAME, null AS W_K_T_Y, NULL LINENO, NULL AS MCH, A.OCCUPATIONCODE OCC, SUM(ATTENDANCEHOURS) HRS_WK_1, 0 HRS_WK_2, '||CHR(10) 
        ||' SUM(NVL(NIGHTALLOWANCEHOURS,0)) NS_HRS, SUM(HOLIDAYHOURS) FESTIVAL_HRS, SUM(O_T_HRS) O_T__HRS, 0 LAY_OFF_HRS, '||CHR(10) 
        ||' null STL_DAYS, null STL_WG_ADV, null DEDN_ADJ_CD, null DEDN_ADJ_AMT_3_2, null INC_ADJ_CD, null INC_ADJ_AMT_3_2, '||CHR(10) 
        ||' null PRD_QL_CD, null PRO_QTY, null TAG, '||CHR(10) 
        ||' A.DEPARTMENTCODE DEPT, DECODE(A.SHIFTCODE,''1'',''A'',DECODE(A.SHIFTCODE,''2'',''B'',''C'')) SHIFT,'''' FBKHOURS  '||CHR(10) 
        ||' FROM  COMPANYMAST D, '||CHR(10)
        ||' ( '||CHR(10)
        ||'   SELECT A.COMPANYCODE, A.TOKENNO, B.WORKERNAME, XX.DEPARTMENTCODE,  XX.SHIFTCODE, A.OCCUPATIONCODE, '||CHR(10) 
        ||'   SUM(ATTENDANCEHOURS) ATTENDANCEHOURS,  '||CHR(10)
        ||'   SUM(NVL(NIGHTALLOWANCEHOURS,0)) NIGHTALLOWANCEHOURS, SUM(HOLIDAYHOURS) HOLIDAYHOURS, 0 O_T_HRS '||CHR(10)
        ||'   FROM WPSATTENDANCEDAYWISE A, WPSWORKERMAST B, /*WPSMACHINELINEMAPPING C,*/ '||CHR(10) 
        ||'      ( '||CHR(10)
        ||'         SELECT A.WORKERSERIAL, A.DEPARTMENTCODE, MIN(SHIFTCODE) SHIFTCODE '||CHR(10) 
        ||'         FROM WPSATTENDANCEDAYWISE A, '||CHR(10) 
        ||'         ( '||CHR(10) 
        ||'            SELECT WORKERSERIAL, DEPARTMENTCODE, MIN(DATEOFATTENDANCE) DATEOFATTENDANCE '||CHR(10) 
        ||'            FROM WPSATTENDANCEDAYWISE A '||CHR(10) 
        ||'            WHERE A.COMPANYCODE = '''||p_companycode||''' '||CHR(10)   
        ||'              AND A.DIVISIONCODE = '''||p_divisioncode||''' '||CHR(10)   
        ||'              AND A.DATEOFATTENDANCE >= TO_DATE('''|| p_fromdt ||''',''DD/MM/YYYY'') '||CHR(10)   
        ||'              AND A.DATEOFATTENDANCE <= TO_DATE('''||p_todt||''',''DD/MM/YYYY'') '||CHR(10) 
        ||'              AND (NVL(A.ATTENDANCEHOURS,0)+NVL(A.HOLIDAYHOURS,0)) >0 '||CHR(10)
        ||'            GROUP BY A.WORKERSERIAL, A.DEPARTMENTCODE '||CHR(10)   
        ||'        ) B '||CHR(10) 
        ||'        WHERE A.COMPANYCODE = '''||p_companycode||'''  '||CHR(10)   
        ||'          AND A.DIVISIONCODE = '''||p_divisioncode||''' '||CHR(10)   
        ||'          AND A.DATEOFATTENDANCE = B.DATEOFATTENDANCE '||CHR(10) 
        ||'          AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10) 
        ||'          AND A.DEPARTMENTCODE = B.DEPARTMENTCODE '||CHR(10)
        ||'          AND (NVL(A.ATTENDANCEHOURS,0)+NVL(A.HOLIDAYHOURS,0)) >0 '||CHR(10)
        ||'        GROUP BY A.WORKERSERIAL, A.DEPARTMENTCODE '||CHR(10) 
        ||'      ) XX '||CHR(10) 
        ||'  WHERE A.COMPANYCODE = '''||p_companycode||''' AND A.DIVISIONCODE = '''||p_divisioncode||''' '||CHR(10) 
        ||'  AND A.YEARCODE = '''||p_yearcode||''' '||CHR(10) 
        ||'  AND A.DATEOFATTENDANCE BETWEEN TO_DATE('''||p_fromdt||''',''DD/MM/YYYY'') '||CHR(10) 
        ||'                          AND TO_DATE('''||p_todt||''',''DD/MM/YYYY'') '||CHR(10) 
        ||'  AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10) 
        ||'  /*AND A.DEPARTMENTCODE = C.DEPARTMENTCODE (+) AND NVL(A.MACHINECODE1,''NA'') = C.MACHINECODE (+) */'||CHR(10)
        ||'  AND A.WORKERSERIAL = XX.WORKERSERIAL AND A.DEPARTMENTCODE = XX.DEPARTMENTCODE '||CHR(10)
        ||'  AND (NVL(A.ATTENDANCEHOURS,0)+NVL(A.HOLIDAYHOURS,0)) >0 '||CHR(10);
        
        IF NVL(p_MaxHrs,0)>0 THEN /* ADDED ON 17/12/2016 */
            lv_sqlstr :=lv_sqlstr || 'AND A.WORKERSERIAL IN (SELECT DISTINCT WORKERSERIAL FROM WPSATTENDANCEDAYWISE '||CHR(10)
                    ||'            WHERE COMPANYCODE = '''||p_companycode||''' '||CHR(10)   
                    ||'              AND DIVISIONCODE = '''||p_divisioncode||''' '||CHR(10)   
                    ||'              AND DATEOFATTENDANCE >= TO_DATE('''|| p_fromdt ||''',''DD/MM/YYYY'') '||CHR(10)   
                    ||'              AND DATEOFATTENDANCE <= TO_DATE('''||p_todt||''',''DD/MM/YYYY'') '||CHR(10)
                    ||'              GROUP BY WORKERSERIAL HAVING  SUM(NVL(ATTENDANCEHOURS,0))>'||TO_NUMBER(p_MaxHrs)||')  '||CHR(10) ;
        END IF;
        
lv_sqlstr :=lv_sqlstr ||'  GROUP BY A.COMPANYCODE,A.TOKENNO, B.WORKERNAME, /*C.LINENO, A.MACHINECODE1,*/ A.OCCUPATIONCODE, XX.DEPARTMENTCODE, XX.SHIFTCODE '||CHR(10)
        ||'  UNION ALL '||CHR(10)
        ||'  SELECT A.COMPANYCODE, A.TOKENNO, B.WORKERNAME, A.DEPARTMENTCODE,  A.SHIFTCODE, A.OCCUPATIONCODE,'||CHR(10) 
        ||'  0 ATTENDANCEHOURS, 0 NIGHTALLOWANCEHOURS, 0  HOLIDAYHOURS, SUM(OVERTIMEHOURS) O_T_OTHRS '||CHR(10)     
        ||'  FROM WPSATTENDANCEDAYWISE A, WPSWORKERMAST B /*, WPSMACHINELINEMAPPING W*/ '||CHR(10)  
        ||'  WHERE A.COMPANYCODE = '''||p_companycode||''' '||CHR(10)   
        ||'    AND A.DIVISIONCODE = '''||p_divisioncode||''' '||CHR(10)
        ||'    AND A.YEARCODE = '''||p_yearcode||''' '||CHR(10)   
        ||'    AND A.DATEOFATTENDANCE >= TO_DATE('''||p_fromdt||''',''DD/MM/YYYY'') '||CHR(10)   
        ||'    AND A.DATEOFATTENDANCE <= TO_DATE('''||p_todt||''',''DD/MM/YYYY'') '||CHR(10) 
        ||'    AND NVL(A.OVERTIMEHOURS,0)  > 0 '||CHR(10)
        ||'    AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
        ||'    /*AND A.DEPARTMENTCODE = W.DEPARTMENTCODE (+) AND NVL(A.MACHINECODE1,''NA'') = W.MACHINECODE (+) */'||CHR(10);
      
         IF NVL(p_MaxHrs,0)>0 THEN
            lv_sqlstr :=lv_sqlstr || 'AND A.WORKERSERIAL IN (SELECT DISTINCT WORKERSERIAL FROM WPSATTENDANCEDAYWISE '||CHR(10)
                    ||'            WHERE COMPANYCODE = '''||p_companycode||''' '||CHR(10)   
                    ||'              AND DIVISIONCODE = '''||p_divisioncode||''' '||CHR(10)   
                    ||'              AND DATEOFATTENDANCE >= TO_DATE('''|| p_fromdt ||''',''DD/MM/YYYY'') '||CHR(10)   
                    ||'              AND DATEOFATTENDANCE <= TO_DATE('''||p_todt||''',''DD/MM/YYYY'') '||CHR(10)
                    ||'              GROUP BY WORKERSERIAL HAVING  SUM(NVL(ATTENDANCEHOURS,0))>'||TO_NUMBER(p_MaxHrs)||')  '||CHR(10) ;
        END IF;
         
lv_sqlstr :=lv_sqlstr ||'  GROUP BY A.COMPANYCODE, A.TOKENNO, B.WORKERNAME, A.DEPARTMENTCODE, A.SHIFTCODE, /*W.LINENO, A.MACHINECODE1,*/ A.OCCUPATIONCODE, A.SHIFTCODE '||CHR(10)
        ||' ) A '||CHR(10)
        ||' WHERE A.COMPANYCODE = D.COMPANYCODE '||CHR(10)
        ||' GROUP BY D.COMPANYNAME, A.TOKENNO, A.WORKERNAME, /*A.LINENO, A.MACHINECODE1,*/ A.OCCUPATIONCODE, A.DEPARTMENTCODE, A.SHIFTCODE '||CHR(10)
        ||' ORDER BY A.DEPARTMENTCODE, A.SHIFTCODE, A.TOKENNO,/* A.LINENO, A.MACHINECODE1,*/ '||CHR(10) 
        ||' SUBSTR(A.OCCUPATIONCODE, 1, 2) '||CHR(10);   

 --dbms_output.put_line(lv_sqlstr);
   execute immediate lv_sqlstr;
   UPDATE GTT_FORTNIGHTATTENDANCE A SET OCC = (SELECT A.OCC||B.WORKERTYPECODE FROM WPSOCCUPATIONMAST B
   WHERE A.DEPT = B.DEPARTMENTCODE AND A.OCC=B.OCCUPATIONCODE);
   COMMIT;
   
   
   UPDATE GTT_FORTNIGHTATTENDANCE A
   SET  STL_DAYS = (
                   SELECT SUM(NVL(STLHOURS,0))/8
                     FROM WPSSTLENTRY B
                    WHERE B.FORTNIGHTENDDATE=TO_DATE(p_todt,'DD/MM/YYYY')
                   GROUP BY WORKERSERIAL,TOKENNO
                   HAVING SUM(NVL(STLHOURS,0))/8>0 AND TRIM(A.EBNO)=B.TOKENNO);
    COMMIT;                   
                      
    UPDATE GTT_FORTNIGHTATTENDANCE A
    SET STL_DAYS=0
    WHERE ROWID<(SELECT MAX(ROWID) FROM GTT_FORTNIGHTATTENDANCE B
                   WHERE A.EBNO=B.EBNO AND NVL(STL_DAYS,0)>0);
    COMMIT;
    
     
    UPDATE GTT_FORTNIGHTATTENDANCE A
   SET (FBKHOURS,LAY_OFF_HRS,DEDN_ADJ_AMT_3_2,INC_ADJ_AMT_3_2)=
   (SELECT SUM(NVL(FBKHOURS,0)) FBKHOURS, SUM(NVL(LAYOFFHOURS,0)) LAYOFFHOURS,
           SUM(NVL(SHIBCO_DEDN,0)) SHIBCO_DEDN,SUM(NVL(NPF_ADJ,0)) NPF_ADJ
     FROM WPSATTENDANCEDAYWISE B
     WHERE COMPANYCODE = p_companycode   
       AND DIVISIONCODE = p_divisioncode 
       AND DATEOFATTENDANCE >= TO_DATE(p_fromdt,'DD/MM/YYYY')   
       AND DATEOFATTENDANCE <= TO_DATE(p_todt,'DD/MM/YYYY')
       GROUP BY WORKERSERIAL,TOKENNO HAVING (SUM(NVL(FBKHOURS,0))>0 OR SUM(NVL(LAYOFFHOURS,0))>0 
                                          OR SUM(NVL(SHIBCO_DEDN,0))>0 OR SUM(NVL(NPF_ADJ,0))>0)  
                                        AND TRIM(A.EBNO)=B.TOKENNO); 
     COMMIT;
     
    UPDATE GTT_FORTNIGHTATTENDANCE A
    SET FBKHOURS=0
    WHERE ROWID<(SELECT MAX(ROWID) FROM GTT_FORTNIGHTATTENDANCE B
                   WHERE A.EBNO=B.EBNO 
                   AND NVL(A.FBKHOURS,0)>0);
    
    
    UPDATE GTT_FORTNIGHTATTENDANCE A
    SET LAY_OFF_HRS=0
    WHERE ROWID<(SELECT MAX(ROWID) FROM GTT_FORTNIGHTATTENDANCE B
                   WHERE A.EBNO=B.EBNO 
                   AND NVL(A.LAY_OFF_HRS,0)>0);  
                   
                   
                   
    UPDATE GTT_FORTNIGHTATTENDANCE A
    SET DEDN_ADJ_AMT_3_2=0
    WHERE ROWID<(SELECT MAX(ROWID) FROM GTT_FORTNIGHTATTENDANCE B
                   WHERE A.EBNO=B.EBNO 
                   AND NVL(A.DEDN_ADJ_AMT_3_2,0)>0);  


    UPDATE GTT_FORTNIGHTATTENDANCE A
    SET INC_ADJ_AMT_3_2=0
    WHERE ROWID<(SELECT MAX(ROWID) FROM GTT_FORTNIGHTATTENDANCE B
                   WHERE A.EBNO=B.EBNO 
                   AND NVL(A.INC_ADJ_AMT_3_2,0)>0);  
                                                             
                   
    COMMIT;                                                             
             -------------------FOR STL HOURS---------------
    lv_sqlstr := 'Insert into GTT_FORTNIGHTATTENDANCE' || CHR(10)
               ||' (FROMDT, TODT, COMPANYNAME, EBNO, WORKERNAME, ' || CHR(10)
               ||'        W_K_T_Y, LINENO, MCH, OCC, HRS_WK_1, ' || CHR(10)
               ||'        HRS_WK_2, NS_HRS, FESTIVAL_HRS, O_T__HRS, LAY_OFF_HRS, ' || CHR(10)
               ||'        STL_DAYS, STL_WG_ADV, DEDN_ADJ_CD, DEDN_ADJ_AMT_3_2, INC_ADJ_CD, ' || CHR(10)
               ||'        INC_ADJ_AMT_3_2, PRD_QL_CD, PRO_QTY, TAG, DEPT, ' || CHR(10)
               ||'        SHIFT, FBKHOURS)        ' || CHR(10)
               ||'     (' || CHR(10)
               ||'       SELECT '''||p_fromdt||''', '''||p_todt||''', C.COMPANYNAME, B.TOKENNO, E.WORKERNAME, ' || CHR(10)
               ||'             '''' , '''' , '''' , B.OCCUPATIONCODE, 0, ' || CHR(10)
               ||'               0, 0, 0, 0, 0, ' || CHR(10)
               ||'               SUM(STLHOURS)/8 STL_DAYS, 0 STL_WG_ADV, 0, 0, 0, ' || CHR(10)
               ||'               0, '''', 0, '''', B.DEPARTMENTCODE, ' || CHR(10)
               ||'               B.SHIFTCODE, 0' || CHR(10)
               ||'        FROM   WPSSTLENTRY B ,COMPANYMAST C,WPSWORKERMAST E' || CHR(10)
               ||'       WHERE  B.FORTNIGHTENDDATE = TO_DATE ('''||p_todt||''', ''DD/MM/YYYY'') ' || CHR(10)
               ||'         AND NVL(LEAVECODE,''STL'')=''STL''   ' || CHR(10)
               ||'         AND B.COMPANYCODE=C.COMPANYCODE' || CHR(10)
               ||'         AND B.COMPANYCODE=E.COMPANYCODE' || CHR(10)
               ||'         AND B.WORKERSERIAL=E.WORKERSERIAL' || CHR(10)
               ||'         AND B.TOKENNO=E.TOKENNO' || CHR(10)
               ||'          AND B.TOKENNO ' || CHR(10)
               ||'         IN (' || CHR(10)
               ||'               SELECT  TOKENNO  FROM   WPSSTLENTRY B ' || CHR(10)
               ||'               WHERE  B.FORTNIGHTENDDATE = TO_DATE ('''||p_todt||''', ''DD/MM/YYYY'') ' || CHR(10)
               ||'                 AND NVL(LEAVECODE,''STL'')=''STL'' ' || CHR(10)
               ||'               MINUS  ' || CHR(10)
               ||'               SELECT EBNO FROM GTT_FORTNIGHTATTENDANCE' || CHR(10)
               ||'            ) ' || CHR(10)
               ||'        GROUP BY C.COMPANYNAME, B.TOKENNO, E.WORKERNAME, ' || CHR(10)
               ||'        B.OCCUPATIONCODE,B.DEPARTMENTCODE,B.SHIFTCODE' || CHR(10)
               ||'        )' || CHR(10);

--dbms_output.put_line(lv_sqlstr);
   EXECUTE IMMEDIATE lv_sqlstr;
   ----------------------------------------------
     -------------------FOR FBK HOURS---------------
    lv_sqlstr := 'Insert into GTT_FORTNIGHTATTENDANCE' || CHR(10)
               ||' (FROMDT, TODT, COMPANYNAME, EBNO, WORKERNAME, ' || CHR(10)
               ||'        W_K_T_Y, LINENO, MCH, OCC, HRS_WK_1, ' || CHR(10)
               ||'        HRS_WK_2, NS_HRS, FESTIVAL_HRS, O_T__HRS, LAY_OFF_HRS, ' || CHR(10)
               ||'        STL_DAYS, STL_WG_ADV, DEDN_ADJ_CD, DEDN_ADJ_AMT_3_2, INC_ADJ_CD, ' || CHR(10)
               ||'        INC_ADJ_AMT_3_2, PRD_QL_CD, PRO_QTY, TAG, DEPT, ' || CHR(10)
               ||'        SHIFT, FBKHOURS)        ' || CHR(10)
               ||'     (' || CHR(10)
               ||'       SELECT '''||p_fromdt||''', '''||p_todt||''', C.COMPANYNAME, B.TOKENNO, E.WORKERNAME, ' || CHR(10)
               ||'             '''' , '''' , '''' , B.OCCUPATIONCODE, 0, ' || CHR(10)
               ||'               0, 0, 0, 0, 0, ' || CHR(10)
               ||'               0 STL_DAYS, 0 STL_WG_ADV, 0, 0, 0, ' || CHR(10)
               ||'               0, '''', 0, '''', B.DEPARTMENTCODE, ' || CHR(10)
               ||'               B.SHIFTCODE, SUM(NVL(FBKHOURS,0))' || CHR(10)
               ||'        FROM   WPSATTENDANCEDAYWISE B ,COMPANYMAST C,WPSWORKERMAST E' || CHR(10)
               ||'       WHERE  B.FORTNIGHTENDDATE = TO_DATE ('''||p_todt||''', ''DD/MM/YYYY'') ' || CHR(10)
               ||'         AND B.COMPANYCODE=C.COMPANYCODE' || CHR(10)
               ||'         AND B.COMPANYCODE=E.COMPANYCODE' || CHR(10)
               ||'         AND B.WORKERSERIAL=E.WORKERSERIAL' || CHR(10)
               ||'         AND B.TOKENNO=E.TOKENNO' || CHR(10)
               ||'          AND B.TOKENNO ' || CHR(10)
               ||'         IN (' || CHR(10)
               ||'               SELECT  TOKENNO  FROM   WPSATTENDANCEDAYWISE B ' || CHR(10)
               ||'               WHERE  B.FORTNIGHTENDDATE = TO_DATE ('''||p_todt||''', ''DD/MM/YYYY'') ' || CHR(10)
               ||'                 AND NVL(FBKHOURS,0)>0 ' || CHR(10)
               ||'               MINUS  ' || CHR(10)
               ||'               SELECT EBNO FROM GTT_FORTNIGHTATTENDANCE' || CHR(10)
               ||'            ) ' || CHR(10)
               ||'        GROUP BY C.COMPANYNAME, B.TOKENNO, E.WORKERNAME, ' || CHR(10)
               ||'        B.OCCUPATIONCODE,B.DEPARTMENTCODE,B.SHIFTCODE' || CHR(10)
               ||'        )' || CHR(10);

 -- dbms_output.put_line(lv_sqlstr);
  EXECUTE IMMEDIATE lv_sqlstr;
   ----------------------------------------------
   
   -------------------FOR LAY OFF HOURS---------------
    lv_sqlstr := 'Insert into GTT_FORTNIGHTATTENDANCE' || CHR(10)
               ||' (FROMDT, TODT, COMPANYNAME, EBNO, WORKERNAME, ' || CHR(10)
               ||'        W_K_T_Y, LINENO, MCH, OCC, HRS_WK_1, ' || CHR(10)
               ||'        HRS_WK_2, NS_HRS, FESTIVAL_HRS, O_T__HRS, LAY_OFF_HRS, ' || CHR(10)
               ||'        STL_DAYS, STL_WG_ADV, DEDN_ADJ_CD, DEDN_ADJ_AMT_3_2, INC_ADJ_CD, ' || CHR(10)
               ||'        INC_ADJ_AMT_3_2, PRD_QL_CD, PRO_QTY, TAG, DEPT, ' || CHR(10)
               ||'        SHIFT, FBKHOURS)        ' || CHR(10)
               ||'     (' || CHR(10)
               ||'       SELECT '''||p_fromdt||''', '''||p_todt||''', C.COMPANYNAME, B.TOKENNO, E.WORKERNAME, ' || CHR(10)
               ||'              '''' , '''' , '''' , B.OCCUPATIONCODE, 0, ' || CHR(10)
               ||'               0, 0, 0, 0, SUM(LAYOFFHOURS),  ' || CHR(10)
               ||'               0 , 0 , 0, 0,0,' || CHR(10)
               ||'               0, '''', 0, '''', B.DEPARTMENTCODE, ' || CHR(10)
               ||'               B.SHIFTCODE,0' || CHR(10)
               ||'        FROM   WPSATTENDANCEDAYWISE B ,COMPANYMAST C,WPSWORKERMAST E' || CHR(10)
               ||'       WHERE  B.FORTNIGHTENDDATE = TO_DATE ('''||p_todt||''', ''DD/MM/YYYY'') ' || CHR(10)
               ||'         AND B.COMPANYCODE=C.COMPANYCODE' || CHR(10)
               ||'         AND B.COMPANYCODE=E.COMPANYCODE' || CHR(10)
               ||'         AND B.WORKERSERIAL=E.WORKERSERIAL' || CHR(10)
               ||'         AND B.TOKENNO=E.TOKENNO' || CHR(10)
               ||'          AND B.TOKENNO ' || CHR(10)
               ||'         IN (' || CHR(10)
               ||'               SELECT  TOKENNO  FROM   WPSATTENDANCEDAYWISE B ' || CHR(10)
               ||'               WHERE  B.FORTNIGHTENDDATE = TO_DATE ('''||p_todt||''', ''DD/MM/YYYY'') ' || CHR(10)
               ||'                 AND NVL(LAYOFFHOURS,0)>0 ' || CHR(10)
               ||'               MINUS  ' || CHR(10)
               ||'               SELECT EBNO FROM GTT_FORTNIGHTATTENDANCE' || CHR(10)
               ||'            ) ' || CHR(10)
               ||'        GROUP BY C.COMPANYNAME, B.TOKENNO, E.WORKERNAME, ' || CHR(10)
               ||'        B.OCCUPATIONCODE,B.DEPARTMENTCODE,B.SHIFTCODE' || CHR(10)
               ||'        )' || CHR(10);

--dbms_output.put_line(lv_sqlstr);
   EXECUTE IMMEDIATE lv_sqlstr;
   ----------------------------------------------
   commit;
    
                   
end;
/


