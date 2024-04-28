mod midi_handler;

use midi_handler::*;

use mlua::prelude::*;

use std::thread;


//meme nom que .so
#[mlua::lua_module]
fn libmidi_input_handler(lua: &Lua) -> LuaResult<LuaTable> {
    let exports = lua.create_table()?;
    exports.set("print_rust", lua.create_function(lua_print_rust)?)?;
    exports.set("innit_midi", lua.create_function(lua_innit_midi)?)?;
    Ok(exports)
}

fn lua_print_rust(_: &Lua, message: String) -> LuaResult<()> {
    println!("[rust] {message}");
    Ok(())
}

fn lua_innit_midi(_: &Lua, _: ()) -> LuaResult<()> {
    thread::spawn(|| {init();});

    Ok(())
}
