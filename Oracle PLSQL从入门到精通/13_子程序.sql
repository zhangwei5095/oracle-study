CREATE OR REPLACE PROCEDURE insertDept(p_deptno IN NUMBER:=55,
                                       p_dname  IN VARCHAR2,
                                       p_loc    IN VARCHAR2) AS
  v_count NUMBER := 0;
BEGIN
  SELECT COUNT(1) INTO v_count FROM scott.dept d WHERE d.deptno = p_deptno;
  IF v_count > 0 THEN
    raise_application_error(-20000, '不能插入相同部门编号的记录');
  END IF;
  INSERT INTO scott.dept VALUES (p_deptno, p_dname, p_loc);
END;
/
SELECT  * FROM scott.dept;

BEGIN
  insertDept(80, '广告部', '纽约');
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(SQLERRM);
END;
--判断存储过程是不是存储
SELECT * FROM user_objects o WHERE o.OBJECT_TYPE='PROCEDURE' AND o.OBJECT_NAME='INSERTDEPT';


CREATE OR REPLACE PROCEDURE insertDept(p_deptno IN NUMBER,
                                       p_dname  IN VARCHAR2,
                                       p_loc    IN VARCHAR2) AS
  v_count NUMBER := 0;
  err_dup_deptno EXCEPTION;
BEGIN
  SELECT COUNT(1) INTO v_count FROM scott.dept d WHERE d.deptno = p_deptno;
  IF v_count > 0 THEN
    RAISE err_dup_deptno;
    
  END IF;
  INSERT INTO scott.dept VALUES (p_deptno, p_dname, p_loc);
  
  EXCEPTION 
    WHEN err_dup_deptno THEN
      raise_application_error(-20000, '不能插入相同部门编号的记录');
END;

SHOW ERRORS;

--获得调薪后的工资
DELETE FROM scott.emp WHERE empno=9006;
SELECT * FROM scott.emp
CREATE OR REPLACE FUNCTION getRaiseSal(p_empno NUMBER) RETURN NUMBER IS
  v_job   scott.emp.job%TYPE;
  v_sal   scott.emp.sal%TYPE;
  v_radio NUMBER(10, 2) := 1;
BEGIN
  SELECT e.job, e.sal
    INTO v_job, v_sal
    FROM scott.emp e
   WHERE e.empno = p_empno;
  CASE v_job
    WHEN 'clerk' THEN
      v_radio := 1.1;
    WHEN 'SALESMAN' THEN
      v_radio := 1.2;
    WHEN 'MANAGER' THEN
      v_radio := 1.5;
    ELSE
      v_radio := 1;
  END CASE;
  IF v_radio <> 1 THEN
    RETURN ROUND(v_sal * v_radio, 2);
  ELSE
    RETURN v_sal;
  END IF;
EXCEPTION
  WHEN no_data_found THEN
    dbms_output.put_line('没有找到员工记录');
    RETURN NULL;
END;
/

SELECT getRaiseSal(10) FROM dual;
SELECT getRaiseSal(7369) FROM dual;

SELECT * FROM scott.emp WHERE sal<3000;
CREATE OR REPLACE PROCEDURE raiseSal(p_empno NUMBER) IS
  v_job scott.emp.job%TYPE;
  v_sal scott.emp.sal%TYPE;
BEGIN
  SELECT e.job, e.sal
    INTO v_job, v_sal
    FROM scott.emp e
   WHERE e.empno = p_empno;
  IF v_job <> 'CLERK' THEN
    dbms_output.put_line(v_job);
    RETURN;
  END IF;
  IF v_sal > 3000 THEN
    dbms_output.put_line(v_sal);
    RETURN;
  END IF;
  UPDATE scott.emp e SET e.sal = e.sal * 1.1 WHERE e.empno = p_empno;
EXCEPTION
  WHEN no_data_found THEN
    dbms_output.put_line('没有找到员工记录');
END;
/

BEGIN
raiseSal(7698);
raiseSal(7876);
END;
/

