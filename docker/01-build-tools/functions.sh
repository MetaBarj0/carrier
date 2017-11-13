#!/bin/sh

# try to extract each shared object dependecies for a specified file
extractNeededSharedObjectsOf() {
  # I need a file as input
  if [ -z "$1" ]; then
    echo 'No file specified...exiting...'
    return 1
  fi

  # get the name of the shared object if the file is binary
  local needed_so_files=$(
    readelf -d "$1" 2> /dev/null | grep NEEDED | sed -r 's/.+\[(.+)\]$/\1/')

  # shared objects found
  if [ ! -z "$needed_so_files" ]; then
    # gets the absolute path of each shared object and put it in image.dist
    local so_paths=
    local so_file=
    for so_file in $needed_so_files; do
      # get the absolute path
      local so_path="$(find $PREFIX -name $so_file)"

      # add the file in the list
      so_paths="$so_paths"$'\n'"$so_path"

      # if so_path is a link, recursively follow it and add it to the list
      while [ -L "$so_path" ]; do
        # get absolute file of the referenced
        so_path="$(find $PREFIX -name $(readlink $so_path))"

	# add it to the list
        so_paths="$so_paths"$'\n'"$so_path"
      done
    done

    # deduping and sorting
    so_paths="$(echo "$so_paths" | sort | uniq)"

    echo "$so_paths"
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
