use borsh::{BorshDeserialize, BorshSerialize};
use solana_program::{
    account_info::AccountInfo, entrypoint, entrypoint::ProgramResult, msg, pubkey::Pubkey,
};
use std::collections::HashMap;

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

pub struct KvStore {
    kv: HashMap<String, String>,
}

entrypoint!(process_instruction);
fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    let instruction = KeyValueInstruction::try_from_slice(instruction_data)?;

    let mut kv_store = KvStore {
        kv: HashMap::new(),
    };

    match instruction {
        KeyValueInstruction::Get { key, sig } => {
            if !kv_store.kv.contains_key(&key) {
                msg!("keyValueEx/get/doesntexist {}", sig);
            } else {
                msg!("keyValueEx/get {}", sig);
                // msg!("Value: {}", val);
            }
        }
        KeyValueInstruction::Set { key, value, sig } => {
            if !kv_store.kv.contains_key(&key) {
                msg!("keyValueEx/set/exist {}", sig);
            } else {
                msg!("keyValueEx/set {}", sig);
            }
        }
    }
    Ok(())
}
