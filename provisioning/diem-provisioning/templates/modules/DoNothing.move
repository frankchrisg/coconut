module 0x1::DoNothing {

    use Std::Event;
    use Std::Vector;

    fun do_nothing_fun(account: &signer, sig: vector<u8>) {
        let handle = Event::new_event_handle<vector<u8>>(account);
        let prefix: vector<u8> = b"doNothing ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }

    public(script) fun do_nothing(account: signer, sig: vector<u8>) {
        do_nothing_fun(&account, sig);
    }
}
