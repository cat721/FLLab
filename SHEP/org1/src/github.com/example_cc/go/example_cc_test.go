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
	"fmt"
	"testing"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/davecgh/go-spew/spew"
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

func checkQuery(t *testing.T, stub *shim.MockStub,name [][]byte, value string) {
	res := stub.MockInvoke("1", name)
	if res.Status != shim.OK {
		fmt.Println("Query", name, "failed", string(res.Message))
		t.FailNow()
	}
	if res.Payload == nil {
		fmt.Println("Query", name, "failed to get value")
		t.FailNow()
	}
	if string(res.Payload) != value {
		fmt.Println("Query value", name,"result",string(res.Payload), "was not", value, "as expected")
		t.FailNow()
	}
}

func checkInvoke(t *testing.T, stub *shim.MockStub, args [][]byte) {
	res := stub.MockInvoke("1", args)
	if res.Status != shim.OK {
		fmt.Println("Invoke", args, "failed", string(res.Message))
		t.FailNow()
	}
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

	checkInvoke(t, stub, [][]byte{[]byte("invoke"), []byte(SourceId), []byte(ReceiveId), []byte(ServerId_1),[]byte("value")})
	checkInvoke(t, stub, [][]byte{[]byte("invoke"), []byte(SourceId), []byte(ReceiveId), []byte(ServerId_2),[]byte("value")})
	spew.Dump(stub.State)
	checkQuery(t,stub,[][]byte{[]byte("query"),[]byte(SourceId)} ,"2") //ok
	checkQuery(t,stub,[][]byte{[]byte("query"),[]byte(SourceId),[]byte(ReceiveId)} ,"2") //ok
	checkQuery(t,stub,[][]byte{[]byte("query"),[]byte(SourceId),[]byte(ReceiveId),[]byte(ServerId_1)} ,"1") //ok
	//checkQuery(t,stub,ServerId_1,"1") //fail
}