SELECT object_name, created, last_ddl_time, status
  FROM user_objects
 WHERE object_type IN ('FUNCTION','PROCEDURE') AND object_name='RAISESAL';
 SELECT   line, text
    FROM user_source
   WHERE NAME = 'RAISESAL'
ORDER BY line;
SELECT   line, POSITION, text
    FROM user_errors
   WHERE NAME = 'RAISESAL'
ORDER BY SEQUENCE;

DROP FUNCTION getRaiseSal ;
DROP PROCEDURE RAISESAL;
--in/out参数
CREATE OR REPLACE PROCEDURE raiseSal(p_empno NUMBER,p_sal OUT NUMBER) IS
  v_job scott.emp.job%TYPE;
  v_sal scott.emp.sal%TYPE;
BEGIN
  SELECT e.job, e.sal
    INTO v_job, v_sal
    FROM scott.emp e
   WHERE e.empno = p_empno;
  IF v_job <> 'CLERK' THEN
    dbms_output.put_line(v_job);
    RETURN;
  END IF;
  IF v_sal > 3000 THEN
    dbms_output.put_line(v_sal);
    RETURN;
  END IF;
  p_sal:=v_sal * 1.1;
  UPDATE scott.emp e SET e.sal = p_sal WHERE e.empno = p_empno;
EXCEPTION
  WHEN no_data_found THEN
    dbms_output.put_line('没有找到员工记录');
END;
/

DECLARE
v_sal NUMBER:=0;
BEGIN
raiseSal(7698,v_sal);
 dbms_output.put_line(v_sal);
raiseSal(7876,v_sal);
 dbms_output.put_line(v_sal);
END;
/


CREATE OR REPLACE PROCEDURE calcRaisedSalary(
         p_job IN VARCHAR2,
         p_salary IN OUT NUMBER                         --定义输入输出参数
)
AS
  v_sal NUMBER(10,2);                               --保存调整后的薪资值
BEGIN
  if p_job='职员' THEN                              --根据不同的job进行薪资的调整
     v_sal:=p_salary*1.12;
  ELSIF p_job='销售人员' THEN
     v_sal:=p_salary*1.18;
  ELSIF p_job='经理' THEN
     v_sal:=p_salary*1.19;
  ELSE
     v_sal:=p_salary;
  END IF;
  p_salary:=v_sal;                                   --将调整后的结果赋给输入输出参数
END calcRaisedSalary;



DECLARE
   v_sal NUMBER(10,2);                 --薪资变量
   v_job VARCHAR2(10);                 --职位变量
BEGIN
   SELECT sal,job INTO v_sal,v_job FROM emp WHERE empno=7369; --获取薪资和职位信息
   calcRaisedSalary(v_job,v_sal);                             --计算调薪
   DBMS_OUTPUT.put_line('计算后的调整薪水为：'||v_sal);    --获取调薪后的结果
END;   

CREATE OR REPLACE PROCEDURE calcRaisedSalaryWithTYPE(
         p_job IN emp.job%TYPE,
         p_salary IN OUT emp.sal%TYPE               --定义输入输出参数
)
AS
  v_sal NUMBER(10,2);                               --保存调整后的薪资值
BEGIN
  if p_job='职员' THEN                              --根据不同的job进行薪资的调整
     v_sal:=p_salary*1.12;
  ELSIF p_job='销售人员' THEN
     v_sal:=p_salary*1.18;
  ELSIF p_job='经理' THEN
     v_sal:=p_salary*1.19;
  ELSE
     v_sal:=p_salary;
  END IF;
  p_salary:=v_sal;                                   --将调整后的结果赋给输入输出参数
END calcRaisedSalaryWithTYPE;

--下面第一种和第三都不能用，因为要和emp.sal%TYPE精度一样，而且值也不能超过它的精度
DECLARE
   v_sal NUMBER(7,2);                 --薪资变量
   v_job VARCHAR2(10);                 --职位变量
BEGIN
   v_sal:=123294.45;
   v_job:='职员';
   calcRaisedSalaryWithTYPE(v_job,v_sal);                             --计算调薪
   DBMS_OUTPUT.put_line('计算后的调整薪水为：'||v_sal);    --获取调薪后的结果
