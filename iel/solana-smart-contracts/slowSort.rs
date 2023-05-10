use borsh::{BorshDeserialize, BorshSerialize};
use std::io::{Error, ErrorKind};

use solana_program::{
    account_info::AccountInfo, entrypoint, entrypoint::ProgramResult, msg, program_error::ProgramError, pubkey::Pubkey,
};

entrypoint!(process_instruction);

fn process_instruction(
    _program_id: &Pubkey,
    _accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    let instruction = SlowSortInstruction::try_from_slice(instruction_data)
        .map_err(|_| ProgramError::InvalidInstructionData)?;

    match instruction {
        SlowSortInstruction::SlowSortFunc { mut a, l, r, sig } => {
            main(&mut a, l, r, &sig)?;
        }
    }
    Ok(())
}

pub fn slowsort(a: &mut Vec<i32>, i: i32, j: i32) -> ProgramResult {
    if i >= j {
        return Ok(());
    }
    let m = (i + j) / 2;
    slowsort(a, i, m)?;
    slowsort(a, m + 1, j)?;
    if a[j as usize] < a[m as usize] {
        exchange(a, j, m);
    }
    slowsort(a, i, j - 1)?;
    Ok(())
}

pub fn main(a: &mut Vec<i32>, l: i32, r: i32, sig: &str) -> ProgramResult {
    slowsort(a, l, r)?;
    emit_sorted("sort/slowSort", sig);
    //msg!("Sorted array: {:?}", a);
    Ok(())
}

pub fn exchange(a: &mut Vec<i32>, q: i32, i: i32) {
    let tmp = a[q as usize];
    a[q as usize] = a[i as usize];
    a[i as usize] = tmp;
}

pub fn emit_sorted(event_type: &str, signature: &str) {
    msg!("{} {}", event_type, signature);
}

pub enum SlowSortInstruction {
    SlowSortFunc { a: Vec<i32>, l: i32, r: i32, sig: String },
}

impl BorshSerialize for SlowSortInstruction {
    fn serialize<W: std::io::Write>(&self, writer: &mut W) -> std::io::Result<()> {
        match self {
            SlowSortInstruction::SlowSortFunc { a, l, r, sig } => {
                0u32.serialize(writer)?;
                a.serialize(writer)?;
                l.serialize(writer)?;
                r.serialize(writer)?;
                sig.serialize(writer)?;
            }
        }
        Ok(())
    }
}

impl BorshDeserialize for SlowSortInstruction {
    fn deserialize(reader: &mut &[u8]) -> std::io::Result<Self> {
        let discriminant: u32 = BorshDeserialize::deserialize(reader)?;
        match discriminant {
            0 => {
                let a = Vec::<i32>::deserialize(reader)?;
                let l = i32::deserialize(reader)?;
                let r = i32::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                Ok(SlowSortInstruction::SlowSortFunc { a, l, r, sig })
            }
            _ => Err(Error::new(
                ErrorKind::InvalidData,
                "Invalid discriminant value",
            )),
        }
    }
}
