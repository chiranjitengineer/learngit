CREATE OR REPLACE TRIGGER "TRG_SEND_EMAIL" 
after insert ON  GTT_EMAIL_DATA for each row
declare
t_a table_attachments := NULL;
lv_subject varchar2(2000)  ;
lv_body clob;
lv_cc varchar2(200);
lv_to varchar2(50);
lv_from varchar2(50) ;
lv_SENDER_EMAIL_PWD varchar2(50);
lv_sqlerrm varchar2(4000);
BEGIN 
 /*  
  BEGIN 
   insert into GTT_EMAIL_DATA_P (COMPANYCODE, DIVISIONCODE, DOCUMENT_TYPE, SENDER_EMAIL_ID, SENDER_EMAIL_PWD, RECEIVER_EMAIL_ID, CC_EMAIL_ID, EMAIL_SUBJECT, EMAIL_BODY, ATTACHMENT_FILENAME, ATTACHMENT_BLOB)
                          values(:NEW.COMPANYCODE,:NEW.DIVISIONCODE,:NEW.DOCUMENT_TYPE,:NEW.SENDER_EMAIL_ID,:NEW.SENDER_EMAIL_PWD,:NEW.RECEIVER_EMAIL_ID,:NEW.CC_EMAIL_ID,:NEW.EMAIL_SUBJECT,:NEW.EMAIL_BODY,:NEW.ATTACHMENT_FILENAME,:NEW.ATTACHMENT_BLOB);
  EXCEPTION
   WHEN OTHERS THEN
    lv_sqlerrm := sqlerrm;
    insert into error_log(ERROR_DATE, ERROR_TEXT) 
    values(sysdate,substr(lv_sqlerrm,1,30)||' - '||:NEW.DOCUMENT_TYPE||' - '||:NEW.ATTACHMENT_FILENAME||' - '||:NEW.RECEIVER_EMAIL_ID);
    --NULL;
  END; */
  --select 'Attachment from trigger', 'Pl. download the attached '||:NEW.ATTACHMENT_TYPE||' report ...' into lv_subject , lv_body from dual; 
   select :NEW.SENDER_EMAIL_ID,:NEW.SENDER_EMAIL_PWD,:NEW.RECEIVER_EMAIL_ID,:NEW.CC_EMAIL_ID,:NEW.EMAIL_SUBJECT,:NEW.EMAIL_BODY into lv_from,lv_SENDER_EMAIL_PWD,lv_to,lv_cc ,lv_subject, lv_body from dual;
   if :new.ATTACHMENT_FILENAME is not null then
       SELECT email_attachment(:new.ATTACHMENT_FILENAME,'IMAGE/JPEG',:new.ATTACHMENT_BLOB) BULK COLLECT INTO t_a FROM dual ; 
       ----dbms_output.put_line( lv_to||' ---- '||lv_cc ) ;
         -- utl_tcp.close_all_connections ; -- added to close open connections --   
      --  WAIT_SEC(3);
   end if;
     custom_send_mail (p_from   => '<'||lv_from||'>' ,    
                                       p_to     => '<'||lv_to||'>' ,                                       
                                       p_cc     =>  lv_cc,                                     
                                       p_subject     => lv_subject ,
                                       p_text_msg => lv_body,                                     
                                       p_attachments => t_a ,
                                       p_smtp_host =>  '192.168.4.4'  , --'192.168.0.249', 
                                       p_smtp_domain => 'gmail.com' , --'gmail.com' ,
                                       p_username => lv_from , --'automailer.howrah@gmail.com' ,
                                       p_password  => lv_SENDER_EMAIL_PWD ) ; -- '123abcxyz');  
  --------
  insert into EMAIL_HISTORY
  (COMPANYCODE, 
  DIVISIONCODE, 
  DOCUMENT_TYPE, 
  SENDER_EMAIL_ID, 
  SENDER_EMAIL_PWD, 
  RECEIVER_EMAIL_ID, 
  CC_EMAIL_ID, 
  EMAIL_SUBJECT, 
  EMAIL_BODY, 
  ATTACHMENT_FILENAME, 
  STATUS  
  )
  values
  (
  :NEW.COMPANYCODE ,
  :NEW.DIVISIONCODE,
  :NEW.DOCUMENT_TYPE ,
  :NEW.SENDER_EMAIL_ID,
  :NEW.SENDER_EMAIL_PWD,
  :NEW.RECEIVER_EMAIL_ID,
  :NEW.CC_EMAIL_ID,
  :NEW.EMAIL_SUBJECT,
  :NEW.EMAIL_BODY,
  :NEW.ATTACHMENT_FILENAME,
  'SUCCESS'
  ) ; 
  --dbms_output.put_line('TRIGGERED EMAIL WITH ATTACHMENT SUCESSFULLY DESPATCHED ') ;   
EXCEPTION
WHEN OTHERS THEN
  /*insert into EMAIL_DATA(COMPANYCODE, DIVISIONCODE, DOCUMENT_TYPE, SENDER_EMAIL_ID, SENDER_EMAIL_PWD, RECEIVER_EMAIL_ID, CC_EMAIL_ID, EMAIL_SUBJECT, EMAIL_BODY, ATTACHMENT_FILENAME, ATTACHMENT_BLOB, ATTEMPT_STATUS)
                  VALUES(:NEW.COMPANYCODE, :NEW.DIVISIONCODE, :NEW.DOCUMENT_TYPE, :NEW.SENDER_EMAIL_ID, :NEW.SENDER_EMAIL_PWD, :NEW.RECEIVER_EMAIL_ID, :NEW.CC_EMAIL_ID, :NEW.EMAIL_SUBJECT, :NEW.EMAIL_BODY, :NEW.ATTACHMENT_FILENAME, :NEW.ATTACHMENT_BLOB,'FAILURE');*/
  lv_sqlerrm := sqlerrm ;
  --dbms_output.put_line(lv_sqlerrm);
   insert into EMAIL_HISTORY
  (COMPANYCODE, 
  DIVISIONCODE, 
  DOCUMENT_TYPE, 
  SENDER_EMAIL_ID, 
  SENDER_EMAIL_PWD, 
  RECEIVER_EMAIL_ID, 
  CC_EMAIL_ID, 
  EMAIL_SUBJECT, 
  EMAIL_BODY, 
  ATTACHMENT_FILENAME, 
  STATUS,
  SENTLOG
  )
  values
  (
  :NEW.COMPANYCODE ,
  :NEW.DIVISIONCODE,
  :NEW.DOCUMENT_TYPE ,
  :NEW.SENDER_EMAIL_ID,
  :NEW.SENDER_EMAIL_PWD,
  :NEW.RECEIVER_EMAIL_ID,
  :NEW.CC_EMAIL_ID,
  :NEW.EMAIL_SUBJECT,
  :NEW.EMAIL_BODY,
  :NEW.ATTACHMENT_FILENAME,
  'FAILURE',
  lv_sqlerrm
  ) ;                          
END;
/

