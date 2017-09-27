#!/bin/bash
# azure CLI 2.0 installation: https://docs.microsoft.com/ko-kr/cli/azure/install-azure-cli?view=azure-cli-latest

targetResourceGroupName="TargetGroup"
targetStorageAccountName="targettmp"
targetImageStorageContainerName="images"
targetImageName="TargetImage"
# 포탈에서 Export 메뉴로 만든 SAS URL 
srcSasUrl="https://md-g23zjjmrllxj.blob.core.windows.net/zx45ct4r2pdv/abcd?sv=2016-05-31&sr=b&si=0e9a41b9-b058-4fc6-b2f2-01cdc085b449&sig=0Sn8Zxo9Jf1yW6wWdYDLucLs8FS%2BA5tjeJpxzSYu0IM%3D"

# 다른 지역/다른 구독에 있는 Azure Storage Account
targetStorageAccountKey=$(az storage account keys list -g $targetResourceGroupName --account-name $targetStorageAccountName --query "[:1].value" -o tsv)
storageSasToken=$(az storage account generate-sas --expiry 2017-10-01'T'12:00'Z' --permissions aclrpuw --resource-types sco --services b --https-only --account-name $targetStorageAccountName --account-key $targetStorageAccountKey -o tsv)

# Container 생성 
echo "create a new container"
az storage container create -n $targetImageStorageContainerName --account-name $targetStorageAccountName --sas-token $storageSasToken

# 복사 시작
echo "Copy is Started"
imageBlobName="$targetImageName-osdisk.vhd"
copyId=$(az storage blob copy start --source-uri $srcSasUrl --destination-blob $imageBlobName --destination-container $targetImageStorageContainerName --sas-token $storageSasToken --account-name $targetStorageAccountName)

# 복사 진행 모니터링
percent=0
while [ $percent -lt 100 ] 
do
    status=$(az storage blob show --container-name $targetImageStorageContainerName -n $imageBlobName --account-name $targetStorageAccountName --sas-token $storageSasToken --query "properties.copy.progress")
    status=$(echo "$status" | sed -e 's/^"//' -e 's/"$//')
    echo $status
    item=$(echo $status | cut -f1 -d "/")
    total=$(echo $status | cut -f2 -d "/")
    echo $item
    echo $total
    percent=$(awk "BEGIN { pc=100*${item}/${total}; i=int(pc); print (pc-i<0.5)?i:i+1 }")
    echo -ne $percent
    sleep 1
done
echo "Copy Done"


# 복사한 VHD 파일에서 Managed Image를 만든다. 
hostname=$(az storage account show --name $targetStorageAccountName --resource-group $targetResourceGroupName --query "primaryEndpoints.blob")
hostname=$(echo "$hostname" | sed -e 's/^"//' -e 's/"$//')
imageVhdUrl="$hostname$targetImageStorageContainerName/$imageBlobName"
echo "VHD Url: $imageVhdUrl"
az image create --resource-group $targetResourceGroupName --name $targetImageName --source $imageVhdUrl --os-type Linux
echo "Finished successfully"
