#!/bin/sh

if git diff --quiet HEAD main -- docs/src; then
  echo ''
  echo '######################'
  echo '# docs/src unchanged #'
  echo '######################'
  echo ''
else
  echo ''
  echo '####################'
  echo '# docs/src changed #'
  echo '####################'

  echo '  checking for change to index.html'
  echo ''

  if git diff --quiet HEAD main -- lib/feature_map/private/docs/index.html; then
    echo '  ###########'
    echo '  # failure #'
    echo '  ###########'

    echo '    please run `npm run build` within the `docs/`` directory'
    echo '    and commit lib/feature_map/private/docs/index.html'
    exit 1
  else
    echo '###########'
    echo '# success #'
    echo '###########'

    echo '    thank you!'
    exit 0
  fi
fi
