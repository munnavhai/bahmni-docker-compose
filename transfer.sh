#!/usr/bin/env bash

IMG=$1
VERSION=$2
DEST=$3

if [ -z "${IMG}" ] || [ -z "${VERSION}" ] || [ -z "${DEST}" ]; then
  echo "usage: transfer.sh <image> <version> <host>"
  exit 1
fi

ARCHIVE=/tmp/${IMG}-${VERSION}.tar.7z

docker save localhost:5000/${IMG}:${VERSION} | 7za a -t7z -m0=lzma2 -ms=on -mx=9 -si ${ARCHIVE}

SAVE_RESULT=$?
if [ ${SAVE_RESULT} -ne 0 ]; then
  echo "Saving the docker image failed."
fi

eval $(ssh-agent)

DONE=1
while [ ${DONE} -ne 0 ]; do
  rsync --partial --delay-updates --progress --rsync-path="sudo rsync" -e "ssh -F $HOME/.ssh/config" ${ARCHIVE} ${DEST}:/opt/
  DONE=$?
done

ssh-agent -k

rm -f ${ARCHIVE}

