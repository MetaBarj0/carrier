# return the thread count of the system. Can be used to speed up build with
# make for instance using the '-j' switch
getThreadCount() {
  echo $(cat /proc/cpuinfo | grep processor | wc -l)
}

# remove a directory only if it is empty otherwise does nothing
removeDirectoryIfEmpty() {
  if [ -z "$1" ]; then
    return 0
  fi

  # empty means no file
  if [ -z "$(find "$1" -type f)" ]; then
    rm -r "$1"
    return $?
  fi
}

# extract common line from files specified in arguments
# $1 first file to compare
# $2 second file to compare
extractCommonLinesInTwoFiles() {
  if [ ! -f "$1" ] || [ ! -f "$2" ]; then
    error 'Extracting common lines requires two files'
  fi

  local common_lines="$(comm -1 -2 "$1" "$2")"

  local returnCode=$?

  if [ $returnCode -ne 0 ]; then
    fatal 'could not extract common lines in '"$1"' and '"$2"
    return 1
  fi

  echo "$common_lines"
}

# wait an user input to put in a variable and echo this variable. If no
# input is made by the user before an end-of-line character, the provided
# default value is used. This function explicitely fails if no default value is
# provided.
readValueWithDefault() {
  if [ -z "$1" ]; then
    error 'No default value specified...exiting...'
    return 1
  fi

  read value

  if [ -z "$value" ]; then
    value="$1"
  fi

  echo "$value"
}

# creates a pair of the form arg1=arg2
makePair() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    error 'Two arguments are necessary to make a pair...exiting...'
    return 1
  fi

  echo "$1"'='"$2"
}

# verify iss given argument is a pair
isPair() {
  if [ -z "$1" ]; then
    error 'No argument specified...exiting...'
    return 1
  fi

  # a pair is something of the form key=value
  echo "$1" | grep -Ex '^[^=]+=.+$' 1> /dev/null

  return $?
}

# extract KEY of a pair having the following form : KEY=VALUE
keyOf() {
  if [ -z "$1" ] || ! isPair "$1"; then
    error 'No pair specified...exiting...'
    return 1
  fi

  echo "$1" | sed -E 's/(^[^=]+)=.+$/\1/'
}

# extract VALUE of a pair having the following form : KEY=VALUE
valueOf() {
  if [ -z "$1" ] || ! isPair "$1"; then
    error 'No pair specified...exiting...'
    return 1
  fi

  echo "$1" | sed -E 's/^[^=]+=(.+)$/\1/'
}

# generate a random modified base64 string ready to be used in a docker build
# stage alias. Replaced all '-' and '+' by '0'
generateRandomBuildStageAlias() {
  local random="$(generateRandomString "$1")"

  # replace annoying special chars (+ and -) with 0
  echo "$random" | sed -E 's/\+|-/0/g'
}

# generate a random modified base64 string from a number specified as argument.
# The number is a factor multiplied by 6 thus, the output string has a length
# multiple of 8 characters. The base 64 is modified as the '/' will be replaced
# by the '-' character. hence, it'll be more path friendly
generateRandomString() {
  # grab the factor from argument, assumes 1 if not provided
  local factor=$([ -z "$1" ] && echo 1 || echo "$1")

  # use dd with /dev/urandom, piped on base64, piped on sed to change '/' with
  # '-'
  local output=$(
    dd if=/dev/urandom \
       ibs=6 \
       count="$factor" 2>/dev/null \
    | base64 \
    | sed 's/\//-/g')

  echo "$output"
}

# pausing function waiting for a return hit. Useful for debugging, pausing stuff
# running in the container to allow the user to attach to it
pause() {
  error 'Press return to continue...' 1>&2
  read
}

# intended to be called after a successful sources build. This function make
# the built image a package reusable as base block in other image builds
package() {
  # register built file for packaging
  registerBuiltFilesForPackaging

  # adding dynamic library dependencies
  collectSharedObjectDependencies

  # finalize the packaging
  finalizePackage
}

# intended to be called after a successful sources build. This function make
# the built image a package reusable as base block in other image builds.
# Moreover, you can include files, directories or complete package used to
# build this image
packageIncluding() {
  # register built file for packaging
  registerBuiltFilesForPackaging

  # adding dynamic library dependencies
  collectSharedObjectDependencies

  # include wanted files, directories or packages
  include "$@"

  # finalize the packaging
  finalizePackage
}

