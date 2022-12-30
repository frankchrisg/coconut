#pragma once

#include <boost/multi_index_container_fwd.hpp>

#include <graphene/db/object.hpp>
#include <graphene/db/generic_index.hpp>
#include <graphene/chain/types.hpp>

using std::string;

namespace graphene {
    namespace chain {

        class io_out_object : public graphene::db::abstract_object<io_out_object> {
        public:
            static const uint8_t space_id = implementation_ids;
            static const uint8_t type_id = impl_io_out_object_type;

            string Key;
            vector<char> Value;

            static constexpr const char chars[] ="!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";

        };

        struct by_io;

        typedef multi_index_container <
        io_out_object,
        indexed_by<
                ordered_unique <
                tag < by_id>, member<object, object_id_type, &object::id>>,
        ordered_unique <
        tag<by_io>, member<io_out_object, string, &io_out_object::Key>>>>
        io_object_index_type;

        typedef generic_index <io_out_object, io_object_index_type> io_index;

    }
}

FC_REFLECT_TYPENAME(graphene::chain::io_out_object)
GRAPHENE_DECLARE_EXTERNAL_SERIALIZATION(graphene::chain::io_out_object)
