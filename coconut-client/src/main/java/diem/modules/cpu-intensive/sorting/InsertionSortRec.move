module 0x1::InsertionSortRec {

    use Std::Event;
    use Std::Vector;
    use 0x1::ConvertHelperUtils;

    public fun insert(a: &mut vector<u128>, l: u64, r: u64) {
        if (l < r) {
            if (*Vector::borrow(a, (r - 1)) > *Vector::borrow(a, r)) {
                Vector::swap(a, (r - 1), r);
            };
            insert(a, l, r - 1);
        };
    }

    fun insertsortrec_fun(a: &mut vector<u128>, l: u64, r: u64) {
        if (l < r) {
            insertsortrec_fun(a, l, r - 1);
            insert(a, l, r);
        }
    }

    public(script) fun insertsort_rec(account: signer, a: vector<u8>, l: u64, r: u64, sig: vector<u8>) {
        let a = ConvertHelperUtils::convert_vec(a);
        insertsortrec_fun(&mut a, l, r);

        let handle = Event::new_event_handle<vector<u8>>(&account);
        let prefix: vector<u8> = b"sort/insertionSortRec ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }
}
