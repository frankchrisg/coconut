module 0x1::SmallBank {

    use Std::Event;
    use Std::Signer;
    use Std::Vector;

    struct SmallBank has key, store {
        savings: u64,
        checking: u64
    }

    fun write_check_fun(account: &signer, amount: u64, sig: vector<u8>): () acquires SmallBank {
        let owner = Signer::address_of(account);
        let exist = exists<SmallBank>(owner);
        let collection = borrow_global_mut<SmallBank>(owner);

        if (!exist /*|| amount < 0*/) {
            let handle = Event::new_event_handle<vector<u8>>(account);
            let prefix: vector<u8> = b"writeCheck/error ";
            Vector::append(&mut prefix, sig);
            Event::emit_event(&mut handle, prefix);
            Event::destroy_handle(handle);
            return ()
        };

        let savings: u64 = collection.savings;
        let checks: u64 = collection.checking;
        let total: u64 = savings + checks;

        if (total < amount) {
            collection.checking = checks - amount - 1;
        } else {
            collection.checking = checks - amount;
        };

        let handle = Event::new_event_handle<vector<u8>>(account);
        let prefix: vector<u8> = b"writeCheck ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }

    fun deposit_checking_fun(account: &signer, amount: u64, sig: vector<u8>): () acquires SmallBank {
        let owner = Signer::address_of(account);
        let exist = exists<SmallBank>(owner);
        let collection = borrow_global_mut<SmallBank>(owner);

        if (!exist) {
            let handle = Event::new_event_handle<vector<u8>>(account);
            let prefix: vector<u8> = b"depositChecking/error ";
            Vector::append(&mut prefix, sig);
            Event::emit_event(&mut handle, prefix);
            Event::destroy_handle(handle);
            return ()
        };

        collection.checking = collection.checking + amount;

        let handle = Event::new_event_handle<vector<u8>>(account);
        let prefix: vector<u8> = b"depositChecking ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }

    fun transact_savings_fun(account: &signer, amount: u64, sig: vector<u8>): () acquires SmallBank {
        let owner = Signer::address_of(account);
        let exist = exists<SmallBank>(owner);
        let collection = borrow_global_mut<SmallBank>(owner);

        if (!exist) {
            let handle = Event::new_event_handle<vector<u8>>(account);
            let prefix: vector<u8> = b"transactSavings/error ";
            Vector::append(&mut prefix, sig);
            Event::emit_event(&mut handle, prefix);
            Event::destroy_handle(handle);
            return ()
        };

        let balance = collection.savings - amount;

        if (balance < 0) {
            let handle = Event::new_event_handle<vector<u8>>(account);
            let prefix: vector<u8> = b"transactSavings/error/balance ";
            Vector::append(&mut prefix, sig);
            Event::emit_event(&mut handle, prefix);
            Event::destroy_handle(handle);
            return ()
        };

        let handle = Event::new_event_handle<vector<u8>>(account);
        let prefix: vector<u8> = b"transactSavings ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }

    fun send_payment_fun(sender: &signer, destination: address, amount: u64, sig: vector<u8>): () acquires SmallBank {
        let sender_addr = Signer::address_of(sender);
        let exist_sender = exists<SmallBank>(sender_addr);
        let collection_sender = borrow_global_mut<SmallBank>(sender_addr);

        let exist_destination = exists<SmallBank>(destination);

        if (!exist_sender || !exist_destination) {
            let handle = Event::new_event_handle<vector<u8>>(sender);
            let prefix: vector<u8> = b"sendPayment/error ";
            Vector::append(&mut prefix, sig);
            Event::emit_event(&mut handle, prefix);
            Event::destroy_handle(handle);
            return ()
        };

        let checking_balance_sender = collection_sender.checking;
        if (checking_balance_sender < amount) {
            let handle = Event::new_event_handle<vector<u8>>(sender);
            let prefix: vector<u8> = b"sendPayment/error/checkingBalanceSender ";
            Vector::append(&mut prefix, sig);
            Event::emit_event(&mut handle, prefix);
            Event::destroy_handle(handle);
            return ()
        };

        collection_sender.checking = collection_sender.checking - amount;

        let collection_destination = borrow_global_mut<SmallBank>(destination);

        collection_destination.checking = collection_destination.checking + amount;

        let handle = Event::new_event_handle<vector<u8>>(sender);
        let prefix: vector<u8> = b"sendPayment ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }

    fun balance_fun(account: &signer, sig: vector<u8>)/*: u64*/ acquires SmallBank {
        let owner = Signer::address_of(account);
        let exist = exists<SmallBank>(owner);
        let collection = borrow_global_mut<SmallBank>(owner);

        if (!exist) {
            let handle = Event::new_event_handle<vector<u8>>(account);
            let prefix: vector<u8> = b"balance/error ";
            Vector::append(&mut prefix, sig);
            Event::emit_event(&mut handle, prefix);
            Event::destroy_handle(handle);
            return ()
        };

        let savings = collection.savings;
        let checkings = collection.checking;

        let _total = savings + checkings;

        let handle = Event::new_event_handle<vector<u8>>(account);
        let prefix: vector<u8> = b"balance ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);

        //return total
    }

    fun amalgamate_fun(acct_id_0: &signer, acct_id_1: address, sig: vector<u8>): () acquires SmallBank {
        let acct_id_0_addr = Signer::address_of(acct_id_0);
        let exist_acct_id_0 = exists<SmallBank>(acct_id_0_addr);
        let collection_acct_id_0 = borrow_global_mut<SmallBank>(acct_id_0_addr);

        let exist_acct_id_1 = exists<SmallBank>(acct_id_1);

        if (!exist_acct_id_0 || !exist_acct_id_1) {
            let handle = Event::new_event_handle<vector<u8>>(acct_id_0);
            let prefix: vector<u8> = b"amalgamate/error ";
            Vector::append(&mut prefix, sig);
            Event::emit_event(&mut handle, prefix);
            Event::destroy_handle(handle);
            // abort
            return ()
        };

        let savings_balance = collection_acct_id_0.savings;
        let checking_balance = collection_acct_id_0.checking;

        let total = savings_balance + checking_balance;
        //assert!(total >= 0, 1);

        collection_acct_id_0.checking = 0;
        collection_acct_id_0.savings = 0;

        let collection_acct_id_1 = borrow_global_mut<SmallBank>(acct_id_1);

        collection_acct_id_1.checking = collection_acct_id_1.checking + total;

        let handle = Event::new_event_handle<vector<u8>>(acct_id_0);
        let prefix: vector<u8> = b"amalgamate ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }

    fun create_account_fun(account: &signer, checking_param: u64, savings_param: u64, sig: vector<u8>): () {
        move_to(account, SmallBank{ checking: checking_param, savings: savings_param });

        let handle = Event::new_event_handle<vector<u8>>(account);
        let prefix: vector<u8> = b"createAccount ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }

    public(script) fun create_account(account: signer, checking_param: u64, savings_param: u64, sig: vector<u8>) {
        create_account_fun(&account, checking_param, savings_param, sig);
    }

    public(script) fun write_check(account: signer, amount: u64, sig: vector<u8>) acquires SmallBank {
        write_check_fun(&account, amount, sig);
    }

    public(script) fun deposit_checking(account: signer, amount: u64, sig: vector<u8>) acquires SmallBank {
        deposit_checking_fun(&account, amount, sig);
    }

    public(script) fun transact_savings(account: signer, amount: u64, sig: vector<u8>) acquires SmallBank {
        transact_savings_fun(&account, amount, sig);
    }

    public(script) fun send_payment(account: signer, destination: address, amount: u64, sig: vector<u8>) acquires SmallBank {
        send_payment_fun(&account, destination, amount, sig);
    }

    public(script) fun balance(account: signer, sig: vector<u8>) acquires SmallBank {
        balance_fun(&account, sig);
    }

    public(script) fun amalgamate(account: signer, acct_id_1: address, sig: vector<u8>) acquires SmallBank {
        amalgamate_fun(&account, acct_id_1, sig);
    }
}
