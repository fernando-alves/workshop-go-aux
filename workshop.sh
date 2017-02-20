#!/bin/bash

set -e

FILESERVER_IP='10.72.20.240'
FILESERVER_BOX_URL="$FILESERVER_IP:8000/package.box"
GCE_BOX_URL="missing"

check_presence() {
  [[ -n `which $1` ]]
}

ensure_brew_is_installed() {
  if ! check_presence 'brew2' ; then
    echo "Ops! We need brew installed =("
    echo "Please execute the following command and try again:"
    echo '  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
    exit 1
  fi
}

install() {
  echo "Installing $1"
  `brew cask install $1`
}

install_if_not_present() {
  if check_presence $1 ; then
    echo "Found $1!"
  else
    install $1
  fi
}

install_dependencies() {
  ensure_brew_is_installed
  for dependency in virtualbox vagrant; do
    install_if_not_present $dependency
  done
}

fileserver_is_up() {
  [[ `ping -c 1 $FILESERVER_IP` ]]
}

download_box_from() {
  curl $1 -o /tmp/package.box
}

add_box_to_vagrant() {
  echo "Adding box to vagrant"
  vagrant box add /tmp/package.box --name gocd/2016-workshop
}

add_box() {
  if fileserver_is_up ; then
    echo "File server is up, uhuuul!"
    download_box_from $FILESERVER_BOX_URL
  else
    echo "File server is down, falling back to google cloud =("
    download_box_from $GCE_BOX_URL
  fi
  add_box_to_vagrant
}

install_dependencies
add_box
