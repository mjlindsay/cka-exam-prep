#!/bin/bash
source ../.env
envsubst < ./encryption-config-template.yaml > encryption-config.yaml