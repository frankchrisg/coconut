#include <graphene/chain/database.hpp>

#include <graphene/chain/static_check_evaluator.hpp>
#include <graphene/chain/static_check_object.hpp>
#include <graphene/chain/auxiliary_event_object.hpp>

namespace graphene {
    namespace chain {

        bool static_check_object::checkVar = true;

        void_result static_check_evaluator::do_evaluate(const static_check_operation &o) {
            return void_result();
        }

        string bool_cast(const bool b) {
            return b ? "true" : "false";
        }

        void
        static_check_evaluator::checkVarGet() {

            ilog("checkVar: ");
            ilog(bool_cast(static_check_object::checkVar));
            if (static_check_object::checkVar) {
                //return "true"
                return;
            } else {
                //return "false"
                return;
            }
        }

        void
        static_check_evaluator::checkVarSet(const string val) {
            bool checkExistingVar = std::stoi(val);
            static_check_object::checkVar = checkExistingVar;
            ilog("New checkVar: ");
            ilog(bool_cast(static_check_object::checkVar));
        }

        static const char delimiter = ';';

        void_result static_check_evaluator::do_apply(const static_check_operation &o) {
            try {

                size_t next;
                size_t last;
                std::string param;

                last = 0;

                next = o.Parameters.find(delimiter, last);
                param = o.Parameters.substr(last, next - last);

                if (o.Function == "CheckVarSet") {
                    checkVarSet(param);
                    return void_result();
                }
                if (o.Function == "CheckVarGet") {
                    checkVarGet();
                    return void_result();
                }
                FC_THROW_EXCEPTION(fc::invalid_arg_exception, ("Invalid function call"));
            }
            FC_CAPTURE_AND_RETHROW((o))
        }
    }
}
