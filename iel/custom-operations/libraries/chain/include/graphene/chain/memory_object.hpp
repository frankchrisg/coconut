#pragma once

#include <boost/multi_index_container_fwd.hpp>

#include <graphene/db/object.hpp>
#include <graphene/db/generic_index.hpp>
#include <graphene/chain/types.hpp>

using std::string;

namespace graphene {
    namespace chain {

        class memory_object : public graphene::db::abstract_object<memory_object> {

        public:

            static const uint8_t space_id = implementation_ids;
            static const uint8_t type_id = impl_memory_object_type;

            account_id_type account;
            string Function;
            string Parameters;

            static constexpr const char field[] ="!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
        };

        struct by_memory;

        typedef multi_index_container <
        memory_object,
        indexed_by<
                ordered_unique <
                tag < by_id>, member<object, object_id_type, &object::id>>,
        ordered_unique <
        tag<by_memory>, member<memory_object, int, nullptr>>>>
        memory_object_index_type;

    }
}

FC_REFLECT_TYPENAME(graphene::chain::memory_object)
GRAPHENE_DECLARE_EXTERNAL_SERIALIZATION(graphene::chain::memory_object)
