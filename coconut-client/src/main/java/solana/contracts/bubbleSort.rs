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
    let instruction = BubbleSortInstruction::try_from_slice(instruction_data)
        .map_err(|_| ProgramError::InvalidInstructionData)?;

    match instruction {
        BubbleSortInstruction::BubbleSortFunc { mut arr, l, r, sig } => {
            bubble_sort(&mut arr, l, r, &sig)?;
            Ok(())
        }
    }
}

fn bubble_sort(arr: &mut Vec<i32>, l: i32, r: i32, sig: &str) -> Result<(), ProgramError> {
    for i in ((l + 1)..=r).rev() {
        for j in l..i {
            if arr[j as usize] > arr[(j + 1) as usize] {
                exchange(arr, j, j + 1);
            }
        }
    }

    msg!("sort/bubbleSort {}", sig);
    //msg!("Sorted array: {:?}", arr);
    Ok(())
}

fn exchange(arr: &mut Vec<i32>, q: i32, i: i32) {
    let tmp = arr[q as usize];
    arr[q as usize] = arr[i as usize];
    arr[i as usize] = tmp;
}

// #[derive(BorshSerialize, BorshDeserialize)]
pub enum BubbleSortInstruction {
    BubbleSortFunc { arr: Vec<i32>, l: i32, r: i32, sig: String },
}

impl BorshSerialize for BubbleSortInstruction {
    fn serialize<W: std::io::Write>(&self, writer: &mut W) -> std::io::Result<()> {
        match self {
            BubbleSortInstruction::BubbleSortFunc { arr, l, r, sig } => {
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

impl BorshDeserialize for BubbleSortInstruction {
    fn deserialize(reader: &mut &[u8]) -> std::io::Result<Self> {
        let discriminant: u32 = BorshDeserialize::deserialize(reader)?;
        match discriminant {
            0 => {
                let arr = Vec::<i32>::deserialize(reader)?;
                let l = i32::deserialize(reader)?;
                let r = i32::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                Ok(BubbleSortInstruction::BubbleSortFunc { arr, l, r, sig })
            }
            _ => Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                "Invalid discriminant value",
            )),
        }
    }
}
