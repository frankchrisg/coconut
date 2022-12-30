module 0x1::ConvertHelperUtils {

    use Std::Vector;

    public fun convert_vec(vector: vector<u8>): vector<u128> {
        let length = Vector::length(&vector);

        let tmpVec = Vector::empty<u8>();
        let resVec = Vector::empty<u128>();
        let i = 0;

        while (i < length) {
            let charVec = Vector::empty<u8>();
            let char = Vector::borrow(&vector, i);
            Vector::push_back(&mut charVec, *char);

            if (i == length - 1) {
                Vector::push_back(&mut tmpVec, *char);
                let result = prepare_values(copy tmpVec);
                Vector::push_back(&mut resVec, result);

                tmpVec = Vector::empty<u8>();
            }
            else if (charVec == b",") {
                let result = prepare_values(copy tmpVec);
                Vector::push_back(&mut resVec, result);

                tmpVec = Vector::empty<u8>();
            }
            else {
                Vector::push_back(&mut tmpVec, *char);
            };

            i = i + 1;
        };

        resVec
    }

    fun prepare_values(vector: vector<u8>): u128 {
        let length = Vector::length(&vector);
        Vector::reverse(&mut vector);
        let offset: u128 = 1;
        let v = Vector::empty<u128>();
        let i = 0;

        while (i < length) {
            let current = Vector::borrow_mut(&mut vector, i);
            let new: u128;
            new = ((*current as u128) * offset);
            Vector::push_back(&mut v, new);
            i = i + 1;
            offset = offset * 10;
        };

        let len = Vector::length(&v);
        let s = 0;
        let sum: u128 = 0;
        while (s < len) {
            let cur = Vector::borrow_mut(&mut v, s);
            sum = sum + *cur;
            s = s + 1;
        };
        sum
    }

    public fun convert_u64_to_vec_u8(number: u64): vector<u8> {

        let tmpVec = Vector::empty<u8>();

        while (number > 0) {
            Vector::push_back(&mut tmpVec, ((number % 10) as u8));
            number = number / 10;
        };

        Vector::reverse(&mut tmpVec);
        return tmpVec
    }

}
