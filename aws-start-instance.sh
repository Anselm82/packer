#!/bin/bash

set -e

if [ $# -eq 0 ]
  then
    echo "You need to provide, at least, one of the following: aws, vagrant"
    exit 1
fi

while getopts ":s:f:" OPTION
do
    case "${OPTION}" in
        s ) SECURITY_GROUP=$OPTARG
            echo "Security group: '${SECURITY_GROUP}'";;
        f ) IMAGE_NAME_FILTER_TAG=$OPTARG
            echo "Filter: '${IMAGE_NAME_FILTER_TAG}'";;
        * ) echo "Required parameters: -s (security group id) and -f (image name filter)."
            exit 1;;
    esac
done

#sg-06eb7592adc485c48
if [ -z ${SECURITY_GROUP} ]
then
    echo "Security group id is mandatory to deploy allowing HTTP traffic.";
    exit 1
fi
#Name=tag:devops-tools-ami,Values=devops-tools-ami
if [ -z ${IMAGE_NAME_FILTER_TAG} ]
then
    echo "Please, add a image name filter predicate to locate the AMI id.";
    exit 1
fi

date=`date '+%Y%m%d%H%M%S'`

for param in "$@"
do
    if [ "$param" == "aws" ];
    then
        ami_id=$(aws ec2 describe-images --filters $IMAGE_NAME_FILTER_TAG --query 'Images[*].{ID:ImageId}' | grep "ID" | cut -d '"' -f 4)
        if [ ! -z "$ami_id" ];
        then
            deployment=$(aws ec2 run-instances --count 1 --image-id $ami_id --instance-type t2.micro --key-name devops-ami --security-group-ids $SECURITY_GROUP)
            echo $deployment
        fi
    elif [ "$param" == "vagrant" ];
    then
        mkdir vagrant-$date
        cp ./output-vagrant/package.box vagrant-$date
        cd vagrant-$date
        vagrant box add new-box --force package.box
        vagrant init new-box
        cp -f ../puppet-node/Vagrantfile  .
        deployment=$(vagrant up)
        echo $deployment
    fi
done
exit 0