# internal function taking a packaged (metabarj0/*) docker image as input and
# returning a list of its packaged files
getPackageFiles() {
  # need an image name as input
  if [ -z "$1" ]; then
    error 'No docker image specified...exiting...'
    return 1
  fi

  # ask docker for images...
  local image=$(docker image ls -q "$1")

  if [ -z "$image" ]; then
    error 'Inexisting docker image: '"$image"'...exiting...'
    return 1
  fi

  # output must be one and only one image
  if [ $(echo "$image" | wc -l) -gt 1 ]; then
    error 'Ambiguous image name specified: '"$image"'...exiting...'
    return 1
  fi

  # get the image.dist file from the image, bypassing registered entrypoint if
  # any
  local dist_file_content="$(
    docker run \
    -u root \
    --rm \
    --entrypoint='' \
    "$image" \
    cat /image.dist 2> /dev/null)"

  # error while querying image.dist file content
  if [ ! $? -eq 0 ]; then
    error 'Could not get '"$image"' package content...exiting...'
    return 1
  fi

  # browse package content, keeping only files, making sure the separator is new
  # line character
  local files=
  local x=
  local IFS=$'\n'
  for x in $dist_file_content; do
    # just in case the package specified exists but is not a direct dependency
    # the the one being built
    if [ ! -e "$x" ]; then
      # a non dependency package has not its file copied in the image being
      # built
      error "$(cat << EOI
Cannot find "$x" in the current image.  Make sure the package you are requesting
is a dependency of the one you are building...exiting
EOI
      )"
      return 1
    fi

    # collect only files
    if [ -f "$x" ]; then
      files="$(append "$files" "$x" $'\n')"
    fi
  done

  echo "$files"
}

# internal function taking a sequence as input and return another sequence
# without duplicated values. Each value of the list is followed by a new line
# character
makeUnique() {
  local list=
  local item=
  for item in $@; do
    list="$(append "$list" "$item" $'\n')"
  done

  echo "$list" | sort | uniq
}

# internal wrapper around include function. Designed to be called by include
# (recursive call) when on item to include is a packaged image. The IFS is
# reduced to \n, to correctly handle file names containing blank characters
wrapIncludeWithAlteredIFS() {
  local oldIFS="$IFS"
  IFS=$'\n'
  include "$@"
  IFS="$oldIFS"
}

