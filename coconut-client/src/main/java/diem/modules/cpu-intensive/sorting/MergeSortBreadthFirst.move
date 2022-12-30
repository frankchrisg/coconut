module 0x1::MergeSortBreadthFirst {

    use Std::Event;
    use Std::Vector;
    use 0x1::ConvertHelperUtils;

    // even only **2
    fun mergesortbreadthfirst_fun(account: &signer, a: &mut vector<u128>, l: u64, r: u64, sig: vector<u8>) {
        let m = 1;
        while (m <= r - l) {
            let i = l;
            while (i <= r) {
                merge(a, i, i + m - 1, i + 2 * m - 1);
                i = i + m * 2;
            };
            m = m + m;
        };

        let handle = Event::new_event_handle<vector<u8>>(account);
        let prefix: vector<u8> = b"sort/mergeSortBreadthFirst ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
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
        }
    }

    public(script) fun mergesortbreadthfirst(account: signer, a: vector<u8>, l: u64, r: u64, sig: vector<u8>) {
        let a = ConvertHelperUtils::convert_vec(a);
        mergesortbreadthfirst_fun(&account, &mut a, l, r, sig);
    }
}
