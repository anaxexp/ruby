# Ruby Docker Container Images

[![Build Status](https://travis-ci.com/anaxexp/ruby.svg?branch=master)](https://travis-ci.com/anaxexp/ruby)
[![Docker Pulls](https://img.shields.io/docker/pulls/anaxexp/ruby.svg)](https://hub.docker.com/r/anaxexp/ruby)
[![Docker Stars](https://img.shields.io/docker/stars/anaxexp/ruby.svg)](https://hub.docker.com/r/anaxexp/ruby)
[![Docker Layers](https://images.microbadger.com/badges/image/anaxexp/ruby.svg)](https://microbadger.com/images/anaxexp/ruby)

## Table of Contents

* [Docker Images](#docker-images)
* [Environment Variables](#environment-variables)
* [Build arguments](#build-arguments)    
* [`-dev` images](#-dev-images)
* [`-dev-macos` images](#-dev-macos-images)
* [Users and permissions](#users-and-permissions)
* [Orchestration Actions](#orchestration-actions)

## Docker Images

❗For better reliability we release images with stability tags (`anaxexp/ruby:3.6-X.X.X`) which correspond to [git tags](https://github.com/anaxexp/ruby/releases). We strongly recommend using images only with stability tags. 

About images:

* All images are based on Alpine Linux
* [Travis CI builds](https://travis-ci.com/anaxexp/ruby) 
* [Docker Hub](https://hub.docker.com/r/anaxexp/ruby) 
* [`-dev`](#-dev-images) and [`-debug`](#-debug-images) images have a few differences

Supported tags and respective `Dockerfile` links:

* `2.5`, `2`, `latest` [_(Dockerfile)_](https://github.com/anaxexp/ruby/tree/master/Dockerfile)
* `2.4` [_(Dockerfile)_](https://github.com/anaxexp/ruby/tree/master/Dockerfile)
* `2.3` [_(Dockerfile)_](https://github.com/anaxexp/ruby/tree/master/Dockerfile)
* `2.5-dev`, `2-dev` [_(Dockerfile)_](https://github.com/anaxexp/ruby/tree/master/Dockerfile)
* `2.4-dev` [_(Dockerfile)_](https://github.com/anaxexp/ruby/tree/master/Dockerfile)
* `2.3-dev` [_(Dockerfile)_](https://github.com/anaxexp/ruby/tree/master/Dockerfile)
* `2.5-dev-macos`, `2-dev-macos` [_(Dockerfile)_](https://github.com/anaxexp/ruby/tree/master/Dockerfile)
* `2.4-dev-macos` [_(Dockerfile)_](https://github.com/anaxexp/ruby/tree/master/Dockerfile)
* `2.3-dev-macos` [_(Dockerfile)_](https://github.com/anaxexp/ruby/tree/master/Dockerfile)

## Environment Variables

| Variable                          | Default value       |
| --------------------------------- | ------------------- |
| `GIT_USER_EMAIL`                  | `anaxexp@example.com` |
| `GIT_USER_NAME`                   | `anaxexp`             |
| `GUNICORN_BACKLOG`                | `2048`              |
| `GUNICORN_WORKERS`                | `4`                 |
| `GUNICORN_WORKER_CLASS`           | `sync`              |
| `GUNICORN_WORKER_CONNECTIONS`     | `1000`              |
| `GUNICORN_TIMEOUT`                | `30`                |
| `GUNICORN_KEEPALIVE`              | `2`                 |
| `GUNICORN_SPEW`                   | `False`             |
| `GUNICORN_USER`                   | `www-data`          |
| `GUNICORN_GROUP`                  | `www-data`          |
| `GUNICORN_LOGLEVEL`               | `info`              |
| `GUNICORN_PROC_NAME`              | `Gunicorn`          |
| `SSH_PRIVATE_KEY`                 |                     |
| `SSH_DISABLE_STRICT_KEY_CHECKING` |                     |
| `SSHD_GATEWAY_PORTS`              | `no`                |
| `SSHD_HOST_KEYS_DIR`              | `/etc/ssh`          |
| `SSHD_LOG_LEVEL`                  | `INFO`              |
| `SSHD_PASSWORD_AUTHENTICATION`    | `no`                |
| `SSHD_PERMIT_USER_ENV`            | `no`                |
| `SSHD_USE_DNS`                    | `yes`               |

## Build arguments

| Argument         | Default value |
| ---------------- | ------------- |
| `RUBY_DEV`       |               |
| `ANAXEXP_GROUP_ID` | `1000`        |
| `ANAXEXP_USER_ID`  | `1000`        |

Change `ANAXEXP_USER_ID` and `ANAXEXP_GROUP_ID` mainly for local dev version of images, if it matches with existing system user/group ids the latter will be deleted. 

## `-dev` Images

Images with `-dev` tag have `sudo` allowed for all commands for `anaxexp` user

## `-dev-macos` Images

Same as `-dev` but the default user/group `anaxexp` has uid/gid `501`/`20`  to match the macOS default user/group ids.

## Users and permissions

Default container user is `anaxexp:anaxexp` (UID/GID `1000`). Gunicorn runs from `www-data:www-data` user (UID/GID `82`) by default. User `anaxexp` is a part of `www-data` group.

Codebase volume `$APP_ROOT` (`/usr/src/app`) owned by `anaxexp:anaxexp`. Files volume `$FILES_DIR` (`/mnt/files`) owned by `www-data:www-data` with `775` mode.

#### Helper scripts 

* `files_chmod` – in case you need write access for `anaxexp` user to a file/dir generated by `www-data` on this volume run `sudo files_chmod [FILEPATH]` script (FILEPATH must be under `/mnt/files`), it will recursively change the mode to `ug=rwX,o=rX`

* `files_chown` – in case you manually uploaded files under `anaxexp` user to files volume and want to change the ownership of those files to `www-data` run `sudo files_chown [FILEPATH]` script (FILEPATH must be under `/mnt/files`), it will recursively change ownership to `www-data:www-data`

## Orchestration Actions

Usage:
```
make COMMAND [params ...]

commands:
    migrate
    check-ready [host max_try wait_seconds delay_seconds]
    files-import source
    files-link public_dir 
```
