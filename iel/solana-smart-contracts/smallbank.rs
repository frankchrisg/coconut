use borsh::{BorshDeserialize, BorshSerialize};
use solana_program::{
    account_info::{next_account_info, AccountInfo},
    entrypoint, entrypoint::ProgramResult, msg, program_error::ProgramError, pubkey::Pubkey,
};
use solana_program::sysvar::rent::Rent;
use solana_program::sysvar::Sysvar;
use std::collections::HashMap;

pub const CHECKING_SUFFIX: &str = "_checking";
pub const SAVINGS_SUFFIX: &str = "_savings";

#[derive(BorshSerialize)]
pub struct SmallBankAccount {
    pub entries: std::collections::HashMap<String, i32>,
    pub exists: std::collections::HashMap<String, bool>,
}

impl BorshDeserialize for SmallBankAccount {
    fn deserialize(buf: &mut &[u8]) -> std::io::Result<Self> {
        let entries_len: u32 = BorshDeserialize::deserialize(buf)?;
        let mut entries = HashMap::with_capacity(entries_len as usize);

        for _ in 0..entries_len {
            let key = String::deserialize(buf)?;
            let value = i32::deserialize(buf)?;
            entries.insert(key, value);
        }

        let exists_len: u32 = BorshDeserialize::deserialize(buf)?;
        let mut exists = HashMap::with_capacity(exists_len as usize);

        for _ in 0..exists_len {
            let key = String::deserialize(buf)?;
            let value = bool::deserialize(buf)?;
            exists.insert(key, value);
        }

        // Ignore any remaining bytes
        *buf = &buf[buf.len()..];

        Ok(SmallBankAccount { entries, exists })
    }
}

impl Default for SmallBankAccount {
    fn default() -> Self {
        SmallBankAccount {
            entries: std::collections::HashMap::new(),
            exists: std::collections::HashMap::new(),
        }
    }
}

// #[derive(BorshSerialize, BorshDeserialize)]
pub enum SmallBankInstruction {
    WriteCheck {
        acct_id: String,
        amount: i32,
        sig: String,
    },
    DepositChecking {
        acct_id: String,
        amount: i32,
        sig: String,
    },
    TransactSavings {
        acct_id: String,
        amount: i32,
        sig: String,
    },
    SendPayment {
        sender_pubkey: Pubkey,
        destination_pubkey: Pubkey,
        sender_acct_id: String,
        destination_acct_id: String,
        amount: i32,
        sig: String,
    },
    Balance {
        acct_id: String,
        sig: String,
    },
    Amalgamate {
        sender_pubkey: Pubkey,
        destination_pubkey: Pubkey,
        acct_id0: String,
        acct_id1: String,
        sig: String,
    },
    CreateAccount {
        acct_id: String,
        checking: i32,
        savings: i32,
        sig: String,
    },
}

