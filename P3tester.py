#!/usr/bin/env python2.7

# Tester for P3 of CMSC 313, Spring 2017, Sections 01, 02
# by David Pan and Jorge Teixeira (jt11@umbc.edu)
# Student version 0.9.1

# Needs sys, pwntools, (c)StringIO
import sys
from pwn import *
try:	from cStringIO import StringIO
except:	from StringIO import StringIO

def main():
	if ((len(sys.argv) != 2) and (len(sys.argv) != 3)):
		print "Aborting: missing mandatory argument or, too many arguments.\nTo run this script: python2 ./P3tester.py ./yourexecutable [--nocolors]"
		sys.exit()
	usec = ansitermcolors
	if ((len(sys.argv) == 3) and (sys.argv[2] == "--nocolors")):
		usec = nocolors
	ye = sys.argv[1]
	# Add your executable name here (use absolute or relative paths as appropriate)
	#ye = "./YourUMBCID.exe"
	runtest( ye, usec )

#                           /   \
# _                 )      ((   ))     (
#(@)               /|\      ))_((     /|\             _
#|-|`\            / | \    (/\|/\)   / | \           (@)
#| |-------------/--|-voV---\'|`/--Vov-|--\----------|-|
#|-|                  '^`   (o o)  '^`               | |
#| |                        `\Y/'                    |-|
#|-|                                                 | |
#| |                CAVEAT DISCIPULUS                |-|
#|-|                                                 | |
#| |   V----------- HIC SVNT DRACONES -----------V   |-|
#|-|                                                 | |
#|_|_________________________________________________|-|
#(@)       l   /\ /         ( (       \ /\   l     `\|_|
#          l /   V           \ \       V   \ l       (@)
#          l/                _) )_          \I
#                            `\ /'
#                              `

# All tests return 0 on success, 1 on failure
def check0(astring):	# Test 0: O wins, no mine explosions
	return (0 if (("Player O wins!" in astring) and not ("@|" in astring or "|@" in astring or "!|" in astring or "|!" in astring)) else 1)

def check1(astring):	# Test 1: X wins, no mine explosions
	return (0 if (("Player X wins!" in astring) and not ("@|" in astring or "|@" in astring or "!|" in astring or "|!" in astring)) else 1)

def check2(astring):	# Test 2: Mine X explodes, mine O is revealed
	return (0 if (("!|" in astring or "|!" in astring) and ("2|" in astring or "|2" in astring)) else 1)

def check3(astring):	# Test 3: Mine O explodes, mine X is revealed
	return (0 if (("@|" in astring or "|@" in astring) and ("1|" in astring or "|1" in astring)) else 1)

def check4(astring):	# Test 4: Tie
	return (0 if ("It's a draw (tie)!" in astring) else 1)

def check5(astring):	# Test 5: Mine X explodes, mine O overlaps it
        return (0 if ("!|" in astring or "|!" in astring) else 1)

def check6(astring):	# Test 6: Mine O explodes, mine X overlaps it
        return (0 if ("@|" in astring or "|@" in astring) else 1)

def check7(astring):	# Test 7: Player O wins, mines overlap, neither exploded
	return (0 if (("Player O wins!" in astring) and ("3|" in astring or "|3" in astring or "|1" in astring or "|2" in astring or "1|" in astring or "2|" in astring)) else 1)

def check8(astring):	# Test 8: Player X wins, mines overlap, neither exploded
	return (0 if (("Player X wins!" in astring) and ("3|" in astring or "|3" in astring or "|1" in astring or "|2" in astring or "1|" in astring or "2|" in astring)) else 1)

# Dictionary of test functions
fun_dict = { '0': check0, '1': check1, '2': check2, '3': check3, '4': check4, '5': check5, '6': check6, '7': check7, '8': check8 }
# Dictionary of expected results
exp_dict = {'0': "O wins, no mine explosions", '1': "X wins, no mine explosions", '2': "Mine X explodes, mine O is revealed", '3': "Mine O explodes, mine X is revealed", '4': "Tie", '5': "Mine X explodes overlapping mine O", '6': "Mine O explodes overlapping mine X",'7': "Player O wins, mines overlap, neither exploded", '8':"Player X wins, mines overlap, neither exploded"}


