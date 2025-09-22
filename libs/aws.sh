#!/usr/bin/env bash


aws::login(){
    PROFILE=$1
    echo "Logging in the ${PROFILE} AWS Profile"
    aws sso login --profile $PROFILE
    export AWS_PROFILE=$PROFILE
}


# set-alias aws-login aws::login