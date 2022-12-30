package handler

import (
	"crypto/sha512"
	"encoding/hex"
	"fmt"
	cbor "github.com/brianolson/cbor_go"
	"github.com/hyperledger/sawtooth-sdk-go/logging"
	"github.com/hyperledger/sawtooth-sdk-go/processor"
	"protobuf/processor_pb2"
	"strconv"

	//"github.com/hyperledger/sawtooth-sdk-go/src/protobuf/processor_pb2"
	"strings"
)

//var logger = logging.Get()
var logger *logging.Logger = logging.Get()

type SmallBankPayload struct {
	Function string
	Args     []string
}

type SmallBankHandler struct {
	namespace string
}

func NewSmallBankHandler(namespace string) *SmallBankHandler {
	return &SmallBankHandler{
		namespace: namespace,
	}
}

const (
	familyName = "smallBank"
)

func (self *SmallBankHandler) FamilyName() string {
	return familyName
}

func (self *SmallBankHandler) FamilyVersions() []string {
	return []string{"0.1"}
}

func (self *SmallBankHandler) Namespaces() []string {
	return []string{self.namespace}
}

const checkingSuffix string = "_checking"

const savingsSuffix string = "_savings"

func getSavings(a string) string {
	return a + savingsSuffix
}

func getChecking(a string) string {
	return a + checkingSuffix
}

func (self *SmallBankHandler) WriteCheck(context *processor.Context, args []string) interface{} {

	var acctId = args[0]

	var hashedNameSavings = Hexdigest(getSavings(acctId))
	var acctIdAddressSavings = self.namespace + hashedNameSavings[len(hashedNameSavings)-64:]
	var stateSavings, errGetSavings = context.GetState([]string{acctIdAddressSavings})
	if errGetSavings != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Error getting the state", errGetSavings),
		}*/
		logger.Errorf("Error getting the state", errGetSavings)
		return nil
	}

	var hashedNameChecking = Hexdigest(getChecking(acctId))
	var acctIdAddressChecking = self.namespace + hashedNameChecking[len(hashedNameChecking)-64:]
	var stateChecking, errGetChecking = context.GetState([]string{acctIdAddressChecking})
	if errGetChecking != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Error getting the state", errGetChecking),
		}*/
		logger.Errorf("Error getting the state", errGetChecking)
		return nil
	}

	var amount, errAmountConvert = strconv.Atoi(args[1])
	if errAmountConvert != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed convert amount", errAmountConvert),
		}*/
		logger.Errorf("Failed convert amount", errAmountConvert)
		return nil
	}

	_, okSavings := stateSavings[acctIdAddressSavings]
	_, okChecking := stateChecking[acctIdAddressChecking]
	if !okSavings || !okChecking || amount < 0 {

		var signature = args[2]

		var data, errEncodeCbor = EncodeCBOR(signature)
		if errEncodeCbor != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to encode data: ", errEncodeCbor),
			}*/
			logger.Errorf("Failed to encode data: ", errEncodeCbor)
			return nil
		}
		var attributes = make([]processor.Attribute, 0)
		var errEvent = context.AddEvent("writeCheck/error", attributes, data)
		if errEvent != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to add event: ", errEvent),
			}*/
			logger.Errorf("Failed to add event: ", errEvent)
			return nil
		}
		return nil
	}

	var savings, errSavingConvert = strconv.Atoi(string(stateSavings[acctIdAddressSavings]))
	if errSavingConvert != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed convert saving", errSavingConvert),
		}*/
		logger.Errorf("Failed convert saving", errSavingConvert)
		return nil
	}
	var checks, errCheckConvert = strconv.Atoi(string(stateChecking[acctIdAddressChecking]))
	if errCheckConvert != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed convert check", errCheckConvert),
		}*/
		logger.Errorf("Failed convert check", errCheckConvert)
		return nil
	}
	var total = savings + checks

	if total < amount {
		var check = strconv.Itoa(checks - amount - 1)

		var result = make(map[string][]byte)
		result[acctIdAddressChecking] = []byte(check)
		var _, errSet = context.SetState(result)
		if errSet != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Cannot put state", errSet),
			}*/
			logger.Errorf("Cannot put state", errSet)
			return nil
		}
	} else {
		var check = strconv.Itoa(checks - amount)

		var result = make(map[string][]byte)
		result[acctIdAddressChecking] = []byte(check)
		var _, errSet = context.SetState(result)
		if errSet != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Cannot put state", errSet),
			}*/
			logger.Errorf("Cannot put state", errSet)
			return nil
		}
	}

	var signature = args[2]

	var data, errEncodeCbor = EncodeCBOR(signature)
	if errEncodeCbor != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to encode data: ", errEncodeCbor),
		}*/
		logger.Errorf("Failed to encode data: ", errEncodeCbor)
		return nil
	}
	var attributes = make([]processor.Attribute, 0)
	var errEvent = context.AddEvent("writeCheck", attributes, data)
	if errEvent != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to add event: ", errEvent),
		}*/
		logger.Errorf("Failed to add event: ", errEvent)
		return nil
	}

	return nil
}

