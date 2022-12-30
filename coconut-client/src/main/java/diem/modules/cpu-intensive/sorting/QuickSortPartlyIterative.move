module 0x1::QuickSortPartlyIterative {

    use Std::Event;
    use Std::Vector;
    use 0x1::ConvertHelperUtils;

    fun quicksortpartlyiterative_fun(a: &mut vector<u128>, l: u64, r: u64) {
        if (l < r) {
            let q = partition(a, l, r);
            quicksortpartlyiterative_fun(a, l, q);
            quicksortpartlyiterative_fun(a, q + 1, r);
        }
    }

    fun partition(a: &mut vector<u128>, l: u64, r: u64): u64 {
        let x = *Vector::borrow(a, ((l + r) / 2));
        let i = l;
        // let i = l - 1;
        let j = r + 1;
        while (true) {
            j = j - 1;
            while (*Vector::borrow(a, j) > x) {
                j = j - 1;
            };

            //i = i + 1;
            while (*Vector::borrow(a, i) < x) {
                i = i + 1;
            };

            if (i < j) {
                Vector::swap(a, i, j);
            } else {
                return j
            }
        };
        abort 1
    }

    public(script) fun quicksortpartlyiterative(account: signer, a: vector<u8>, l: u64, r: u64, sig: vector<u8>) {
        let a = ConvertHelperUtils::convert_vec(a);
        quicksortpartlyiterative_fun(&mut a, l, r);

        let handle = Event::new_event_handle<vector<u8>>(&account);
        let prefix: vector<u8> = b"sort/quickSortPartlyIterative ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }
}
