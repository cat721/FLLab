## 使用范例

```
curl -s -X GET \
        "http://localhost:4000/num?No=$No"\
        -H "authorization: Bearer $ORG1_TOKEN" \
        -H "content-type: application/json"
```

## 请求参数

| 参数 | 可选 |含义 |
| :------  | :------- | :------ |
|$No       |必选  | 业务Id        |


## 返回值与格式
返回一个value值或者空
