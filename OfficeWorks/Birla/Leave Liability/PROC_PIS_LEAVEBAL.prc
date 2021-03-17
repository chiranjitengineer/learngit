CREATE OR REPLACE PROCEDURE BIRLANEW.PROC_PIS_LEAVEBAL(P_COMPANYCODE VARCHAR2,P_DIVISIONCODE VARCHAR2,P_YEARCODE VARCHAR2,P_FROMDATE VARCHAR2,P_TODATE VARCHAR2, P_WORKERSERIAL VARCHAR2 DEFAULT NULL)
as
lv_sql  varchar2(20000);
lv_cnt int;
lv_EARNFLAG VARCHAR2(10);
BEGIN
    
     BEGIN
           EXECUTE IMMEDIATE 'DROP TABLE TEMP_LEAVE';
          
            EXCEPTION WHEN OTHERS THEN
                NULL;                 
        END;
    
    lv_EARNFLAG := 'N';

    SELECT COUNT(PARAMETER_VALUE) INTO lv_cnt FROM SYS_PARAMETER
    WHERE PARAMETER_NAME='LEAVE BALANCE MAINTAIN PROPORTIONATE';

    IF lv_cnt > 0 THEN

        SELECT PARAMETER_VALUE INTO lv_EARNFLAG FROM SYS_PARAMETER
        WHERE PARAMETER_NAME='LEAVE BALANCE MAINTAIN PROPORTIONATE';

    END IF;


    
    lv_sql:='CREATE TABLE TEMP_LEAVE'||CHR(10)
            ||'AS'||CHR(10)
            ||'SELECT WORKERSERIAL,LEAVECODE,SUM(OPENING) OPENING,SUM(ENT) ENT,SUM(AVAIL) AVAIL'||CHR(10)
            ||'FROM'||CHR(10)
            ||'('||CHR(10)
            ||'     SELECT A.CATEGORYCODE, A.WORKERSERIAL, LEAVECODE, SUM(NOOFDAYS) OPENING, 0 ENT, 0 AVAIL'||CHR(10)
            ||'     FROM PISEMPLOYEEMASTER A, PISCATEGORYMASTER C,PISLEAVETRANSACTION B'||CHR(10)
            ||'     WHERE A.COMPANYCODE='''||P_COMPANYCODE||''''||CHR(10)
            ||'         AND A.DIVISIONCODE='''||P_DIVISIONCODE||''''||CHR(10)
            ||'         AND A.COMPANYCODE=C.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=C.DIVISIONCODE'||CHR(10)
            ||'         AND A.CATEGORYCODE=C.CATEGORYCODE'||CHR(10)
            ||'         AND C.LEAVECALENDARORFINYRWISE=''F'''||CHR(10)
            ||'         AND A.COMPANYCODE=B.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=B.DIVISIONCODE'||CHR(10)
            ||'         AND A.WORKERSERIAL=B.WORKERSERIAL'||CHR(10)
            ||'         AND B.TRANSACTIONTYPE=''BF'''||CHR(10)
            ||'         AND B.YEARCODE='''||P_YEARCODE||''''||CHR(10)
            ||'         AND B.YEARMONTH<=TO_CHAR(TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY''),''YYYYMM'')'||CHR(10)
            ||'     GROUP BY A.CATEGORYCODE,A.WORKERSERIAL,B.LEAVECODE'||CHR(10)
            ||'     UNION ALL'||CHR(10)
            ||'     SELECT A.CATEGORYCODE, A.WORKERSERIAL, LEAVECODE, SUM(NOOFDAYS) OPENING, 0 ENT, 0 AVAIL'||CHR(10)
            ||'     FROM PISEMPLOYEEMASTER A, PISCATEGORYMASTER C,PISLEAVETRANSACTION B'||CHR(10)
            ||'     WHERE A.COMPANYCODE='''||P_COMPANYCODE||''''||CHR(10)
            ||'         AND A.DIVISIONCODE='''||P_DIVISIONCODE||''''||CHR(10)
            ||'         AND A.COMPANYCODE=C.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=C.DIVISIONCODE'||CHR(10)
            ||'         AND A.CATEGORYCODE=C.CATEGORYCODE'||CHR(10)
            ||'         AND C.LEAVECALENDARORFINYRWISE=''C'''||CHR(10)
            ||'         AND A.COMPANYCODE=B.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=B.DIVISIONCODE'||CHR(10)
            ||'         AND A.WORKERSERIAL=B.WORKERSERIAL'||CHR(10)
            ||'         AND B.TRANSACTIONTYPE=''BF'''||CHR(10)
            ||'         AND B.CALENDARYEAR=TO_CHAR(TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY''),''YYYY'')'||CHR(10)
            ||'         AND B.YEARMONTH<=TO_CHAR(TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY''),''YYYYMM'')'||CHR(10)
            ||'     GROUP BY A.CATEGORYCODE,A.WORKERSERIAL,B.LEAVECODE'||CHR(10)
            ||'     UNION ALL'||CHR(10);
            