func (self *SmallBankHandler) DepositChecking(context *processor.Context, args []string) interface{} {

	var acctId = args[0]

	var hashedNameChecking = Hexdigest(getChecking(acctId))
	var acctIdAddressChecking = self.namespace + hashedNameChecking[len(hashedNameChecking)-64:]
	var stateChecking, errGetChecking = context.GetState([]string{acctIdAddressChecking})
	if errGetChecking != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Error getting the state", errGetChecking),
		}*/
		logger.Errorf("Error getting the state", errGetChecking)
		return nil
	}

	_, ok := stateChecking[acctIdAddressChecking]
	if !ok {

		var signature = args[2]

		var data, errEncodeCbor = EncodeCBOR(signature)
		if errEncodeCbor != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to encode data: ", errEncodeCbor),
			}*/
			logger.Errorf("Failed to encode data: ", errEncodeCbor)
			return nil
		}
		var attributes = make([]processor.Attribute, 0)
		var errEvent = context.AddEvent("depositChecking/error", attributes, data)
		if errEvent != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to add event: ", errEvent),
			}*/
			logger.Errorf("Failed to add event: ", errEvent)
			return nil
		}
		return nil
	}

	var checks, errCheckConvert = strconv.Atoi(string(stateChecking[acctIdAddressChecking]))
	if errCheckConvert != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed convert check", errCheckConvert),
		}*/
		logger.Errorf("Failed convert check", errCheckConvert)
		return nil
	}

	var amount, errAmountConvert = strconv.Atoi(args[1])
	if errAmountConvert != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed convert amount", errCheckConvert),
		}*/
		logger.Errorf("Failed convert amount", errCheckConvert)
		return nil
	}
	checks += amount

	var newAmount = strconv.Itoa(checks)

	var result = make(map[string][]byte)
	result[acctIdAddressChecking] = []byte(newAmount)
	var _, errSet = context.SetState(result)
	if errSet != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Cannot put state", errSet),
		}*/
		logger.Errorf("Cannot put state", errSet)
		return nil
	}

	var signature = args[2]

	var data, errEncodeCbor = EncodeCBOR(signature)
	if errEncodeCbor != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to encode data: ", errEncodeCbor),
		}*/
		logger.Errorf("Failed to encode data: ", errEncodeCbor)
		return nil
	}
	var attributes = make([]processor.Attribute, 0)
	var errEvent = context.AddEvent("depositChecking", attributes, data)
	if errEvent != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to add event: ", errEvent),
		}*/
		logger.Errorf("Failed to add event: ", errEvent)
		return nil
	}

	return nil
}

