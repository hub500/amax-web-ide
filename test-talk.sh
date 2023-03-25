
amax-cpp contract/talk.cpp

amcli create account amax talk AM6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV

amcli set code talk talk.wasm
amcli set abi talk talk.abi

amcli create account amax bob AM6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV
amcli create account amax jane AM6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV

amcli push action talk post '[1000, 0, bob, "This is a new post"]' -p bob
amcli push action talk post '[2000, 0, jane, "This is my first post"]' -p jane
amcli push action talk post '[1001, 2000, bob, "Replying to your post"]' -p bob

amcli get table talk '' message
