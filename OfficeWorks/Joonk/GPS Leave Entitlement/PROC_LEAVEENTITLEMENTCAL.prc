CREATE OR REPLACE PROCEDURE JOONK.PROC_LEAVEENTITLEMENTCAL
(
    --CREATED BY CHIRANJIT GHOSH ON 02/01/2020
    P_COMPCODE          VARCHAR2,
    P_DIVCODE           VARCHAR2,
    P_FROMDATE          VARCHAR2,
    P_TODATE            VARCHAR2,
    P_YEARCODE          VARCHAR2,
    P_CALENDARYEAR      VARCHAR2,
    P_CATEGORYCODE      VARCHAR2,
    P_LEAVECODE         VARCHAR2,
    P_YEARTYPE          VARCHAR2
)
AS
    LV_STRSQL           VARCHAR2(10000);
    
    LV_LASTYEAR         VARCHAR2(200);
    LV_LASTYEARCODE     VARCHAR2(2000);
BEGIN

    DELETE FROM GBL_LEAVEENTITLEMENTCAL;
    
    
    --    
    --SELECT TO_CHAR(TO_NUMBER('2019')-1) PREVYEAR FROM DUAL

    --SELECT (TO_NUMBER(SUBSTR('2019-2020',1,4))-1)||'-'||(TO_NUMBER(SUBSTR('2019-2020',-4))-1)XX FROM DUAL
        
    SELECT TO_CHAR(TO_NUMBER(P_CALENDARYEAR)-1) INTO LV_LASTYEAR FROM DUAL;

    SELECT (TO_NUMBER(SUBSTR(P_YEARCODE,1,4))-1)||'-'||(TO_NUMBER(SUBSTR(P_YEARCODE,-4))-1) INTO LV_LASTYEARCODE FROM DUAL;



    
