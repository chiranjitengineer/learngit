DROP PROCEDURE NJMCL_WEB.PRCWPS_QUARTERALLOC_AFTERSAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRCWPS_QUARTERALLOC_AFTERSAVE" 
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_QUARTERALLOCATION%rowtype;
lv_MaxAllocationdate    date;
lv_Lastdate             date;
lv_LastStatus           varchar2(50);
lv_LastTokenNo          varchar2(50);
lv_LastWorkerSerialNo          varchar2(50);
lv_DateCount                  number; 

begin

    lv_result:='#SUCCESS#';
    
    --return;
    
        select *
        into lv_Master
        from GBL_QUARTERALLOCATION
        WHERE ROWNUM<=1;

        select count(*)
        into lv_cnt
        from GBL_QUARTERALLOCATION;
        
         IF NVL(lv_cnt,0)=0 THEN
            lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
        END IF;
        
        IF lv_Master.OPERATIONMODE IS NULL THEN
            lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF; 
        
        
        select count(*)
        into lv_cnt
        FROM QUARTERALLOCATIONDETAILS
        WHERE 1=1
        AND COMPANYCODE=lv_Master.COMPANYCODE
        AND DIVISIONCODE=lv_Master.DIVISIONCODE
        AND LINENO=lv_Master.LINENO
        AND QUARTERNO=lv_Master.QUARTERNO;
        --AND TOKENNO=lv_Master.TOKENNO
        --AND WORKERSERIAL=lv_Master.WORKERSERIAL
        --AND QUARTERSTATUS=lv_Master.QUARTERSTATUS;              
        
       
        
        IF lv_cnt>0 THEN
        
            select count(*)
            into lv_cnt
            FROM QUARTERALLOCATIONDETAILS
            WHERE 1=1
            AND COMPANYCODE=lv_Master.COMPANYCODE
            AND DIVISIONCODE=lv_Master.DIVISIONCODE
            AND LINENO=lv_Master.LINENO
            AND QUARTERNO=lv_Master.QUARTERNO
            AND EFFECTIVEDATE=
            (
            SELECT MAX(EFFECTIVEDATE) FROM QUARTERALLOCATIONDETAILS
            WHERE 1=1
            AND COMPANYCODE=lv_Master.COMPANYCODE
            AND DIVISIONCODE=lv_Master.DIVISIONCODE
            AND LINENO=lv_Master.LINENO
            AND QUARTERNO=lv_Master.QUARTERNO
            )AND ROWNUM=1;
            
             
            
            IF lv_cnt>0 THEN 
                SELECT QUARTERSTATUS,EFFECTIVEDATE,TOKENNO,WORKERSERIAL 
                into 
                lv_LastStatus,lv_MaxAllocationdate,lv_LastTokenNo,lv_LastWorkerSerialNo 
                FROM QUARTERALLOCATIONDETAILS
                WHERE 1=1
                AND COMPANYCODE=lv_Master.COMPANYCODE
                AND DIVISIONCODE=lv_Master.DIVISIONCODE
                AND LINENO=lv_Master.LINENO
                AND QUARTERNO=lv_Master.QUARTERNO
                AND EFFECTIVEDATE=
                (
                SELECT MAX(EFFECTIVEDATE) FROM QUARTERALLOCATIONDETAILS
                WHERE 1=1
                AND COMPANYCODE=lv_Master.COMPANYCODE
                AND DIVISIONCODE=lv_Master.DIVISIONCODE
                AND LINENO=lv_Master.LINENO
                AND QUARTERNO=lv_Master.QUARTERNO
                )AND ROWNUM=1;
                
               --lv_error_remark := 'lv_LastStatus'||lv_LastStatus;
                --raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
             
                UPDATE QUARTERMASTER SET QUARTERSTATUS=lv_LastStatus
                WHERE
                    COMPANYCODE=lv_Master.COMPANYCODE
                AND DIVISIONCODE=lv_Master.DIVISIONCODE
                AND LINENO=lv_Master.LINENO
                AND QUARTERNO=lv_Master.QUARTERNO;
                
            
            END IF;
        
        ELSE
        
         UPDATE QUARTERMASTER SET QUARTERSTATUS='VACANT'
                WHERE
                    COMPANYCODE=lv_Master.COMPANYCODE
                AND DIVISIONCODE=lv_Master.DIVISIONCODE
                AND LINENO=lv_Master.LINENO
                AND QUARTERNO=lv_Master.QUARTERNO;
        
        END IF;
        
        IF NVL(LV_MASTER.OPERATIONMODE,'NA') = 'D' THEN
           
           UPDATE  QUARTERALLOCATIONDETAILS SET RELEASEDATE=NULL
                WHERE 1=1
                AND COMPANYCODE=lv_Master.COMPANYCODE
                AND DIVISIONCODE=lv_Master.DIVISIONCODE
                AND LINENO=lv_Master.LINENO
                AND QUARTERNO=lv_Master.QUARTERNO
                AND EFFECTIVEDATE=
                (
                SELECT MAX(EFFECTIVEDATE) FROM QUARTERALLOCATIONDETAILS
                WHERE 1=1
                AND COMPANYCODE=lv_Master.COMPANYCODE
                AND DIVISIONCODE=lv_Master.DIVISIONCODE
                AND LINENO=lv_Master.LINENO
                AND QUARTERNO=lv_Master.QUARTERNO
                )AND ROWNUM=1;
        END IF;
       
end;
/


