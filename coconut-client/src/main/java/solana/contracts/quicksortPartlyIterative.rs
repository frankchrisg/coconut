use solana_program::{
    account_info::AccountInfo, entrypoint, entrypoint::ProgramResult, msg, program_error::ProgramError, pubkey::Pubkey,
};
use borsh::{BorshDeserialize, BorshSerialize};

pub enum QuickSortPartlyIterativeInstruction {
    Main {
        a: Vec<i32>,
        l: i32,
        r: i32,
        sig: String,
    },
}

impl BorshSerialize for QuickSortPartlyIterativeInstruction {
    fn serialize<W: std::io::Write>(&self, writer: &mut W) -> std::io::Result<()> {
        match self {
            QuickSortPartlyIterativeInstruction::Main { a, l, r, sig } => {
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

impl BorshDeserialize for QuickSortPartlyIterativeInstruction {
    fn deserialize(reader: &mut &[u8]) -> std::io::Result<Self> {
        let discriminant: u32 = BorshDeserialize::deserialize(reader)?;
        match discriminant {
            0 => {
                let a = Vec::<i32>::deserialize(reader)?;
                let l = i32::deserialize(reader)?;
                let r = i32::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                Ok(QuickSortPartlyIterativeInstruction::Main { a, l, r, sig })
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
    input: &[u8],
) -> ProgramResult {
    let instruction = QuickSortPartlyIterativeInstruction::try_from_slice(input)?;
    match instruction {
        QuickSortPartlyIterativeInstruction::Main { mut a, l, r, sig } => {
            main(&mut a, l, r, &sig)?;
        }
    }
    Ok(())
}

pub fn main(a: &mut Vec<i32>, l: i32, r: i32, sig: &str) -> ProgramResult {
    quicksort(a, l, r)?;
    emit_sorted("sort/quickSortPartlyIterative", sig);
    //msg!("Sorted array: {:?}", a);
    Ok(())
}

pub fn quicksort(a: &mut Vec<i32>, l: i32, r: i32) -> ProgramResult {
    if l < r {
        let q = partition(a, l, r)?;
        quicksort(a, l, q)?;
        quicksort(a, q + 1, r)?;
    }
    Ok(())
}

pub fn partition(a: &mut Vec<i32>, l: i32, r: i32) -> Result<i32, ProgramError> {
    let x = a[((l + r) / 2) as usize];
    let mut i = l - 1;
    let mut j = r + 1;
    loop {
        loop {
            j -= 1;
            if a[j as usize] <= x {
                break;
            }
        }
        loop {
            i += 1;
            if a[i as usize] >= x {
                break;
            }
        }
        if i < j {
            exchange(a, i, j);
        } else {
            return Ok(j);
        }
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