EXCEPTION 
   WHEN OTHERS THEN
      DBMS_OUTPUT.put_line(SQLCODE||' '||SQLERRM);   
END; 

DECLARE
   v_sal NUMBER(8,2);                 --薪资变量
   v_job VARCHAR2(10);                 --职位变量
BEGIN
   v_sal:=123294.45;
   v_job:='职员';
   calcRaisedSalaryWithTYPE(p_job=>v_job,p_salary=>v_sal);                             --计算调薪
   DBMS_OUTPUT.put_line('计算后的调整薪水为：'||v_sal);    --获取调薪后的结果
EXCEPTION 
   WHEN OTHERS THEN
      DBMS_OUTPUT.put_line(SQLCODE||' '||SQLERRM);   
END;   


DECLARE
   v_sal NUMBER(7,2);                 --薪资变量
   v_job VARCHAR2(10);                 --职位变量
BEGIN
   v_sal:=1224.45;
   v_job:='职员';
   calcRaisedSalaryWithTYPE(p_salary=>v_sal,p_job=>v_job);                             --计算调薪
   DBMS_OUTPUT.put_line('计算后的调整薪水为：'||v_sal);    --获取调薪后的结果
EXCEPTION 
   WHEN OTHERS THEN
      DBMS_OUTPUT.put_line(SQLCODE||' '||SQLERRM);   
END;  


CREATE OR REPLACE PROCEDURE newdeptwithdefault (
   p_deptno   dept.deptno%TYPE DEFAULT 57,    --部门编号
   p_dname    dept.dname%TYPE:='管理部',     --部门名称
   p_loc      dept.loc%TYPE DEFAULT '江苏'        --位置
)
AS
   v_deptcount   NUMBER;           --保存是否存在员工编号
BEGIN
   SELECT COUNT (*) INTO v_deptcount FROM dept
    WHERE deptno = p_deptno;       --查询在dept表中是否存在部门编号
   IF v_deptcount > 0              --如果存在相同的员工记录
   THEN                            --抛出异常
      raise_application_error (-20002, '出现了相同的员工记录');
   END IF;
   INSERT INTO dept(deptno, dname, loc)  
        VALUES (p_deptno, p_dname, p_loc);--插入记录
END;

BEGIN
   newdeptwithdefault;       --不指定任何参数，将使用形参默认值
END;

BEGIN
   newdeptwithdefault(58,'事务组');       --不指定任何参数，将使用形参默认值
END;


BEGIN
   newdeptwithdefault(58,'事务组');       
END;

BEGIN
   newdeptwithdefault(p_deptno=>58,p_loc=>'南海');       --让dname使用默认值
END;

SELECT * FROM dept;

DECLARE
   TYPE emptabtyp IS TABLE OF emp%ROWTYPE;               --定义嵌套表类型
   emp_tab   emptabtyp  := emptabtyp (NULL);             --定义一个空白的嵌套表变量
   t1        NUMBER (5);                                 --定义保存时间的临时变量
   t2        NUMBER (5);
   t3        NUMBER (5);

   PROCEDURE get_time (t OUT NUMBER)                     --获取当前时间
   IS
   BEGIN
      SELECT TO_CHAR (SYSDATE, 'SSSSS')                  --获取从午夜到当前的秒数
        INTO t
        FROM DUAL;
      DBMS_OUTPUT.PUT_LINE(t);        
   END;
   PROCEDURE do_nothing1 (tab IN OUT emptabtyp)          --定义一个空白的过程，具有IN OUT参数
   IS
   BEGIN
      NULL;
   END;

   PROCEDURE do_nothing2 (tab IN OUT NOCOPY emptabtyp)   --在参数中使用NOCOPY编译提示
   IS
   BEGIN
      NULL;
   END;
