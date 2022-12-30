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

//var logger = logging.Get()
var logger *logging.Logger = logging.Get()

type MergeSortPayload struct {
	Function string
	Args     []string
}

type MergeSortHandler struct {
	namespace string
}

func NewMergeSortHandler(namespace string) *MergeSortHandler {
	return &MergeSortHandler{
		namespace: namespace,
	}
}

const (
	familyName = "mergeSortBreadthFirst"
)

func (self *MergeSortHandler) FamilyName() string {
	return familyName
}

func (self *MergeSortHandler) FamilyVersions() []string {
	return []string{"0.1"}
}

func (self *MergeSortHandler) Namespaces() []string {
	return []string{self.namespace}
}

// even only **2
func (self *MergeSortHandler) MergeSort(context *processor.Context, A []int, l int, r int, sig string) interface{} {

	for m := 1; m <= r-l; m = m + m {
		for i := l; i <= r; i = i + m*2 {
			merge(A, i, i+m-1, i+2*m-1)
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
	var errEvent = context.AddEvent("sort/mergeSortBreadthFirst", attributes, data)
	if errEvent != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to add event: ", errEvent),
		}*/
		logger.Errorf("Failed to add event: ", errEvent)
		return nil
	}
	return nil
}

func (self *MergeSortHandler) Apply(request *processor_pb2.TpProcessRequest, context *processor.Context) error {

	var payload, err = self.preparePayload(request)
	if err != nil {
		return err
	}

	var function = payload.Function

	var args = payload.Args
	if function == "Sort" {

		if len(args) < 4 {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Call to Sort must have at least 4 parameters")}
			logger.Error("Call to Sort must have at least 4 parameters")
			return nil
		}

		var A = make([]int, len(args)-3)
		for i := range A {
			A[i], _ = strconv.Atoi(args[i])
		}

		var l, errL = strconv.Atoi(args[len(A)])
		if errL != nil {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Error while setting L in Sort")}
			logger.Error("Error while setting L in Sort")
			return nil
		}
		var r, errR = strconv.Atoi(args[len(A)+1])
		if errR != nil {
			//return &processor.InvalidTransactionError{Msg: fmt.Sprintf("Error while setting R in Sort")}
			logger.Error("Error while setting R in Sort")
			return nil
		}

		var signature = args[len(A)+2]

		var err = self.MergeSort(context, A, l, r, signature)
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

func (self *MergeSortHandler) preparePayload(request *processor_pb2.TpProcessRequest) (MergeSortPayload, error) {

	var payloadData = request.GetPayload()
	if payloadData == nil {
		return MergeSortPayload{}, &processor.InvalidTransactionError{Msg: "Must contain payload"}
	}
	var payload MergeSortPayload
	var err = DecodeCBOR(payloadData, &payload)
	if err != nil {
		return MergeSortPayload{}, &processor.InvalidTransactionError{
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

func merge(A []int, l int, q int, r int) {
	var B = make([]int, len(A))
	for i := l; i <= q; i++ {
		B[i] = A[i]
	}
	for j := q + 1; j <= r; j++ {
		B[(r + q + 1 - j)] = A[j]
	}
	var s = l
	var t = r
	for k := l; k <= r; k++ {
		if B[s] <= B[t] {
			A[k] = B[s]
			s++
		} else {
			A[k] = B[t]
			t--
		}
	}
}

func exchange(A []int, q int, i int) {
	var tmp = A[q]
	A[q] = A[i]
	A[i] = tmp
}

func Hexdigest(str string) string {
	hash := sha512.New()
	hash.Write([]byte(str))
	hashBytes := hash.Sum(nil)
	return strings.ToLower(hex.EncodeToString(hashBytes))
}
