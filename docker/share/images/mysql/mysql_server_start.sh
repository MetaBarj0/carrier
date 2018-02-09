#!/bin/sh

# Two phases execution :
# - first, the container runs with the root user : it creates a mysql user using
#   the user and group id provided by the environment and create a sub-script
#   to execute as 'mysql' instead as 'root'. The sub script creation is necessary
#   because the 'su -c ...' command looks not able to parse arguments of the
#   command it is supposed to execute.
# - second, as the mysql user, execute this very same script and configure mysql,
#   create ssh key files and forward the provided command
if [ $(whoami) != mysql ]; then
  addgroup mysql
  adduser -D -G mysql mysql

  cd /usr/local/mysql

  # look for an existing configuration, normally, stored in a persistent volume
  if [ ! -f etc/my.cnf ]; then
    # no conf found, deploying default one
    tar -xf configuration.tar
  fi

  if [ ! -d mysql-files ]; then
    mkdir mysql-files
  fi

  if [ ! -d data ]; then
    mkdir data
  fi

  # existing data, especially system databases?
  if [ ! -d data -o $(ls data | wc -c) -eq 0 ]; then
    # nope! Creating a brand new data load
    tar -xf data.tar.xz
  fi

  # change ownership of some directories
  chown -R root:root etc
  chown -R mysql:mysql data
  chown -R mysql:mysql mysql-files
  chmod 750 mysql-files data

  # the subscript is only a call to this one but it expand here the value of
  # $@, avoiding to have to supply the 'su -c ...' command with arguments as
  # it does not work as intended
  cat << EOI > unprivileged_mysql_server_start.sh
#!/bin/sh
cd /usr/local/mysql
exec ./mysql_server_start.sh "$@"
EOI
  chmod +x unprivileged_mysql_server_start.sh

  # re-launch this script as 'mysql' user
  exec su mysql -c ./unprivileged_mysql_server_start.sh
# Here, i am the 'mysql' user
else
  # starting the beast with provided arguments if any
  exec mysqld_safe "$@"
fi
