#!node_modules/bats/libexec/bats
############
# Authors: Ankshit Jain
# Purpose: Tests for the working status of containers of AutolabJS
# Date: 19-Feb-2018
# Previous Versions: -
###########

@test "Main Server Container Check" {
    result=$(grep -c "^main_server mainserver Up.*" container_status.txt)
    [ "$result" -eq 1 ]
}

@test "Load Balancer Container Check" {
    result=$(grep -c "^load_balancer loadbalancer Up.*" container_status.txt)
    [ "$result" -eq 1 ]
}

@test "Execution Nodes Container Check" {
     result=$(grep -c "^execution_node execution-node.* Up.*" container_status.txt)
    [ "$result" -eq "$NUMBER_OF_EXECUTION_NODES" ]
}

@test "Database Container Check" {
    result=$(grep -c "^mysql:latest autolab-db Up.*" container_status.txt)
    [ "$result" -eq 1 ]
}

@test "Gitlab Container Check" {
    result=$(grep -c "^gitlab/gitlab-ce:10.1.4-ce.0 gitlab Up.* (healthy)$" container_status.txt)
    [ "$result" -eq 1 ]
}

@test "Restart Script Check" {
    sudo bash -c "bash ./helper_scripts/container/restart_script_check.sh"
    result=$(sudo crontab -l -u root | grep -c 'bash /root/autolab-restart.sh')
    [ "$result" -eq 1 ]
}
