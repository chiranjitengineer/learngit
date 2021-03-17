

SELECT TOKENNO,EMPLOYEENAME, DATEOFBIRTH,DATEOFRETIRE,RETIRE_DATE,MONTH_START_DATE, TO_CHAR(MONTH_END_DATE,'MON-YYYY') MM ,
(RETIRE_DATE-MONTH_START_DATE)+1 PENDAYS, (MONTH_END_DATE-MONTH_START_DATE)+1 MONTHDAYS
FROM 
(
    SELECT TOKENNO,EMPLOYEENAME, DATEOFBIRTH,DATEOFRETIRE, 
    ADD_MONTHS(DATEOFBIRTH, 58*12) RETIRE_DATE , TO_DATE(202012,'YYYYMM') MONTH_START_DATE,
    LAST_DAY(TO_DATE('202012','YYYYMM')) MONTH_END_DATE
    FROM PISEMPLOYEEMASTER
) 
WHERE 1=1
and RETIRE_DATE between month_start_date and month_end_date
 
DATEOFRETIRE<>RETIRE_DATE


SELECT TOKENNO, WORKERSERIAL, YEARMONTH, PF_GROSS,PEN_GROSS 
FROM PISPAYTRANSACTION_SWT


UPDATE PISPAYTRANSACTION_SWT A SET (PEN_GROSS,FPF, PF_C) = (
    SELECT NEW_PEN_GR, (NEW_PEN_GR* FPF_PERC) FPF, (PF_E-FPF) PF_C
    FROM 
    (
        SELECT A.TOKENNO, A.WORKERSERIAL,ROUND((PF_GROSS/MONTHDAYS)*PENDAYS,2) NEW_PEN_GR, B.PEN_GROSS, (8.33/100) FPF_PERC FROM 
        (
            SELECT TOKENNO,WORKERSERIAL, DATEOFBIRTH,DATEOFRETIRE,RETIRE_DATE,MONTH_START_DATE, TO_CHAR(MONTH_END_DATE,'MON-YYYY') MM ,
            (RETIRE_DATE-MONTH_START_DATE)+1 PENDAYS, (MONTH_END_DATE-MONTH_START_DATE)+1 MONTHDAYS
            FROM 
            (
                SELECT TOKENNO,WORKERSERIAL,EMPLOYEENAME, DATEOFBIRTH,DATEOFRETIRE, 
                ADD_MONTHS(DATEOFBIRTH, 58*12) RETIRE_DATE , TO_DATE(202012,'YYYYMM') MONTH_START_DATE,
                LAST_DAY(TO_DATE('202012','YYYYMM')) MONTH_END_DATE
                FROM PISEMPLOYEEMASTER
            ) 
            WHERE 1=1
            AND RETIRE_DATE BETWEEN MONTH_START_DATE AND MONTH_END_DATE
        ) A,
        (
            SELECT TOKENNO, WORKERSERIAL, YEARMONTH, PF_GROSS,PEN_GROSS, PF_E 
            FROM PISPAYTRANSACTION_SWT
            WHERE YEARMONTH='202011'
        ) B
        WHERE A.WORKERSERIAL=B.WORKERSERIAL
    )
    WHERE A.WORKERSERIAL=WORKERSERIAL
)
WHERE YEARMONTH='202012'


CREATE TABLE PISPAYTRANSACTION_241220 AS
SELECT * FROM PISPAYTRANSACTION

SELECT * FROM PISPAYTRANSACTION
WHERE TOKENNO='00638'

SELECT TOKENNO,WORKERSERIAL,EMPLOYEENAME, DATEOFBIRTH,DATEOFRETIRE, 
ADD_MONTHS(DATEOFBIRTH, 58*12) RETIRE_DATE , TO_DATE(202012,'YYYYMM') MONTH_START_DATE,
LAST_DAY(TO_DATE('202012','YYYYMM')) MONTH_END_DATE
FROM PISEMPLOYEEMASTER
WHERE TOKENNO='00794'


SELECT TOKENNO,YEARMONTH, PF_E, PF_C, VPF, FPF FROM PISPAYTRANSACTION
WHERE TOKENNO='00638'
ORDER BY YEARMONTH

