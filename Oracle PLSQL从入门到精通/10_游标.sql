DECLARE
  v_emp scott.emp%ROWTYPE;
  CURSOR v_cur IS
    SELECT * FROM emp;
BEGIN
  OPEN v_cur;
  LOOP
    FETCH v_cur
      INTO v_emp;
    EXIT WHEN v_cur%NOTFOUND;
    dbms_output.put_line('雇员名字为:' || v_emp.ename || ' 雇员职业：' || v_emp.job);
    dbms_output.put_line('目前己提取到的游标的行为' || v_cur%ROWCOUNT);
  END LOOP;
END;

DECLARE
  v_emp scott.emp%ROWTYPE;
  CURSOR v_cur IS
    SELECT * FROM emp;
BEGIN
  OPEN v_cur;
  FETCH v_cur
    INTO v_emp;
  WHILE v_cur%FOUND LOOP
    dbms_output.put_line('雇员名字为:' || v_emp.ename || ' 雇员职业：' || v_emp.job);
    FETCH v_cur
      INTO v_emp;
  END LOOP;
  CLOSE v_cur;
END;

SELECT * FROM scott.emp;
--隐式游标sql%rowcount、sqlerrm、sql%found、sql%notfound
BEGIN
  UPDATE scott.emp e SET e.sal = e.sal * 1.1 WHERE e.empno = 7891;
  dbms_output.put_line(SQL%ROWCOUNT || '行被更新');
  IF SQL%NOTFOUND THEN
    dbms_output.put_line('不能为此行更新数据');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(SQLERRM);
END;
--cur%isopen cur%found cur%notfound
SELECT * FROM emp;
DECLARE
  v_empno NUMBER;
  CURSOR v_cur IS
    SELECT * FROM scott.emp WHERE emp.empno = v_empno;
  CURSOR v_cur1(p_empno IN NUMBER) IS
    SELECT * FROM scott.emp WHERE emp.empno = p_empno;
    v_emp scott.emp%ROWTYPE;
BEGIN
  v_empno := 7693;
  OPEN v_cur;
  IF NOT v_cur%ISOPEN THEN
    DBMS_OUTPUT.PUT_LINE('游标已经被打开');
  END IF;
  IF v_cur%FOUND IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('游标在取用之前%FOUND属性是空的');
  END IF;
  IF NOT v_cur1%ISOPEN THEN
    --如果游标还没有被打开
    OPEN v_cur1(7499); --打开游标
  END IF;
  IF v_cur1%ISOPEN THEN
    DBMS_OUTPUT.PUT_LINE('游标已经被打开');
  END IF;
  LOOP 
    FETCH v_cur1 INTO v_emp;
    EXIT WHEN v_cur1%NOTFOUND;
    --EXIT WHEN NOT emp_cursor%FOUND;
   dbms_output.put_line('雇员名字为:' || v_emp.ename || ' 雇员职业：' || v_emp.job);
    END LOOP;
END;

--定义嵌套表，把游标中的行一次取到嵌套表中，再循环取出
DECLARE
  TYPE v_emp_t IS TABLE OF scott.emp%ROWTYPE;
  v_emp_list v_emp_t;
  CURSOR v_cur IS
    SELECT * FROM emp;
BEGIN
  OPEN v_cur;
  FETCH v_cur BULK COLLECT
    INTO v_emp_list;
  CLOSE v_cur;
  FOR i IN 1 .. v_emp_list.count LOOP
    dbms_output.put_line('雇员名字为:' || v_emp_list(i).ename || ' 雇员职业：' || v_emp_list(i).job);
  END LOOP;
END;
--定义变长数组
DECLARE
  TYPE emp_type IS VARRAY(4) OF scott.emp%ROWTYPE;
  v_emp_list emp_type;
  CURSOR v_cur IS
    SELECT * FROM scott.emp;
  v_count NUMBER := 0;
BEGIN
  OPEN v_cur;
  LOOP
    FETCH v_cur BULK COLLECT
      INTO v_emp_list LIMIT 4;
    EXIT WHEN v_cur%NOTFOUND;
    FOR i IN 1 .. (v_cur%ROWCOUNT - v_count) LOOP
      dbms_output.put_line('雇员名字为:' || v_emp_list(i).ename || ' 雇员职业：' || v_emp_list(i).job);
    END LOOP;
    dbms_output.new_line;
    v_count := v_cur%ROWCOUNT;
  END LOOP;
  CLOSE v_cur;
END;

/*循环的几种方式*/
DECLARE
CURSOR v_cur_dept IS SELECT * FROM scott.dept;
v_dept scott.dept%ROWTYPE;
BEGIN
  OPEN v_cur_dept;
  LOOP 
    FETCH v_cur_dept INTO v_dept;
    EXIT WHEN v_cur_dept%NOTFOUND;
     dbms_output.put_line('部门编号为:' || v_dept.deptno || ' 部门名字：' || v_dept.dname);
    END LOOP;
    CLOSE v_cur_dept;
  END;
  
DECLARE
  CURSOR v_cur_dept IS
    SELECT * FROM scott.dept;
  v_dept scott.dept%ROWTYPE;
