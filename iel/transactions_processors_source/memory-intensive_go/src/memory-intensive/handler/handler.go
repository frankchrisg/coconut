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

const field string = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"

//var logger = logging.Get()
var logger *logging.Logger = logging.Get()

type MemoryPayload struct {
	Function string
	Args     []string
}

type MemoryHandler struct {
	namespace string
}

func NewMemoryHandler(namespace string) *MemoryHandler {
	return &MemoryHandler{
		namespace: namespace,
	}
}

const (
	familyName = "memory"
)

func (self *MemoryHandler) FamilyName() string {
	return familyName
}

func (self *MemoryHandler) FamilyVersions() []string {
	return []string{"0.1"}
}

func (self *MemoryHandler) Namespaces() []string {
	return []string{self.namespace}
}

func (self *MemoryHandler) Memory(context *processor.Context, lenOut int, lenIn int, firstChar int, length int, sig string) interface{} {

	var arr = make([][]string, lenOut)
	for i := range arr {
		arr[i] = make([]string, lenIn)
	}

	for i := 0; i < lenOut; i++ {
		for j := 0; j < lenIn; j++ {
			arr[i][j] = getChars(firstChar+i+j, length+i+j)
		}
	}

	var data, errCbor = EncodeCBOR(sig)
	if errCbor != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to encode data: ", errCbor),
		}*/
		logger.Errorf("Failed to encode data: ", errCbor)
		return nil
	}
	var attributes = make([]processor.Attribute, 0)
	var errEvent = context.AddEvent("memory", attributes, data)
	if errEvent != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to add event: ", errEvent),
		}*/
		logger.Errorf("Failed to add event: ", errEvent)
		return nil
	}
	return nil
}

func (self *MemoryHandler) Apply(request *processor_pb2.TpProcessRequest, context *processor.Context) error {

	var payload, err = self.preparePayload(request)
	if err != nil {
		return err
	}

	var function = payload.Function

	var args = payload.Args
	if function == "Memory" {

		if len(args) != 5 {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Call to Memory must have 5 parameters")}
			logger.Error("Call to Memory must have 5 parameters")
			return nil
		}

		var lenOut, errOut = strconv.Atoi(args[0])
		if errOut != nil {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Error while setting lenOut")}
			logger.Error("Error while setting lenOut")
			return nil
		}
		var lenIn, errIn = strconv.Atoi(args[1])
		if errIn != nil {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Error while setting lenIn")}
			logger.Error("Error while setting lenIn")
			return nil
		}
		var firstChar, errFirst = strconv.Atoi(args[2])
		if errFirst != nil {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Error while setting firstChar")}
			logger.Error("Error while setting firstChar")
			return nil
		}
		var length, errLength = strconv.Atoi(args[3])
		if errLength != nil {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Error while setting length")}
			logger.Error("Error while setting length")
			return nil
		}

		var signature = args[4]

		var err = self.Memory(context, lenOut, lenIn, firstChar, length, signature)
		if err != nil {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Function failed %s %s", function, err)}
			logger.Errorf("Function failed %s %s", function, err)
			return nil
		}
		return nil
	} else {
		//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Invalid function: %v", function)}
		logger.Errorf("Invalid function: %v", function)
		return nil
	}
}

func (self *MemoryHandler) preparePayload(request *processor_pb2.TpProcessRequest) (MemoryPayload, error) {

	var payloadData = request.GetPayload()
	if payloadData == nil {
		return MemoryPayload{}, &processor.InvalidTransactionError{Msg: "Must contain payload"}
	}
	var payload MemoryPayload
	var err = DecodeCBOR(payloadData, &payload)
	if err != nil {
		return MemoryPayload{}, &processor.InvalidTransactionError{
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

func getChars(firstChar int, length int) string {

	var stateArr []byte
	for i := firstChar; i < length+firstChar; i++ {
		stateArr = append(stateArr, field[(firstChar+i)%len(field)])
	}
	return string(stateArr)
}

func Hexdigest(str string) string {
	hash := sha512.New()
	hash.Write([]byte(str))
	hashBytes := hash.Sum(nil)
	return strings.ToLower(hex.EncodeToString(hashBytes))
}
