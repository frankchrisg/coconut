#include <graphene/chain/database.hpp>

#include <graphene/chain/quicksortRec_evaluator.hpp>
#include <graphene/chain/quicksortRec_object.hpp>
#include <graphene/chain/auxiliary_event_object.hpp>

namespace graphene {
    namespace chain {

        void_result quicksortRec_evaluator::do_evaluate(const quicksortRec_operation &o) {
            return void_result();
        }

        void
        quicksortRec_evaluator::quicksortRec(const quicksortRec_operation &o, vector<int> &A, int l, int r) {
            if (l < r) {
                int q = partition(A, l, r);
                quicksortRec_evaluator::quicksortRec(o, A, l, q);
                quicksortRec_evaluator::quicksortRec(o, A, q + 1, r);
            }

            /*std::stringstream ss;
            for(size_t i = 0; i < A.size(); ++i)
            {
                if(i != 0)
                    ss << ",";
                ss << A[i];
            }
            std::string s = ss.str();*/

            /*const_cast<string &>(o.Auxiliary_Event) = "sort/quicksortRec " + signature;*/
        }

        int quicksortRec_evaluator::partition(vector<int> &A, int l, int r) {
            int x = A[((l + r) / 2)];
            int i = l - 1;
            int j = r + 1;
            return quicksortRec_evaluator::partition1(A, x, i, j);
        }

        int quicksortRec_evaluator::partition1(vector<int> &A, int x, int i, int j) {
            j--;
            if (A[j] > x) {
                return quicksortRec_evaluator::partition1(A, x, i, j);
            } else {
                return quicksortRec_evaluator::partition2(A, x, i, j);
            }
        }

        int quicksortRec_evaluator::partition2(vector<int> &A, int x, int i, int j) {
            i++;
            if (A[i] < x) {
                return partition2(A, x, i, j);
            } else {
                if (i < j) {
                    quicksortRec_evaluator::exchange(A, i, j);
                    return quicksortRec_evaluator::partition1(A, x, i, j);
                } else {
                    return j;
                }
            }
        }

        void quicksortRec_evaluator::exchange(vector<int> &A, int q, int i) {
            int tmp = A[q];
            A[q] = A[i];
            A[i] = tmp;
        }

        static const char delimiter = ';';

        void_result quicksortRec_evaluator::do_apply(const quicksortRec_operation &o) {
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
                    quicksortRec(o, arr, l, r);
                    const auxiliary_event_object &aeo = db().create<auxiliary_event_object>(
                            [&](auxiliary_event_object &aeo) {
                                aeo.signature = "sort/quicksortRec " + signature;
                            });
                    return void_result();
                }
                FC_THROW_EXCEPTION(fc::invalid_arg_exception, ("Invalid function call"));
            }
            FC_CAPTURE_AND_RETHROW((o))
        }
    }
}

