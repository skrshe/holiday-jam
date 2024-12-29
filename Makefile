FLAGS=-lSDL2 -lSDL2_image -lm -ggdb

holidayjam: main.odin
	odin build main.odin -out:holiday-jam

clean:
	rm holiday-jam

run:
	./holiday-jam
