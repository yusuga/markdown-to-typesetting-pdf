# Environment variable

MAKEFILE_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
MAKEFILE_PATH := $(MAKEFILE_DIR)/Makefile
BOOK_DIR := $(MAKEFILE_DIR)/book
VIVLIOSTYLE_WORKSPACE_DIR := $(BOOK_DIR)/.vivliostyle
OUTPUT_DIR := $(BOOK_DIR)/output
BOOK_PATH := $(OUTPUT_DIR)/ebook.pdf

## https://github.com/vivliostyle/vivliostyle-cli/pkgs/container/cli
VIVLIOSTYLE_CLI_IMAGE_NAME := ghcr.io/vivliostyle/cli
VIVLIOSTYLE_CLI_IMAGE_TAG := 6.1.0

ALL_DOCKER_IMAGES := $(VIVLIOSTYLE_CLI_IMAGE_NAME)

DOCKER = \
  @$(MAKE) prepare_docker; \
  $(shell command -v docker)

VIVLIOSTYLE_CLI = $(DOCKER) run \
  --rm \
  -v $(BOOK_DIR):/local \
  -w /local \
  $(VIVLIOSTYLE_CLI_IMAGE_NAME):$(VIVLIOSTYLE_CLI_IMAGE_TAG) \

# Commands

default: help

.PHONY: help
help:
	@## コマンド名とその直前のコメント行が出力されます。
	@## @see https://stackoverflow.com/a/35730928
	@awk '/^#/{c=substr($$0,3);next}c&&/^[[:alpha:]][[:alnum:]_-]+:/{print substr($$1,1,index($$1,":")),c}1{c=0}' $(MAKEFILE_LIST) | column -s: -t

.PHONY: all
## pdfを生成して開く
all: \
  pdf \
  open

.PHONY: pdf
## pdfを生成
pdf:
	$(VIVLIOSTYLE_CLI) build \
		--no-sandbox

.PHONY: pdf_press
## プレス版のpdfを生成
pdf_press:
	$(VIVLIOSTYLE_CLI) build \
		--no-sandbox \
		--press-ready \
		--preflight-option gray-scale

.PHONY: open
## pdfを開く
open:
	open $(BOOK_PATH)

.PHONY: clean
## 生成ファイルをすべて削除
clean:
	rm -rf $(VIVLIOSTYLE_WORKSPACE_DIR)
	rm -rf $(OUTPUT_DIR)
	@if command -v colima >/dev/null 2>&1; then \
		$(MAKE) stop_colima; \
	fi

# Internal Commands

.PHONY: check_brew
check_brew:
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "brewをインストールする必要があります。 https://brew.sh/index_ja"; \
		exit 1; \
	fi

.PHONY: install_docker
install_docker:
	@if ! command -v colima >/dev/null 2>&1; then \
		brew install docker; \
	fi

.PHONY: install_colima
install_colima:
	@if ! command -v colima >/dev/null 2>&1; then \
		brew install colima; \
	fi

.PHONY: start_colima
start_colima:
	@if [ $$(colima status 2>&1 | grep -c "not running") -eq 1 ]; then \
		colima start; \
	fi

.PHONY: stop_colima
stop_colima:
	colima stop

.PHONY: prepare_docker
prepare_docker: \
  check_brew \
  install_docker \
  install_colima \
  start_colima
