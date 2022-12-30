#pragma once

#include <boost/multi_index_container_fwd.hpp>

#include <graphene/db/object.hpp>
#include <graphene/db/generic_index.hpp>
#include <graphene/chain/types.hpp>

using std::string;

namespace graphene {
    namespace chain {

        class quicksortRec_object : public graphene::db::abstract_object<quicksortRec_object> {

        public:

            static const uint8_t space_id = implementation_ids;
            static const uint8_t type_id = impl_quicksortRec_object_type;

            account_id_type account;
            string Function;
            string Parameters;
        };

        struct by_quicksortRec;

        typedef multi_index_container <
        quicksortRec_object,
        indexed_by<
                ordered_unique <
                tag < by_id>, member<object, object_id_type, &object::id>>,
        ordered_unique <
        tag<by_quicksortRec>, member<quicksortRec_object, int, nullptr>>>>
        quicksortRec_object_index_type;

    }
}

FC_REFLECT_TYPENAME(graphene::chain::quicksortRec_object)
GRAPHENE_DECLARE_EXTERNAL_SERIALIZATION(graphene::chain::quicksortRec_object)
