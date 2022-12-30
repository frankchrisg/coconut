module 0x1::Recursion {

    use Std::Event;
    use Std::Vector;

    fun recursion_fun(start: u64, end: u64) {
        if (start != end) {
            recursion_fun(start, end - 1);
        };
    }

    public(script) fun recursion(account: signer, start: u64, end: u64, sig: vector<u8>) {
        recursion_fun(start, end);

        let handle = Event::new_event_handle<vector<u8>>(&account);
        let prefix: vector<u8> = b"recursion ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }
}
