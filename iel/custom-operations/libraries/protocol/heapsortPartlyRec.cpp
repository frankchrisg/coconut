#include <graphene/protocol/heapsortPartlyRec.hpp>
#include <graphene/protocol/fee_schedule.hpp>

#include <fc/io/raw.hpp>

namespace graphene {
    namespace protocol {

        void heapsortPartlyRec_operation::validate() const {
//NOP
        }

    }
}

GRAPHENE_IMPLEMENT_EXTERNAL_SERIALIZATION(graphene::protocol::heapsortPartlyRec_operation::fee_parameters_type)
GRAPHENE_IMPLEMENT_EXTERNAL_SERIALIZATION(graphene::protocol::heapsortPartlyRec_operation)

