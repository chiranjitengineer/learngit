DROP PROCEDURE NJMCL_WEB.PRCWPSDAILYLOOM_AF_SAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PRCWPSDAILYLOOM_AF_SAVE
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_COMPCODE             varchar2(10) :='';
lv_DIVCODE              varchar2(10) :='';
lv_CopyFrom_dt          DATE;
lv_EntryDate            date;
lv_OperationMode        varchar2(1) :='';
lv_FORTNIGHTNO          number(11,2) := '';
lv_QUALITYCODE          varchar2(10) := '';
lv_USER                 varchar2(50) := '';
begin
    lv_result:='#SUCCESS#';
    --Master
    select count(*)
    into lv_cnt
    from GBL_WPSDAILYLOOMALLOCATION;
   
    ---- THIS IS PROCEDURE USE FOR COPY ALL DAILY LOOM ALLOCATION FROM COPY_FROM DATE ----- 

    if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [No row found in Loom Allocation Entry]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
    SELECT COUNT (A.QUALITYCODE) into lv_cnt
    from WPSDAILYLOOMALLOCATION A , GBL_WPSDAILYLOOMALLOCATION B
    where A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE
      AND A.DATEOFENTRY = B.DATEOFENTRY
      AND A.QUALITYCODE <> B.QUALITYCODE;
        
    IF lv_cnt = 0 THEN
        select distinct companycode, divisioncode, COPYFROM_DT, DATEOFENTRY, QUALITYCODE, FORTNIGHTNO, USERNAME
        INTO lv_COMPCODE, lv_DIVCODE, lv_CopyFrom_dt, lv_EntryDate, lv_QUALITYCODE, lv_FORTNIGHTNO, lv_USER
        FROM GBL_WPSDAILYLOOMALLOCATION;
        
        INSERT INTO WPSDAILYLOOMALLOCATION ( COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, DATEOFENTRY, FORTNIGHTNO, REEDSPACE, QUALITYCODE, 
            MACHINECODE, LOOMDESC, LINENO, ZONENO, EDITED, LOOMCODE, USERNAME, SYSROWID, LASTMODIFIED)
        SELECT COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, lv_EntryDate DATEOFENTRY, lv_FORTNIGHTNO FORTNIGHTNO, REEDSPACE, QUALITYCODE, 
            MACHINECODE, LOOMDESC, LINENO, ZONENO, EDITED, LOOMCODE, lv_USER USERNAME, sys_guid() SYSROWID, sysdate LASTMODIFIED
        from WPSDAILYLOOMALLOCATION 
        where COMPANYCODE = lv_COMPCODE AND DIVISIONCODE = lv_DIVCODE
          AND DATEOFENTRY = lv_CopyFrom_dt
          AND QUALITYCODE <> lv_QUALITYCODE;
    END IF;
    
end;
/


