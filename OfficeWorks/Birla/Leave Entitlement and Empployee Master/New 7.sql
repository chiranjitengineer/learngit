
SELECT E.TOKENNO, E.EMPLOYEENAME, E.DEPARTMENTCODE, D.DEPARTMENTDESC, L.ENTITLEMENTS, L.CARRYFORWARD, E.COMPANYCODE, E.DIVISIONCODE, '2020-2021' YEARCODE, E.UNITCODE, E.CATEGORYCODE, E.GRADECODE, E.WORKERSERIAL,  
       L.LEAVECODE,  CASE WHEN C.LEAVECALENDARORFINYRWISE='C' THEN TO_CHAR(TRUNC(SYSDATE),'YYYY') ELSE NULL END CALENDARYEAR, 
       L.SYSROWID, 'A' OPERATIONMODE, 'SWT' USERNAME 
  FROM PISEMPLOYEEMASTER E,  
       ( 
        SELECT T.* 
          FROM PISLEAVEENTITLEMENT T, PISLEAVEMASTER M  
         WHERE T.COMPANYCODE=M.COMPANYCODE 
           AND T.DIVISIONCODE=M.DIVISIONCODE 
           AND T.LEAVECODE=M.LEAVECODE 
           AND NVL(M.WITHOUTPAYLEAVE,'N')='N' 
           AND T.COMPANYCODE='BJ0056' 
           AND T.DIVISIONCODE='0001' 
           AND T.UNITCODE='01' 
           AND T.CATEGORYCODE='10' 
           AND T.GRADECODE='A' 
       ) L, PISDEPARTMENTMASTER D, PISCATEGORYMASTER C 
 WHERE E.COMPANYCODE=L.COMPANYCODE(+) 
   AND E.DIVISIONCODE=L.DIVISIONCODE(+) 
   AND E.WORKERSERIAL=L.WORKERSERIAL(+) 
   AND E.TOKENNO=L.TOKENNO(+) 
   AND L.LEAVECODE(+)='PL' 
   AND NVL(L.CALENDARYEAR,'NA') = DECODE(C.LEAVECALENDARORFINYRWISE,'C','2020', NVL(L.CALENDARYEAR,'NA'))
   AND E.COMPANYCODE=D.COMPANYCODE 
   AND E.DIVISIONCODE=D.DIVISIONCODE 
   AND E.DEPARTMENTCODE=D.DEPARTMENTCODE 
   AND E.COMPANYCODE=C.COMPANYCODE 
   AND E.DIVISIONCODE=C.DIVISIONCODE 
   AND E.CATEGORYCODE=C.CATEGORYCODE 
   AND E.COMPANYCODE='BJ0056' 
   AND E.DIVISIONCODE='0001' 
   AND E.UNITCODE='01' 
   AND E.CATEGORYCODE='10' 
   AND E.GRADECODE='A' 
 ORDER BY E.TOKENNO 