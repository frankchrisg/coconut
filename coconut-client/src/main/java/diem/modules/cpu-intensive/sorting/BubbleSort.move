module 0x1::BubbleSort {

    use Std::Event;
    use Std::Vector;
    use 0x1::ConvertHelperUtils;

    fun bubblesort_fun(account: &signer, a: vector<u128>, l: u64, r: u64, sig: vector<u8>) {
        let i = r;
        while (i >= l + 1) {
            let j = l;
            while (j <= i - 1) {
                if (*Vector::borrow(&a, j) > *Vector::borrow(&a, (j + 1))) {
                    Vector::swap(&mut a, j, (j + 1));
                };
                j = j + 1;
            };
            i = i - 1;
        };
        let handle = Event::new_event_handle<vector<u8>>(account);
        let prefix: vector<u8> = b"sort/bubbleSort ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }

    public(script) fun bubblesort(account: signer, a: vector<u8>, l: u64, r: u64, sig: vector<u8>) {
        let a = ConvertHelperUtils::convert_vec(a);
        bubblesort_fun(&account, a, l, r, sig);
    }
}
