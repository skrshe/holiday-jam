all: main run

run: main
	./holiday-jam
main: main.odin
	odin build . -out:holiday-jam -file
clean:
	rm holiday-jam