SELECT TOKENNO, SUM(PF_E) PF_E, SUM(PF_C) PF_C, SUM(VPF) VPF, SUM(FPF) FPF FROM PISPAYTRANSACTION
WHERE TOKENNO IN ('00638')
AND YEARCODE='2020-2021'
GROUP BY TOKENNO
ORDER BY TOKENNO

UPDATE PISPAYTRANSACTION SET PF_C=PF_C+FPF
WHERE TOKENNO IN ('00638')
AND YEARCODE='2020-2021'
AND YEARMONTH >= '202004'

UPDATE PISPAYTRANSACTION SET FPF=0
WHERE TOKENNO IN ('00638')
AND YEARCODE='2020-2021'
AND YEARMONTH >= '202004'

------------------------------------------------------------------------------------



SELECT TOKENNO,WORKERSERIAL,EMPLOYEENAME, DATEOFBIRTH,DATEOFRETIRE, 
ADD_MONTHS(DATEOFBIRTH, 58*12) RETIRE_DATE , TO_DATE(202012,'YYYYMM') MONTH_START_DATE,
LAST_DAY(TO_DATE('202012','YYYYMM')) MONTH_END_DATE
FROM PISEMPLOYEEMASTER
WHERE TOKENNO='00794'


SELECT TOKENNO,YEARMONTH, PF_E, PF_C, VPF, FPF FROM PISPAYTRANSACTION
WHERE TOKENNO='00794'
ORDER BY YEARMONTH

SELECT TOKENNO, SUM(PF_E) PF_E, SUM(PF_C) PF_C, SUM(VPF) VPF, SUM(FPF) FPF, (SUM(PF_C)+ SUM(FPF) ) TOT_PF_C FROM PISPAYTRANSACTION
WHERE TOKENNO IN ('00794')
AND YEARCODE='2020-2021'
GROUP BY TOKENNO
ORDER BY TOKENNO

UPDATE PISPAYTRANSACTION SET PF_C=PF_C+FPF
WHERE TOKENNO IN ('00794')
AND YEARCODE='2020-2021'
AND YEARMONTH >= '202004'

UPDATE PISPAYTRANSACTION SET FPF=0
WHERE TOKENNO IN ('00794')
AND YEARCODE='2020-2021'
AND YEARMONTH >= '202004'



------------------------------------------------------------------------------------



SELECT TOKENNO,WORKERSERIAL,EMPLOYEENAME, DATEOFBIRTH,DATEOFRETIRE, 
ADD_MONTHS(DATEOFBIRTH, 58*12) RETIRE_DATE , TO_DATE(202012,'YYYYMM') MONTH_START_DATE,
LAST_DAY(TO_DATE('202012','YYYYMM')) MONTH_END_DATE
FROM PISEMPLOYEEMASTER
WHERE TOKENNO='00979'


SELECT TOKENNO,YEARMONTH, PF_E, PF_C, VPF, FPF FROM PISPAYTRANSACTION
WHERE TOKENNO='00979'
ORDER BY YEARMONTH

SELECT TOKENNO, SUM(PF_E) PF_E, SUM(PF_C) PF_C, SUM(VPF) VPF, SUM(FPF) FPF, (SUM(PF_C)+ SUM(FPF) ) TOT_PF_C FROM PISPAYTRANSACTION
WHERE TOKENNO IN ('00979')
AND YEARCODE='2020-2021'
GROUP BY TOKENNO
ORDER BY TOKENNO

UPDATE PISPAYTRANSACTION SET PF_C=PF_C+FPF
WHERE TOKENNO IN ('00979')
AND YEARCODE='2020-2021'
AND YEARMONTH >= '202004'

UPDATE PISPAYTRANSACTION SET FPF=0
WHERE TOKENNO IN ('00979')
AND YEARCODE='2020-2021'
AND YEARMONTH >= '202004'

------------------------------------------------------------------------------------


SELECT TOKENNO,WORKERSERIAL,EMPLOYEENAME, PFAPPLICABLE, EPFAPPLICABLE, DATEOFBIRTH,DATEOFRETIRE, 
ADD_MONTHS(DATEOFBIRTH, 58*12) RETIRE_DATE , TO_DATE(202012,'YYYYMM') MONTH_START_DATE,
LAST_DAY(TO_DATE('202012','YYYYMM')) MONTH_END_DATE
FROM PISEMPLOYEEMASTER
WHERE TOKENNO='01133'


