# /channels/:channelname/chaindoces/:chaindcodename

## 使用范例

```
curl -s -X GET http://localhost:4000/channels/mychannel/transactions/$TRX_ID?peer=peer0.org1.example.com \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
```

## 请求参数

| 参数 | 可选 |含义 |
| :------ | :------- | :------ |
| peer    | 必选 | 请求的peer节点 |
| $TRX_ID | 必选 | Transaction ID |


## 返回值与格式
完整的transaction 信息
返回值的完整格式是[queryTransaction](https://fabric-sdk-node.github.io/Channel.html#queryTransaction__anchor)返回值信息
