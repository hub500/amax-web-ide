## 查看节点、编译合约

```
amcli get info

amcli wallet list

amcli get account amax

amax-cpp contract/talk.cpp
```

## 创建合约账号、部署合约

```
amcli create account amax talk AM6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV

amcli set code talk talk.wasm

amcli set abi talk talk.abi
```

## 创建用户账号、调用合约

```
amcli create account amax bob AM6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV

amcli create account amax jane AM6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV

amcli push action talk post '[1000, 0, bob, "This is a new post"]' -p bob

amcli push action talk post '[2000, 0, jane, "This is my first post"]' -p jane

amcli push action talk post '[1001, 2000, bob, "Replying to your post"]' -p bob
```

## 查询表数据

```
amcli get table talk '' message
```


# 部署amax.token合约


```
# deploy-amax-token.sh

amcli create account amax amax.token AM6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV -p amax@active

cd /home/gitpod/contracts

amcli set code amax.token amax.token.wasm -p amax.token@active
amcli set abi amax.token amax.token.abi -p amax.token@active

amcli push action amax.token create '[ "amax", "1000000000.00000000 AMAX"]' -p amax.token@active

amcli push action amax.token issue '[ "amax", "1000000000.00000000 AMAX", "amax issue"]' -p amax@active


amcli create account amax myusermyuser AM6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV -p amax@active

amcli push action amax.token transfer '["amax","myusermyuser","100.00000000 AMAX",""]' -p amax@active
```
