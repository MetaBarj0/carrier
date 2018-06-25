#!/bin/sh

# check arguments that are the command we want the container runs. if not set,
# assumes that the user want a shell
if [ -z "$1" ]; then
  set -- sh -l --;
fi

# Two phases execution :
# - first, the container runs with the root user : it creates a vim user using
#   the user and group id provided by the environment and create a sub-script
#   to execute as 'vim' instead as 'root'. The sub script creation is necessary
#   because the 'su -c ...' command looks not able to parse arguments of the
#   command it is supposed to execute.
# - second, as the vim user, execute this very same script and forward the
#   provided command if any, otherwise, starts sh
if [ $(whoami) != vim ]; then
  if [ -z "$VIM_LINUX_USER" ]; then
    echo 'Hi there! I need a linux user id to execute my commands.'
    echo 'Preferably, you should give me your current user id. Therefore, I can'
    echo 'modify your files with the correct user, saving you a'
    echo 'lot of pain in the a**.'
    echo 'The next time you will run this container, please, provide a valid'
    echo 'user id using the -e switch like :'
    echo 'docker run --rm -it -e VIM_LINUX_USER=$(id -u) metabarj0/vim'
    echo 'Bye!'
    exit 1
  fi

  if [ -z "$VIM_LINUX_GROUP" ]; then
    echo 'Hi there! I need a linux group id to execute my commands.'
    echo 'Preferably, you should give me your current group id. Therefore, I can'
    echo 'modify your files with the correct group, saving you a'
    echo 'lot of pain in the a**.'
    echo 'The next time you will run this container, please, provide a valid'
    echo 'user id using the -e switch like :'
    echo 'docker run --rm -it -e VIM_LINUX_GROUP=$(id -g) metabarj0/vim'
    echo 'Bye!'
    exit 1
  fi

  addgroup -g $VIM_LINUX_GROUP vim
  adduser -D -u $VIM_LINUX_USER -G vim vim

  # security reasons, sensitive values
  unset VIM_LINUX_USER
  unset VIM_LINUX_GROUP

  # the subscript is only a call to this one but it expand here the value of
  # $@, avoiding to have to supply the 'su -c ...' command with arguments as
  # it does not work as intended
  proxyScript='/home/vim/vim-execute.sh'
  cat << EOI > "$proxyScript"
#!/bin/sh
rm -f $proxyScript
exec vim-entrypoint.sh "$@"
EOI
  chmod +x "$proxyScript"
  chown vim:vim "$proxyScript"
  
  exec su vim -c "$proxyScript"
# Here, i am the 'vim' user
else
  exec $(echo "$@")
fi
