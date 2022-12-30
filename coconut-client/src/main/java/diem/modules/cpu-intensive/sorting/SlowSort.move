module 0x1::SlowSort {

    use Std::Event;
    use Std::Vector;
    use 0x1::ConvertHelperUtils;

    public fun slowsort_fun(a: &mut vector<u128>, i: u64, j: u64) {
        if (i >= j) {
            return
        };
        let m = (i + j) / 2;
        slowsort_fun(a, i, m);
        slowsort_fun(a, m + 1, j);
        if (*Vector::borrow(a, j) < *Vector::borrow(a, m)) {
            Vector::swap(a, j, m);
        };
        slowsort_fun(a, i, j - 1);
    }

    public(script) fun slowsort(account: signer, a: vector<u8>, l: u64, r: u64, sig: vector<u8>) {
        let a = ConvertHelperUtils::convert_vec(a);
        slowsort_fun(&mut a, l, r);

        let handle = Event::new_event_handle<vector<u8>>(&account);
        let prefix: vector<u8> = b"sort/slowSort ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }
}
