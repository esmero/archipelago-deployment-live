#!/bin/bash

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
metadata_action_opts=("Export all Metadata Displays to a folder." "Import all Metadata Displays from a folder." "Cancel")
selected_metadata_action=""
archipelago_domain=""
archipelago_protocol="https://"
archipelago_domain_set=0
json_api_endpoint=""

domain_questions() {
  if [[ -v "${ARCHIPELAGO_DOMAIN}" ]]; then
    echo "Is $ARCHIPELAGO_DOMAIN the correct domain? "
    PS3='> '
    select opt in Yes No; do
      case "$opt" in
        Yes)
          archipelago_domain_set=1
          archipelago_domain=$ARCHIPELAGO_DOMAIN
          break;;
        No)
          archipelago_domain_set=0
          break;;
        *) echo "Please select an option.";;
      esac
    done
  fi
  if [ "${archipelago_domain_set}" -eq 0 ]
  then
	  echo -n $'What is the domain? (without protocol or trailing slash, e.g. metro.org or archipelago.nyc or localhost:8001)\n'
      read -p "> " archipelago_domain
  fi
  echo "Is $archipelago_domain HTTPS or HTTP? "
  PS3='> '
  select opt in HTTPS HTTP; do
    case "$opt" in
      HTTPS)
        break;;
      HTTP)
        archipelago_protocol="http://"
        break;;
      *) echo "Please select an option.";;
    esac
  done

}

echo 'What would you like to do? '
PS3='> '

select opt in "${metadata_action_opts[@]}"; do
  case "$opt" in
    "Cancel")
      exit 0;;
    Export*)
      selected_metadata_action=1
      break;;
    Import*)
      selected_metadata_action=0
      break;;
    *) echo "Please select an option.";;
  esac
done

unset username
unset password
echo "JSON:API Username:"
read -p "> " username
prompt="JSON:API Password: `echo $'\n> '`"
while IFS= read -p "$prompt" -r -s -n 1 char
do
  if [[ "${char}" == $'\0' ]]
  then
    break
  fi
  prompt='*'
  password+="$char"
done
echo $'\n'

env_file="$script_dir/../../../deploy/ec2-docker/.env"
if [ -f "$env_file" ]; then
  source "$env_file"
  domain_questions
else
  domain_questions
fi

echo "$archipelago_protocol$archipelago_domain"
json_api_endpoint="$archipelago_protocol$archipelago_domain/jsonapi/metadatadisplay_entity/metadatadisplay_entity"

if [ "${selected_metadata_action}" -eq 1 ]
then
  export_source=""
  echo 'Export to the current directory? '
  echo "$PWD"
  PS3='> '
  select opt in "Yes, export from current directory." "No, specify a directory."; do
    case "$opt" in
      Yes*)
	export_source="$PWD"
        break;;
      No*)
	      echo "Please provide an absolute directory (will be created if it doesn't already exist): "
        read -p "> " export_source
        break;;
      *) echo "Please select an option.";;
    esac
  done
  [ ! -d "$export_source" ] && mkdir -p "$export_source"
  echo "Exporting Metadata Displays to to the current directory."
  cd "$export_source" &&
  curl -w "\n" --user "$username":"$password" -H 'Accept: application/vnd.api+json' -H 'Content-type: application/vnd.api+json' -XGET "$json_api_endpoint" | jq -cr '.data[]|del(.links)|del(.relationships)|del(.attributes.created)|del(.attributes.drupal_internal__id)|del(.attributes.changed)|del(.attributes.link)|{"data": .}'| awk -F'\t' '{ i++ ; fname = "metadatadisplay_entity_" i ".json"; print > fname; close(fname)}'

elif [ "${selected_metadata_action}" -eq 0 ]
then
  import_source=""
  echo 'Import from the current directory? '
  echo "$PWD"
  PS3='> '
  select opt in "Yes, import from current directory." "No, specify a directory."; do
    case "$opt" in
      Yes*)
	import_source=$PWD
        break;;
      No*)
	echo "Please provide an absolute directory: "
        read -p "> " import_source
        break;;
      *) echo "Please select an option.";;
    esac
  done
  [[ "${import_source}" != */ ]] && import_source="${import_source}/"
  shopt -s nullglob
  for f in $import_source*.json
  do
    import_id=$(jq -cr .data.id "$f")
    import_id_exists=$(curl -I -w "\n" --user "$username":"$password" --write-out '%{http_code}' --silent --output /dev/null "$json_api_endpoint"/"$import_id")
    if [ $import_id_exists -eq 200 ]
    then
      echo 'Metadata Display Entity exists. Updating.'
      curl -w "\n" --user "$username":"$password" -H 'Accept: application/vnd.api+json' -H 'Content-type: application/vnd.api+json' -XPATCH "$json_api_endpoint"/"$import_id" --data-binary @$f;
    else
      echo 'Metadata Display Entity exists. Importing.'
      curl -w "\n" --user "$username":"$password" -H 'Accept: application/vnd.api+json' -H 'Content-type: application/vnd.api+json' -XPOST "$json_api_endpoint" --data-binary @"$f";
    fi
  done
fi

