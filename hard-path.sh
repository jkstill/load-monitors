#!/bin/bash

: << 'COMMENT'

  given a path, return the fully pathed command
  return NA if not available.

  the calling program should probably abort if NA is returned.

COMMENT

cmdToFind=$1

fqpCmd='NA'

for path in /usr/bin /bin /sbin /usr/sbin /usr/local/bin /opt/local/bin /opt/share/bin
do
	if [[ -x ${path}/${cmdToFind} ]]; then
		fqpCmd=${path}/${cmdToFind}
		break
	fi
done

echo $fqpCmd


