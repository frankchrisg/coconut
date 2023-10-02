use borsh::{BorshDeserialize, BorshSerialize};
use solana_program::{
    account_info::AccountInfo, entrypoint, entrypoint::ProgramResult, msg, program_error::ProgramError,
    pubkey::Pubkey,
};

entrypoint!(process_instruction);
pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    let instruction = LoopInstruction::try_from_slice(instruction_data)
        .map_err(|_| ProgramError::InvalidInstructionData)?;

    match instruction {
        LoopInstruction::LoopFunc { start, end, sig } => {
            loop_func(start, end, &sig)?;
            Ok(())
        }
    }
}

fn loop_func(start: u64, end: u64, sig: &str) -> Result<(), ProgramError> {
    let mut j = 0;
    for i in start..end {
        j = start + i;
    }
    msg!("loop {}", sig);
    Ok(())
}

// #[derive(BorshSerialize, BorshDeserialize)]
pub enum LoopInstruction {
    LoopFunc { start: u64, end: u64, sig: String },
}

impl BorshSerialize for LoopInstruction {
    fn serialize<W: std::io::Write>(&self, writer: &mut W) -> std::io::Result<()> {
        match self {
            LoopInstruction::LoopFunc { start, end, sig } => {
                0u32.serialize(writer)?;
                start.serialize(writer)?;
                end.serialize(writer)?;
                sig.serialize(writer)?;
            }
        }
        Ok(())
    }
}

impl BorshDeserialize for LoopInstruction {
    fn deserialize(reader: &mut &[u8]) -> std::io::Result<Self> {
        let discriminant: u32 = BorshDeserialize::deserialize(reader)?;
        match discriminant {
            0 => {
                let start = u64::deserialize(reader)?;
                let end = u64::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                Ok(LoopInstruction::LoopFunc { start, end, sig })
            }
            _ => Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                "Invalid discriminant value",
            )),
        }
    }
}
