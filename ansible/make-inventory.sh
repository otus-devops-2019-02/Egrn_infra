#!/bin/bash

make_yaml(){
if [ -f ./inventory ]; then > ./inventory
fi
if [ -f ./inventory.yml ]; then > ./inventory.yml
fi

#rowList=`cat ./instc-list |
rowList=`gcloud compute instances list --format=json |
jq '.[]|{g1:.name|split("-")|.[0],g2:.name|split("-")|.[1],name,ipInt:.networkInterfaces[].networkIP, ipExt:.networkInterfaces[].accessConfigs[].natIP,tags:.tags.items[],status,user:.metadata.items[].value|gsub("\n";"")}|join ("\t")' -cr`


h2=""
IFS=$'\n'
for i in `echo "$rowList" | sort`;
do
    group1=`echo $i| awk -F'\t' '{print $1}'`
    group2=`echo $i| awk -F'\t' '{print $2}'`
    name=`echo $i| awk -F'\t' '{print $3}'`
    #ipInt=`echo $i| awk -F'\t' '{print $4}'`
    ipExt=`echo $i| awk -F'\t' '{print $5}'`
    #tags=`echo $i| awk -F'\t' '{print $6}'`
    #status=`echo $i| awk -F'\t' '{print $7}'`
    user=`echo $i| awk -F'\t' '{print $8}'|sed -E 's/^([^:]+).*/\1/g'`

	if [ "$h2" != "$group1" ]; then
    	h2=`echo $group1`
    	echo -e "\n[$h2]" >> ./inventory
		echo -e "\n$h2:\n  hosts:" >> ./inventory.yml
	fi
	
	echo "$name ansible_host=$ipExt ansible_user=$user" >> ./inventory
	echo -e "    $name:\n      ansible_host: $ipExt\n      ansible_user: $user" >> ./inventory.yml

	ssh-keygen -f "/root/.ssh/known_hosts" -R $ipExt
	#until nc -vzw 2 $ipExt 22; do sleep 1; done
done


IFS=$'\n'
for i in `echo "$rowList" | sort -t$'\t' -k2`;
do
    group1=`echo $i| awk -F'\t' '{print $1}'`
    group2=`echo $i| awk -F'\t' '{print $2}'`
    name=`echo $i| awk -F'\t' '{print $3}'`
    #ipInt=`echo $i| awk -F'\t' '{print $4}'`
    ipExt=`echo $i| awk -F'\t' '{print $5}'`
    #tags=`echo $i| awk -F'\t' '{print $6}'`
    #status=`echo $i| awk -F'\t' '{print $7}'`
    user=`echo $i| awk -F'\t' '{print $8}'|sed -E 's/^([^:]+).*/\1/g'`

    if [ "$h2" != "$group2" ]; then
        h2=`echo $group2`
        echo -e "\n[$h2]" >> ./inventory
        echo -e "\n$h2:\n  hosts:" >> ./inventory.yml
    fi

    echo "$name ansible_host=$ipExt ansible_user=$user" >> ./inventory
    echo -e "    $name:\n      ansible_host: $ipExt\n      ansible_user: $user" >> ./inventory.yml
done

}

make_json_list(){
if [ -f ./inventory.json ]; then > ./inventory.json
fi

#rowList=`cat ./instc-list | jq '[.[]|{g1:.name|split("-")|.[0],g2:.name|split("-")|.[1],name,ip:.networkInterfaces[].accessConfigs[].natIP}]'`
rowList=`gcloud compute instances list --format=json | jq '[.[]|{g1:.name|split("-")|.[0],g2:.name|split("-")|.[1],name,ip:.networkInterfaces[].accessConfigs[].natIP}]'`

#IFS=$'\n'; for i in `echo $rowList | jq '.[]|.ip' -r`; do ssh-keygen -f "/root/.ssh/known_hosts" -R $i 2>/dev/null; done

hostArray=`echo $rowList |
jq '.|[{_meta: {hostvars: map({(.ip): {}})|add }}]'`

allArray=`echo $rowList |
jq '.|[{all: {hosts: map(.ip)}}]'`

groupArray1=`echo $rowList |
jq '.|group_by(.g1)|map({ g1: .[0].g1, hosts: map(.ip) })|map({(.g1):{hosts}})'`
#jq '.|group_by(.g1)|map({ g1: .[0].g1, hosts: map(.ip) })|map({(.g1):{hosts}|add})'`

groupArray2=`echo $rowList |
jq '.|group_by(.g2)|map({ g2: .[0].g2, hosts: map(.ip)})|map({(.g2):{hosts}})'`


jq --argjson arr1 "$hostArray" --argjson arr2 "$allArray" --argjson arr3 "$groupArray1" --argjson arr4 "$groupArray2"  --argjson arr4 "$allArray" \
-n '$arr1 + $arr2 + $arr3 + $arr4 | map(.) | add' |
tee inventory.json
}


make_json_host(){
#rowList=`cat ./instc-list | jq '[.[]|{name,ip:.networkInterfaces[].accessConfigs[].natIP}|select(.ip=="'$HOST'")]'`
rowList=`gcloud compute instances list --format=json | jq '[.[]|{name,ip:.networkInterfaces[].accessConfigs[].natIP}|select(.ip=="'$HOST'")]'`

hostArray=`echo $rowList |
jq '.|{_meta: {hostvars: map({(.ip): {var_name: .name, var_user: "appuser" }})|add }}'`

echo $hostArray | jq .
}


terraform_output() {
rowOutput=`cd ../terraform/stage; terraform output -json`

#Fix ssh keys
for i in `echo "$rowOutput" | jq '.[]|.value[]' -cr`;
do
	ssh-keygen -f "/root/.ssh/known_hosts" -R $i
	#until nc -vzw 2 $ipExt 22; do sleep 1; done
done

#refreshin db ip
db_host=`echo "$rowOutput" | jq '."ip-db-int".value[]' -r`
sed -E 's/(db_host: )([0-9.]+)?/\1'$db_host'/g' -i ./*.yml
}



while true; do
  case "$1" in
    -l | --list ) make_json_list; terraform_output;exit 0 ;;
    -h | --host ) HOST="$2"; make_json_host $HOST; break ;;
    -y | --yaml ) make_yaml; terraform_output; break ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done


exit 0
