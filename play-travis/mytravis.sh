#!/bin/bash
set -e

echo 'Hello Travis'

#украдем версии у преподаватаелей
PACKER_VER=1.2.4
TERRAFORM_VER=0.11.7
TFLINT_VER=0.7.0
ANSIBLE_VER=2.6.0
ANSLINT_VER=3.4.23
DOCKERVERSION=18.03.0-ce
DOCKERCOMPOSE_VER=1.21.0


#украдем зависимости у преподаватаелей
sudo pip install --upgrade pip

sudo pip install ansible==${ANSIBLE_VER} ansible-lint==${ANSLINT_VER}

mkdir ./tmp && \
cd ./tmp && \
curl -O https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip && \
unzip terraform_${TERRAFORM_VER}_linux_amd64.zip && \
rm terraform_${TERRAFORM_VER}_linux_amd64.zip && \
sudo mv terraform /usr/bin && \
sudo chmod +x /usr/bin/terraform #&& \
#curl -OL https://github.com/wata727/tflint/releases/download/v${TFLINT_VER}/tflint_linux_amd64.zip && \
#unzip tflint_linux_amd64.zip && \
#rm tflint_linux_amd64.zip && \
#sudo mv tflint /usr/bin && \
#sudo chmod +x /usr/bin/tflint && \
cd ..

echo 'blablalbla appuser' > ~/.ssh/appuser.pub

#packer validate для всех шаблонов

for i in `find . -type f -name '*.json' -path './packer/*'`;
do 
	echo $i' checking.........'
	packer validate -var-file=packer/variables.json.example packer/db.json
done


# terraform validate и tflint для окружений stage и prod
echo 'terraform/prod checking.........'
cd terraform/prod
terraform init -backend=false && terraform validate -var-file=terraform.tfvars.example
cd .. && cd ..
echo 'terraform/stage checking........'
cd terraform/stage
terraform init -backend=false && terraform validate -var-file=terraform.tfvars.example
cd .. && cd ..


# ansible-lint для плейбуков Ansible
for i in `find . -type f -name '*.yml' -path './ansible/playbooks/*'`;
do
    echo $i' checking.........'
	ansible-lint $i --exclude=roles/jdauphant.nginx --exclude=*/credentials.yml
done

#в README.md добавлен бейдж с статусом билда

echo 'Bage checking.........'
Bage=`cat README.md | grep -E '.*Build Status.*ansible-3.*'`
if [ -z "$Bage" ]; then
	exit 1
else
	echo "Successfull"
fi
