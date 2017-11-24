#!/bin/sh

# grab the build script from the build tools
CURRENT_DIRECTORY=$(pwd -P)
cd $(dirname $0)
SCRIPT_DIRECTORY=$(pwd -P)
BUILD_TOOLS_DIRECTORY=$SCRIPT_DIRECTORY/../01-build-tools
cd $CURRENT_DIRECTORY

# if this image require some extra commands (environment vars, volumes...), put
# them here
EXTRA_DOCKERFILE_COMMANDS="$(cat << EOI
ENV TERMINFO /usr/local/share/terminfo
ENV PATH /usr/local/mysql/bin:\${PATH}

VOLUME [ "/usr/local/mysql/data/" ]
VOLUME [ "/usr/local/mysql/etc/" ]
VOLUME [ "/usr/local/mysql/mysql-files/" ]

EXPOSE 3306

ENTRYPOINT [ "/usr/local/mysql/mysql_server_start.sh" ]
EOI
)"

exec \
  $BUILD_TOOLS_DIRECTORY/build.sh \
  metabarj0/mysql \
  $SCRIPT_DIRECTORY \
  "$EXTRA_DOCKERFILE_COMMANDS"
