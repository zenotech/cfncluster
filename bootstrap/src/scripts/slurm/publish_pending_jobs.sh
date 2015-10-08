#!/bin/sh

# Copyright 2013-2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License"). You may not use this file except in compliance with the
# License. A copy of the License is located at
#
# http://aws.amazon.com/asl/
#
# or in the "LICENSE.txt" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES 
# OR CONDITIONS OF ANY KIND, express or implied. See the License for the specific language governing permissions and
# limitations under the License.

. /opt/cfncluster/cfnconfig

ec2_region_url="http://169.254.169.254/latest/meta-data/placement/availability-zone"
ec2_region=$(curl --retry 3 --retry-delay 0 --silent --fail ${ec2_region_url})

if [ "${cfn_spot_fleet}" == "True" ]; then
pending=$(/opt/slurm/bin/squeue -p spot -h -o '%t %D' | awk '$1 == "PD" { total = total + $2} END {print total}')
if [ "${pending}x" == "x" ]; then
pending=0
fi
aws --region ${ec2_region%?} cloudwatch put-metric-data --namespace cfncluster --metric-name spotpending --unit Count --value ${pending} --dimensions Stack=${stack_name}
else
pending=$(/opt/slurm/bin/squeue -p ondemand -h -o '%t %D' | awk '$1 == "PD" { total = total + $2} END {print total}')
if [ "${pending}x" == "x" ]; then
pending=0
fi
aws --region ${ec2_region%?} cloudwatch put-metric-data --namespace cfncluster --metric-name pending --unit Count --value ${pending} --dimensions Stack=${stack_name}
fi
