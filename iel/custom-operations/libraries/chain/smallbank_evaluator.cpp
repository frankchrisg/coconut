#include <graphene/chain/database.hpp>

#include <graphene/chain/smallbank_evaluator.hpp>
#include <graphene/chain/smallbank_in_object.hpp>

#include <graphene/chain/smallbank_out_object.hpp>

namespace graphene {
    namespace chain {

        const char smallbank_out_object::checkingSuffix[];
        const char smallbank_out_object::savingsSuffix[];

        void_result smallbank_evaluator::do_evaluate(const smallbank_in_operation &o) {
            return void_result();
        }

        string getSavings(const string &a) {
            string s(smallbank_out_object::savingsSuffix);
            return a + s;
        }

        string getChecking(const string &a) {
            string s(smallbank_out_object::checkingSuffix);
            return a + s;
        }

        void
        smallbank_evaluator::writeCheck(const smallbank_in_operation &o, vector<string> args) {

            string acctId = args[0];

            /*flat_map<string, int> s;
            std::pair<string, int> t;
            t.first = "a";
            t.second = 22;
            s.insert(t);*/

            const auto &bucket_idx = db().get_index_type<smallbank_index>();
            const auto &by_smallbank_idx = bucket_idx.indices().get<by_smallbank>();

            std::pair<string, int> checkingIter;
            std::pair<string, int> savingsIter;
            auto targetIter = by_smallbank_idx.end();
            for (auto iter = by_smallbank_idx.begin(); iter != by_smallbank_idx.end(); iter++) {
                if (iter->map.count(getChecking(acctId)) > 0 && iter->map.count(getSavings(acctId)) > 0) {
                    checkingIter = *iter->map.find(getChecking(acctId));
                    savingsIter = *iter->map.find(getSavings(acctId));
                    targetIter = iter;
                }
                if (targetIter != by_smallbank_idx.end()) {
                    break;
                }
            }

            int amount = std::stoi(args[1]);

            string signature = args[2];

            if (targetIter == by_smallbank_idx.end() || amount < 0) {
                /*const_cast<string &>(o.Auxiliary_Event) =
                        "writeCheck/error " + signature;*/

                const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                    aeo.signature = "writeCheck/error " + signature;
                });
                return;
            }

            int savings = savingsIter.second;
            int checking = checkingIter.second;
            int total = savings + checking;

            if (total < amount) {
                int check = checking - amount - 1;

                db().modify(*targetIter, [&](smallbank_out_object &soo) {
                    soo.map[getChecking(acctId)] = check;
                });
            } else {
                int check = checking - amount;
                db().modify(*targetIter, [&](smallbank_out_object &soo) {
                    soo.map[getChecking(acctId)] = check;
                });
            }

            string output;
            string convrt;

            for (auto it = targetIter->map.cbegin(); it != targetIter->map.cend(); it++) {
                convrt = std::to_string(it->second);
                output += (it->first) + ":" + (convrt) + ", ";
            }

            /*const_cast<string &>(o.Auxiliary_Event) =
                    "writeCheck " + signature;*/

