# /channels/:channelname/chaindoces/:chaindcodename

## 使用范例

```
curl -s -X GET \
  http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%$sourceID%$ReceiveID%$ServerID%$Timestamp \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
```

## 请求参数

| 参数 | 可选 |含义 |
| :------  | :------- | :------ |
| peer     | 必选 | 请求的peer节点 |
|$sourceID | 必选 | 触发chaincode函数的参数（如果是invoke函数，参数数量必须为4个，含义见范例） |
|$ReceiveID| 必选 |  |
|$ServerID | 必选 |  |
|$Timestamp| 必须 |  |

## 返回值与格式
返回一个value值或者空
