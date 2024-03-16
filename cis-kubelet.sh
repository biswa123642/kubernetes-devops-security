#!/bin/bash

total_fail=$(kube-bench run --targets node  --version 1.28 --check 3.1.1,3.1.2 --json | jq -r '.Totals.total_fail')

if [[ "$total_fail" -ne 0 ]];
        then
                echo "CIS Benchmark Failed Kubelet while testing for 3.1.1, 3.1.2"
                exit 1;
        else
                echo "CIS Benchmark Passed Kubelet for 3.1.1, 3.1.2"
fi;
