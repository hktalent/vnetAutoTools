# vnetAutoTools
auto login vnet.link and create more links
# how use
```

$cd ~/
$mkdir safe;cd safe
# depends
$git clone https://github.com/hktalent/myhktools.git
# this project
$git clone https://github.com/hktalent/vnetAutoTools.git
$cd vnetAutoTools
$
$vi servers.txt
# change to your vps shadowsocks info,eg:

$chmod +x loginVnetLink.sh
#help 
$./loginVnetLink.sh -h
-u, --username, default[xx]
-p, --password, default[xx]
-f, --file, default[servers.txt]
-s, --socks, default[socks5://127.0.0.1:1090]
-l, --list, no default

git clone https://
Example:

./loginVnetLink.sh -h
./loginVnetLink.sh -u YouVnetName -p pswd -s socks5://127.0.0.1:1090 -f servers.txt
./loginVnetLink.sh -u YouVnetName -p pswd -s socks5://127.0.0.1:1090 -l
./loginVnetLink.sh --username YouVnetName --password pswd --socks socks5://127.0.0.1:1090
./loginVnetLink.sh --username YouVnetName --password pswd --socks socks5://127.0.0.1:1090 --list

# use:
./loginVnetLink.sh -u yourName -p yourPswd
./loginVnetLink.sh -u yourName -p yourPswd -l
# so make run file
$ls *.json
proxychains.conf
$curUser=`whoami`
$chmod +x runAll.sh
$ln -s ./proxychains.conf ~/safe/$curUser/proxychains.conf
$brew install proxychains-ng
# /usr/local/Cellar/proxychains-ng/4.12_1/bin/proxychains4
$./runAll.sh



```

# demo 


![demo1](https://raw.githubusercontent.com/hktalent/vnetAutoTools/master/demo/s1.png)
![demo2](https://raw.githubusercontent.com/hktalent/vnetAutoTools/master/demo/s2.png)
