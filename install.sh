#！/bin/bash

basepath=`pwd`

# 检查命令执行情况：
function is_fail(){
    if [[ $1 -ne 0 ]];then
        echo -e "\033[31m--------------- Error ---------------\033[0m"
        [[ $1 -eq 1 ]] && exit 1;
    fi
}


# 移植python虚拟环境
mkdir -p /root/.virtualenvs
is_fail $?
tar -xf $basepath/ansible-py3.tar.gz -C /root/.virtualenvs/
is_fail $?
playbook=/root/.virtualenvs/ansible-py3/bin/ansible-playbook
is_fail $?


# 调用 ansible-playbook:
cp -r $basepath/ansible/* /etc/ansible
is_fail $?

$playbook deploy.yaml