IF lv_EARNFLAG = 'Y' THEN

            
    lv_sql:= lv_sql          
            ||'     SELECT A.CATEGORYCODE, A.WORKERSERIAL, LEAVECODE, 0 OPENING, SUM(ENTITLEMENTS) ENT, 0 AVAIL'||CHR(10)
            ||'     FROM PISEMPLOYEEMASTER A, PISCATEGORYMASTER C,'||CHR(10)
            ||'     ('||CHR(10)
            ||'         SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL,LEAVECODE,YEARCODE, SUM(NOOFDAYS) ENTITLEMENTS'||CHR(10)
            ||'         FROM PISLEAVETRANSACTION'||CHR(10)
            ||'         WHERE YEARCODE='''||P_YEARCODE||''''||CHR(10)
            
            ||'         AND TRANSACTIONTYPE=''ENT'''||CHR(10)
            ||'         AND TO_DATE(YEARMONTH,''YYYYMM'') BETWEEN TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'') AND TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'') '||CHR(10)
            
            ||'         GROUP BY COMPANYCODE, DIVISIONCODE, WORKERSERIAL,LEAVECODE,YEARCODE'||CHR(10)
            ||'     ) B'||CHR(10)
            ||'     WHERE A.COMPANYCODE='''||P_COMPANYCODE||''''||CHR(10)
            ||'         AND A.DIVISIONCODE='''||P_DIVISIONCODE||''''||CHR(10)
            ||'         AND A.COMPANYCODE=C.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=C.DIVISIONCODE'||CHR(10)
            ||'         AND A.CATEGORYCODE=C.CATEGORYCODE'||CHR(10)
            ||'         AND C.LEAVECALENDARORFINYRWISE=''F'''||CHR(10)
            ||'         AND A.COMPANYCODE=B.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=B.DIVISIONCODE'||CHR(10)
            ||'         AND A.WORKERSERIAL=B.WORKERSERIAL'||CHR(10)
            ||'         AND B.YEARCODE='''||P_YEARCODE||''''||CHR(10)
            ||'     GROUP BY A.CATEGORYCODE,A.WORKERSERIAL,B.LEAVECODE'||CHR(10)
            ||'     UNION ALL'||CHR(10)
            ||'     SELECT A.CATEGORYCODE, A.WORKERSERIAL, LEAVECODE, 0 OPENING, SUM(ENTITLEMENTS) ENT, 0 AVAIL'||CHR(10)
            ||'     FROM PISEMPLOYEEMASTER A, PISCATEGORYMASTER C,'||CHR(10)
            ||'     ('||CHR(10)
            ||'         SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL,LEAVECODE,CALENDARYEAR, SUM(NOOFDAYS) ENTITLEMENTS'||CHR(10)
            ||'         FROM PISLEAVETRANSACTION'||CHR(10)
            ||'         WHERE CALENDARYEAR=TO_CHAR(TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY''),''YYYY'')'||CHR(10)
            ||'         AND TRANSACTIONTYPE=''ENT'''||CHR(10)
            ||'         GROUP BY COMPANYCODE, DIVISIONCODE, WORKERSERIAL,LEAVECODE,CALENDARYEAR'||CHR(10)
            ||'     ) B'||CHR(10)
            ||'     WHERE A.COMPANYCODE='''||P_COMPANYCODE||''''||CHR(10)
            ||'         AND A.DIVISIONCODE='''||P_DIVISIONCODE||''''||CHR(10)
            ||'         AND A.COMPANYCODE=C.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=C.DIVISIONCODE'||CHR(10)
            ||'         AND A.CATEGORYCODE=C.CATEGORYCODE'||CHR(10)
            ||'         AND C.LEAVECALENDARORFINYRWISE=''C'''||CHR(10)
            ||'         AND A.COMPANYCODE=B.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=B.DIVISIONCODE'||CHR(10)
            ||'         AND A.WORKERSERIAL=B.WORKERSERIAL'||CHR(10)
            ||'         AND B.CALENDARYEAR=TO_CHAR(TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY''),''YYYY'')'||CHR(10)
            ||'     GROUP BY A.CATEGORYCODE,A.WORKERSERIAL,B.LEAVECODE'||CHR(10);
            
            
