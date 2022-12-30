#pragma once

#include <boost/multi_index_container_fwd.hpp>

#include <graphene/db/object.hpp>
#include <graphene/db/generic_index.hpp>
#include <graphene/chain/types.hpp>

using std::string;

namespace graphene {
    namespace chain {

        class smallbank_in_object : public graphene::db::abstract_object<smallbank_in_object> {

        public:

            static const uint8_t space_id = implementation_ids;
            static const uint8_t type_id = impl_smallbank_in_object_type;

            account_id_type account;
            string Function;
            string Parameters;
        };

    }
}

FC_REFLECT_TYPENAME(graphene::chain::smallbank_in_object)
GRAPHENE_DECLARE_EXTERNAL_SERIALIZATION(graphene::chain::smallbank_in_object)