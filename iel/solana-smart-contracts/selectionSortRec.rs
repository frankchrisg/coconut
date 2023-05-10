use solana_program::{
    account_info::AccountInfo,
    entrypoint,
    entrypoint::ProgramResult,
    msg,
    program_error::ProgramError,
    pubkey::Pubkey,
};

use borsh::{BorshDeserialize, BorshSerialize};
use std::io::{Write, Error, ErrorKind};

entrypoint!(process_instruction);

pub fn selectsort_rec(a: &mut Vec<i32>, l: i32, r: i32, sig: &str) -> ProgramResult {
    if l < r {
        let q = max(a, l, l + 1, r)?;
        exchange(a, q, r);
        selectsort_rec(a, l, r - 1, sig)?;
    }
    Ok(())
}

pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    let instruction = SelectionSortRecInstruction::try_from_slice(instruction_data)
        .map_err(|_| ProgramError::InvalidInstructionData)?;

    match instruction {
        SelectionSortRecInstruction::Main { mut a, l, r, sig } => {
            main(&mut a, l, r, &sig)?;
        }
    }
    Ok(())
}

pub fn main(a: &mut Vec<i32>, l: i32, r: i32, sig: &str) -> ProgramResult {
    selectsort_rec(a, l, r, sig)?;
    emit_sorted("sort/selectionSortRec", sig);
    //msg!("Sorted array: {:?}", a);
    Ok(())
}

pub fn max(a: &Vec<i32>, q: i32, l: i32, r: i32) -> Result<i32, ProgramError> {
    if l <= r {
        if a[l as usize] > a[q as usize] {
            return max(a, l, l + 1, r);
        } else {
            return max(a, q, l + 1, r);
        }
    } else {
        return Ok(q);
    }
}

pub fn exchange(a: &mut Vec<i32>, q: i32, i: i32) {
    let tmp = a[q as usize];
    a[q as usize] = a[i as usize];
    a[i as usize] = tmp;
}

pub fn emit_sorted(event_type: &str, signature: &str) {
    msg!("{} {}", event_type, signature);
}

pub enum SelectionSortRecInstruction {
    Main {
        a: Vec<i32>,
        l: i32,
        r: i32,
        sig: String,
    },
}

impl BorshSerialize for SelectionSortRecInstruction {
    fn serialize<W: Write>(&self, writer: &mut W) -> std::io::Result<()> {
        match self {
            SelectionSortRecInstruction::Main { a, l, r, sig } => {
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

impl BorshDeserialize for SelectionSortRecInstruction {
    fn deserialize(reader: &mut &[u8]) -> std::io::Result<Self> {
        let discriminant: u32 = BorshDeserialize::deserialize(reader)?;
        match discriminant {
            0 => {
                let a = Vec::<i32>::deserialize(reader)?;
                let l = i32::deserialize(reader)?;
                let r = i32::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                Ok(SelectionSortRecInstruction::Main { a, l, r, sig })
            }
            _ => Err(Error::new(
                ErrorKind::InvalidData,
                "Invalid discriminant value",
            )),
        }
    }
}
