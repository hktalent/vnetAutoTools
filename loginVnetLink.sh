#!/bin/bash
socks5='socks5://127.0.0.1:1099'
username="xx"
psd="xx"
svFile="servers.txt"

# mac connect 62
# 38 conn not ok
rd01=$((1 + RANDOM % 10))
rd02=$((1 + RANDOM % 600))
rd03=$((1 + RANDOM % 4565))

token1="ugeasq5b${rd03}c${rd02}ff$rd01"
# max connection
macConn=100
tm='date "+%Y-%m-%d %H:%M.%S"'
RED='\033[0;31m'
NC='\033[0m' # No Color
start="\033[7;35mstart${NC}"
end="\033[7;34mend${NC}"
ok="\033[7;102mOk${NC}"
error="\033[7;101mOk${NC}"
newLine="\n=========================================="

usage()
{
	echo "Help: ./loginVnetLink.sh [options]\n"
	
	echo "-u, --username, default[$username]"
	echo "-p, --password, default[$psd]"
	echo "-f, --file, default[$svFile]"
	echo "-s, --socks, default[$socks5]"
	echo "-l, --list, no default"
	echo 
	echo "git clone https://"
	echo "Example:"
	echo 
	echo "./loginVnetLink.sh -h"
	echo "./loginVnetLink.sh -u YouVnetName -p pswd -s socks5://127.0.0.1:1090 -f servers.txt"
	echo "./loginVnetLink.sh -u YouVnetName -p pswd -s socks5://127.0.0.1:1090 -l"
	echo "./loginVnetLink.sh --username YouVnetName --password pswd --socks socks5://127.0.0.1:1090"
	echo "./loginVnetLink.sh --username YouVnetName --password pswd --socks socks5://127.0.0.1:1090 --list"
	
	echo 

}
# 获取当前日期
getCurDt()
{
	eval "$1=\"`date '+%Y-%m-%d %H:%M.%S'`\""
}

# 日志输出
mylog()
{
	getCurDt tm2
	printf "[${RED}${tm2}${NC}] ${1}\n"
}

# 解析参数
while [ "$1" != "" ]; do
    case $1 in
        -u | --username )       shift
                                username=$1
                                ;;
        -f | --file )           shift
                                svFile=$1
                                ;;                                
        -p | --password )       shift
                                psd=$1
                                ;;
        -s | --socks )          shift
                                socks5=$1
                                ;;
        -l | --list )    getList=1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done


# array，引用所有：${svFiles[@]}，其他引用：${svFiles[1]}
IFS=$'\r\n' GLOBIGNORE='*' command eval  'svFiles=($(cat $svFile))'
# Length=${#svFiles[@]}
# echo "${svFiles[3]}"
# kk1=(${svFiles[3]})
# echo ${kk1[1]}

