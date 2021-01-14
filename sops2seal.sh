#!/usr/bin/env bash
set -e
shopt -s nullglob


do_job()
{
    mkdir -p ${DESTPATH}
    for clear_files in ${SOURCEPATH}/*.{yml,yaml}
    do
        echo "INFO: File used for sealing: ./${clear_files}"
        write_file_name=$(echo ${clear_files} | rev | cut -d'/' -f 1 | rev)
        sops -e -i $clear_files 2>/dev/null || true
        sops -d ${clear_files} | kubeseal --format=yaml >${DESTPATH}/${write_file_name}
        echo "INFO: Sealed file written to : ${DESTPATH}/${write_file_name}"
    done
}

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -e|--env)
    ENVIRONMENT="${2}"
    shift # past argument
    shift # past value
    ;;
    -d|--destpath)
    DESTPATH="${2}"
    shift # past argument
    shift # past value
    ;;
    -s|--sourcepath)
    SOURCEPATH="${2}"
    shift # past argument
    shift # past value
    ;;
    -h|--help)
    HELP="1"
    shift # past argument
    shift # past value
    ;;
    --default)
    DEFAULT=YES
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


export SOURCEPATH="${SOURCEPATH}"

#echo "HELP    = ${HELP}"
#echo "Number files in SEARCH PATH with EXTENSION:" $(ls -1 "${SEARCHPATH}"/*."${SOURCEPATH}" | wc -l)

if [[ -n "${HELP}" ]] || [[ ! -n "${SOURCEPATH}" ]]; then
    echo "Usage:"
    echo "-s|--sourcepath :(Mandatory)To give the path to the source files"
    echo "-d|--destpath :(Optional: Default value:./sealed/<Cluster-name>/)To give the destination to the files to be copied"
    echo "-e|--env :(Optional Default value, current terminal k8s context)"
    exit 0
fi

ENVIRONMENT="${ENVIRONMENT}"
if [[ -n $ENVIRONMENT  ]]; then
    kubectl config use-context ${ENVIRONMENT}
    if [[ $? -ne 0 ]]; then
        echo "Error changing the context!"
        exit 1
    fi
    env_dir=$(echo $ENVIRONMENT|rev | cut -d'.' -f 3 | rev)
    echo "This is env_dir $env_dir"
else
    echo "Inside else $ENVIRONMENT"
    ENVIRONMENT=$(kubectl config current-context)
    env_dir=$(echo ${ENVIRONMENT}|rev | cut -d'.' -f 3 | rev)
fi


export DESTPATH="${DESTPATH:-${env_dir}}"
if [[ ${DESTPATH} == ${env_dir} ]]; then
    export DESTPATH=./sealed/${DESTPATH}
fi


if [[ -n "${SOURCEPATH}" ]]; then
    echo "SOURCE PATH (-s)  = ${SOURCEPATH}"
    echo "DESTINATION PATH (-d)    = ${DESTPATH}"
    echo "ENVIRONMENT (-e)    = ${ENVIRONMENT}"
    do_job

fi