BEGIN
   SELECT *
     INTO emp_tab (1)
     FROM emp
    WHERE empno = 7788;                                  --查询emp表中的员工，插入到emp_tab第1个记录
   emp_tab.EXTEND (900000, 1);                            --拷贝第1个元素N次
   get_time (t1);                                        --获取当前时间
   do_nothing1 (emp_tab);                                --执行不带NOCOPY的过程
   get_time (t2);                                        --获取当前时间
   do_nothing2 (emp_tab);                                --执行带NOCOPY的过程
   get_time (t3);                                        --获取当前时间
   DBMS_OUTPUT.put_line ('调用所花费的时间(秒)');
   DBMS_OUTPUT.put_line ('--------------------');
   DBMS_OUTPUT.put_line ('不带NOCOPY的调用:' || TO_CHAR (t2 - t1));
   DBMS_OUTPUT.put_line ('带NOCOPY的调用:' || TO_CHAR (t3 - t2));
END;
/

CREATE OR REPLACE FUNCTION getempdept(
        p_empno emp.empno%TYPE
) RETURN VARCHAR2                                 --参数必须是Oracle数据库类型
AS
  v_dname dept.dname%TYPE;               
BEGIN
   SELECT b.dname INTO v_dname FROM emp a,dept b 
   WHERE a.deptno=b.deptno
   AND a.empno=p_empno AND ROWNUM=1;
   RETURN v_dname;                                --查询数据表，获取部门名称
EXCEPTION 
   WHEN NO_DATA_FOUND THEN
      RETURN NULL;                                --如果出现查询不到数据，返回NULL
END;        


SELECT empno 员工编号,getempdept(empno) 员工名称 from emp;

--函数的嵌套调用
CREATE OR REPLACE FUNCTION getraisedsalary_subprogram (p_empno emp.empno%TYPE)
   RETURN NUMBER
IS
   v_salaryratio   NUMBER (10, 2);             --调薪比率  
   v_sal           emp.sal%TYPE;            --薪资变量     
   --定义内嵌子函数，返回薪资和调薪比率  
   FUNCTION getratio(p_sal OUT NUMBER) RETURN NUMBER IS
      n_job           emp.job%TYPE;            --职位变量
      n_salaryratio   NUMBER (10, 2);          --调薪比率       
   BEGIN
       --获取员工表中的薪资信息
       SELECT job, sal INTO n_job, p_sal FROM emp WHERE empno = p_empno;
       CASE n_job                               --根据不同的职位获取调薪比率
          WHEN '职员' THEN
             n_salaryratio := 1.09;
          WHEN '销售人员' THEN
             n_salaryratio := 1.11;
          WHEN '经理' THEN
             n_salaryratio := 1.18;
          ELSE
             n_salaryratio := 1;
       END CASE; 
       RETURN n_salaryratio;    
   END;        
BEGIN
   v_salaryratio:=getratio(v_sal);          --调用嵌套函数，获取调薪比率和员工薪资
   IF v_salaryratio <> 1                    --如果有调薪的可能
   THEN
      RETURN ROUND(v_sal * v_salaryratio,2);         --返回调薪后的薪资
   ELSE
      RETURN v_sal;                         --否则不返回薪资
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 0;                             --如果没找到原工记录，返回0
END;


--存储过程的互调
BEGIN
   --调用函数获取调薪后的记录
   DBMS_OUTPUT.PUT_LINE('7369员工调薪记录：'||getraisedsalary_subprogram(7369));
   DBMS_OUTPUT.PUT_LINE('7521员工调薪记录：'||getraisedsalary_subprogram(7521));   
END;

DECLARE
   v_val BINARY_INTEGER:=5;
   PROCEDURE B(p_counter IN OUT BINARY_INTEGER);            --前向声明嵌套子程序B
   PROCEDURE A(p_counter IN OUT BINARY_INTEGER) IS          --声明嵌套子程序A
   BEGIN
      DBMS_OUTPUT.PUT_LINE('A('||p_counter||')');
      IF p_counter>0 THEN
         B(p_counter);                                      --在嵌套子程序中调用B
         p_counter:=p_counter-1;
      END IF;
   END A;
   PROCEDURE B(p_counter IN OUT BINARY_INTEGER) IS          --声明嵌套子程序B
   BEGIN
      DBMS_OUTPUT.PUT_LINE('B('||p_counter||')');
      p_counter:=p_counter-1;
      A(p_counter);                                          --在嵌套子程序中调用A
   END B;
