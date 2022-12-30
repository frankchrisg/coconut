module 0x1::QuickSortRec {

    use Std::Event;
    use Std::Vector;
    use 0x1::ConvertHelperUtils;

    fun quicksortrec_fun(a: &mut vector<u128>, l: u64, r: u64) {
        if (l < r) {
            let q = partition(a, l, r);
            quicksortrec_fun(a, l, q);
            quicksortrec_fun(a, q + 1, r);
        };
    }

    fun partition(a: &mut vector<u128>, l: u64, r: u64): u64 {
        let x = *Vector::borrow(a, ((l + r) / 2));

        let i = l; //- 1;
        let j = r + 1;
        return partition1(a, (x as u64), i, j)
    }

    fun partition1(a: &mut vector<u128>, x: u64, i: u64, j: u64): u64 {
        j = j - 1;

        if (*Vector::borrow(a, j) > (x as u128)) {
            return partition1(a, x, i, j)
        } else {
            return partition2(a, x, i, j)
        }
    }

    fun partition2(a: &mut vector<u128>, x: u64, i: u64, j: u64): u64 {
        //i = i + 1;
        if (*Vector::borrow(a, i) < (x as u128)) {
            i = i + 1;
            return partition2(a, x, i, j)
        } else {
            if (i < j) {
                Vector::swap(a, i, j);
                i = i + 1;
                return partition1(a, x, i, j)
            } else {
                return j
            }
        }
    }

    public(script) fun quicksortrec(account: signer, a: vector<u8>, l: u64, r: u64, sig: vector<u8>) {
        let a = ConvertHelperUtils::convert_vec(a);
        quicksortrec_fun(&mut a, l, r);

        let handle = Event::new_event_handle<vector<u8>>(&account);
        let prefix: vector<u8> = b"sort/quickSortRec ";
        Vector::append(&mut prefix, sig);
        Event::emit_event(&mut handle, prefix);
        Event::destroy_handle(handle);
    }
}
