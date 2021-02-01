--(?=(.*[0-9]))(?=.*[\!@#$%^&*()\\[\]{}\-_+=~`|:;'"'<>,./?])(?=.*[a-z])(?=(.*[A-Z]))(?=(.*)).{8,}
 

select regexp('112') from dual 



SELECT 'aeiou' last_name
FROM dual
WHERE REGEXP_LIKE (last_name, '([aeiou])\1', 'i');

select last_name from
(
    SELECT 'Greenberg' last_name FROM dual
)
WHERE REGEXP_LIKE (last_name, '([aeiou])\1', 'i');



select last_name from
(
    SELECT 'helloWorld555@!' last_name FROM dual
)
WHERE REGEXP_LIKE (last_name, '(?=(.*[0-9]))(?=.*[\!@#$%^&*()\\[\]{}\-_+=~`|:;''"''<>,./?])(?=.*[a-z])(?=(.*[A-Z]))(?=(.*)).{8,}');



SELECT 
CASE 
    WHEN NOT REGEXP_LIKE(VNEWPWD,'^.*[A-Z].*$') THEN 'ATLEAST 1 CAPITAL LETTER [A-Z] REQUIRED.'
    WHEN NOT REGEXP_LIKE(VNEWPWD,'^.*[0-9].*$') THEN 'ATLEAST 1 DIGIT [0-9] REQUIRED'
    WHEN NOT REGEXP_LIKE(VNEWPWD,'^.*[\!@#$%].*$') THEN 'ATLEAST 1 SPECIAL CHARACTER  LETTER [\!@#$%] REQUIRED '
    WHEN NOT REGEXP_LIKE(VNEWPWD,'.{7,}') THEN 'ATLEAST 7 CHARACTERS REQUIRED'
ELSE VNEWPWD 
END PASSCODE FROM (
SELECT VNEWPWD FROM
(
    SELECT 'aa@15656' VNEWPWD FROM DUAL
)
)
WHERE 1=1


and regexp_like(vNewPwd,'^.*[A-Z].*$')
and regexp_like(vNewPwd,'.*[0-9].*$')
--and regexp_like(vNewPwd,'.*[^A-Z,0-9].*$')
--and regexp_like(vNewPwd,'.*[a-z]')
and regexp_like(vNewPwd,'.*[\!@#$%]')
and regexp_like(vNewPwd,'.{7,}')



