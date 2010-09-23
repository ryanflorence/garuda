if [ $# -lt 1 ]; then
  echo "Gimme a path to a repository or sumfink!"
else
  path=$1
  if [ -d $path ]
  then
      git clone $path
  else
      echo No git repository found in $path
      exit
  fi
fi
