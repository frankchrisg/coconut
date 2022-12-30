module 0x1::HeapSort {

    use Std::Event;
    use Std::Vector;
    use 0x1::ConvertHelperUtils;

    const K: u64 = 2; //2, 3

    fun heapsort_fun(account: &signer, a: vector<u128>, l: u64, r: u64, sig: vector<u8>) {
        buildheap(&mut a, l, r);

        let i: u64 = r;

        while (i >= l + 1) {
            Vector::swap(&mut a, l, i);
            heapify(&mut a, l, l, i - 1);
            i = i - 1;
        };

        let handle = Event::new_event_handle<vector<u8>>(account);
        let prefix: vector<u8> = b"sort/heapSort ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }

    fun buildheap(a: &mut vector<u128>, l: u64, r: u64) {
        let i = ((r - l - 1) / K) + 1;
        while (i >= 1) {
            heapify(a, l, l + i - 1, r);
            i = i - 1;
        };
    }

    fun heapify(a: &mut vector<u128>, l: u64, q: u64, r: u64): () {
        while (true) {
            let largest: u64 = l + K * (q - l) + 1;
            if (largest <= r) {
                let i: u64 = largest + 1;
                while (i <= largest + K - 1) {
                    if (i <= r && *Vector::borrow(a, i) > *Vector::borrow(a, largest)) {
                        largest = i;
                    };
                    i = i + 1;
                };
                if (*Vector::borrow(a, largest) > *Vector::borrow(a, q)) {
                    Vector::swap(a, largest, q);
                    q = largest;
                } else {
                    return ()
                };
            }
            else {
                //return ()
                break
            };
        };
    }

    public(script) fun heapsort(account: signer, a: vector<u8>, l: u64, r: u64, sig: vector<u8>) {
        let a = ConvertHelperUtils::convert_vec(a);
        heapsort_fun(&account, a, l, r, sig);
    }
}
