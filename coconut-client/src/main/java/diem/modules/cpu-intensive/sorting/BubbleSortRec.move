module 0x1::BubbleSortRec {

    use Std::Event;
    use Std::Vector;
    use 0x1::ConvertHelperUtils;

    fun bubble(a: &mut vector<u128>, l: u64, r: u64) {
        if (l < r) {
            if (*Vector::borrow(a, l) > *Vector::borrow(a, (l + 1))) {
                Vector::swap(a, l, (l + 1));
            };
            bubble(a, l + 1, r);
        };
    }

    fun bubblesortrec_fun(a: &mut vector<u128>, l: u64, r: u64) {
        if (l < r) {
            bubble(a, l, r);
            bubblesortrec_fun(a, l, r - 1);
        };
    }

    public(script) fun bubblesort_rec(account: signer, a: vector<u8>, l: u64, r: u64, sig: vector<u8>) {
        let a = ConvertHelperUtils::convert_vec(a);
        bubblesortrec_fun(&mut a, l, r);
        let handle = Event::new_event_handle<vector<u8>>(&account);
        let prefix: vector<u8> = b"sort/bubbleSortRec ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }
}
