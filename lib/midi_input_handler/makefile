
LIBNAME=libmidi_input_handler

debug:
	cargo build
	rm ./bin/libmidi_input_handler.so || cp ./target/debug/$(LIBNAME).so ./bin/ -i 

release:
	cargo build --release
	@mkdir ./bin
	rm ./bin/libmidi_input_handler.so|| mv ./target/release/$(LIBNAME).so ./bin/ -i 


run :
	make debug
	lua ./main.lua

clean :
	cargo clean
	rm ./bin/libmidi_input_handler.so