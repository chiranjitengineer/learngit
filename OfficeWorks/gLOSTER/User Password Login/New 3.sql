SELECT DISTINCT USERNAME FROM LOGIN

SELECT * FROM LOGIN


SELECT USERNAME,ISADMINISTRATOR, ACTIVE 
FROM LOGIN
ORDER BY USERNAME


SELECT * FROM SYS_HELP_QRY


SELECT QUALITYTYPECODE,QUALITYTYPEDESC
FROM PRODQUALITYTYPEMAST
  WHERE COMPANYCODE = <<COMPANYCODE>> 
   AND DIVISIONCODE = <<DIVISIONCODE>>
ORDER BY 1
   

SELECT ISADMINISTRATOR FROM LOGIN WHERE USERNAME = 'SWT' AND COMPANYCODE='0001'