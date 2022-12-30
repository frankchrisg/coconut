#include <graphene/chain/database.hpp>

#include <graphene/chain/memory_evaluator.hpp>
#include <graphene/chain/memory_object.hpp>

namespace graphene {
    namespace chain {

        const char memory_object::field[];

        const bool usePointerArray = false;
        const bool delPointerArray = true;

        void_result memory_evaluator::do_evaluate(const memory_operation &o) {
            return void_result();
        }

        string getChars(int firstChar, int length) {
            vector<char> ret;
            for (int i = firstChar; i < length + firstChar; i++) {
                ret.push_back(memory_object::field[((firstChar + i) %
                                                    (sizeof(memory_object::field) / sizeof(memory_object::field[0])))]);
            }
            std::string value(ret.begin(), ret.end());
            return value;
        }

        void
        memory_evaluator::memory(const memory_operation &o, int lenOut, int lenIn, int firstChar, int length,
                                 bool useVector,
                                 const string &signature) {

            if (useVector) {
                vector<vector<string>> vec(lenOut, vector<string>(lenIn));
                for (int i = 0; i < lenOut; i++) {
                    //vector<string> vecIn;
                    for (int j = 0; j < lenIn; j++) {
                        vec[i][j] = getChars(firstChar + i + j, length + i + j);
                    }
                    //vec.push_back(vecIn);
                }
            } else {
                if (!usePointerArray) {
                    string arr[lenOut][lenIn];
                    for (int i = 0; i < lenOut; i++) {
                        for (int j = 0; j < lenIn; j++) {
                            arr[i][j] = getChars(firstChar + i + j, length + i + j);
                        }
                    }
                } else {
                    string **arr = new string *[lenOut];
                    for (int i = 0; i < lenOut; i++) {
                        arr[i] = new string[lenIn];
                    }

                    for (int i = 0; i < lenOut; i++) {
                        for (int j = 0; j < lenIn; j++) {
                            arr[i][j] = getChars(firstChar + i + j, length + i + j);
                        }
                    }

                    if (delPointerArray) {
                        for (int i = 0; i < lenOut; ++i) {
                            delete[] arr[i];
                        }
                        delete[] arr;
                    }
                }
            }

            /*const_cast<string &>(o.Auxiliary_Event) = "memory " + signature;*/

            const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                aeo.signature = "memory " + signature;
            });
        }

        static const char delimiter = ';';

        void_result memory_evaluator::do_apply(const memory_operation &o) {
            try {

                if (o.Function == "Memory") {
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

                    if (len != 6) {
                        FC_CAPTURE_AND_THROW(fc::invalid_arg_exception, ("Call to Memory must have 6 parameters"));
                    }

                    last = 0;
                    int lenOut;
                    next = o.Parameters.find(delimiter, last);
                    param = o.Parameters.substr(last, next - last);
                    lenOut = std::stoi(param);
                    last = next + 1;
                    int lenIn;
                    next = o.Parameters.find(delimiter, last);
                    param = o.Parameters.substr(last, next - last);
                    lenIn = std::stoi(param);
                    last = next + 1;
                    int firstChar;
                    next = o.Parameters.find(delimiter, last);
                    param = o.Parameters.substr(last, next - last);
                    firstChar = std::stoi(param);
                    last = next + 1;
                    int length;
                    next = o.Parameters.find(delimiter, last);
                    param = o.Parameters.substr(last, next - last);
                    length = std::stoi(param);
                    last = next + 1;
                    bool useVector;
                    next = o.Parameters.find(delimiter, last);
                    param = o.Parameters.substr(last, next - last);
                    useVector = std::stoi(param);
                    last = next + 1;
                    string signature;
                    next = o.Parameters.find(delimiter, last);
                    param = o.Parameters.substr(last, next - last);
                    signature = param;

                    memory(o, lenOut, lenIn, firstChar, length, useVector, signature);
                    return void_result();
                }
                FC_THROW_EXCEPTION(fc::invalid_arg_exception, ("Invalid function call"));
            }
            FC_CAPTURE_AND_RETHROW((o))
        }
    }
}
