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
# Moreover, you can include files and or directories from dependencies used to
# build this image
packageIncluding() {
  # register built file for packaging
  registerBuiltFilesForPackaging

  # adding dynamic library dependencies
  collectSharedObjectDependencies

  # include wanted files and directories
  include "$@"

  # finalize the packaging
  finalizePackage
}

include() {
  :
}

# write all built files in /image.dist file of the image
registerBuiltFilesForPackaging() {
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
  # fix the list (file name containing space characters)

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
    echo 'append expects 3 arguments, no more, no les...exiting...'
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
        local so_path="$(find $PREFIX -name $so_file)"

        # add the file in the list
	so_paths="$(append "$so_paths" "$so_path" $'\n')"

        # if so_path is a link, recursively follow it and add it to the list
        while [ -L "$so_path" ]; do
          # get absolute file of the referenced
          so_path="$(find $PREFIX -name $(readlink $so_path))"

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

  # sorting and removing duplicates in image.dist
  echo "$(sort /image.dist | uniq)" > /image.dist

  return 0
}
