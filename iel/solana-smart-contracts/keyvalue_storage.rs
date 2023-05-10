// Attention for Program log: Error during deserialization: Custom { kind: InvalidData, error: "Not all bytes read" }

use borsh::{BorshSerialize, BorshDeserialize};
use solana_program::{
    account_info::{next_account_info, AccountInfo},
    entrypoint, entrypoint::ProgramResult, msg, program_error::ProgramError,
    pubkey::Pubkey, rent::Rent, sysvar::Sysvar,
};
use std::collections::HashMap;
use std::io::Read;

#[derive(Debug, BorshSerialize)]
pub struct KeyValue {
    kv: HashMap<String, String>,
}

impl BorshDeserialize for KeyValue {
    fn deserialize(reader: &mut &[u8]) -> std::io::Result<Self> {
        let kv_length: u32 = BorshDeserialize::deserialize(reader)?;
        let mut kv = HashMap::new();
        for _ in 0..kv_length {
            let key = String::deserialize(reader)?;
            let value = String::deserialize(reader)?;
            kv.insert(key, value);
        }

// Attention for Program log: Error during deserialization: Custom { kind: InvalidData, error: "Not all bytes read" }
        // Ignore any remaining bytes
        let mut remaining = Vec::new();
        let _ = reader.read_to_end(&mut remaining);

        Ok(Self { kv })
    }
}

impl Default for KeyValue {
    fn default() -> Self {
        Self { kv: HashMap::new() }
    }
}

impl KeyValue {
    pub fn try_from_slice_ignore_extra(slice: &[u8]) -> std::io::Result<Self> {
        let mut slice_ref = &slice[..];
        let result = Self::deserialize(&mut slice_ref);
        result
    }

    pub fn from_account_data(data: &[u8]) -> Result<Self, ProgramError> {
        //  msg!("Actual deserialized data length: {}", data.len());
        //  msg!("Deserializing account data: {:?}", data);
        let result = Self::try_from_slice_ignore_extra(data).map_err(|err| {
            msg!("Error during deserialization: {:?}", err);
            ProgramError::InvalidAccountData
        });
        //  msg!("Deserialized KeyValue: {:?}", result);
        result
    }

    pub fn get(&self, key: &str, sig: &str) -> Result<Option<String>, ProgramError> {
        for (k, v) in self.kv.iter() {
            if k == key {
                //msg!("key {} value {}", k, v);
                msg!("keyValue/get {}", sig);
                return Ok(Some(v.clone()));
            }
        }
        Ok(None)
    }

    pub fn set(&mut self, key: String, value: String, sig: &str) -> Result<(), ProgramError> {
        for (k, v) in self.kv.iter_mut() {
            if k == &key {
                *v = value;
                msg!("keyValue/set {}", sig);
                return Ok(());
            }
        }
        self.kv.insert(key, value);
        msg!("keyValue/set {}", sig);
        Ok(())
    }

    pub fn to_account_data(&self) -> Result<Vec<u8>, ProgramError> {
        // msg!("Serializing KeyValue: {:?}", self);
        let mut account_data = Vec::new();
        self.serialize(&mut account_data)
            .map_err(|_| ProgramError::InvalidAccountData)?;
        // msg!("Actual serialized data length: {}", account_data.len());
        // msg!("Serialized account data: {:?}", account_data);
        Ok(account_data)
    }
}

entrypoint!(process_instruction);

pub enum KeyValueInstruction {
    Get { key: String, sig: String },
    Set { key: String, value: String, sig: String },
}

pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    let account_info_iter = &mut accounts.iter();
    let kv_account = next_account_info(account_info_iter)?;
    let rent = &Rent::from_account_info(next_account_info(account_info_iter)?)?;

    if !kv_account.is_writable {
        return Err(ProgramError::InvalidAccountData);
    }

    if !rent.is_exempt(kv_account.lamports(), kv_account.data_len()) {
        return Err(ProgramError::AccountNotRentExempt);
    }

    let mut kv_store = {
        let account_data = kv_account.data.borrow();
        let is_all_zeros = account_data.iter().all(|&byte| byte == 0);

        if is_all_zeros {
            KeyValue::default()
        } else {
            // msg!("Account data before operation: {:?}", kv_account.data.borrow());
            KeyValue::from_account_data(&account_data)?
        }
    };

    let instruction = KeyValueInstruction::try_from_slice(instruction_data)
        .map_err(|err| {
            msg!("Error deserializing instruction data: {:?}", err);
            ProgramError::InvalidInstructionData
        })?;

    match instruction {
        KeyValueInstruction::Get { key, sig } => {
            let _ = kv_store.get(&key, &sig)?;
        }
        KeyValueInstruction::Set { key, value, sig } => {
            kv_store.set(key, value, &sig)?;
        }
    }

    // msg!("Before updating account data: {:?}", kv_account.data.borrow());

    let account_data_new = kv_store.to_account_data()?;
    {
        let mut account_data = kv_account.data.borrow_mut();
        let data_len = account_data.len();
        let new_data_len = account_data_new.len();
        let copy_len = data_len.min(new_data_len);
        account_data[..copy_len].copy_from_slice(&account_data_new[..copy_len]);
    }

// msg!("Account data after operation: {:?}", kv_account.data.borrow());


    Ok(())
}

fn emit_key_value_event(event_type: &str, signature: &str) {
    msg!("{} {}", event_type, signature);
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
