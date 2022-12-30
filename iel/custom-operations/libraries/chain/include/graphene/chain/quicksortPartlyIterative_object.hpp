#pragma once

#include <boost/multi_index_container_fwd.hpp>

#include <graphene/db/object.hpp>
#include <graphene/db/generic_index.hpp>
#include <graphene/chain/types.hpp>

using std::string;

namespace graphene {
    namespace chain {

        class quicksortPartlyIterative_object : public graphene::db::abstract_object<quicksortPartlyIterative_object> {

        public:

            static const uint8_t space_id = implementation_ids;
            static const uint8_t type_id = impl_quicksortPartlyIterative_object_type;

            account_id_type account;
            string Function;
            string Parameters;
        };

        struct by_quicksortPartlyIterative;

        typedef multi_index_container <
        quicksortPartlyIterative_object,
        indexed_by<
                ordered_unique <
                tag < by_id>, member<object, object_id_type, &object::id>>,
        ordered_unique <
        tag<by_quicksortPartlyIterative>, member<quicksortPartlyIterative_object, int, nullptr>>>>
        quicksortPartlyIterative_object_index_type;

    }
}

FC_REFLECT_TYPENAME(graphene::chain::quicksortPartlyIterative_object)
GRAPHENE_DECLARE_EXTERNAL_SERIALIZATION(graphene::chain::quicksortPartlyIterative_object)