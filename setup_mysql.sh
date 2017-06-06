#!/usr/bin/env bash

AUTOLOAD_FILE="/vagrant/mysql.autoload.sql"

MYSQL_ADMIN_USER=root
MYSQL_ADMIN_PASS=rootpwd
MYSQL_ASPACE_USER=as
MYSQL_ASPACE_PASS=as123

# Export MySQL root password before installing to prevent MySQL from prompting for a password during the installation process
# http://stackoverflow.com/questions/18812293/vagrant-ssh-provisioning-mysql-password
echo "mysql-server mysql-server/root_password password ${MYSQL_ADMIN_PASS}" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password ${MYSQL_ADMIN_PASS}" | debconf-set-selections

# Install mysql-server and create the archivesspace database
# http://archivesspace.github.io/archivesspace/user/running-archivesspace-against-mysql/
# https://gist.github.com/rrosiek/8190550
apt-get -y install mysql-server
mysql -u${MYSQL_ADMIN_USER} -p${MYSQL_ADMIN_PASS} -e "create database archivesspace"
mysql -u${MYSQL_ADMIN_USER} -p${MYSQL_ADMIN_PASS} -e "grant all on archivesspace.* to 'as'@'localhost' identified by 'as123'"

# mysql -u${MYSQL_ADMIN_USER} -p${MYSQL_ADMIN_PASS} -e "create database browse_pages"
# mysql -u${MYSQL_ADMIN_USER} -p${MYSQL_ADMIN_PASS} -e "grant all on browse_pages.* to 'as'@'localhost' identified by 'as123'"

mysql -u${MYSQL_ADMIN_USER} -p${MYSQL_ADMIN_PASS} -e "create database aspacedev"
mysql -u${MYSQL_ADMIN_USER} -p${MYSQL_ADMIN_PASS} -e "grant all on aspacedev.* to 'as'@'localhost' identified by 'as123'"

if [[ -r "${AUTOLOAD_FILE}" ]]; then
  echo -n "Autoloading database from file '${AUTOLOAD_FILE}'..."
  mysql -u${MYSQL_ASPACE_USER} -p${MYSQL_ASPACE_PASS} archivesspace < "${AUTOLOAD_FILE}"
  echo "done"
else
  >&2 echo "WARNING: Did not autoload database: autload file '${AUTOLOAD_FILE}' does not exist or is not readable"
fi
