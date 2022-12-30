#pragma once

#include <boost/multi_index_container_fwd.hpp>

#include <graphene/db/object.hpp>
#include <graphene/db/generic_index.hpp>
#include <graphene/chain/types.hpp>

using std::string;

namespace graphene {
    namespace chain {

        class heapsort_object : public graphene::db::abstract_object<heapsort_object> {

        public:

            static const uint8_t space_id = implementation_ids;
            static const uint8_t type_id = impl_heapsort_object_type;

            account_id_type account;
            string Function;
            string Parameters;
        };

        struct by_heapsort;

        typedef multi_index_container <
        heapsort_object,
        indexed_by<
                ordered_unique <
                tag < by_id>, member<object, object_id_type, &object::id>>,
        ordered_unique <
        tag<by_heapsort>, member<heapsort_object, int, nullptr>>>>
        heapsort_object_index_type;

    }
}

FC_REFLECT_TYPENAME(graphene::chain::heapsort_object)
GRAPHENE_DECLARE_EXTERNAL_SERIALIZATION(graphene::chain::heapsort_object)