ELSE
            
    lv_sql:= lv_sql          
            ||'     SELECT A.CATEGORYCODE, A.WORKERSERIAL, LEAVECODE, 0 OPENING, SUM(ENTITLEMENTS) ENT, 0 AVAIL'||CHR(10)
            ||'     FROM PISEMPLOYEEMASTER A, PISCATEGORYMASTER C,PISLEAVEENTITLEMENT B'||CHR(10)
            ||'     WHERE A.COMPANYCODE='''||P_COMPANYCODE||''''||CHR(10)
            ||'         AND A.DIVISIONCODE='''||P_DIVISIONCODE||''''||CHR(10)
            ||'         AND A.COMPANYCODE=C.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=C.DIVISIONCODE'||CHR(10)
            ||'         AND A.CATEGORYCODE=C.CATEGORYCODE'||CHR(10)
            ||'         AND C.LEAVECALENDARORFINYRWISE=''F'''||CHR(10)
            ||'         AND A.COMPANYCODE=B.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=B.DIVISIONCODE'||CHR(10)
            ||'         AND A.WORKERSERIAL=B.WORKERSERIAL'||CHR(10)
            ||'         AND B.YEARCODE='''||P_YEARCODE||''''||CHR(10)
            ||'     GROUP BY A.CATEGORYCODE,A.WORKERSERIAL,B.LEAVECODE'||CHR(10)
            ||'     UNION ALL'||CHR(10)
            ||'     SELECT A.CATEGORYCODE, A.WORKERSERIAL, LEAVECODE, 0 OPENING, SUM(ENTITLEMENTS) ENT, 0 AVAIL'||CHR(10)
            ||'     FROM PISEMPLOYEEMASTER A, PISCATEGORYMASTER C,PISLEAVEENTITLEMENT B'||CHR(10)
            ||'     WHERE A.COMPANYCODE='''||P_COMPANYCODE||''''||CHR(10)
            ||'         AND A.DIVISIONCODE='''||P_DIVISIONCODE||''''||CHR(10)
            ||'         AND A.COMPANYCODE=C.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=C.DIVISIONCODE'||CHR(10)
            ||'         AND A.CATEGORYCODE=C.CATEGORYCODE'||CHR(10)
            ||'         AND C.LEAVECALENDARORFINYRWISE=''C'''||CHR(10)
            ||'         AND A.COMPANYCODE=B.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=B.DIVISIONCODE'||CHR(10)
            ||'         AND A.WORKERSERIAL=B.WORKERSERIAL'||CHR(10)
            ||'         AND B.CALENDARYEAR=TO_CHAR(TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY''),''YYYY'')'||CHR(10)
            ||'     GROUP BY A.CATEGORYCODE,A.WORKERSERIAL,B.LEAVECODE'||CHR(10);
            
            
