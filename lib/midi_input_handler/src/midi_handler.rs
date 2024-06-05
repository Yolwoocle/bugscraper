use midi_control::*;
use midir::*;
use std::sync::mpsc::{channel, Receiver, Sender};
use std::thread;

#[allow(dead_code)]
pub const FRENCH_NOTE_TABLE: [&str; 12] = [
    "do", "do#", "re", "re#", "mi", "fa", "fa#", "sol", "sol#", "la", "la#", "si",
];
pub const ENGLISH_NOTE_TABLE: [&str; 12] = [
    "C", "C#", "D", "D#", "E", "F", "F#", "F", "F#", "A", "A#", "B",
];

type Connection = MidiInputConnection<Sender<MidiInputPressed>>;

pub struct Note {
    pub oct: u8,
    pub note: u8,
    pub velocity: u8,

    pub channel: Channel,
}
impl Note {
    pub fn from(key: KeyEvent, channel: Channel) -> Self {
        Note {
            oct: key.key / 12,
            note: key.key % 12,
            velocity: key.value,
            channel,
        }
    }

    fn to_string(&self) -> String {
        format!(
            "{}-{}",
            ENGLISH_NOTE_TABLE[usize::from(self.note)],
            self.oct
        )
    }
    #[allow(dead_code)]
    pub fn get_channel_num(&self) -> u8 {
        ((self.channel as u8) + 1) % 17
    }
}

#[allow(dead_code)]
pub struct MidiValue {
    pub value: i16,
    pub key: u8,
    pub channel: Channel,
}
impl MidiValue {
    #[allow(dead_code)]
    pub fn to_string(&self) -> String {
        format!("{}-{}-{:?}", self.value, self.key, self.channel)
    }
    #[allow(dead_code)]
    pub fn get_channel_num(&self) -> u8 {
        ((self.channel as u8) + 1) % 17
    }
}

#[allow(dead_code)]

pub enum MidiInputPressed {
    Note(Note),
    JoystickX(MidiValue),
    JoystickY(MidiValue),
    Knob(MidiValue),
    Unknown(u16),
    None,
}

impl MidiInputPressed {
    #[allow(dead_code)]
    pub fn get_input_name(&self) -> String {
        match self {
            Self::None => "None".to_string(),
            Self::Note(note) => note.to_string(),
            Self::JoystickX(val) => val.to_string(),
            Self::JoystickY(val) => val.to_string(),
            Self::Knob(val) => val.to_string(),
            Self::Unknown(val) => format!("{:x}", val),
        }
    }
}

fn callback(_timestamp: u64, data: &[u8], sender: &mut Sender<MidiInputPressed>) {
    
    let message = MidiMessage::from(data);
    // #[cfg(debug_assertions)]
    // print!("\nreceived midi data  -> {:?}", data);
    match message {
        MidiMessage::NoteOn(channel, key) => {
            let note: Note = Note::from(key, channel);
            #[cfg(debug_assertions)]
            println!("{} on channel : {channel:?} ", note.to_string());
            sender.send(MidiInputPressed::Note(note)).expect("corresponding receiver has already been deallocated (callback)");
        }
        MidiMessage::NoteOff(channel, key) => {
            let note: Note = Note::from(key, channel);
            // #[cfg(debug_assertions)]
            // println!("{} on channel : {channel:?} ", note.to_string());
            sender.send(MidiInputPressed::Note(note)).expect("corresponding receiver has already been deallocated (callback)");
        }

        MidiMessage::PitchBend(channel, _x, y) => {
            // #[cfg(debug_assertions)]
            // println!("pitch bend : ({x},{y}) on channel : {channel:?}");
            let axis = MidiValue {
                value: (y as i16) - 64,

                key: 0,
                channel,
            };
            sender.send(MidiInputPressed::JoystickX(axis)).expect("corresponding receiver has already been deallocated (callback)");
        }

        MidiMessage::PolyKeyPressure(channel, key) => {
            // #[cfg(debug_assertions)]
            // println!(
            //     "polykey pressure : ({:?}) on channel : {channel:?}",
            //     key.key
            // );
            let axis = MidiValue {
                value: key.value as i16,
                key: key.key,
                channel,
            };
            sender.send(MidiInputPressed::JoystickX(axis)).expect("corresponding receiver has already been deallocated (callback)");
        }

        MidiMessage::ControlChange(channel, controle) => {
            // #[cfg(debug_assertions)]
            // println!(
            //     "control change : ({:?}) -> ({:?}) on channel : {channel:?}",
            //     controle.control, controle.value
            // );
            let knob = MidiValue {
                value: i16::from(controle.value),
                key: controle.control,
                channel,
            };
            sender.send(MidiInputPressed::Knob(knob)).expect("corresponding receiver has already been deallocated (callback)");
        }

        _ => {
            () //do nothing in case of an unknown input
        }
    }
}

pub fn init() -> Receiver<MidiInputPressed> {
    //initialisation

    let (sender, receiver) = channel::<MidiInputPressed>();
    thread::spawn(move || {
        let sender: Sender<MidiInputPressed> = sender;
        let midi_input: MidiInput = match MidiInput::new("input") {
            Ok(result) => result,
            Err(e) => panic!("{}", e),
        };

        //conection
        let ports_nb = midi_input.port_count();
        println!("{} ports avalaibles", ports_nb);

        let mut connections: Vec<Connection> =
            init_all_connections(&midi_input, &sender);

        loop {
            //TODO stop active loop
            if connections.len() != midi_input.port_count() {
                connections = init_all_connections(&midi_input, &sender);
            }
        }
    });
    receiver
}

fn init_all_connections(
    midi_input: &MidiInput,
    sender: &Sender<MidiInputPressed>,
) -> Vec<Connection> {
    let mut return_vec: Vec<Connection> = Vec::new();

    for port in midi_input.ports() {
        let port_name = midi_input
            .port_name(&port)
            .expect("Error getting port name");
        let name = port_name.as_str();

        match MidiInput::new(&format!("connection {port_name}"))
            .expect("error new midi input")
            .connect(&port, name, callback, sender.clone())
        {
            Ok(result) => return_vec.push(result),
            Err(e) => eprintln!("Error connecting to port {}: {:?}", name, e),
        }
    }

    return_vec
}

