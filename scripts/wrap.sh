#!/bin/bash

set -e  # exit on any error

# determine rootdir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
ROOTDIR="$(dirname $DIR)"

LUAMIN="luamin"
if ! which $LUAMIN 1> /dev/null; then
    LUAMIN="${ROOTDIR}/scripts/node_modules/.bin/luamin"
fi
if ! which $LUAMIN 1> /dev/null; then
    echo "Need luamin in PATH (do \`npm install -g luamin\` or run \`npm install\` from the scripts/ folder)"; exit 1
fi

# We expect this file to be run from the <repo>/scripts directory
LUA_SRC=${ROOTDIR}/src/ButtonHUD.lua
CONF_DST=${ROOTDIR}/ButtonHUD.conf

WORK_DIR=${ROOTDIR}/scripts/work

# Make a fresh work dir
(rm -rf $WORK_DIR || true) && mkdir -p $WORK_DIR

# Extract the exports because the minifier will eat them.
grep "\-- \?export:" $LUA_SRC | sed -e 's/^[ \t]*/        /' -e 's/-- export:/--export:/' > $WORK_DIR/ButtonHUD.exports
VERSION_NUMBER=`grep "VERSION_NUMBER = .*" $LUA_SRC | sed -E "s/\s*VERSION_NUMBER = (.*)/\1/"`

if [[ "${VERSION_NUMBER}" == "" ]]; then
    echo "Failed to detect version number"; exit 1
fi

sed "/-- \?export:/d" $LUA_SRC > $WORK_DIR/ButtonHUD.extracted.lua

# Minify the lua
if [[ "$1" == "true" ]]; then
    echo "Minifying ... "
    # using stdin pipe to avoid a bug in luamin complaining about "No such file: ``"
    echo "$WORK_DIR/ButtonHUD.extracted.lua" | $LUAMIN --file > $WORK_DIR/ButtonHUD.min.lua
else
    cp $WORK_DIR/ButtonHUD.extracted.lua $WORK_DIR/ButtonHUD.min.lua
fi

# Wrap in AutoConf
SLOTS=(
    core:class=CoreUnit
    radar:class=RadarPVPUnit,select=manual
    antigrav:class=AntiGravityGeneratorUnit
    warpdrive:class=WarpDriveUnit
    gyro:class=GyroUnit
    weapon:class=WeaponUnit,select=manual
    dbHud:class=databank
    vBooster:class=VerticalBooster
    hover:class=Hovercraft
    door:class=DoorUnit,select=manual
    forcefield:class=ForceFieldUnit,select=manual
    atmofueltank:class=AtmoFuelContainer,select=manual
    spacefueltank:class=SpaceFuelContainer,select=manual
    rocketfueltank:class=RocketFuelContainer,select=manual
)

echo "Wrapping ..."
lua ${ROOTDIR}/scripts/wrap.lua --handle-errors --output yaml \
             --name "ButtonsHud - Dimencia and Archaegeo v$VERSION_NUMBER (Minified)" \
             $WORK_DIR/ButtonHUD.min.lua $WORK_DIR/ButtonHUD.wrapped.conf \
             --slots ${SLOTS[*]}

# Re-insert the exports
sed "/script={}/e cat $WORK_DIR/ButtonHUD.exports" $WORK_DIR/ButtonHUD.wrapped.conf > $CONF_DST

# Fix up minified L_TEXTs which requires a space after the comma
sed -i -E 's/L_TEXT\(("[^"]*"),("[^"]*")\)/L_TEXT(\1, \2)/g' $CONF_DST

echo "$VERSION_NUMBER" > ${ROOTDIR}/ButtonHUD.conf.version

echo "Compiled v$VERSION_NUMBER at ${CONF_DST}"