--   EXEC PROC_LEAVEENTITLEMENTCAL('JT0069','0006','01/01/2019','31/12/2019','2019-2020','2019','SL1','C')
            
    --LV_REPORTHEADER := 'Leave with Wages Payment';
            
    --EXEC PROC_RPT_LEAVEWAGESPAYMENT('','','','')  
    
    IF P_YEARTYPE = 'C' THEN
            
        INSERT INTO GBL_LEAVEENTITLEMENTCAL         
        SELECT COMPANYCODE,DIVISIONCODE,DATEOFJOINING, TOKENNO,EMPLOYEENAME, NVL(CARRYFORWARD,0) CARRYFORWARD , ENTITLEMENT PREVIOUSENTITLEMENT, (NVL(CARRYFORWARD,0) +  ENTITLEMENT) ENTITLEMENTS,LEAVECODE,WORKERSERIAL,CATEGORYCODE,CALENDARYEAR,YEARCODE 
        FROM
        (
            SELECT TO_CHAR(B.DATEOFJOINING,'DD/MM/YYYY') DATEOFJOINING, B.TOKENNO, B.EMPLOYEENAME, A.LEAVEBAL, B.COMPANYCODE, B.DIVISIONCODE, 
            C.MAXCARRYFORWARDLIMIT,C.CARRYFORWARDUPTO,C.ENTITLEMENT MAXENTITLEMENT,B.WORKERSERIAL,B.CATEGORYCODE,(SELECT P_LEAVECODE FROM DUAL)  LEAVECODE, (SELECT P_CALENDARYEAR FROM DUAL) CALENDARYEAR,(SELECT P_YEARCODE FROM DUAL) YEARCODE,
            CASE WHEN A.LEAVEBAL = C.MAXCARRYFORWARDLIMIT THEN C.MAXCARRYFORWARDLIMIT 
            ELSE 
                CASE WHEN A.LEAVEBAL <  C.MAXCARRYFORWARDLIMIT THEN
                    CASE WHEN A.LEAVEBAL < C.CARRYFORWARDUPTO THEN A.LEAVEBAL 
                        ELSE C.CARRYFORWARDUPTO 
                    END
                END
            END
            CARRYFORWARD ,
             CASE WHEN C.CARRYFORWARDUPTO = 0 AND C.MAXCARRYFORWARDLIMIT = 0 THEN C.ENTITLEMENT 
            ELSE
                CASE WHEN A.LEAVEBAL = C.MAXCARRYFORWARDLIMIT AND C.MAXCARRYFORWARDLIMIT <> 0 THEN 0 ELSE C.ENTITLEMENT END
            END     ENTITLEMENT    
            FROM 
            (
                SELECT TOKENNO, SUM(BAL) LEAVEBAL 
                FROM 
                (
                    SELECT TOKENNO, -SUM(HAZIRA) BAL  FROM GPSATTENDANCEDETAILS
                    WHERE OCCUPATIONCODE=P_LEAVECODE
                    AND TO_CHAR(ATTENDANCEDATE,'YYYY') =  LV_LASTYEAR
                    AND COMPANYCODE=P_COMPCODE
                    AND DIVISIONCODE=P_DIVCODE
                    AND CATEGORYCODE=P_CATEGORYCODE
                    GROUP BY TOKENNO
                    UNION ALL
                    SELECT TOKENNO, SUM(NVL(ENTITLEMENTS,0)+NVL(CARRYFORWARD,0)) BAL 
                    FROM GPSLEAVEENTITLEMENT
                    WHERE LEAVECODE=P_LEAVECODE
                    AND COMPANYCODE=P_COMPCODE
                    AND DIVISIONCODE=P_DIVCODE
                    AND CATEGORYCODE=P_CATEGORYCODE
                    AND CALENDARYEAR=LV_LASTYEAR
                    GROUP BY TOKENNO
                )
                GROUP BY TOKENNO
            ) A, GPSEMPLOYEEMAST B, GPSLEAVEPARAMS C
            WHERE B.TOKENNO=A.TOKENNO(+)
            AND B.CATEGORYCODE=C.CATEGORYCODE
            AND B.COMPANYCODE=C.COMPANYCODE
            AND B.DIVISIONCODE=C.DIVISIONCODE
            AND B.COMPANYCODE=P_COMPCODE
            AND B.DIVISIONCODE=P_DIVCODE
            AND C.LEAVECODE=P_LEAVECODE
            AND C.CALENDARYEAR=P_CALENDARYEAR
            AND B.CATEGORYCODE=P_CATEGORYCODE
        )
        ORDER BY TOKENNO;
    ELSE
             
        INSERT INTO GBL_LEAVEENTITLEMENTCAL         
        SELECT COMPANYCODE,DIVISIONCODE,DATEOFJOINING, TOKENNO,EMPLOYEENAME, CARRYFORWARD , ENTITLEMENT PREVIOUSENTITLEMENT, (CARRYFORWARD +  ENTITLEMENT) ENTITLEMENTS,LEAVECODE,WORKERSERIAL,CATEGORYCODE,CALENDARYEAR,YEARCODE 
        FROM
        (
            SELECT TO_CHAR(B.DATEOFJOINING,'DD/MM/YYYY') DATEOFJOINING, A.TOKENNO, B.EMPLOYEENAME, A.LEAVEBAL, B.COMPANYCODE, B.DIVISIONCODE, 
            C.MAXCARRYFORWARDLIMIT,C.CARRYFORWARDUPTO,C.ENTITLEMENT MAXENTITLEMENT,B.WORKERSERIAL,B.CATEGORYCODE,(SELECT P_LEAVECODE FROM DUAL)  LEAVECODE, (SELECT P_CALENDARYEAR FROM DUAL) CALENDARYEAR,(SELECT P_YEARCODE FROM DUAL) YEARCODE,
            CASE WHEN A.LEAVEBAL = C.MAXCARRYFORWARDLIMIT THEN C.MAXCARRYFORWARDLIMIT 
            ELSE 
                CASE WHEN A.LEAVEBAL <  C.MAXCARRYFORWARDLIMIT THEN
                    CASE WHEN A.LEAVEBAL < C.CARRYFORWARDUPTO THEN A.LEAVEBAL 
                        ELSE C.CARRYFORWARDUPTO 
                    END
                END
            END
            CARRYFORWARD ,
            CASE WHEN C.CARRYFORWARDUPTO = 0 AND C.MAXCARRYFORWARDLIMIT = 0 THEN C.ENTITLEMENT 
            ELSE
                CASE WHEN A.LEAVEBAL = C.MAXCARRYFORWARDLIMIT AND C.MAXCARRYFORWARDLIMIT <> 0 THEN 0 ELSE C.ENTITLEMENT END
            END     ENTITLEMENT   
            FROM 
            (
                SELECT TOKENNO, SUM(BAL) LEAVEBAL 
                FROM 
                (
                    SELECT TOKENNO, -SUM(HAZIRA) BAL  FROM GPSATTENDANCEDETAILS
                    WHERE OCCUPATIONCODE=P_LEAVECODE
                    AND YEARCODE =  LV_LASTYEARCODE
                    AND COMPANYCODE=P_COMPCODE
                    AND DIVISIONCODE=P_DIVCODE
                    AND CATEGORYCODE=P_CATEGORYCODE
                    GROUP BY TOKENNO
                    UNION ALL
                    SELECT TOKENNO, SUM(NVL(ENTITLEMENTS,0)+NVL(CARRYFORWARD,0)) BAL 
                    FROM GPSLEAVEENTITLEMENT
                    WHERE LEAVECODE=P_LEAVECODE
                    AND COMPANYCODE=P_COMPCODE
                    AND DIVISIONCODE=P_DIVCODE
                    AND CATEGORYCODE=P_CATEGORYCODE
                    AND YEARCODE =  LV_LASTYEARCODE
                    GROUP BY TOKENNO
                )
                GROUP BY TOKENNO
            ) A, GPSEMPLOYEEMAST B, GPSLEAVEPARAMS C
            WHERE B.TOKENNO=A.TOKENNO(+)
            AND B.CATEGORYCODE=C.CATEGORYCODE
            AND B.COMPANYCODE=C.COMPANYCODE
            AND B.DIVISIONCODE=C.DIVISIONCODE
            AND B.COMPANYCODE=P_COMPCODE
            AND B.DIVISIONCODE=P_DIVCODE
            AND C.LEAVECODE=P_LEAVECODE
            AND C.YEARCODE=P_YEARCODE
            AND B.CATEGORYCODE=P_CATEGORYCODE
        )
        ORDER BY TOKENNO;
    END IF;
EXCEPTION WHEN OTHERS THEN NULL;
                                    
END;
/
