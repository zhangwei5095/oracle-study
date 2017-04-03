netmgr
lsnrctl --help

侦听器的配置信息存入对应的配置文件listener.ora（注：使用Net Manager工具配置侦听器相当于修改该文件），
该文件的默认路径为$ORACLE_HOME/network/admin
设置环境变量TNS_ADMIN可以改变侦听器配置文件的位置（.bash_profile文件中设置）。
1． 启动Net Manager
[oracle@oracle ~]$ netmgr
[oracle@ocp ~]$ cd $ORACLE_HOME/network/admin

[oracle@ocp admin]$ cat listener.ora
# listener.ora Network Configuration File: /u01/app/oracle/product/11.2.0/db_1/network/admin/listener.ora
# Generated by Oracle configuration tools.

LISTENER =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = ocp.example.com)(PORT = 1521))
  )

ADR_BASE_LISTENER = /u01/app/oracle
LISTENER1 =
(DESCRIPTION =
        (ADDRESS = (PROTOCOL = TCP)(HOST = ocp.example.com)(PORT =1522))
)
SID_LIST_LISTENER =
(SID_LIST =
        (SID_DESC =
                (GLOBAL_DBNAME = orcl)
                (ORACLE_HOME = /u01/app/oracle/product/11.2.0/db_1)
                (SID_NAME = orcl)
        )
)

[oracle@ocp admin]$ tnsping orcl    
[oracle@ocp admin]$ lsnrctl start
[oracle@ocp admin]$ lsnrctl status

2．配置客户端网络服务名
网络服务名对应的配置文件名称为tnsnames.ora，
该文件的默认路径为$ORACLE_HOME/network/admin。
通过设置环境变量TNS_ADMIN可以改变该配置文件的位置。

[oracle@ocp admin]$ more tnsnames.ora
# tnsnames.ora Network Configuration File: /u01/app/oracle/product/11.2.0/db_1/network/admin/tnsnames.o
ra
# Generated by Oracle configuration tools.

ORCL =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = ocp.example.com)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = orcl)
    )
  )
  
SQL> alter system set service_names='orcl,prod';

SQL> show parameter service_names;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
service_names                        string      orcl,prod

[oracle@ocp admin]$ sqlplus sys/oracle@orcl as sysdba
[oracle@ocp admin]$ lsnrctl start LISTENER1 
[oracle@ocp admin]$ sqlplus sys/oracle@prod as sysdba
QL> show parameter instance_name

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
instance_name                        string      orcl
SQL> alter system set service_names='orcl';

SQL> show parameter db_name
SQL> show parameter service_names
SQL> alter system set db_domain='example.com' scope=spfile;
SQL> alter system reset service_names scope=spfile sid='*';
SQL> shutdown immediate;
SQL> startup
SQL> show parameter service --//验证service_names 的值为db_name+db_domain

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
service_names                        string      orcl.example.com