entrypoint!(process_instruction);
fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    let accounts_iter = &mut accounts.iter();
    let account = next_account_info(accounts_iter)?;
    let rent = &Rent::from_account_info(next_account_info(accounts_iter)?)?;

    if account.owner != program_id {
        msg!("Account does not have the correct program id");
        return Err(ProgramError::IncorrectProgramId);
    }

    if !account.is_writable {
        msg!("SmallBank storage account is not writable");
        return Err(ProgramError::InvalidAccountData);
    }

    if !rent.is_exempt(account.lamports(), account.data_len()) {
        msg!("Smallbank storage account not rent-exempt");
        return Err(ProgramError::AccountNotRentExempt);
    }

    //let mut small_bank_account = SmallBankAccount::try_from_slice(&account.data.borrow())?;

    let mut small_bank_account = if account.data_is_empty() {
        SmallBankAccount::default()
    } else {
        SmallBankAccount::from_account_data(&account.data.borrow())?
    };

    let instruction =
        SmallBankInstruction::try_from_slice(instruction_data).map_err(|_| ProgramError::InvalidInstructionData)?;

    match instruction {
        SmallBankInstruction::WriteCheck {
            acct_id,
            amount,
            sig,
        } => {
            small_bank_account.write_check(&acct_id, amount, &sig)?;
        }
        SmallBankInstruction::DepositChecking {
            acct_id,
            amount,
            sig,
        } => {
            small_bank_account.deposit_checking(&acct_id, amount, &sig)?;
        }
        SmallBankInstruction::TransactSavings {
            acct_id,
            amount,
            sig,
        } => {
            small_bank_account.transact_savings(&acct_id, amount, &sig)?;
        }
        SmallBankInstruction::SendPayment { sender_pubkey, destination_pubkey, sender_acct_id, destination_acct_id, amount, sig } => {
            /*msg!("Accounts iterator:");
            for account in accounts_iter.clone() {
                msg!("Account key: {}", account.key);
            }*/

            let sender_account = accounts_iter
                .find(|account| account.key == &sender_pubkey)
                .ok_or(ProgramError::MissingRequiredSignature)?;
//msg!("Found sender account with key: {:?}", sender_account.key);

            let destination_account = accounts_iter
                .find(|account| account.key == &destination_pubkey)
                .ok_or(ProgramError::MissingRequiredSignature)?;
//msg!("Found destination account with key: {:?}", destination_account.key);

            return small_bank_account.send_payment(
                sender_account,
                destination_account,
                &sender_acct_id,
                &destination_acct_id,
                amount,
                &sig,
            );
        }

        SmallBankInstruction::Balance { acct_id, sig } => {
            small_bank_account.balance(&acct_id, &sig)?;
        }
        SmallBankInstruction::Amalgamate {
            sender_pubkey,
            destination_pubkey,
            acct_id0,
            acct_id1,
            sig,
        } => {
            let sender_account = accounts_iter
                .find(|account| account.key == &sender_pubkey)
                .ok_or(ProgramError::MissingRequiredSignature)?;
            let destination_account = accounts_iter
                .find(|account| account.key == &destination_pubkey)
                .ok_or(ProgramError::MissingRequiredSignature)?;

            //small_bank_account.amalgamate(&acct_id0, &acct_id1, &sig)?;
            small_bank_account.amalgamate(&sender_account, &destination_account, &acct_id0, &acct_id1, &sig)?;
        }
        SmallBankInstruction::
        CreateAccount {
            acct_id,
            checking,
            savings,
            sig,
        } => {
            small_bank_account.create_account(&acct_id, checking, savings, &sig)?;
        }
    }

    small_bank_account.to_account_data(&mut account.data.borrow_mut())?;
    //small_bank_account.serialize(&mut &mut account.data.borrow_mut()[..])?;
    Ok(())
}

impl SmallBankAccount {
    pub fn from_account_data(account_data: &[u8]) -> Result<Self, ProgramError> {
        match SmallBankAccount::try_from_slice(account_data) {
            Ok(small_bank_account) => Ok(Self {
                entries: small_bank_account.entries,
                exists: small_bank_account.exists,
            }),
            Err(_) => Err(ProgramError::InvalidAccountData),
        }
    }

    pub fn to_account_data(&self, account_data: &mut [u8]) -> Result<(), ProgramError> {
        let data = self.entries.try_to_vec().map_err(|_| ProgramError::InvalidAccountData)?;

        // Zero out the account_data slice
        //account_data.iter_mut().for_each(|byte| *byte = 0);

        account_data[..data.len()].copy_from_slice(&data);
        Ok(())
    }

    pub fn write_check(&mut self, acct_id: &str, amount: i32, sig: &str) -> ProgramResult {
        let savings_key = get_savings(acct_id);
        let checking_key = get_checking(acct_id);
        if !self.exists.get(&savings_key).unwrap_or(&false)
            || !self.exists.get(&checking_key).unwrap_or(&false)
            || amount < 0
        {
            emit_error_event("writeCheck/error", sig);
            return Ok(());
        }

        let savings = self.entries.get(&savings_key).unwrap_or(&0);
        let checks = self.entries.get(&checking_key).unwrap_or(&0);
        let total = savings + checks;

        if total < amount {
            self.entries.insert(checking_key.clone(), checks - amount - 1);
        } else {
            self.entries.insert(checking_key.clone(), checks - amount);
        }

        emit_write_check_event("writeCheck", sig);
        Ok(())
    }

    pub fn deposit_checking(&mut self, acct_id: &str, amount: i32, sig: &str) -> ProgramResult {
        let checking_key = get_checking(acct_id);

        if !self.exists.get(&checking_key).unwrap_or(&false) {
            emit_error_event("depositChecking/error", sig);
            return Ok(());
        }

        let checks = self.entries.get(&checking_key).unwrap_or(&0);
        self.entries.insert(checking_key.clone(), checks + amount);
        emit_deposit_checking_event("depositChecking", sig);
        Ok(())
    }

