#!/bin/bash

total_fail=$(docker run --pid=host -v /etc:/etc:ro -v /var:/var:ro -v $(which kubectl):/usr/local/mount-from-host/bin/kubectl -v ~/.kube:/.kube -e KUBECONFIG=/.kube/config -t aquasec/kube-bench:latest  run --targets node --version 1.28 --check 3.1.1,3.1.2 --json | jq -r '.Totals.total_fail')

if [[ "$total_fail" -ne 0 ]];
        then
                echo "CIS Benchmark Failed Kubelet while testing for 3.1.1, 3.1.2"
                exit 1;
        else
                echo "CIS Benchmark Passed Kubelet for 3.1.1, 3.1.2"
fi;