END IF;
            
    lv_sql:= lv_sql   
            ||'     UNION ALL'||CHR(10)
            ||'     SELECT A.CATEGORYCODE, A.WORKERSERIAL, LEAVECODE, 0 OPENING, 0 ENT, SUM(LEAVEDAYS) AVAIL'||CHR(10)
            ||'     FROM PISEMPLOYEEMASTER A, PISLEAVEAPPLICATION B, PISCATEGORYMASTER C'||CHR(10)
            ||'     WHERE A.COMPANYCODE = '''||P_COMPANYCODE||''''||CHR(10)
            ||'         AND A.DIVISIONCODE = '''||P_DIVISIONCODE||''''||CHR(10)
            ||'         AND A.COMPANYCODE=C.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=C.DIVISIONCODE'||CHR(10)
            ||'         AND A.CATEGORYCODE = C.CATEGORYCODE'||CHR(10)
            ||'         AND C.LEAVECALENDARORFINYRWISE =''F'''||CHR(10)
            ||'         AND A.COMPANYCODE=B.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=B.DIVISIONCODE'||CHR(10)
            ||'         AND A.WORKERSERIAL = B.WORKERSERIAL'||CHR(10)
            ||'         AND B.YEARCODE = '''||P_YEARCODE||''''||CHR(10)
            ||'         AND B.LEAVESANCTIONEDON IS NOT NULL'||CHR(10)
--            ||'         AND B.LEAVEAPPLIEDON <= TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'||CHR(10)
            ||'         AND B.LEAVEDATE <= TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'||CHR(10)            
            ||'     GROUP BY A.CATEGORYCODE, A.WORKERSERIAL, B.LEAVECODE'||CHR(10)
            ||'     UNION ALL'||CHR(10)
            ||'     SELECT A.CATEGORYCODE, A.WORKERSERIAL, LEAVECODE, 0 OPENING, 0 ENT, SUM(LEAVEDAYS) AVAIL'||CHR(10)
            ||'     FROM PISEMPLOYEEMASTER A, PISLEAVEAPPLICATION B, PISCATEGORYMASTER C'||CHR(10)
            ||'     WHERE A.COMPANYCODE = '''||P_COMPANYCODE||''''||CHR(10)
            ||'         AND A.DIVISIONCODE = '''||P_DIVISIONCODE||''''||CHR(10)
            ||'         AND A.COMPANYCODE=C.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=C.DIVISIONCODE'||CHR(10)
            ||'         AND A.CATEGORYCODE = C.CATEGORYCODE'||CHR(10)
            ||'         AND C.LEAVECALENDARORFINYRWISE =''C'''||CHR(10)
            ||'         AND A.COMPANYCODE=B.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=B.DIVISIONCODE'||CHR(10)
            ||'         AND A.WORKERSERIAL = B.WORKERSERIAL'||CHR(10)
            ||'         AND B.CALENDARYEAR = TO_CHAR(TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY''),''YYYY'')'||CHR(10)
            ||'         AND B.LEAVESANCTIONEDON IS NOT NULL'||CHR(10)   
      --    ||'         AND B.LEAVEAPPLIEDON <= TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'||CHR(10)
            ||'         AND B.LEAVEDATE <= TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'||CHR(10)
            ||'     GROUP BY A.CATEGORYCODE, A.WORKERSERIAL, B.LEAVECODE'||CHR(10)
            ||')'||CHR(10)
            ||'GROUP BY WORKERSERIAL, LEAVECODE'||CHR(10);
            
      DBMS_OUTPUT.PUT_LINE(lv_sql);
      EXECUTE IMMEDIATE lv_sql;
      
      
        BEGIN
           EXECUTE IMMEDIATE 'DROP TABLE TEMP_NOOFDAYS_DEDUCT';
          
            EXCEPTION WHEN OTHERS THEN
                NULL;                 
        END;
      
        lv_sql:= '     CREATE TABLE TEMP_NOOFDAYS_DEDUCT AS           '||CHR(10)
            ||'    SELECT S.COMPANYCODE, S.DIVISIONCODE, L.WORKERSERIAL,L.LEAVECODE, NVL(OPENING,0) OPENING, NVL(ENT,0) ENT, NVL(AVAIL,0) AVAIL,NVL(CARRYFORWARD,0)CARRYFORWARD,'||CHR(10) 
            ||'    CASE WHEN (NVL(OPENING,0)+NVL(ENT,0)-NVL(CARRYFORWARD,0)>0 AND CARRYFORWARD>0) THEN NVL(OPENING,0)+NVL(ENT,0)-NVL(CARRYFORWARD,0) ELSE 0 END DEDUC'||CHR(10)
            ||'    FROM TEMP_LEAVE T,PISLEAVEENTITLEMENT S,(    '||CHR(10)
            ||'                        SELECT A.WORKERSERIAL,B.LEAVECODE'||CHR(10)
            ||'                        FROM ('||CHR(10)
            ||'                                SELECT DISTINCT WORKERSERIAL'||CHR(10)
            ||'                                FROM TEMP_LEAVE'||CHR(10)
            ||'                             ) A,'||CHR(10)
            ||'                             ('||CHR(10)
            ||'                                SELECT LEAVECODE from PISLEAVEMASTER'||CHR(10)
            ||'                                WHERE COMPANYCODE='''||P_COMPANYCODE||''''||CHR(10)
            ||'                                    AND DIVISIONCODE='''||P_DIVISIONCODE||''''||CHR(10)
            ||'                                    AND WITHOUTPAYLEAVE<>''Y'''||CHR(10)
            ||'                              ) B'||CHR(10)
            ||'                      ) L'||CHR(10)
            ||'    WHERE L.WORKERSERIAL=T.WORKERSERIAL(+)'||CHR(10)
            ||'        AND L.LEAVECODE=T.LEAVECODE(+)'||CHR(10)
            ||'        AND L.WORKERSERIAL=S.WORKERSERIAL'||CHR(10)
            ||'        AND L.LEAVECODE=S.LEAVECODE     '||CHR(10)
            ||'         AND S.YEARCODE='''||P_YEARCODE||'''     '||CHR(10)                    
            ||'         AND (NVL(OPENING,0)+NVL(ENT,0)-NVL(CARRYFORWARD,0))>0 AND  NVL(CARRYFORWARD,0)>0'||CHR(10);
                 
                
          --        DBMS_OUTPUT.PUT_LINE(lv_sql);
                  EXECUTE IMMEDIATE lv_sql;    
            
            
            lv_sql:= '    UPDATE PISLEAVETRANSACTION A'||CHR(10)
            ||'    SET NOOFDAYS='||CHR(10)
            ||'        ('||CHR(10)
            ||'            SELECT A.NOOFDAYS-B.DEDUC FROM TEMP_NOOFDAYS_DEDUCT B'||CHR(10)
            ||'            WHERE '||CHR(10)
            ||'            B.DIVISIONCODE=A.DIVISIONCODE'||CHR(10)
            ||'           AND B.WORKERSERIAL=A.WORKERSERIAL'||CHR(10)
            ||'            AND B.LEAVECODE=A.LEAVECODE'||CHR(10)
            ||'        )       '||CHR(10)
            ||'    WHERE A.DIVISIONCODE='''||P_DIVISIONCODE||''''||CHR(10)
            ||'    AND A.LEAVECODE=''PL'''||CHR(10)
            ||'    AND A.WORKERSERIAL IN (SELECT WORKERSERIAL FROM TEMP_NOOFDAYS_DEDUCT)   '||CHR(10)  ;   
                    
                
                  
      DBMS_OUTPUT.PUT_LINE(lv_sql);
      
