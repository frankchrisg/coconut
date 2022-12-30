module 0x1::Memory {

    use Std::Vector;
    use Std::Event;

    const FIELD: vector<u8> = b"!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";

    fun memory_fun(account: &signer, len_out: u64, len_in: u64, first_char: u64, length: u64, sig: vector<u8>) {
        let memory = Vector::empty<vector<vector<u8>>>();

        let i: u64 = 0;
        while (i < len_out) {
            Vector::push_back(&mut memory, Vector::empty());

            let j: u64 = 0;
            while (j < len_in) {
                let vec = Vector::borrow_mut(&mut memory, i);
                Vector::push_back(vec, get_chars(first_char + i + j, length + i + j));
                j = j + 1;
            };

            i = i + 1;
        };

        let handle = Event::new_event_handle<vector<u8>>(account);
        let prefix: vector<u8> = b"memory ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }

    fun get_chars(first_char: u64, length: u64): vector<u8> {
        let state_arr = Vector::empty<u8>();
        let i: u64 = first_char;
        while (i < length + first_char) {
            let char = Vector::borrow(&FIELD, ((first_char + i) % Vector::length(&FIELD)));
            Vector::push_back(&mut state_arr, *char);
            i = i + 1;
        };

        state_arr
    }


    public(script) fun memory(account: signer, len_out: u64, len_in: u64, first_char: u64, length: u64, sig: vector<u8>) {
        memory_fun(&account, len_out, len_in, first_char, length, sig);
    }
}
