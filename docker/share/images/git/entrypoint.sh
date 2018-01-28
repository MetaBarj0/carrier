#!/bin/sh
# check arguments that are the command we want the container runs. if not set,
# assumes that the user want a shell
if [ -z "$1" ]; then
  set -- sh;
fi

# checking necessary environment
if [ -z "$GIT_USER_NAME" ]; then
  cat << EOI 1>&2
Hello John Doe, you forgot to tell me your name. I need it to configure The
Stupid Content Tracker properly!  The next time you will run this container,
please, provide your name using the -e switch like :
  docker run --rm -it metabarj0/git -e GIT_USER_NAME=Groot
Bye!
EOI
  exit 1
fi

if [ -z "$GIT_USER_MAIL" ]; then
  cat << EOI 1>&2
Hello, you forgot to tell me your email. I need it to configure The Stupid
Content Tracker properly!  The next time you will run this container, please,
provide your email address using the -e switch like :
  docker run --rm -it metabarj0/git -e GIT_USER_MAIL=groot@gog.com
Bye!
EOI
  exit 1
fi

if [ -z "$GIT_SSH_PUBLIC_KEY" ]; then
  cat << EOI 1>&2
Hello, you forgot to tell me your ssh public key. I need it to configure The
Stupid Content Tracker properly!  The next time you will run this container,
please, provide your ssh public using the -e switch like :
  docker run --rm -it \\
    metabarj0/git -e GIT_SSH_PUBLIC_KEY="\$(cat ~/.ssh/id_rsa.pub)"
for instance.
Bye!
EOI
  exit 1
fi

if [ -z "$GIT_SSH_SECRET_KEY" ]; then
  cat << EOI 1>&2
Hello, you forgot to tell me your ssh secret key. I need it to configure The
Stupid Content Tracker properly!  The next time you will run this container,
please, provide your ssh public using the -e switch like :
  docker run --rm -it metabarj0/git \\
    -e GIT_SSH_SECRET_KEY="\$(cat ~/.ssh/id_rsa)"
for instance.
Bye!
EOI
  exit 1
fi

if [ -z "$GIT_REPOSITORY_PATH" -o ! -d "$GIT_REPOSITORY_PATH" ]; then
  echo 'Hey, to work well, you need to specify a path where git will work'
  cat << EOI 1>&2
The next time you will run this container, please, provide a valid directory
path using the -e switch like :
  docker run --rm -it metabarj0/git -e GIT_REPOSITORY_PATH=\$(pwd)
Note that you would like to bind-mount a volume in this directory to work on a
local copy of a git repository located on your docker host.
Bye!
EOI
  exit 1
fi

if [ -z "$GIT_LINUX_USER" ]; then
  cat << EOI 1>&2
Hi there! I need a linux user id to execute my commands.  Preferably, you should
give me your current user id. Therefore, I can create your git repository files
with the correct user, saving you a lot of pain in the a**.  The next time you
will run this container, please, provide a valid user id using the -e switch
like :
  docker run --rm -it metabarj0/git -e GIT_LINUX_USER=\$(id -u)
Bye!
EOI
  exit 1
fi

if [ -z "$GIT_LINUX_GROUP" ]; then
  cat << EOI 1>&2
Hi there! I need a linux group id to execute my commands.  Preferably, you
should give me your current group id. Therefore, I can create your git
repository files with the correct group, saving you a lot of pain in the a**.
The next time you will run this container, please, provide a valid user id using
the -e switch like :
  docker run --rm -it metabarj0/git -e GIT_LINUX_GROUP=\$(id -g)
Bye!
EOI
  exit 1
fi

# Two phases execution :
# - first, the container runs with the root user : it creates a git user using
#   the user and group id provided by the environment and create a sub-script
#   to execute as 'git' instead as 'root'. The sub script creation is necessary
#   because the 'su -c ...' command looks not able to parse arguments of the
#   command it is supposed to execute.
# - second, as the git user, execute this very same script and configure git,
#   create ssh key files and forward the provided command
if [ $(whoami) != git ]; then
  addgroup -g $GIT_LINUX_GROUP git
  adduser -D -u $GIT_LINUX_USER -G git git

  # the subscript is only a call to this one but it expand here the value of
  # $@, avoiding to have to supply the 'su -c ...' command with arguments as
  # it does not work as intended
  cat << EOI > entrypoint-as-git.sh
#!/bin/sh
exec entrypoint.sh "$@"
rm -f \$0
EOI
  chown git:git entrypoint-as-git.sh
  chmod +x entrypoint-as-git.sh
  
  exec su git -c ./entrypoint-as-git.sh
# Here, i am the 'git' user
else
  # some global configuration for git
  git config --global init.templatedir /usr/local/share/git-core/templates/
  git config --global core.editor vi
  
  git config --global user.name $GIT_USER_NAME
  git config --global user.email $GIT_USER_MAIL
  
  cd $HOME
  mkdir -p .ssh
  cd .ssh

  # create ssh key pair
  echo "$GIT_SSH_PUBLIC_KEY" > id_rsa.pub
  echo "$GIT_SSH_SECRET_KEY" > id_rsa

  # create a 'very' permissive ssh configuration, disabling host key checking
  # this container is ephemeral and it is not a serious issue in this context
  cat << EOI > config
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  LogLevel QUIET
EOI
  
  # security
  chmod 400 id_rsa
  unset GIT_SSH_PUBLIC_KEY
  unset GIT_SSH_SECRET_KEY
  unset GIT_LINUX_USER
  unset GIT_LINUX_GROUP

  # lots of useful git stuff is located here
  export GIT_EXEC_PATH=/usr/local/libexec/git-core

  # go to the bind directory from host
  cd "$GIT_REPOSITORY_PATH"
  
  exec $(echo "$@")
fi
