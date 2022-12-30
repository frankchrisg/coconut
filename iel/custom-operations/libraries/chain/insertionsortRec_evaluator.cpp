#include <graphene/chain/database.hpp>

#include <graphene/chain/insertionsortRec_evaluator.hpp>
#include <graphene/chain/insertionsortRec_object.hpp>
#include <graphene/chain/auxiliary_event_object.hpp>

namespace graphene {
    namespace chain {

        void_result insertionsortRec_evaluator::do_evaluate(const insertionsortRec_operation &o) {
            return void_result();
        }

        void
        insertionsortRec_evaluator::insertionsortRec(const insertionsortRec_operation &o, vector<int> &A, int l, int r) {
            if (l < r) {
                insertionsortRec_evaluator::insertionsortRec(o, A, l, r-1);
                insertionsortRec_evaluator::insert(A, l, r);
                }

            /*std::stringstream ss;
            for(size_t i = 0; i < A.size(); ++i)
            {
                if(i != 0)
                    ss << ",";
                ss << A[i];
            }
            std::string s = ss.str();*/

            /*const_cast<string &>(o.Auxiliary_Event) = "sort/insertionsortRec " + signature;*/
        }

        void insertionsortRec_evaluator::insert(vector<int> &A, int l, int r) {
            if (l < r) {
                        if (A[r-1] > A[r]) {
                            exchange(A, r-1, r);
                        }
                        insert(A, l, r-1);
                }
        }

        void insertionsortRec_evaluator::exchange(vector<int> &A, int q, int i) {
            int tmp = A[q];
            A[q] = A[i];
            A[i] = tmp;
        }

        static const char delimiter = ';';

        void_result insertionsortRec_evaluator::do_apply(const insertionsortRec_operation &o) {
            try {

                int len = 0;
                size_t next = 0;
                size_t last = 0;
                std::string param;

                while (next != std::string::npos) {
                    len++;
                    next = o.Parameters.find(delimiter, last);
                    param = o.Parameters.substr(last, next - last);
                    last = next + 1;
                }

                if (len < 4) {
                    FC_CAPTURE_AND_THROW(fc::invalid_arg_exception, ("Call to Sort must have at least 4 parameters"));
                }

                last = 0;
                std::vector<int> arr;
                int l;
                int r;
                string signature;
                for (int i = 0; i < len; i++) {
                    next = o.Parameters.find(delimiter, last);
                    param = o.Parameters.substr(last, next - last);
                    if (i < len - 3) {
                        arr.push_back(std::stoi(param));
                    } else if (i == len - 3) { l = std::stoi(param); }
                    else if (i == len - 2) { r = std::stoi(param); }
                    else if (i == len - 1) { signature = param; }
                    last = next + 1;
                }

                if (o.Function == "Sort") {
                    insertionsortRec(o, arr, l, r);
                    const auxiliary_event_object &aeo = db().create<auxiliary_event_object>(
                            [&](auxiliary_event_object &aeo) {
                                aeo.signature = "sort/insertionsortRec " + signature;
                            });
                    return void_result();
                }
                FC_THROW_EXCEPTION(fc::invalid_arg_exception, ("Invalid function call"));
            }
            FC_CAPTURE_AND_RETHROW((o))
        }
    }
}
