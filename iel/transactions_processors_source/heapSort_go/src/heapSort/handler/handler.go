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

type HeapSortPayload struct {
	Function string
	Args     []string
}

const k int = 2 // 2, 3

type HeapSortHandler struct {
	namespace string
}

func NewHeapSortHandler(namespace string) *HeapSortHandler {
	return &HeapSortHandler{
		namespace: namespace,
	}
}

const (
	familyName = "heapSort"
)

func (self *HeapSortHandler) FamilyName() string {
	return familyName
}

func (self *HeapSortHandler) FamilyVersions() []string {
	return []string{"0.1"}
}

func (self *HeapSortHandler) Namespaces() []string {
	return []string{self.namespace}
}

func (self *HeapSortHandler) HeapSort(context *processor.Context, A []int, l int, r int, sig string) interface{} {
	buildheap(A, l, r)
	for i := r; i >= l+1; i-- {
		exchange(A, l, i)
		heapify(A, l, l, i-1)
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
	var errEvent = context.AddEvent("sort/heapSort", attributes, data)
	if errEvent != nil {
		/*return &processor.InvalidTransactionError{
			Msg: fmt.Sprint("Failed to add event: ", errEvent),
		}*/
		logger.Errorf("Failed to add event: ", errEvent)
		return nil
	}
	return nil
}

func (self *HeapSortHandler) Apply(request *processor_pb2.TpProcessRequest, context *processor.Context) error {

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

		var err = self.HeapSort(context, A, l, r, signature)
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

func (self *HeapSortHandler) preparePayload(request *processor_pb2.TpProcessRequest) (HeapSortPayload, error) {

	var payloadData = request.GetPayload()
	if payloadData == nil {
		return HeapSortPayload{}, &processor.InvalidTransactionError{Msg: "Must contain payload"}
	}
	var payload HeapSortPayload
	var err = DecodeCBOR(payloadData, &payload)
	if err != nil {
		return HeapSortPayload{}, &processor.InvalidTransactionError{
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

func buildheap(A []int, l int, r int) {
	for i := (r - l - 1) / k; i >= 0; i-- {
		heapify(A, l, l+i, r)
	}
}

func heapify(A []int, l int, q int, r int) {
	for ok := true; ok; ok = true {
		var largest = l + k*(q-l) + 1
		if largest <= r {
			for i := largest + 1; i <= largest+k-1; i++ {
				if i <= r && A[i] > A[largest] {
					largest = i
				}
			}
			if A[largest] > A[q] {
				exchange(A, largest, q)
				q = largest
			} else {
				return
			}
		} else {
			return
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