func (self *SmallBankHandler) TransactSavings(context *processor.Context, args []string) interface{} {

	var acctId = args[0]

	var hashedNameSavings = Hexdigest(getSavings(acctId))
	var acctIdAddressSavings = self.namespace + hashedNameSavings[len(hashedNameSavings)-64:]
	var stateSavings, errGetSavings = context.GetState([]string{acctIdAddressSavings})
	if errGetSavings != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Error getting the state", errGetSavings),
		}*/
		logger.Errorf("Error getting the state", errGetSavings)
		return nil
	}

	_, ok := stateSavings[acctIdAddressSavings]
	if !ok {

		var signature = args[2]

		var data, errEncodeCbor = EncodeCBOR(signature)
		if errEncodeCbor != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to encode data: ", errEncodeCbor),
			}*/
			logger.Errorf("Failed to encode data: ", errEncodeCbor)
			return nil
		}
		var attributes = make([]processor.Attribute, 0)
		var errEvent = context.AddEvent("transactSavings/error", attributes, data)
		if errEvent != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to add event: ", errEvent),
			}*/
			logger.Errorf("Failed to add event: ", errEvent)
			return nil
		}
		return nil
	}

	var savings, errSavingConvert = strconv.Atoi(string(stateSavings[acctIdAddressSavings]))
	if errSavingConvert != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed convert saving", errSavingConvert),
		}*/
		logger.Errorf("Failed convert saving", errSavingConvert)
		return nil
	}

	var amount, errAmountConvert = strconv.Atoi(args[1])
	if errAmountConvert != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed convert amount", errAmountConvert),
		}*/
		logger.Errorf("Failed convert amount", errAmountConvert)
		return nil
	}
	var balance = savings - amount
	if balance < 0 {
		var signature = args[2]

		var data, errEncodeCbor = EncodeCBOR(signature)
		if errEncodeCbor != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to encode data: ", errEncodeCbor),
			}*/
			logger.Errorf("Failed to encode data: ", errEncodeCbor)
			return nil
		}
		var attributes = make([]processor.Attribute, 0)
		var errEvent = context.AddEvent("transactSavings/error/balance", attributes, data)
		if errEvent != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to add event: ", errEvent),
			}*/
			logger.Errorf("Failed to add event: ", errEvent)
			return nil
		}
		return nil
	}

	savings -= amount
	var newAmount = strconv.Itoa(savings)

	var result = make(map[string][]byte)
	result[acctIdAddressSavings] = []byte(newAmount)
	var _, errSet = context.SetState(result)
	if errSet != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Cannot put state", errSet),
		}*/
		logger.Errorf("Cannot put state", errSet)
		return nil
	}

	var signature = args[2]

	var data, errEncodeCbor = EncodeCBOR(signature)
	if errEncodeCbor != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to encode data: ", errEncodeCbor),
		}*/
		logger.Errorf("Failed to encode data: ", errEncodeCbor)
		return nil
	}
	var attributes = make([]processor.Attribute, 0)
	var errEvent = context.AddEvent("transactSavings", attributes, data)
	if errEvent != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to add event: ", errEvent),
		}*/
		logger.Errorf("Failed to add event: ", errEvent)
		return nil
	}

	return nil
}

