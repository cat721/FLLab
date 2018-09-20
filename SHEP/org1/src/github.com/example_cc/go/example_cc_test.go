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
	"testing"

	"github.com/hyperledger/fabric/core/chaincode/shim"
)

var SourceId = "123456"
var ReceiveId = "university"
var ServerId_1 = "777777"
var ServerId_2 = "888888"

func checkInit(t *testing.T, stub *shim.MockStub, args [][]byte) {
	res := stub.MockInit("1", args)
	if res.Status != shim.OK {
		fmt.Println("Init failed", string(res.Message))
		t.FailNow()
	}
}

func checkState(t *testing.T, stub *shim.MockStub, name string, value string) {
	bytes := stub.State[name]
	if bytes == nil {
		fmt.Println("State", name, "failed to get value")
		t.FailNow()
	}
	if string(bytes) != value {
		fmt.Println("State value", name, "was not", value, "as expected")
		t.FailNow()
	}
}

func checkQuerySuccess(t *testing.T, stub *shim.MockStub, name [][]byte) {
	res := stub.MockInvoke("1", name)
	if res.Status != shim.OK {
		fmt.Println("Query failed", string(res.Message))
		// spew.Dump(name)
		t.FailNow()
	}
	if res.Payload == nil {
		fmt.Println("Query", name, "failed to get value")
		t.FailNow()
	}
	if string(res.Payload) != "true" {
		fmt.Println(string(res.Payload) + " doesnot equal 1")
		t.FailNow()
	}
}

func checkQueryError(t *testing.T, stub *shim.MockStub, name [][]byte) {
	res := stub.MockInvoke("1", name)
	if res.Status != shim.OK {
		fmt.Println("Query failed", string(res.Message))
		// spew.Dump(name)
		t.FailNow()
	}
	if res.Payload == nil {
		fmt.Println("Query", name, "failed to get value")
		t.FailNow()
	}
	if string(res.Payload) != "false" {
		fmt.Println(string(res.Payload) + " doesnot equal 0")
		t.FailNow()
	}
}

func checkInvoke(t *testing.T, stub *shim.MockStub, args [][]byte) string {
	res := stub.MockInvoke("1", args)
	if res.Status != shim.OK {
		fmt.Println("Invoke", args, "failed", string(res.Message))
		t.FailNow()
	}
	m := msg{}
	json.Unmarshal(res.Payload, &m)
	return m.Time
}

func TestExample02_Init(t *testing.T) {
	scc := new(SimpleChaincode)
	stub := shim.NewMockStub("ex02", scc)

	checkInit(t, stub, [][]byte{})
}

func TestExample02_Invoke(t *testing.T) {
	scc := new(SimpleChaincode)
	stub := shim.NewMockStub("ex02", scc)

	checkInit(t, stub, [][]byte{})

	time1 := checkInvoke(t, stub, [][]byte{[]byte("invoke"), []byte(SourceId), []byte(ReceiveId), []byte(ServerId_1), []byte("value")})
	time2 := checkInvoke(t, stub, [][]byte{[]byte("invoke"), []byte(SourceId), []byte(ReceiveId), []byte(ServerId_2), []byte("上港是冠军")})

	// spew.Dump(stub.State)
	checkQuerySuccess(t, stub, [][]byte{[]byte("query"), []byte(SourceId), []byte(ReceiveId), []byte(ServerId_1), []byte(time1), []byte("value")})
	checkQueryError(t, stub, [][]byte{[]byte("query"), []byte(SourceId), []byte(ReceiveId), []byte(ServerId_1), []byte(time1), []byte("ErrorValue")})
	checkQuerySuccess(t, stub, [][]byte{[]byte("query"), []byte(SourceId), []byte(ReceiveId), []byte(ServerId_2), []byte(time2), []byte("上港是冠军")})
	checkQueryError(t, stub, [][]byte{[]byte("query"), []byte(SourceId), []byte(ReceiveId), []byte(ServerId_2), []byte(time2), []byte("恒大是冠军")})
}
