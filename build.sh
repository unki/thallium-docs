#!/bin/bash

APIGEN="/usr/bin/apigen"
#APIGEN="strace -f -s 256 /usr/bin/apigen"

DIRNAME=$(dirname $0)
DIRNAME=$(realpath ${DIRNAME})
GITREPO="http://git.netshadow.net/thallium.git"
GITORIGIN="devel"

OUTPUT="${DIRNAME}/docs"
TITLE="Thallium API Documentation"
SOURCE="${DIRNAME}/$(basename ${GITREPO} .git)"

if [ ! -d ${OUTPUT} ]; then
   if [ -f ${OUTPUT} ]; then
      echo "${OUTPUT} already exists!"
      exit 1
   fi
   mkdir ${OUTPUT}
fi

if [ ! -d ${SOURCE} ]; then
   if [ -f ${SOURCE} ]; then
      echo "${SOURCE} already exists!"
      exit 1
   fi
   pushd ${DIRNAME} >/dev/null
   git clone -q ${GITREPO}
   popd >/dev/null

   if [ ! -d ${SOURCE} ] || [ ! -d ${SOURCE}/.git ]; then
      echo "git-clone on ${GITREPO} failed!"
      exit 1
   fi
fi

pushd ${SOURCE} >/dev/null
git fetch -q ${GITORIGIN}
git rebase -q -s recursive -X ours ${GITORIGIN}/master
popd >/dev/null

${APIGEN} \
   generate \
   --debug \
   --source="${SOURCE}" \
   --destination="${OUTPUT}" \
   --title="${TITLE}" \
   --todo \
   --tree \
   --template-theme="bootstrap"

RETVAL=$?

if [ "x${RETVAL}" != "x0" ]; then
   echo "${APIGEN} exited with exit code ${RETVAL}!"
   exit 1
fi

DATE=$(date)
git add ${OUTPUT}
git commit -q -m "commit docs from run ${DATE}" ${OUTPUT}
