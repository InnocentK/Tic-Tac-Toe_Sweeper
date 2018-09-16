#
# Leave the following lines alone!!!

LDFLAGS=-g -m elf_x86_64
%.o: %.asm
	nasm -g -f elf64 -l $*.lst $< -o $@

#
# End of provided rules
#

# Modify following to the name of your linked program
TARGET=QC54897
JORGE=Jorge_TTT

# Modify following to the list of component object files
OBJS=QC54897.o
JORGE_OBJS=Jorge_TTT.o

#
# Do not modify remainder of this Makefile
#

all: ${TARGET} ${JORGE}

${TARGET}: ${OBJS}
	${LD} ${LDFLAGS} ${OBJS} -o ${TARGET}

${JORGE}: ${JORGE_OBJS}
	${LD} ${LDFLAGS} ${JORGE_OBJS} -o ${JORGE}

clean:
	rm *.o
cleaner:
	rm *~
cleanest:
	rm *.o
	rm *~
