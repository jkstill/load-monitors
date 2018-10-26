#!/bin/bash

: << 'COMMENT'

  Get the email progrem, mail or mailx
  return /bin/cat if not available

  if a mailer is not found, the cat program will be returned
  in this case that is fine, as the calling script will simple echo the output rather than mailing it

  default for cat is 'cat'
  while it would be best if we find the path to cat, 'cat' will be used in case it is not found

COMMENT

CAT=$(./hard-path.sh cat)

# this should not happen, but just in case
[[ $CAT == 'NA' ]] && { 
	CAT='cat ' 
}


#echo CAT: $CAT

# simple, just look in the likely places - mailx gets precedence

MAILER=$(./hard-path.sh mailx)

[[ $MAILER == 'NA' ]] && { 
	MAILER=$(./hard-path.sh mail)
}

if [[ $MAILER == 'NA' ]]; then
	MAILER="$CAT "
else
	MAILER="$MAILER -s "
fi

echo $MAILER

