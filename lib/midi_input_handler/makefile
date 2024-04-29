
LIBNAME=libmidi_input_handler

debug:
	cargo build
	rm ./libmidi_input_handler.so || cp ./target/debug/$(LIBNAME).so ./ -i 

release:
	cargo build --release
	@mkdir ./bin
	rm ./libmidi_input_handler.so|| mv ./target/release/$(LIBNAME).so ./ -i 


run :
	make debug
	lua ./main.lua

clean :
	cargo clean
	rm ./bin/libmidi_input_handler.so