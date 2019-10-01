#!/bin/sh

base_dir=$(pwd)
deps_missing=false
deploy_key_fe="deploy-fe.priv"
deploy_key_be="deploy-be.priv"
frontend_repo="git@github.com:tomislavperich/udomime-frontend.git"
backend_repo="git@github.com:tomislavperich/udomime-backend.git"

# check dependencies
for cmd in git docker docker-compose; do
    if ! command -v $cmd 1>/dev/null; then
        echo "please install ${cmd} to continue"
        deps_missing=true
    fi
done

if $deps_missing; then
    exit 1
fi

show_help() {
    echo "Usage: $(basename $0) [OPTION]"
    echo "Deploy Udomi Me"
    echo
    echo "-h            Show this help"
    echo "-d, --deploy  Deploy application"
    echo "-s, --start   Start docker containers"
    echo "-u, --stop    Stop docker containers"
    echo "--clone-only  Only clone git repositories"
}

clone_repos() {
    echo "[+] Cloning public repositories"
    git clone $frontend_repo 
    git clone $backend_repo
}

clone_repos_private() {
    echo "[o] Checking for private keys"
    if [ -f $deploy_key_fe ] && [ -f $deploy_key_be ]; then
        export git_ssh_command="ssh -i ${base_dir}/${deploy_key_fe}"
        git clone $frontend_repo

        export git_ssh_command="ssh -i ${base_dir}/${deploy_key_be}"
        git clone $backend_repo
    else
        echo "[!] Missing deployment keys, exiting..."
        exit 1
    fi
}

start_containers() {
    echo "[+] Starting containers"
    workdir="udomime-frontend"
    cd "${base_dir}/${workdir}" && sudo docker-compose up -d
 
    workdir="udomime-backend"
    cd "${base_dir}/${workdir}" && sudo docker-compose up -d
}


stop_containers() {
    echo "[!] Shutting down..."
    workdir="udomime-frontend"
    cd "${base_dir}/${workdir}" && sudo docker-compose down
    
    workdir="udomime-backend"
    cd "${base_dir}/${workdir}" && sudo docker-compose down
}

deploy_app() {
    private_repos=${1:-false}
    echo "[i] Deploying app..."

    if $private_repos; then
        clone_repos_private
    else
        clone_repos
    fi

    start_containers

    # migrate backend
    echo "[+] Migrating database, ignore retry errors"
    sudo docker exec -it udomime-web bash -c '/scripts/wait-for-mysql.py && /app/manage.py migrate'
}

check_args() {
    case $1 in
    "-h" | "--help")
        show_help
        exit
        ;;
    "-d" | "--deploy")
        deploy_app
        exit
        ;;
    "-s" | "--start")
        start_containers
        exit
        ;;
    "-t" | "--stop")
        stop_containers
        exit
        ;;
    "--clone-only")
        clone_repos
        exit
        ;;
    *)
        show_help
        exit
        ;;
    esac
}

check_args "$1"

