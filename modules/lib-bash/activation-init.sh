#!/usr/bin/env bash

function setupVars() {
    local profilesPath="/nix/var/nix/profiles/per-user/$USER"
    local gcPath="/nix/var/nix/gcroots/per-user/$USER"

    genProfilePath="$profilesPath/home-manager"
    newGenPath="@GENERATION_DIR@";
    newGenGcPath="$gcPath/current-home"

    local greatestGenNum
    greatestGenNum=$( \
        nix-env --list-generations --profile "$genProfilePath" \
            | tail -1 \
            | cut -f2 -d' ')

    if [[ -n $greatestGenNum ]] ; then
        oldGenNum=$greatestGenNum
        newGenNum=$((oldGenNum + 1))
    else
        newGenNum=1
    fi

    if [[ -e $profilesPath/home-manager ]] ; then
        oldGenPath="$(readlink -e "$profilesPath/home-manager")"
    fi

    $VERBOSE_ECHO "Sanity checking oldGenNum and oldGenPath"
    if [[ -v oldGenNum && ! -v oldGenPath
            || ! -v oldGenNum && -v oldGenPath ]]; then
        errorEcho "Invalid profile number and current profile values! These"
        errorEcho "must be either both empty or both set but are now set to"
        errorEcho "    '${oldGenNum:-}' and '${oldGenPath:-}'"
        errorEcho "If you don't mind losing previous profile generations then"
        errorEcho "the easiest solution is probably to run"
        errorEcho "   rm $profilesPath/home-manager*"
        errorEcho "   rm $gcPath/current-home"
        errorEcho "and trying home-manager switch again. Good luck!"
        exit 1
    fi
}

if [[ -v VERBOSE ]]; then
    export VERBOSE_ECHO=echo
    export VERBOSE_ARG="--verbose"
else
    export VERBOSE_ECHO=true
    export VERBOSE_ARG=""
fi

echo "Starting home manager activation"

setupVars

if [[ -v DRY_RUN ]] ; then
    echo "This is a dry run"
    export DRY_RUN_CMD=echo
else
    $VERBOSE_ECHO "This is a live run"
    export DRY_RUN_CMD=""
fi

if [[ -v VERBOSE ]]; then
    echo -n "Using Nix version: "
    nix-env --version
fi

$VERBOSE_ECHO "Activation variables:"
if [[ -v oldGenNum ]] ; then
    $VERBOSE_ECHO "  oldGenNum=$oldGenNum"
    $VERBOSE_ECHO "  oldGenPath=$oldGenPath"
else
    $VERBOSE_ECHO "  oldGenNum undefined (first run?)"
    $VERBOSE_ECHO "  oldGenPath undefined (first run?)"
fi
$VERBOSE_ECHO "  newGenPath=$newGenPath"
$VERBOSE_ECHO "  newGenNum=$newGenNum"
$VERBOSE_ECHO "  newGenGcPath=$newGenGcPath"
$VERBOSE_ECHO "  genProfilePath=$genProfilePath"
