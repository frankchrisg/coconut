use borsh::{BorshDeserialize, BorshSerialize};
use solana_program::{
    account_info::AccountInfo, entrypoint, entrypoint::ProgramResult, msg, program_error::ProgramError,
    pubkey::Pubkey,
};

entrypoint!(process_instruction);

pub enum DoNothingInstruction {
    DoNothingFunc { sig: String },
}

impl BorshSerialize for DoNothingInstruction {
    fn serialize<W: std::io::Write>(&self, writer: &mut W) -> std::io::Result<()> {
        match self {
            DoNothingInstruction::DoNothingFunc { sig } => {
                0u32.serialize(writer)?;
                sig.serialize(writer)?;
            }
        }
        Ok(())
    }
}

impl BorshDeserialize for DoNothingInstruction {
    fn deserialize(reader: &mut &[u8]) -> std::io::Result<Self> {
        let discriminant: u32 = BorshDeserialize::deserialize(reader)?;
        match discriminant {
            0 => {
                let sig = String::deserialize(reader)?;
                Ok(DoNothingInstruction::DoNothingFunc { sig })
            }
            _ => Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                "Invalid discriminant value",
            )),
        }
    }
}

fn process_instruction(
    _program_id: &Pubkey,
    _accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    // msg!("instruction_data: {:?}", instruction_data);
    let instruction = DoNothingInstruction::try_from_slice(instruction_data)
        .map_err(|_| ProgramError::InvalidInstructionData)?;

    match instruction {
        DoNothingInstruction::DoNothingFunc { sig } => do_nothing_func(&sig),
    }
}

fn do_nothing_func(sig: &str) -> ProgramResult {
    emit_nothing("doNothing ", sig);
    Ok(())
}

fn emit_nothing(event_type: &str, signature: &str) {
    msg!("doNothing {}", signature);
}
