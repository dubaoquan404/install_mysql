# install_mysql_el7

普通用户安装mysql for el7

## 所需介质

```
rpm2cpio mysql-community-common-5.7.27-1.el7.x86_64.rpm  | cpio -idvm
rpm2cpio mysql-community-libs-5.7.27-1.el7.x86_64.rpm  | cpio -idvm
rpm2cpio mysql-community-client-5.7.27-1.el7.x86_64.rpm  | cpio -idvm
rpm2cpio mysql-community-server-5.7.27-1.el7.x86_64.rpm  | cpio -idvm
```
