#pragma once

#include <boost/multi_index_container_fwd.hpp>

#include <graphene/db/object.hpp>
#include <graphene/db/generic_index.hpp>
#include <graphene/chain/types.hpp>

using std::string;

namespace graphene {
    namespace chain {

        class donothing_object : public graphene::db::abstract_object<donothing_object> {

        public:

            static const uint8_t space_id = implementation_ids;
            static const uint8_t type_id = impl_donothing_object_type;

            account_id_type account;
            string Function;
            string Parameters;
        };

        struct by_donothing;
    }
}

FC_REFLECT_TYPENAME(graphene::chain::donothing_object)
GRAPHENE_DECLARE_EXTERNAL_SERIALIZATION(graphene::chain::donothing_object)
