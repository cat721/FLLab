GetArgs:
以[][]byte 格式返回，第一个[]byte是function，后面的[]byte是参数，比较常用


GetStringArgs:
把GetArgs返回的结果，都转成string


GetFunctionAndParameters
返回2个对象，第一个对象是一个string，为GetStringArgs返回的[]string中的第一个；第二个对象签名是[]string，是GetStringArgs返回的[]string去掉第一个剩下的，比较常用


GetArgsSlice
看上去是把GetArgs返回的内容拼在一起，没想到有什么用处。在MockStub中没有实现
以上函数的结构可以看出，参数的类型要保持一致，全部为string或者全部是压成[]byte(json)


======================================


GetTxId
对每笔交易，每个peer唯一


GetChannelId
唯一要注意的是跨channel调用chaincode时，返回的是哪一个channel，我也不太清楚


GetTxTimestamp

返回交易创建时间，在任何一个peer上运行结果一致。
```
    t, err := stub.GetTxTimestamp()
    if err != nil {
        return shim.Error(err.Error())
    }
 
    loc, err := time.LoadLocation("Asia/Chongqing")   //不要给成Beijing之类的
    if err != nil {
        return shim.Error(err.Error())
    }
//返回 2018-07-31 16:22:23 的string
// 2006-01-02 15:04:05 这个string不能修改
    CreateTime := time.Unix(t.Seconds, 0).In(loc).Format("2006-01-02 15:04:05")
```




GetState(key string) ([]byte ,error)
PutState(key string,value []byte)
DelState(key string) error
这几个没什么好说的


GetStateByRange
//把key按照字母顺序排列之后，返回几个字母之间的key。用处不大


CreateCompositeKey(objectType string,attributes []string)(string,error)
把ObjectType放在第一项，然后 把attributes中每一项，以minUnicodeRuneValue为分隔符，连在一起
compositeKeyNamespace+objectType+minUnicodeRuneValue+attribute[0]+minUnicodeRuneValue+...


SplitCompositeKey
CreateCompositeKey的逆操作。


GetTransient
常用函数，用来获取一些附加的信息，这些内容不会被写入到账本


GetQueryResult
GetHistoryForKey

GetCreator
GetBinding
GetDecorations
GetSignedProposal
InvokeChaincode

//以上没怎么用过




GetStateByPartialCompositeKey(objectType string,keys []string)(StateQueryIteratorInterface,error)
搜索是只能对于前缀搜索，比如有这样的CompositeKey
(1) 'a','b'
(2) 'a','b','c'
(3) 'c','b','a'


搜索a，能搜到(1)(2)
搜索a b，能搜到(1)(2)
搜索a b c，能搜到(2)
搜索c，能搜到(3)
如果想收到(1),(2),(3)，那么可以传一个空的[]string{}进去，如
```
undoneIterator, err := stub.GetStateByPartialCompositeKey(prefixUndone, []string{})

```


================================
要保存这样的结构
```
{
    a:"43214",

    b:"fadf"

}
```
那是一定不行的，golang中struct的key必须要大写字母开头，如下面所示
```
type demoStruct struct{
    A string

    B string
}
repairOrder := demoStruct{
    A:"43214",

    B:"fadf"

}
repairOrderBytes,err:= json.Marshal(repairOrder)
stub.PutState("key",repairOrderBytes)
```
取的时候这样取
```
repairOrderBytes,err:= stub.GetState("key")
var s demoStruct
err := json.Unmarshal(repairOrderBytes,&s)
```
而如果要保存这样一个[]string ，可以利用createCompositeKey
```
a:= []string{"a","b","c"}
value,err := stub.CreateCompositeKey("demoType",a)
stub.PutState("key",[]byte(value))
```
```
//取的时候这样取
value,err:=stub.GetState("key")
_,a, err := stub.SplitCompositeKey(string(value))
```