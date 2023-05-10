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
    let instruction = MergeSortBreadthFirstInstruction::try_from_slice(instruction_data)
        .map_err(|_| ProgramError::InvalidInstructionData)?;

    match instruction {
        MergeSortBreadthFirstInstruction::MergeSortFunc { mut arr, l, r, sig } => {
            merge_sort(&mut arr, l, r, &sig)?;
            Ok(())
        }
    }
}

fn merge_sort(arr: &mut Vec<i32>, l: i32, r: i32, sig: &str) -> Result<(), ProgramError> {
    /*for m in (1..=r - l).step_by(m) {
        for i in (l..=r).step_by(m * 2) {
            merge(arr, i, i + m - 1, i + 2 * m - 1);
        }
    }*/

    let mut m = 1;
    while m <= r - l {
        let mut i = l;
        while i <= r {
            merge(arr, i, i + m - 1, i + 2 * m - 1);
            i = i + m * 2;
        };
        m = m + m;
    };

    msg!("sort/mergeSortBreadthFirst {}", sig);
    //msg!("Sorted array: {:?}", arr);
    Ok(())
}

fn merge(arr: &mut Vec<i32>, l: i32, q: i32, r: i32) {
    let mut b: Vec<i32> = vec![0; arr.len()];
    for i in l..=q {
        b[i as usize] = arr[i as usize];
    }
    for j in q + 1..=r {
        b[(r + q + 1 - j) as usize] = arr[j as usize];
    }
    let mut s = l;
    let mut t = r;
    for k in l..=r {
        if b[s as usize] <= b[t as usize] {
            arr[k as usize] = b[s as usize];
            s += 1;
        } else {
            arr[k as usize] = b[t as usize];
            t -= 1;
        }
    }
}

// #[derive(BorshSerialize, BorshDeserialize)]
pub enum MergeSortBreadthFirstInstruction {
    MergeSortFunc { arr: Vec<i32>, l: i32, r: i32, sig: String },
}

impl BorshSerialize for MergeSortBreadthFirstInstruction {
    fn serialize<W: std::io::Write>(&self, writer: &mut W) -> std::io::Result<()> {
        match self {
            MergeSortBreadthFirstInstruction::MergeSortFunc { arr, l, r, sig } => {
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

impl BorshDeserialize for MergeSortBreadthFirstInstruction {
    fn deserialize(reader: &mut &[u8]) -> std::io::Result<Self> {
        let discriminant: u32 = BorshDeserialize::deserialize(reader)?;
        match discriminant {
            0 => {
                let arr = Vec::<i32>::deserialize(reader)?;
                let l = i32::deserialize(reader)?;
                let r = i32::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                Ok(MergeSortBreadthFirstInstruction::MergeSortFunc { arr, l, r, sig })
            }
            _ => Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                "Invalid discriminant value",
            )),
        }
    }
}
