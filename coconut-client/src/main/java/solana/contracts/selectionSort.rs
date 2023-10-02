use solana_program::{
    account_info::AccountInfo,
    entrypoint,
    entrypoint::ProgramResult,
    msg,
    program_error::ProgramError,
    pubkey::Pubkey,
};
use borsh::{BorshDeserialize, BorshSerialize};

pub enum SelectSortInstruction {
    SelectSortFunc { a: Vec<i32>, l: i32, r: i32, sig: String },
}

entrypoint!(process_instruction);

pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    let instruction = SelectSortInstruction::try_from_slice(instruction_data)
        .map_err(|_| ProgramError::InvalidInstructionData)?;

    match instruction {
        SelectSortInstruction::SelectSortFunc { a, l, r, sig } => {
            let mut a = a;
            selectsort(&mut a, l, r, &sig)?;
        }
    }
    Ok(())
}

pub fn selectsort(a: &mut Vec<i32>, l: i32, r: i32, sig: &str) -> ProgramResult {
    for i in ((l + 1)..=r).rev() {
        let mut q = l;
        for j in l + 1..=i {
            if a[j as usize] > a[q as usize] {
                q = j;
            }
        }
        exchange(a, q, i);
    }
    emit_sorted("sort/selectionSort", sig);
    //msg!("Sorted array: {:?}", a);
    Ok(())
}

pub fn exchange(a: &mut Vec<i32>, q: i32, i: i32) {
    let tmp = a[q as usize];
    a[q as usize] = a[i as usize];
    a[i as usize] = tmp;
}

pub fn emit_sorted(event_type: &str, signature: &str) {
    msg!("{} {}", event_type, signature);
}

impl BorshSerialize for SelectSortInstruction {
    fn serialize<W: std::io::Write>(&self, writer: &mut W) -> std::io::Result<()> {
        match self {
            SelectSortInstruction::SelectSortFunc { a, l, r, sig } => {
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

impl BorshDeserialize for SelectSortInstruction {
    fn deserialize(reader: &mut &[u8]) -> std::io::Result<Self> {
        let discriminant: u32 = BorshDeserialize::deserialize(reader)?;
        match discriminant {
            0 => {
                let a = Vec::<i32>::deserialize(reader)?;
                let l = i32::deserialize(reader)?;
                let r = i32::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                Ok(SelectSortInstruction::SelectSortFunc { a, l, r, sig })
            }
            _ => Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                "Invalid discriminant value",
            )),
        }
    }
}
