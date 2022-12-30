module 0x1::SelectionSort {

    use Std::Event;
    use Std::Vector;
    use 0x1::ConvertHelperUtils;

    public fun selectionsort_fun(account: &signer, a: vector<u128>, l: u64, r: u64, sig: vector<u8>) {
        let i = r;
        while (i >= l + 1) {
            let q = l;
            let j = l + 1;
            while (j <= i) {
                if (*Vector::borrow(&a, j) > *Vector::borrow(&a, q)) {
                    q = j;
                };

                j = j + 1;
            };

            Vector::swap(&mut a, q, i);

            i = i - 1;
        };

        let handle = Event::new_event_handle<vector<u8>>(account);
        let prefix: vector<u8> = b"sort/selectionSort ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }

    public(script) fun selectionsort(account: signer, a: vector<u8>, l: u64, r: u64, sig: vector<u8>) {
        let a = ConvertHelperUtils::convert_vec(a);
        selectionsort_fun(&account, a, l, r, sig);
    }
}
