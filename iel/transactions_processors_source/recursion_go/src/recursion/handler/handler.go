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
	"strings"
)

//var logger = logging.Get()
var logger *logging.Logger = logging.Get()

type RecursionPayload struct {
	Function string
	Args     []string
}

type RecursionHandler struct {
	namespace string
}

func NewRecursionHandler(namespace string) *RecursionHandler {
	return &RecursionHandler{
		namespace: namespace,
	}
}

const (
	familyName = "recursion"
)

func (self *RecursionHandler) FamilyName() string {
	return familyName
}

func (self *RecursionHandler) FamilyVersions() []string {
	return []string{"0.1"}
}

func (self *RecursionHandler) Namespaces() []string {
	return []string{self.namespace}
}

func (self *RecursionHandler) Recursion(context *processor.Context, start int, end int) interface{} {
	if start != end {
		self.Recursion(context, start, end-1)
	}
	return nil
}

func (self *RecursionHandler) Apply(request *processor_pb2.TpProcessRequest, context *processor.Context) error {

	var payload, err = self.preparePayload(request)
	if err != nil {
		return err
	}

	var function = payload.Function

	var args = payload.Args
	if function == "Recursion" {

		if len(args) != 3 {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Call to Recursion must have 3 parameters")}
			logger.Error("Call to Recursion must have 3 parameters")
			return nil
		}

		var start, errStart = strconv.Atoi(args[0])
		if errStart != nil {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Error while setting start")}
			logger.Error("Error while setting start")
			return nil
		}
		var end, errEnd = strconv.Atoi(args[1])
		if errEnd != nil {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Error while setting end")}
			logger.Error("Error while setting end")
			return nil
		}

		var signature = args[2]

		var err = self.Recursion(context, start, end)
		if err != nil {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Function failed %s %s", function, err)}
			logger.Errorf("Function failed %s %s", function, err)
			return nil
		}

		var data, errCbor = EncodeCBOR(signature)
		if errCbor != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to encode data: ", errCbor),
			}*/
			logger.Errorf("Failed to encode data: ", errCbor)
			return nil
		}
		var attributes = make([]processor.Attribute, 0)
		var errEvent = context.AddEvent("recursion", attributes, data)
		if errEvent != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to add event: ", errEvent),
			}*/
			logger.Errorf("Failed to add event: ", errEvent)
			return nil
		}

		return nil
	} else {
		//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Invalid function: %v", function)}
		logger.Errorf("Invalid function: %v", function)
		return nil
	}
}

func (self *RecursionHandler) preparePayload(request *processor_pb2.TpProcessRequest) (RecursionPayload, error) {

	var payloadData = request.GetPayload()
	if payloadData == nil {
		return RecursionPayload{}, &processor.InvalidTransactionError{Msg: "Must contain payload"}
	}
	var payload RecursionPayload
	var err = DecodeCBOR(payloadData, &payload)
	if err != nil {
		return RecursionPayload{}, &processor.InvalidTransactionError{
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