SELECT TOKENNO,YEARMONTH, PF_E, PF_C, VPF, FPF FROM PISPAYTRANSACTION
WHERE TOKENNO='01133'
ORDER BY YEARMONTH

SELECT TOKENNO, SUM(PF_E) PF_E, SUM(PF_C) PF_C, SUM(VPF) VPF, SUM(FPF) FPF, (SUM(PF_C)+ SUM(FPF) ) TOT_PF_C FROM PISPAYTRANSACTION
WHERE TOKENNO IN ('01133')
AND YEARCODE='2020-2021'
GROUP BY TOKENNO
ORDER BY TOKENNO

UPDATE PISPAYTRANSACTION SET PF_C=PF_C+FPF
WHERE TOKENNO IN ('01133')
AND YEARCODE='2020-2021'
AND YEARMONTH >= '202004'

UPDATE PISPAYTRANSACTION SET FPF=0
WHERE TOKENNO IN ('01133')
AND YEARCODE='2020-2021'
AND YEARMONTH >= '202004'

------------------------------------------------------------------------------------


SELECT TOKENNO,WORKERSERIAL,EMPLOYEENAME, PFAPPLICABLE, EPFAPPLICABLE, DATEOFBIRTH,DATEOFRETIRE, 
ADD_MONTHS(DATEOFBIRTH, 58*12) RETIRE_DATE , TO_DATE(202012,'YYYYMM') MONTH_START_DATE,
LAST_DAY(TO_DATE('202012','YYYYMM')) MONTH_END_DATE
FROM PISEMPLOYEEMASTER
WHERE TOKENNO='01133'


SELECT TOKENNO,YEARMONTH, PF_E, PF_C, VPF, FPF FROM PISPAYTRANSACTION
WHERE TOKENNO='01133'
ORDER BY YEARMONTH

SELECT TOKENNO, SUM(PF_E) PF_E, SUM(PF_C) PF_C, SUM(VPF) VPF, SUM(FPF) FPF, (SUM(PF_C)+ SUM(FPF) ) TOT_PF_C FROM PISPAYTRANSACTION
WHERE TOKENNO IN ('01133')
AND YEARCODE='2020-2021'
GROUP BY TOKENNO
ORDER BY TOKENNO

UPDATE PISPAYTRANSACTION SET PF_C=PF_C+FPF
WHERE TOKENNO IN ('01133')
AND YEARCODE='2020-2021'
AND YEARMONTH >= '202004'

UPDATE PISPAYTRANSACTION SET FPF=0
WHERE TOKENNO IN ('01133')
AND YEARCODE='2020-2021'
AND YEARMONTH >= '202004'


------------------------------------------------------------------------------------


SELECT TOKENNO,WORKERSERIAL,EMPLOYEENAME, PFAPPLICABLE, EPFAPPLICABLE, DATEOFBIRTH,DATEOFRETIRE, 
ADD_MONTHS(DATEOFBIRTH, 58*12) RETIRE_DATE , TO_DATE(202012,'YYYYMM') MONTH_START_DATE,
LAST_DAY(TO_DATE('202012','YYYYMM')) MONTH_END_DATE
FROM PISEMPLOYEEMASTER
WHERE TOKENNO='01205'


SELECT TOKENNO,YEARMONTH, PF_E, PF_C, VPF, FPF FROM PISPAYTRANSACTION
WHERE TOKENNO='01205'
ORDER BY YEARMONTH

SELECT TOKENNO, SUM(PF_E) PF_E, SUM(PF_C) PF_C, SUM(VPF) VPF, SUM(FPF) FPF, (SUM(PF_C)+ SUM(FPF) ) TOT_PF_C FROM PISPAYTRANSACTION
WHERE TOKENNO IN ('01205')
AND YEARCODE='2020-2021'
GROUP BY TOKENNO
ORDER BY TOKENNO

UPDATE PISPAYTRANSACTION SET PF_C=PF_C+FPF
WHERE TOKENNO IN ('01205')
AND YEARCODE='2020-2021'
AND YEARMONTH >= '202004'

UPDATE PISPAYTRANSACTION SET FPF=0
WHERE TOKENNO IN ('01205')
AND YEARCODE='2020-2021'
AND YEARMONTH >= '202004'
------------------------------------------------------------------------------------


