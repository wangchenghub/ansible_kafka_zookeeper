#！/bin/bash

basepath=`pwd`

# 节点配置：
sources="deb [trusted=yes] http://172.16.105.150:81/ soft/"
nodes="172.16.150.181","172.16.150.182","172.16.150.183"


# 检查命令执行情况：
function is_fail(){
    if [[ $1 -ne 0 ]];then
        echo -e "\033[31m--------------- Error ---------------\033[0m"
        [[ $1 -eq 1 ]] && exit 1;
    fi
}


# 修改内网apt源：
function modify(){
    hostname=$1
    username="root"

    # step: 1 --> 删除源文件
    ssh $username@$hostname "rm -vrf /etc/apt/sources.list"

    # step: 2 --> 生成源文件
    ssh $username@$hostname "echo $sources > /etc/apt/sources.list" 
}


# 下载依赖包：
function download(){
    hostname=$1
    username="root"

    # step: 1 --> apt update
    ssh $username@$hostname "apt update"

    # step: 2 --> apt install xxx
    ssh $username@$hostname "apt install -y $2"

}


# 加载主机：
IFS=',' arr=($nodes)

## 换源：
#for x in ${arr[@]}; do
#  modify $x $sources
#  is_fail $?
#done


# 下载 java sdk：
for x in ${arr[@]}; do
  download $x "openjdk-8-jre-headless"
  is_fail $?
done


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