    pub fn transact_savings(&mut self, acct_id: &str, amount: i32, sig: &str) -> ProgramResult {
        let savings_key = get_savings(acct_id);

        if !self.exists.get(&savings_key).unwrap_or(&false) {
            emit_error_event("transactSavings/error", sig);
            return Ok(());
        }

        let savings = self.entries.get(&savings_key).unwrap_or(&0);
        let new_balance = *savings - amount;

        if new_balance < 0 {
            emit_error_event("transactSavings/error/balance", sig);
            return Ok(());
        }

        self.entries.insert(savings_key.clone(), savings - amount);
        emit_transact_savings_event("transactSavings", sig);
        Ok(())
    }

    pub fn send_payment(
        &mut self,
        sender_account: &AccountInfo,
        destination_account: &AccountInfo,
        sender_acct_id: &str,
        destination_acct_id: &str,
        amount: i32,
        sig: &str,
    ) -> ProgramResult {
        if !sender_account.is_writable || !destination_account.is_writable {
            msg!("sendPayment/error: accounts must be writable");
            return Err(ProgramError::InvalidAccountData);
        }
        let mut sender_small_bank_account = SmallBankAccount::from_account_data(&sender_account.data.borrow())?;
        let mut destination_small_bank_account = SmallBankAccount::from_account_data(&destination_account.data.borrow())?;

        if let (
            Some(sender_checking_balance),
            Some(destination_checking_balance),
            Some(sender_savings_balance),
            Some(destination_savings_balance),
        ) = (
            sender_small_bank_account.entries.get(&get_checking(sender_acct_id)),
            destination_small_bank_account.entries.get(&get_checking(destination_acct_id)),
            sender_small_bank_account.entries.get(&get_savings(sender_acct_id)),
            destination_small_bank_account.entries.get(&get_savings(destination_acct_id)),
        ) {
            let sender_balance = sender_checking_balance;

            if sender_balance < &amount {
                emit_error_event("sendPayment/error/checkingBalanceSender", sig);
                return Ok(());
            }

            sender_small_bank_account.entries.insert(get_checking(sender_acct_id).to_string(), sender_balance - amount);
            let destination_balance = destination_checking_balance;
            destination_small_bank_account.entries.insert(get_checking(destination_acct_id).to_string(), destination_balance + amount);

            sender_small_bank_account.to_account_data(&mut sender_account.data.borrow_mut())?;
            destination_small_bank_account.to_account_data(&mut destination_account.data.borrow_mut())?;

            emit_send_payment_event("sendPayment", sig);
            Ok(())
        } else {
            emit_error_event("sendPayment/error", sig);
            return Ok(());
        }
    }


    pub fn balance(&mut self, acct_id: &str, sig: &str) -> ProgramResult {
        let savings_key = get_savings(acct_id);
        let checking_key = get_checking(acct_id);

        if !self.exists.get(&savings_key).unwrap_or(&false)
            || !self.exists.get(&checking_key).unwrap_or(&false)
        {
            emit_error_event("balance/error", sig);
            return Ok(());
        }

        let savings = self.entries.get(&savings_key).unwrap_or(&0);
        let checkings = self.entries.get(&checking_key).unwrap_or(&0);

        let total = savings + checkings;

        //emit_balance_event("balance", sig, total);
        emit_balance_event("balance", sig, acct_id, total);
        Ok(())
    }

    pub fn amalgamate(
        &mut self,
        sender_account: &AccountInfo,
        destination_account: &AccountInfo,
        acct_id0: &str,
        acct_id1: &str,
        sig: &str) -> ProgramResult {
        if !sender_account.is_writable || !destination_account.is_writable {
            msg!("amalgamate/error: accounts must be writable");
            return Err(ProgramError::InvalidAccountData);
        }

        let mut sender_small_bank_account = SmallBankAccount::from_account_data(&sender_account.data.borrow())?;
        let mut destination_small_bank_account = SmallBankAccount::from_account_data(&destination_account.data.borrow())?;

        if let (
            Some(sender_checking_balance),
            Some(destination_checking_balance),
            Some(sender_savings_balance),
            Some(destination_savings_balance),
        ) = (
            sender_small_bank_account.entries.get(&get_checking(acct_id0)),
            destination_small_bank_account.entries.get(&get_checking(acct_id1)),
            sender_small_bank_account.entries.get(&get_savings(acct_id0)),
            destination_small_bank_account.entries.get(&get_savings(acct_id1)),
        ) {
            let total = sender_savings_balance + sender_checking_balance;

            sender_small_bank_account.entries.insert(get_checking(acct_id0).to_string(), 0);
            sender_small_bank_account.entries.insert(get_savings(acct_id0).to_string(), 0);

            let checking_balance1 = destination_small_bank_account.entries.get(&get_checking(acct_id1)).unwrap_or(&0);
            destination_small_bank_account.entries.insert(get_checking(acct_id1.clone()), checking_balance1 + total);

            sender_small_bank_account.to_account_data(&mut sender_account.data.borrow_mut())?;
            destination_small_bank_account.to_account_data(&mut destination_account.data.borrow_mut())?;

            emit_amalgamate_event("amalgamate", sig);
            return Ok(());
        } else {
            emit_error_event("amalgamate/error", sig);
            return Ok(());
        }
    }

