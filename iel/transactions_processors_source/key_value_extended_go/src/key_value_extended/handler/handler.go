package handler

import (
	"crypto/sha512"
	"encoding/hex"
	"fmt"
	cbor "github.com/brianolson/cbor_go"
	"github.com/hyperledger/sawtooth-sdk-go/logging"
	"github.com/hyperledger/sawtooth-sdk-go/processor"
	"protobuf/processor_pb2"
	//"github.com/hyperledger/sawtooth-sdk-go/src/protobuf/processor_pb2"
	"strings"
)

//var logger = logging.Get()
var logger *logging.Logger = logging.Get()

type KeyValueExistingCheckPayload struct {
	Function string
	Args     []string
}

type KeyValueExistingCheckHandler struct {
	namespace string
}

func NewKeyValueExistingCheckHandler(namespace string) *KeyValueExistingCheckHandler {
	return &KeyValueExistingCheckHandler{
		namespace: namespace,
	}
}

const (
	familyName = "keyValueExtended"
)

func (self *KeyValueExistingCheckHandler) FamilyName() string {
	return familyName
}

func (self *KeyValueExistingCheckHandler) FamilyVersions() []string {
	return []string{"0.1"}
}

func (self *KeyValueExistingCheckHandler) Namespaces() []string {
	return []string{self.namespace}
}

func (self *KeyValueExistingCheckHandler) Get(context *processor.Context, args []string) interface{} {

	if len(args) != 2 {
		//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Call to Get must have 2 parameters")}
		logger.Error("Call to Get must have 2 parameters")
		return nil
	}

	var key = args[0]

	var hashedName = Hexdigest(key)
	var keyAddress = self.namespace + hashedName[len(hashedName)-64:]

	var state, errGet = context.GetState([]string{keyAddress})
	if errGet != nil {
		//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Error while GetState call")}
		logger.Error("Error while GetState call")
		return nil
	}

	_, ok := state[keyAddress]
	if !ok {

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
		var errEvent = context.AddEvent("keyValueEx/get/doesntexist", attributes, data)
		if errEvent != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to add event: ", errEvent),
			}*/
			logger.Errorf("Failed to add event: ", errEvent)
			return nil
		}
	} else {
		var decodedData string
		var errDecodeCbor = DecodeCBOR(state[keyAddress], &decodedData)
		if errDecodeCbor != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to encode data: ", errDecodeCbor),
			}*/
			logger.Errorf("Failed to encode data: ", errDecodeCbor)
			return nil
		}
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
		var errEvent = context.AddEvent("keyValueEx/get", attributes, data)
		if errEvent != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to add event: ", errEvent),
			}*/
			logger.Errorf("Failed to add event: ", errEvent)
			return nil
		}
	}
	return nil
}

func (self *KeyValueExistingCheckHandler) Set(context *processor.Context, args []string) interface{} {

	if len(args) != 3 {
		//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Call to Set must have 3 parameters")}
		logger.Error("Call to Set must have 3 parameters")
		return nil
	}

	var key = args[0]
	var value = args[1]

	var hashedName = Hexdigest(key)
	var keyAddress = self.namespace + hashedName[len(hashedName)-64:]

	var checkKey, errGet = context.GetState([]string{keyAddress})
	if errGet != nil {
		//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Error while getting state in Set")}
		logger.Error("Error while getting state in Set")
		return nil
	}

	_, ok := checkKey[keyAddress]
	if ok {

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
		var errEvent = context.AddEvent("keyValueEx/set/exist", attributes, data)
		if errEvent != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to add event: ", errEvent),
			}*/
			logger.Errorf("Failed to add event: ", errEvent)
			return nil
		}
	} else {
		var state = make(map[string][]byte)
		var valueData, errCbor = EncodeCBOR(value)
		if errCbor != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to encode data: ", errCbor),
			}*/
			logger.Errorf("Failed to encode data: ", errCbor)
			return nil
		}
		state[keyAddress] = valueData

		var _, errSet = context.SetState(state)
		if errSet != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Cannot put state"),
			}*/
			logger.Error("Cannot put state")
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
		var errEvent = context.AddEvent("keyValueEx/set", attributes, data)
		if errEvent != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to add event: ", errEvent),
			}*/
			logger.Errorf("Failed to add event: ", errEvent)
			return nil
		}
	}
	return nil
}

func (self *KeyValueExistingCheckHandler) Apply(request *processor_pb2.TpProcessRequest, context *processor.Context) error {

	var payload, err = self.preparePayload(request)
	if err != nil {
		return err
	}

	var function = payload.Function

	var args = payload.Args
	if function == "Get" {
		var err = self.Get(context, args)
		if err != nil {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Function failed %s %s", function, err)}
			logger.Errorf("Function failed %s %s", function, err)
			return nil
		}
		return nil
	}
	if function == "Set" {
		var err = self.Set(context, args)
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

func (self *KeyValueExistingCheckHandler) preparePayload(request *processor_pb2.TpProcessRequest) (KeyValueExistingCheckPayload, error) {

	var payloadData = request.GetPayload()
	if payloadData == nil {
		return KeyValueExistingCheckPayload{}, &processor.InvalidTransactionError{Msg: "Must contain payload"}
	}
	var payload KeyValueExistingCheckPayload
	var err = DecodeCBOR(payloadData, &payload)
	if err != nil {
		return KeyValueExistingCheckPayload{}, &processor.InvalidTransactionError{
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
