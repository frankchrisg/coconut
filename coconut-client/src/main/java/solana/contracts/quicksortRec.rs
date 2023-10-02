use solana_program::{
    account_info::AccountInfo,
    entrypoint,
    entrypoint::ProgramResult,
    msg,
    program_error::ProgramError,
    pubkey::Pubkey,
};
use borsh::{BorshDeserialize, BorshSerialize};

entrypoint!(process_instruction);
pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    let instruction = QuickSortRecInstruction::try_from_slice(instruction_data)
        .map_err(|_| ProgramError::InvalidInstructionData)?;

    match instruction {
        QuickSortRecInstruction::Main { mut a, l, r, sig } => main(&mut a, l, r, &sig),
    }
}

pub enum QuickSortRecInstruction {
    Main {
        a: Vec<i32>,
        l: i32,
        r: i32,
        sig: String,
    },
}

impl BorshSerialize for QuickSortRecInstruction {
    fn serialize<W: std::io::Write>(&self, writer: &mut W) -> std::io::Result<()> {
        match self {
            QuickSortRecInstruction::Main { a, l, r, sig } => {
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

impl BorshDeserialize for QuickSortRecInstruction {
    fn deserialize(reader: &mut &[u8]) -> std::io::Result<Self> {
        let discriminant: u32 = BorshDeserialize::deserialize(reader)?;
        match discriminant {
            0 => {
                let a = Vec::<i32>::deserialize(reader)?;
                let l = i32::deserialize(reader)?;
                let r = i32::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                Ok(QuickSortRecInstruction::Main { a, l, r, sig })
            }
            _ => Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                "Invalid discriminant value",
            )),
        }
    }
}

pub fn main(a: &mut Vec<i32>, l: i32, r: i32, sig: &str) -> ProgramResult {
    quicksort(a, l, r)?;
    emit_sorted("sort/quickSortRec", sig);
    //msg!("Sorted array: {:?}", a);
    Ok(())
}

pub fn quicksort(a: &mut Vec<i32>, l: i32, r: i32) -> Result<(), ProgramError> {
    if l < r {
        let q = partition(a, l, r)?;
        quicksort(a, l, q)?;
        quicksort(a, q + 1, r)?;
    }
    Ok(())
}

pub fn partition(a: &mut Vec<i32>, l: i32, r: i32) -> Result<i32, ProgramError> {
    let x = a[((l + r) / 2) as usize];
    let i = l - 1;
    let j = r + 1;
    partition1(a, x, i, j)
}

pub fn partition1(a: &mut Vec<i32>, x: i32, i: i32, j: i32) -> Result<i32, ProgramError> {
    let j = j - 1;
    if a[j as usize] > x {
        partition1(a, x, i, j)
    } else {
        partition2(a, x, i, j)
    }
}

pub fn partition2(a: &mut Vec<i32>, x: i32, i: i32, j: i32) -> Result<i32, ProgramError> {
    let i = i + 1;
    if a[i as usize] < x {
        partition2(a, x, i, j)
    } else {
        if i < j {
            exchange(a, i, j);
            partition1(a, x, i, j)
        } else {
            Ok(j)
        }
    }
}

pub fn exchange(a: &mut Vec<i32>, i: i32, j: i32) {
    let tmp = a[i as usize];
    a[i as usize] = a[j as usize];
    a[j as usize] = tmp;
}

pub fn emit_sorted(event_type: &str, signature: &str) {
    msg!("{} {}", event_type, signature);
}