BEGIN
   B(v_val);                                                 --调用嵌套子程序B
END;

--存储过程的重载
DECLARE
    PROCEDURE GetSalary(p_empno IN NUMBER) IS                       --带一个参数的过程
    BEGIN
      DBMS_OUTPUT.put_line('员工编号为：'||p_empno);      
    END;
    PROCEDURE GetSalary(p_empname IN VARCHAR2) IS                    --重载的过程
    BEGIN
      DBMS_OUTPUT.put_line('员工名称为：'||p_empname);
    END;
    PROCEDURE GETSalary(p_empno IN NUMBER,p_empname IN VARCHAR) IS   --生的过程
    BEGIN
      DBMS_OUTPUT.put_line('员工编号为：'||p_empno||' 员工名称为：'||p_empname);
    END;       
BEGIN 
    GetSalary(7369);                                                 --调用重载方未予
    GetSalary('史密斯');
    GetSalary(7369,'史密斯');        
END; 

SELECT * FROM emp;

CREATE TABLE emp_history AS SELECT * FROM emp WHERE 1=2;

SELECT * FROM emp_history;
--pragma autonomous_transaction自治事务，提交后不影响主事务
DECLARE
   PROCEDURE TestAutonomous(p_empno NUMBER) AS
     PRAGMA AUTONOMOUS_TRANSACTION;         --标记为自治事务
   BEGIN
     --现在过程中是自治的事务，主事务被挂起
     INSERT INTO emp_history SELECT * FROM emp WHERE empno=p_empno;
     COMMIT;                                --提交自治事务，不影响主事务
   END TestAutonomous;
BEGIN
   --主事务开始执行
   INSERT INTO emp_history(empno,ename,sal) VALUES(1011,'测试',1000);
   TestAutonomous(7369);                    --主事务挂起，开始自治事务
   ROLLBACK;                                --回滚主事务
END;
--函数的递归调用
DECLARE
  v_ret NUMBER;
  FUNCTION fac(n NUMBER) RETURN NUMBER IS
  BEGIN
    IF n = 1 THEN
      dbms_output.put_line('1!=1*0!');
      RETURN 1;
    ELSE
      dbms_output.put_line(n || '!=' || n || '*');
      RETURN fac(n - 1) * n;
    END IF;
  END;
BEGIN
  v_ret := fac(10);
  dbms_output.put_line('10的阶乖：' || v_ret);
END;
--存储过程的递归调用
DECLARE
  PROCEDURE find_staff(mgr_no NUMBER, tier NUMBER := 1) IS
    boss_name VARCHAR2(10); --定义老板的名称
    CURSOR c1(boss_no NUMBER) --定义游标来查询emp表中当前编号下的员工列表
    IS
      SELECT empno, ename FROM emp WHERE mgr = boss_no;
  BEGIN
    SELECT ename INTO boss_name FROM emp WHERE empno = mgr_no; --获取管理者名称
    IF tier = 1 --如果tier指定1,表示从最顶层开始查询
     THEN
      INSERT INTO staff VALUES (boss_name || ' 是老板 '); --因为第1层是老板，下面的才是经理
    END IF;
    FOR ee IN c1(mgr_no) --通过游标FOR循环向staff表插入员工信息
     LOOP
      INSERT INTO staff
      VALUES
        (boss_name || ' 管理 ' || ee.ename || ' 在层次 ' || TO_CHAR(tier));
      find_staff(ee.empno, tier + 1); --在游标中，递归调用下层的员工列表
    END LOOP;
    COMMIT;
  END find_staff;
BEGIN
  find_staff(7839); --查询7839的管理下的员工的列表和层次结构
