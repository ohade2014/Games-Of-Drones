#format is target-name: target dependencies
#{-tab-}actions

# All Targets
all: ass3

ass3: Task3.o target.o printer.o scheduler.o drone.o
	gcc -m32 -g -Wall -o ass3 Task3.o target.o printer.o scheduler.o drone.o

Task3.o: ass3.s
	nasm -g -f elf -w+all -o Task3.o ass3.s

target.o: target.s
	nasm -g -f elf -w+all -o target.o target.s

printer.o: printer.s
	nasm -g -f elf -w+all -o printer.o printer.s

scheduler.o: scheduler.s
	nasm -g -f elf -w+all -o scheduler.o scheduler.s

drone.o: drone.s
	nasm -g -f elf -w+all -o drone.o drone.s

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o ass3
