function confirm {
  local message=$1
  local default=$2

  if [[ $default =~ ^[yY]$ ]]; then
    default="Y"
    options="[Yn]"
  else
    default="N"
    options="[yN]"
  fi

  read -p "$message" -n 1 response
  response=${response:-${default}}

  if [[ $response =~ ^([Yy]|yes)$ ]];
    return true
  else
    return false
  fi
}