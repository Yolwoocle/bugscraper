mod midi_handler;
mod wrapper;

use std::{
    sync::{
        mpsc::{channel, Receiver},
        OnceLock,
    },
    thread,
};

use midi_handler::*;
use mlua::prelude::*;
use wrapper::Wrapper;

static RECEIVER: OnceLock<Wrapper<Receiver<MidiInputPressed>>> = OnceLock::new();


//LUA init

//same name as the lib (path include...)
#[mlua::lua_module]
fn libmidi_input_handler(lua: &Lua) -> LuaResult<LuaTable> {
    lua_init(lua)
}
#[mlua::lua_module]
fn target_debug_libmidi_input_handler(lua: &Lua) -> LuaResult<LuaTable> {
    lua_init(lua)
}
#[mlua::lua_module]
fn libmidi_input_handler_libmidi_input_handler(lua: &Lua) -> LuaResult<LuaTable> {
    lua_init(lua)
}

#[mlua::lua_module]
fn lib_midi_input_handler_libmidi_input_handler(lua: &Lua) -> LuaResult<LuaTable> {
    lua_init(lua)
}

#[mlua::lua_module]
fn lua_init(lua: &Lua) -> LuaResult<LuaTable> {
    let exports = lua.create_table()?;
    exports.set("print_rust", lua.create_function(lua_print_rust)?)?;
    exports.set("init_midi", lua.create_function(lua_init_midi)?)?;
    exports.set("get_inputs", lua.create_function(lua_get_inputs)?)?;

    Ok(exports)
}

//LUA functions

//test function
fn lua_print_rust(_: &Lua, message: String) -> LuaResult<()> {
    println!("[rust] {message}");
    Ok(())
}

fn lua_init_midi(_lua: &Lua, _: ()) -> LuaResult<()> {
    let (sender, receiver) = channel::<MidiInputPressed>();
    RECEIVER.get_or_init(|| Wrapper::new(receiver));

    //--loop thread--
    thread::spawn(move || {
        let sender = sender;
        let input_receiver = init();
        loop {
            let input = input_receiver.recv().expect("no senders for input (lua init midi)");

            match sender.send(input){
                Ok(_)=> (),
                Err(e) =>{println!("{e} :sender.send(input)")}
            }
                
        }
    });
    //--loop thread -- end
    Ok(())
}

//renvoie les inputs du buffer
fn lua_get_inputs(lua: &Lua, _: ()) -> LuaResult<LuaTable> {
    // TODO: handle panic
    let receiver = RECEIVER.get().unwrap();

    let buffer_table = lua.create_table()?;

    while let Ok(input) = receiver.try_recv() {
        buffer_table.set(
            buffer_table.len().expect("error len lua get inputs") + 1,
            midi_input_to_table(lua, &input)?,
        )?;
    }

    Ok(buffer_table)
}

//---------------------

fn midi_input_to_table<'a>(lua: &'a Lua, input: &'a MidiInputPressed) -> LuaResult<LuaTable<'a>> {
    let input_table = lua.create_table()?;
    match input {
        MidiInputPressed::Note(note) => {
            input_table.set("midi_type", "note")?;
            input_table.set("oct", note.oct)?;
            input_table.set("note", note.note)?;
            input_table.set("velocity", note.velocity)?;
            input_table.set("channel", note.get_channel_num())?;
        }
        MidiInputPressed::JoystickX(midi_val) => {
            midival_into_table(&input_table, midi_val, "JoystickX".to_string())?
        }
        MidiInputPressed::JoystickY(midi_val) => {
            midival_into_table(&input_table, midi_val, "JoystickY".to_string())?
        }
        MidiInputPressed::Knob(midi_val) => {
            midival_into_table(&input_table, midi_val, "Knob".to_string())?
        }
        MidiInputPressed::Unknown(midi_val) => {
            input_table.set("midi_type", "unknown")?;
            input_table.set("id", *midi_val)?;
        }

        MidiInputPressed::None => (),
    }

    Ok(input_table)
}

fn midival_into_table(
    input_table: &LuaTable,
    midi_val: &MidiValue,
    midi_type: String,
) -> LuaResult<()> {
    input_table.set("midi_type", midi_type)?;
    input_table.set("value", midi_val.value)?;
    input_table.set("key", midi_val.key)?;
    input_table.set("channel", midi_val.get_channel_num())?;

    Ok(())
}
