CREATE OR REPLACE PROCEDURE GLOSTER_WEB."CUSTOM_SEND_MAIL" (
  p_to          IN VARCHAR2 DEFAULT NULL,
  p_cc          IN VARCHAR2 DEFAULT NULL,
  p_bcc         IN VARCHAR2 DEFAULT NULL,
  p_from        IN VARCHAR2 , --:= '<softweb.techteam@gmail.com>',
  p_subject     IN VARCHAR2 DEFAULT NULL,
  p_text_msg    IN VARCHAR2 DEFAULT NULL,
  p_html_msg   IN CLOB DEFAULT NULL,
  p_attachments IN table_attachments DEFAULT NULL,
  p_smtp_host   IN VARCHAR2 , -- := '80.0.1.5',
  p_smtp_domain IN VARCHAR2 ,  --:= 'gmail.com' , -- senders domain like -> gmail.com , rediffmail.com etc
  p_smtp_port   IN NUMBER DEFAULT 25,
  p_username    IN VARCHAR2 DEFAULT NULL,
  p_password    IN VARCHAR2 DEFAULT NULL)
AS
  l_mail_conn   UTL_SMTP.connection;
  l_boundary    VARCHAR2(50) := '----=*#abc1234321cba#*=';
  l_step        PLS_INTEGER  := 24573;
  l_length PLS_INTEGER;
  l_begin PLS_INTEGER := 1;
  l_buffer_size INTEGER := 75;
  l_raw RAW(32767);
  lv_call varchar2(1) ;
BEGIN  
 -- l_mail_conn := UTL_SMTP.open_connection(p_smtp_host, p_smtp_port);
  l_mail_conn := UTL_SMTP.open_connection(p_smtp_host);
  UTL_SMTP.HELO(l_mail_conn, p_smtp_domain);
  UTL_SMTP.command( l_mail_conn, 'AUTH LOGIN'); 
 
  --Establish SMTP connection
 IF (p_username IS NOT NULL) THEN
    UTL_SMTP.command( l_mail_conn, UTL_RAW.cast_to_varchar2( UTL_ENCODE.base64_encode( UTL_RAW.cast_to_raw( p_username ))) );
    UTL_SMTP.command( l_mail_conn, UTL_RAW.cast_to_varchar2( UTL_ENCODE.base64_encode( UTL_RAW.cast_to_raw( p_password ))) );  
 END IF;
 
 -- UTL_SMTP.helo(l_mail_conn, p_smtp_host);
 -- UTL_SMTP.HELO(l_mail_conn, 'gmail.com'); 
  
  UTL_SMTP.mail(l_mail_conn, p_from);
  UTL_SMTP.rcpt(l_mail_conn, p_to);
 -- UTL_SMTP.rcpt(l_mail_conn, p_cc);
  lv_call := fn_smtp_cc(l_mail_conn,p_cc) ;
 
  UTL_SMTP.open_data(l_mail_conn);
 
  UTL_SMTP.write_data(l_mail_conn, 'Date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, 'To: ' || p_to || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, 'From: ' || p_from || UTL_TCP.crlf);
  IF (p_cc IS NOT NULL) THEN
    UTL_SMTP.write_data(l_mail_conn, 'CC: ' || p_cc || UTL_TCP.crlf);     
  END IF;
  IF (p_bcc IS NOT NULL) THEN
    UTL_SMTP.write_data(l_mail_conn, 'BCC: ' || p_bcc || UTL_TCP.crlf);
  END IF;
  UTL_SMTP.write_data(l_mail_conn, 'Subject: ' || p_subject || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, 'Reply-To: ' || p_from || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, 'MIME-Version: 1.0' || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, 'Content-Type: multipart/mixed; boundary="' || l_boundary || '"' || UTL_TCP.crlf || UTL_TCP.crlf);
  --Plain Text Body
  IF p_text_msg IS NOT NULL THEN
    UTL_SMTP.write_data(l_mail_conn, '--' || l_boundary || UTL_TCP.crlf);
    UTL_SMTP.write_data(l_mail_conn, 'Content-Type: text/plain; charset="iso-8859-1"' || UTL_TCP.crlf || UTL_TCP.crlf);
 
    UTL_SMTP.write_data(l_mail_conn, p_text_msg);
    UTL_SMTP.write_data(l_mail_conn, UTL_TCP.crlf || UTL_TCP.crlf);
 
  ELSIF p_html_msg IS NOT NULL THEN
    -- HTML Body
    UTL_SMTP.write_data(l_mail_conn, '--' || l_boundary || UTL_TCP.crlf);
    UTL_SMTP.write_data(l_mail_conn, 'Content-Type: text/html; charset="iso-8859-1"' || UTL_TCP.crlf || UTL_TCP.crlf);
    FOR i IN 0 .. TRUNC((DBMS_LOB.getlength(p_html_msg) - 1 )/l_step) LOOP
      UTL_SMTP.write_data(l_mail_conn,  DBMS_LOB.SUBSTR(p_html_msg, l_step, i * l_step + 1));
    END LOOP;
 
    UTL_SMTP.write_data(l_mail_conn, UTL_TCP.crlf || UTL_TCP.crlf);
  END IF;
 
  IF p_attachments IS NOT NULL THEN
 
   FOR i IN 1..p_attachments.COUNT
   LOOP
 
     UTL_SMTP.write_data(l_mail_conn, '--' || l_boundary || UTL_TCP.crlf);
     UTL_SMTP.write_data(l_mail_conn, 'Content-Type: ' ||p_attachments(i).attachment_mime || UTL_TCP.crlf);
     UTL_SMTP.write_data(l_mail_conn, 'Content-Transfer-Encoding: base64' || UTL_TCP.crlf);
     UTL_SMTP.write_data(l_mail_conn, 'Content-Disposition: attachment; filename="' || p_attachments(i).attachment_name || '"' || UTL_TCP.crlf || UTL_TCP.crlf);
 
     l_length := DBMS_LOB.getlength(p_attachments(i).attachment_blob);
     l_begin := 1;
     l_raw := NULL;
     l_buffer_size := 75;
     WHILE l_begin < l_length LOOP
        DBMS_LOB.read( p_attachments(i).attachment_blob, l_buffer_size, l_begin, l_raw );
        UTL_SMTP.write_raw_data( l_mail_conn, UTL_ENCODE.base64_encode(l_raw) );
        UTL_SMTP.write_data( l_mail_conn, UTL_TCP.crlf );
        l_begin := l_begin + l_buffer_size;
     END LOOP ;
 
    UTL_SMTP.write_data(l_mail_conn, UTL_TCP.crlf || UTL_TCP.crlf);
 
   END LOOP;
 
  END IF;
 
  UTL_SMTP.write_data(l_mail_conn, '--' || l_boundary || '--' || UTL_TCP.crlf);
  UTL_SMTP.close_data(l_mail_conn);
 
  UTL_SMTP.quit(l_mail_conn);
 
END;
/
