LIBNAME=libmidi_input_handler

RED=\033[0;31m
NC=\033[0m # No Color

TARGET_OS := $(shell uname)
ifeq ($(TARGET),)
    TARGET := $(TARGET_OS)
endif

ifeq ($(TARGET),Linux)
    EXT := so
	TARGET_BUILD := x86_64-unknown-linux-gnu
else ifeq ($(TARGET),Darwin)
    EXT := dylib
	TARGET_BUILD := x86_64-apple-darwin
else ifeq ($(TARGET),Windows_NT)
    EXT := dll
	TARGET_BUILD := x86_64-pc-windows-gnu
	LIBNAME := midi_input_handler
else
    $(error Unsupported target OS: $(TARGET))
endif



debug:
	@echo "$(RED)<==building for $(TARGET)==> $(NC)"
	cargo build --target $(TARGET_BUILD)
	@if [ -f "$(LIBNAME).$(EXT)" ]; then rm "$(LIBNAME).$(EXT)"; fi
	cp ./target/$(TARGET_BUILD)/release/$(LIBNAME).$(EXT) ./ -i 

release:
	@echo "$(RED)<==building for $(TARGET)==> $(NC)"
	cargo build --release --target $(TARGET_BUILD)
	@if [ -f "$(LIBNAME).$(EXT)" ]; then rm "$(LIBNAME).$(EXT)"; fi
	mv ./target/$(TARGET_BUILD)/release/$(LIBNAME).$(EXT) ./ -i 


clean :
	cargo clean
	@rm ./libmidi_input_handler.so