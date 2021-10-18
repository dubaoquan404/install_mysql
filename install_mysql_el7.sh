#!/bin/bash

port=$1

if [ -z "$port" ]; then
  port=3306
fi

exist_port=`netstat -nl | grep $port`

if [ ! -z "$exist_port" ]; then
        echo "error: Default port $port is exist ,please alter mysql server port "
        exit 1
fi

echo "install mysql server port $port ..."

export mysql_dir=$(cd `dirname $0`;pwd)
export my_cnf=$mysql_dir/etc/my.cnf
#check sys_version
# sys_version=`cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/'`
# [[ "$sys_version" != "7" ]] && echo "Version mismatch !" && exit
# [[ `id -u` -ne 0 ]] && echo "User mismatch ! Switch root to execute." && exit
install_rpm()
{
     echo "start install mysql rpm packages ..."
    cd ${mysql_dir} 
    rpm2cpio mysql-community-common-5.7.27-1.el7.x86_64.rpm  | cpio -idvm
    rpm2cpio mysql-community-libs-5.7.27-1.el7.x86_64.rpm  | cpio -idvm
    rpm2cpio mysql-community-client-5.7.27-1.el7.x86_64.rpm  | cpio -idvm
    rpm2cpio mysql-community-server-5.7.27-1.el7.x86_64.rpm  | cpio -idvm


    mkdir $mysql_dir/var/log
}


init_conf()
{

    echo "start init mysql my.cnf file ..."
cat > $my_cnf  << EOF

[client]
port=$port
socket=$mysql_dir/var/lib/mysql/mysql.sock

[mysqld]
port=$port
basedir=$mysql_dir/usr
datadir=$mysql_dir/var/lib/mysql
socket=$mysql_dir/var/lib/mysql/mysql.sock
secure-file-priv=$mysql_dir/var/lib/mysql-files
symbolic-links=0
lower_case_table_names=1
log-error=$mysql_dir/var/log/mysqld.log
pid-file=$mysql_dir/var/run/mysqld/mysqld.pid

default-storage-engine=INNODB
character-set-server=utf8
collation-server=utf8_general_ci


EOF

}


init_mysql()
{
    #init data
    echo "start init mysql data ..."
    $mysql_dir/usr/sbin/mysqld --defaults-file=$mysql_dir/etc/my.cnf --initialize --user=root

    #start 
    echo "start mysql server ..."
    # ./usr/bin/mysqld_safe --defaults-file=/home/deploy/app/mysql/etc/my.cnf --user=root >start.log  2>&1 &
    $mysql_dir/usr/sbin/mysqld --defaults-file=$mysql_dir/etc/my.cnf --user=root >/dev/null  2>&1 &
    # output=`$mysql_dir/usr/bin/mysqld_safe --defaults-file=$mysql_dir/etc/my.cnf --user=root >/dev/null  2>&1 &`
    pwd=`grep 'temporary password' $mysql_dir/var/log/mysqld.log|awk '{print $NF}'|awk 'END {print}'`

    #login
    echo "start login mysql by root ...."
    sleep 10s
    # ./usr/bin/mysql -uroot  -p',d,7tpn*g;mF' -S /home/deploy/app/mysql/var/lib/mysql/mysql.sock
    # echo "$mysql_dir/usr/bin/mysql -uroot  -p'$pwd' -S $mysql_dir/var/lib/mysql/mysql.sock "
    $mysql_dir/usr/bin/mysql -uroot  -p$pwd --connect-expired-password -S $mysql_dir/var/lib/mysql/mysql.sock << EOF
alter user 'root'@'localhost' identified by 'root';
grant all privileges on *.* to 'root'@'%' identified by 'root' with grant option; 
quit
EOF


}

install()
{
    install_rpm
    init_conf
    init_mysql
}

install
netstat -nl | grep $port
