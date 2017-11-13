#!/bin/sh

# try to extract each shared object dependecies for a specified file
tryExtractSharedObjectFromFile() {
  # I need a file as input
  if [ -z $1 ]; then
    echo 'No file specified...exiting...'
    return 1
  fi

  # get the name of the shared object if the file is binary
  needed_so_files=$(
    readelf -d $1 | grep NEEDED | sed -r 's/.+\[(.+)\]$/\1/') 2> /dev/null

  # shared objects found
  if [ ! -z "$needed_so_files" ]; then
    # gets the absolute path of each shared object and put it in image.dist
    so_paths=
    for so_file in $needed_so_files; do
      # get the absolute path
      so_path="$(find $PREFIX -name $so_file)"

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

    echo "$so_paths"
  fi

  return 0
}

# collect each dynamic object dependencies in /image.dist file.
# each file in image.dist is scanned
collectSharedObjectDependencies() {
  for x in $(cat /image.dist); do
    # directory item, looks for file
    if [ -d $x ]; then
      for f in $(find $x -type f); do
        so="$(tryExtractSharedObjectFromFile $f)"
        if [ ! -z "$so" ]; then
	  # some shared objects have been found
          echo "$so" >> /image.dist
        fi
      done
    fi
  
    # file or symlink found
    if [ -f $x -o -L $x ]; then
      so="$(tryExtractSharedObjectFromFile $x)"
      if [ ! -z "$so" ]; then
	  # some shared objects have been found
        echo "$so" >> /image.dist
      fi
    fi
  done

  # sorting and removing duplicates in image.dist
  echo "$(sort /image.dist | uniq)" > /image.dist

  return 0
}
