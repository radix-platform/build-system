#!/bin/bash

program=$0
pseudo_prefix=$(cd $(dirname $program)/.. ; pwd -P)/usr

shell=$1 ; shift ; option=$1 ; shift

enable_op_logging=
if [ "$ENABLE_PSEUDO_LOGGING" == "yes" ] ; then
  enable_op_logging=-l
fi

#
# remove extra spaces
#
args=`echo "${@}" | sed 's/ \{1,\}/ /g'`

${pseudo_prefix}/bin/pseudo ${enable_op_logging} -P ${pseudo_prefix} $shell $option "$args"
