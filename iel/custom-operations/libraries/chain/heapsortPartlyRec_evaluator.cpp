#include <graphene/chain/database.hpp>

#include <graphene/chain/heapsortPartlyRec_evaluator.hpp>
#include <graphene/chain/heapsortPartlyRec_object.hpp>
#include <graphene/chain/auxiliary_event_object.hpp>

namespace graphene {
    namespace chain {

        void_result heapsortPartlyRec_evaluator::do_evaluate(const heapsortPartlyRec_operation &o) {
            return void_result();
        }

        static const int k = 2; // 2, 3

        void
        heapsortPartlyRec_evaluator::heapsortPartlyRec(const heapsortPartlyRec_operation &o, vector<int> A, int l, int r,
                                         const string &signature) {
            heapsortPartlyRec_evaluator::buildheap(A, l, r);
            heapsortPartlyRec_evaluator::heapsort2(A, l, r);

            /*std::stringstream ss;
            for(size_t i = 0; i < A.size(); ++i)
            {
                if(i != 0)
                    ss << ",";
                ss << A[i];
            }
            std::string s = ss.str();*/

            /*const_cast<string &>(o.Auxiliary_Event) = "sort/heapsortPartlyRec " + signature;*/

            const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                aeo.signature = "sort/heapsortPartlyRec " + signature;
            });
        }

        void heapsortPartlyRec_evaluator::heapsort2(vector<int> &A, int l, int r) {
            if (r > l) {
                heapsortPartlyRec_evaluator::exchange(A, l, r);
                heapsortPartlyRec_evaluator::heapify(A, l, l, r-1);
                heapsortPartlyRec_evaluator::heapsort2(A, l, r-1);
                }
        }

        void heapsortPartlyRec_evaluator::buildheap(const vector<int> &A, int l, int r) {
            heapsortPartlyRec_evaluator::buildheap_helper(A, l, r, (r-l-1)/k);
        }

        void heapsortPartlyRec_evaluator::buildheap_helper(const vector<int> &A, int l, int r, int i) {
            if (i >= 0) {
                heapsortPartlyRec_evaluator::heapify(const_cast<vector<int> &>(A), l, l + i, r);
                heapsortPartlyRec_evaluator::buildheap_helper(A, l, r, i-1);
            }
        }

        void heapsortPartlyRec_evaluator::heapify(vector<int> &A, int l, int q, int r) {
            int largest = l + k*(q-l) + 1;
            if (largest <= r) {

                        for (int i = largest + 1; i <= largest+k-1; i++) {
                            if (i <= r && A[i] > A[largest]) {
                                largest = i;
                            }

                            if (A[largest] > A[q]) {
                                heapsortPartlyRec_evaluator::exchange(A, largest, q);
                                heapsortPartlyRec_evaluator::heapify(A, l, largest, r);
                            }
                        }
                }
        }

        void heapsortPartlyRec_evaluator::exchange(vector<int> &A, int q, int i) {
            int tmp = A[q];
            A[q] = A[i];
            A[i] = tmp;
        }

        static const char delimiter = ';';

        void_result heapsortPartlyRec_evaluator::do_apply(const heapsortPartlyRec_operation &o) {
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
                    heapsortPartlyRec(o, arr, l, r, signature);
                    return void_result();
                }
                FC_THROW_EXCEPTION(fc::invalid_arg_exception, ("Invalid function call"));
            }
            FC_CAPTURE_AND_RETHROW((o))
        }
    }
}