func (self *SmallBankHandler) SendPayment(context *processor.Context, args []string) interface{} {

	var sender = args[0]
	var destination = args[1]
	var amount, errAmountConvert = strconv.Atoi(args[2])
	if errAmountConvert != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed convert amount", errAmountConvert),
		}*/
		logger.Errorf("Failed convert amount", errAmountConvert)
		return nil
	}

	var hashedNameSavingsSender = Hexdigest(getSavings(sender))
	var acctIdAddressSavingsSender = self.namespace + hashedNameSavingsSender[len(hashedNameSavingsSender)-64:]
	var stateSavingsSender, errGetSavingsSender = context.GetState([]string{acctIdAddressSavingsSender})
	if errGetSavingsSender != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Error getting the state", errGetSavingsSender),
		}*/
		logger.Errorf("Error getting the state", errGetSavingsSender)
		return nil
	}

	var hashedNameCheckingSender = Hexdigest(getChecking(sender))
	var acctIdAddressCheckingSender = self.namespace + hashedNameCheckingSender[len(hashedNameCheckingSender)-64:]
	var stateCheckingSender, errGetCheckingSender = context.GetState([]string{acctIdAddressCheckingSender})
	if errGetCheckingSender != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Error getting the state", errGetCheckingSender),
		}*/
		logger.Errorf("Error getting the state", errGetCheckingSender)
		return nil
	}

	var hashedNameSavingsDestination = Hexdigest(getSavings(destination))
	var acctIdAddressSavingsDestination = self.namespace + hashedNameSavingsDestination[len(hashedNameSavingsDestination)-64:]
	var stateSavingsDestination, errGetSavingsDestination = context.GetState([]string{acctIdAddressSavingsDestination})
	if errGetSavingsDestination != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Error getting the state", errGetSavingsDestination),
		}*/
		logger.Errorf("Error getting the state", errGetSavingsDestination)
		return nil
	}

	var hashedNameCheckingSenderDestination = Hexdigest(getChecking(destination))
	var acctIdAddressCheckingDestination = self.namespace + hashedNameCheckingSenderDestination[len(hashedNameCheckingSenderDestination)-64:]
	var stateCheckingDestination, errGetCheckingDestination = context.GetState([]string{acctIdAddressCheckingDestination})
	if errGetCheckingDestination != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Error getting the state", errGetSavingsDestination),
		}*/
		logger.Errorf("Error getting the state", errGetSavingsDestination)
		return nil
	}

	_, okCheckingSender := stateCheckingSender[acctIdAddressCheckingSender]
	_, okCheckingDestination := stateCheckingDestination[acctIdAddressCheckingDestination]
	_, okSavingsSender := stateSavingsSender[acctIdAddressSavingsSender]
	_, okSavingsDestination := stateSavingsDestination[acctIdAddressSavingsDestination]
	if !okCheckingSender || !okCheckingDestination || !okSavingsSender || !okSavingsDestination {
		var signature = args[3]

		var data, errEncodeCbor = EncodeCBOR(signature)
		if errEncodeCbor != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to encode data: ", errEncodeCbor),
			}*/
			logger.Errorf("Failed to encode data: ", errEncodeCbor)
			return nil
		}
		var attributes = make([]processor.Attribute, 0)
		var errEvent = context.AddEvent("sendPayment/error", attributes, data)
		if errEvent != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to add event: ", errEvent),
			}*/
			logger.Errorf("Failed to add event: ", errEvent)
			return nil
		}
		return nil
	}

	var checkingBalanceSender, errCheckingBalanceSender = strconv.Atoi(string(stateCheckingSender[acctIdAddressCheckingSender]))
	if errCheckingBalanceSender != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed convert amount", errAmountConvert),
		}*/
		logger.Errorf("Failed convert amount", errAmountConvert)
		return nil
	}
	if checkingBalanceSender < amount {
		var signature = args[3]

		var data, errEncodeCbor = EncodeCBOR(signature)
		if errEncodeCbor != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to encode data: ", errEncodeCbor),
			}*/
			logger.Errorf("Failed to encode data: ", errEncodeCbor)
			return nil
		}
		var attributes = make([]processor.Attribute, 0)
		var errEvent = context.AddEvent("sendPayment/error/checkingBalanceSender", attributes, data)
		if errEvent != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to add event: ", errEvent),
			}*/
			logger.Errorf("Failed to add event: ", errEvent)
			return nil
		}
		return nil
	}

	var newAmountSender, errNewAmountSender = strconv.Atoi(string(stateCheckingSender[acctIdAddressCheckingSender]))
	if errNewAmountSender != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed convert amount", errAmountConvert),
		}*/
		logger.Errorf("Failed convert amount", errAmountConvert)
		return nil
	}
	var newAmountDestination, errNewAmountDestination = strconv.Atoi(string(stateCheckingDestination[acctIdAddressCheckingDestination]))
	if errNewAmountDestination != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed convert amount", errAmountConvert),
		}*/
		logger.Errorf("Failed convert amount", errAmountConvert)
		return nil
	}

	newAmountSender -= amount
	newAmountDestination += amount

	var newAmountSenderPut = strconv.Itoa(newAmountSender)
	var newAmountDestinationPut = strconv.Itoa(newAmountDestination)

	var resultSender = make(map[string][]byte)
	resultSender[acctIdAddressCheckingSender] = []byte(newAmountSenderPut)
	var _, errSetSender = context.SetState(resultSender)
	if errSetSender != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Cannot put state", errSetSender),
		}*/
		logger.Errorf("Cannot put state", errSetSender)
		return nil
	}

	var resultDestination = make(map[string][]byte)
	resultDestination[acctIdAddressCheckingDestination] = []byte(newAmountDestinationPut)
	var _, errSet = context.SetState(resultDestination)
	if errSet != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Cannot put state", errSet),
		}*/
		logger.Errorf("Cannot put state", errSet)
		return nil
	}

	var signature = args[3]

	var data, errEncodeCbor = EncodeCBOR(signature)
	if errEncodeCbor != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to encode data: ", errEncodeCbor),
		}*/
		logger.Errorf("Failed to encode data: ", errEncodeCbor)
		return nil
	}
	var attributes = make([]processor.Attribute, 0)
	var errEvent = context.AddEvent("sendPayment", attributes, data)
	if errEvent != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to add event: ", errEvent),
		}*/
		logger.Errorf("Failed to add event: ", errEvent)
		return nil
	}

	return nil
}

