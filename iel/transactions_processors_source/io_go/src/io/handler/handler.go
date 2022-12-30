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
	"strconv"
	"strings"
)

const chars string = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"

//var logger = logging.Get()
var logger *logging.Logger = logging.Get()

type IOPayload struct {
	Function string
	Args     []string
}

type IOHandler struct {
	namespace string
}

func NewIOHandler(namespace string) *IOHandler {
	return &IOHandler{
		namespace: namespace,
	}
}

const (
	familyName = "io"
)

func (self *IOHandler) FamilyName() string {
	return familyName
}

func (self *IOHandler) FamilyVersions() []string {
	return []string{"0.1"}
}

func (self *IOHandler) Namespaces() []string {
	return []string{self.namespace}
}

func (self *IOHandler) Write(context *processor.Context, args []string) interface{} {

	if len(args) != 4 {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Call to Write must have 4 parameters"),
		}*/
		logger.Error("Call to Write must have 4 parameters")
		return nil
	}

	var size, errSize = strconv.Atoi(args[0])
	if errSize != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed convert size"),
		}*/
		logger.Error("Failed convert size")
		return nil
	}

	var startKey, errKey = strconv.Atoi(args[1])
	if errKey != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed convert key"),
		}*/
		logger.Error("Failed convert key")
		return nil
	}
	var retLen, errLen = strconv.Atoi(args[2])
	if errLen != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed convert length"),
		}*/
		logger.Error("Failed convert length")
		return nil
	}

	var stateArr []byte
	for i := 0; i < size; i++ {
		var sK = strconv.Itoa(startKey + i)

		var hashedName = Hexdigest(sK)
		var sKAddress = self.namespace + hashedName[len(hashedName)-64:]

		var val = getVal(startKey+i, retLen)

		var state = make(map[string][]byte)
		var data, errCbor = EncodeCBOR(val)
		if errCbor != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to encode data: ", errCbor),
			}*/
			logger.Errorf("Failed to encode data: ", errCbor)
			return nil
		}
		state[sKAddress] = data

		var _, errSet = context.SetState(state)
		if errSet != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprintf("Cannot put state %s", errSet),
			}*/
			logger.Errorf("Cannot put state %s", errSet)
			return nil
		}
		stateArr = append(stateArr, val...)
	}

	var signature = args[3]

	var data, errCbor = EncodeCBOR(signature)
	if errCbor != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to encode data: ", errCbor),
		}*/
		logger.Errorf("Failed to encode data: ", errCbor)
		return nil
	}
	var attributes = make([]processor.Attribute, 0)
	var errEvent = context.AddEvent("storage/write", attributes, data)
	if errEvent != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to add event: ", errEvent),
		}*/
		logger.Errorf("Failed to add event: ", errEvent)
		return nil
	}
	return nil
}

func getVal(k int, retLen int) []byte {
	var ret = make([]byte, retLen)
	for i := 0; i < retLen; i++ {
		ret[i] = chars[(k+i)%len(chars)]
	}
	return ret
}

func (self *IOHandler) Scan(context *processor.Context, args []string) interface{} {

	if len(args) != 3 {
		//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Call to Scan must have 3 parameters")}
		logger.Error("Call to Scan must have 3 parameters")
		return nil
	}

	var size, errSize = strconv.Atoi(args[0])
	if errSize != nil {
		//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Failed convert size: ")}
		logger.Error("Failed convert size: ")
		return nil
	}
	var startKey, errSk = strconv.Atoi(args[1])
	if errSk != nil {
		//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Failed to convert startKey: ")}
		logger.Error("Failed to convert startKey: ")
		return nil
	}
	var stateArr []byte
	for i := 0; i < size; i++ {
		var sK = strconv.Itoa(startKey + i)

		var hashedName = Hexdigest(sK)
		var sKAddress = self.namespace + hashedName[len(hashedName)-64:]

		var state, errGet = context.GetState([]string{sKAddress})
		if errGet != nil {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Error getting the state")}
			logger.Error("Error getting the state")
			return nil
		}

		var decodedData string
		var errCbor = DecodeCBOR(state[sKAddress], &decodedData)
		if errCbor != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to encode data: ", errCbor),
			}*/
			logger.Errorf("Failed to encode data: ", errCbor)
			return nil
		}
		stateArr = append(stateArr, decodedData...)
	}
	var signature = args[2]

	var data, errCbor = EncodeCBOR(signature)
	if errCbor != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to encode data: ", errCbor),
		}*/
		logger.Errorf("Failed to encode data: ", errCbor)
		return nil
	}
	var attributes = make([]processor.Attribute, 0)
	var errEvent = context.AddEvent("storage/scan", attributes, data)
	if errEvent != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to add event: ", errEvent),
		}*/
		logger.Errorf("Failed to add event: ", errEvent)
		return nil
	}
	return nil
}

