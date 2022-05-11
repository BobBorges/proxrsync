#!/bin/bash
date=`date '+%F_%H-%M-%S'`
display_help () {
    echo ""
    echo " Uses rsync to move files via a proxy server."
    echo ""
    echo " usage: ./proxrsync.sh [options] [operation] [src] [proxy] [dest]"
    echo ""
    echo "       options:    -h    help"
    echo "                   -k    keep data on proxy server"
    echo "                   -r    rsync options (no hyphen)"
    echo ""
    echo "       operations: push    sends data to remote server"
    echo "                   pull    gets data from remote server"
    echo ""
    echo " e.g.   ./proxrsync.sh -r vrut push .bash_aliases user@proxyurl.com user@192.168.0.2:/home/user" 
    echo ""
}

keep_bool () {
    keepOnProxy="true"
}

PUSH () {
    push_src=$1
    push_prox=$2
    push_dest=$3
    syncopts=$4
    
    echo "...checking if you have a ~/.proxrsync dir on your proxy machine..."
    if ssh $push_prox "[ -d ~/.proxrsync ]" ; then
        echo  "    ~/.proxrsync/ exists on proxy"
    else
        echo "    Nie ma..."
        echo "    ...making ~/.proxrsync/ on proxy"
        ssh $push_prox "mkdir ~/.proxrsync"
    fi

    echo "...moving $push_src to proxy server"
    if [ -z $syncopts ] ; then
        rsync $push_src $push_prox:~/.proxrsync/$date/
    else
        rsync -$syncopts $push_src $push_prox:~/.proxrsync/$date/
    fi

    echo "...moving $push_src to destination"
    if [ -z $syncopts ] ; then
        ssh $push_prox "rsync ~/.proxrsync/$date/ $push_dest" 
    else 
        ssh $push_prox "rsync -$syncopts ~/.proxrsync/$date/ $push_dest" 
    fi

    if [[ $keepOnProxy != "true" ]] ; then
        echo "...removing data from proxy server"
        ssh $push_prox "rm -rf ~/.proxrsync/$date"
    else
        echo "...leaving data on proxy server"
    fi
}

PULL () {
    pull_src=$1
    pull_prox=$2
    pull_dest=$3
    syncopts=$4

    echo "...checking if you have a ~/.proxrsync dir on your proxy machine..."
    if ssh $pull_prox "[ -d ~/.proxrsync ]" ; then
        echo  "    ~/.proxrsync/ exists on proxy"
    else
        echo "    Nie ma..."
        echo "    ...making ~/.proxrsync/ on proxy"
        ssh $pull_prox "mkdir ~/.proxrsync"
    fi

    echo "...moving files from remote to proxy"
    if [ -z $syncopts ] ; then
        ssh $pull_prox "rsync $pull_src ~/.proxrsync/$date/ " 
    else 
        ssh $pull_prox "rsync -$syncopts $pull_src ~/.proxrsync/$date/" 
    fi

    echo "...moving files from proxy server to $pull_dest"

    if [ -z $syncopts ] ; then
        rsync $pull_prox:~/.proxrsync/$date/ $pull_dest
    else
        rsync -$syncopts $pull_prox:~/.proxrsync/$date/ $pull_dest
    fi

    if [[ $keepOnProxy != "true" ]] ; then
        echo "...removing data from proxy server"
        ssh $pull_prox "rm -rf ~/.proxrsync/$date"
    else
        echo "...leaving data on proxy server"
    fi
}

while getopts ":h:r:k" flag; do
case $flag in
    h) # HELP
        display_help
        exit;;
    r) # rsync flags
        rsyncOpts=$OPTARG;;
    k) # keep copy on proxy
        keep_bool;;
    \?) # invalid option
        echo "Dafuq? Invalid option..."
        display_help
        exit;;
    esac
done

OPERATION=${@:$OPTIND:1}
SRC=${@:$OPTIND+1:1}
PROXY=${@:$OPTIND+2:1}
DEST=${@:$OPTIND+3:1}

if [ -z $OPERATION ] ; then
    #echo "Wrong nr positional args - 1"
    display_help
    exit
else
    echo "OK, here we go..."
    sleep 0.5
    echo "Operation is set: $OPERATION"
fi

sleep 0.5
if [ -z $SRC ] ; then
    #echo "Wrong nr positional args - 2"
    display_help
    exit
else
    echo "Source is set: $SRC"
fi

sleep 0.5
if [ -z $PROXY ] ; then
    #echo "Wrong nr positional args - 3"
    display_help
    exit
else
    echo "Proxy is set: $PROXY"
fi

sleep 0.5
if [ -z $DEST ] ; then
    #echo "Wrong nr positional args - 4"
    display_help
    exit
else
    echo "Destination is set: $DEST"
fi
sleep 0.5
echo "So far so good"
sleep 0.5
echo ""
echo "Już"
echo ""
sleep 0.5

if  [ $OPERATION == "push" ] ; then
    echo "Pushing"
    PUSH $SRC $PROXY $DEST $rsyncOpts
elif [ $OPERATION == "pull" ] ; then
    echo "Pulling"
    PULL $SRC $PROXY $DEST $rsyncOpts
else
    echo "Invalid Operation ($OPERATION) : must be \"push\" or \"pull\""
    exit
fi