# Actual tests, one per line, with expected result at the end (see above dictionary)
ta = r'''n\n3\n3\n5\n0\n1\n2\n4\n8\n7\n0
n\n3\n2\n4\n0\n1\n2\n4\n8\n7\n0
n\n3\n8\n8\n0\n1\n2\n4\n8\n6
n\n3\n7\n7\n0\n1\n2\n4\n8\n7\n5
n\n3\n5\n4\n0\n1\n2\n8\n7\n6\n3\n4\n5\n4
n\n3\n5\n7\n0\n2\n1\n4\n8\n7\n3\n5\n2
n\n3\n6\n8\n0\n1\n2\n3\n4\n5\n7\n8\n6\n1
n\n3\n5\n5\n0\n3\n1\n4\n2\n1
n\n3\n4\n4\n0\n3\n1\n4\n5
n\n3\n1\n1\n0\n3\n6\n4\n7\n5\n7
n\n3\n4\n4\n8\n0\n1\n7\n2\n6\n3\n5\n4\n6
n\n4\n4\n5\n0\n1\n2\n3\n6\n7\n10\n15\n14\n8
n\n4\n12\n12\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n11\n12\n6
n\n4\n14\n14\n0\n2\n4\n6\n8\n10\n12\n8
n\n4\n10\n10\n0\n2\n4\n6\n8\n10\n5
n\n4\n11\n12\n0\n2\n5\n7\n8\n10\n13\n15\n1\n3\n4\n6\n14\n9\n11\n12\n0
n\n4\n12\n12\n0\n2\n5\n7\n8\n10\n13\n15\n1\n3\n4\n6\n14\n9\n11\n12\n5
n\n4\n11\n11\n0\n2\n5\n7\n8\n10\n13\n15\n1\n3\n4\n6\n14\n9\n11\n6
n\n4\n3\n14\n0\n6\n1\n2\n10\n5\n4\n12\n9\n15\n8\n11\n13\n7\n3\n14\n4
n\n5\n20\n20\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n11\n12\n13\n14\n15\n16\n17\n18\n19\n20\n6
n\n5\n24\n23\n0\n2\n5\n7\n10\n12\n15\n17\n20\n1
n\n5\n24\n24\n0\n2\n5\n7\n10\n12\n15\n17\n20\n8
n\n5\n20\n20\n0\n2\n5\n7\n10\n12\n15\n17\n20\n6
n\n5\n17\n17\n0\n2\n5\n7\n10\n12\n15\n17\n5
n\n5\n0\n1\n0\n1\n2\n3\n4\n9\n14\n15\n24\n23\n22\n21\n20\n15\n10\n5\n6\n7\n8\n13\n18\n17\n16\n11\n12\n19\n4
'''

# Failure codes
FC_PROC = 0x10
FC_PIPS = 0x8
FC_PIPR = 0x4
FC_EXIT = 0x2
FC_XPCT = 0x1

# Sleep time
st = 0.001
class ansitermcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

class nocolors(ansitermcolors):
    HEADER = ''
    OKBLUE = ''
    OKGREEN = ''
    WARNING = ''
    FAIL = ''
    ENDC = ''
    BOLD = ''
    UNDERLINE = ''

def runtest( ye, usec ):
	context.log_level = 'WARNING'		# Reduce default pwntools verbosity
	
	f = StringIO(ta)			# Use the large test string as a file (stream)
	ftc = 0					# Reset failed test counter

	for tc, l in enumerate(f, 1):		# Each line is one test, starting at test 1
		tt = l[-2]			# Get test type
		fc = 0				# Failure code
		fmsg = ""			# Fail messages

		print ye + ": Test " + "{0:03d}".format(tc) + " (type " + tt + "):",
		r = process(ye)			# Attach pipe to target executable
		try:
			rout = r.recv()		# Get target's initial output, if any
			#print rout,		# Display output
			sleep(st)
		except:
			fmsg += "\t\tearly recv() exception\n"
			fc |= FC_PROC		# Something is broken			
			break

		for c in l[:-4].split('\\n'):	# Break test line into chunks, simulating real interactive input
			try:
				r.send(c+"\n")	# Send chunk to target
				#print c+"\n",	# Echo input locally
				sleep(st)
			except EOFError:
				fmsg += "\t\tsend() EOFError exception\n"
				fc |= FC_PIPS	# Something is broken			
				break

			try:
				rout = r.recv()	# Get target's response
				#print rout,	# Display output
				sleep(st)
			except:
				fmsg += "\t\trecv() exception\n"
				fc |= FC_PIPR	# Something is broken			
				break

		#print rout
		xs = r.poll(block = False)	# Exit status
		r.close				# Close process, if needed
		
		# Update test failure code, if needed
		fc |= (FC_EXIT if (None == xs) else 0)	
		fc |= (FC_XPCT if (0 != fun_dict[str(tt)](rout)) else 0)

		print "{0:05b}".format(fc) + " " + ("PASS" if (fc == 0) else (usec.FAIL + "FAIL" + usec.ENDC + " for sequence: " + l[:-4].replace("\\n", ",")))
		if fmsg != "": print fmsg,	# Print extra fail messages
		if fc != 0: print "\t\tExpected: " + exp_dict[str(tt)]
		ftc += (0 if (fc == 0) else 1)	# Add to failed test counter

	print "\nTotal number of failed tests: " + (str(ftc) if (ftc == 0) else (usec.FAIL + str(ftc) + usec.ENDC)) + " out of " + str(tc) + "\n"
	print "Failure codes 00000: PASS/" + usec.FAIL + "FAIL" + usec.ENDC
	print "              ^^^^^"
	print """              ABCDE
A: Target process opening
B: Pipe send()
C: Pipe recv()
D: No exit
E: No match
"""

if __name__ == "__main__":
	main()