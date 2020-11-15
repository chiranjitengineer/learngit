CREATE OR REPLACE PROCEDURE DHAMAI.PROC_WAGES_REGISTER_STDFRMT
(
    P_COMPANYCODE       VARCHAR2,
    P_DIVISIONCODE      VARCHAR2,
    P_FROMDATE          VARCHAR2,
    P_TODATE            VARCHAR2,
    P_ATTN              VARCHAR2,
    P_CLUSTER           VARCHAR2,
    P_RPTOPTION         VARCHAR2
)
AS
    LV_SQLSTR VARCHAR2(12000);
    LV_CNT NUMBER;
    P_RPTOPT VARCHAR2(100);
BEGIN
       
        DELETE FROM GTT_WAGES_REGISTER_STDFRMT;
        
        SELECT  INSTR(P_RPTOPTION, 'WEEK') INTO LV_CNT FROM DUAL;
        
        IF LV_CNT > 0 THEN
            P_RPTOPT := 'WEEKLY';
        ELSE
            P_RPTOPT := 'FORTNIGHTLY';
        END IF;
        
LV_SQLSTR :=' INSERT INTO GTT_WAGES_REGISTER_STDFRMT '||CHR(10)
          ||'    SELECT  XXX.*    '||CHR(10)
          ||'      FROM (     '||CHR(10)      
          ||'              SELECT DISTINCT A.TOKENNO EMP_CODE, A.PFNO, A.NAME, A.NETPAY, B.SK_DAYS, '||CHR(10) 
          ||'                     B.MT_DAYS, B.AL_DAYS, B.WP_DAYS, B.HOLIDAYS, B.PRESENTDAYS,   '||CHR(10)
          ||'                     SUM( D.DAILYWAGES),  '||CHR(10)
          ||'                     NVL(E.INCENTIVE, 0) INCENTIVE, NVL(E.SPL_ALLOW, 0) SPL_ALLOW, NVL(E.SPRAY_ALLOW, 0) SPRAY_ALLOW,  '||CHR(10)
      --    ||'                     NVL(E.FACT_ALOW, 0) FACT_ALOW, NVL(E.EXTRA, 0) EXTRA, (NVL(E.ATTN_ALLOW, 0)+NVL(E.FACT_ALOW, 0)+NVL(E.SPRAY_ALLOW, 0))  ATTN_ALLOW,  '||CHR(10)
          ||'                     NVL(E.FACT_ALOW, 0) FACT_ALOW, NVL(E.EXTRA, 0) EXTRA, NVL(E.ATTN_ALLOW, 0) ATTN_ALLOW,  '||CHR(10)
          ||'                     NVL(E.GROSSWAGES, 0) GROSSWAGES, NVL(E.COINBF, 0) COINBF, NVL(E.PF_E, 0) PF_E, NVL(E.PTAX, 0) PTAX,   '||CHR(10)
          ||'                     (NVL(E.ADVANCE, 0)+NVL(E.MD_LOAN, 0)) ADVANCE, NVL(E.PF_LOAN, 0) PF_LOAN, NVL(E.PF_INT, 0) PF_INT,  '||CHR(10) 
          ||'                     NVL(E.MD_LOAN, 0) MD_LOAN, NVL(E.RAT_DED, 0) RAT_DED, NVL(E.LIC_DED, 0) LIC_DED, NVL(E.DED_ELEC, 0) DED_ELEC,  '||CHR(10)
          ||'                     NVL(E.DED_WELFARE, 0) DED_WELFARE, NVL(E.DED_UNION, 0) DED_UNION,  '||CHR(10)
          ||'                     NVL(E.GROSSDEDN, 0) GROSSDEDN, NVL(E.COINCF, 0) COINCF,     '||CHR(10)
          ||'                     NULL COMPANYNAME, NULL DIVISIONNAME,  '||CHR(10) 
          ||'                     '''||P_FROMDATE||'''||'' To ''||'''||P_TODATE||'''  PRINTEDDATE, ' || CHR(10)
          ||'                     TO_CHAR(SYSDATE, ''DD/MM/YYYY'') RUNDATE, E.TOT_EARN EX1,  '||CHR(10)
          ||'                     NVL(E.TOT_DED,0) EX2, NVL(E.OT_AMOUNT,0)  EX3, NVL(E.temp_DED,0) EX4,  ROUND(NVL(E.PF_FC_GROSS,0)*0.12,2) EX5, '||CHR(10)
          ||'                     NVL(E.FUEL_ALLOW,0) FUEL_ALLOW,NVL(DED_LPG,0) DED_LPG,NVL(OTHER_DED,0) OTHER_DED,'''' EX6,'''' EX7,'''' EX8,'''' EX9,'''' EX10 '||CHR(10)
          ||'                     FROM (  '||CHR(10)
          ||'                      SELECT PSD.COMPANYCODE, PSD.DIVISIONCODE, PSD.TOKENNO, PSD.WORKERSERIAL,  '||CHR(10) 
          ||'                             EM.PFNO, EM.EMPLOYEENAME NAME, NETSALARY NETPAY  '||CHR(10)
          ||'                        FROM GPSPAYSHEETDETAILS PSD, GPSEMPLOYEEMAST EM  ,GPSCATEGORYMAST CAT '||CHR(10)
          ||'                       WHERE PSD.COMPANYCODE = EM.COMPANYCODE  '||CHR(10)
          ||'                         AND PSD.DIVISIONCODE = EM.DIVISIONCODE  '||CHR(10)
          ||'                         AND PSD.TOKENNO = EM.TOKENNO '||CHR(10)
          ||'                         AND PSD.COMPANYCODE = CAT.COMPANYCODE  '||CHR(10)
          ||'                         AND PSD.DIVISIONCODE = CAT.DIVISIONCODE  '||CHR(10)
          ||'                         AND PSD.CATEGORYCODE = CAT.CATEGORYCODE '||CHR(10)
          ||'                         AND PSD.PERIODFROM >= TO_DATE('''||P_FROMDATE||''', ''DD/MM/YYYY'')  '||CHR(10)
          ||'                         AND PSD.PERIODTO <= TO_DATE('''||P_TODATE||''', ''DD/MM/YYYY'')  '||CHR(10)
          ||'                         AND PSD.COMPANYCODE = '''||P_COMPANYCODE||''' '||CHR(10)
          ||'                         AND PSD.DIVISIONCODE = '''||P_DIVISIONCODE||'''  '||CHR(10)
          ||'                         AND CAT.WAGESPERIODTYPE='''||P_RPTOPT||''' '||CHR(10) 
          ||'                       ORDER BY TOKENNO  '||CHR(10)
          ||'                     ) A,  '||CHR(10)
          ||'                     (  '||CHR(10)       
          ||'                      SELECT COMPANYCODE, DIVISIONCODE, TOKENNO, WORKERSERIAL, SUM(SK_DAYS) SK_DAYS, SUM(MT_DAYS) MT_DAYS, '||CHR(10)
          ||'                             SUM(AL_DAYS) AL_DAYS, SUM(WP_DAYS) WP_DAYS, SUM(HOLIDAYS) HOLIDAYS, SUM(PRESENTDAYS) PRESENTDAYS  '||CHR(10)
          ||'                        FROM (  '||CHR(10)
          ||'                              SELECT A.COMPANYCODE, A.DIVISIONCODE, A.TOKENNO, A.WORKERSERIAL, '||CHR(10)
          ||'                                     CASE WHEN B.OCCUPATIONTYPE = ''SICK LEAVE'' THEN HAZIRA ELSE 0 END SK_DAYS,  '||CHR(10)
          ||'                                     CASE WHEN B.OCCUPATIONTYPE = ''MATERNITY LEAVE'' THEN HAZIRA ELSE 0 END MT_DAYS,  '||CHR(10)
          ||'                                     CASE WHEN B.OCCUPATIONTYPE = ''ANNUAL LEAVE'' THEN HAZIRA ELSE 0 END AL_DAYS,  '||CHR(10)
          ||'                                     CASE WHEN B.OCCUPATIONTYPE IN (''ABSENT'',''SPECIAL LEAVE'',''SICK LEAVE WITHOUT PAY'') THEN HAZIRA ELSE 0 END WP_DAYS,  '||CHR(10)
          ||'                                     CASE WHEN B.OCCUPATIONTYPE = ''PAID HOLIDAY'' THEN HAZIRA ELSE 0 END HOLIDAYS,  '||CHR(10)
          --||'                                     CASE WHEN B.OCCUPATIONTYPE IN (''TUBE FILLING'',''PLUCKING'',''OTHERS'') THEN HAZIRA ELSE 0 END PRESENTDAYS  '||CHR(10)
          ||'                                     HAZIRA PRESENTDAYS  '||CHR(10)
          ||'                                FROM GPSATTENDANCEDETAILS A, (  '||CHR(10)
          ||'                                                             SELECT DISTINCT OCCUPATIONTYPE FROM GPSOCCUPATIONMAST  '||CHR(10) 
          ||'                                                              WHERE COMPANYCODE = '''||P_COMPANYCODE||''' '||CHR(10)
          ||'                                                                AND DIVISIONCODE = '''||P_DIVISIONCODE||'''  '||CHR(10)
          ||'                                                           ) B  ,GPSCATEGORYMAST CAT  '||CHR(10)
          ||'                               WHERE ATTENDANCEDATE >= TO_DATE('''||P_FROMDATE||''', ''DD/MM/YYYY'')  '||CHR(10)
          ||'                                 AND ATTENDANCEDATE <= TO_DATE('''||P_TODATE||''', ''DD/MM/YYYY'')  '||CHR(10)
          ||'                                 AND A.COMPANYCODE = '''||P_COMPANYCODE||''' '||CHR(10)
          ||'                                 AND A.DIVISIONCODE = '''||P_DIVISIONCODE||'''  '||CHR(10)
          ||'                                 AND A.OCCOUPATIONTYPE = B.OCCUPATIONTYPE  '||CHR(10)
          ||'                                 AND A.COMPANYCODE = CAT.COMPANYCODE  '||CHR(10)
          ||'                                 AND A.DIVISIONCODE = CAT.DIVISIONCODE  '||CHR(10)
          ||'                                 AND A.CATEGORYCODE = CAT.CATEGORYCODE  '||CHR(10)
          ||'                                 AND A.ATTENDANCETYPE=''NORMAL'''||CHR(10)          
          ||'                                 AND CAT.WAGESPERIODTYPE='''||P_RPTOPT||'''      '||CHR(10)     
          ||'                              )  '||CHR(10) 
          ||'                       GROUP BY TOKENNO, WORKERSERIAL, COMPANYCODE, DIVISIONCODE  '||CHR(10)        
          ||'                     ) B,  '||CHR(10)
          ||'                     (  '||CHR(10)
          ||'                      SELECT LA.COMPANYCODE, LA.DIVISIONCODE, LA.TOKENNO, LA.WORKERSERIAL,  '||CHR(10)
          ||'                             LA.LEAVECODE, LM.LEAVEDESC, SUM(LA.LEAVEDAYS) LEAVE '||CHR(10)
          ||'                        FROM GPSLEAVEAPPLICATION LA, GPSLEAVEMASTER LM ,GPSCATEGORYMAST CAT '||CHR(10)
          ||'                       WHERE LA.COMPANYCODE = LM.COMPANYCODE  '||CHR(10)
          ||'                         AND LA.DIVISIONCODE = LM.DIVISIONCODE  '||CHR(10)
          ||'                         AND LA.LEAVECODE = LM.LEAVECODE  '||CHR(10)
          ||'                         AND LA.LEAVEAPPLIEDON BETWEEN TO_DATE('''||P_FROMDATE||''', ''DD/MM/YYYY'') AND TO_DATE('''||P_TODATE||''', ''DD/MM/YYYY'')  '||CHR(10)
          ||'                         AND LA.COMPANYCODE = CAT.COMPANYCODE  '||CHR(10)
          ||'                         AND LA.DIVISIONCODE = CAT.DIVISIONCODE  '||CHR(10)
          ||'                         AND LA.CATEGORYCODE = CAT.CATEGORYCODE '||CHR(10)     
          ||'                         AND CAT.WAGESPERIODTYPE='''||P_RPTOPT||''' '||CHR(10)
          ||'                       GROUP BY LA.TOKENNO, LA.WORKERSERIAL, LA.LEAVECODE, LM.LEAVEDESC, LA.COMPANYCODE, LA.DIVISIONCODE  '||CHR(10)
          ||'                       ORDER BY LA.TOKENNO  '||CHR(10)
          ||'                     ) C,  '||CHR(10)
          ||'                     (  '||CHR(10)
          ||'                      SELECT A.COMPANYCODE, A.DIVISIONCODE, TOKENNO, WORKERSERIAL, CLUSTERCODE, ATTNBOOKCODE, A.CATEGORYCODE, '||CHR(10) 
          ||'                             ATTENDANCEDATE, OCCUPATIONCODE, A.DAILYWAGES  '||CHR(10)
          ||'                        FROM GPSDAILYPAYSHEETDETAILS A  ,GPSCATEGORYMAST CAT  '||CHR(10)
          ||'                       WHERE ATTENDANCEDATE BETWEEN TO_DATE('''||P_FROMDATE||''', ''DD/MM/YYYY'') AND TO_DATE('''||P_TODATE||''', ''DD/MM/YYYY'')  '||CHR(10)
          ||'                         AND A.COMPANYCODE = '''||P_COMPANYCODE||''' '||CHR(10)
          ||'                         AND A.DIVISIONCODE = '''||P_DIVISIONCODE||'''  '||CHR(10) 
          ||'                         AND A.COMPANYCODE = CAT.COMPANYCODE  '||CHR(10)
          ||'                         AND A.DIVISIONCODE = CAT.DIVISIONCODE  '||CHR(10)
          ||'                         AND A.CATEGORYCODE = CAT.CATEGORYCODE '||CHR(10)   
          ||'                         AND PROCESSTYPE=''DAILY PROCESS'' '||CHR(10)
          ||'                         AND CAT.WAGESPERIODTYPE='''||P_RPTOPT||''' '||CHR(10)
          ||'                         ORDER BY TOKENNO  '||CHR(10)
          ||'                     ) D,  '||CHR(10)
          ||'                     (  '||CHR(10)
          ||'                      SELECT X.COMPANYCODE, X.DIVISIONCODE, X.TOKENNO, X.WORKERSERIAL,  '||CHR(10)
          ||'                             INCENTIVE, SPL_ALLOW, SPRAY_ALLOW, FACT_ALOW, EXTRA_ALLOW EXTRA,X.HOLIDAY_WAGE ATTN_ALLOW,  '||CHR(10)
          ||'                             GROSSWAGES, COINBF, PF_E, PTAX, LOAN_ADVGN ADVANCE, LOAN_PF PF_LOAN, LINT_PF PF_INT,  '||CHR(10) 
          ||'                             LOAN_MD MD_LOAN, RAT_DED, DED_LIC LIC_DED, DED_ELEC, DED_WELFARE, DED_UNION,    '||CHR(10)
          ||'                             GROSSDEDN, COINCF, XX.TOT_EARN, XX.TOT_DED ,PF_FC_GROSS,OT_AMOUNT ,TEMP_DED,0 FUEL_ALLOW,DED_LPG,OTHER_DED'||CHR(10)
          ||'                        FROM GPSPAYSHEETDETAILS X,(  '||CHR(10)
          ||'                                                  SELECT TOKENNO, WORKERSERIAL, SUM(GROSSWAGES + COINBF) TOT_EARN, SUM(GROSSDEDN + COINCF) TOT_DED'||CHR(10)
          ||'                                                    FROM GPSPAYSHEETDETAILS  '||CHR(10)
          ||'                                                   WHERE PERIODFROM >= TO_DATE('''||P_FROMDATE||''', ''DD/MM/YYYY'')  '||CHR(10)
          ||'                                                     AND PERIODTO <= TO_DATE('''||P_TODATE||''', ''DD/MM/YYYY'')  '||CHR(10)
          ||'                                                     AND COMPANYCODE = '''||P_COMPANYCODE||''' '||CHR(10)
          ||'                                                     AND DIVISIONCODE = '''||P_DIVISIONCODE||'''  '||CHR(10)
          ||'                                                   GROUP BY TOKENNO, WORKERSERIAL    '||CHR(10)
          ||'                                                )  XX ,GPSCATEGORYMAST CAT '||CHR(10)
          ||'                       WHERE PERIODFROM >= TO_DATE('''||P_FROMDATE||''', ''DD/MM/YYYY'')  '||CHR(10)
          ||'                         AND PERIODTO <= TO_DATE('''||P_TODATE||''', ''DD/MM/YYYY'')  '||CHR(10)
          ||'                         AND X.COMPANYCODE = '''||P_COMPANYCODE||''' '||CHR(10)
          ||'                         AND X.DIVISIONCODE = '''||P_DIVISIONCODE||'''  '||CHR(10)
          ||'                         AND X.TOKENNO = XX.TOKENNO     '||CHR(10)
          ||'                         AND X.COMPANYCODE = CAT.COMPANYCODE  '||CHR(10)
          ||'                         AND X.DIVISIONCODE = CAT.DIVISIONCODE  '||CHR(10)
          ||'                         AND X.CATEGORYCODE = CAT.CATEGORYCODE'||CHR(10)
          ||'   AND CAT.WAGESPERIODTYPE='''||P_RPTOPT||''' '||CHR(10)
          ||'                     ) E  '||CHR(10)
          ||'                WHERE A.COMPANYCODE = B.COMPANYCODE  '||CHR(10)
          ||'                  AND A.DIVISIONCODE = B.DIVISIONCODE  '||CHR(10)
          ||'                  AND A.WORKERSERIAL = B.WORKERSERIAL  '||CHR(10)
          ||'                  AND A.COMPANYCODE = C.COMPANYCODE (+) '||CHR(10)
          ||'                  AND A.DIVISIONCODE = C.DIVISIONCODE (+)  '||CHR(10)
          ||'                  AND A.WORKERSERIAL = C.WORKERSERIAL (+)  '||CHR(10)  
          ||'                  AND A.COMPANYCODE = D.COMPANYCODE  '||CHR(10)
          ||'                  AND A.DIVISIONCODE = D.DIVISIONCODE  '||CHR(10)
          ||'                  AND A.WORKERSERIAL = D.WORKERSERIAL  '||CHR(10)
          ||'                  AND A.COMPANYCODE = E.COMPANYCODE  '||CHR(10)
          ||'                  AND A.DIVISIONCODE = E.DIVISIONCODE  '||CHR(10)
          ||'                  AND A.WORKERSERIAL = E.WORKERSERIAL  '||CHR(10);
         IF P_ATTN IS NOT NULL THEN
             LV_SQLSTR := LV_SQLSTR ||'  AND D.ATTNBOOKCODE IN ('||P_ATTN||')   '||CHR(10);
          END IF;
         IF P_CLUSTER IS NOT NULL THEN
             LV_SQLSTR := LV_SQLSTR ||'  AND D.CLUSTERCODE IN ('||P_CLUSTER||')   '||CHR(10);
          END IF;
          LV_SQLSTR := LV_SQLSTR ||' GROUP BY A.TOKENNO , A.PFNO, A.NAME, A.NETPAY, B.SK_DAYS, '||CHR(10)
                ||' B.MT_DAYS, B.AL_DAYS, B.WP_DAYS, B.HOLIDAYS, B.PRESENTDAYS,  NVL(E.INCENTIVE, 0) , NVL(E.SPL_ALLOW, 0) , NVL(E.SPRAY_ALLOW, 0) ,'||CHR(10)  
                ||' NVL(E.FACT_ALOW, 0) , NVL(E.EXTRA, 0) , NVL(E.ATTN_ALLOW, 0) ,  '||CHR(10)
                ||' NVL(E.GROSSWAGES, 0) , NVL(E.COINBF, 0) , NVL(E.PF_E, 0) , NVL(E.PTAX, 0) ,   '||CHR(10)
                ||' NVL(E.ADVANCE, 0) , NVL(E.PF_LOAN, 0) , NVL(E.PF_INT, 0) ,  '||CHR(10)
                ||' NVL(E.MD_LOAN, 0) , NVL(E.RAT_DED, 0),  NVL(E.LIC_DED, 0) , NVL(E.DED_ELEC, 0) ,  '||CHR(10)
                ||' NVL(E.DED_WELFARE, 0) , NVL(E.DED_UNION, 0) ,  '||CHR(10)
                ||' NVL(E.GROSSDEDN, 0) , NVL(E.COINCF, 0),TOT_EARN,TOT_DED  ,NVL(E.OT_AMOUNT,0)  , NVL(E.temp_DED,0) ,  nvl(E.PF_FC_GROSS,0),nvl(E.PF_FC_GROSS,0),NVL(E.FUEL_ALLOW,0),NVL(DED_LPG,0),NVL(OTHER_DED,0) '||CHR(10)
               -- ||' ORDER BY A.TOKENNO  '||CHR(10)
                                 ||'  ) XXX   '||CHR(10)
            ||' ORDER BY EMP_CODE  '||CHR(10);
              
          
          
             DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
             EXECUTE IMMEDIATE LV_SQLSTR;    
     
             UPDATE GTT_WAGES_REGISTER_STDFRMT A
                SET (COMPANYNAME,DIVISIONNAME) = (SELECT B.COMPANYNAME,C.DIVISIONNAME
               FROM COMPANYMAST B, DIVISIONMASTER C
              WHERE B.COMPANYCODE= P_COMPANYCODE
                AND B.COMPANYCODE=C.COMPANYCODE
                AND C.DIVISIONCODE= P_DIVISIONCODE);
     

END;
/