#include <graphene/chain/database.hpp>

#include <graphene/chain/donothing_evaluator.hpp>
#include <graphene/chain/donothing_object.hpp>

namespace graphene {
    namespace chain {

        void_result donothing_evaluator::do_evaluate(const donothing_operation &o) {
            return void_result();
        }

        void_result donothing_evaluator::do_apply(const donothing_operation &o) {
            try {

                string signature = o.Parameters;
                /*const_cast<string &>(o.Auxiliary_Event) = "donothing " + signature;*/

                const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                    aeo.signature = "donothing " + signature;
                });

                return void_result();
                FC_THROW_EXCEPTION(fc::invalid_arg_exception, ("Invalid function call"));
            }
            FC_CAPTURE_AND_RETHROW((o))
        }
    }
}
