#pragma once

#include <boost/multi_index_container_fwd.hpp>

#include <graphene/db/object.hpp>
#include <graphene/db/generic_index.hpp>
#include <graphene/chain/types.hpp>

using std::string;

namespace graphene {
    namespace chain {

        class smallbank_out_object : public graphene::db::abstract_object<smallbank_out_object> {
        public:
            static const uint8_t space_id = implementation_ids;
            static const uint8_t type_id = impl_smallbank_out_object_type;
            
            flat_map<string, int> map;

            static constexpr const char checkingSuffix[] = "_checking";

            static constexpr const char savingsSuffix[] = "_savings";

        };

        struct by_smallbank;

        typedef multi_index_container <
        smallbank_out_object,
        indexed_by<
                ordered_unique <
                tag < by_id>, member<object, object_id_type, &object::id>>,
        ordered_unique <
        tag<by_smallbank>, member<smallbank_out_object, flat_map<string, int>, &smallbank_out_object::map>>>>
        smallbank_object_index_type;

        typedef generic_index <smallbank_out_object, smallbank_object_index_type> smallbank_index;

    }
}

FC_REFLECT_TYPENAME(graphene::chain::smallbank_out_object)
GRAPHENE_DECLARE_EXTERNAL_SERIALIZATION(graphene::chain::smallbank_out_object)
