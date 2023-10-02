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
    let instruction = HeapSortPartlyRecInstruction::try_from_slice(instruction_data)
        .map_err(|_| ProgramError::InvalidInstructionData)?;

    match instruction {
        HeapSortPartlyRecInstruction::HeapSortPartlyRecFunc { mut arr, l, r, sig } => {
            heap_sort_partly_rec(&mut arr, l, r, &sig)?;
            Ok(())
        }
    }
}

fn heap_sort_partly_rec(arr: &mut Vec<i32>, l: i32, r: i32, sig: &str) -> Result<(), ProgramError> {
    build_heap(arr, l, r);
    heap_sort_2(arr, l, r);
    msg!("sort/heapSortPartlyRec {}", sig);
    //msg!("Sorted array: {:?}", arr);
    Ok(())
}

const K: i32 = 2; // 2, 3

fn heap_sort_2(arr: &mut Vec<i32>, l: i32, r: i32) {
    if r > l {
        exchange(arr, l, r);
        heapify(arr, l, l, r - 1);
        heap_sort_2(arr, l, r - 1);
    }
}

fn build_heap(arr: &mut Vec<i32>, l: i32, r: i32) {
    build_heap_recursive(arr, l, r, (r - l - 1) / K);
}

fn build_heap_recursive(arr: &mut Vec<i32>, l: i32, r: i32, i: i32) {
    if i >= 0 {
        heapify(arr, l, l + i, r);
        build_heap_recursive(arr, l, r, i - 1);
    }
}

fn heapify(arr: &mut Vec<i32>, l: i32, q: i32, r: i32) {
    let mut largest = l + K * (q - l) + 1;
    if largest <= r {
        for i in largest + 1..=largest + K - 1 { //.filter(|i| *i <= r) {
            if i <= r && arr[i as usize] > arr[largest as usize] {
                largest = i;
            }
            if arr[largest as usize] > arr[q as usize] {
                exchange(arr, largest, q);
                heapify(arr, l, largest, r);
            }
        }
    }
}

fn exchange(arr: &mut Vec<i32>, q: i32, i: i32) {
    let tmp = arr[q as usize];
    arr[q as usize] = arr[i as usize];
    arr[i as usize] = tmp;
}

// #[derive(BorshSerialize, BorshDeserialize)]
pub enum HeapSortPartlyRecInstruction {
    HeapSortPartlyRecFunc { arr: Vec<i32>, l: i32, r: i32, sig: String },
}

impl BorshSerialize for HeapSortPartlyRecInstruction {
    fn serialize<W: std::io::Write>(&self, writer: &mut W) -> std::io::Result<()> {
        match self {
            HeapSortPartlyRecInstruction::HeapSortPartlyRecFunc { arr, l, r, sig } => {
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

impl BorshDeserialize for HeapSortPartlyRecInstruction {
    fn deserialize(reader: &mut &[u8]) -> std::io::Result<Self> {
        let discriminant: u32 = BorshDeserialize::deserialize(reader)?;
        match discriminant {
            0 => {
                let arr = Vec::<i32>::deserialize(reader)?;
                let l = i32::deserialize(reader)?;
                let r = i32::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                Ok(HeapSortPartlyRecInstruction::HeapSortPartlyRecFunc { arr, l, r, sig })
            }
            _ => Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                "Invalid discriminant value",
            )),
        }
    }
}