SELECT TOKENNO,WORKERSERIAL,EMPLOYEENAME, PFAPPLICABLE, EPFAPPLICABLE, DATEOFBIRTH,DATEOFRETIRE, 
ADD_MONTHS(DATEOFBIRTH, 58*12) RETIRE_DATE , TO_DATE(202012,'YYYYMM') MONTH_START_DATE,
LAST_DAY(TO_DATE('202012','YYYYMM')) MONTH_END_DATE
FROM PISEMPLOYEEMASTER
WHERE TOKENNO='01192'


SELECT TOKENNO,YEARMONTH, PF_E, PF_C, VPF, FPF FROM PISPAYTRANSACTION
WHERE TOKENNO='01192'
ORDER BY YEARMONTH

SELECT TOKENNO, SUM(PF_E) PF_E, SUM(PF_C) PF_C, SUM(VPF) VPF, SUM(FPF) FPF, (SUM(PF_C)+ SUM(FPF) ) TOT_PF_C FROM PISPAYTRANSACTION
WHERE TOKENNO IN ('01192')
AND YEARCODE='2020-2021'
GROUP BY TOKENNO
ORDER BY TOKENNO

UPDATE PISPAYTRANSACTION SET PF_C=PF_C+FPF
WHERE TOKENNO IN ('01192')
AND YEARCODE='2020-2021'
AND YEARMONTH >= '202004'

UPDATE PISPAYTRANSACTION SET FPF=0
WHERE TOKENNO IN ('01192')
AND YEARCODE='2020-2021'
AND YEARMONTH >= '202004'


------------------------------------------------------------------------------------


SELECT TOKENNO,WORKERSERIAL,EMPLOYEENAME, PFAPPLICABLE, EPFAPPLICABLE, DATEOFBIRTH,DATEOFRETIRE, 
ADD_MONTHS(DATEOFBIRTH, 58*12) RETIRE_DATE , TO_DATE(202012,'YYYYMM') MONTH_START_DATE,
LAST_DAY(TO_DATE('202012','YYYYMM')) MONTH_END_DATE
FROM PISEMPLOYEEMASTER
WHERE TOKENNO='01192'


SELECT TOKENNO,YEARMONTH, PF_E, PF_C, VPF, FPF FROM PISPAYTRANSACTION
WHERE TOKENNO='01192'
ORDER BY YEARMONTH

SELECT TOKENNO, SUM(PF_E) PF_E, SUM(PF_C) PF_C, SUM(VPF) VPF, SUM(FPF) FPF, (SUM(PF_C)+ SUM(FPF) ) TOT_PF_C FROM PISPAYTRANSACTION
WHERE TOKENNO IN ('01192')
AND YEARCODE='2020-2021'
GROUP BY TOKENNO
ORDER BY TOKENNO

UPDATE PISPAYTRANSACTION SET PF_C=PF_C+FPF
WHERE TOKENNO IN ('01192')
AND YEARCODE='2020-2021'
AND YEARMONTH >= '202004'

UPDATE PISPAYTRANSACTION SET FPF=0
WHERE TOKENNO IN ('01192')
AND YEARCODE='2020-2021'
AND YEARMONTH >= '202004'


------------------------------------------------------------------------------------


SELECT TOKENNO,WORKERSERIAL,EMPLOYEENAME, PFAPPLICABLE, EPFAPPLICABLE, DATEOFBIRTH,DATEOFRETIRE, 
ADD_MONTHS(DATEOFBIRTH, 58*12) RETIRE_DATE , TO_DATE(202012,'YYYYMM') MONTH_START_DATE,
LAST_DAY(TO_DATE('202012','YYYYMM')) MONTH_END_DATE
FROM PISEMPLOYEEMASTER
WHERE TOKENNO='01213'


SELECT TOKENNO,YEARMONTH, PF_E, PF_C, VPF, FPF FROM PISPAYTRANSACTION
WHERE TOKENNO='01213'
ORDER BY YEARMONTH

SELECT TOKENNO, SUM(PF_E) PF_E, SUM(PF_C) PF_C, SUM(VPF) VPF, SUM(FPF) FPF, (SUM(PF_C)+ SUM(FPF) ) TOT_PF_C FROM PISPAYTRANSACTION
WHERE TOKENNO IN ('01213')
AND YEARCODE='2020-2021'
GROUP BY TOKENNO
ORDER BY TOKENNO

