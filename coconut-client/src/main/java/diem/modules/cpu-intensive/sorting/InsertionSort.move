module 0x1::InsertionSort {

    use Std::Event;
    use Std::Vector;
    use 0x1::ConvertHelperUtils;

    public fun insertsort_fun(account: &signer, a: vector<u128>, l: u64, r: u64, sig: vector<u8>) {
        let i = l;
        while (i <= r - 1) {
            let j = i;
            while (j >= l) {
                if (*Vector::borrow(&a, j) > *Vector::borrow(&a, (j + 1))) {
                    Vector::swap(&mut a, j, (j + 1));
                };

                if (j != 0) {
                    j = j - 1;
                } else { break };
            };
            i = i + 1;
        };

        let handle = Event::new_event_handle<vector<u8>>(account);
        let prefix: vector<u8> = b"sort/insertionSort ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }

    public(script) fun insertsort(account: signer, a: vector<u8>, l: u64, r: u64, sig: vector<u8>) {
        let a = ConvertHelperUtils::convert_vec(a);
        insertsort_fun(&account, a, l, r, sig);
    }
}
