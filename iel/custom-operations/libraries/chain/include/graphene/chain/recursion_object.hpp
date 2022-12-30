#pragma once

#include <boost/multi_index_container_fwd.hpp>

#include <graphene/db/object.hpp>
#include <graphene/db/generic_index.hpp>
#include <graphene/chain/types.hpp>

using std::string;

namespace graphene {
    namespace chain {

        class recursion_object : public graphene::db::abstract_object<recursion_object> {

        public:

            static const uint8_t space_id = implementation_ids;
            static const uint8_t type_id = impl_recursion_object_type;

            account_id_type account;
            string Function;
            string Parameters;
        };

        struct by_recursion;

        typedef multi_index_container <
        recursion_object,
        indexed_by<
                ordered_unique <
                tag < by_id>, member<object, object_id_type, &object::id>>,
        ordered_unique <
        tag<by_recursion>, member<recursion_object, int, nullptr>>>>
        recursion_object_index_type;

    }
}

FC_REFLECT_TYPENAME(graphene::chain::recursion_object)
GRAPHENE_DECLARE_EXTERNAL_SERIALIZATION(graphene::chain::recursion_object)
