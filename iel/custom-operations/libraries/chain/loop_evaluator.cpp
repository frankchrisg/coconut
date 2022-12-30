#include <graphene/chain/database.hpp>

#include <graphene/chain/loop_evaluator.hpp>
#include <graphene/chain/loop_object.hpp>
#include <graphene/chain/auxiliary_event_object.hpp>

namespace graphene {
    namespace chain {

        void_result loop_evaluator::do_evaluate(const loop_operation &o) {
            return void_result();
        }

        void
        loop_evaluator::loop(const loop_operation &o, int start, int end,
                             const string &signature) {

            int j = 0;
            for (int i = start; i < end; i++) {
                j = start + i;
            }

            /*const_cast<string &>(o.Auxiliary_Event) = "loop " + signature;*/

            const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                aeo.signature = "loop " + signature;
            });
        }

        static const char delimiter = ';';

        void_result loop_evaluator::do_apply(const loop_operation &o) {
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

                if (len != 3) {
                    FC_CAPTURE_AND_THROW(fc::invalid_arg_exception, ("Call to Loop must have 3 parameters"));
                }

                last = 0;
                int start;
                next = o.Parameters.find(delimiter, last);
                param = o.Parameters.substr(last, next - last);
                start = std::stoi(param);
                last = next + 1;
                int end;
                next = o.Parameters.find(delimiter, last);
                param = o.Parameters.substr(last, next - last);
                end = std::stoi(param);
                last = next + 1;
                string signature;
                next = o.Parameters.find(delimiter, last);
                param = o.Parameters.substr(last, next - last);
                signature = param;

                if (o.Function == "Loop") {
                    loop(o, start, end, signature);
                    return void_result();
                }
                FC_THROW_EXCEPTION(fc::invalid_arg_exception, ("Invalid function call"));
            }
            FC_CAPTURE_AND_RETHROW((o))
        }
    }
}