IF lv_EARNFLAG = 'N' THEN
      EXECUTE IMMEDIATE lv_sql; --COMMENTED ON 11032021
END IF;
            
      
      EXECUTE IMMEDIATE 'TRUNCATE TABLE GBL_PIS_LEAVEBAL';
             
      lv_sql:= 'INSERT INTO GBL_PIS_LEAVEBAL'||CHR(10)
               ||'SELECT '''||P_COMPANYCODE||''' COMPANYCODE,'''||P_DIVISIONCODE||''' DVISIONCODE,TO_CHAR(TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY''),''YYYYMM'') YEARMONTH,D.WORKERSERIAL,E.TOKENNO,E.CATEGORYCODE,E.GRADECODE,D.LEAVECODE,D.OPENING OPENING,D.ENT ENTITLE,D.AVAIL AVAILED,(D.OPENING+D.ENT-D.AVAIL) BALANCE'||CHR(10)
               ||'FROM ('||CHR(10)
               ||'        SELECT L.WORKERSERIAL,L.LEAVECODE, NVL(OPENING,0) OPENING, NVL(ENT,0) ENT, NVL(AVAIL,0) AVAIL'||CHR(10)
               ||'        FROM TEMP_LEAVE T,('||CHR(10)
               ||'                            SELECT A.WORKERSERIAL,B.LEAVECODE'||CHR(10)
               ||'                            FROM ('||CHR(10)
               ||'                                    SELECT DISTINCT WORKERSERIAL'||CHR(10)
               ||'                                    FROM TEMP_LEAVE'||CHR(10)
               ||'                                 ) A,'||CHR(10)
               ||'                                 ('||CHR(10)
               ||'                                    SELECT LEAVECODE from PISLEAVEMASTER'||CHR(10)
               ||'                                    WHERE COMPANYCODE='''||P_COMPANYCODE||''''||CHR(10)
               ||'                                        AND DIVISIONCODE='''||P_DIVISIONCODE||''''||CHR(10)
               ||'                                        AND WITHOUTPAYLEAVE<>''Y'''||CHR(10)
               ||'                                  ) B'||CHR(10)
               ||'                           ) L'||CHR(10)
               ||'        WHERE L.WORKERSERIAL=T.WORKERSERIAL(+)'||CHR(10)
               ||'            AND L.LEAVECODE=T.LEAVECODE(+)'||CHR(10)
               ||'     ) D, PISEMPLOYEEMASTER E'||CHR(10)
               ||'WHERE D.WORKERSERIAL=E.WORKERSERIAL'||CHR(10);
     IF P_WORKERSERIAL IS NOT NULL THEN
        lv_sql:= lv_sql ||' D.WORKERSERIAL IN ('||P_WORKERSERIAL||')'||CHR(10) ;
     END IF;
     
--        DBMS_OUTPUT.PUT_LINE(lv_sql);
       EXECUTE IMMEDIATE lv_sql;
        
        EXECUTE IMMEDIATE 'DROP TABLE TEMP_LEAVE';
END;
/
