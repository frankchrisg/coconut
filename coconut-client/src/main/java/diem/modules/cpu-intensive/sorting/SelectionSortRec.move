module 0x1::SelectionSortRec {

    use Std::Event;
    use Std::Vector;
    use 0x1::ConvertHelperUtils;

    public fun selectionsortrec_fun(a: &mut vector<u128>, l: u64, r: u64) {
        if (l < r) {
            let q = max(a, l, l + 1, r);
            Vector::swap(a, q, r);
            selectionsortrec_fun(a, l, r - 1);
        };
    }

    fun max(a: &mut vector<u128>, q: u64, l: u64, r: u64): u64 {
        if (l <= r) {
            if (*Vector::borrow(a, l) > *Vector::borrow(a, q)) {
                return max(a, l, l + 1, r)
            } else {
                return max(a, q, l + 1, r)
            }
        } else {
            return q
        }
    }

    public(script) fun selectionsortrec(account: signer, a: vector<u8>, l: u64, r: u64, sig: vector<u8>) {
        let a = ConvertHelperUtils::convert_vec(a);
        selectionsortrec_fun(&mut a, l, r);

        let handle = Event::new_event_handle<vector<u8>>(&account);
        let prefix: vector<u8> = b"sort/selectionSortRec ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }
}
