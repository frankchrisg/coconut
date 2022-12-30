module 0x1::MergeSortRec {

    use Std::Event;
    use Std::Vector;
    use 0x1::ConvertHelperUtils;

    fun mergesortrec_fun(a: &mut vector<u128>, l: u64, r: u64) {
        if (l < r) {
            let q = (l + r) / 2;
            mergesortrec_fun(a, l, q);
            mergesortrec_fun(a, q + 1, r);
            merge(a, l, q, r);
        }
    }

    fun merge(a: &mut vector<u128>, l: u64, q: u64, r: u64) {
        let b = Vector::empty<u128>();

        while (Vector::length(&b) != Vector::length(a)) {
            Vector::push_back(&mut b, 0);
        };

        let i = l;
        while (i <= q) {
            *Vector::borrow_mut(&mut b, i) = *Vector::borrow(a, i);
            i = i + 1;
        };

        let j = q + 1;
        while (j <= r) {
            *Vector::borrow_mut(&mut b, r + q + 1 - j) = *Vector::borrow(a, j);
            j = j + 1;
        };

        let s = l;
        let t = r;

        let k = l;
        while (k <= r) {
            if (*Vector::borrow(&b, s) <= *Vector::borrow(&b, t)) {
                *Vector::borrow_mut(a, k) = *Vector::borrow(&b, s);
                s = s + 1;
            } else {
                *Vector::borrow_mut(a, k) = *Vector::borrow(&b, t);
                t = t - 1;
            };

            k = k + 1;
        };
    }

    public(script) fun mergesortrec(account: signer, a: vector<u8>, l: u64, r: u64, sig: vector<u8>) {
        let a = ConvertHelperUtils::convert_vec(a);
        mergesortrec_fun(&mut a, l, r);

        let handle = Event::new_event_handle<vector<u8>>(&account);
        let prefix: vector<u8> = b"sort/mergeSortRec ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }
}
