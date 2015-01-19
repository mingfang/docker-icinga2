chown -R mysql:mysql /var/lib/mysql
mysql_install_db
mysqld_safe & mysqladmin --wait=5 ping
mysql -v < /mysql.ddl
mysql -v icinga < /usr/share/icinga2-ido-mysql/schema/mysql.sql
mysql -v icingaweb < /usr/share/icingaweb2/etc/schema/mysql.schema.sql

#default admin
password=$(openssl passwd -1 "admin")
echo  "INSERT INTO icingaweb_user (name, active, password_hash) VALUES ('admin', 1, '$password');" | mysql -v icingaweb

mysqladmin shutdown