UPDATE PISPAYTRANSACTION SET PF_C=PF_C+FPF
WHERE TOKENNO IN ('01213')
AND YEARCODE='2020-2021'
AND YEARMONTH >= '202004'

UPDATE PISPAYTRANSACTION SET FPF=0
WHERE TOKENNO IN ('01213')
AND YEARCODE='2020-2021'
AND YEARMONTH >= '202004'

------------------------------------------------------------------------------------


SELECT TOKENNO,WORKERSERIAL,EMPLOYEENAME, PFAPPLICABLE, EPFAPPLICABLE, DATEOFBIRTH,DATEOFRETIRE, 
ADD_MONTHS(DATEOFBIRTH, 58*12) RETIRE_DATE , TO_DATE(202012,'YYYYMM') MONTH_START_DATE,
LAST_DAY(TO_DATE('202012','YYYYMM')) MONTH_END_DATE
FROM PISEMPLOYEEMASTER
WHERE TOKENNO='01219'


SELECT TOKENNO,YEARMONTH, PF_E, PF_C, VPF, FPF FROM PISPAYTRANSACTION
WHERE TOKENNO='01219'
ORDER BY YEARMONTH

SELECT TOKENNO, SUM(PF_E) PF_E, SUM(PF_C) PF_C, SUM(VPF) VPF, SUM(FPF) FPF, (SUM(PF_C)+ SUM(FPF) ) TOT_PF_C FROM PISPAYTRANSACTION
WHERE TOKENNO IN ('01219')
AND YEARCODE='2020-2021'
GROUP BY TOKENNO
ORDER BY TOKENNO

UPDATE PISPAYTRANSACTION SET PF_C=PF_C+FPF
WHERE TOKENNO IN ('01219')
AND YEARCODE='2020-2021'
AND YEARMONTH >= '202004'

UPDATE PISPAYTRANSACTION SET FPF=0
WHERE TOKENNO IN ('01219')
AND YEARCODE='2020-2021'
AND YEARMONTH >= '202004'



SELECT * FROM MENUMASTER_RND
WHERE MENUDESC LIKE 'PF and Loan%'


------------------------------------------------------------------------------------


SELECT TOKENNO,WORKERSERIAL,EMPLOYEENAME, PFAPPLICABLE, EPFAPPLICABLE, DATEOFBIRTH,DATEOFRETIRE, 
ADD_MONTHS(DATEOFBIRTH, 58*12) RETIRE_DATE , TO_DATE(202012,'YYYYMM') MONTH_START_DATE,
LAST_DAY(TO_DATE('202012','YYYYMM')) MONTH_END_DATE
FROM PISEMPLOYEEMASTER
WHERE TOKENNO='00473'


select * from pfloantransaction
where tokenno='00473'
and loancode='PFL'

select * from pfloanbreakup
where tokenno='00473'
and loancode='PFL'

select * from loantransaction
where tokenno='00473'

select * from loanbreakup
where tokenno='00473'
  

SELECT * FROM MENUMASTER_RND
WHERE MENUDESC LIKE 'PF and Loan%'


------------------------------------------------------------------------------------


SELECT TOKENNO,WORKERSERIAL,EMPLOYEENAME, PFAPPLICABLE, EPFAPPLICABLE, DATEOFBIRTH,DATEOFRETIRE, 
ADD_MONTHS(DATEOFBIRTH, 58*12) RETIRE_DATE , TO_DATE(202012,'YYYYMM') MONTH_START_DATE,
LAST_DAY(TO_DATE('202012','YYYYMM')) MONTH_END_DATE
FROM PISEMPLOYEEMASTER
WHERE TOKENNO='00926'


select * from pfloantransaction
where tokenno='00926'
and loancode='PFL'

select * from pfloanbreakup
where tokenno='00926'
and loancode='PFL'

select * from loantransaction
where tokenno='00473'

select * from loanbreakup
where tokenno='00473'
  

SELECT * FROM MENUMASTER_RND
WHERE MENUDESC LIKE 'PF and Loan%'


PROC_RPT_PF_LOANDEDN_TEXT('COMPANYCODE','DIVISIONCODE','YEARCODE','txtYEARMONTH','btnUnit','btnCategory') 


selct * pia