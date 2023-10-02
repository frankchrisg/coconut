use borsh::{BorshDeserialize, BorshSerialize};
use solana_program::{
    account_info::AccountInfo, entrypoint, entrypoint::ProgramResult, msg,
    program_error::ProgramError, pubkey::Pubkey,
};
use std::collections::HashMap;

entrypoint!(process_instruction);

pub enum KeyValueInstruction {
    Get { key: String, sig: String },
    Set { key: String, value: String, sig: String },
}

impl BorshSerialize for KeyValueInstruction {
    fn serialize<W: std::io::Write>(&self, writer: &mut W) -> std::io::Result<()> {
        match self {
            KeyValueInstruction::Get { key, sig } => {
                0u32.serialize(writer)?;
                key.serialize(writer)?;
                sig.serialize(writer)?;
            }
            KeyValueInstruction::Set { key, value, sig } => {
                1u32.serialize(writer)?;
                key.serialize(writer)?;
                value.serialize(writer)?;
                sig.serialize(writer)?;
            }
        }
        Ok(())
    }
}

impl BorshDeserialize for KeyValueInstruction {
    fn deserialize(reader: &mut &[u8]) -> std::io::Result<Self> {
        let discriminant: u32 = BorshDeserialize::deserialize(reader)?;
        match discriminant {
            0 => {
                let key = String::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                Ok(KeyValueInstruction::Get { key, sig })
            }
            1 => {
                let key = String::deserialize(reader)?;
                let value = String::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                Ok(KeyValueInstruction::Set { key, value, sig })
            }
            _ => Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                "Invalid discriminant value",
            )),
        }
    }
}

pub fn process_instruction(
    _program_id: &Pubkey,
    _accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    let instruction = KeyValueInstruction::try_from_slice(instruction_data)
        .map_err(|_| ProgramError::InvalidInstructionData)?;

    let mut kv_store = KeyValue::default();

    match instruction {
        KeyValueInstruction::Get { key, sig } => kv_store.get(&key, &sig),
        KeyValueInstruction::Set { key, value, sig } => kv_store.set(key, value, &sig),
    }
}

pub struct KeyValue {
    kv: HashMap<String, String>,
}

impl Default for KeyValue {
    fn default() -> Self {
        Self {
            kv: HashMap::new(),
        }
    }
}

impl KeyValue {
    pub fn get(&mut self, key: &str, sig: &str) -> ProgramResult {
        let value = self.kv.get(key);

        match value {
            Some(val) => {
                emit_key_value_event("keyValue/get", sig);
                // msg!("Value: {}", val);
            }
            None => (),
        }
        Ok(())
    }

    pub fn set(&mut self, key: String, value: String, sig: &str) -> ProgramResult {
        self.kv.insert(key, value);
        emit_key_value_event("keyValue/set", sig);
        Ok(())
    }
}

fn emit_key_value_event(event_type: &str, signature: &str) {
    msg!("{} {}", event_type, signature);
}
