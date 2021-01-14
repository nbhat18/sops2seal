# sops2seal


```
$ ./sops2seal.sh -h
Usage:
-s|--sourcepath :(Mandatory)To give the path to the source files
-d|--destpath :(Optional: Default value:./sealed/<Cluster-name>/)To give the destination to the files to be copied
-e|--env :(Optional Default value, current terminal k8s context)

eg:

$ ./sops2seal.sh -s sonar-integration/secrets -d sonar-integration/ -e k8s-a.infra.ppro.com
Switched to context "k8s-a.infra.ppro.com".
This is env_dir infra
SOURCE PATH (-s)  = sonar-integration/secrets
DESTINATION PATH (-d)    = sonar-integration/
ENVIRONMENT (-e)    = k8s-a.infra.ppro.com
INFO: File used for sealing: ./sonar-integration/secrets/02-gitlab-secrets.yaml
INFO: Sealed file written to : sonar-integration//02-gitlab-secrets.yaml

```
