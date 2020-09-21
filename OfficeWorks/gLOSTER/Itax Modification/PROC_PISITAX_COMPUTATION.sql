CREATE OR REPLACE PROCEDURE GLOSTER_WEB.PROC_PISITAX_COMPUTATION
--exec PROC_PISITAX_COMPUTATION ('0001', '0002', '2019-2020','SS','SREG', '00378')
(
    P_COMPANYCODE    VARCHAR2,
    P_DIVISIONCODE   VARCHAR2,
    P_YEARCODE       VARCHAR2,
    P_CATEGORY       VARCHAR2 DEFAULT NULL,
    P_GRADE          VARCHAR2 DEFAULT NULL,
    P_TOKENNO        VARCHAR2 DEFAULT NULL
)
 AS
  LV_SQLSTR           VARCHAR2(3000) := '';
  LV_CNT              NUMBER         := 0;
  LV_ACTLY            NUMBER(15,2)   := 0;
  LV_PRJCT            NUMBER(15,2)   := 0;
  LV_COLUMNNO         VARCHAR2(50)   :='';
  LV_COLNO            VARCHAR2(50)   :='';
  LV_TEMPTAB          VARCHAR2(50)   :='';
  LV_YEARMONTH        VARCHAR2(50)   :='';
  LV_NOOFMONTH        VARCHAR2(10)   :='';
  LV_FIN_STARTDATE    VARCHAR2(10)   :='';
  LV_FIN_ENDDATE      VARCHAR2(10)   :='';
  LV_GENDER           VARCHAR2(30)   :='';  
  LV_ACTUAL          NUMBER         := 0;
  LV_PROJEC          NUMBER         := 0;
  LV_MANUAL          NUMBER         := 0;
  
  
  --ADDED BY CHIRANJIT GHOSH 12/07/2020

    LV_FORMULA_ACT VARCHAR2(1000);
    LV_VALUE_ACT NUMBER(18,2);

    LV_FORMULA_PROJ VARCHAR2(1000);
    LV_VALUE_PROJ NUMBER(18,2);

    LV_FORMULA_MANU VARCHAR2(1000);
    LV_VALUE_MANU NUMBER(18,2);

  BEGIN
  
  
     SELECT DISTINCT STARTDATE, ENDDATE INTO LV_FIN_STARTDATE, LV_FIN_ENDDATE  FROM FINANCIALYEAR
     WHERE YEARCODE = P_YEARCODE;
  
  
  
      SELECT COUNT(*) INTO LV_CNT 
        FROM PISITAXPARAM
        WHERE COMPANYCODE=P_COMPANYCODE
        AND DIVISIONCODE=P_DIVISIONCODE
        AND YEARCODE=P_YEARCODE
        AND NVL(DISPLAYINGRID,'N')<>'N';
       ------DBMS_OUTPUT.PUT_LINE('LV_CNT : '||LV_CNT); 
  
      IF LV_CNT>0 THEN
      
       DELETE FROM GTTPISITAXCOMPUTATION ;
       
       LV_SQLSTR:= ' DELETE FROM PISITAXATTRIBUTEVALUE '||CHR(10)
            ||' WHERE COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
            ||' AND DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
            ||' AND YEARCODE='''||P_YEARCODE||''' '||CHR(10);              
--             IF NVL(P_TOKENNO,'NA')<>'NA' THEN
--                LV_SQLSTR:= LV_SQLSTR ||' AND TOKENNO='''||P_TOKENNO||''' '|| CHR(10);
--             END IF;
     
             EXECUTE IMMEDIATE LV_SQLSTR ;COMMIT;  
             
             --------- FOR YEARMONTH BY SWEETY
              LV_SQLSTR:= ' SELECT MAX(YEARMONTH) FROM PISPAYTRANSACTION  '||CHR(10)
            ||' WHERE COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
            ||' AND DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
            ||' AND YEARCODE='''||P_YEARCODE||''' '||CHR(10);              
             IF NVL(P_CATEGORY,'NA')<>'NA' THEN
                    LV_SQLSTR:= LV_SQLSTR ||' AND CATEGORYCODE='''||P_CATEGORY||''' '|| CHR(10);
                 END IF;
             IF NVL(P_GRADE,'NA')<>'NA' THEN
                LV_SQLSTR:= LV_SQLSTR ||' AND GRADECODE='''||P_GRADE||''' '|| CHR(10);
             END IF;              
             
             ------DBMS_OUTPUT.PUT_LINE('LV_SQLSTR : '||LV_SQLSTR);
             
               EXECUTE IMMEDIATE LV_SQLSTR INTO LV_YEARMONTH;
             ---------END YEARMONTH
                            
--       ------DBMS_OUTPUT.PUT_LINE('1_1');                
       ------------ALL-----------------
       
       
      LV_SQLSTR:= ' INSERT INTO GTTPISITAXCOMPUTATION (COMPANYCODE,DIVISIONCODE,YEARCODE,WORKERSERIAL,TOKENNO,COLUMNNO,COMPONENTHEADER, COMPONENTCODE,COMPFORMULA,DISPLAYINGRID, CATEGORYCODE, GRADECODE,COMPMAXAMOUNT) '||CHR(10)  
                ||' SELECT DISTINCT A.COMPANYCODE,A.DIVISIONCODE,A.YEARCODE , '||CHR(10)
                ||' B.WORKERSERIAL,B.TOKENNO,A.COLUMNNO,A.COLUMNSUBHEADING ,COLUMNSUBHEADING1,COLUMNFORMULA,DISPLAYINGRID, B.CATEGORYCODE, B.GRADECODE, A.MAXAMOUNT '||CHR(10)
                ||' FROM PISITAXPARAM A ,PISEMPLOYEEMASTER B  '||CHR(10)
                ||' WHERE A.COMPANYCODE=B.COMPANYCODE  '||CHR(10)
                ||' AND A.DIVISIONCODE=B.DIVISIONCODE '||CHR(10)
                ||' AND A.COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
                ||' AND A.DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
                ||' AND A.YEARCODE='''||P_YEARCODE||''' '||CHR(10)
                ||' AND NVL(DISPLAYINGRID,''N'')<>''N'' '||CHR(10);
                --||' and B.WORKERSERIAL IS NOT NULL '||CHR(10);
                 IF NVL(P_CATEGORY,'NA')<>'NA' THEN
                    LV_SQLSTR:= LV_SQLSTR ||' AND B.CATEGORYCODE='''||P_CATEGORY||''' '|| CHR(10);
                 END IF;
                 IF NVL(P_GRADE,'NA')<>'NA' THEN
                    LV_SQLSTR:= LV_SQLSTR ||' AND B.GRADECODE='''||P_GRADE||''' '|| CHR(10);
                 END IF;
                 IF NVL(P_TOKENNO,'NA')<>'NA' THEN
                    LV_SQLSTR:= LV_SQLSTR ||' AND B.TOKENNO = '''||P_TOKENNO||''' '|| CHR(10);
                 END IF;                 
                 ------DBMS_OUTPUT.PUT_LINE('1_2 : '||LV_SQLSTR);
                 EXECUTE IMMEDIATE LV_SQLSTR ;COMMIT;
                       
        --------DBMS_OUTPUT.PUT_LINE('1_2');
            
        FOR T1 IN ( SELECT DISTINCT WORKERSERIAL,TOKENNO FROM GTTPISITAXCOMPUTATION )
        LOOP                
       
          FOR C1 IN ( SELECT DISTINCT COLUMNNO, COLUMNFORMULA ,COLUMNSOURCE,COLUMNATTRIBUTE ,COLUMNBASIS,COLUMNSUBHEADING1 ,COLUMNSUBHEADING2,
          decode(TRIM(TYPE),'YEARLY',1,'HALF YEARLY',2,'QUATERLY',3,12) TYPE, MAXAMOUNT
                    FROM PISITAXPARAM
                    WHERE COMPANYCODE= P_COMPANYCODE
                    AND DIVISIONCODE=P_DIVISIONCODE
                    AND YEARCODE=P_YEARCODE  
                    AND (COLUMNFORMULA IS NOT NULL OR COLUMNSOURCE IS NOT NULL)    
                    --UJJWAL
                   -- AND COLUMNATTRIBUTE='BASIC'     
                    ORDER BY COLUMNNO)
                    
                    
             LOOP     
             
             ----DBMS_OUTPUT.PUT_LINE('******------- COLUMNNO = '||C1.COLUMNNO||' , COLUMNSOURCE = '||C1.COLUMNSOURCE||' , COLUMNATTRIBUTE'||C1.COLUMNATTRIBUTE||' , COLUMNBASIS = '||C1.COLUMNBASIS||' , COLUMNSUBHEADING1'||C1.COLUMNSUBHEADING1); 
              
              ------------------------ FOR ATTRIBUTE VALUE------------------------- 
                IF NVL(C1.COLUMNSOURCE,'NA')<>'NA' THEN
              
                    LV_SQLSTR:= ' SELECT COUNT(*)  '  ||CHR(10)
                              ||' FROM '||C1.COLUMNSOURCE|| ' '||CHR(10) 
                              ||' WHERE COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
                              ||' AND DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
                              ||' AND YEARCODE='''||P_YEARCODE||''' '||CHR(10)
                              ||' AND WORKERSERIAL ='''||T1.WORKERSERIAL||''' '||CHR(10);
--                              ------DBMS_OUTPUT.PUT_LINE('INSERT ALL ROW : '||LV_SQLSTR); 
                        EXECUTE IMMEDIATE LV_SQLSTR INTO LV_CNT;
                      --  ------DBMS_OUTPUT.PUT_LINE('2_1 - '||C1.COLUMNNO||' QRY - '||LV_SQLSTR);
                  
                  IF LV_CNT>0 THEN
                    IF  C1.COLUMNSOURCE='PISPAYTRANSACTION' THEN
                        LV_SQLSTR:= 'INSERT INTO PISITAXATTRIBUTEVALUE  '||CHR(10)
                                  ||' (COMPANYCODE, DIVISIONCODE, YEARCODE, COLUMNNO, COLUMNATTRIBUTE, COMPACTUALVALUE,WORKERSERIAL,TOKENNO,YEARMONTH,CATEGORYCODE,GRADECODE) '||CHR(10)
                                  ||' SELECT '''||P_COMPANYCODE||''' COMPANYCODE , '''||P_DIVISIONCODE||''' DIVISIONCODE, '||CHR(10)
                                  ||' '''||P_YEARCODE||''' YEARCODE, '''||C1.COLUMNNO||''' COLUMNNO,'''||C1.COLUMNATTRIBUTE||''' COLUMNATTRIBUTE ,'|| CHR(10)
                                  ||' SUM(CASE WHEN '||NVL(C1.MAXAMOUNT,0)||' > 0 AND COMPACTUALVALUE > '||C1.MAXAMOUNT||' THEN '||C1.MAXAMOUNT||' ELSE  COMPACTUALVALUE END) COMPACTUALVALUE ,A.WORKERSERIAL ,B.TOKENNO,MAX(A.YEARMONTH) ,'''||P_CATEGORY||''','''||P_GRADE||''' '||CHR(10)
                                  ||' FROM ( '||CHR(10)
                                  ||'         SELECT WORKERSERIAL, SUM('||C1.COLUMNATTRIBUTE||') COMPACTUALVALUE, '''||LV_YEARMONTH||''' YEARMONTH '||CHR(10)
                                  ||'         FROM '||C1.COLUMNSOURCE|| ' '||CHR(10)
                                  ||'         WHERE COMPANYCODE = '''||P_COMPANYCODE||''' '||CHR(10)
                                  ||'           AND YEARCODE = '''||P_YEARCODE||''' '||CHR(10)
                                  ||'           AND WORKERSERIAL ='''||T1.WORKERSERIAL||''' '||CHR(10)
                                  ||'           GROUP BY WORKERSERIAL  '||CHR(10)
                                  ||'         UNION ALL '||CHR(10)
                                  ||'         SELECT WORKERSERIAL, SUM('||C1.COLUMNATTRIBUTE||') COMPACTUALVALUE ,'''||LV_YEARMONTH||''' YEARMONTH '||CHR(10)
                                  ||'         FROM PISARREARTRANSACTION '||CHR(10)
                                  ||'         WHERE COMPANYCODE = '''||P_COMPANYCODE||''' '||CHR(10)
                                  ||'           AND YEARCODE = '''||P_YEARCODE||''' '||CHR(10)
                                  --UJJWAL
--                                  ||'           AND TRANSACTIONTYPE =''MONTHLYARR'' '||CHR(10)
                                  ||'           AND TRANSACTIONTYPE =''ARREAR'' '||CHR(10)
                                  ||'           AND WORKERSERIAL ='''||T1.WORKERSERIAL||''' '||CHR(10)
                                  ||'           GROUP BY WORKERSERIAL  '||CHR(10)
                                  ||'      ) A, PISEMPLOYEEMASTER B' ||CHR(10)
                                  ||' WHERE B.COMPANYCODE = '''||P_COMPANYCODE||''' '||CHR(10)
                                  ||'   AND B.DIVISIONCODE = '''||P_DIVISIONCODE||''' '||CHR(10)
                                  ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
                                  ||' GROUP BY  A.WORKERSERIAL ,B.TOKENNO '||CHR(10);
                                  
                                  ------DBMS_OUTPUT.PUT_LINE('2_2 - ' ||LV_SQLSTR ); 
                                  EXECUTE IMMEDIATE LV_SQLSTR ;COMMIT; 
                                     
                       
                    
                    -- ADD BY PRASUN ON 14.01.2020
                    ELSIF C1.COLUMNSOURCE='PISBONUSDETAILS' THEN
                            
                        LV_SQLSTR:= 'INSERT INTO PISITAXATTRIBUTEVALUE  '||CHR(10)
                              ||' (COMPANYCODE, DIVISIONCODE, YEARCODE, COLUMNNO, COLUMNATTRIBUTE, COMPACTUALVALUE,WORKERSERIAL,TOKENNO,YEARMONTH,CATEGORYCODE,GRADECODE) '||CHR(10)       
                              ||' SELECT '''||P_COMPANYCODE||''' COMPANYCODE , '''||P_DIVISIONCODE||''' DIVISIONCODE, '||CHR(10)
                              ||' '''||P_YEARCODE||''' YEARCODE, '''||C1.COLUMNNO||''' COLUMNNO,'''||C1.COLUMNATTRIBUTE||''' COLUMNATTRIBUTE ,'|| CHR(10)
                              ||' NVL(SUM('||C1.COLUMNATTRIBUTE||'),0) COMPACTUALVALUE, WORKERSERIAL,TOKENNO, '''||LV_YEARMONTH||''' YEARMONTH ,'''||P_CATEGORY||''','''||P_GRADE||''' '||CHR(10)
                              ||' FROM PISBONUSDETAILS   '|| CHR(10)
                              ||' WHERE TRANSACTIONTYPE = ''BONUS PAYMENT'' '|| CHR(10)
                              ||' AND PAYMENTDATE BETWEEN  '''||LV_FIN_STARTDATE||''' AND '''||LV_FIN_ENDDATE||''' '|| CHR(10);
                           
                            --   ------DBMS_OUTPUT.PUT_LINE('2_3 ' || LV_SQLSTR);  -------------
                                EXECUTE IMMEDIATE LV_SQLSTR ;COMMIT; 
                                
                                
                    ELSIF C1.COLUMNSOURCE='PISREIMBURSEMENTDETAILS' THEN
                    
                          LV_SQLSTR:= 'INSERT INTO PISITAXATTRIBUTEVALUE  '||CHR(10)
                                  ||' (COMPANYCODE, DIVISIONCODE, YEARCODE, COLUMNNO, COLUMNATTRIBUTE, COMPACTUALVALUE,WORKERSERIAL,TOKENNO,YEARMONTH,CATEGORYCODE,GRADECODE) '||CHR(10)
                                  ||' SELECT '''||P_COMPANYCODE||''' COMPANYCODE , '''||P_DIVISIONCODE||''' DIVISIONCODE, '||CHR(10)
                                  ||' '''||P_YEARCODE||''' YEARCODE, '''||C1.COLUMNNO||''' COLUMNNO,'''||C1.COLUMNATTRIBUTE||''' COLUMNATTRIBUTE ,'|| CHR(10)
                                  ||' NVL(SUM('||C1.COLUMNATTRIBUTE||'),0) COMPACTUALVALUE ,B.WORKERSERIAL ,B.TOKENNO,'''||LV_YEARMONTH||''' YEARMONTH ,'''||P_CATEGORY||''','''||P_GRADE||''' '||CHR(10)
                                  ||' FROM '||C1.COLUMNSOURCE||' A, PISEMPLOYEEMASTER B'||CHR(10) 
                                  ||' WHERE B.COMPANYCODE ='''||P_COMPANYCODE||''' '||CHR(10)
                                  ||' AND A.YEARCODE (+)='''||P_YEARCODE||''' '||CHR(10)
                                  ||' AND B.WORKERSERIAL ='''||T1.WORKERSERIAL||''' '||CHR(10)
                                  ||' AND B.COMPANYCODE = A.COMPANYCODE (+) AND B.WORKERSERIAL = A.WORKERSERIAL (+) '||CHR(10)
                                  ||' AND A.COMPONENTCODE (+)= '''||C1.COLUMNSUBHEADING1||''' '||CHR(10)
                                  ||' GROUP BY B.WORKERSERIAL, B.TOKENNO '||CHR(10);
                        IF NVL(C1.COLUMNBASIS,'NA')<>'NA' THEN          
                           IF NVL(C1.COLUMNATTRIBUTE,'NA')<> NVL(C1.COLUMNBASIS,'NA') THEN
                                LV_SQLSTR:= LV_SQLSTR ||' AND '||C1.COLUMNBASIS|| '='''||C1.COLUMNSUBHEADING2||''' '|| CHR(10);
                           END IF;
                       END IF;
                     --  ------DBMS_OUTPUT.PUT_LINE('LV_SQLSTR ' || LV_SQLSTR);  -------------
                      --  ------DBMS_OUTPUT.PUT_LINE('2_4 ' || LV_SQLSTR);  -------------
                       EXECUTE IMMEDIATE LV_SQLSTR ;COMMIT;      
                              
                    --  END  ADD BY PRASUN ON 14.01.2020                                  
                    ELSE
                                                                    
                        LV_SQLSTR:= 'INSERT INTO PISITAXATTRIBUTEVALUE  '||CHR(10)
                                  ||' (COMPANYCODE, DIVISIONCODE, YEARCODE, COLUMNNO, COLUMNATTRIBUTE, COMPACTUALVALUE,WORKERSERIAL,TOKENNO,YEARMONTH,CATEGORYCODE,GRADECODE) '||CHR(10)
                                  ||' SELECT '''||P_COMPANYCODE||''' COMPANYCODE , '''||P_DIVISIONCODE||''' DIVISIONCODE, '||CHR(10)
                                  ||' '''||P_YEARCODE||''' YEARCODE, '''||C1.COLUMNNO||''' COLUMNNO,'''||C1.COLUMNATTRIBUTE||''' COLUMNATTRIBUTE ,'|| CHR(10)
                                -- change 30042020 
                                  ||' NVL(SUM('||C1.COLUMNATTRIBUTE||'),0) COMPACTUALVALUE ,            '|| CHR(10) ;                                
--                                  if C1.COLUMNSOURCE='PISPAYINVESTMENT' then
--                                         LV_SQLSTR:= LV_SQLSTR ||' case when a.columnno='''||C1.COLUMNNO||''' then  NVL(SUM('||C1.COLUMNATTRIBUTE||'),0) else 0 end COMPACTUALVALUE ,';
--                                  else
--                                         LV_SQLSTR:= LV_SQLSTR ||' NVL(SUM('||C1.COLUMNATTRIBUTE||'),0) COMPACTUALVALUE ,';
--                                  end if;                                                                    
                                  -- End change 30042020 
                                   LV_SQLSTR:= LV_SQLSTR ||' A.WORKERSERIAL ,B.TOKENNO,'''||LV_YEARMONTH||''' YEARMONTH ,'''||P_CATEGORY||''','''||P_GRADE||''' '||CHR(10)
                                  ||' FROM '||C1.COLUMNSOURCE||' A, PISEMPLOYEEMASTER B'||CHR(10) 
                                  ||' WHERE A.COMPANYCODE (+)='''||P_COMPANYCODE||''' '||CHR(10)
                                  ||' AND A.YEARCODE (+)='''||P_YEARCODE||''' '||CHR(10)
                                  ||' AND B.WORKERSERIAL ='''||T1.WORKERSERIAL||''' '||CHR(10)
                                  ||' AND B.COMPANYCODE = A.COMPANYCODE AND B.WORKERSERIAL = A.WORKERSERIAL (+)  '||CHR(10);
                                  -- change 30042020 
                                   if C1.COLUMNSOURCE='PISPAYINVESTMENT' then
--                                     LV_SQLSTR:= LV_SQLSTR ||' and a.columnno='''||C1.COLUMNNO||'''  '||CHR(10);
                                     LV_SQLSTR:= LV_SQLSTR ||' and a.INVESTMENTCODE=NVL('''||C1.COLUMNSUBHEADING2||''',a.INVESTMENTCODE)'||CHR(10);
                                   end if;
                                  -- End change 30042020 
                                                              
                            -- change 30042020
                            --    ||' GROUP BY A.WORKERSERIAL, B.TOKENNO '||CHR(10);
                            --End change 30042020
                        IF NVL(C1.COLUMNBASIS,'NA')<>'NA' THEN          
                           IF NVL(C1.COLUMNATTRIBUTE,'NA')<> NVL(C1.COLUMNBASIS,'NA') THEN
                                LV_SQLSTR:= LV_SQLSTR ||' AND '||C1.COLUMNBASIS|| '='''||C1.COLUMNSUBHEADING2||''' '|| CHR(10);
                           END IF;
                       END IF;
                       
                       --change 30042020
                        LV_SQLSTR:= LV_SQLSTR ||' GROUP BY A.WORKERSERIAL, B.TOKENNO ';
                        -- Emd change 30042020
--                        
--                        if C1.COLUMNSOURCE='PISPAYINVESTMENT' then
--                            LV_SQLSTR:= LV_SQLSTR ||', COLUMNNO '||CHR(10);
--                        end if;
                       
                       
                       ----DBMS_OUTPUT.PUT_LINE('LV_SQLSTR ' || LV_SQLSTR);  -------------
                      -- ------DBMS_OUTPUT.PUT_LINE('2_5 ' || LV_SQLSTR);  -------------
                       EXECUTE IMMEDIATE LV_SQLSTR ;COMMIT; 
                    END IF;
                     --------DBMS_OUTPUT.PUT_LINE('ATTRI INSERT : COL NO. '||C1.COLUMNNO||' -  '||LV_SQLSTR);
                     --EXECUTE IMMEDIATE LV_SQLSTR ;COMMIT;   
                  ELSE
                  /*
                    LV_SQLSTR:= 'INSERT INTO PISITAXATTRIBUTEVALUE  '||CHR(10)
                              ||' (COMPANYCODE, DIVISIONCODE, YEARCODE, COLUMNNO, COLUMNATTRIBUTE, COMPACTUALVALUE,WORKERSERIAL,TOKENNO,YEARMONTH,CATEGORYCODE,GRADECODE) '||CHR(10)
                              ||' SELECT '''||P_COMPANYCODE||''' COMPANYCODE , '''||P_DIVISIONCODE||''' DIVISIONCODE, '||CHR(10)
                              ||' '''||P_YEARCODE||''' YEARCODE, '''||C1.COLUMNNO||''' COLUMNNO,'''||C1.COLUMNATTRIBUTE||''' COLUMNATTRIBUTE ,'|| CHR(10)
                              ||' 0 COMPACTUALVALUE ,WORKERSERIAL ,TOKENNO,MAX(YEARMONTH) ,'''||P_CATEGORY||''','''||P_GRADE||''' '||CHR(10)
                              ||' FROM PISEMPLOYEEMASTER '||CHR(10) 
                              ||' WHERE COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
                              ||' AND DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
                              ||' AND WORKERSERIAL ='''||T1.WORKERSERIAL||''' '||CHR(10);  */
                              
                    LV_SQLSTR:= 'INSERT INTO PISITAXATTRIBUTEVALUE  '||CHR(10)
                              ||' (COMPANYCODE, DIVISIONCODE, YEARCODE, COLUMNNO, COLUMNATTRIBUTE, COMPACTUALVALUE,WORKERSERIAL,TOKENNO,YEARMONTH,CATEGORYCODE,GRADECODE) '||CHR(10)
                              ||' SELECT '''||P_COMPANYCODE||''' COMPANYCODE , '''||P_DIVISIONCODE||''' DIVISIONCODE, '||CHR(10)
                              ||' '''||P_YEARCODE||''' YEARCODE, '''||C1.COLUMNNO||''' COLUMNNO,'''||C1.COLUMNATTRIBUTE||''' COLUMNATTRIBUTE ,'|| CHR(10)
                              ||' 0 COMPACTUALVALUE ,A.WORKERSERIAL ,B.TOKENNO,'''||LV_YEARMONTH||''' YEARMONTH ,'''||P_CATEGORY||''','''||P_GRADE||''' '||CHR(10)
                              ||' FROM '||C1.COLUMNSOURCE||' A, PISEMPLOYEEMASTER B  '||CHR(10) 
                              ||' WHERE A.COMPANYCODE (+)= '''||P_COMPANYCODE||''' '||CHR(10)
                              ||' AND A.DIVISIONCODE (+)= '''||P_DIVISIONCODE||''' '||CHR(10)
                              ||' AND A.YEARCODE (+)='''||P_YEARCODE||''' '||CHR(10)
                              ||' AND B.WORKERSERIAL(+) ='''||T1.WORKERSERIAL||''' '||CHR(10)
                              ||' AND B.COMPANYCODE = A.COMPANYCODE (+) AND B.WORKERSERIAL = A.WORKERSERIAL (+)  '||CHR(10)
                              ||' GROUP BY A.WORKERSERIAL, B.TOKENNO      '||CHR(10);                

                   --------DBMS_OUTPUT.PUT_LINE('ATTRI INSERT : COL NO. '||C1.COLUMNNO||' -  '||LV_SQLSTR);
                   --  ------DBMS_OUTPUT.PUT_LINE('2_6 ' || LV_SQLSTR);  -------------
                     EXECUTE IMMEDIATE LV_SQLSTR ;COMMIT;  
                  END IF;   
                  --  LV_SQLSTR:= LV_SQLSTR  ||' GROUP BY WORKERSERIAL ,TOKENNO '||CHR(10);
--                 ------DBMS_OUTPUT.PUT_LINE('ATTRI INSERT : COL NO. '||C1.COLUMNNO||' -  '||LV_SQLSTR);
--                     EXECUTE IMMEDIATE LV_SQLSTR ;COMMIT;   
                                              
                 --COMMENTED BY SWEETY FOR YEAR MONTH
                 ---SELECT MAX(YEARMONTH) INTO LV_YEARMONTH FROM PISITAXATTRIBUTEVALUE;
                -- ------DBMS_OUTPUT.PUT_LINE('2_5');
                                                  
                --UJJWAL                  
--                 select TRUNC(MONTHS_BETWEEN (TO_DATE('31/03/'||(SUBSTR(LV_YEARMONTH,0,4)+1),'DD/MM/YY'),TO_DATE('01/'||SUBSTR(LV_YEARMONTH,5,2)||SUBSTR(LV_YEARMONTH,0,4) ,'DD/MM/YY')),0)
--                 INTO LV_NOOFMONTH   FROM DUAL;

                 SELECT 
                 TRUNC(MONTHS_BETWEEN (CASE WHEN TO_NUMBER(SUBSTR(LV_YEARMONTH,5,2)) <=3  
                 THEN TO_DATE('31/03/'||(SUBSTR(LV_YEARMONTH,0,4)),'DD/MM/YYYY') 
                 ELSE TO_DATE('31/03/'||(SUBSTR(LV_YEARMONTH,0,4)+1),'DD/MM/YYYY') 
                 END ,TO_DATE('01/'||SUBSTR(LV_YEARMONTH,5,2)||SUBSTR(LV_YEARMONTH,0,4) ,'DD/MM/YY')),0) B
                 INTO LV_NOOFMONTH  
                 FROM DUAL;
                      
                 --------DBMS_OUTPUT.PUT_LINE('2_6');   
                 ------DBMS_OUTPUT.PUT_LINE('LV_YEARMONTH : '||LV_YEARMONTH);           
                 PRC_PISVIEWCREATION (P_COMPANYCODE,P_DIVISIONCODE,'PISASSIGN',0,LV_YEARMONTH,LV_YEARMONTH, 'SALARY', 'PISPAYTRANSACTION_SWT');
                 
                 
                                                             
                                 
                 LV_SQLSTR:= ' SELECT COUNT(*) FROM COLS  '  ||CHR(10)
                           ||' WHERE TABLE_NAME = ''PISASSIGN'' AND COLUMN_NAME='''||C1.COLUMNATTRIBUTE||''' '||CHR(10);
                 EXECUTE IMMEDIATE LV_SQLSTR INTO LV_CNT;                                                                  
--                 ------DBMS_OUTPUT.PUT_LINE('2_7');            
                   IF LV_CNT> 0 THEN                             
                            --UJJWAL 30042020
--                           LV_SQLSTR:= 'UPDATE  PISITAXATTRIBUTEVALUE SET COMPPROJCTEDVALUE = COMPACTUALVALUE + '||CHR(10)
                           LV_SQLSTR:= 'UPDATE  PISITAXATTRIBUTEVALUE SET COMPPROJCTEDVALUE =  '||CHR(10)
--                           ||'  ( SELECT SUM('||C1.COLUMNATTRIBUTE||'  * '||LV_NOOFMONTH||')  FROM PISASSIGN A ,PISEMPLOYEEMASTER B   '||CHR(10)
                           ||'  ( SELECT (SUM(CASE WHEN '||C1.MAXAMOUNT||' > 0 AND '||C1.COLUMNATTRIBUTE||' > '||C1.MAXAMOUNT||' THEN '||C1.MAXAMOUNT||' ELSE '||C1.COLUMNATTRIBUTE||' END)  * '||C1.TYPE||')  FROM PISASSIGN A ,PISEMPLOYEEMASTER B   '||CHR(10)
                           ||'        WHERE A.COMPANYCODE=B.COMPANYCODE  '||CHR(10)
                           ||'        AND A.DIVISIONCODE=B.DIVISIONCODE '||CHR(10)
                           ||'        AND A.WORKERSERIAL =B.WORKERSERIAL '||CHR(10)
                           ||'        AND A.COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
                           ||'        AND A.DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
                           ||'        AND A.WORKERSERIAL ='''||T1.WORKERSERIAL||''' '||CHR(10)
                           ||'        AND B.EMPLOYEESTATUS=''ACTIVE'')'||CHR(10)
                           ||' WHERE COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
                           ||' AND DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
                           ||' AND YEARCODE='''||P_YEARCODE||''' '||CHR(10)
                           ||' AND COLUMNNO='''||C1.COLUMNNO||''' ' ||CHR(10)
                           ||' AND COLUMNATTRIBUTE='''||C1.COLUMNATTRIBUTE||''' ' ||CHR(10)
                           ||' AND WORKERSERIAL ='''||T1.WORKERSERIAL||''' '||CHR(10);   
                             --DBMS_OUTPUT.PUT_LINE('2_7 SEEE>0 : '||LV_SQLSTR); 
                           EXECUTE IMMEDIATE LV_SQLSTR ;                                    
                   ELSE
                           
                        IF NVL(C1.COLUMNSOURCE,'NA')='PISPAYTRANSACTION' THEN 
                            LV_SQLSTR:= 'UPDATE  PISITAXATTRIBUTEVALUE SET COMPPROJCTEDVALUE =  '||CHR(10)
--                           ||'  ( SELECT (SUM('||C1.COLUMNATTRIBUTE||') * '||LV_NOOFMONTH||')/ '||C1.TYPE||') FROM '||C1.COLUMNSOURCE||' A ,PISEMPLOYEEMASTER B '||CHR(10)
                           ||' ('||CHR(10);
                            ----*************************************
--                           ||'  (     SELECT (MAX('||C1.COLUMNATTRIBUTE||') * '||C1.TYPE||') FROM '||C1.COLUMNSOURCE||' A ,PISEMPLOYEEMASTER B '||CHR(10)
--                           ||'        WHERE A.COMPANYCODE=B.COMPANYCODE  '||CHR(10)
--                           ||'        AND A.DIVISIONCODE=B.DIVISIONCODE '||CHR(10)
--                           ||'        AND A.WORKERSERIAL =B.WORKERSERIAL '||CHR(10)
--                           ||'        AND A.COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
--                           ||'        AND A.DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
--                           ||'        AND A.WORKERSERIAL ='''||T1.WORKERSERIAL||''' '||CHR(10)
--                           ||'        AND A.YEARCODE ='''||P_YEARCODE||''' '||CHR(10)
--                           ||'        AND B.EMPLOYEESTATUS=''ACTIVE'' '||CHR(10);
----                           ||'        WHERE COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
----                           ||'        AND DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
----                           ||'       AND WORKERSERIAL ='''||T1.WORKERSERIAL||''' '||CHR(10);
--                           IF C1.COLUMNSOURCE='PISCOMPONENTASSIGNMENT' THEN
--                               LV_SQLSTR:= LV_SQLSTR  ||' AND TRANSACTIONTYPE=''ASSIGNMENT'' '|| CHR(10);
--                           END IF;

                            ----*************************************
                            
                            LV_SQLSTR:= LV_SQLSTR||'SELECT  FN_GET_COMP_VAL_PROJECTED('''||P_COMPANYCODE||''','''||P_DIVISIONCODE||''','''||C1.COLUMNATTRIBUTE||''','''||T1.WORKERSERIAL||''','''||P_YEARCODE||''','''||C1.TYPE||''') FROM DUAL'||CHR(10);
                            
                            LV_SQLSTR:= LV_SQLSTR||'       ) '||CHR(10)
                            
                           ||' WHERE COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
                           ||' AND DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
                           ||' AND YEARCODE='''||P_YEARCODE||''' '||CHR(10)
                           ||' AND COLUMNATTRIBUTE='''||C1.COLUMNATTRIBUTE||''' ' ||CHR(10)
                           ||' AND COLUMNNO='''||C1.COLUMNNO||''' ' ||CHR(10)
                           ||' AND WORKERSERIAL ='''||T1.WORKERSERIAL||''' '||CHR(10);   
                               --DBMS_OUTPUT.PUT_LINE('2_8 SEEE  ELSE : '||LV_SQLSTR); 
                               EXECUTE IMMEDIATE LV_SQLSTR ;         
                      END IF;  
                    END IF;  
                                                                                           
                             
                ELSE
                    LV_SQLSTR:= 'INSERT INTO PISITAXATTRIBUTEVALUE  '||CHR(10)
                          ||' (COMPANYCODE, DIVISIONCODE, YEARCODE, COLUMNNO, COLUMNATTRIBUTE, COMPACTUALVALUE,WORKERSERIAL,TOKENNO,YEARMONTH,CATEGORYCODE,GRADECODE) '||CHR(10)
                          ||' SELECT '''||P_COMPANYCODE||''' COMPANYCODE , '''||P_DIVISIONCODE||''' DIVISIONCODE, '||CHR(10)
                          ||' '''||P_YEARCODE||''' YEARCODE, '''||C1.COLUMNNO||''' COLUMNNO,'''||C1.COLUMNATTRIBUTE||''' COLUMNATTRIBUTE ,'|| CHR(10)
                          ||' 0 COMPACTUALVALUE ,'''||T1.WORKERSERIAL||'''  ,'''||T1.TOKENNO||''' ,NULL ,'''||P_CATEGORY||''','''||P_GRADE||''' '||CHR(10)
                          ||' FROM DUAL '||CHR(10);
                      --     ------DBMS_OUTPUT.PUT_LINE('2_9 : '||LV_SQLSTR);
                         EXECUTE IMMEDIATE LV_SQLSTR ;COMMIT;   
                                                    
                   END IF;      
                                
--                ------DBMS_OUTPUT.PUT_LINE('2_8'); 
                UPDATE PISITAXATTRIBUTEVALUE SET COMPMANUALVALUE=COMPPROJCTEDVALUE; 
                COMMIT;       
--                RETURN;
                --------DBMS_OUTPUT.PUT_LINE('COLUMNSUBHEADING1 '||C1.COLUMNSUBHEADING1);
--                ------DBMS_OUTPUT.PUT_LINE('COLUMNFORMULA '||C1.COLUMNFORMULA);
              
              
               -- START ADDED BY PRASUN ON 13.01.2020
               
               IF  C1.COLUMNSOURCE <> 'PISPAYTRANSACTION' THEN
               --DBMS_OUTPUT.PUT_LINE('COLUMNSOURCE '||C1.COLUMNSOURCE||CHR(10));
                
                       
                   LV_SQLSTR:= ' UPDATE PISITAXATTRIBUTEVALUE A ' || CHR(10)
                   ||' SET A.COMPPROJCTEDVALUE = A.COMPACTUALVALUE, A.COMPMANUALVALUE = A.COMPACTUALVALUE ' ||CHR(10)
                   ||' WHERE COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
                   ||' AND DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
                   ||' AND COLUMNNO='''||C1.COLUMNNO||''' '||CHR(10)
                   ||' AND YEARCODE='''||P_YEARCODE||''' '||CHR(10)
                   ||' AND COLUMNATTRIBUTE='''||C1.COLUMNATTRIBUTE||''' ' ||CHR(10);
                   --||' AND A.WORKERSERIAL = (SELECT WORKERSERIAL FROM PISEMPLOYEEMASTER WHERE WORKERSERIAL = '''||T1.WORKERSERIAL||'''  AND EMPLOYEESTATUS = ''Y''  ) ' ||CHR(10);
                        
                     ----DBMS_OUTPUT.PUT_LINE('LV_SQLSTR ' || LV_SQLSTR);              
                     EXECUTE IMMEDIATE LV_SQLSTR;COMMIT; 
                       
                END IF;  
                     
--                END ADDED BY PRASUN ON 13.01.2020  
              
               --------DBMS_OUTPUT.PUT_LINE('1111 - '||C1.COLUMNFORMULA);
                
               IF NVL(C1.COLUMNFORMULA,'~NA')<>'~NA' THEN     
                       ------DBMS_OUTPUT.PUT_LINE('FUNCTION C1.COLUMNNO : '||C1.COLUMNNO||' C1.COLUMNFORMULA : '||C1.COLUMNFORMULA);
--                    --------DBMS_OUTPUT.PUT_LINE('2_8_1 - '||C1.COLUMNNO||', '||C1.COLUMNFORMULA);
                    --------DBMS_OUTPUT.PUT_LINE(P_COMPANYCODE||'-----'||P_DIVISIONCODE||'-----'||C1.COLUMNNO||'-----'||C1.COLUMNFORMULA);
               
               
                    LV_ACTLY:=round(nvl(fn_get_itax_calc_value(P_COMPANYCODE ,P_DIVISIONCODE,C1.COLUMNNO,C1.COLUMNFORMULA,'ACTUAL',P_YEARCODE),0),2);
--                    --------DBMS_OUTPUT.PUT_LINE('2_8_2');
                    
                   
                   
                    LV_PRJCT:=round(nvl(fn_get_itax_calc_value(P_COMPANYCODE ,P_DIVISIONCODE,C1.COLUMNNO,C1.COLUMNFORMULA,'PROJECTED',P_YEARCODE),0),2)  ;  
                    
                    
--                    IF C1.COLUMNNO = '01_02_99' THEN
--                        
--                        --------DBMS_OUTPUT.PUT_LINE('C1.COLUMNFORMULA '||C1.COLUMNFORMULA);
--                        ----------DBMS_OUTPUT.PUT_LINE('LV_PRJCT '||LV_PRJCT);
--                    END IF;
                    
                                         
--                    --------DBMS_OUTPUT.PUT_LINE('2_8_3');  
                  
                  -- START ADDED BY PRASUN ON 14.01.2020 TO AVOID DUPLICATION
                  
                   LV_SQLSTR:= 'DELETE FROM PISITAXATTRIBUTEVALUE '||CHR(10)
                              ||'WHERE COMPANYCODE = '''||P_COMPANYCODE||'''   '||CHR(10)
                              ||'AND DIVISIONCODE = '''||P_DIVISIONCODE||''' '||CHR(10)
                              ||'AND YEARCODE = '''||P_YEARCODE||''' '||CHR(10)
                              ||'AND WORKERSERIAL = '''||T1.WORKERSERIAL||''' '||CHR(10)
                              ||'AND COLUMNNO = '''||C1.COLUMNNO||'''  '||CHR(10);
                           
                    EXECUTE IMMEDIATE LV_SQLSTR;           
                  
                  --  END ADDED BY PRASUN ON 14.01.2020  
                             
                    LV_SQLSTR:= 'INSERT INTO PISITAXATTRIBUTEVALUE  '||CHR(10)
                             ||' (COMPANYCODE, DIVISIONCODE, YEARCODE, COLUMNNO ,WORKERSERIAL,TOKENNO,CATEGORYCODE,GRADECODE ,'||CHR(10)
                             ||' COMPACTUALVALUE,COMPPROJCTEDVALUE,COMPMANUALVALUE ) '||CHR(10)
                             ||' SELECT '''||P_COMPANYCODE||''' COMPANYCODE , '''||P_DIVISIONCODE||''' DIVISIONCODE, '||CHR(10)
                             ||' '''||P_YEARCODE||''' YEARCODE, '''||C1.COLUMNNO||''' COLUMNNO,'''||T1.WORKERSERIAL||''' ,'||CHR(10)
                             ||' '''||T1.TOKENNO||''' ,'''||P_CATEGORY||''','''||P_GRADE||''' , '||CHR(10)
                             ||' '||LV_ACTLY||'  COMPACTUALVALUE, '||CHR(10) 
                             ||' '||LV_PRJCT||' COMPPROJCTEDVALUE, '||CHR(10)
                             ||' '||LV_PRJCT||' COMPMANUALVALUE '||CHR(10)
                             ||' FROM DUAL '||CHR(10);  
    --                              --------DBMS_OUTPUT.PUT_LINE('LV_SQLSTR: '||LV_SQLSTR);          
                 --------DBMS_OUTPUT.PUT_LINE('2_7 : '||LV_SQLSTR);    
                   EXECUTE IMMEDIATE LV_SQLSTR;COMMIT;                         
               END IF;
               
             END LOOP;         
--              --------DBMS_OUTPUT.PUT_LINE('LV_CNT: '||LV_CNT); 
              --  IF LV_CNT>0 THEN
                        
        END LOOP;
        
--        RETURN;
        
     FOR T2 IN  ( SELECT WORKERSERIAL,COLUMNNO
                        FROM GTTPISITAXCOMPUTATION
                        WHERE COMPANYCODE= P_COMPANYCODE
                        AND DIVISIONCODE=P_DIVISIONCODE
                        AND YEARCODE=P_YEARCODE   )
      LOOP
        ----------DBMS_OUTPUT.PUT_LINE(' T2.COLUMNNO '||T2.COLUMNNO||'  T2.WORKERSERIAL '||T2.WORKERSERIAL);
        
       -- if T2.COLUMNNO='12' then
        LV_SQLSTR:= 'UPDATE GTTPISITAXCOMPUTATION  SET 
         (COMPACTUALVALUE,COMPPROJCTEDVALUE,COMPMANUALVALUE)=
         (select distinct sum(COMPACTUALVALUE),sum(COMPPROJCTEDVALUE),sum(COMPMANUALVALUE)
         FROM PISITAXATTRIBUTEVALUE 
         WHERE COMPANYCODE='''||P_COMPANYCODE||'''
         AND DIVISIONCODE='''||P_DIVISIONCODE||'''
         and YEARCODE='''||P_YEARCODE||'''
         AND COLUMNNO='''||T2.COLUMNNO||'''
         AND WORKERSERIAL='''||T2.WORKERSERIAL||'''
         group by WORKERSERIAL,COLUMNNO )
         WHERE COMPANYCODE='''||P_COMPANYCODE||'''
         AND DIVISIONCODE='''||P_DIVISIONCODE||'''
         and YEARCODE='''||P_YEARCODE||'''
         AND COLUMNNO='''||T2.COLUMNNO||'''
         AND WORKERSERIAL='''||T2.WORKERSERIAL||''' ';
         
         ----DBMS_OUTPUT.PUT_LINE('update : : '||LV_SQLSTR);
         EXECUTE IMMEDIATE LV_SQLSTR;              
     --   end if; 

      END LOOP;
      commit;
--        

      
--        RETURN;  
--        --------DBMS_OUTPUT.PUT_LINE('AWT: '); 
--        UPDATE GTTPISITAXCOMPUTATION A SET 
--         (A.COMPACTUALVALUE,A.COMPPROJCTEDVALUE,A.COMPMANUALVALUE)=
--         (SELECT B.COMPACTUALVALUE,B.COMPPROJCTEDVALUE,B.COMPMANUALVALUE
--         FROM PISITAXATTRIBUTEVALUE B
--         WHERE A.COMPANYCODE=B.COMPANYCODE
--         AND A.DIVISIONCODE=B.DIVISIONCODE
--         AND A.COLUMNNO=B.COLUMNNO );
--        --------DBMS_OUTPUT.PUT_LINE('CIII ');
        

          
        -- CURRENT TAX
--        SELECT DECODE(SEX,'M','MALE', 'F','FEMALE','SENIOR CITIZEN')GENDER INTO LV_GENDER
--        FROM PISEMPLOYEEMASTER
--        WHERE TOKENNO=P_TOKENNO 
--        AND COMPANYCODE= P_COMPANYCODE
--        AND DIVISIONCODE=P_DIVISIONCODE;
--                        
--                
--        SELECT CFFROMLASTSLAB INTO LV_ACTUAL
--        FROM PISITAXSLAB B
--        WHERE B.COMPANYCODE=P_COMPANYCODE
--        AND B.DIVISIONCODE=P_DIVISIONCODE
--        AND B.YEARCODE=P_YEARCODE
--        AND (SLABTO>=(SELECT COMPACTUALVALUE FROM GTTPISITAXCOMPUTATION WHERE COLUMNNO='11') 
--        AND SLABFROM<=(SELECT COMPACTUALVALUE FROM GTTPISITAXCOMPUTATION WHERE COLUMNNO='11'))
--        AND CATEGORY=LV_GENDER;
--        
--        SELECT CFFROMLASTSLAB INTO LV_PROJEC
--        FROM PISITAXSLAB B
--        WHERE B.COMPANYCODE=P_COMPANYCODE
--        AND B.DIVISIONCODE=P_DIVISIONCODE
--        AND B.YEARCODE=P_YEARCODE
--        AND (SLABTO>=(SELECT COMPPROJCTEDVALUE FROM GTTPISITAXCOMPUTATION WHERE COLUMNNO='11') 
--        AND SLABFROM<=(SELECT COMPPROJCTEDVALUE FROM GTTPISITAXCOMPUTATION WHERE COLUMNNO='11'))
--        AND CATEGORY=LV_GENDER;
--                      
--        SELECT CFFROMLASTSLAB INTO LV_MANUAL
--        FROM PISITAXSLAB B
--        WHERE B.COMPANYCODE=P_COMPANYCODE
--        AND B.DIVISIONCODE=P_DIVISIONCODE
--        AND B.YEARCODE=P_YEARCODE
--        AND (SLABTO>=(SELECT COMPMANUALVALUE FROM GTTPISITAXCOMPUTATION WHERE COLUMNNO='11') 
--        AND SLABFROM<=(SELECT COMPMANUALVALUE FROM GTTPISITAXCOMPUTATION WHERE COLUMNNO='11'))
--        AND CATEGORY=LV_GENDER;
--                      
--        UPDATE GTTPISITAXCOMPUTATION 
--        SET (COMPACTUALVALUE,COMPPROJCTEDVALUE,COMPMANUALVALUE)=(SELECT LV_ACTUAL,LV_PROJEC,LV_MANUAL FROM DUAL)
--        WHERE 
--        COMPANYCODE=P_COMPANYCODE
--        AND DIVISIONCODE=P_DIVISIONCODE
--        AND YEARCODE=P_YEARCODE
--        AND COLUMNNO='12'
--        AND TOKENNO=P_TOKENNO;        
                       
      --  PROC_UPDATEITAX_COMP(P_COMPANYCODE,P_DIVISIONCODE,P_YEARCODE,P_TOKENNO);

    END IF;       
        
    
--ADDED BY CHIRANJIT GHOSH
--UPDATE TABLE WITH FORMULA VALUES
FOR C2 IN (
    SELECT COMPANYCODE, DIVISIONCODE, YEARCODE, WORKERSERIAL, COLUMNNO, COMPFORMULA 
    FROM GTTPISITAXCOMPUTATION
    WHERE COMPFORMULA IS NOT NULL
    ORDER BY COLUMNNO
)
LOOP
    LV_FORMULA_ACT := C2.COMPFORMULA;
    LV_FORMULA_PROJ := C2.COMPFORMULA;
    LV_FORMULA_MANU := C2.COMPFORMULA;
    
    --------DBMS_OUTPUT.PUT_LINE(C2.COLUMNNO);
    --------DBMS_OUTPUT.PUT_LINE(C2.COMPFORMULA);
    FOR C1 IN 
    (
        SELECT COLUMNNO FROM (
            SELECT DISTINCT REGEXP_SUBSTR (C2.COMPFORMULA,'[^<<(w)>>$]+',1,LEVEL) AS COLUMNNO
            FROM   DUAL
            CONNECT BY REGEXP_SUBSTR (C2.COMPFORMULA,'[^<<(w)>>]+',1,LEVEL) IS NOT NULL
        )
--        WHERE COLUMNNO NOT IN ('*','+','-','/')
        WHERE COLUMNNO NOT LIKE ('%*%') 
        AND COLUMNNO NOT LIKE ('%-%') 
        AND COLUMNNO NOT LIKE ('%+%') 
        AND COLUMNNO NOT LIKE ('%/%')
    )
    LOOP
        LV_SQLSTR := 'SELECT NVL( COMPACTUALVALUE,0), NVL(COMPPROJCTEDVALUE,0), NVL(COMPMANUALVALUE,0) FROM GTTPISITAXCOMPUTATION
                    WHERE COLUMNNO='''||C1.COLUMNNO||'''
                    AND COMPANYCODE='''||C2.COMPANYCODE||'''
                    AND DIVISIONCODE='''||C2.DIVISIONCODE||'''
                    AND YEARCODE='''||C2.YEARCODE||'''
                    AND WORKERSERIAL='''||C2.WORKERSERIAL||'''';
                    
        BEGIN            
            --------DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
            EXECUTE IMMEDIATE LV_SQLSTR INTO LV_VALUE_ACT, LV_VALUE_PROJ, LV_VALUE_MANU;
        EXCEPTION WHEN OTHERS THEN 
            LV_VALUE_ACT := 0;
            LV_VALUE_PROJ := 0;
            LV_VALUE_MANU := 0;
        END;
        IF LV_VALUE_ACT < 0 THEN
            LV_FORMULA_ACT := REPLACE(LV_FORMULA_ACT,'<<'||C1.COLUMNNO||'>>', '('||LV_VALUE_ACT||')');
        ELSE
            LV_FORMULA_ACT := REPLACE(LV_FORMULA_ACT,'<<'||C1.COLUMNNO||'>>', LV_VALUE_ACT);
        END IF;
        IF LV_VALUE_PROJ < 0 THEN
            LV_FORMULA_PROJ := REPLACE(LV_FORMULA_PROJ,'<<'||C1.COLUMNNO||'>>', '('||LV_VALUE_PROJ||')');
        ELSE
            LV_FORMULA_PROJ := REPLACE(LV_FORMULA_PROJ,'<<'||C1.COLUMNNO||'>>', LV_VALUE_PROJ);
        END IF;
        IF LV_VALUE_MANU < 0 THEN
            LV_FORMULA_MANU := REPLACE(LV_FORMULA_MANU,'<<'||C1.COLUMNNO||'>>', '('||LV_VALUE_MANU||')');
        ELSE
            LV_FORMULA_MANU := REPLACE(LV_FORMULA_MANU,'<<'||C1.COLUMNNO||'>>', LV_VALUE_MANU);
        END IF;
    END LOOP;
    
    --------DBMS_OUTPUT.PUT_LINE(LV_FORMULA_ACT);
    --------DBMS_OUTPUT.PUT_LINE(LV_FORMULA_PROJ);
    --------DBMS_OUTPUT.PUT_LINE(LV_FORMULA_MANU);
    
    LV_SQLSTR := 'SELECT '||LV_FORMULA_ACT||','||LV_FORMULA_PROJ||','||LV_FORMULA_MANU||' FROM DUAL';
        EXECUTE IMMEDIATE LV_SQLSTR INTO LV_VALUE_ACT, LV_VALUE_PROJ, LV_VALUE_MANU;
    --------DBMS_OUTPUT.PUT_LINE(LV_VALUE_ACT);
    --------DBMS_OUTPUT.PUT_LINE(LV_VALUE_PROJ);
    --------DBMS_OUTPUT.PUT_LINE(LV_VALUE_MANU);
    
    LV_SQLSTR := 'UPDATE GTTPISITAXCOMPUTATION SET 
                COMPACTUALVALUE = '||LV_VALUE_ACT||',
                COMPPROJCTEDVALUE = '||LV_VALUE_PROJ||',
                COMPMANUALVALUE = '||LV_VALUE_MANU||'
                WHERE COLUMNNO='''||C2.COLUMNNO||'''
                AND COMPANYCODE='''||C2.COMPANYCODE||'''
                AND DIVISIONCODE='''||C2.DIVISIONCODE||'''
                AND YEARCODE='''||C2.YEARCODE||'''
                AND WORKERSERIAL='''||C2.WORKERSERIAL||'''';
    --------DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
    EXECUTE IMMEDIATE LV_SQLSTR;
    
    IF(C2.COLUMNNO = '11') THEN
        --UPDATE INCOME TAX SLAB PERCENTAGE
        UPDATE GTTPISITAXCOMPUTATION A SET
        (COMPACTUALVALUE, COMPPROJCTEDVALUE, COMPMANUALVALUE) = 
        (
            SELECT FN_GET_ITAX_PERCENTAGE(COMPANYCODE, DIVISIONCODE, YEARCODE, TOKENNO,COMPACTUALVALUE)  ITAX_ACTUALVALUE,
            FN_GET_ITAX_PERCENTAGE(COMPANYCODE, DIVISIONCODE, YEARCODE, TOKENNO,COMPPROJCTEDVALUE)  ITAX_PROJCTEDVALUE,
            FN_GET_ITAX_PERCENTAGE(COMPANYCODE, DIVISIONCODE, YEARCODE, TOKENNO,COMPMANUALVALUE)  ITAX_MANUALVALUE
            FROM GTTPISITAXCOMPUTATION
            WHERE COLUMNNO='11'
            AND A.COMPANYCODE=COMPANYCODE
            AND A.DIVISIONCODE=DIVISIONCODE
            AND A.YEARCODE=YEARCODE
            AND A.WORKERSERIAL=WORKERSERIAL
        )
        WHERE COLUMNNO='12'
        AND A.COMPANYCODE=C2.COMPANYCODE
        AND A.DIVISIONCODE=C2.DIVISIONCODE
        AND A.YEARCODE=C2.YEARCODE
        AND A.WORKERSERIAL=C2.WORKERSERIAL;
    END IF;
END LOOP;

UPDATE GTTPISITAXCOMPUTATION SET
COMPPROJCTEDVALUE = COMPACTUALVALUE,
COMPMANUALVALUE = COMPACTUALVALUE
WHERE NVL(COMPPROJCTEDVALUE,0) = 0;
     
END;
/
