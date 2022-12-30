#pragma once

#include <boost/multi_index_container_fwd.hpp>

#include <graphene/db/object.hpp>
#include <graphene/db/generic_index.hpp>
#include <graphene/chain/types.hpp>

using std::string;

namespace graphene {
    namespace chain {

        class auxiliary_event_object : public graphene::db::abstract_object<auxiliary_event_object> {

        public:

            static const uint8_t space_id = implementation_ids;
            static const uint8_t type_id = impl_auxiliary_event_object_type;

            string signature;
        };

        struct by_auxiliary_event;

        typedef multi_index_container <
        auxiliary_event_object,
        indexed_by<
                ordered_unique <
                tag < by_id>, member<object, object_id_type, &object::id>>,
        ordered_unique <
        tag<by_auxiliary_event>, member<auxiliary_event_object, string, &auxiliary_event_object::signature>>>>
        auxiliary_event_object_index_type;

        typedef generic_index <auxiliary_event_object, auxiliary_event_object_index_type> auxiliary_event_index;

    }
}

FC_REFLECT_TYPENAME(graphene::chain::auxiliary_event_object)
GRAPHENE_DECLARE_EXTERNAL_SERIALIZATION(graphene::chain::auxiliary_event_object)
