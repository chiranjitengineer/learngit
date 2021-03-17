DROP PROCEDURE NJMCL_WEB.PRCWPS_IMPORTATTENDANCEDATA;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRCWPS_IMPORTATTENDANCEDATA" (  P_COMPCODE VARCHAR2, 
                                                          P_DIVCODE VARCHAR2,
                                                          P_DATEOFATTENDANCE VARCHAR2, 
                                                          P_MACHINECODE VARCHAR2,
                                                          P_YEARCODECODE VARCHAR2,
                                                          P_USERNAME VARCHAR2 
                                                        )
IS
LV_CNT                          NUMBER := 0;
BEGIN

SELECT COUNT(*)
    INTO LV_CNT
    FROM (  
            SELECT TOKENNO 
              FROM WPSATTENDANCEDEVICERAWDATA
             WHERE TO_DATE(DATEOFATTENDANCE,'DD/MM/RRRR') = TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')            
         );
         
    IF LV_CNT > 0 THEN
        INSERT INTO GBL_WPSATTENDANCEDAYWISE (ATTENDANCEHOURS,SPELLHOURS,DEDUCTIONHOURS,SPELLTYPE,
                    WORKERTYPECODE,OCCUPATIONCODE,WORKERCATEGORYCODE,TOKENNO,WORKERSERIAL,PAGENO,SERIALNO,SHIFTCODE,PARENTSHIFTCODE,
                    DEPARTMENTCODE,DATEOFATTENDANCE,FORTNIGHTSTARTDATE,FORTNIGHTENDDATE,
                    COMPANYCODE,DIVISIONCODE,YEARCODE,SYSROWID,USERNAME,OPERATIONMODE,MODULE)
        SELECT MAXSPELLHOURS ATTENDANCEHOURS,MAXSPELLHOURS SPELLHOURS, 0 DEDUCTIONHOURS,D.SPELLTYPE,--'' REMARKS,'' ISDAYOFF,
               --'' LOOMCODE,'' MACHINECODE2,'' MACHINECODE1,'' SARDERNO,'' HELPERNO, 0 PAGESERIALNO,,MACHINEMANDETORY
               B.WORKERTYPECODE,NVL(C.OCCUPATIONCODE,A.OCCUPATIONCODE) OCCUPATIONCODE,
               A.WORKERCATEGORYCODE,A.TOKENNO,A.WORKERSERIAL,0 PAGENO,'1' SERIALNO,Z.SHIFTCODE, SHIFT PARENTSHIFTCODE,
               NVL(B.DEPARTMENTCODE,A.DEPARTMENTCODE) DEPARTMENTCODE,TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY') DATEOFATTENDANCE,'' FORTNIGHTSTARTDATE,
               '' FORTNIGHTENDDATE,P_COMPCODE COMPANYCODE,P_DIVCODE DIVISIONCODE,P_YEARCODECODE YEARCODE,'' SYSROWID, P_USERNAME USERNAME,
               'A' OPERATIONMODE,'' MODULE
          FROM WPSWORKERMAST A, WPSOCCUPATIONMAST B,(SELECT DISTINCT DEPARTMENTCODE,OCCUPATIONCODE,WORKERSERIAL 
                                                       FROM WPSATTENDANCEDAYWISE
                                                      WHERE COMPANYCODE = P_COMPCODE  AND DIVISIONCODE = P_DIVCODE 
                                                        AND DATEOFATTENDANCE||WORKERSERIAL IN (SELECT MAX(DATEOFATTENDANCE)||WORKERSERIAL
                                                                                                FROM WPSATTENDANCEDAYWISE   
                                                                                               WHERE COMPANYCODE = P_COMPCODE  AND DIVISIONCODE = P_DIVCODE 
                                                                                                 AND DATEOFATTENDANCE<=TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')     
                                                                                               GROUP BY WORKERSERIAL
                                                                                              )
                                                    ) C, WPSSPELLMASTER D,
                                                    (
                                                      SELECT TOKENNO,DATEOFATTENDANCE,TIMEOFATTENDANCE,SHIFTCODE,SHIFTNAME 
                                                        FROM
                                                            (  
                                                                SELECT TOKENNO,TO_DATE(DATEOFATTENDANCE,'DD/MM/RRRR') DATEOFATTENDANCE, MIN(TIMEOFATTENDANCE) TIMEOFATTENDANCE
                                                                  FROM WPSATTENDANCEDEVICERAWDATA
                                                                GROUP BY TOKENNO,DATEOFATTENDANCE  
                                                                ORDER BY TOKENNO,DATEOFATTENDANCE, TIMEOFATTENDANCE   
                                                            ) A,
                                                            (
                                                                SELECT *
                                                                  FROM WPSSHIFTMAST
                                                            ) B
                                                       WHERE A.TIMEOFATTENDANCE BETWEEN B.TIMEFROM AND B.TIMETO     
                                                    ) Z
        WHERE A.COMPANYCODE = P_COMPCODE  AND A.DIVISIONCODE = P_DIVCODE   AND A.TOKENNO = Z.TOKENNO
          AND A.COMPANYCODE =B.COMPANYCODE  AND A.DIVISIONCODE =B.DIVISIONCODE  
          AND A.OCCUPATIONCODE=B.OCCUPATIONCODE
          AND A.WORKERSERIAL=C.WORKERSERIAL(+)
          AND A.COMPANYCODE=D.COMPANYCODE AND A.DIVISIONCODE =D.DIVISIONCODE;
          
          prcWPS_Attendance_b4Save;  
          PROC_SD_GTTVSACTUAL_SYNC('GBL_WPSATTENDANCEDAYWISE','A');
          COMMIT;
    END IF;
                                 
/*EXCEPTION
WHEN OTHERS THEN
 --INSERT INTO ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) VALUES( 'ERROR SQL',LV_SQLSTR,LV_SQLSTR,LV_PARVALUES,LV_REMARKS);
 LV_SQLERRM := SQLERRM ;
 INSERT INTO WPS_ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) VALUES( 'prcWPS_VIEWCREATION',LV_SQLERRM,LV_SQLSTR,LV_PARVALUES,LV_FN_STDT,LV_FN_ENDT, LV_REMARKS);*/
END;
/


