use midi_control::*;
use midir::*;

pub const FRENCH_NOTE_TABLE : [&str;12] = ["do" ,"do#","re","re#","mi","fa","fa#","sol","sol#","la","la#","si"];
#[allow(dead_code)]
pub const ENGLISH_NOTE_TABLE : [&str;12]= ["C" , "C#", "D", "D#", "E", "F", "F#", "F" , "F#" , "A", "A#", "B" ];

#[allow(dead_code)]
struct Note {
    oct: u8,
    note: u8,
    velocity: u8,

    channel: Channel,
}

impl Note {
    fn from(key: KeyEvent, channel: Channel) -> Self {
        Note {
            oct: key.key / 12,
            note: key.key % 12,
            velocity: key.value,
            channel,
        }
    }

    fn to_string(&self) -> String{
        format!("{}-{}",FRENCH_NOTE_TABLE[usize::from(self.note)],self.oct)
    }

}

fn callback(_timestamp: u64, data: &[u8], _: &mut ()) {
    let message = MidiMessage::from(data);
    print!("\nreceived midi data {:?} -> ", data);
    match message {
        MidiMessage::NoteOn(channel, key) => {
            println!("⤓ {} ON on channel : {channel:?} ⤓", Note::from(key,channel).to_string());
        }
        MidiMessage::NoteOff(channel, key) => {
            println!("⤒ {} OFF on channel : {channel:?}⤒", Note::from(key,channel).to_string());
        }

        MidiMessage::PitchBend(channel,x ,y ) =>{
            println!("pitch bend : ({x},{y}) on channel : {channel:?}")
        }

        MidiMessage::ControlChange(channel,controle ) => {
            println!("control change : ({:?}) -> ({:?}) on channel : {channel:?}",controle.control,controle.value);
        }
        
        MidiMessage::PolyKeyPressure(channel,key ) =>{
            println!("polykey pressure : ({:?}) on channel : {channel:?}",key.key);
        }

        _ => println!("unknow message received !"),
    }
}

pub fn init() {
    //initialisation
    let midi_input: MidiInput = match MidiInput::new("input") {
        Ok(result) => result,
        Err(e) => panic!("{}", e),
    };

    //conection
    let ports_nb = midi_input.port_count();
    println!("{} ports avalaibles", ports_nb);
    let _connection_number = 0;

    let mut connections: Vec<MidiInputConnection<()>> = innit_connections(&midi_input);

    #[allow(while_true)]
    while true {


        if connections.len() != midi_input.port_count() {
            connections = innit_connections(&midi_input);
        }
    }

    println!("[rust] exit !!");
}

fn innit_connections(midi_input: &MidiInput) -> Vec<MidiInputConnection<()>> {
    let mut return_vec: Vec<MidiInputConnection<()>> = vec![];

    for port in midi_input.ports() {

        let port_name = midi_input
            .port_name(&port)
            .expect("Error getting port name");
        let name: &str = port_name.as_str();

        match MidiInput::new(&format!("conection {port_name}"))
            .expect("error new midi input")
            .connect(&port, name, callback, ())
        {
            Ok(result) => return_vec.push(result),
            Err(e) => eprintln!("Error connecting to port {}: {:?}", name, e),
        }
    }

    return_vec
}
