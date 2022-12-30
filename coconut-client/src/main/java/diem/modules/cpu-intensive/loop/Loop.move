module 0x1::Loop {

    use Std::Event;
    use Std::Vector;

    fun loop_fun(account: &signer, start: u64, end: u64, sig: vector<u8>) {
        let _j: u64;
        let i = start;
        while (i < end) {
            _j = start + i;
            i = i + 1;
        };

        let handle = Event::new_event_handle<vector<u8>>(account);
        let prefix: vector<u8> = b"loop ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }

    public(script) fun loop_main(account: signer, start: u64, end: u64, sig: vector<u8>) {
        loop_fun(&account, start, end, sig);
    }
}
