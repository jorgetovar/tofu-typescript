#!/bin/bash

apply () {
    terraform init
    ./build.sh
    terraform apply
}

destroy () {
    terraform destroy --auto-approve
}

case "$1" in
   "apply") apply
   ;;
   "destroy") destroy
   ;;
esac