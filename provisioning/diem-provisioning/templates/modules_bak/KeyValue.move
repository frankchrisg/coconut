module 0x1::KeyValue {

    use Std::Event;
    use Std::Signer;
    use Std::Vector;

    struct KeyValue has key, store {
        key: vector<u8>,
        value: vector<u8>
    }

    fun get_func(account: &signer, key: vector<u8>, sig: vector<u8>) acquires KeyValue {
        let owner = Signer::address_of(account);
        let exist = exists<KeyValue>(owner);
        let collection = borrow_global<KeyValue>(owner);

        if (!exist || *&collection.key != key) {} else {
            let handle = Event::new_event_handle<vector<u8>>(account);
            let prefix: vector<u8> = b"keyValue/get ";
            Vector::append(&mut prefix, sig);
            Event::emit_event(&mut handle, prefix);
            Event::destroy_handle(handle);
        };
    }

    fun set_func(account: &signer, key_param: vector<u8>, value_param: vector<u8>, sig: vector<u8>) {
        move_to(account, KeyValue{ key: key_param, value: value_param });

        let handle = Event::new_event_handle<vector<u8>>(account);
        let prefix: vector<u8> = b"keyValue/set ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }

    public(script) fun set(account: signer, key_param: vector<u8>, value_param: vector<u8>, sig: vector<u8>) {
        //        if(copy vec == b"set") {}
        set_func(&account, key_param, value_param, sig);
    }

    public(script) fun get(account: signer, key: vector<u8>, sig: vector<u8>) acquires KeyValue {
        get_func(&account, key, sig);
    }
}
