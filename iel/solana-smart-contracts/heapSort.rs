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
    let instruction = HeapSortInstruction::try_from_slice(instruction_data)
        .map_err(|_| ProgramError::InvalidInstructionData)?;

    match instruction {
        HeapSortInstruction::HeapSortFunc { mut arr, l, r, sig } => {
            heap_sort(&mut arr, l, r, &sig)?;
            Ok(())
        }
    }
}

fn heap_sort(arr: &mut Vec<i32>, l: i32, r: i32, sig: &str) -> Result<(), ProgramError> {
    build_heap(arr, l, r);
    //for i in (l + 1..=r).rev() {
    for i in (l..=r).rev() {
        exchange(arr, l, i);
        heapify(arr, l, l, i - 1);
    }
    msg!("sort/heapSort {}", sig);
    //msg!("Sorted array: {:?}", arr);
    Ok(())
}

const K: i32 = 2; // 2, 3

fn build_heap(arr: &mut Vec<i32>, l: i32, r: i32) {
    //for i in ((r - l - 1) / K..=0).rev() {
    let start = (r - l - K) / K;
    for i in (0..=start).rev() {
        heapify(arr, l, l + i, r);
    }
}

fn heapify(arr: &mut Vec<i32>, l: i32, q: i32, r: i32) {
    let mut q = q;
    loop {
        let mut largest = l + K * (q - l) + 1;
        if largest <= r {
            for i in largest + 1..=largest + K - 1 { //.filter(|i| *i <= r) {
                if i <= r && arr[i as usize] > arr[largest as usize] {
                    largest = i;
                }
            }
            if arr[largest as usize] > arr[q as usize] {
                exchange(arr, largest, q);
                q = largest;
            } else {
                break;
            }
        } else {
            break;
        }
    }
}

fn exchange(arr: &mut Vec<i32>, q: i32, i: i32) {
    let tmp = arr[q as usize];
    arr[q as usize] = arr[i as usize];
    arr[i as usize] = tmp;
}

// #[derive(BorshSerialize, BorshDeserialize)]
pub enum HeapSortInstruction {
    HeapSortFunc { arr: Vec<i32>, l: i32, r: i32, sig: String },
}

impl BorshSerialize for HeapSortInstruction {
    fn serialize<W: std::io::Write>(&self, writer: &mut W) -> std::io::Result<()> {
        match self {
            HeapSortInstruction::HeapSortFunc { arr, l, r, sig } => {
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

impl BorshDeserialize for HeapSortInstruction {
    fn deserialize(reader: &mut &[u8]) -> std::io::Result<Self> {
        let discriminant: u32 = BorshDeserialize::deserialize(reader)?;
        match discriminant {
            0 => {
                let arr = Vec::<i32>::deserialize(reader)?;
                let l = i32::deserialize(reader)?;
                let r = i32::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                Ok(HeapSortInstruction::HeapSortFunc { arr, l, r, sig })
            }
            _ => Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                "Invalid discriminant value",
            )),
        }
    }
}
