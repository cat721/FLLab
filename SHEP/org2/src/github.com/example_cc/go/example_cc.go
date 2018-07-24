/*
Copyright IBM Corp. 2016 All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

		 http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package main

import (
	"encoding/json"
	"fmt"

	"strconv"

	"time"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

// SimpleChaincode example simple Chaincode implementation
type SimpleChaincode struct {
}

func (t *SimpleChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println("ex02 Init")
	return shim.Success(nil)
}

func (t *SimpleChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println("ex02 Invoke")
	function, args := stub.GetFunctionAndParameters()
	if function == "invoke" {
		// Make payment of X units from A to B
		return t.invoke(stub, args)
	} else if function == "query" {
		return t.query(stub, args)
	}

	return shim.Error("Invalid invoke function name. Expecting \"invoke\" \"query\"")
}

func (t *SimpleChaincode) invoke(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var SourceId, ReceiveId, ServerId string // Entities
	var value string

	if len(args) != 4 {
		return shim.Error("Incorrect number of arguments. Expecting 4")
	}

	SourceId = args[0]
	ReceiveId = args[1]
	ServerId = args[2]
	value = args[3]
	IdIndexKey, err := stub.CreateCompositeKey("DemoType", []string{SourceId, ReceiveId, ServerId})
	if err != nil {
		return shim.Error("Failed to create compositeKey")
	}

	err = stub.PutState(IdIndexKey, []byte(value))
	if err != nil {
		return shim.Error("Fail to put state")
	}

	type msg struct {
		SourceId  string
		ReceiveId string
		ServerId  string
		Value     string
		Tx_Id     string
		Time      string
	}
	mytime, _ := stub.GetTxTimestamp()
	loc, _ := time.LoadLocation("Asia/Chongqing")
	m := msg{
		SourceId:  SourceId,
		ReceiveId: ReceiveId,
		ServerId:  ServerId,
		Value:     value,
		Tx_Id:     stub.GetTxID(),
		Time:      time.Unix(mytime.Seconds, 0).In(loc).Format("2006-01-02 15:04:05"),
	}
	msgByte, err := json.Marshal(m)
	if err != nil {
		return shim.Error("unable to marshal")
	}
	stub.SetEvent("testWrite", msgByte)
	return shim.Success(msgByte)
}

func (t *SimpleChaincode) query(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) > 3 {
		return shim.Error("Incorrect number of arguments. Expecting smaller than 3")
	}

	DemoIterator, err := stub.GetStateByPartialCompositeKey("DemoType", args)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer DemoIterator.Close()
	var i int
	i = 0
	for i = 0; DemoIterator.HasNext(); i++ {
		DemoIterator.Next()
	}
	return shim.Success([]byte(strconv.Itoa(i)))
}

func main() {
	err := shim.Start(new(SimpleChaincode))
	if err != nil {
		fmt.Printf("Error starting Simple chaincode: %s", err)
	}
}