END;
SELECT * FROM scott.emp;
--在声明中的过程名不要加create or replace否则会出错
DECLARE
  PROCEDURE find_staff(manager_id NUMBER, trier NUMBER := 1) AS
    v_name scott.emp.ename%TYPE;
    CURSOR v_cur(p_mgr scott.emp.mgr%TYPE) IS
      SELECT empno,ename FROM scott.emp WHERE mgr = p_mgr;
  BEGIN
    SELECT ename INTO v_name FROM scott.emp WHERE empno = manager_id;
    IF trier = 1 THEN
      INSERT INTO staff VALUES (v_name || ' 是老板');
    END IF;
    FOR ee IN v_cur(manager_id) LOOP
      INSERT INTO staff
      VALUES
        (v_name || '管理' || ee.ename || '在层次' || to_char(trier));
      find_staff(ee.empno, trier + 1);
    END LOOP;
    COMMIT;
  END find_staff;
BEGIN
  find_staff(7839); --查询7839的管理下的员工的列表和层次结构
END;


CREATE TABLE staff(line VARCHAR2(100));
SELECT * FROM staff ORDER BY line;


CREATE OR REPLACE PROCEDURE TestDependence AS
BEGIN
   --向emp表插入测试数据
   INSERT INTO emp(empno,ename,sal) VALUES(1011,'测试',1000);
   TestSubProg(7369);                   
   ROLLBACK;                               
END;
--被另一个过程调用，用来向emp_history表插入数据
CREATE OR REPLACE PROCEDURE TestSubProg(p_empno NUMBER) AS
 BEGIN
     INSERT INTO emp_history SELECT * FROM emp WHERE empno=p_empno;
 END TestSubProg;
SELECT name,type FROM user_dependencies WHERE referenced_name='EMP';
--alter compile 当相关的表发生变化时
SELECT * FROM emp_history;
ALTER TABLE emp_history DROP COLUMN emp_desc;
ALTER TABLE emp_history ADD emp_desc VARCHAR2(200) NULL;
SELECT object_name, object_type, status
  FROM user_objects
 WHERE object_name IN ('TESTDEPENDENCE', 'TESTSUBPROG');
ALTER TABLE emp_history DROP COLUMN emp_desc;
ALTER PROCEDURE testdependence COMPILE;
ALTER PROCEDURE testsubprog COMPILE;

--authid current_user
CREATE OR REPLACE PROCEDURE find_staff(mgr_no NUMBER, tier NUMBER := 1)
AUTHID CURRENT_USER --Authid Current_User时存储过程可以使用role权限
 IS
  boss_name VARCHAR2(10); --定义老板的名称
  CURSOR c1(boss_no NUMBER) --定义游标来查询emp表中当前编号下的员工列表
  IS
    SELECT empno, ename FROM emp WHERE mgr = boss_no;
BEGIN
  SELECT ename INTO boss_name FROM emp WHERE empno = mgr_no; --获取管理者名称
  IF tier = 1 --如果tier指定1,表示从最顶层开始查询
   THEN
    INSERT INTO staff VALUES (boss_name || ' 是老板 '); --因为第1层是老板，下面的才是经理
  END IF;
  FOR ee IN c1(mgr_no) --通过游标FOR循环向staff表插入员工信息
   LOOP
    INSERT INTO staff
    VALUES
      (boss_name || ' 管理 ' || ee.ename || ' 在层次 ' || TO_CHAR(tier));
    find_staff(ee.empno, tier + 1); --在游标中，递归调用下层的员工列表
  END LOOP;
  COMMIT;
END find_staff;

select * from v$version;
CREATE OR REPLACE PROCEDURE p_test IS
BEGIN
  EXECUTE IMMEDIATE 'create table creat_table(id number)';
END;
/

--exec p_test;
select * from dba_role_privs where grantee='scott';
select * from dba_role_privs where grantee='SFX';
CREATE OR REPLACE PROCEDURE p_test AUTHID CURRENT_USER IS
BEGIN
  EXECUTE IMMEDIATE 'create table creat_table(id number)';
END;
/

CREATE USER usera IDENTIFIED BY usera;
GRANT RESOURCE,CONNECT TO usera;
GRANT EXECUTE ON find_staff TO usera;


