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
    echo 'No docker image specified...exiting...'
  fi

  # ask docker for images...
  local image=$(docker image ls -q "$1")

  if [ -z "$image" ]; then
    echo 'Inexisting docker image: '"$image"'...exiting...'
    return 1
  fi

  # output must be one and only one image
  if [ $(echo "$image" | wc -l) -gt 1 ]; then
    echo 'Ambiguous image name specified: '"$image"'...exiting...'
    return 1
  fi

  # get the image.dist file from the image, bypassing registered entrypoint if
  # any
  local dist_file_content="$(
    docker run --rm --entrypoint='' "$image" cat /image.dist 2> /dev/null)"

  # error while querying image.dist file content
  if [ ! $? -eq 0 ]; then
    echo 'Could not get '"$image"' package content...exiting...'
    return 1
  fi

  # browse package content, keeping only files
  local files=
  for x in $dist_file_content; do
    # just in case the package specified exists but is not a direct dependency
    # the the one being built
    if [ ! -e "$x" ]; then
      # a non dependency package has not its file copied in the image being
      # built
      echo 'Cannot find '"$x"' in the current image.'
      echo 'Make sure the package you are requesting is a dependency of the'
      echo 'one you are building...exiting'
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
  for item in $@; do
    list="$(append "$list" "$item" $'\n')"
  done

  echo "$list" | sort | uniq
}

# internal function designed to include files, directories or entire package
# inside the buildt image. This function is intended to be called by the
# 'packageIncluding' function
include() {
  if [ -z "$@" ]; then
    echo 'Nothing to include. Consider using package next time...continuing...'
    return 0
  fi

  # final file list to include, will be deduped
  local file_list=
  # browse items without dupes
  for item in $(makeUnique "$@"); do
    if [ -d "$item" ]; then # directory
      file_list="$(append "$file_list" "$(find "$item")" $'\n')"
    elif [ -f "$item" ]; then # file
      file_list="$(append "$file_list" "$item" $'\n')"
    else # packaged docker image?
      # get each files of the package (only files are returned to avoid
      # unnecessary recursive scan of existing directories
      local package_files=$(getPackageFiles "$item")

      # item is neither a file, a directory nor a packaged docker image
      if [ ! $? -eq 0 ]; then
        echo 'Invalid argument '"$item"' specified...exiting...'
        return 1
      fi

      # recursive call with the list of files
      include "$package_files"
    fi
  done

  # dedupe the file list before adding it to image.dist and touch each of its
  # file
  file_list="$(makeUnique "$file_list")"
  for f in $file_list; do touch "$f"; done

  echo "$file_list" >> /image.dist
}

# write all built files in /image.dist file of the image
registerBuiltFilesForPackaging() {
  if [ -z "$PREFIX" ]; then
    echo 'No prefix specified, $PREFIX must be defined...exiting...'
    return 1
  fi

  # get the diff between now and before the project was built, only in the
  # prefix directory. Produce a list of added files after the build and
  # installation
  docker diff $(hostname) \
  | grep -E '^A\s'$PREFIX \
  | sed -r 's/^A\s//' > /image.dist
}

# finalize the packaging process, fixing /image.dist file paths and commiting
# changes of the container in the image
finalizePackage() {
  # sorting and removing duplicates in image.dist
  echo "$(sort /image.dist | uniq)" > /image.dist

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
    echo 'append expects 3 arguments, no more, no less...exiting...'
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
    echo 'Nothing specified as argument...exiting...'
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
      | sed -r 's/.+\[(.+)\]$/\1/')

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
