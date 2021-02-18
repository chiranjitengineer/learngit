SELECT ASSIGN.DA_RATA,ASSIGN.VDA_RATE,ASSIGN.BASIC,ASSIGN.DA_AMOUNT,ASSIGN.VDA,ASSIGN.ADHOC_DA,ASSIGN.HRA_FIX,ASSIGN.HRA_PER,ASSIGN.TIFFN_ALLW,ASSIGN.SHIFT_ALLW,ASSIGN.TRNP_ALLW,ASSIGN.SPCL_ALLW,ASSIGN.EDUC_ALLW,ASSIGN.SOFT_FURNS,ASSIGN.LV_ENCASH,ASSIGN.ENTMT_ALLW,ASSIGN.PRFRM_BONUS,ASSIGN.EX_GRATIA,ASSIGN.KIT_ALLW,ASSIGN.OTH_ALLW_1,ASSIGN.OTH_ALLW_2,ASSIGN.OTH_ALLW_TM,ASSIGN.OTH_DEDN_TM,ASSIGN.RENT 
  FROM PISEMPLOYEEMASTER EMPMAST, PISDEPARTMENTMASTER DEPT,  
       ( 
        SELECT * 
          FROM PISCOMPONENTASSIGNMENT 
         WHERE COMPANYCODE='BT0104' 
           AND DIVISIONCODE='HO' 
           AND TRANSACTIONTYPE='ASSIGNMENT' 
           AND WORKERSERIAL||YEARMONTH IN ( 
                                            SELECT WORKERSERIAL||MAX(YEARMONTH) FROM PISCOMPONENTASSIGNMENT 
                                             WHERE COMPANYCODE='BT0104' AND DIVISIONCODE='HO' 
                                               AND TO_NUMBER(YEARMONTH)<=TO_NUMBER('202004') 
                                               AND TRANSACTIONTYPE='ASSIGNMENT' 
                                            GROUP BY WORKERSERIAL 
                                          ) 
       ) ASSIGN 
 WHERE EMPMAST.COMPANYCODE=DEPT.COMPANYCODE 
   AND EMPMAST.DIVISIONCODE=DEPT.DIVISIONCODE 
   AND EMPMAST.DEPARTMENTCODE=DEPT.DEPARTMENTCODE 
   AND EMPMAST.COMPANYCODE=ASSIGN.COMPANYCODE(+) 
   AND EMPMAST.DIVISIONCODE=ASSIGN.DIVISIONCODE(+) 
   AND EMPMAST.TOKENNO=ASSIGN.TOKENNO(+) 
   AND EMPMAST.WORKERSERIAL=ASSIGN.WORKERSERIAL(+) 
   AND EMPMAST.COMPANYCODE='BT0104' 
   AND EMPMAST.DIVISIONCODE='HO' 
   AND EMPMAST.UNITCODE='HO' 
   AND EMPMAST.CATEGORYCODE='OFF' 
   AND EMPMAST.GRADECODE='OFF' 
   AND TO_NUMBER(TO_CHAR(EMPMAST.DATEOFJOIN,'YYYYMM'))<=TO_NUMBER('202004') 
   AND TO_NUMBER(NVL(TO_CHAR(EMPMAST.STATUSDATE,'YYYYMM'),NVL(TO_CHAR(EMPMAST.EXTENDEDRETIREDATE,'YYYYMM'),'202004')))>=TO_NUMBER('202004') 
   
   
   SELECT * FROM PISEMPLOYEEMASTER
   
   
   SELECT * FROM PISDEPARTMENTMASTER
   
   
   SELECT * FROM PISEMPLOYEEMASTER EMPMAST, PISDEPARTMENTMASTER DEPT,  
       ( 
        SELECT * 
          FROM PISCOMPONENTASSIGNMENT 
         WHERE COMPANYCODE='BT0104' 
           AND DIVISIONCODE='HO' 
           AND TRANSACTIONTYPE='ASSIGNMENT' 
           AND WORKERSERIAL||YEARMONTH IN ( 
                                            SELECT WORKERSERIAL||MAX(YEARMONTH) FROM PISCOMPONENTASSIGNMENT 
                                             WHERE COMPANYCODE='BT0104' AND DIVISIONCODE='HO' 
                                               AND TO_NUMBER(YEARMONTH)<=TO_NUMBER('202004') 
                                               AND TRANSACTIONTYPE='ASSIGNMENT' 
                                            GROUP BY WORKERSERIAL 
                                          ) 
       ) ASSIGN 
 WHERE EMPMAST.COMPANYCODE=DEPT.COMPANYCODE 
   AND EMPMAST.DIVISIONCODE=DEPT.DIVISIONCODE 
   AND EMPMAST.DEPARTMENTCODE=DEPT.DEPARTMENTCODE 
   AND EMPMAST.COMPANYCODE=ASSIGN.COMPANYCODE(+) 
   AND EMPMAST.DIVISIONCODE=ASSIGN.DIVISIONCODE(+) 
   AND EMPMAST.TOKENNO=ASSIGN.TOKENNO(+) 
   AND EMPMAST.WORKERSERIAL=ASSIGN.WORKERSERIAL(+) 
   AND EMPMAST.COMPANYCODE='BT0104' 
   AND EMPMAST.DIVISIONCODE='HO' 
   AND EMPMAST.UNITCODE='HO' 
   AND EMPMAST.CATEGORYCODE='OFF' 
   AND EMPMAST.GRADECODE='OFF' 
   AND TO_NUMBER(TO_CHAR(EMPMAST.DATEOFJOIN,'YYYYMM'))<=TO_NUMBER('202004') 
   AND TO_NUMBER(NVL(TO_CHAR(EMPMAST.STATUSDATE,'YYYYMM'),NVL(TO_CHAR(EMPMAST.EXTENDEDRETIREDATE,'YYYYMM'),'202004')))>=TO_NUMBER('202004')
   
   
   SELECT * FROM pistagwisefixedcolumnshow
   
   UPDATE pistagwisefixedcolumnshow
   SET DIVISIONCODE='HO'
   
   SELECT * FROM DIVISIONMASTER
   
   