#!/usr/local/bin/bash

# Two phases execution :
# - first, the container runs with the root user : it creates a
#   devenv_trinitycore user using the user and group id provided by the
#   environment and create a sub-script to execute as 'devenv_trinitycore'
#   instead as 'root'. The sub script creation is necessary because the 'su -c
#   ...' command looks not able to parse arguments of the command it is supposed
#   to execute.
# - second, as the devenv_trinitycore user, execute this very same script and
#   check the environment
if [ $(whoami) != devenv_trinitycore ]; then
  # create a specific user belonging to the docker group, allowing him to use
  # the metabarj0/docker-cli image features
  addgroup -g $DOCKER_GROUP_ID docker
  adduser -H -D -G docker devenv_trinitycore

  # security consideration, remove this environment variable, no longer needed
  unset DOCKER_GROUP_ID

  # operates in the user directory
  cd /home/devenv_trinitycore

  # change ownership of user directories if needed, could be long depending the
  # number of files, this command is only intended to be run once volumes are
  # first mounted because initially, root do the mount
  if [ ! -f .volume.configured  ]; then
    mkdir -p /usr/local/trinitycore

    chown -R devenv_trinitycore:docker \
      /home/devenv_trinitycore \
      /usr/local/trinitycore

    touch .volume.configured
  fi

  # the subscript is only a call to this one but it expand here the value of $@,
  # avoiding to have to supply the 'su -c ...' command with arguments as it does
  # not work as intended
  cat << EOI > unprivileged_devenv_shell_entrypoint.sh
#!/usr/local/bin/bash
cd /usr/local/bin
exec ./devenv_shell_entrypoint.sh "$@"
EOI
  chmod +x unprivileged_devenv_shell_entrypoint.sh
  chown devenv_trinitycore:docker unprivileged_devenv_shell_entrypoint.sh

  # re-launch this script as 'devenv_trinitycore' user
  exec su devenv_trinitycore -c ./unprivileged_devenv_shell_entrypoint.sh
# Here, i am the 'devenv_trinitycore' user
else
  cd

  # no args? assume a login
  if [ -z "$1" ]; then
    set -- bash --login --
  fi

  # remove the unprivileged_devenv_shell_entrypoint.sh script
  rm unprivileged_devenv_shell_entrypoint.sh

  exec $(echo "$@")
fi
