DROP PROCEDURE NJMCL_WEB.PRCWPS_QUARTERALLOC_B4SAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRCWPS_QUARTERALLOC_B4SAVE" 
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
lv_QUARTERNO_Allocated varchar2(50);

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
        
        IF lv_Master.TOKENNO IS NULL  AND lv_Master.QUARTERSTATUS='ALLOCATED' THEN
            lv_error_remark := 'Validation Failure : [Token No No is blank!!! ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF;
        
        
        UPDATE GBL_QUARTERALLOCATION SET TOKENNO=lv_Master.COMPANYCODE,WORKERSERIAL=lv_Master.COMPANYCODE
        WHERE WORKERSERIAL IS NULL;
       
       if nvl(lv_Master.operationmode,'NA') = 'A' then
        
        select count(*)
        into lv_cnt
        FROM QUARTERALLOCATIONDETAILS
        WHERE 1=1
        AND COMPANYCODE=lv_Master.COMPANYCODE
        AND DIVISIONCODE=lv_Master.DIVISIONCODE
        AND WORKERSERIAL=lv_Master.WORKERSERIAL
        AND QUARTERSTATUS='ALLOCATED'
        AND RELEASEDATE IS NULL;             
        
        IF NVL(lv_cnt,0)>0 THEN
        
            select QUARTERNO
            into lv_QUARTERNO_Allocated
            FROM QUARTERALLOCATIONDETAILS
            WHERE 1=1
            AND COMPANYCODE=lv_Master.COMPANYCODE
            AND DIVISIONCODE=lv_Master.DIVISIONCODE
            AND WORKERSERIAL=lv_Master.WORKERSERIAL
            AND QUARTERSTATUS='ALLOCATED'
            AND RELEASEDATE IS NULL 
            and rownum=1;   
        
            lv_error_remark := 'Validation Failure : [TOKEN NO Already Allocated With Different Quarter - '||lv_QUARTERNO_Allocated||' ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF; 
         
        select count(*)
        into lv_cnt
        FROM QUARTERALLOCATIONDETAILS
        WHERE 1=1
        AND COMPANYCODE=lv_Master.COMPANYCODE
        AND DIVISIONCODE=lv_Master.DIVISIONCODE
        AND LINENO=lv_Master.LINENO
        AND QUARTERNO=lv_Master.QUARTERNO
        --AND TOKENNO=lv_Master.TOKENNO
        AND WORKERSERIAL=lv_Master.WORKERSERIAL
        AND QUARTERSTATUS=lv_Master.QUARTERSTATUS;
        
         IF lv_cnt>0 THEN
            lv_error_remark := 'Validation Failure : [Already Allocated this Quarter With this Token No!!! ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF; 
         
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
        
         
        
        
            
        IF lv_MaxAllocationdate IS NOT NULL THEN 
        SELECT lv_Master.EFFECTIVEDATE -  
        lv_MaxAllocationdate into lv_DateCount
        FROM   dual;
        
        --lv_error_remark := 'lv_DateCount'||lv_DateCount;
        --raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        
        IF lv_DateCount<0 THEN
            lv_error_remark := 'Validation Failure : [Current Effective Date Cannot be Less than Last Effective Date]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF; 
        
        if lv_DateCount>0 then
            select (lv_Master.EFFECTIVEDATE-1) into lv_Lastdate from dual;
        end if;
        
        --lv_error_remark := 'lv_Lastdate~'||lv_Lastdate;
        --raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
        
        END IF;
            if lv_Lastdate is not null then 
        
                UPDATE QUARTERALLOCATIONDETAILS SET RELEASEDATE=lv_Lastdate 
                where
                    COMPANYCODE=lv_Master.COMPANYCODE
                AND DIVISIONCODE=lv_Master.DIVISIONCODE
                AND LINENO=lv_Master.LINENO
                AND QUARTERNO=lv_Master.QUARTERNO
                AND EFFECTIVEDATE=lv_MaxAllocationdate
                AND RELEASEDATE IS NULL;
            end if;
    END IF; 

       end if;
       
end;
/