func (self *IOHandler) RevertScan(context *processor.Context, args []string) interface{} {

	if len(args) != 3 {
		//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Call to RevertScan must have 3 parameters")}
		logger.Error("Call to RevertScan must have 3 parameters")
		return nil
	}

	var size, errSize = strconv.Atoi(args[0])
	if errSize != nil {
		//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Failed convert size: ")}
		logger.Error("Failed convert size: ")
		return nil
	}
	var startKey, errSk = strconv.Atoi(args[1])
	if errSk != nil {
		//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Failed to convert startKey: ")}
		logger.Error("Failed to convert startKey: ")
		return nil
	}
	var stateArr []byte
	for i := 0; i < size; i++ {
		var sK = strconv.Itoa(startKey + size - i - 1)

		var hashedName = Hexdigest(sK)
		var sKAddress = self.namespace + hashedName[len(hashedName)-64:]

		var state, errGet = context.GetState([]string{sKAddress})
		if errGet != nil {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Error getting the state")}
			logger.Error("Error getting the state")
			return nil
		}

		var decodedData string
		var errCbor = DecodeCBOR(state[sKAddress], &decodedData)
		if errCbor != nil {
			/*return &processor.InvalidTransactionError{
				Msg: fmt.Sprint("Failed to encode data: ", errCbor),
			}*/
			logger.Errorf("Failed to encode data: ", errCbor)
			return nil
		}
		stateArr = append(stateArr, decodedData...)
	}
	var signature = args[2]

	var data, errCbor = EncodeCBOR(signature)
	if errCbor != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to encode data: ", errCbor),
		}*/
		logger.Errorf("Failed to encode data: ", errCbor)
		return nil
	}
	var attributes = make([]processor.Attribute, 0)
	var errEvent = context.AddEvent("storage/revertScan", attributes, data)
	if errEvent != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to add event: ", errEvent),
		}*/
		logger.Errorf("Failed to add event: ", errEvent)
		return nil
	}
	return nil
}

func (self *IOHandler) Apply(request *processor_pb2.TpProcessRequest, context *processor.Context) error {

	var payload, err = self.preparePayload(request)
	if err != nil {
		return err
	}

	var function = payload.Function

	var args = payload.Args
	if function == "Write" {
		var err = self.Write(context, args)
		if err != nil {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Function failed %s %s", function, err)}
			logger.Errorf("Function failed %s %s", function, err)
			return nil
		}
		return nil
	}
	if function == "Scan" {
		var err = self.Scan(context, args)
		if err != nil {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Function failed %s %s", function, err)}
			logger.Errorf("Function failed %s %s", function, err)
			return nil
		}
		return nil
	}
	if function == "RevertScan" {
		var err = self.RevertScan(context, args)
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

func (self *IOHandler) preparePayload(request *processor_pb2.TpProcessRequest) (IOPayload, error) {

	var payloadData = request.GetPayload()
	if payloadData == nil {
		return IOPayload{}, &processor.InvalidTransactionError{Msg: "Must contain payload"}
	}
	var payload IOPayload
	var err = DecodeCBOR(payloadData, &payload)
	if err != nil {
		return IOPayload{}, &processor.InvalidTransactionError{
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
