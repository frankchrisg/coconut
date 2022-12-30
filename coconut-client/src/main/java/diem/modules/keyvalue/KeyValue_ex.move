module 0x1::KeyValue_ex {

    use Std::Event;
    use Std::Signer;
    use Std::Vector;

    struct KeyValue_ex has key, store, copy {
        key: vector<u8>,
        value: vector<u8>
    }

    fun get_func(account: &signer, key: vector<u8>, sig: vector<u8>) acquires KeyValue_ex {
        let owner = Signer::address_of(account);
        let exist = exists<KeyValue_ex>(owner);
        let collection = borrow_global<KeyValue_ex>(owner);

        if (!exist || *&collection.key != key) {
            let handle = Event::new_event_handle<vector<u8>>(account);
            let prefix: vector<u8> = b"keyValueEx/get/doesntexist ";
            Vector::append(&mut prefix, sig);
            Event::emit_event(&mut handle, prefix);
            Event::destroy_handle(handle);
        } else {
            let handle = Event::new_event_handle<vector<u8>>(account);
            let prefix: vector<u8> = b"keyValueEx/get ";
            Vector::append(&mut prefix, sig);
            Event::emit_event(&mut handle, prefix);
            Event::destroy_handle(handle);
        };
    }

    fun set_func(account: &signer, key_param: vector<u8>, value_param: vector<u8>, sig: vector<u8>) {
        let owner = Signer::address_of(account);
        let exist = exists<KeyValue_ex>(owner);

        if (exist) {
            let handle = Event::new_event_handle<vector<u8>>(account);
            let prefix: vector<u8> = b"keyValueEx/set/exist ";
            Vector::append(&mut prefix, sig);
            Event::emit_event(&mut handle, prefix);
            Event::destroy_handle(handle);
        } else {
            move_to(account, KeyValue_ex{ key: key_param, value: value_param });

            let handle = Event::new_event_handle<vector<u8>>(account);
            let prefix: vector<u8> = b"keyValueEx/set ";
            Vector::append(&mut prefix, sig);
            Event::emit_event(&mut handle, prefix);
            Event::destroy_handle(handle);
        };
    }

    public(script) fun set_ex(account: signer, key_param: vector<u8>, value_param: vector<u8>, sig: vector<u8>) {
        //        if(copy vec == b"set") {
        set_func(&account, key_param, value_param, sig);
    }

    public(script) fun get_ex(account: signer, key: vector<u8>, sig: vector<u8>) {
        get_func(&account, key, sig);
    }
}