# internal function designed to include files, directories or entire package
# inside the buildt image. This function is intended to be called by the
# 'packageIncluding' function
include() {
  if [ $# -lt 1 ]; then
    echo 'Nothing to include. Consider using package next time...continuing...'
    return 0
  fi

  # final file list to include, will be deduped
  local file_list=
  local item=
  # browse items without dupes
  for item in $(makeUnique "$@"); do
    if [ -d "$item" ]; then # directory
      file_list="$(append "$file_list" "$(find "$item")" $'\n')"
    elif [ -f "$item" ]; then # file
      file_list="$(append "$file_list" "$item" $'\n')"
    else # packaged docker image?
      # get each files of the package (only files are returned to avoid
      # unnecessary recursive scan of existing directories
      local package_files="$(getPackageFiles "$item")"

      # item is neither a file, a directory nor a packaged docker image
      if [ ! $? -eq 0 ]; then
        error 'Invalid argument '"$item"' specified...exiting...'
        return 1
      fi

      # recursive call with the list of files. Files in the list may contain
      # some special characters as space or tabs... Therefore, a special wrapper
      # is called to ensure each file names are separated by a new line and not
      # an eventual blanck character
      wrapIncludeWithAlteredIFS "$package_files"
    fi
  done

  # dedupe the file list before adding it to image.dist
  file_list="$(makeUnique "$file_list")"

  echo "$file_list" >> /image.dist
}

# write all built files in /image.dist file of the image
registerBuiltFilesForPackaging() {
  if [ -z "$PREFIX" ]; then
    error 'No prefix specified, $PREFIX must be defined...exiting...'
    return 1
  fi

  # get the diff between now and before the project was built, only in the
  # prefix directory. Produce a list of added files after the build and
  # installation
  docker diff $(hostname) \
  | grep -E '^A\s'$PREFIX \
  | sed -E 's/^A\s//' > /image.dist
}

# finalize the packaging process, fixing /image.dist file paths and commiting
# changes of the container in the image
finalizePackage() {
  # sorting and removing duplicates in image.dist
  echo "$(sort /image.dist | uniq)" > /image.dist

  # finally, touch each file in image.dist to register them for the commit
  xargs -a /image.dist -P $(getThreadCount) touch

  # commit changes
  docker commit $(hostname) $REPOSITORY

  # intermediate clean
  docker image prune -f
}

# a function that append stuff to a list that may be empty using a specified
# separator or space
append() {
  # even if empty, an argument surrounded by "" is detected
  if [ ! $# -eq 3 ]; then
    error 'append expects 3 arguments, no more, no less...exiting...'
    return 1
  fi

  local list="$1"
  local item="$2"
  local separator="$3"

  if [ -z "$list" ]; then
    echo "$item"
  else
    echo "$list""$separator""$item"
  fi

  return 0
}

# try to extract each shared object dependecies for a specified file
extractNeededSharedObjectsOf() {
  # I need a file as input
  if [ -z "$1" ]; then
    error 'Nothing specified as argument...exiting...'
    return 1
  fi

  # root path in which search for shared objects
  local ROOT=/usr/local

  # first arg is a least of at least one file
  local input="$1"

  # second arg is a list of shared object directly or indirectly needed by the
  # input file list
  local output="$2"

  local input_file=
  local so_paths=
  for input_file in $input; do
    # get the name of the shared object if the file is binary
    local needed_so_files=$(
      readelf -d "$input_file" 2> /dev/null \
      | grep NEEDED \
      | sed -E 's/.+\[(.+)\]$/\1/')

    # shared objects found
    if [ ! -z "$needed_so_files" ]; then
      # gets the absolute path of each shared object and put it in image.dist
      local so_file=
      for so_file in $needed_so_files; do
        # get the absolute path
        local so_path="$(find $ROOT -name $so_file)"

        # add the file in the list
        so_paths="$(append "$so_paths" "$so_path" $'\n')"

        # if so_path is a link, recursively follow it and add it to the list
        while [ -L "$so_path" ]; do
          # get absolute file of the referenced
          so_path="$(find $ROOT -name $(readlink $so_path))"

          # add it to the list
          so_paths="$(append "$so_paths" "$so_path" $'\n')"
        done
      done
    fi
  done

  # dependencies have been found
  if [ ! -z "$so_paths" ]; then
    # adding to output that will contain the final result
    output="$(append "$output" "$so_paths" $'\n')"

    # deduping
    output="$(echo "$output" | sort | uniq)"

    # continue to drill down
    extractNeededSharedObjectsOf "$so_paths" "$output"
  else
    echo "$output"
  fi

  return 0
}

# collect each dynamic object dependencies in /image.dist file.
# each file in image.dist is scanned
collectSharedObjectDependencies() {
  local x=
  local so=
  for x in $(cat /image.dist); do
    # directory item, looks for file
    if [ -d $x ]; then
      local f=
      for f in $(find $x -type f); do
        so="$(extractNeededSharedObjectsOf $f)"
        if [ ! -z "$so" ]; then
          # some shared objects have been found
          echo "$so" >> /image.dist
        fi
      done
    fi

    # file or symlink found
    if [ -f $x -o -L $x ]; then
      so="$(extractNeededSharedObjectsOf $x)"
      if [ ! -z "$so" ]; then
          # some shared objects have been found
        echo "$so" >> /image.dist
      fi
    fi
  done

  # adding the dynamic loader link
  echo '/lib/ld-musl-x86_64.so.1' >> /image.dist

  return 0
}

# fetches the metabarj0/manifest docker image content into a specified
# destination directory.
# The destination directory MUST exist, the metabarj0/manifest docker image is
# assumed to exist on the docker host.
# This function is intended to be called while image or appliance are being
# built, therefore, it is consistent to check for variables FETCHED_MANIFEST and
# USER_DIRECTORY
fetchManifestImageContent() {
  if [ ! ${USER_DIRECTORY+0} ]; then
    error "$(cat << EOI
Error: the internal variable USER_DIRECTORY is not set and mandatory to use
this function...exiting...
EOI
    )"
    return 1
  fi

  if [ ! -d "$1" ]; then
    error "$(cat << EOI
Error: need an existing destination directory to fetch the metabarj0/manifest
docker image content...exiting...
EOI
    )"
    return 1
  fi

  local destination_directory="$1"

  # check if a manifest has been fetched before by either a parent process or a
  # recursive call.
  if [ ! -z $FETCHED_MANIFEST ]; then
    return 0
  fi

  # change directory to the destination directory to work
  cd "$destination_directory"

  # background running of a manifest container
  local container_id=$(docker run --rm -d metabarj0/manifest)

  # update the manifest
  docker exec $container_id update

  # preparing manifest content to be copied on the host in the image
  # staging directory, then kill the running container
  docker cp $container_id:/docker.tar.bz2 .
  docker kill $container_id

  tar -xf docker.tar.bz2
  rm -f docker.tar.bz2

  # indicates that the manifest image content has been fetched, used in
  # subsequent sub shell invocation if dependency images must be built
  export FETCHED_MANIFEST="${destination_directory}"/docker

  # return to the user directory
  cd "$USER_DIRECTORY"
}

