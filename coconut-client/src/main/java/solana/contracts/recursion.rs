use borsh::{BorshDeserialize, BorshSerialize};
use solana_program::{
    account_info::AccountInfo,
    entrypoint,
    entrypoint::ProgramResult,
    msg,
    program_error::ProgramError,
    pubkey::Pubkey,
};
use std::io::{Error, ErrorKind};

pub enum RecursionInstruction {
    Main { start: u32, end: u32, sig: String },
}

impl BorshSerialize for RecursionInstruction {
    fn serialize<W: std::io::Write>(&self, writer: &mut W) -> std::io::Result<()> {
        match self {
            RecursionInstruction::Main { start, end, sig } => {
                0u32.serialize(writer)?;
                start.serialize(writer)?;
                end.serialize(writer)?;
                sig.serialize(writer)?;
            }
        }
        Ok(())
    }
}

impl BorshDeserialize for RecursionInstruction {
    fn deserialize(reader: &mut &[u8]) -> std::io::Result<Self> {
        let discriminant: u32 = BorshDeserialize::deserialize(reader)?;
        match discriminant {
            0 => {
                let start = u32::deserialize(reader)?;
                let end = u32::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                Ok(RecursionInstruction::Main { start, end, sig })
            }
            _ => Err(Error::new(
                ErrorKind::InvalidData,
                "Invalid discriminant value",
            )),
        }
    }
}

entrypoint!(process_instruction);
pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    let instruction = RecursionInstruction::try_from_slice(instruction_data)
        .map_err(|_| ProgramError::InvalidInstructionData)?;

    match instruction {
        RecursionInstruction::Main { start, end, sig } => {
            rec(start, end);
            emit_recursion_event("recursion", &sig);
            Ok(())
        }
    }
}

fn rec(start: u32, end: u32) {
    if start != end {
        rec(start, end - 1);
    }
}

fn emit_recursion_event(event_type: &str, sig: &str) {
    msg!("{} {}", event_type, sig);
}
