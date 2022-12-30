#pragma once

#include <boost/multi_index_container_fwd.hpp>

#include <graphene/db/object.hpp>
#include <graphene/db/generic_index.hpp>
#include <graphene/chain/types.hpp>

using std::string;

namespace graphene {
    namespace chain {

        class io_extended_out_object : public graphene::db::abstract_object<io_extended_out_object> {
        public:
            static const uint8_t space_id = implementation_ids;
            static const uint8_t type_id = impl_io_extended_out_object_type;

            string Key;
            vector<char> Value;

            static constexpr const char chars[] ="!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";

        };

        struct by_io_extended;

        typedef multi_index_container <
        io_extended_out_object,
        indexed_by<
                ordered_unique <
                tag < by_id>, member<object, object_id_type, &object::id>>,
        ordered_unique <
        tag<by_io_extended>, member<io_extended_out_object, string, &io_extended_out_object::Key>>>>
        io_extended_object_index_type;

        typedef generic_index <io_extended_out_object, io_extended_object_index_type> io_extended_index;

    }
}

FC_REFLECT_TYPENAME(graphene::chain::io_extended_out_object)
GRAPHENE_DECLARE_EXTERNAL_SERIALIZATION(graphene::chain::io_extended_out_object)
