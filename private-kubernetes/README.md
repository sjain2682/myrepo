This Repo contains Docker containers, YAML , and support files to deploy MapR in K8S.

Folders include:
- build - Contains all Docker Images
	- base - Various Mapr base docker images (base, baseubuntu, etc.)
	- core - Product container docker images (zk, cldb, mfs, etc.)
	- clients - PACC images
	- drill - Drill Images
	- ecosystem - Ecosystem Images (tez, hue, oozie etc.)
	- hive - Hive Images (metastore, webhcat, etc)
	- spark - Spark Images (master, worker, history, zepplin, livy, etc.)
	- yarn - Yarn Images (nodemanger, resourcemanager, historyserver, etc.)
- deploy - Contains Various Kubernetes components
	- config - Various Kubernetes YAML files
	- demo - demo scripts to start k8s clusters
