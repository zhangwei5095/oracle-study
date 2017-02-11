/*
影响性能常见原因
1. 尽量使用存储过程，避免使用pl/sql匿名块
2.　编写共享sql语句
3.　使用binary_integer/pls_integer声明整形
4.　在过程中传递大数据参数时使用nocopy编译提示
5.　使用returning获取返回值
6.　避免使用动态sql
7. 尽量使用bulk批处理

使用系统包监测和跟踪性能
1. 使用dbms_profiler包
2. 使用dbms_trace包

pl/sql性能优化技巧
1.　理解查询执行计划
2.　联接查询的表顺序
3.　指定where条件顺序
4、避免使用*符号
5.　使用decode函数
6.　使用where而非having
7. 使用union而非or 
8. 使用exists而非in
9. 避免低效的pl/sql流程控制语句
10. 避免隐式类型的转换

理解查询执行计划
1.　解析sql语句：主要进行在共享池中查询相同的sql语句，检查安全性和sql语句与语义
2.　创建计划与执行：包括创建sql的执行计划以及对表数据的实际获取
3.　显示结果集: 对字段数据执行所有必要的排序、转换和重新格式化
4.　转换字段数据: 对己通过内置函数进行转换的字段进行重新格式化处理和转换

*/
