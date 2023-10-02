use borsh::{BorshDeserialize, BorshSerialize};
use solana_program::{
    account_info::AccountInfo, entrypoint, entrypoint::ProgramResult, msg, pubkey::Pubkey,
};

pub const FIELD: &[u8] = b"!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";

pub enum MemInstruction {
    CreateString {
        len_out: usize,
        len_in: usize,
        first_char: usize,
        length: usize,
        sig: String,
    },
}

impl BorshSerialize for MemInstruction {
    fn serialize<W: std::io::Write>(&self, writer: &mut W) -> std::io::Result<()> {
        match self {
            MemInstruction::CreateString {
                len_out,
                len_in,
                first_char,
                length,
                sig,
            } => {
                0u32.serialize(writer)?;
                len_out.serialize(writer)?;
                len_in.serialize(writer)?;
                first_char.serialize(writer)?;
                length.serialize(writer)?;
                sig.serialize(writer)?;
            }
        }
        Ok(())
    }
}

impl BorshDeserialize for MemInstruction {
    fn deserialize(reader: &mut &[u8]) -> std::io::Result<Self> {
        let discriminant: u32 = BorshDeserialize::deserialize(reader)?;
        match discriminant {
            0 => {
                let len_out = usize::deserialize(reader)?;
                let len_in = usize::deserialize(reader)?;
                let first_char = usize::deserialize(reader)?;
                let length = usize::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                Ok(MemInstruction::CreateString {
                    len_out,
                    len_in,
                    first_char,
                    length,
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
    let instruction = MemInstruction::try_from_slice(instruction_data)?;
    match instruction {
        MemInstruction::CreateString {
            len_out,
            len_in,
            first_char,
            length,
            sig,
        } => {
            let mut arr: Vec<Vec<String>> = vec![vec![String::new(); len_in]; len_out];

            for i in 0..len_out {
                for j in 0..len_in {
                    arr[i][j] = get_chars(first_char + i + j, length + i + j);
                }
            }

            msg!("memory {}", sig);
        }
    }
    Ok(())
}

fn get_chars(first_char: usize, length: usize) -> String {
    let mut chars = Vec::new();

    for i in first_char..(length + first_char) {
        chars.extend_from_slice(&[FIELD[(first_char + i) % FIELD.len()]]);
    }

    String::from_utf8(chars).unwrap()
}
