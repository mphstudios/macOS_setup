function confirm {
  local message=$1
  local default=$2

  if [[ $default =~ ^[yY]$ ]]
  then
    default="Y"
    options="[Yn]"
  else
    default="N"
    options="[yN]"
  fi

  read -p "$message " response
  response=${response:-default}

  [[ $response =~ ^([Yy]|yes)$ ]] && true || false
}