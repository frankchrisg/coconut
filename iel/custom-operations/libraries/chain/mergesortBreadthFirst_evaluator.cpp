#include <graphene/chain/database.hpp>

#include <graphene/chain/mergesortBreadthFirst_evaluator.hpp>
#include <graphene/chain/mergesortBreadthFirst_object.hpp>
#include <graphene/chain/auxiliary_event_object.hpp>

namespace graphene {
    namespace chain {

        void_result mergesortBreadthFirst_evaluator::do_evaluate(const mergesortBreadthFirst_operation &o) {
            return void_result();
        }

        // even only **2
        void
        mergesortBreadthFirst_evaluator::mergesortBreadthFirst(const mergesortBreadthFirst_operation &o, vector<int> A, int l, int r,
                                         const string &signature) {
            for (int m = 1; m <= r-l; m = m + m) {
                    for (int i = l; i <= r; i = i + m*2) {
                        mergesortBreadthFirst_evaluator::merge(A, i, i+m-1, i+2*m-1);
                    }
            }

            /*std::stringstream ss;
            for(size_t i = 0; i < A.size(); ++i)
            {
                if(i != 0)
                    ss << ",";
                ss << A[i];
            }
            std::string s = ss.str();*/

            /*const_cast<string &>(o.Auxiliary_Event) = "sort/mergesortBreadthFirst " + signature;*/

            const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                aeo.signature = "sort/mergesortBreadthFirst " + signature;
            });
        }

        void mergesortBreadthFirst_evaluator::merge(vector<int> &A, int l, int q, int r) {
            vector<int> B(A.size());
            for (int i = l; i <= q; i++) {
                B[i] = A[i];
            }
            for (int j = q + 1; j <= r; j++) {
                B[(r + q + 1 - j)] = A[j];
            }
            int s = l;
            int t = r;
            for (int k = l; k <= r; k++) {
                if (B[s] <= B[t]) {
                    A[k] = B[s];
                    s++;
                } else {
                    A[k] = B[t];
                    t--;
                }
            }
        }
        
        static const char delimiter = ';';

        void_result mergesortBreadthFirst_evaluator::do_apply(const mergesortBreadthFirst_operation &o) {
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
                    mergesortBreadthFirst(o, arr, l, r, signature);
                    return void_result();
                }
                FC_THROW_EXCEPTION(fc::invalid_arg_exception, ("Invalid function call"));
            }
            FC_CAPTURE_AND_RETHROW((o))
        }
    }
}
