SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := up

PYTHON ?= python3
PORT ?= 8888
JUPYTER := .venv/bin/jupyter
SCRIPTS := scripts
export JUPYTER_RUNTIME_DIR := $(CURDIR)/.jupyter/runtime

.PHONY: setup up down init tables 

setup: .venv/.ready

.venv/.ready: requirements.txt
	$(PYTHON) -m venv .venv
	.venv/bin/python -m pip install -r requirements.txt
	touch $@

up: setup
	@mkdir -p "$$JUPYTER_RUNTIME_DIR"
	chmod 700 .jupyter "$$JUPYTER_RUNTIME_DIR"
	if [[ -n "$$($(JUPYTER) server list --json 2>/dev/null)" ]]; then
		echo "Jupyter is already running:"
		$(JUPYTER) server list
		exit 0
	fi
	nohup setsid $(JUPYTER) lab --no-browser --ip=127.0.0.1 --port=$(PORT) --port-retries=10 --ServerApp.root_dir="$(CURDIR)" > .jupyter/server.log 2>&1 < /dev/null &
	pid=$$!
	for attempt in {1..30}; do
		if [[ -n "$$($(JUPYTER) server list --json 2>/dev/null)" ]]; then
			echo "Jupyter is running. Open the URL below:"
			$(JUPYTER) server list
			exit 0
		fi
		if ! kill -0 "$$pid" 2>/dev/null; then
			cat .jupyter/server.log
			exit 1
		fi
		sleep 1
	done
	kill "$$pid" 2>/dev/null || true
	echo "Jupyter failed to become ready. See .jupyter/server.log."
	exit 1

down:
	@if [[ ! -x "$(JUPYTER)" ]]; then
		echo "Jupyter is already stopped."
		exit 0
	fi
	ports=$$($(JUPYTER) server list --json 2>/dev/null | .venv/bin/python -c 'import json, sys; [print(json.loads(line)["port"]) for line in sys.stdin if line.strip()]')
	if [[ -z "$$ports" ]]; then
		echo "Jupyter is already stopped."
	else
		for port in $$ports; do
			$(JUPYTER) server stop "$$port"
		done
	fi

init:
	./$(SCRIPTS)/init.sh

tables:	
	./$(SCRIPTS)/check_tables.sh