# Printing

Printing within the CSU CS Department is overseen by SNA.

To use the SNA printers, you can follow the directions over at their website:

[SNA's Printer Info](https://sna.cs.colostate.edu/printing/)

There is more granularity with the `lp` command and the CUPS system within the 
department computers than what's exposed here, but I really wanted a script
that could do a quick print without having to think too much about it.

Moreover, some of the limitations of `lp` aren't intuitive unless you have some
previous experience. For instance, you can only send over PDF, PostScript, and 
plain text whereas the typical print experience allows you to send over just
about anything and the service will figure it out.

So, `printcs.sh` was born.

`printcs.sh` does the following in a normal run:
- Verifies the file is a supported type.
- Verifies the host you've selected exists and is known to your machine
- Provides a selection of printers
- Connects to selected host (default albany) three times
    - First, initialize the `~/.printcache` directory if it's not already been
    done
    - Second, copy your selected file over to the `~/.printcache` directory
    - Third, queues the file for print on the selected printer and establishes
    a job on the machine to delete the file in 10 minutes time.

I will try to update this as I run into issues. I tried my best to manufacture
a lot of the issues and edge cases, but I'd really love some feedback if you
run into problems yourself.

Shoot me an email at `adalaza@cs.colostate.edu`, or feel free to create a PR!

(P.S. don't yell at me if SNA gets on your case about too many prints)

Rye