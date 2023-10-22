#!/bin/sh
#
# Running a verification server will greatly improve performance
# of linting (using hhast-lint) and testing (using hacktest).
# Usage:
#  - Start a webserver at the repo root.
#  - Run `bin/verify.sh --skip-hh-client-linter`.
#  - You must run this script from the repo root (don't cd to bin).
#
# THIS SCRIPT WON'T WORK FOR YOU OUT OF THE BOX.
#
# I have needed to make two changes to vendor/facebook/hh-clilib.
#
# In src/CLIBase.hack
#   Find: `HH\global_get('argv')`.
#   Replace:
#     If it is a vec<_>, it's fine. (Running from an actual CLI.)
#     Else
#       Grab \HH\global_get('_GET') and vecify it.
#       Concat a single string in front (a made up binary name).
#     Give this result to the Responder.
#
# In src/Terminal.hack
#   Find: `\posix_isatty(\STDIN)` and friends.
#   Add:
#     Check `\defined('STDIN')` and `\defined('STDOUT')`.
#     If either is false, return false.
#
# You should now be able to spin up a linting+testing server like so:
#   `hhvm -m server -p 8080`
# Optional flags to pass to hhvm:
#  - `-vServer.AllowRunAsRoot=1` if running as the root user.
#  - `-dhhvm.jit_retranslate_all_seconds=30` to reduce the jit warmup time.
#
# Then run verify.sh to get both your test and lint errors.

PORT=8080
BASE_URI="http://localhost:$PORT/vendor/hhvm"
HACKTEST_URI="$BASE_URI/hacktest/bin/hacktest.hack?0"
HHAST_URI="$BASE_URI/hhast/bin/hhast-lint.hack?0=--config-file"

echo -n " - Testing: "
curl --silent "$HACKTEST_URI=../../../../tests"

if [ "$1" = "--skip-hh-client-linter" ]; then
  cat ./hhast-lint.json | sed /HHClientLinter/d > ./hhast-lint.deleteme.json
  echo -n " - Linting (skipping HHClientLinter): "
else
  cp ./hhast-lint.json ./hhast-lint.deleteme.json
  echo -n " - Linting: "
fi

curl --silent "$HHAST_URI=../../../../hhast-lint.deleteme.json"
rm ./hhast-lint.deleteme.json