declare
  v_count number;
  v_username varchar2(20) := 'yanni0301';
begin
  select count(*) into v_count from all_users where username=v_username;
  if v_count >0 then
    execute immediate 'drop user '||v_username|| 'cascade';
  end if;
end;
/

create user yanni0301 identified by yanni quota unlimited on users;
grant create session, create table, create procedure, create sequence to yanni0301;


