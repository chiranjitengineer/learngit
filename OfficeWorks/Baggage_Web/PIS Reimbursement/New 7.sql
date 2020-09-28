INSERT INTO GTT_PISREIMBURSEMENT 

         SELECT A.COMPANYCODE, A.DIVISIONCODE,'2020-2021' YEARCODE,'2020-2021' FORYEARCODE,'202004' YEARMONTH,A.WORKERSERIAL,A.TOKENNO,
         A.EMPLOYEENAME,TO_CHAR(A.DATEOFJOIN,'DD/MM/YYYY') DATEOFJOIN , A.UNITCODE,A.CATEGORYCODE, A.GRADECODE, 'LOCAL_CONV' COMPONENTCODE, 
         B.COMPONENTAMOUNT  COMPONENTAMOUNT,'LOCAL_CONV'   TRANSACTIONTYPE,    'ADD' ADDLESS, 
         B.COMPONENTAMOUNT   BILLAMOUNT, NVL(D.PAIDAMOUNT,0) PAIDAMOUNT,'DETAILS' TRANTYPE,   
         (NVL(D2.PAIDAMOUNT,0)-NVL(D.PAIDAMOUNT,0)) AMOUNTTAKEN,NVL(C.LASTCOMPONENTAMOUNT,0) PREVCOMPONENTAMOUNT, (NVL(C.LASTCOMPONENTAMOUNT,0)-NVL(D3.PREVIOUSYRTAKEN,0)) PREVIOUSYRBALANCE,
         NVL(D3.PREVIOUSYRTAKEN,0)  PREVIOUSYRTAKEN,(B.COMPONENTAMOUNT + (NVL(C.LASTCOMPONENTAMOUNT,0)-NVL(D3.PREVIOUSYRTAKEN,0)) -NVL(D2.PAIDAMOUNT,0)) TOTALDUE,DECODE('M','A', DECODE('LOCAL_CONV', 'BONUS', B.COMPONENTAMOUNT ,0),NVL(D.PAIDAMOUNT,0))  AMOUNTCLAIMCURRENT,NVL(D4.AMOUNTCLAIMPREVIOUS,0) AMOUNTCLAIMPREVIOUS,
        (B.COMPONENTAMOUNT+(NVL(C.LASTCOMPONENTAMOUNT,0)-NVL(D3.PREVIOUSYRTAKEN,0)))-(NVL(D2.PAIDAMOUNT,0)) BALANCEAMOUNT , NVL(D5.LEAVEBALANCE,0)   LEAVEBALANCE , 0   LEAVEENCASHMENT  
         FROM PISEMPLOYEEMASTER A ,
         (
                  SELECT P.COMPANYCODE, P.DIVISIONCODE,P.UNITCODE, P.GRADECODE, P.CATEGORYCODE, P.TOKENNO, P.WORKERSERIAL,  P.COMPONENTAMOUNT BASIC    
                  FROM PISREIMBURSEMENT_ENTITLE   P    
                  WHERE 1=1     
                  AND P.TRANSACTIONTYPE='ENTITLEMENT'     
                  AND P.YEARCODE =  '2020-2021'    
                  AND COMPONENTCODE='LOCAL_CONV'    
                  AND COMPANYCODE='0001'
                  AND DIVISIONCODE='001'
              ) A,-- LAST YEAR COMPONENT AMOUNT 
              (
                  SELECT TOKENNO, WORKERSERIAL, DATEOFJOIN, (TRUNC(B.ENDDATE-A.DATEOFJOIN)+1) NOWORKDAYS, (TRUNC(B.ENDDATE-B.STARTDATE)+1) YEARDAYS 
                  FROM PISEMPLOYEEMASTER A,
                  (
                      SELECT STARTDATE, ENDDATE FROM FINANCIALYEAR
                      WHERE COMPANYCODE='0001'
                      AND DIVISIONCODE='001'
                      AND YEARCODE='2020-2021'
                  ) B
                  WHERE DATEOFJOIN > B.STARTDATE
                  AND DATEOFJOIN < B.ENDDATE
              ) B
              WHERE A.WORKERSERIAL=B.WORKERSERIAL(+) --CALCULATE YEAR DAYS, NO OF DAYS WORKING FROM DATE OF JOINING FOR LAST YEAR
         ) B,  -- TOKENNO WITH BASIC, YEARMONTH
         (
              SELECT A.WORKERSERIAL, DECODE(B.TOKENNO,NULL,A.BASIC,ROUND((A.BASIC/B.YEARDAYS)*B.NOWORKDAYS,2)) LASTCOMPONENTAMOUNT FROM 
              (
                  SELECT COMPANYCODE, DIVISIONCODE,UNITCODE, GRADECODE, CATEGORYCODE, DEPARTMENTCODE, TOKENNO, WORKERSERIAL,  YEARMONTH , BASIC
                  FROM PISCOMPONENTASSIGNMENT   P
                  WHERE 1=1 
                  AND TRANSACTIONTYPE='ASSIGNMENT' 
                  AND YEARMONTH =  
                  (
                      SELECT MAX(YEARMONTH)  YEARMONTH 
                      FROM PISCOMPONENTASSIGNMENT 
                      WHERE TOKENNO=P.TOKENNO
                      AND TRANSACTIONTYPE='ASSIGNMENT' 
                      AND COMPANYCODE='0001'
                      AND DIVISIONCODE='001'
                      AND YEARMONTH >= '201904'
                      AND YEARMONTH <= '202003'
                  )-- TOKENNO WITH BASIC, YEARMONTH FOR LAST YEAR
              ) A,-- LAST YEAR COMPONENT AMOUNT 
              (
                  SELECT TOKENNO, WORKERSERIAL, DATEOFJOIN, (TRUNC(B.ENDDATE-A.DATEOFJOIN)+1) NOWORKDAYS, (TRUNC(B.ENDDATE-B.STARTDATE)+1) YEARDAYS 
                  FROM PISEMPLOYEEMASTER A,
                  (
                      SELECT STARTDATE, ENDDATE FROM FINANCIALYEAR
                      WHERE COMPANYCODE='0001'
                      AND DIVISIONCODE='001'
                  ) B
                  WHERE DATEOFJOIN > B.STARTDATE
                  AND DATEOFJOIN < B.ENDDATE
              ) B
              WHERE A.WORKERSERIAL=B.WORKERSERIAL(+) --CALCULATE YEAR DAYS, NO OF DAYS WORKING FROM DATE OF JOINING FOR LAST YEAR
                      AND 1=2 
         ) C, -- LAST YEAR COMPONENT AMOUNT 
         (
             SELECT WORKERSERIAL, TOKENNO, SUM(PAIDAMOUNT)  PAIDAMOUNT
             FROM PISREIMBURSEMENTDETAILS
             WHERE YEARCODE = '2020-2021'
             AND COMPANYCODE='0001'
             AND DIVISIONCODE='001' 
             AND COMPONENTCODE='LOCAL_CONV' 
             AND YEARMONTH='202004' 
             GROUP BY WORKERSERIAL, TOKENNO 
         ) D, --CALCULATE  PAID AMOUNT THIS YEAR
         (
             SELECT WORKERSERIAL, TOKENNO, SUM(PAIDAMOUNT)  PAIDAMOUNT
             FROM PISREIMBURSEMENTDETAILS
             WHERE YEARCODE = '2020-2021'
             AND YEARMONTH >= '202004'
             AND YEARMONTH <= '202004'
             AND COMPANYCODE='0001'
             AND DIVISIONCODE='001' 
             AND COMPONENTCODE='LOCAL_CONV' 
             GROUP BY WORKERSERIAL, TOKENNO
         ) D2, --CALCULATE  PAID AMOUNT THIS YEAR 
         (
             SELECT WORKERSERIAL, TOKENNO, SUM(PAIDAMOUNT)  PREVIOUSYRTAKEN
             FROM PISREIMBURSEMENTDETAILS
             WHERE 1=1--YEARCODE = '2019-2020'
             AND YEARCODE IN (
                 SELECT (TO_NUMBER(SUBSTR('2020-2021',1,4))-LX)||'-'||(TO_NUMBER(SUBSTR('2020-2021',-4))-LX) XX  FROM 
                 (
                     SELECT Level AS LX 
                     FROM Dual 
                     CONNECT BY Level <= 1
                 )
             )
             AND COMPANYCODE='0001'
             AND DIVISIONCODE='001' 
             AND COMPONENTCODE='LOCAL_CONV' 
             GROUP BY WORKERSERIAL, TOKENNO
         ) D3,--CALCULATE  PAID AMOUNT  FOR LAST YEAR 
         (
             SELECT WORKERSERIAL, TOKENNO, PAIDAMOUNT  AMOUNTCLAIMPREVIOUS
             FROM PISREIMBURSEMENTDETAILS P
             WHERE 1=1 --YEARCODE = '2019-2020'
             AND YEARMONTH = 
             (
                      SELECT MAX(YEARMONTH)  YEARMONTH 
                      FROM PISREIMBURSEMENTDETAILS 
                      WHERE TOKENNO=P.TOKENNO
                     AND COMPANYCODE='0001'
                     AND DIVISIONCODE='001' 
                      AND YEARMONTH < '202004'
             )
             AND COMPANYCODE='0001'
             AND DIVISIONCODE='001' 
             AND COMPONENTCODE='LOCAL_CONV' 
         ) D4,
         (
             SELECT COMPANYCODE,DIVISIONCODE, TOKENNO, WORKERSERIAL, SUM(LV_BAL) LEAVEBALANCE 
             FROM GBL_PISLEAVEBALANCE
             GROUP BY COMPANYCODE,DIVISIONCODE, TOKENNO, WORKERSERIAL
         ) D5
         WHERE 1=1--A.COMPANYCODE=B.COMPANYCODE 
   --      AND A.DIVISIONCODE=B.DIVISIONCODE 
         AND A.WORKERSERIAL=B.WORKERSERIAL 
         AND A.WORKERSERIAL=C.WORKERSERIAL(+)
         AND A.WORKERSERIAL=D.WORKERSERIAL(+)
         AND A.WORKERSERIAL=D2.WORKERSERIAL(+)
         AND A.WORKERSERIAL=D3.WORKERSERIAL(+)
         AND A.WORKERSERIAL=D4.WORKERSERIAL(+)
         AND A.WORKERSERIAL=D5.WORKERSERIAL(+)
         AND NVL(D.PAIDAMOUNT,0) > 0 
         AND A.COMPANYCODE='0001'
         AND A.DIVISIONCODE='001' 
   AND A.UNITCODE='001'
   AND A.CATEGORYCODE='02'
   AND A.GRADECODE='CIV'
         ORDER BY A.TOKENNO