    pub fn create_account(
        &mut self,
        acct_id: &str,
        checking: i32,
        savings: i32,
        sig: &str,
    ) -> ProgramResult {
        let savings_key = get_savings(acct_id);
        let checking_key = get_checking(acct_id);

        self.exists.insert(savings_key.clone(), true);
        self.exists.insert(checking_key.clone(), true);
        self.entries.insert(savings_key.clone(), savings);
        self.entries.insert(checking_key.clone(), checking);
        emit_create_account_event("createAccount", sig);
        Ok(())
    }
}

fn get_savings(acct_id: &str) -> String {
    format!("{}{}", acct_id, SAVINGS_SUFFIX)
}

fn get_checking(acct_id: &str) -> String {
    format!("{}{}", acct_id, CHECKING_SUFFIX)
}

fn emit_error_event(event_type: &str, signature: &str) {
    msg!("{} {}", event_type, signature);
}

fn emit_write_check_event(event_type: &str, signature: &str) {
    msg!("{} {}", event_type, signature);
}

fn emit_deposit_checking_event(event_type: &str, signature:
&str) {
    msg!("{} {}", event_type, signature);
}

fn emit_transact_savings_event(event_type: &str, signature: &str) {
    msg!("{} {}", event_type, signature);
}

fn emit_send_payment_event(event_type: &str, signature: &str) {
    msg!("{} {}", event_type, signature);
}

/*fn emit_balance_event(event_type: &str, signature: &str, total: i32) {
    msg!("{} {}", event_type, signature);
}*/

fn emit_balance_event(event: &str, sig: &str, acct_id: &str, total: i32) {
    let event_string = format!(
        "{} __balance_event:-balance-{}-acctId-{}",
        sig, total, acct_id
    );
    msg!("{}", event_string);
}

fn emit_amalgamate_event(event_type: &str, signature: &str) {
    msg!("{} {}", event_type, signature);
}

fn emit_create_account_event(event_type: &str, signature: &str) {
    msg!("{} {}", event_type, signature);
}

impl BorshSerialize for SmallBankInstruction {
    fn serialize<W: std::io::Write>(&self, writer: &mut W) -> std::io::Result<()> {
        match self {
            SmallBankInstruction::WriteCheck { acct_id, amount, sig } => {
                0u32.serialize(writer)?;
                acct_id.serialize(writer)?;
                amount.serialize(writer)?;
                sig.serialize(writer)?;
            }
            SmallBankInstruction::DepositChecking { acct_id, amount, sig } => {
                1u32.serialize(writer)?;
                acct_id.serialize(writer)?;
                amount.serialize(writer)?;
                sig.serialize(writer)?;
            }
            SmallBankInstruction::TransactSavings { acct_id, amount, sig } => {
                2u32.serialize(writer)?;
                acct_id.serialize(writer)?;
                amount.serialize(writer)?;
                sig.serialize(writer)?;
            }
            //SmallBankInstruction::SendPayment { sender, destination, amount, sig } => {
            SmallBankInstruction::SendPayment { sender_pubkey, destination_pubkey, sender_acct_id, destination_acct_id, amount, sig } => {
                3u32.serialize(writer)?;
                sender_pubkey.serialize(writer)?;
                destination_pubkey.serialize(writer)?;
                sender_acct_id.serialize(writer)?;
                destination_acct_id.serialize(writer)?;
                amount.serialize(writer)?;
                sig.serialize(writer)?;
            }
            SmallBankInstruction::Balance { acct_id, sig } => {
                4u32.serialize(writer)?;
                acct_id.serialize(writer)?;
                sig.serialize(writer)?;
            }
            SmallBankInstruction::Amalgamate {
                sender_pubkey,
                destination_pubkey,
                acct_id0,
                acct_id1,
                sig,
            } => {
                5u32.serialize(writer)?;
                sender_pubkey.serialize(writer)?;
                destination_pubkey.serialize(writer)?;
                acct_id0.serialize(writer)?;
                acct_id1.serialize(writer)?;
                /*(acct_id0.len() as u32).serialize(writer)?;
                writer.write_all(acct_id0.as_bytes())?;
                (acct_id1.len() as u32).serialize(writer)?;
                writer.write_all(acct_id1.as_bytes())?;*/
                sig.serialize(writer)?;
            }
            SmallBankInstruction::CreateAccount {
                acct_id, checking
                , savings, sig
            } => {
                6u32.serialize(writer)?;
                acct_id.serialize(writer)?;
                checking.serialize(writer)?;
                savings.serialize(writer)?;
                sig.serialize(writer)?;
            }
        }
        Ok(())
    }
}

