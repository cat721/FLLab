## stubmock简介
mockstub和ChaincodeStub一样，是ChaincodeStubInterface 的实现，实现了ChaincodeStubInterface中的函数，如GetState,PutState等。但也有一些没有做实现，如数据库相关的GetQueryResult（针对couchdb的rich query函数），GetHistoryForKey（某个key的历史键值）和交易者相关的GetCreator，GetTransient（不记录在账本的与加密相关的字段）以及没人用的函数，如GetArgsSlice（把Args中去掉function，拼成一个byte[]）
interfaces_stable是在实际的区块链网络中，智能合约与区块链的交互，而mockstub目标是单元测试。

### stubmock结构
```
type MockStub struct {
    // arguments the stub was called with
    args [][]byte
 
    // A pointer back to the chaincode that will invoke this, set by constructor.
    // If a peer calls this stub, the chaincode will be invoked from here.
    cc Chaincode
 
    // A nice name that can be used for logging
    Name string
 
    // State keeps name value pairs
    State map[string][]byte
 
    // Keys stores the list of mapped values in lexical order
    Keys *list.List
 
    // registered list of other MockStub chaincodes that can be called from this MockStub
    Invokables map[string]*MockStub
 
    // stores a transaction uuid while being Invoked / Deployed
    // TODO if a chaincode uses recursion this may need to be a stack of TxIDs or possibly a reference counting map
    TxID string
 
    TxTimestamp *timestamp.Timestamp
 
    // mocked signedProposal
    signedProposal *pb.SignedProposal
 
    // stores a channel ID of the proposal
    ChannelID string
}
```

### 优势
- 可以对key遍历。访问stub.Keys
- 可以对state遍历。访问stub.State即可。在ChaincodeStub中没有遍历函数

## mockstub与Chaincodestub对比
 |mockstub|Chaincodestub
 ---- | --- | --
特有的内容 |state，keys |creator，transient，binding，decorations，event
未实现函数| GetQueryResult，GetHistoryForKey，GetTransient，GetCreator，GetBinding，GetSignedProposalGetArgsSlice|无
GetState  | 直接从mockstub的state中获得 | 使用handler.handleGetState从ledger中查询
PutState | 写入到mockStub的state和Keys中 | 调用handler.handlePutState
DelState | 同时从mockStub的state和Keys中删除 | 调用handler.handleDelState
GetArgs，GetStringArgs，GetFunctionAndParameters| 两者一样| 两者一样


## stubmock使用
### 初始
```
scc := new(SimpleChaincode)
stub := shim.NewMockStub("ex02", scc)
```
### init
因为是单元测试，所以不需要install chaincode。MockInit对应instantiate，对chaincode初始化。
```res := stub.MockInit("1", args) ```

### invoke
一般我们使用peer invoke，如
```peer chaincode invoke -n mycc -c '{"Args":["invoke","a","b","10"]}' -o 127.0.0.1:7050 -C ch1```
使用stubmock，调用MockInvoke
```res := stub.MockInvoke("1", [][]byte{[]byte("query"), []byte(name)})```
第一个1是一个uuid，query是function ，name及以后是真正的参数。

### 特有函数
#### MockTransactionStart
设置txid，signedProposal，txtimestamp

#### MockTransactionEnd
把signedProposal和txid设为空

#### MockPeerChaincode
把一个chaincode和一个对应的stub对象，写入Mockstub.Invokables

#### MockInit
先MockTranctionStart，设置stub的args，然后调用chaincode的Init函数，最后MockTranctionEnd

#### MockInvoke
与MockInit的唯一区别是调用chaincode的Invoke函数


### 如果要测试的chaincode会调用其他chaincode
对于另一个chaincode stub2Hash，首先new一个stub2，并且stub.init
然后```stub1.MockPeerChaincode("stub2Hash", stub2)```
然后```stub1.InvokeChaincode("stub2Hash", funcArgs, channel)```

### 常见写法
在待测chaincode的同级目录下，新建一个***_test.go的文件，例如，如果有一个chaincode_example02.go的chaincode文件，测试文件名为chaincode_example02_test.go

```
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
 
func checkQuery(t *testing.T, stub *shim.MockStub, name string, value string) {
    res := stub.MockInvoke("1", [][]byte{[]byte("query"), []byte(name)})
    if res.Status != shim.OK {
        fmt.Println("Query", name, "failed", string(res.Message))
        t.FailNow()
    }
    if res.Payload == nil {
        fmt.Println("Query", name, "failed to get value")
        t.FailNow()
    }
    if string(res.Payload) != value {
        fmt.Println("Query value", name, "was not", value, "as expected")
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
```
在测试源码文件中，针对其他源码文件中的程序实体的功能测试程序总是以函数为单位的，被用于测试程序实体功能的函数的名称和签名形如
```
func TextXxx(t *testing.T)
```
```
func TestExample02_Invoke(t *testing.T) {
    scc := new(SimpleChaincode)   //SimpleChaincode是待测试的chaincode中的struct名
    stub := shim.NewMockStub("ex02", scc)   //ex02是name，没有用处。
 
    // Init A=567 B=678
    checkInit(t, stub, [][]byte{[]byte("init"), []byte("A"), []byte("567"), []byte("B"), []byte("678")})
 
    // Invoke A->B for 123
    checkInvoke(t, stub, [][]byte{[]byte("invoke"), []byte("A"), []byte("B"), []byte("123")})
    checkQuery(t, stub, "A", "444")
    checkQuery(t, stub, "B", "801")
 
    // Invoke B->A for 234
    checkInvoke(t, stub, [][]byte{[]byte("invoke"), []byte("B"), []byte("A"), []byte("234")})
    checkQuery(t, stub, "A", "678")
    checkQuery(t, stub, "B", "567")
    checkQuery(t, stub, "A", "678")
    checkQuery(t, stub, "B", "567")
}
```

### reference
[1] https://github.com/hyperledger/fabric/blob/release-1.2/examples/chaincode/go/example02/chaincode_test.go
[2] https://github.com/hyperledger/fabric/blob/release-1.2/core/chaincode/shim/mockstub.go
