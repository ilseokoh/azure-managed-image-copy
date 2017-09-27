Login-AzureRmAccount

# 타켓 리소스 그룹 
$targetResourceGroupName="TargetGroup"
# 타겟 스토리지 어카운트 이름 
$targetStorageAccountName="targettmp"
# 새로 생성할 컨테이너 이름 
$targetImageStorageContainerName="images"
# 생성할 이미지 이름 
$targetImageName="TargetImage"
# 포탈에서 Export 메뉴로 만든 SAS URL 
$srcSasUrl="https://md-g23zjjmrllxj.blob.core.windows.net/zx45ct4r2pdv/abcd?sv=2016-05-31&sr=b&si=f7b6eb11-3249-48f2-8507-1bed43bccd5f&sig=5mMvgETuenriMQ%2B%2B%2F79%2BCjhHJ8b%2FlAlrWF9FwPMADlE%3D"

$targetRegion = "koreacentral"


#
$targetStorageContext = (Get-AzureRmStorageAccount -ResourceGroupName $targetResourceGroupName -Name $targetStorageAccountName).Context
New-AzureStorageContainer -Name $targetImageStorageContainerName -Context $targetStorageContext -Permission Container
 
# Use the SAS URL to copy the blob to the target storage account (and thus region)
$imageBlobName = $targetImageName + "-osdisk.vhd"
Start-AzureStorageBlobCopy -AbsoluteUri $srcSasUrl -DestContainer $targetImageStorageContainerName -DestContext $targetStorageContext -DestBlob $imageBlobName
Get-AzureStorageBlobCopyState -Container $targetImageStorageContainerName -Blob $imageBlobName -Context $targetStorageContext -WaitForComplete


 # 복사한 VHD 파일에서 Managed Image를 만든다. 
$imageVhdUrl = $targetStorageContext.BlobEndPoint + $targetImageStorageContainerName + "/" + $imageBlobName
$imageConfig = New-AzureRmImageConfig -Location $targetRegion

Set-AzureRmImageOsDisk -Image $imageConfig -OsType Linux -OsState Generalized -BlobUri $imageVhdUrl
 
New-AzureRmImage -ResourceGroupName $targetResourceGroupName -ImageName $targetImageName -Image $imageConfig