func (self *SmallBankHandler) Balance(context *processor.Context, args []string) interface{} {

	var acctId = args[0]

	var hashedNameSavings = Hexdigest(getSavings(acctId))
	var acctIdAddressSavings = self.namespace + hashedNameSavings[len(hashedNameSavings)-64:]
	var stateSavings, errGetSavings = context.GetState([]string{acctIdAddressSavings})
	if errGetSavings != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Error getting the state", errGetSavings),
		}*/
		logger.Errorf("Error getting the state", errGetSavings)
		return nil
	}

	var hashedNameChecking = Hexdigest(getChecking(acctId))
	var acctIdAddressChecking = self.namespace + hashedNameChecking[len(hashedNameChecking)-64:]
	var stateChecking, errGetChecking = context.GetState([]string{acctIdAddressChecking})
	if errGetChecking != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Error getting the state", errGetChecking),
		}*/
		logger.Errorf("Error getting the state", errGetChecking)
		return nil
	}

	_, okSavings := stateSavings[acctIdAddressSavings]
	_, okChecking := stateChecking[acctIdAddressChecking]
	if !okSavings || !okChecking {

		var signature = args[1]

		var data, errEncodeCbor = EncodeCBOR(signature)
		if errEncodeCbor != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to encode data: ", errEncodeCbor),
			}*/
			logger.Errorf("Failed to encode data: ", errEncodeCbor)
			return nil
		}
		var attributes = make([]processor.Attribute, 0)
		var errEvent = context.AddEvent("balance/error", attributes, data)
		if errEvent != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to add event: ", errEvent),
			}*/
			logger.Errorf("Failed to add event: ", errEvent)
			return nil
		}

		return nil
	}

	var savings, errSavingsConvert = strconv.Atoi(string(stateSavings[acctIdAddressSavings]))
	if errSavingsConvert != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed convert savings", errSavingsConvert),
		}*/
		logger.Errorf("Failed convert savings", errSavingsConvert)
		return nil
	}
	var checkings, errCheckingsConvert = strconv.Atoi(string(stateChecking[acctIdAddressChecking]))
	if errCheckingsConvert != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed convert checkings", errCheckingsConvert),
		}*/
		logger.Errorf("Failed convert checkings", errCheckingsConvert)
		return nil
	}

	//var _ = savings + checkings
	var total = savings + checkings

	var signature = args[1] + " __balance_event:" + "-balance-" + strconv.Itoa(total) + "-acctId-" + acctId
	//var signature = args[1]

	var data, errEncodeCbor = EncodeCBOR(signature)
	if errEncodeCbor != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to encode data: ", errEncodeCbor),
		}*/
		logger.Errorf("Failed to encode data: ", errEncodeCbor)
		return nil
	}
	var attributes = make([]processor.Attribute, 0)
	var errEvent = context.AddEvent("balance", attributes, data)
	if errEvent != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to add event: ", errEvent),
		}*/
		logger.Errorf("Failed to add event: ", errEvent)
		return nil
	}
	return nil
}