# server list length
Length=${#svFiles[@]}

# passwd list init
pdList=()
until [ $Length -lt 1 ]; do
	let Length-=1
	kk1=(${svFiles[$Length]})
	kTmp=`echo ${kk1[0]}""${kk1[1]} |sed 's/[\.]//g'`
	pdList[$kTmp]=${kk1[2]}
	# echo $kTmp ${pdList[$kTmp]}
done
# 恢复，后面用
Length=${#svFiles[@]}


#######test#########
curUser=`whoami`
mydir="/Users/${curUser}/Library/Application Support/ShadowsocksX-NG"
mkdir -p $mydir
youSsLocal="${mydir}/ss-local"


# 获取已经创建的列表：./loginVnetLink.sh list
nPort=2081
getCreatedList()
{
	mylog "4、$start get created lists ..."
	myLists=`curl -x $socks5 -kqfs 'https://vx.link/x2/service/vxtrans/core?action=list' -H 'cookie: PHPSESSID='$token  --compressed -o - > tmp1.txt 2>&1`
	myLists=`cat tmp1.txt`
	myLists1=`cat tmp1.txt|grep -E '入口:|目标:'|sed 's/.* //g'|sed 's/<.*//g'|grep -v "^\s*$"`
	rm tmp1.txt
	lstT=''
	cat runAll.bak>runAll.sh
	cat proxychains.bak>proxychains.conf
	rm runTmp.sh
	for k in ${myLists1}; do
		if [ "$lstT" = "" ]; then
			lstT=$k
		else
			kTmp=`echo $k|sed 's/[\.:]//g'`
			#echo ${pdList[$kTmp]}
			jk=(`echo $lstT |sed 's/:/ /g'`)
			jsonNm=`echo $lstT|sed 's/[:\.]/_/g'`"_${kTmp}_${nPort}.json"
			echo "{\
\"method\":\"aes-256-cfb\",\
\"server\":\"${jk[0]}\",\
\"server_port\":${jk[1]},\
\"password\":\"${pdList[$kTmp]}\",\
\"auth\":false,\
\"local_address\":\"127.0.0.1\",\
\"timeout\":60,\
\"local_port\":${nPort}\
}">$jsonNm
			
			
			mylog "test $jsonNm ...."
			## test port
			"$youSsLocal" -c $jsonNm -u &
			teststr=`curl -x "socks5://127.0.0.1:${nPort}" -s -o - http://ip.cn`
			proxyIp=`echo $teststr|grep -Eo '\d{1,}\.\d{1,}\.\d{1,}\.\d{1,}'`
			proxyIp=`echo $proxyIp|sed 's/[\.:]//g'`
			if [[ $jsonNm =~ $proxyIp ]]
			then
				mylog "$ok $jsonNm,and test is $ok"
				echo '"'$youSsLocal'" -c '$jsonNm' -u &' >>runTmp.sh
				kpid=`ps -ef|grep $jsonNm|grep -v 'grep'|awk '{print $2}'`
				echo "pid: ["$kpid"]"
				kpid=`kill -9 $kpid`
				echo "testOne ${nPort}" >>runAll.sh
				echo "socks5	127.0.0.1	${nPort}">>proxychains.conf
			fi


			let nPort+=1
			lstT=''
		fi
	done

	mylog "4、$start make ss-local json file"

	mylog "4、$end make ss-local json file"
	mylog "4、$end get created lists${newLine}"
}

mylog "1、$start login......"
tmp=`curl -x $socks5 -fs -vv -o - 'https://vx.link/openapi/v1/user?token='$token1'&username='$username'&password='$psd'&action=login' > tmp.txt 2>&1`
mylog "1、${end} login${newLine}"

# 获取token
mylog "2、$start get token......"
token=`cat tmp.txt |tr -d '[\r\n]'|grep '{"data":"ok","status":1}'|grep -Eo ': PHPSESSID=([^;]+);'|sed 's/;.*//g'|sed 's/.*=//g'`
rm tmp.txt
if [ "$token" != '' ]; then
	mylog 'login is '$ok': '$token
	echo "[$token]"
else
	mylog "login $error"
fi
mylog "2、$end get token${newLine}"


if [ "$getList" != '' ]; then
	mylog 'list 命令'
	getCreatedList
	mylog '退出'
	exit 0
fi

# 不用代理，结果迥然不一样
# 获取可选的国家的列表，线路列表
mylog "3、$start get select list ..."
selectHtml=''
# https://vx.link/x2/service/vxtrans/
# https://vx.link/x2/service/vxtrans/index
selectHtml=`curl -x $socks5 -kqfs https://vx.link/x2/service/vxtrans/index -H 'cookie: PHPSESSID='$token --compressed`
selectLists=`echo $selectHtml|sed 's/.*id="set_location">//g'|sed 's/<\/select>.*//g'|grep -Eo 'value="([^"]+)'|sed 's/value="//g'`
unset selectHtml
selectCnt=`echo $selectLists|wc -w|sed 's/[\t ]*//g'`
mylog "find select lists $selectCnt $ok: \n${selectLists}"
mylog "3、$end get select list${newLine}"

# 对列表进行循环，创建连接
mylog "4、$start create link ..."
xCnt=0
# 官方说最多可以创建100个连接
let xNum=$macConn/$selectCnt
nOld=$xNum

getCreatedList
## 去重
allLists=${myLists[@]}


bBreak=''
for k in ${selectLists}; do
	let xCnt=xCnt+1 
	until [ $xNum -lt 1 ]; do
		 let xNum-=1
		 if [ $Length -lt 1 ]; then
		 	let Length=4
		 fi
		 let Length-=1
		 kk1=(${svFiles[$Length]})

		# mylog "$start $xCnt $k $xNum"
		tmpName='x'$xCnt'_'$xNum
		if [[ $allLists =~ "名称: $tmpName<br>" ]]
		then
			mylog '已经创建过，跳过创建: '$tmpName
		else
			rtnOk=`curl -x $socks5 -kqfs 'https://vx.link/openapi/v1/vxtrans?protocol=tcp&name='$tmpName'&action=add&location='$k'&localport=&to_ip='${kk1[0]}'&to_port='${kk1[1]}'&limit=' -H 'cookie: PHPSESSID=ugeasq5b4564c559fe8' -H 'accept: application/json' -H 'referer: https://vx.link/x2/service/vxtrans/index' -H 'authority: vx.link' -H 'x-requested-with: XMLHttpRequest' --compressed`
			if [[ $rtnOk =~ '"data":"ok"' ]]
			then
				mylog '成功创建: '$tmpName
			elif [[ $rtnOk =~  "\u8be5\u8d26\u53f7\u5df2\u8fbe\u5230\u8fde\u63a5\u70b9\u4e0a\u9650" ]]
			then
				mylog '创建失败、该账号已达到连接点上限: '$tmpName
				bBreak='1'
				break
			else
				mylog '创建失败: '$tmpName' '$rtnOk
			fi
		fi
	done
	if [ bBreak='1' ]; then
		bBreak=''
		break
	fi
	let xNum=$nOld
done

mylog "4、$end create link"
# 再次获取新的、已经创建的列表
getCreatedList
