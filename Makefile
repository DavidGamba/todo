# Macros
CC = gcc
CFLAGS = -I. -Wall
CDIR= $(notdir $(CURDIR))

SRC=$(wildcard *.c)
OBJ=$(SRC:.c=.o)

# target $@: dependencies $<
# [tab] system command

all: $(CDIR).a

# Link main
$(CDIR).a: main.o utils.o
	@echo [Linking]: $^ $@
	$(CC) $(CFLAGS) $^ -o $@

# Compiling
%.o: %.c
	@echo [Compiling]: $<
	$(CC) $(CFLAGS) -c $< -o $@

# Linking
%.a: %.c
	@echo [Linking]: $<
	$(CC) $(CFLAGS) $< -o $@


.PHONY : clean

clean :
	rm -f *.o
	rm -f *.a
# The configure script and the Makefile rules for building and
# installation should not use any utilities directly except these:
# awk cat cmp cp diff echo egrep expr false grep install-info ln ls
# mkdir mv printf pwd rm rmdir sed sleep sort tar test touch tr true

# $@ filename of target
# $< name of first prerequesite
# $? The names of all the prerequisites that are newer than the target
# $^ The names of all the prerequisites
# $* stem name
# $(@D) dir part of the filename of the target