func (self *SmallBankHandler) Amalgamate(context *processor.Context, args []string) interface{} {

	var acctId0 = args[0]
	var acctId1 = args[1]

	var hashedNameSavingsAcctId0 = Hexdigest(getSavings(acctId0))
	var acctIdAddressSavingsAcctId0 = self.namespace + hashedNameSavingsAcctId0[len(hashedNameSavingsAcctId0)-64:]
	var stateSavingsAcctId0, errGetSavingsAcctId0 = context.GetState([]string{acctIdAddressSavingsAcctId0})
	if errGetSavingsAcctId0 != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Error getting the state", errGetSavingsAcctId0),
		}*/
		logger.Errorf("Error getting the state", errGetSavingsAcctId0)
		return nil
	}

	var hashedNameCheckingAcctId0 = Hexdigest(getChecking(acctId0))
	var acctIdAddressCheckingAcctId0 = self.namespace + hashedNameCheckingAcctId0[len(hashedNameCheckingAcctId0)-64:]
	var stateCheckingAcctId0, errGetCheckingAcctId0 = context.GetState([]string{acctIdAddressCheckingAcctId0})
	if errGetCheckingAcctId0 != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Error getting the state", errGetCheckingAcctId0),
		}*/
		logger.Errorf("Error getting the state", errGetCheckingAcctId0)
		return nil
	}

	var hashedNameSavingsAcctId1 = Hexdigest(getSavings(acctId1))
	var acctIdAddressSavingsAcctId1 = self.namespace + hashedNameSavingsAcctId1[len(hashedNameSavingsAcctId1)-64:]
	var stateSavingsAcctId1, errGetSavingsAcctId1 = context.GetState([]string{acctIdAddressSavingsAcctId1})
	if errGetSavingsAcctId1 != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Error getting the state", errGetSavingsAcctId1),
		}*/
		logger.Errorf("Error getting the state", errGetSavingsAcctId1)
		return nil
	}

	var hashedNameCheckingAcctId1 = Hexdigest(getChecking(acctId1))
	var acctIdAddressCheckingAcctId1 = self.namespace + hashedNameCheckingAcctId1[len(hashedNameCheckingAcctId1)-64:]
	var stateCheckingAcctId1, errGetCheckingAcctId1 = context.GetState([]string{acctIdAddressCheckingAcctId1})
	if errGetCheckingAcctId1 != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Error getting the state", errGetSavingsAcctId1),
		}*/
		logger.Errorf("Error getting the state", errGetSavingsAcctId1)
		return nil
	}

	var signature = args[2]

	_, okCheckingAcctId0 := stateCheckingAcctId0[acctIdAddressCheckingAcctId0]
	_, okCheckingAcctId1 := stateCheckingAcctId1[acctIdAddressCheckingAcctId1]
	_, okSavingsAcctId0 := stateSavingsAcctId0[acctIdAddressSavingsAcctId0]
	_, okSavingsAcctId1 := stateSavingsAcctId1[acctIdAddressSavingsAcctId1]
	if !okCheckingAcctId0 || !okCheckingAcctId1 || !okSavingsAcctId0 || !okSavingsAcctId1 {

		var data, errEncodeCbor = EncodeCBOR(signature)
		if errEncodeCbor != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to encode data: ", errEncodeCbor),
			}*/
			logger.Errorf("Failed to encode data: ", errEncodeCbor)
			return nil
		}
		var attributes = make([]processor.Attribute, 0)
		var errEvent = context.AddEvent("amalgamate/error", attributes, data)
		if errEvent != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to add event: ", errEvent),
			}*/
			logger.Errorf("Failed to add event: ", errEvent)
			return nil
		}
		return nil
	}

	var savings, errSavingsConvert = strconv.Atoi(string(stateSavingsAcctId0[acctIdAddressSavingsAcctId0]))
	if errSavingsConvert != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed convert savings", errSavingsConvert),
		}*/
		logger.Errorf("Failed convert savings", errSavingsConvert)
		return nil
	}
	var checkings, errCheckingsConvert = strconv.Atoi(string(stateCheckingAcctId0[acctIdAddressCheckingAcctId0]))
	if errCheckingsConvert != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed convert checkings", errCheckingsConvert),
		}*/
		logger.Errorf("Failed convert checkings", errCheckingsConvert)
		return nil
	}

	var total = savings + checkings
	//assert(total >= 0)

	var zero = "0"
	var resultAcct0Checking = make(map[string][]byte)
	resultAcct0Checking[acctIdAddressCheckingAcctId0] = []byte(zero)
	var _, errSetAcct0Checking = context.SetState(resultAcct0Checking)
	if errSetAcct0Checking != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Cannot put state", errSetAcct0Checking),
		}*/
		logger.Errorf("Cannot put state", errSetAcct0Checking)
		return nil
	}
	var resultAcct0Savings = make(map[string][]byte)
	resultAcct0Savings[acctIdAddressSavingsAcctId0] = []byte(zero)
	var _, errSetAcct0Savings = context.SetState(resultAcct0Savings)
	if errSetAcct0Savings != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Cannot put state", errSetAcct0Savings),
		}*/
		logger.Errorf("Cannot put state", errSetAcct0Savings)
		return nil
	}

	var checkingsAcct1, errCheckingsConvertAcct1 = strconv.Atoi(string(stateCheckingAcctId1[acctIdAddressCheckingAcctId1]))
	if errCheckingsConvertAcct1 != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed convert checkings", errCheckingsConvertAcct1),
		}*/
		logger.Errorf("Failed convert checkings", errCheckingsConvertAcct1)
		return nil
	}

	checkingsAcct1 += total
	var checkingsNew = strconv.Itoa(checkingsAcct1)

	var resultAcct1 = make(map[string][]byte)
	resultAcct1[acctIdAddressCheckingAcctId1] = []byte(checkingsNew)
	var _, errSetAcct1 = context.SetState(resultAcct1)
	if errSetAcct1 != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Cannot put state", errSetAcct1),
		}*/
		logger.Errorf("Cannot put state", errSetAcct1)
		return nil
	}

	var data, errEncodeCbor = EncodeCBOR(signature)
	if errEncodeCbor != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to encode data: ", errEncodeCbor),
		}*/
		logger.Errorf("Failed to encode data: ", errEncodeCbor)
		return nil
	}
	var attributes = make([]processor.Attribute, 0)
	var errEvent = context.AddEvent("amalgamate", attributes, data)
	if errEvent != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to add event: ", errEvent),
		}*/
		logger.Errorf("Failed to add event: ", errEvent)
		return nil
	}

	return nil
}

