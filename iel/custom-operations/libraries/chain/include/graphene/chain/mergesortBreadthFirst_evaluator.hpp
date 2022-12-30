#pragma once

#include <graphene/chain/evaluator.hpp>

namespace graphene {
    namespace chain {

        class mergesortBreadthFirst_evaluator : public evaluator<mergesortBreadthFirst_evaluator> {
        public:
            typedef mergesortBreadthFirst_operation operation_type;

            void_result do_evaluate(const mergesortBreadthFirst_operation &o);

            void mergesortBreadthFirst(const mergesortBreadthFirst_operation &o, vector<int> A, int l, int r, const string &signature);

            void merge(vector<int> &A , int l, int q, int r);

            void_result do_apply(const mergesortBreadthFirst_operation &o);
        };
    }
}
