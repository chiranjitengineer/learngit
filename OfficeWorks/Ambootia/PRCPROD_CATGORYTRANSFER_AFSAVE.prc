CREATE OR REPLACE PROCEDURE AMBOOTIA.prcProd_CatgoryTransfer_afSave
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_PRODCATEGORYTRANSFERDTLS%rowtype;
lv_MaxDRCRdate          date;
lv_TransactionNo        varchar2(50);   
lv_BatchNo        varchar2(50);   

begin

    lv_result:='#SUCCESS#';
    
    
        select *
        into lv_Master
        from GBL_PRODCATEGORYTRANSFERDTLS
        WHERE ROWNUM<=1;

        select count(*)
        into lv_cnt
        from GBL_PRODCATEGORYTRANSFERDTLS;
        
         IF NVL(lv_cnt,0)=0 THEN
            lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
        END IF;
        
        IF lv_Master.OPERATIONMODE IS NULL THEN
            lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF;            
     


        if nvl(lv_Master.operationmode,'NA') = 'A' then
        
        
--SELECT FN_GETBATCH('AM0082','A16','A16','TRANSFER','01/09/2020','OWN','TRANSFER','TRANSFER') FROM DUAL

--                lv_BatchNo := FN_GETBATCH(
--                        lv_Master.COMPANYCODE,
--                        lv_Master.DIVISIONCODE,
--                        lv_Master.DIVISIONCODE,
--                        'TRANSFER',
--                        lv_Master.TRANSFERDATE,
--                        'OWN',
--                        'TRANSFER',
--                        'TRANSFER'
--                    );
--        
--FN_GETBATCH (
--   P_COMPANYCODE      VARCHAR2,
--   P_DIVOWN           VARCHAR2,
--   P_DIVISIONCODE     VARCHAR2,
--   P_AREACODE         VARCHAR2,
--   P_WITHERINGDATE    VARCHAR2,
--   P_RECEIPTTYPE      VARCHAR2,
--   P_TROUGHNO         VARCHAR2,
--   P_FLAG             VARCHAR2) 
        
                INSERT INTO PRODDAILYDRYERDETAILS
                (
                    COMPANYCODE, DIVISIONCODE, YEARCODE, SEASON, DRYERNO, TEACATEGORYCODE, PRODUCTIONDATE, DRYERMACHINENO, 
                    DRYERSTARTDATE, DRYERSTARTTIME, DRYERENDDATE, DRYERENDTIME, BDREASONCODE, BDTIME, BATCHNO, DRYERQTY, 
                    INTIME, OUTTIME, RUNNINGTIME, TEAMADEQTY, T1, T2, T3, T5, USERNAME, SYSROWID, TRANDATE, OWNBOUGHT, LASTMODIFIED
                )
                SELECT COMPANYCODE, DIVISIONCODE, YEARCODE,TO_CHAR(TRANSFERDATE,'YYYY') SEASON,DOCUMENTNO DRYERNO,
                CATEGORYCODETO TEACATEGORYCODE,TRANSFERDATE PRODUCTIONDATE,NULL DRYERMACHINENO,TRANSFERDATE DRYERSTARTDATE,
                NULL DRYERSTARTTIME,TRANSFERDATE DRYERENDDATE,NULL DRYERENDTIME,NULL BDREASONCODE, NULL BDTIME,
                DOCUMENTNO BATCHNO,0 DRYERQTY,NULL INTIME,NULL OUTTIME,NULL RUNNINGTIME,
                TRANSFERQTY TEAMADEQTY,NULL T1,NULL T2,NULL T3,NULL T5, 
                USERNAME,SYS_GUID() SYSROWID,TRANSFERDATE TRANDATE,'CAT_TRANSFER' OWNBOUGHT,SYSDATE LASTMODIFIED
                FROM GBL_PRODCATEGORYTRANSFERDTLS;
                
                
--            IF nvl(lv_TransactionNo,'NA') <> 'NA' then
--                lv_error_remark := 'DOCUMENT No not generated. Check Parameters for Auto Gen.';
--                raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
--            end if;
            
        end if;
        
 --exception when others then
--    lv_error_remark:= lv_error_remark || '#UNSUCC#ESSFULL#';
--    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
end;
/
