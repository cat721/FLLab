# /data

## 使用范例

```
crul -s -X POST \
http://localhost:4000/data \
-H "content-type: application/json" \
-d "{
	\"SourceID\":\"sourceid\",
	\"ReceiveID\":\"receiveid\",
	\"ServerID\":\"serverid\",
	\"STime\":\"2018-07-12 22:04:59\",
	\"ETime\":\"2018-07-13 22:04:59\"
}"
```

## 请求参数

| 参数 | 可选 |含义 |
| :------ | :------- | :------ |
| SourceID  | 必选 | 交易的来源ID | % TODO: 与潘业达确认
| ReceiveID | 可选 | 交易的接收者ID | % TODO: 与潘业达确认
| ServerID  | 可选 | 服务器ID | % TODO: 与潘业达确认
| STime     | 可选 | 查找的时间范围的起始时间 |
| ETime     | 可选 | 查找的时间范围的终止时间 |

## 关于STime,ETime的说明

STime，ETime都是可选字段，POST的时候可以不提供

|STime | ETime | 返回结果 |
|------| ----- | -------- |
| 有   | 有    |  返回从STime到ETime时间段内的所有记录        |
| 有   | 没有  |  返回从STime到目前为止时间段内的所有记录       |
| 没有 | 有    |  返回错误（关于如何解析错误，请参考下一小节）        |
| 没有 | 没有  |  返回所有flag为false的记录（从来没有被请求过的记录）|       |

## 返回值与格式

返回值为JSON格式，模板如下所示

```
<Return JSON> ::= {
  "state" : <Return State Code>,
  "data"  : "<Return Data>"
}

<Return State Code> ::= 500|1001|1002|1003|1004|1005|1006

<Return Data> ::= <Query Result Entry List>|<Error Message>

<Query Result Entry List> ::= {<Query Result Entry>}

<Query Result Entry> ::= SourceID, ReceiveID, ServerID, Value, Tx_ID, TxTime

<Error Message> ::= SQL Query Condition Error: Field "ReceiveID" is null|
                    SQL Query Condition Error: Field "ETime" is not null and field "STime" is null|
                    SQL Query Condition Error: Field "STime" is greater than field "ETime"|
                    MySQL Database Connection Error|
                    MySQL Database Update Error: Update statement is "<Update Statement>"
```

关于状态码的详细解释如下表所示

| 状态码 | 含义 |
| :----| ---- |
|500  |  所有操作成功                            |
|1001  |  ReceiveID为空                        |
|1002  |  有ETime字段，但没有提供STime字段      |
|1003  |  连接数据库错误，可能是数据库的账号密码有错，或者数据库禁止外部访问                         |
|1004  |  ETime在STime之前                     |
|1006  |  数据库的Flag字段update（从false改成true）出错           |





