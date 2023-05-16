# Prompt for confirmation
#
# @param {String} message  String displayed as the prompt for confirmation
# @param {String} default  Default when the response is empty or not Yes/No
function confirm {
  local message=$1
  local default=$2

  if [[ $default =~ ^([Yy]|yes)$ ]]
  then
    default="Y"
    options="[Yn]"
  else
    default="N"
    options="[yN]"
  fi

  read -p "$message $options " response
  response=${response:-$default}

  [[ $response =~ ^([Yy]|yes)$ ]] && true || false
}