func (self *SmallBankHandler) CreateAccount(context *processor.Context, args []string) interface{} {
	var acctIdChecking = args[0]
	var acctIdSavings = args[1]
	var checking = args[2]
	var savings = args[3]

	var hashedNameCheckingAcctIdSavings = Hexdigest(getSavings(acctIdSavings))
	var acctIdAddressCheckingAcct = self.namespace + hashedNameCheckingAcctIdSavings[len(hashedNameCheckingAcctIdSavings)-64:]

	var hashedNameSavingsAcctIdChecking = Hexdigest(getChecking(acctIdChecking))
	var acctIdAddressSavingsAcct = self.namespace + hashedNameSavingsAcctIdChecking[len(hashedNameSavingsAcctIdChecking)-64:]

	var resultChecking = make(map[string][]byte)
	resultChecking[acctIdAddressCheckingAcct] = []byte(checking)
	var _, errSetAcctChecking = context.SetState(resultChecking)
	if errSetAcctChecking != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Cannot put state", errSetAcctChecking),
		}*/
		logger.Errorf("Cannot put state", errSetAcctChecking)
		return nil
	}

	var resultSavings = make(map[string][]byte)
	resultSavings[acctIdAddressSavingsAcct] = []byte(savings)
	var _, errSetAcctSavings = context.SetState(resultSavings)
	if errSetAcctSavings != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Cannot put state", errSetAcctChecking),
		}*/
		logger.Errorf("Cannot put state", errSetAcctChecking)
		return nil
	}

	var signature = args[4]

	var data, errEncodeCbor = EncodeCBOR(signature)
	if errEncodeCbor != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to encode data: ", errEncodeCbor),
		}*/
		logger.Errorf("Failed to encode data: ", errEncodeCbor)
		return nil
	}
	var attributes = make([]processor.Attribute, 0)
	var errEvent = context.AddEvent("createAccount", attributes, data)
	if errEvent != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to add event: ", errEvent),
		}*/
		logger.Errorf("Failed to add event: ", errEvent)
		return nil
	}
	return nil
}

