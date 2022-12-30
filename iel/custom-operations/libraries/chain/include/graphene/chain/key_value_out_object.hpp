#pragma once

#include <boost/multi_index_container_fwd.hpp>

#include <graphene/db/object.hpp>
#include <graphene/db/generic_index.hpp>
#include <graphene/chain/types.hpp>

using std::string;

namespace graphene {
    namespace chain {

        class key_value_out_object : public graphene::db::abstract_object<key_value_out_object> {
        public:
            static const uint8_t space_id = implementation_ids;
            static const uint8_t type_id = impl_key_value_out_object_type;

            string Key;
            string Value;

        };

        struct by_key_value;

        typedef multi_index_container <
        key_value_out_object,
        indexed_by<
                ordered_unique <
                tag < by_id>, member<object, object_id_type, &object::id>>,
        ordered_unique <
        tag<by_key_value>, member<key_value_out_object, string, &key_value_out_object::Key>>>>
        key_value_object_index_type;

        typedef generic_index <key_value_out_object, key_value_object_index_type> key_value_index;

    }
}

FC_REFLECT_TYPENAME(graphene::chain::key_value_out_object)
GRAPHENE_DECLARE_EXTERNAL_SERIALIZATION(graphene::chain::key_value_out_object)
