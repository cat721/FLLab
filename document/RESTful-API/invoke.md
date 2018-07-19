# /channels/:channelname/chaindoces/:chaindcodename

## 使用范例

```
curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
	"fcn":"invoke",
	"args":["sourceID","ReceiveID","ServerID","Value"]
}
```

## 请求参数

| 参数 | 可选 |含义 |
| :------ | :------- | :------ |
| peers   | 必选 | 触发chaincode选择的peer节点 |
| fcn     | 必选 | 触发的chaincode中的函数名（必须写invoke）|
| args    | 必选 | 触发chaincode函数的参数（如果是invoke函数，参数数量必须为4个，含义见范例） |


## 返回值与格式

返回值为JSON格式，模板为

```
<Return JSON> ::= {
  "state" : "<Return State>",
  "error_message"  : "<Entry List>"
}

<Return state> ::= <500|1001|1002|1003|1004 >

<Entry error_message> ::= <Error Message|NULL>

```

| 错误码 | 含义 |
| :----| ---- |
|500  |  所有操作成功                            |
|1001 | invoke错误                    |
|1002 | 把收集到的proposal发给orderer出错 |
|1003 | eventHub 返回错误 |
|1004 | try-catch中错误，比如发给不存在的peer，channel还没有创建|



