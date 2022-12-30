#pragma once

#include <boost/multi_index_container_fwd.hpp>

#include <graphene/db/object.hpp>
#include <graphene/db/generic_index.hpp>
#include <graphene/chain/types.hpp>

using std::string;

namespace graphene {
    namespace chain {

        class static_check_object : public graphene::db::abstract_object<static_check_object> {

        public:

            static const uint8_t space_id = implementation_ids;
            static const uint8_t type_id = impl_static_check_object_type;

            static bool checkVar;

            account_id_type account;
            string Function;
            string Parameters;
        };

        struct by_static_check;

        typedef multi_index_container <
        static_check_object,
        indexed_by<
                ordered_unique <
                tag < by_id>, member<object, object_id_type, &object::id>>,
        ordered_unique <
        tag<by_static_check>, member<static_check_object, int, nullptr>>>>
        static_check_object_index_type;

    }
}

FC_REFLECT_TYPENAME(graphene::chain::static_check_object)
GRAPHENE_DECLARE_EXTERNAL_SERIALIZATION(graphene::chain::static_check_object)
