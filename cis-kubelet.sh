#!/bin/bash

JOB_NAME="kube-bench"

#Create Job
kubectl create -f kube-bench-job.yaml
kubectl wait --for=condition=complete --timeout=60s job/$JOB_NAME


podname=$(kubectl get pods -l job-name=kube-bench -o=jsonpath='{.items..metadata.name}')

total_fail=$(kubectl logs $podname | grep "checks FAIL" | tail -n 1 | awk '{print $1}')

if [[ "$total_fail" -ne 0 ]];
        then
                echo "CIS Benchmark Failed Node while testing"
                exit 1;
        else
                echo "CIS Benchmark Passed for Node"
fi;

#Delete Job
kubectl delete -f kube-bench-job.yaml
