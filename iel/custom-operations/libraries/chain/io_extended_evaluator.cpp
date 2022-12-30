#include <graphene/chain/database.hpp>

#include <graphene/chain/io_extended_evaluator.hpp>
#include <graphene/chain/io_extended_in_object.hpp>

namespace graphene {
    namespace chain {

        const char io_extended_out_object::chars[];

        void_result io_extended_evaluator::do_evaluate(const io_extended_in_operation &o) {
            return void_result();
        }

        void
        io_extended_evaluator::write(const io_extended_in_operation &o, vector<string> args) {

            if (args.size() != 4) {
                FC_CAPTURE_AND_THROW(fc::invalid_arg_exception, ("Call to Write must have 4 parameters"));
            }

            int size = std::stoi(args[0]);
            int startKey = std::stoi(args[1]);
            int retLen = std::stoi(args[2]);
            string signature = args[3];

            vector<char> stateArr;
            for (int i = 0; i < size; i++) {
                string sK = std::to_string(startKey + i);

                const auto &bucket_idx = db().get_index_type<io_extended_index>();
                const auto &by_key_idx = bucket_idx.indices().get<by_io_extended>();
                auto bucket_itr = by_key_idx.find(sK);

                if (bucket_itr != by_key_idx.end()) {
                    /*const_cast<string &>(o.Auxiliary_Event) =
                            "ioExtended/write/exist " + signature;*/

                    const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                        aeo.signature = "ioExtended/write/exist " + signature;
                    });
                    return;
                }
                vector<char> val = io_extended_evaluator::getVal(startKey + i, retLen);

                const io_extended_out_object &io = db().create<io_extended_out_object>([&](io_extended_out_object &io) {
                    io.Key = sK;
                    io.Value = val;
                });

                stateArr.insert(stateArr.end(), val.begin(), val.end());
                //stateArr.insert(stateArr.end(), v.begin(), v.end());
            }

            //std::string s(stateArr.begin(), stateArr.end());
            /*const_cast<string &>(o.Auxiliary_Event) =
                    "storage/write " + signature;*/

            const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                aeo.signature = "storage/write " + signature;
            });
        }

        vector<char> io_extended_evaluator::getVal(int k, int retLen) {
            vector<char> ret;
            for (int i = 0; i < retLen; i++) {
                ret.push_back(io_extended_out_object::chars[((k + i) %
                                                             (sizeof(io_extended_out_object::chars) /
                                                              sizeof(io_extended_out_object::chars[0])))]);
            }
            //std::string value(ret.begin(), ret.end());
            return ret;
        }

        void
        io_extended_evaluator::scan(const io_extended_in_operation &o, vector<string> args) {

            if (args.size() != 3) {
                FC_CAPTURE_AND_THROW(fc::invalid_arg_exception, ("Call to Scan must have 3 parameters"));
            }

            int size = std::stoi(args[0]);
            int startKey = std::stoi(args[1]);
            string signature = args[2];

            vector<char> stateArr;
            for (int i = 0; i < size; i++) {
                string sK = std::to_string(startKey + i);

                const auto &bucket_idx = db().get_index_type<io_extended_index>();
                const auto &by_io_extended_idx = bucket_idx.indices().get<by_io_extended>();
                auto bucket_itr = by_io_extended_idx.find(sK);

                if (bucket_itr == by_io_extended_idx.end()) {
                    /*const_cast<string &>(o.Auxiliary_Event) =
                            "ioExtended/scan/doesntexist " + signature;*/

                    const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                        aeo.signature = "ioExtended/scan/doesntexist " + signature;
                    });

                    return;
                } else {
                    io_extended_out_object it = *bucket_itr;
                    stateArr.insert(stateArr.end(), it.Value.begin(), it.Value.end());
                }
            }

            //std::string s(stateArr.begin(), stateArr.end());

            /*const_cast<string &>(o.Auxiliary_Event) =
                    "storage/scan " + signature;*/

            const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                aeo.signature = "storage/scan " + signature;
            });
        }

        void
        io_extended_evaluator::revertScan(const io_extended_in_operation &o, vector<string> args) {

            if (args.size() != 3) {
                FC_CAPTURE_AND_THROW(fc::invalid_arg_exception, ("Call to RevertScan must have 3 parameters"));
            }

            int size = std::stoi(args[0]);
            int startKey = std::stoi(args[1]);
            string signature = args[2];

            vector<char> stateArr;
            for (int i = 0; i < size; i++) {
                string sK = std::to_string(startKey + size - i - 1);

                const auto &bucket_idx = db().get_index_type<io_extended_index>();
                const auto &by_io_extended_idx = bucket_idx.indices().get<by_io_extended>();
                auto bucket_itr = by_io_extended_idx.find(sK);

                if (bucket_itr == by_io_extended_idx.end()) {
                    /*const_cast<string &>(o.Auxiliary_Event) =
                            "ioExtended/revertScan/doesntexist " + signature;*/

                    const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                        aeo.signature = "ioExtended/revertScan/doesntexist " + signature;
                    });

                    return;
                } else {
                    io_extended_out_object it = *bucket_itr;
                    stateArr.insert(stateArr.end(), it.Value.begin(), it.Value.end());
                }
            }

            //std::string s(stateArr.begin(), stateArr.end());

            /*const_cast<string &>(o.Auxiliary_Event) =
                    "storage/revertScan " + signature;*/

            const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                aeo.signature = "storage/revertScan " + signature;
            });
        }

        static const char delimiter = ';';

        void_result io_extended_evaluator::do_apply(const io_extended_in_operation &o) {
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

                if (o.Function == "Write") {
                    write(o, arr);
                    return void_result();
                }
                if (o.Function == "Scan") {
                    scan(o, arr);
                    return void_result();
                }
                if (o.Function == "RevertScan") {
                    revertScan(o, arr);
                    return void_result();
                }
                FC_THROW_EXCEPTION(fc::invalid_arg_exception, ("Invalid function call"));
            }
            FC_CAPTURE_AND_RETHROW((o))
        }
    }
}
