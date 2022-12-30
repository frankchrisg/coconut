#include <graphene/chain/database.hpp>

#include <graphene/chain/key_value_extended_evaluator.hpp>
#include <graphene/chain/key_value_extended_in_object.hpp>

namespace graphene {
    namespace chain {

        void_result key_value_extended_evaluator::do_evaluate(const key_value_extended_in_operation &o) {
            return void_result();
        }

        void
        key_value_extended_evaluator::get(const key_value_extended_in_operation &o, vector<string> args) {

            if (args.size() != 2) {
                FC_CAPTURE_AND_THROW(fc::invalid_arg_exception, ("Call to Get must have 2 parameters"));
            }

            const auto &bucket_idx = db().get_index_type<key_value_extended_index>();
            const auto &by_key_idx = bucket_idx.indices().get<by_key_value_extended>();
            auto bucket_itr = by_key_idx.find(args[0]);

            string signature = args[1];

            if (bucket_itr == by_key_idx.end()) {
                /*const_cast<string &>(o.Auxiliary_Event) =
                        "keyValueEx/get/doesntexist " + signature;*/

                const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                    aeo.signature = "keyValueEx/get/doesntexist " + signature;
                });

            } else {
                key_value_extended_out_object it = *bucket_itr;
                /*const_cast<string &>(o.Auxiliary_Event) =
                        "keyValueEx/get " + signature;*/

                const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                    aeo.signature = "keyValueEx/get " + signature;
                });
            }

            //return *bucket_itr;
        }

        void
        key_value_extended_evaluator::set(const key_value_extended_in_operation &o, vector<string> args) {

            if (args.size() != 3) {
                FC_CAPTURE_AND_THROW(fc::invalid_arg_exception, ("Call to Set must have 3 parameters"));
            }

            string key = args[0];
            string value = args[1];

            const auto &bucket_idx = db().get_index_type<key_value_extended_index>();
            const auto &by_key_idx = bucket_idx.indices().get<by_key_value_extended>();
            auto bucket_itr = by_key_idx.find(key);
            string signature = args[2];
            if (bucket_itr != by_key_idx.end()) {
                /*const_cast<string &>(o.Auxiliary_Event) =
                        "keyValueEx/set/exist " + signature;*/

                const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                    aeo.signature = "keyValueEx/set/exist " + signature;
                });
            } else {
                const key_value_extended_out_object &kvo = db().create<key_value_extended_out_object>(
                        [&](key_value_extended_out_object &kvo) {
                            kvo.Key = key;
                            kvo.Value = value;
                        });
                /*const_cast<string &>(o.Auxiliary_Event) =
                        "keyValueEx/set " + signature;*/

                const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                    aeo.signature = "keyValueEx/set " + signature;
                });
            }
        }

        static const char delimiter = ';';

        void_result key_value_extended_evaluator::do_apply(const key_value_extended_in_operation &o) {
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

                last = 0;
                std::vector<string> arr;
                string signature;
                for (int i = 0; i < len; i++) {
                    next = o.Parameters.find(delimiter, last);
                    param = o.Parameters.substr(last, next - last);
                    arr.push_back(param);
                    last = next + 1;
                }

                if (o.Function == "Get") {
                    get(o, arr);
                    return void_result();
                }

                if (o.Function == "Set") {
                    set(o, arr);
                    return void_result();
                }
                FC_THROW_EXCEPTION(fc::invalid_arg_exception, ("Invalid function call"));
            }
            FC_CAPTURE_AND_RETHROW((o))
        }
    }
}
