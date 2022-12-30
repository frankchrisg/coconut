#pragma once

#include <graphene/protocol/base.hpp>
#include <graphene/chain/key_value_in_object.hpp>

#include <graphene/protocol/asset.hpp>

namespace graphene {
    namespace protocol {

        struct key_value_in_operation : public base_operation {
            struct fee_parameters_type {
                uint64_t fee = 0 * GRAPHENE_BLOCKCHAIN_PRECISION;
            };
            asset fee;
            account_id_type account;
            string Function;
            string Parameters;
            //string Auxiliary_Event;

            void validate() const;

            void get_required_active_authorities(flat_set<account_id_type> &a) const { a.insert(account); }

            account_id_type fee_payer() const { return account; }
        };

    }
}

FC_REFLECT(graphene::protocol::key_value_in_operation::fee_parameters_type, (fee))

FC_REFLECT(graphene::protocol::key_value_in_operation, (fee)(account)(Function)(Parameters));

GRAPHENE_DECLARE_EXTERNAL_SERIALIZATION(graphene::protocol::key_value_in_operation::fee_parameters_type)
GRAPHENE_DECLARE_EXTERNAL_SERIALIZATION(graphene::protocol::key_value_in_operation)
