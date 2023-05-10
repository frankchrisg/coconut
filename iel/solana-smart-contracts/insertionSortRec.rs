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
    let instruction = InsertionSortRecInstruction::try_from_slice(instruction_data)
        .map_err(|_| ProgramError::InvalidInstructionData)?;

    match instruction {
        InsertionSortRecInstruction::InsertSortRecFunc { mut arr, l, r, sig } => {
            insert_sort_rec(&mut arr, l, r, &sig)?;
            Ok(())
        }
    }
}

fn insert_sort_rec(arr: &mut Vec<i32>, l: i32, r: i32, sig: &str) -> Result<(), ProgramError> {
    if l < r {
        insert_sort_rec(arr, l, r - 1, sig)?;
        insert(arr, l, r);
    }
    msg!("sort/insertionSortRec {}", sig);
    //msg!("Sorted array: {:?}", arr);
    Ok(())
}

fn insert(arr: &mut Vec<i32>, l: i32, r: i32) {
    if l < r {
        if arr[(r - 1) as usize] > arr[r as usize] {
            exchange(arr, r - 1, r);
        }
        insert(arr, l, r - 1);
    }
}

fn exchange(arr: &mut Vec<i32>, q: i32, i: i32) {
    let tmp = arr[q as usize];
    arr[q as usize] = arr[i as usize];
    arr[i as usize] = tmp;
}

// #[derive(BorshSerialize, BorshDeserialize)]
pub enum InsertionSortRecInstruction {
    InsertSortRecFunc { arr: Vec<i32>, l: i32, r: i32, sig: String },
}

impl BorshSerialize for InsertionSortRecInstruction {
    fn serialize<W: std::io::Write>(&self, writer: &mut W) -> std::io::Result<()> {
        match self {
            InsertionSortRecInstruction::InsertSortRecFunc { arr, l, r, sig } => {
                0u32.serialize(writer)?;
                arr.serialize(writer)?;
                l.serialize(writer)?;
                r.serialize(writer)?;
                sig.serialize(writer)?;
            }
        }
        Ok(())
    }
}

impl BorshDeserialize for InsertionSortRecInstruction {
    fn deserialize(reader: &mut &[u8]) -> std::io::Result<Self> {
        let discriminant: u32 = BorshDeserialize::deserialize(reader)?;
        match discriminant {
            0 => {
                let arr = Vec::<i32>::deserialize(reader)?;
                let l = i32::deserialize(reader)?;
                let r = i32::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                Ok(InsertionSortRecInstruction::InsertSortRecFunc { arr, l, r, sig })
            }
            _ => Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                "Invalid discriminant value",
            )),
        }
    }
}
