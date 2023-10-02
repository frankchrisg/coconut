use solana_program::{
    account_info::AccountInfo,
    entrypoint,
    entrypoint::ProgramResult,
    msg,
    program_error::ProgramError,
    pubkey::Pubkey,
};
use std::io::{Error, ErrorKind, Write};
use borsh::{BorshDeserialize, BorshSerialize};

entrypoint!(process_instruction);
pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    let instruction = MergeSortInstruction::try_from_slice(instruction_data)
        .map_err(|_| ProgramError::InvalidInstructionData)?;

    match instruction {
        MergeSortInstruction::MergeSortFunc { mut a, l, r, sig } => {
            main(&mut a, l, r, &sig)?;
            Ok(())
        }
    }
}

pub fn main(a: &mut Vec<i32>, l: i32, r: i32, sig: &str) -> ProgramResult {
    mergesort(a, l, r)?;
    emit_sorted("sort/mergeSortRec", sig);
    //msg!("Sorted array: {:?}", a);
    Ok(())
}

pub fn mergesort(a: &mut Vec<i32>, l: i32, r: i32) -> ProgramResult {
    if l < r {
        let q = (l + r) / 2;
        mergesort(a, l, q)?;
        mergesort(a, q + 1, r)?;
        merge(a, l, q, r)?;
    }
    Ok(())
}

pub fn merge(a: &mut Vec<i32>, l: i32, q: i32, r: i32) -> ProgramResult {
    let mut b: Vec<i32> = vec![0; a.len()];
    for i in l..=q {
        b[i as usize] = a[i as usize];
    }
    for j in (q + 1)..=r {
        b[(r + q + 1 - j) as usize] = a[j as usize];
    }
    let mut s = l;
    let mut t = r;
    for k in l..=r {
        if b[s as usize] <= b[t as usize] {
            a[k as usize] = b[s as usize];
            s += 1;
        } else {
            a[k as usize] = b[t as usize];
            t -= 1;
        }
    }
    Ok(())
}

pub fn emit_sorted(event_type: &str, signature: &str) {
    msg!("{} {}", event_type, signature);
}

pub enum MergeSortInstruction {
    MergeSortFunc {
        a: Vec<i32>,
        l: i32,
        r: i32,
        sig: String,
    },
}

impl BorshSerialize for MergeSortInstruction {
    fn serialize<W: Write>(&self, writer: &mut W) -> Result<(), Error> {
        match self {
            MergeSortInstruction::MergeSortFunc { a, l, r, sig } => {
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

impl BorshDeserialize for MergeSortInstruction {
    fn deserialize(reader: &mut &[u8]) -> Result<Self, Error> {
        let discriminant: u32 = BorshDeserialize::deserialize(reader)?;
        match discriminant {
            0 => {
                let a = Vec::<i32>::deserialize(reader)?;
                let l = i32::deserialize(reader)?;
                let r = i32::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                Ok(MergeSortInstruction::MergeSortFunc { a, l, r, sig })
            }
            _ => Err(Error::new(
                ErrorKind::InvalidData,
                "Invalid discriminant value",
            )),
        }
    }
}
