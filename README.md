# proxrsync

This is a script that lets you move files with rsync via a proxy server.

## Example use case

You're out in the wild with a laptop and you need to fetch or deposit files on a computer that doesn't have a public facing IP, but another computer on the same local network does (the proxy). So you need to move your files via that proxy. You could log into the proxy machine, copy the files from the target machine, then copy them to the laptop (or vice versa)...or you could use proxrsync.



## Prerequisites

Proxrsync uses ssh and rsync – otherwise it's just a bash script.

You _must_ set up an ssh access key between the proxy and remote machine, and unless you like typing your password 5 times in a row, you _should_ do it for access to the proxy machine as well.

proxrsync will create a directory `~/.proxrsync` on the proxy machine where files are stored temporarily (unless `-k` is set). It is necessary, therefore, that your user has a home directory and write privileges in that directory. 

### Installation: 

Download the script, and make it executable. That's it.

I would suggest using a bash alias to reference the script so you can use it from anywhere in your file system, as you would `rsync`. I use `pxrsync`.

### Usage


    usage: ./proxrsync.sh [options] [operation] [src] [proxy] [dest]

           options:    -h    help
                       -k    keep data on proxy server
                       -r    rsync options (no flag)

           operations: push    sends data to remote server
                       pull    gets data from remote server

     e.g.   ./proxrsync.sh -r vrut push .bash_aliases user@proxyurl.com user@192.168.0.2:/home/user


## Caveats

1. As of May 2022, I created this script because I needed the functionality. It seems to be working as it should, but I haven't tested it extensively. Use at your own risk!
2. I didn't escape all the variables for spaces. If you have spaces in your file system above the files you want to move (`/home/john doe's computer/`), you're gonna have a bad time. If you want to escape all the vars for spaces, go for it & submit a pull request.
