#pragma once

#include <graphene/chain/evaluator.hpp>

namespace graphene {
    namespace chain {

        class heapsortPartlyRec_evaluator : public evaluator<heapsortPartlyRec_evaluator> {
        public:
            typedef heapsortPartlyRec_operation operation_type;

            void_result do_evaluate(const heapsortPartlyRec_operation &o);

            void heapsortPartlyRec(const heapsortPartlyRec_operation &o, vector<int> A, int l, int r, const string &signature);

            void heapsort2(vector<int> &A, int l, int r);

            void buildheap(const vector<int> &A, int l, int r);

            void buildheap_helper(const vector<int> &A, int l, int r, int i);

            void heapify(vector<int> &A, int l, int q, int r);

            void exchange(vector<int> &A, int q, int i);

            void_result do_apply(const heapsortPartlyRec_operation &o);
        };
    }
}
