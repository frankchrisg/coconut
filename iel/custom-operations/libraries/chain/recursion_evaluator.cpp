#include <graphene/chain/database.hpp>

#include <graphene/chain/recursion_evaluator.hpp>
#include <graphene/chain/recursion_object.hpp>
#include <graphene/chain/auxiliary_event_object.hpp>

namespace graphene {
    namespace chain {

        void_result recursion_evaluator::do_evaluate(const recursion_operation &o) {
            return void_result();
        }

        void
        recursion_evaluator::recursion(const recursion_operation &o, int start, int end) {

            if (start != end) {
                recursion_evaluator::recursion(o, start, end - 1);
            }
        }

        static const char delimiter = ';';

        void_result recursion_evaluator::do_apply(const recursion_operation &o) {
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
                    FC_CAPTURE_AND_THROW(fc::invalid_arg_exception, ("Call to Recursion must have 3 parameters"));
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

                if (o.Function == "Recursion") {
                    //elog("s " + std::to_string(start) + " e " + std::to_string(end));
                    recursion(o, start, end);
                    /*const_cast<string &>(o.Auxiliary_Event) = "recursion " + signature;*/

                    const auxiliary_event_object &aeo = db().create<auxiliary_event_object>(
                            [&](auxiliary_event_object &aeo) {
                                aeo.signature = "recursion " + signature;
                            });
                    return void_result();
                }
                FC_THROW_EXCEPTION(fc::invalid_arg_exception, ("Invalid function call"));
            }
            FC_CAPTURE_AND_RETHROW((o))
        }
    }
}

