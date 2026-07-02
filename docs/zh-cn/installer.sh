#!/bin/bash

# UUSEC WAF one click installation script
# Supported system: CentOS/RHEL 7+, Debian 11+, Ubuntu 18+, Fedora 32+, etc

info() {
    echo -e "\033[32m[南墙] $*\033[0m"
}

warning() {
    echo -e "\033[33m[南墙] $*\033[0m"
}

abort() {
    echo -e "\033[31m[南墙] $*\033[0m"
    exit 1
}

if [[ $EUID -ne 0 ]]; then
    abort "此脚本必须以root权限运行"
fi

OS_ARCH=$(uname -m)
case "$OS_ARCH" in
    x86_64)
    ;;
    *)
    abort "不支持的 CPU 架构: $OS_ARCH"
    ;;
esac

if [ -f /etc/os-release ]; then
    source /etc/os-release
    OS_NAME=$ID
    OS_VERSION=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    OS_NAME=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    OS_VERSION=$(lsb_release -sr)
else
    abort "无法检测操作系统"
fi

normalize_version() {
    local version=$1
    version=$(echo "$version" | tr -d '[:alpha:]_-' | sed 's/\.\+/./g')
    IFS='.' read -ra segments <<< "$version"

    while [ ${#segments[@]} -lt 4 ]; do
        segments+=(0)
    done

    printf "%04d%04d%04d%04d" \
        "${segments[0]}" \
        "${segments[1]}" \
        "${segments[2]}" \
        "${segments[3]}"
}

NEW_OS_VERSION=$(normalize_version "$OS_VERSION")

check_ports() {
    if [ $(command -v ss) ]; then
        for port in 80 443 777 4443 4447 6612; do
            if ss -tln "( sport = :${port} )" | grep -q LISTEN; then
                abort "端口 ${port} 被占用, 请关闭该端口后重新安装"
            fi
        done
	fi
}

install_waf() {
    if [ ! $(command -v curl) ]; then
        $( command -v yum || command -v apt-get || command -v zypper ) -y install curl
    fi
    curl https://waf.uusec.com/zh-cn/docker.tgz -o /tmp/docker.tgz
    mkdir -p /opt && tar -zxf /tmp/docker.tgz -C /opt/
    if [ $? -ne "0" ]; then
        abort "安装失败"
    fi
    
    if [ ! $(command -v docker) ]; then
        warning "未检测到 Docker 引擎，我们将自动为您安装。过程较慢，请耐心等待 ..."
        case $OS_NAME in
            alinux)
                wget -O /etc/yum.repos.d/docker-ce.repo http://mirrors.cloud.aliyuncs.com/docker-ce/linux/centos/docker-ce.repo
                sed -i 's|https://mirrors.aliyun.com|http://mirrors.cloud.aliyuncs.com|g' /etc/yum.repos.d/docker-ce.repo
                local v3=$(normalize_version "3")
                if [ "$NEW_OS_VERSION" -ge "$v3" ]; then
                    dnf -y install dnf-plugin-releasever-adapter --repo alinux3-plus
                    dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                else
                    yum -y install yum-plugin-releasever-adapter --disablerepo=* --enablerepo=plus
                    yum -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                fi
                ;;
            tlinux)
                local v4=$(normalize_version "4")
                if [ "$NEW_OS_VERSION" -ge "$v4" ]; then
                    yum install docker -y
                else
                    dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin --nobest
                fi
                ;;
            *)
                sh /opt/waf/install-docker.sh --mirror Aliyun
                if [ $? -ne "0" ]; then
                    abort "Docker 引擎自动安装失败，请在执行此脚本之前手动安装它。"
                fi
                ;;
        esac
        
        mkdir -p /etc/docker
        echo '{"registry-mirrors":["https://docker.1ms.run"]}' > /etc/docker/daemon.json
        systemctl enable docker && systemctl daemon-reload && systemctl restart docker
    fi
}

allow_firewall_ports() {
    if [ ! -f "/opt/waf/.fw" ];then
        echo "" > /opt/waf/.fw
        if [ $(command -v firewall-cmd) ]; then
            firewall-cmd --permanent --add-port={80,443,4443,4447}/tcp > /dev/null 2>&1
            firewall-cmd --reload > /dev/null 2>&1
        elif [ $(command -v ufw) ]; then
            for port in 80 443 4443 4447; do ufw allow $port/tcp > /dev/null 2>&1; done
            ufw reload > /dev/null 2>&1
        fi
    fi
}

main() {
    info "检测到系统：${OS_NAME} ${OS_VERSION} ${OS_ARCH}"

    warning "检查端口冲突 ..."
    check_ports

    if [ ! -e "/opt/waf" ]; then
        warning "安装中 ..."
        install_waf
    else
        abort '目录 "/opt/waf" 已存在, 请确认删除后再试'
    fi

    warning "添加防火墙端口例外..."
    allow_firewall_ports

    bash /opt/waf/manager.sh
}

main
