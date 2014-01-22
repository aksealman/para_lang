#!/usr/bin/env python3
# pipeit.py
# Glenn G. Chappell
# 19 Dec 2013
# Example of pipe in Python 3.x using subprocess library
#
# For Python 2.x, replace function 'input' with 'raw_input'
# and eliminate the parentheses in print statements.

import sys         # for sys.stdin
import subprocess  # for subprocess.Popen, .PIPE


def send_fobj_to_command(f, cmdlist):
    """Given open file object, list w/ cmd & args, pipe file thru cmd.
    
    Example:
        with open(filename, 'r') as f:
            send_fobj_to_command(f, ["grep", "-i", "abc"])
    
    """
    try:
        # No "with"; Popen lacks context-manager support until Py3.2
        p = subprocess.Popen(cmdlist,
                             stdin=subprocess.PIPE,
                             universal_newlines=True)
        for line in f:
            line = line.rstrip("\r\n")
            p.stdin.write(line + "\n")
    finally:
        p.stdin.close()
        p.wait()            # Wait for command to terminate
        sys.stdout.flush()  # In case command produced output
        sys.stderr.flush()


# Note: Above, we pipe to a command, and the output of the command is
# simply displayed. To capture the output as a string, use the
# Popen.communicate member function (and watch out for deadlock!).
# See: http://docs.python.org/3/library/subprocess.html


def send_file_to_command(filename, cmdlist):
    """Given filename, list w/ cmd & args, pipe file thru cmd.

    Pipes std input if filename is "-" or empty string.

    See docs for function send_fobj_to_command for example cmdlist.

    """
    if filename == "-" or filename == "":
        f = sys.stdin
        send_fobj_to_command(f, cmdlist)
    else:
        with open(filename, 'r') as f:
            send_fobj_to_command(f, cmdlist)


if __name__ == "__main__":
    # Get a filename and pipe the file to the "sort" command
    # (No error handling)
    filename = input("Type input filename: ")
    # In Python 2.x, replace 'input' with 'raw_input' above
    #print("Piping file to the 'sort' command")
    send_file_to_command(filename, ["./trial"])

