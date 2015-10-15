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

spot_pending=$(/opt/slurm/bin/squeue -p spot -h -o '%t %C' | awk '$1 == "PD" { total = total + $2} END {print total}')
small_pending=$(/opt/slurm/bin/squeue -p small -h -o '%t %C' | awk '$1 == "PD" { total = total + $2} END {print total}')
medium_pending=$(/opt/slurm/bin/squeue -p medium -h -o '%t %C' | awk '$1 == "PD" { total = total + $2} END {print total}')
large_pending=$(/opt/slurm/bin/squeue -p large -h -o '%t %C' | awk '$1 == "PD" { total = total + $2} END {print total}')

if [ "${spot_pending}x" == "x" ]; then
spot_pending=0
fi
if [ "${small_pending}x" == "x" ]; then
small_pending=0
fi
if [ "${medium_pending}x" == "x" ]; then
medium_pending=0
fi
if [ "${large_pending}x" == "x" ]; then
large_pending=0
fi

aws --region ${ec2_region%?} cloudwatch put-metric-data --namespace cfncluster --metric-name spot_pending_cpu --unit Count --value ${spot_pending} --dimensions Stack=${stack_name}
aws --region ${ec2_region%?} cloudwatch put-metric-data --namespace cfncluster --metric-name small_pending_cpu --unit Count --value ${small_pending} --dimensions Stack=${stack_name}
aws --region ${ec2_region%?} cloudwatch put-metric-data --namespace cfncluster --metric-name medium_pending_cpu --unit Count --value ${medium_pending} --dimensions Stack=${stack_name}
aws --region ${ec2_region%?} cloudwatch put-metric-data --namespace cfncluster --metric-name large_pending_cpu --unit Count --value ${large_pending} --dimensions Stack=${stack_name}