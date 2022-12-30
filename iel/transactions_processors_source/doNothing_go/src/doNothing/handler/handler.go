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

type DoNothingPayload struct {
	Function string
	Args     []string
}

type DoNothingHandler struct {
	namespace string
}

func NewDoNothingHandler(namespace string) *DoNothingHandler {
	return &DoNothingHandler{
		namespace: namespace,
	}
}

const (
	familyName = "doNothing"
)

func (self *DoNothingHandler) FamilyName() string {
	return familyName
}

func (self *DoNothingHandler) FamilyVersions() []string {
	return []string{"0.1"}
}

func (self *DoNothingHandler) Namespaces() []string {
	return []string{self.namespace}
}

func (self *DoNothingHandler) Apply(request *processor_pb2.TpProcessRequest, context *processor.Context) error {

	var payload, err = self.preparePayload(request)
	if err != nil {
		return err
	}

	var signature = payload.Args[0]

	var data, errCbor = EncodeCBOR(signature)
	if errCbor != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to encode data: ", errCbor),
		}*/
		logger.Errorf("Failed to encode data: ", errCbor)
		return nil
	}

	var attributes = make([]processor.Attribute, 0)
	var errEvent = context.AddEvent("doNothing", attributes, data)
	if errEvent != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to add event: ", errEvent),
		}*/
		logger.Errorf("Failed to add event: ", errEvent)
		return nil
	}
	return nil
}

func (self *DoNothingHandler) preparePayload(request *processor_pb2.TpProcessRequest) (DoNothingPayload, error) {

	var payloadData = request.GetPayload()
	if payloadData == nil {
		return DoNothingPayload{}, &processor.InvalidTransactionError{Msg: "Must contain payload"}
	}
	var payload DoNothingPayload
	var err = DecodeCBOR(payloadData, &payload)
	if err != nil {
		return DoNothingPayload{}, &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to decode payload: ", err),
		}
	}

	return payload, nil
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

func EncodeCBOR(value interface{}) ([]byte, error) {
	data, err := cbor.Dumps(value)
	return data, err
}

func Hexdigest(str string) string {
	hash := sha512.New()
	hash.Write([]byte(str))
	hashBytes := hash.Sum(nil)
	return strings.ToLower(hex.EncodeToString(hashBytes))
}
