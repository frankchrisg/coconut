module 0x1::HeapSortPartlyRec {

    use Std::Event;
    use Std::Vector;
    use 0x1::ConvertHelperUtils;

    const K: u64 = 2; //2, 3

    fun heapsortpartlyrec_fun(account: &signer, a: &mut vector<u128>, l: u64, r: u64, sig: vector<u8>) {
        buildheap(a, l, r);
        heapsort2(a, l, r);
        let handle = Event::new_event_handle<vector<u8>>(account);
        let prefix: vector<u8> = b"sort/heapSortPartlyRec ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }

    fun heapsort2(a: &mut vector<u128>, l: u64, r: u64) {
        if (r > l) {
            Vector::swap(a, l, r);
            heapify(a, l, l, r - 1);
            heapsort2(a, l, r - 1);
        };
    }

    fun buildheap(a: &mut vector<u128>, l: u64, r: u64) {
        buildheap_helper(a, l, r, (r - l - 1) / K, false);
    }

    fun buildheap_helper(a: &mut vector<u128>, l: u64, r: u64, i: u64, z: bool) {
        if (i >= 0) {
            if (!z) {
                heapify(a, l, l + i, r);
            } else {
                // noop
            };
            if (i != 0) {
                buildheap_helper(a, l, r, i - 1, false);
            } else {
                // noop
            };
        };
    }

    fun heapify(a: &mut vector<u128>, l: u64, q: u64, r: u64) {
        let largest = l + K * (q - l) + 1;
        if (largest <= r) {
            let i = largest + 1;
            while (i <= largest + K - 1) {
                if (i <= r && *Vector::borrow(a, i) > *Vector::borrow(a, largest)) {
                    largest = i;
                };

                if (*Vector::borrow(a, largest) > *Vector::borrow(a, q)) {
                    Vector::swap(a, largest, q);
                    heapify(a, l, largest, r);
                };

                i = i + 1;
            };
        };
    }

    public(script) fun heapsortpartlyrec(account: signer, a: vector<u8>, l: u64, r: u64, sig: vector<u8>) {
        let a = ConvertHelperUtils::convert_vec(a);
        heapsortpartlyrec_fun(&account, &mut a, l, r, sig);
    }
}
