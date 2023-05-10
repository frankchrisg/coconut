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
    let instruction = BubbleSortRecInstruction::try_from_slice(instruction_data)
        .map_err(|_| ProgramError::InvalidInstructionData)?;

    match instruction {
        BubbleSortRecInstruction::MainFunc { mut arr, l, r, sig } => {
            bubble_sort_rec(&mut arr, l, r, &sig)?;
            Ok(())
        }
    }
}

fn bubble_sort_rec(arr: &mut Vec<i32>, l: i32, r: i32, sig: &str) -> Result<(), ProgramError> {
    bubble_sort_recursive(arr, l, r);
    msg!("sort/bubbleSortRec {}", sig);
    //msg!("Sorted array: {:?}", arr);
    Ok(())
}

fn bubble_sort_recursive(arr: &mut Vec<i32>, l: i32, r: i32) {
    if l < r {
        bubble(arr, l, r);
        bubble_sort_recursive(arr, l, r - 1);
    }
}

fn bubble(arr: &mut Vec<i32>, l: i32, r: i32) {
    if l < r {
        if arr[l as usize] > arr[(l + 1) as usize] {
            exchange(arr, l, l + 1);
        }
        bubble(arr, l + 1, r);
    }
}

fn exchange(arr: &mut Vec<i32>, q: i32, i: i32) {
    let tmp = arr[q as usize];
    arr[q as usize] = arr[i as usize];
    arr[i as usize] = tmp;
}

// #[derive(BorshSerialize, BorshDeserialize)]
pub enum BubbleSortRecInstruction {
    MainFunc { arr: Vec<i32>, l: i32, r: i32, sig: String },
}

impl BorshSerialize for BubbleSortRecInstruction {
    fn serialize<W: std::io::Write>(&self, writer: &mut W) -> std::io::Result<()> {
        match self {
            BubbleSortRecInstruction::MainFunc { arr, l, r, sig } => {
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

impl BorshDeserialize for BubbleSortRecInstruction {
    fn deserialize(reader: &mut &[u8]) -> std::io::Result<Self> {
        let discriminant: u32 = BorshDeserialize::deserialize(reader)?;
        match discriminant {
            0 => {
                let arr = Vec::<i32>::deserialize(reader)?;
                let l = i32::deserialize(reader)?;
                let r = i32::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                Ok(BubbleSortRecInstruction::MainFunc { arr, l, r, sig })
            }
            _ => Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                "Invalid discriminant value",
            )),
        }
    }
}
