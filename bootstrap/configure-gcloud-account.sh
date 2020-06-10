#!/bin/sh

CONFIG_NAME="swamp"
PROJECT_NAME="sawmp"

gcloud config configurations create $CONFIG_NAME

gcloud config configurations activate $CONFIG_NAME

gcloud auth login	#	log into service account for project

gcloud config set project $PROJECT_NAME

