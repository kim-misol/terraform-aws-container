#!/usr/bin/env bash

init() {
  export $(cat .env | xargs)
  local workspace="$1"

  local username="$GITLAB_USERNAME"
  local access_token="$GITLAB_ACCESS_TOKEN"

  # Change the following two values if repository has been moved.
  local id="34892655"
  local state_name="terraform-aws-cherry-cake-cluster"

  case $workspace in
    "dev" | "develop")
      workspace="./environments/dev"
      ;;
    "prod" | "production")
      workspace="./environments/prod"
      ;;
    "test")
      workspace="./environments/test"
      ;;
    *)
      echo -e "\nUsage: gitlab-terraform-init.sh WORKSPACE"
      echo -e "\t'dev', 'prod', or 'test'"
      exit 1
      ;;
  esac

  if [[ -z $username ]] || [[ -z $access_token ]]; then
    echo -e "GITLAB_USERNAME and GITLAB_ACCESS_TOKEN should be defined in .env file"
    exit 1
  fi

  printf "environments:\t%s\n" $workspace
  printf "username:\t%s\n" $username
  printf "access token:\t%s\n" $access_token
  printf "project id:\t%s\n" $id
  printf "state name:\t%s\n" $state_name

  local url="https://gitlab.com/api/v4/projects/$id/terraform/state/$state_name"
  terraform -chdir="$workspace" init \
    -backend-config="address=$url" \
    -backend-config="lock_address=$url/lock" \
    -backend-config="unlock_address=$url/lock" \
    -backend-config="username=$username" \
    -backend-config="password=$access_token" \
    -backend-config="lock_method=POST" \
    -backend-config="unlock_method=DELETE" \
    -backend-config="retry_wait_min=5"
}

init "$@"
