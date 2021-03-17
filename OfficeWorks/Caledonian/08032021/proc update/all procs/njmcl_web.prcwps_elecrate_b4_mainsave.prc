DROP PROCEDURE NJMCL_WEB.PRCWPS_ELECRATE_B4_MAINSAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRCWPS_ELECRATE_B4_MAINSAVE" 
    IS
    LV_CNT                  NUMBER;
    LV_RESULT               VARCHAR2(10);
    LV_ERROR_REMARK         VARCHAR2(4000) := '' ;
    LV_MASTER               GBL_ELECTRICMETERREADING%ROWTYPE;
    LV_MAXEFFECTIVEDATE            DATE;
    LV_COMPANYCODE          VARCHAR2(10) :='';
    LV_DIVISIONCODE         VARCHAR2(10) :='';
    LV_QUARTERNO        VARCHAR2(10) :='';
    LV_SLABFROM              NUMBER;
    LV_SLABTO               NUMBER;
    LV_AMOUNT               NUMBER;
    LEFT_UNIT               NUMBER;
    LV_OPTMODE              VARCHAR2(1) :='';
    
    BEGIN
    LV_RESULT:='#SUCCESS#';
                   
    LV_CNT := 0;
    SELECT COUNT(*)
    INTO LV_CNT
    FROM GBL_ELECTRICMETERREADING;
                        
        IF  NVL(LV_CNT,0) =0 THEN
        LV_ERROR_REMARK := 'No details available to save.';
        RAISE_APPLICATION_ERROR(TO_NUMBER(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,LV_ERROR_REMARK));
        END IF;
                            
        SELECT DISTINCT OPERATIONMODE 
        INTO LV_OPTMODE
        FROM GBL_ELECTRICMETERREADING;                            
                          
            IF NVL(LV_OPTMODE,'NA') <>'D' THEN                          
            
                               
            FOR C1 IN (SELECT * FROM GBL_ELECTRICMETERREADING) LOOP
                LV_AMOUNT := 0;
                LEFT_UNIT := C1.CHARGEUNIT ;
              FOR C2 IN(SELECT SLABFROM,SLABTO,AMOUNT,MAX(WITHEFFECTFROM)   WITHEFFECTFROM                       
                            FROM COMPONENTSLABMASTER
                            WHERE COMPANYCODE = C1.COMPANYCODE
                            AND DIVISIONCODE = C1.DIVISIONCODE
                           AND COMPONENTCODE = 'ELECTRICITY'
                          AND WITHEFFECTFROM<=C1.READINGDATE
                          GROUP BY SLABFROM,SLABTO,AMOUNT 
                          ORDER BY SLABFROM) LOOP                   
                IF LEFT_UNIT > ( C2.SLABTO - C2.SLABFROM ) THEN
                    LV_AMOUNT := LV_AMOUNT + ( C2.AMOUNT*(C2.SLABTO-C2.SLABFROM) );
                    LEFT_UNIT :=  LEFT_UNIT - ( C2.SLABTO - C2.SLABFROM ) ;
                ELSE
                   LV_AMOUNT := LV_AMOUNT + C2.AMOUNT*LEFT_UNIT;
                   EXIT;
                END IF;               
                
              END LOOP;  
                                    
              UPDATE GBL_ELECTRICMETERREADING
              SET ELEC_DED_AMT = LV_AMOUNT,ELEC_EMI=(LV_AMOUNT/2)
              WHERE NVL(COMPANYCODE,'X') = NVL(C1.COMPANYCODE,'X')
              AND NVL(DIVISIONCODE,'X') = NVL(C1.DIVISIONCODE,'X')
              AND NVL(QUARTERNO,'X') = NVL(C1.QUARTERNO,'X')
              AND NVL(YEARMONTH,'X') = NVL(C1.YEARMONTH,'X');
            END LOOP;
                           
        END IF;
    --EXCEPTION WHEN OTHERS THEN
    --    LV_ERROR_REMARK:= LV_ERROR_REMARK || '#UNSUCC#ESSFULL#';
    --    RAISE_APPLICATION_ERROR(TO_NUMBER(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,LV_ERROR_REMARK));
    END;
/