impl BorshDeserialize for SmallBankInstruction {
    fn deserialize(reader: &mut &[u8]) -> std::io::Result<Self> {
        let discriminant: u32 = BorshDeserialize::deserialize(reader)?;
        match discriminant {
            0 => {
                let acct_id = String::deserialize(reader)?;
                let amount = i32::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                Ok(SmallBankInstruction::WriteCheck { acct_id, amount, sig })
            }
            1 => {
                let acct_id = String::deserialize(reader)?;
                let amount = i32::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                Ok(SmallBankInstruction::DepositChecking { acct_id, amount, sig })
            }
            2 => {
                let acct_id = String::deserialize(reader)?;
                let amount = i32::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                Ok(SmallBankInstruction::TransactSavings { acct_id, amount, sig })
            }
            3 => {
                msg!("Deserializing SendPaymenta");
                let sender_pubkey = Pubkey::deserialize(reader)?;
                let destination_pubkey = Pubkey::deserialize(reader)?;
                let sender_acct_id_len = u32::deserialize(reader)?;
                let sender_acct_id = String::from_utf8_lossy(&read_bytes(reader, sender_acct_id_len as usize)?).to_string();
                let destination_acct_id_len = u32::deserialize(reader)?;
                let destination_acct_id = String::from_utf8_lossy(&read_bytes(reader, destination_acct_id_len as usize)?).to_string();
                let amount = i32::deserialize(reader)?;
                let sig = String::deserialize(reader)?;

                /*msg!("Sender pubkey: {:?}", sender_pubkey);
                msg!("Destination pubkey: {:?}", destination_pubkey);
                msg!("Sender acct ID len: {}", sender_acct_id_len);
                msg!("Sender acct ID: {}", sender_acct_id);
                msg!("Destination acct ID len: {}", destination_acct_id_len);
                msg!("Destination acct ID: {}", destination_acct_id);
                msg!("Amount: {}", amount);
                msg!("Signature: {}", sig);*/

                Ok(SmallBankInstruction::SendPayment { sender_pubkey, destination_pubkey, sender_acct_id, destination_acct_id, amount, sig })
            }
            4 => {
                let acct_id = String::deserialize(reader)?;
                let sig = String::deserialize(reader)?;
                Ok(SmallBankInstruction::Balance { acct_id, sig })
            }
            5 => {
                let sender_pubkey = Pubkey::deserialize(reader)?;
                let destination_pubkey = Pubkey::deserialize(reader)?;
                let acct_id0_len = u32::deserialize(reader)?;
                let acct_id0 = String::from_utf8_lossy(&read_bytes(reader, acct_id0_len as usize)?).to_string();
                let acct_id1_len = u32::deserialize(reader)?;
                let acct_id1 = String::from_utf8_lossy(&read_bytes(reader, acct_id1_len as usize)?).to_string();
                let sig = String::deserialize(reader)?;

        /*msg!("Sender pubkey: {:?}", sender_pubkey);
        msg!("Destination pubkey: {:?}", destination_pubkey);
        msg!("Sender acct ID: {}", acct_id0);
        msg!("Destination acct ID: {}", acct_id1);
        msg!("Signature: {}", sig);*/

Ok(SmallBankInstruction::Amalgamate { sender_pubkey, destination_pubkey, acct_id0, acct_id1, sig })
}
6 => {
let acct_id = String::deserialize(reader)?;
let checking = i32::deserialize(reader)?;
let savings = i32::deserialize(reader)?;
let sig = String::deserialize(reader)?;
Ok(SmallBankInstruction::CreateAccount { acct_id, checking, savings, sig })
}
_ => Err(std::io::Error::new(
std::io::ErrorKind::InvalidData,
"Invalid discriminant value",
)),
}
}
}

fn read_bytes(reader: &mut &[u8], length: usize) -> std::io::Result<Vec<u8>> {
if reader.len() < length {
return Err(std::io::Error::new(
std::io::ErrorKind::UnexpectedEof,
"Not enough bytes to read",
));
}

let (head, tail) = reader.split_at(length);
*reader = tail;
Ok(head.to_vec())
}
