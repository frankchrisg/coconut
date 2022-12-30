module 0x1::IO {

    use Std::Vector;
    use Std::Event;
    use Std::Signer;

    struct IO has key, store, copy {
        sks: vector<u64>,
        states: vector<vector<u8>>
    }

    const CHARS: vector<u8> = b"!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";

    fun write_fun(account: &signer, size: u64, start_key: u64, ret_len: u64, sig: vector<u8>) {
        let sks = Vector::empty<u64>();
        let states = Vector::empty<vector<u8>>();

        let i = 0;
        while (i < size) {
            let sk: u64 = start_key + i;
            let val = getVal(start_key + i, ret_len);

            Vector::push_back(&mut sks, sk);
            Vector::push_back(&mut states, val);

            i = i + 1;
        };

        move_to(account, IO{ sks: sks, states: states });

        let handle = Event::new_event_handle<vector<u8>>(account);
        let prefix: vector<u8> = b"storage/write ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }

    fun getVal(k: u64, ret_len: u64): vector<u8> {
        let ret = Vector::empty<u8>();
        let i: u64 = 0;
        while (i < ret_len) {
            let char = Vector::borrow(&CHARS, ((k + i) % Vector::length(&CHARS)));
            Vector::push_back(&mut ret, *char);
            i = i + 1;
        };

        ret
    }

    fun scan_fun(account: &signer, size: u64, sig: vector<u8>): () acquires IO {
        let owner = Signer::address_of(account);
        let exist = exists<IO>(owner);
        let collection = borrow_global<IO>(owner);

        if (!exist) {
            return ()
        };

        let stateArr = Vector::empty<vector<u8>>();
        let val = *&collection.states;
        let i = 0;
        while (i < size) {
            Vector::push_back(&mut stateArr, *Vector::borrow(&val, i));
            i = i + 1;
        };

        let handle = Event::new_event_handle<vector<u8>>(account);
        let prefix: vector<u8> = b"storage/scan ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }

    fun revert_scan_fun(account: &signer, sig: vector<u8>): () acquires IO {
        let owner = Signer::address_of(account);
        let exist = exists<IO>(owner);
        let collection = borrow_global<IO>(owner);

        if (!exist) {
            return ()
        };

        let stateArr = Vector::empty<vector<u8>>();
        let val = *&collection.states;
        let i = Vector::length(&val);
        while (i > 0) {
            Vector::push_back(&mut stateArr, *Vector::borrow(&val, i - 1));
            i = i - 1;
        };

        let handle = Event::new_event_handle<vector<u8>>(account);
        let prefix: vector<u8> = b"storage/revertScan ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }

    public(script) fun write(account: signer, size: u64, start_key: u64, ret_len: u64, sig: vector<u8>) {
        write_fun(&account, size, start_key, ret_len, sig);
    }

    public(script) fun scan(account: signer, size: u64, sig: vector<u8>) acquires IO {
        scan_fun(&account, size, sig);
    }

    public(script) fun revert_scan(account: signer, sig: vector<u8>) acquires IO {
        revert_scan_fun(&account, sig);
    }
}

