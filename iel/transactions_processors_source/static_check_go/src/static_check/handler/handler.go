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

type StaticCheckPayload struct {
	Function string
	Args     []string
}

type StaticCheckHandler struct {
	namespace string
}

func NewStaticCheckHandler(namespace string) *StaticCheckHandler {
	return &StaticCheckHandler{
		namespace: namespace,
	}
}

const (
	familyName = "staticCheck"
)

func (self *StaticCheckHandler) FamilyName() string {
	return familyName
}

func (self *StaticCheckHandler) FamilyVersions() []string {
	return []string{"0.1"}
}

func (self *StaticCheckHandler) Namespaces() []string {
	return []string{self.namespace}
}

var checkVar = true

func (self *StaticCheckHandler) CheckVarSet(val string) interface{} {
	var checkExistingVar, errParse = strconv.ParseBool(val)
	checkVar = checkExistingVar
	if errParse != nil {
		//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Could not parse boolean")}
		logger.Error("Could not parse boolean")
		return nil
	}
	logger.Infof("New checkVar: ")
	logger.Infof(strconv.FormatBool(checkVar))
	return nil
}

func (self *StaticCheckHandler) CheckVarGet() interface{} {
	logger.Infof("checkVar: ")
	logger.Infof(strconv.FormatBool(checkVar))
	return nil
}

func (self *StaticCheckHandler) Apply(request *processor_pb2.TpProcessRequest, context *processor.Context) error {

	var payload, err = self.preparePayload(request)
	if err != nil {
		return err
	}

	var function = payload.Function

	var args = payload.Args
	if function == "CheckVarSet" {
		var err = self.CheckVarSet(args[0])
		if err != nil {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Function failed %s %s", function, err)}
			logger.Errorf("Function failed %s %s", function, err)
			return nil
		}
		return nil
	}
	if function == "CheckVarGet" {
		var err = self.CheckVarGet()
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

func (self *StaticCheckHandler) preparePayload(request *processor_pb2.TpProcessRequest) (StaticCheckPayload, error) {

	var payloadData = request.GetPayload()
	if payloadData == nil {
		return StaticCheckPayload{}, &processor.InvalidTransactionError{Msg: "Must contain payload"}
	}
	var payload StaticCheckPayload
	var err = DecodeCBOR(payloadData, &payload)
	if err != nil {
		return StaticCheckPayload{}, &processor.InvalidTransactionError{
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

func Hexdigest(str string) string {
	hash := sha512.New()
	hash.Write([]byte(str))
	hashBytes := hash.Sum(nil)
	return strings.ToLower(hex.EncodeToString(hashBytes))
}
