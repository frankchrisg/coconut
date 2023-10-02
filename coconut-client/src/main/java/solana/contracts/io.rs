use borsh::{BorshDeserialize, BorshSerialize};
use solana_program::{
    account_info::AccountInfo, entrypoint, entrypoint::ProgramResult, msg, program_error::ProgramError, pubkey::Pubkey,
};
use std::collections::HashMap;
use std::io::Read;

pub struct IO {
    store: HashMap<String, String>,
}

pub enum IOInstruction {
    Write {
        size: u32,
        start_key: u32,
        ret_len: u32,
        sig: String,
    },
    Scan {
        size: u32,
        start_key: u32,
        sig: String,
    },
    RevertScan {
        size: u32,
        start_key: u32,
        sig: String,
    },
}

impl BorshSerialize for IO {
    fn serialize<W: std::io::Write>(&self, writer: &mut W) -> std::io::Result<()> {
        self.store.serialize(writer)
    }
}

impl BorshDeserialize for IO {
    fn deserialize(reader: &mut &[u8]) -> std::io::Result<Self> {
        let store = match HashMap::deserialize(reader) {
            Ok(s) => {
                //msg!("Deserialized store successfully");
                s
            }
            Err(e) => {
                msg!("Error deserializing store: {:?}", e);
                return Err(e);
            }
        };

        // Ignore any remaining bytes
        let mut remaining = Vec::new();
        let _ = reader.read_to_end(&mut remaining);

        Ok(Self { store })
    }
}

const CHARS: &'static [u8] = b"!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";

impl IO {
    pub fn write(&mut self, size: u32, start_key: u32, ret_len: u32) {
        let mut states: String = String::new();
        for i in 0..size {
            let s_k = (start_key + i).to_string();
            let val = Self::get_val(start_key + i, ret_len as usize);
            let val_str: String = val.iter().collect();
            self.store.insert(s_k, val_str.clone());
            states.push_str(&val_str);

            //msg!("s_k: {}", s_k);
            //msg!("val: {:?}", val);
            //msg!("val_str: {}", val_str);
        }
        //msg!("states: {}", states);
        /*for (key, value) in &self.store {
            msg!("Key: {}, Value: {}", key, value);
        }*/
    }

    pub fn get_val(k: u32, ret_length: usize) -> Vec<char> {
        //let chars: Vec<u8> = b"!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~".to_vec();
        let mut ret = Vec::with_capacity(ret_length);
        for i in 0..ret_length {
            ret.push(CHARS[((k + i as u32) % CHARS.len() as u32) as usize] as char);
        }
        ret
    }

    pub fn scan(&mut self, size: u32, start_key: u32) {
        let mut states: String = String::new();
        for i in 0..size {
            let s_k = (start_key + i).to_string();
            //msg!("s_k: {}", s_k);
            let val = match self.store.get(&s_k) {
                Some(value) => value,
                None => {
                    break;
                }
            };
            //msg!("val: {}", val);

            states.push_str(val);
        }
        //msg!("states: {}", states);
        /*for (key, value) in &self.store {
            msg!("Key: {}, Value: {}", key, value);
        }*/
    }

    pub fn revert_scan(&mut self, size: u32, start_key: u32) {
        let mut states: String = String::new();
        for i in 0..size {
            let s_k = (start_key + size - i - 1).to_string();
            //msg!("s_k: {}", s_k);
            let val = match self.store.get(&s_k) {
                Some(value) => value,
                None => {
                    break;
                }
            };
            //msg!("val: {}", val);

            states.push_str(val);
        }
        //msg!("states: {}", states);
        /*for (key, value) in &self.store {
            msg!("Key: {}, Value: {}", key, value);
        }*/
    }
}

impl BorshSerialize for IOInstruction {
    fn serialize<W: std::io::Write>(&self, writer: &mut W) -> std::io::Result<()> {
        match self {
            IOInstruction::Write {
                size,
                start_key,
                ret_len,
                sig,
            } => {
                0u32.serialize(writer)?;
                size.serialize(writer)?;
                start_key.serialize(writer)?;
                ret_len.serialize(writer)?;
                sig.serialize(writer)?;
            }
            IOInstruction::Scan {
                size,
                start_key,
                sig,
            } => {
                1u32.serialize(writer)?;
                size.serialize(writer)?;
                start_key.serialize(writer)?;
                sig.serialize(writer)?;
            }
            IOInstruction::RevertScan {
                size,
                start_key,
                sig,
            } => {
                2u32.serialize(writer)?;
                size.serialize(writer)?;
                start_key.serialize(writer)?;
                sig.serialize(writer)?;
            }
        }
        Ok(())
    }
}


impl BorshDeserialize for IOInstruction {
    fn deserialize(reader: &mut &[u8]) -> std::io::Result<Self> {
        let discriminant: u32 = BorshDeserialize::deserialize(reader)?;
        match discriminant {
            0 => {
                let size = u32::deserialize(reader)?;
                let start_key = u32::deserialize(reader)?;
                let ret_len = u32::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                //msg!("Deserialized Write instruction");
                Ok(IOInstruction::Write {
                    size,
                    start_key,
                    ret_len,
                    sig,
                })
            }
            1 => {
                let size = u32::deserialize(reader)?;
                let start_key = u32::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                //msg!("Deserialized Scan instruction");
                Ok(IOInstruction::Scan {
                    size,
                    start_key,
                    sig,
                })
            }
            2 => {
                let size = u32::deserialize(reader)?;
                let start_key = u32::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                //msg!("Deserialized RevertScan instruction");
                Ok(IOInstruction::RevertScan {
                    size,
                    start_key,
                    sig,
                })
            }
            _ => Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                "Invalid discriminant value",
            )),
        }
    }
}

entrypoint!(process_instruction);
fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    let instruction = match IOInstruction::try_from_slice(instruction_data) {
        Ok(instr) => {
            //msg!("Deserialized instruction successfully");
            instr
        }
        Err(e) => {
            msg!("Error deserializing instruction: {:?}", e);
            return Err(ProgramError::InvalidInstructionData);
        }
    };
    let io_data = &mut accounts[0].data.borrow_mut();
    let mut io: IO = match IO::try_from_slice(&io_data) {
        Ok(existing_io) => existing_io,
        Err(e) => {
            msg!("Error deserializing IO: {:?}", e);
            msg!("Initializing a new HashMap");
            IO::default()
        }
    };

    match instruction {
        IOInstruction::Write {
            size,
            start_key,
            ret_len,
            sig,
        } => {
            io.write(size, start_key, ret_len);
            msg!("storage/write {}", sig);
        }
        IOInstruction::Scan {
            size,
            start_key,
            sig,
        } => {
            io.scan(size, start_key);
            msg!("storage/scan {}", sig);
        }
        IOInstruction::RevertScan {
            size,
            start_key,
            sig,
        } => {
            io.revert_scan(size, start_key);
            msg!("storage/revertScan {}", sig);
        }
    }

    match io.serialize(&mut io_data.as_mut()) {
        Ok(_) => {
            //msg!("Serialized IO successfully");
        }
        Err(e) => {
            msg!("Error serializing IO: {:?}", e);
            return Err(ProgramError::InvalidAccountData);
        }
    }

    Ok(())
}

impl Default for IO {
    fn default() -> Self {
        Self {
            store: HashMap::new(),
        }
    }
}