            const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                aeo.signature = "writeCheck " + signature;
            });

        }

        void
        smallbank_evaluator::depositChecking(const smallbank_in_operation &o, vector<string> args) {

            string acctId = args[0];

            const auto &bucket_idx = db().get_index_type<smallbank_index>();
            const auto &by_smallbank_idx = bucket_idx.indices().get<by_smallbank>();

            std::pair<string, int> checkingIter;
            auto targetIter = by_smallbank_idx.end();
            for (auto iter = by_smallbank_idx.begin(); iter != by_smallbank_idx.end(); iter++) {
                if (iter->map.count(getChecking(acctId)) > 0) {
                    checkingIter = *iter->map.find(getChecking(acctId));
                    targetIter = iter;
                }
                if (targetIter != by_smallbank_idx.end()) {
                    break;
                }
            }

            string signature = args[2];

            if (targetIter == by_smallbank_idx.end()) {
                /*const_cast<string &>(o.Auxiliary_Event) =
                        "depositChecking/error " + signature;*/

                const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                    aeo.signature = "depositChecking/error " + signature;
                });
                return;
            }

            int currentAmount = checkingIter.second;
            int amount = std::stoi(args[1]);

            currentAmount += amount;

            db().modify(*targetIter, [&](smallbank_out_object &soo) {
                soo.map[getChecking(acctId)] = currentAmount;
            });

            string output;
            string convrt;

            for (auto it = targetIter->map.cbegin(); it != targetIter->map.cend(); it++) {
                convrt = std::to_string(it->second);
                output += (it->first) + ":" + (convrt) + ", ";
            }

            /*const_cast<string &>(o.Auxiliary_Event) =
                    "depositChecking " + signature;*/

            const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                aeo.signature = "depositChecking " + signature;
            });

        }

        void
        smallbank_evaluator::transactSavings(const smallbank_in_operation &o, vector<string> args) {

            string acctId = args[0];

            const auto &bucket_idx = db().get_index_type<smallbank_index>();
            const auto &by_smallbank_idx = bucket_idx.indices().get<by_smallbank>();

            std::pair<string, int> savingsIter;
            auto targetIter = by_smallbank_idx.end();
            for (auto iter = by_smallbank_idx.begin(); iter != by_smallbank_idx.end(); iter++) {
                if (iter->map.count(getSavings(acctId)) > 0) {
                    savingsIter = *iter->map.find(getSavings(acctId));
                    targetIter = iter;
                }
                if (targetIter != by_smallbank_idx.end()) {
                    break;
                }
            }

            string signature = args[2];

            if (targetIter == by_smallbank_idx.end()) {
                /*const_cast<string &>(o.Auxiliary_Event) =
                        "transactSavings/error " + signature;*/

                const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                    aeo.signature = "transactSavings/error " + signature;
                });
                return;
            }

            int amount = std::stoi(args[1]);

            int balance = savingsIter.second - amount;
            if (balance < 0) {
                /*const_cast<string &>(o.Auxiliary_Event) =
                        "transactSavings/error/balance " + signature;*/

                const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                    aeo.signature = "transactSavings/error/balance " + signature;
                });
                return;
            }

            savingsIter.second -= amount;

            db().modify(*targetIter, [&](smallbank_out_object &soo) {
                soo.map[getSavings(acctId)] = savingsIter.second;
            });

            string output;
            string convrt;

            for (auto it = targetIter->map.cbegin(); it != targetIter->map.cend(); it++) {
                convrt = std::to_string(it->second);
                output += (it->first) + ":" + (convrt) + ", ";
            }

            /*const_cast<string &>(o.Auxiliary_Event) =
                    "transactSavings " + signature;*/

            const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                aeo.signature = "transactSavings " + signature;
            });

        }

        void
        smallbank_evaluator::sendPayment(const smallbank_in_operation &o, vector<string> args) {

            string sender = args[0];
            string destination = args[1];
            int amount = std::stoi(args[2]);

            const auto &bucket_idx = db().get_index_type<smallbank_index>();
            const auto &by_smallbank_idx = bucket_idx.indices().get<by_smallbank>();

            std::pair<string, int> savingsIterSender;
            std::pair<string, int> checkingIterSender;
            std::pair<string, int> savingsIterDestination;
            std::pair<string, int> checkingIterDestination;
            auto targetIterSender = by_smallbank_idx.end();
            auto targetIterDestination = by_smallbank_idx.end();
            for (auto iter = by_smallbank_idx.begin(); iter != by_smallbank_idx.end(); iter++) {
                if (iter->map.count(getSavings(sender)) > 0 && iter->map.count(getChecking(sender)) > 0) {
                    checkingIterSender = *iter->map.find(getChecking(sender));
                    savingsIterSender = *iter->map.find(getSavings(sender));
                    targetIterSender = iter;
                }
                if (iter->map.count(getSavings(destination)) > 0 && iter->map.count(getChecking(destination)) > 0) {
                    checkingIterDestination = *iter->map.find(getChecking(destination));
                    savingsIterDestination = *iter->map.find(getSavings(destination));
                    targetIterDestination = iter;
                }
                if (targetIterSender != by_smallbank_idx.end() && targetIterDestination != by_smallbank_idx.end()) {
                    break;
                }
            }

            string signature = args[3];

            if (targetIterSender == by_smallbank_idx.end() || targetIterDestination == by_smallbank_idx.end()) {
                /*const_cast<string &>(o.Auxiliary_Event) =
                        "sendPayment/error " + signature;*/
                const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                    aeo.signature = "sendPayment/error " + signature;
                });
                return;
            }

            if (checkingIterSender.second < amount) {
                /*const_cast<string &>(o.Auxiliary_Event) =
                        "sendPayment/error/checkingBalanceSender " + signature;*/

                const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                    aeo.signature = "sendPayment/error/checkingBalanceSender " + signature;
                });
                return;
            }

            checkingIterSender.second -= amount;
            checkingIterDestination.second += amount;

            db().modify(*targetIterSender, [&](smallbank_out_object &soo) {
                soo.map[getChecking(sender)] = checkingIterSender.second;
            });

            db().modify(*targetIterDestination, [&](smallbank_out_object &soo) {
                soo.map[getChecking(destination)] = checkingIterDestination.second;
            });

            string output;
            string convrt;

            for (auto it = targetIterSender->map.cbegin(); it != targetIterSender->map.cend(); it++) {
                convrt = std::to_string(it->second);
                output += (it->first) + ":" + (convrt) + ", ";
            }
            for (auto it = targetIterDestination->map.cbegin(); it != targetIterDestination->map.cend(); it++) {
                convrt = std::to_string(it->second);
                output += (it->first) + ":" + (convrt) + ", ";
            }

            /*const_cast<string &>(o.Auxiliary_Event) =
                    "sendPayment " + signature;*/

            const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                aeo.signature = "sendPayment " + signature;
            });
        }

        void
        smallbank_evaluator::balance(const smallbank_in_operation &o, vector<string> args) {

            string acctId = args[0];

            const auto &bucket_idx = db().get_index_type<smallbank_index>();
            const auto &by_smallbank_idx = bucket_idx.indices().get<by_smallbank>();

            std::pair<string, int> savingsIter;
            std::pair<string, int> checkingIter;
            auto targetIter = by_smallbank_idx.end();
            for (auto iter = by_smallbank_idx.begin(); iter != by_smallbank_idx.end(); iter++) {
                if (iter->map.count(getSavings(acctId)) > 0 && iter->map.count(getChecking(acctId)) > 0) {
                    savingsIter = *iter->map.find(getSavings(acctId));
                    checkingIter = *iter->map.find(getChecking(acctId));
                    targetIter = iter;
                }
                if (targetIter != by_smallbank_idx.end()) {
                    break;
                }
            }

            string signature = args[1];

            if (targetIter == by_smallbank_idx.end()) {
                /*const_cast<string &>(o.Auxiliary_Event) =
                        "balance/error " + signature;*/

                const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                    aeo.signature = "balance/error " + signature;
                });

                //int zero = 0;
                //return zero;
                return;
            }

            int savings = savingsIter.second;
            int checking = checkingIter.second;
            int total = savings + checking;

            string output;
            string convrt;

            for (auto it = targetIter->map.cbegin(); it != targetIter->map.cend(); it++) {
                convrt = std::to_string(it->second);
                output += (it->first) + ":" + (convrt) + ", ";
            }

            /*const_cast<string &>(o.Auxiliary_Event) =
                    "balance " + signature;*/

            const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                //aeo.signature = "balance " + signature;
                string totalAsString = std::to_string(total);
                aeo.signature = "balance " + signature + " __balance_event:" + "-balance-" + totalAsString + "-acctId-" + acctId;
            });

            //return total;
        }

        void
        smallbank_evaluator::amalgamate(const smallbank_in_operation &o, vector<string> args) {

            string acctId0 = args[0];
            string acctId1 = args[1];

            const auto &bucket_idx = db().get_index_type<smallbank_index>();
            const auto &by_smallbank_idx = bucket_idx.indices().get<by_smallbank>();

            std::pair<string, int> savingsIterAcctId0;
            std::pair<string, int> checkingIterAcctId0;
            std::pair<string, int> savingsIterAcctId1;
            std::pair<string, int> checkingIterAcctId1;
            auto targetIterAcctId0 = by_smallbank_idx.end();
            auto targetIterAcctId1 = by_smallbank_idx.end();
            for (auto iter = by_smallbank_idx.begin(); iter != by_smallbank_idx.end(); iter++) {
                if (iter->map.count(getSavings(acctId0)) > 0 && iter->map.count(getChecking(acctId0)) > 0) {
                    savingsIterAcctId0 = *iter->map.find(getSavings(acctId0));
                    checkingIterAcctId0 = *iter->map.find(getChecking(acctId0));
                    targetIterAcctId0 = iter;
                }
                if (iter->map.count(getSavings(acctId1)) > 0 && iter->map.count(getChecking(acctId1)) > 0) {
                    savingsIterAcctId1 = *iter->map.find(getSavings(acctId1));
                    checkingIterAcctId1 = *iter->map.find(getChecking(acctId1));
                    targetIterAcctId1 = iter;
                }
                if (targetIterAcctId0 != by_smallbank_idx.end() && targetIterAcctId1 != by_smallbank_idx.end()) {
                    break;
                }
            }

            string signature = args[2];

            if (targetIterAcctId0 == by_smallbank_idx.end() || targetIterAcctId1 == by_smallbank_idx.end()) {
                /*const_cast<string &>(o.Auxiliary_Event) =
                        "amalgamate/error " + signature;*/

                const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                    aeo.signature = "amalgamate/error " + signature;
                });

                return;
            }

            int total = savingsIterAcctId0.second + checkingIterAcctId0.second;
            //assert(total >= 0)

            int zero = 0;

            db().modify(*targetIterAcctId0, [&](smallbank_out_object &soo) {
                soo.map[getChecking(acctId0)] = zero;
            });
            db().modify(*targetIterAcctId0, [&](smallbank_out_object &soo) {
                soo.map[getSavings(acctId0)] = zero;
            });

            checkingIterAcctId1.second += total;

            db().modify(*targetIterAcctId1, [&](smallbank_out_object &soo) {
                soo.map[getChecking(acctId1)] = checkingIterAcctId1.second;
            });

            string output;
            string convrt;

            for (auto it = targetIterAcctId0->map.cbegin(); it != targetIterAcctId0->map.cend(); it++) {
                convrt = std::to_string(it->second);
                output += (it->first) + ":" + (convrt) + ", ";
            }
            for (auto it = targetIterAcctId1->map.cbegin(); it != targetIterAcctId1->map.cend(); it++) {
                convrt = std::to_string(it->second);
                output += (it->first) + ":" + (convrt) + ", ";
            }

            /*const_cast<string &>(o.Auxiliary_Event) =
                    "amalgamate " + signature;*/

            const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                aeo.signature = "amalgamate " + signature;
            });

            //return total
        }

        void
        smallbank_evaluator::createAccount(const smallbank_in_operation &o, vector<string> args) {

            string acctIdChecking = args[0];
            string acctIdSavings = args[1];
            int checking = std::stoi(args[2]);
            int savings = std::stoi(args[3]);

            const smallbank_out_object &soo = db().create<smallbank_out_object>([&](smallbank_out_object &soo) {
                std::pair<string, int> checkingAccount;
                checkingAccount.first = getChecking(acctIdChecking);
                checkingAccount.second = checking;
                soo.map.insert(checkingAccount);
                std::pair<string, int> savingsAccount;
                savingsAccount.first = getSavings(acctIdSavings);
                savingsAccount.second = savings;
                soo.map.insert(savingsAccount);
            });

            string signature = args[4];

            /*const_cast<string &>(o.Auxiliary_Event) =
                    "createAccount " + signature;*/

            const auxiliary_event_object &aeo = db().create<auxiliary_event_object>([&](auxiliary_event_object &aeo) {
                aeo.signature = "createAccount " + signature;
            });

        }

        static const char delimiter = ';';

        void_result smallbank_evaluator::do_apply(const smallbank_in_operation &o) {
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

                if (o.Function == "WriteCheck") {
                    writeCheck(o, arr);
                    return void_result();
                }
                if (o.Function == "DepositChecking") {
                    depositChecking(o, arr);
                    return void_result();
                }
                if (o.Function == "TransactSavings") {
                    transactSavings(o, arr);
                    return void_result();
                }
                if (o.Function == "SendPayment") {
                    sendPayment(o, arr);
                    return void_result();
                }
                if (o.Function == "Balance") {
                    balance(o, arr);
                    return void_result();
                }
                if (o.Function == "Amalgamate") {
                    amalgamate(o, arr);
                    return void_result();
                }
                if (o.Function == "CreateAccount") {
                    createAccount(o, arr);
                    return void_result();
                }
                FC_THROW_EXCEPTION(fc::invalid_arg_exception, ("Invalid function call"));
            }
            FC_CAPTURE_AND_RETHROW((o))
        }
    }
}

