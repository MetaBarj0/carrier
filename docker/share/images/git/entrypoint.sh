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

# configure git, create ssh key files and forward the provided command
# some global configuration for git
git config --global init.templatedir /usr/local/share/git-core/templates/
git config --global core.editor vi

git config --global user.name $GIT_USER_NAME
git config --global user.email $GIT_USER_MAIL

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

cd

unset GIT_SSH_PUBLIC_KEY
unset GIT_SSH_SECRET_KEY
unset GIT_LINUX_USER
unset GIT_LINUX_GROUP

exec $(echo "$@")
