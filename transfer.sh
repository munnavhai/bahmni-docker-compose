#!/usr/bin/env bash

IMG=$1
VERSION=$2
DEST=$3
KEY=$4

if [ -z "${IMG}" ] || [ -z "${VERSION}" ] || [ -z "${DEST}" ] || [ -z "${KEY}" ]; then
  echo "usage: transfer.sh <image> <version> <host> <private_key>"
  exit 1
fi

ARCHIVE_NAME=${IMG}-${VERSION}.tar.7z
ARCHIVE=/opt/${ARCHIVE_NAME}

eval $(ssh-agent)
ssh-add "${KEY}"

if [ ! -f "${ARCHIVE}" ]; then
  docker save localhost:5000/${IMG}:${VERSION} | 7za a -t7z -m0=lzma2 -ms=on -mx=9 -si ${ARCHIVE}.tmp

  SAVE_RESULT=$?
  if [ ${SAVE_RESULT} -ne 0 ]; then
    echo "Saving the docker image failed."
    if [ -f ${ARCHIVE}.tmp ]; then
      rm -f ${ARCHIVE}.tmp
    fi
    exit 1
  fi
  
  mv ${ARCHIVE}.tmp ${ARCHIVE}
fi

DONE=1
while [ ${DONE} -ne 0 ]; do
  rsync --partial --delay-updates --progress --rsync-path="sudo rsync" -e "ssh -F $HOME/.ssh/config" ${ARCHIVE} ${DEST}:/opt/
  DONE=$?
  if [ ${DONE} -ne 0 ]; then
    sleep 30
  fi
done

ssh-agent -k

echo "Now run the following command on the receiving end:"
echo "  7za x -so /opt/${ARCHIVE_NAME} | docker load"
echo -e "\n"
echo "Delete the transferred image from /opt ?"
select DELETE in "Yes" "No"; do
  case ${DELETE} in
    Yes ) rm -rf ${ARCHIVE}; break;;
    No  ) break;;
  esac
done

