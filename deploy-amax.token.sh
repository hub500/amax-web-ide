sleep 30

amcli create account amax amax.token AM6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV -p amax@active

cd /home/gitpod/contracts

amcli set code amax.token amax.token.wasm -p amax.token@active
amcli set abi amax.token amax.token.abi -p amax.token@active

amcli push action amax.token create '[ "amax", "1000000000.00000000 AMAX"]' -p amax.token@active
amcli push action amax.token issue '[ "amax", "1000000000.00000000 AMAX", "amax issue"]' -p amax@active

amcli create account amax myusermyuser AM6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV -p amax@active
amcli push action amax.token transfer '["amax","myusermyuser","100.00000000 AMAX",""]' -p amax@active
