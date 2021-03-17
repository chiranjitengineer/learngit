DROP PROCEDURE NJMCL_WEB.PRCWPS_TOKENCHANGE_B4SAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.prcWPS_TOKENCHANGE_b4Save
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_WPSWORKERTOKENCHANGE%rowtype;
lv_ApplicationNo        varchar2(50);

begin

    lv_result:='#SUCCESS#';
    
    select *
    into lv_Master
    from GBL_WPSWORKERTOKENCHANGE
    WHERE ROWNUM<=1;
            
    select count(*)
    into lv_cnt
    from GBL_WPSWORKERTOKENCHANGE;
        
     IF NVL(lv_cnt,0)=0 THEN
        lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
    END IF;
        
    IF lv_Master.OPERATIONMODE IS NULL THEN
        lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    END IF;

/*
            
    lv_cnt :=0;
    select count(*)
    into lv_cnt
    from WPSATTENDANCEDAYWISE
    WHERE DATEOFATTENDANCE=to_date(lv_Master.EFFECTIVEDATE,'DD/MM/RRRR');

    IF NVL(lv_cnt,0)>0 THEN
        lv_error_remark := 'Validation Failure : [Attendance exist in this effectivedate!]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
    END IF;
 */   
    lv_cnt :=0;
    select count(*)
    into lv_cnt
    from WPSWORKERMAST
    WHERE TOKENNO=TRIM(lv_Master.OLDTOKENNO);

    IF NVL(lv_cnt,0)=0 THEN
        lv_error_remark := 'Validation Failure : [Invalid Old Tokenno!] ' || lv_Master.OLDTOKENNO;
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
    END IF;
    
    lv_cnt :=0;
    select count(*)
    into lv_cnt
    from WPSWORKERMAST
    WHERE TOKENNO=TRIM(lv_Master.NEWTOKENNO);

    IF NVL(lv_cnt,0)> 0 THEN
        lv_error_remark := 'Validation Failure : [New Tokenno already exist!]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
    END IF;
    
    lv_cnt :=0;
    select count(*)
    into lv_cnt
    from WPSWORKERCATEGORYMAST
    WHERE WORKERCATEGORYCODE=TRIM(lv_Master.NEWWORKERCATEGORYCODE);

    IF NVL(lv_cnt,0)=0 THEN
        lv_error_remark := 'Validation Failure : [Invalid Categorycode!]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
    END IF;
    
    
    UPDATE WPSWORKERMAST 
       SET  TOKENNO = TRIM(lv_Master.NEWTOKENNO),
            WORKERCATEGORYCODE=TRIM(lv_Master.NEWWORKERCATEGORYCODE),
            CONTRACTORCODE=TRIM(lv_Master.NEWCONTRACTORCODE),
            CONTRACTORNAME=TRIM(lv_Master.NEWCONTRACTORNAME),
            FIXEDBASIC=lv_Master.NEWBASIC,
            DARATE=lv_Master.NEWDA
     WHERE COMPANYCODE = TRIM(lv_Master.COMPANYCODE)
       AND DIVISIONCODE = TRIM(lv_Master.DIVISIONCODE)
       AND TOKENNO = TRIM(lv_Master.OLDTOKENNO)
       AND WORKERSERIAL=TRIM(lv_Master.WORKERSERIAL);
       
    UPDATE WPSATTENDANCEDAYWISE
       SET TOKENNO = TRIM(lv_Master.NEWTOKENNO),
           WORKERCATEGORYCODE=TRIM(lv_Master.NEWWORKERCATEGORYCODE)
     WHERE DATEOFATTENDANCE >=to_date(lv_Master.EFFECTIVEDATE,'DD/MM/RRRR')
       AND TOKENNO = TRIM(lv_Master.OLDTOKENNO)
       AND WORKERSERIAL=TRIM(lv_Master.WORKERSERIAL);
    
end;
/