# utility function mapping image names with a build stage alias partially
# randomly generated. used in appliance's Dockerfile generation system as well
# as in the image's Dockerfile generation build system
mapImageNamesAndBuildStageAliases() {
  # first argument are a sequence of docker images, or not
  [ -z "$1" ] && return 0

  local required_images="$1"
  local map=
  local pair=
  local image=
  for image in $required_images; do
    pair="$(
      makePair \
        "$image" \
        "$(basename "$image")"'_'"$(generateRandomBuildStageAlias)"
    )"

    map="$(append "$map" "$pair" ' ')"
  done

  echo "$map"
}

setValueWithDefault() {
  if [ -z "$2" ]; then
    error 'No default value specified...exiting...'
    return 1
  fi

  local value="$1"
  if [ -z "$value" ]; then
    value="$2"
  fi

  echo "$value"
}

# internal log function
log() {
  local msg="$(setValueWithDefault "$1" 'missing message')"
  local dest="$(setValueWithDefault "$2" '&2')"

  # special handling of stderr: does not add "
  [ ! "$dest" = '&2' ] && dest='"'"$dest"'"'

  # special kind for redirection to be effective :
  # - with multi line argument, " must be explicitely added for eval
  command="$(cat << EOI
echo "$msg" 1>$dest
EOI
  )"

  eval "$command"
}

# logging function, designed to trace
trace() {
  log 'trace: '"$1" "$2"
}

# logging function, designed to debug
debug() {
  log 'debug: '"$1" "$2"
}

# logging function, designed to info
info() {
  log 'info: '"$1" "$2"
}

# logging function, designed to warning
warning() {
  log 'warning: '"$1" "$2"
}

# logging function, designed to error
error() {
  log 'error: '"$1" "$2"
}

# logging function, designed to fatal
fatal() {
  log 'fatal: '"$1" "$2"
}

# delete shell comment lines in argument
deleteCommentLines() {
  if [ ! -z "$1" ]; then
    echo "$1" | sed -E '/^ *#/d'
  fi
}

# split a sequence of element delimited by a specified separator using another
# specified separator
splitSequence() {
  if [ -z "$1" ]; then
    error "No sequence specified...exiting..."
    return 1
  fi

  if [ -z "$2"+0 ]; then
    error "No separator specified...exiting..."
    return 1
  fi

  local sequence="$1"
  local src_separator="$2"
  local dst_separator=$(setValueWithDefault "$3" ' ')

  echo "$sequence" | sed -E 's/'"$src_separator"'/'"$dst_separator"'/g'
}

# indicates if a provided string at frst argument exactly matches the provided
# pattern at second argument.
# $1: string to test
# $2: pattern to test string against
# If both inputs are empty, returns true
exactMatchWithPattern() {
  local string="$1"
  local pattern="$2"

  if [ -z "$string" ] && [ -z "$pattern" ]; then
    return 0
  fi

  #fatal 'printf -- '"$string"' | grep -Ex -- '"$pattern"' 1> /dev/null'
  printf -- "$string" | grep -Ex -- "$pattern" 1> /dev/null

  return $?
}

# take a regular string and encode it in path64. path64 is the same thing as
# base64 but '/' are replaced by '-'
# $1 a path string
path64Encode() {
  if [ -z "$1" ]; then
    return 0
  fi

  local encoded="$(printf "$1" | base64 | sed 's/\//-/g')"

  echo "$encoded"
}

# take a path64 string and decode it. path64 is the same thing as base64 but
# '/' are replaced by '-'
# $1 a path string
path64Decode() {
  if [ -z "$1" ]; then
    return 0
  fi

  local decoded="$(printf "$1" | sed 's/-/\//g' | base64 -d)"

  echo "$decoded"
}

# create a sequence of pair with the given sequence. If the element count of
# the sequence is odd, this function fails
# $1: a sequence to transform into a sequence of pair
makePairSequence() {
  if [ -z "$1" ]; then
    error 'no sequence specified.'
    return 1
  fi

  local key=
  local value=
  local pair=
  local pairSequence=

  local item=
  for item in $1; do
    [ -z "$key" ] && key="$item" && continue \
    || value="$item"

    pair="$(makePair "$key" "$value")"
    pairSequence="$(
      append "$pairSequence" "$pair" $'\n')"

    key=
    value=
  done

  # non empty key denote a malformed sequence containing an odd count of element
  [ -z "$key" ] \
  || return $?

  echo "$pairSequence"

  return $?
}
