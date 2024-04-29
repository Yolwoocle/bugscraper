
LIBNAME=libmidi_input_handler

OS := $(shell uname)
ifeq ($(OS),Linux)
    EXT := so
else ifeq ($(OS),Darwin)
    EXT := dylib
else ifeq ($(OS),Windows_NT)
    EXT := dll
else
    $(error Unsupported operating system: $(OS))
endif


debug:
	@echo "building for $(shell uname)"
	cargo build
	rm ./libmidi_input_handler.$(EXT) || cp ./target/debug/$(LIBNAME).$(EXT) ./ -i 

release:
	@echo "building for $(shell uname)"
	cargo build --release
	@rm ./libmidi_input_handler.$(EXT)|| mv ./target/release/$(LIBNAME).$(EXT) ./ -i 


run :
	make debug
	lua ./main.lua

clean :
	cargo clean
	@rm ./libmidi_input_handler.so