func (self *SmallBankHandler) Apply(request *processor_pb2.TpProcessRequest, context *processor.Context) error {

	var payload, err = self.preparePayload(request)
	if err != nil {
		return err
	}

	var function = payload.Function

	var args = payload.Args
	if function == "WriteCheck" {
		var err = self.WriteCheck(context, args)
		if err != nil {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Function failed %s %s", function, err)}
			logger.Errorf("Function failed %s %s", function, err)
			return nil
		}
		return nil
	}
	if function == "DepositChecking" {
		var err = self.DepositChecking(context, args)
		if err != nil {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Function failed %s %s", function, err)}
			logger.Errorf("Function failed %s %s", function, err)
			return nil
		}
		return nil
	}
	if function == "TransactSavings" {
		var err = self.TransactSavings(context, args)
		if err != nil {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Function failed %s %s", function, err)}
			logger.Errorf("Function failed %s %s", function, err)
			return nil
		}
		return nil
	}
	if function == "SendPayment" {
		var err = self.SendPayment(context, args)
		if err != nil {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Function failed %s %s", function, err)}
			logger.Errorf("Function failed %s %s", function, err)
			return nil
		}
		return nil
	}
	if function == "Balance" {
		var err = self.Balance(context, args)
		if err != nil {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Function failed %s %s", function, err)}
			logger.Errorf("Function failed %s %s", function, err)
			return nil
		}
		return nil
	}
	if function == "Amalgamate" {
		var err = self.Amalgamate(context, args)
		if err != nil {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Function failed %s %s", function, err)}
			logger.Errorf("Function failed %s %s", function, err)
			return nil
		}
		return nil
	}
	if function == "CreateAccount" {
		var err = self.CreateAccount(context, args)
		if err != nil {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Function failed %s %s", function, err)}
			logger.Errorf("Function failed %s %s", function, err)
			return nil
		}
		return nil
	}
	//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Invalid function: %v", function)}
	logger.Errorf("Invalid function: %v", function)
	return nil
}

func (self *SmallBankHandler) preparePayload(request *processor_pb2.TpProcessRequest) (SmallBankPayload, error) {

	var payloadData = request.GetPayload()
	if payloadData == nil {
		return SmallBankPayload{}, &processor.InvalidTransactionError{Msg: "Must contain payload"}
	}
	var payload SmallBankPayload
	var err = DecodeCBOR(payloadData, &payload)
	if err != nil {
		return SmallBankPayload{}, &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to decode payload: ", err),
		}
	}

	return payload, nil
}

func EncodeCBOR(value interface{}) ([]byte, error) {
	data, err := cbor.Dumps(value)
	return data, err
}

func DecodeCBOR(data []byte, pointer interface{}) error {
	defer func() error {
		if recover() != nil {
			//return &processor.InvalidTransactionError{Msg: "Failed to decode payload"}
			logger.Error("Failed to decode payload")
			return nil
		}
		return nil
	}()
	var err = cbor.Loads(data, pointer)
	if err != nil {
		return err
	}
	return nil
}

func Hexdigest(str string) string {
	hash := sha512.New()
	hash.Write([]byte(str))
	hashBytes := hash.Sum(nil)
	return strings.ToLower(hex.EncodeToString(hashBytes))
}