BEGIN
  OPEN v_cur_dept;
  FETCH v_cur_dept
    INTO v_dept;
  WHILE v_cur_dept%FOUND LOOP
    dbms_output.put_line('部门编号为:' || v_dept.deptno || ' 部门名字：' ||
                         v_dept.dname);
    FETCH v_cur_dept
      INTO v_dept;
  END LOOP;
  CLOSE v_cur_dept;
END;

DECLARE
  CURSOR v_cur_dept IS
    SELECT * FROM scott.dept;
BEGIN
  FOR v_dept IN v_cur_dept LOOP
    dbms_output.put_line('部门编号为:' || v_dept.deptno || ' 部门名字：' ||
                         v_dept.dname);
  END LOOP;
END;

DECLARE
BEGIN
  FOR v_dept IN (SELECT * FROM scott.dept) LOOP
    dbms_output.put_line('部门编号为:' || v_dept.deptno || ' 部门名字：' ||
                         v_dept.dname);
  END LOOP;
END;

--带参的游标
DECLARE
  CURSOR v_cur(p_empno IN NUMBER) IS
    SELECT * FROM scott.emp WHERE empno = p_empno FOR UPDATE;
BEGIN
  FOR i IN v_cur(7891) LOOP
    UPDATE scott.emp SET sal = sal * 1.1 WHERE CURRENT OF v_cur;
  END LOOP;
END;
/
SELECT * FROM scott.emp WHERE empno =7891;
--select..for update, 可以用 where current of cursor代替当前行
DECLARE
  CURSOR v_cur(p_empno IN NUMBER) IS
    SELECT * FROM scott.emp WHERE empno = p_empno FOR UPDATE;
BEGIN
  FOR i IN v_cur(9003) LOOP
    DELETE FROM scott.emp WHERE CURRENT OF v_cur;
  END LOOP;
END;
/

--引用游标
DECLARE
  TYPE emp_cur_type IS REF CURSOR RETURN scott.emp%ROWTYPE;
  v_emp     scott.emp%ROWTYPE;
  v_emp_cur emp_cur_type;
BEGIN
  OPEN v_emp_cur FOR
    SELECT * FROM scott.emp;
  LOOP
    FETCH v_emp_cur
      INTO v_emp;
    EXIT WHEN v_emp_cur%NOTFOUND;
    dbms_output.put_line('雇员名字为:' || v_emp.ename || ' 雇员职业：' || v_emp.job);
  END LOOP;
  CLOSE v_emp_cur;
  /* 这种方法不行
  OPEN v_emp_cur FOR
    SELECT * FROM scott.emp;
  FOR v_emp IN v_emp_cur LOOP
     dbms_output.put_line('FOR雇员名字为:' || v_emp.ename || ' 雇员职业：' || v_emp.job);
    END LOOP;
  CLOSE v_emp_cur;   
  */
END;

--invalid_cursor游标错误
DECLARE
   TYPE emp_curtype IS REF CURSOR;                       --定义游标类型
   emp_cur emp_curtype;                                  --声明游标类型的变量
   emp_row emp%ROWTYPE;
   dept_row scott.dept%ROWTYPE;
BEGIN   
   FETCH emp_cur INTO emp_row;
   EXCEPTION 
     WHEN invalid_cursor THEN
       dbms_output.put_line('无效游标');
END;
--rowtype_mismatch游标错误
DECLARE
  TYPE emp_curtype IS REF CURSOR; --定义游标类型
  emp_cur  emp_curtype; --声明游标类型的变量
  dept_row scott.dept%ROWTYPE;
BEGIN
  IF NOT emp_cur%ISOPEN THEN
    OPEN emp_cur FOR
      SELECT * FROM scott.emp;
  END IF;
  FETCH emp_cur
    INTO dept_row;
EXCEPTION
  WHEN rowtype_mismatch THEN
    dbms_output.put_line('类型不匹配');
END;

/*
create or replace pagekage pack_name as
       procedure proc_name(args);
end pack_name;

create or replace package body pack_name as
       procedure proc_name(args) is 
       end proc_name;
end pack_name;
*/
--在包中使用引用游标
CREATE OR REPLACE PACKAGE get_emp_data AS
  TYPE emp_cur_type IS REF CURSOR RETURN scott.emp%ROWTYPE;
  PROCEDURE getempbydeptno(emp_cur IN OUT emp_cur_type, p_deptno NUMBER);
END get_emp_data;
/
CREATE OR REPLACE PACKAGE BODY get_emp_data AS
  PROCEDURE getempbydeptno(emp_cur IN OUT emp_cur_type, p_deptno NUMBER) IS
    v_emp scott.emp%ROWTYPE;
  BEGIN
    OPEN emp_cur FOR
      SELECT * FROM scott.emp WHERE deptno = p_deptno;
    LOOP
      FETCH emp_cur
        INTO v_emp;
      EXIT WHEN emp_cur%NOTFOUND;
      dbms_output.put_line('雇员名字为:' || v_emp.ename || ' 雇员职业：' ||
                           v_emp.job);
    END LOOP;
  END;
END get_emp_data;
/

DECLARE
  v_emp get_emp_data.emp_cur_type;
BEGIN
  get_emp_data.getempbydeptno(v_emp, 20);
END;
