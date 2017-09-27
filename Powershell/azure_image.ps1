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
$srcSasUrl="https://md-csf3np234j5s.blob.core.windows.net/njm1snksbrrw/abcd?sv=2016-05-31&sr=b&si=795ce90e-5064-48db-b235-e6f2d28d5600&sig=Ae5zUq1IqvpNvezeTPInBgPjjr2hRdBmQwo3g03ksBM%3D"

$targetRegion = "koreacentral"


# 새로운 컨테이너 생성
$targetStorageContext = (Get-AzureRmStorageAccount -ResourceGroupName $targetResourceGroupName -Name $targetStorageAccountName).Context
New-AzureStorageContainer -Name $targetImageStorageContainerName -Context $targetStorageContext -Permission Container
 
# 다른 지역이나 구독의 스토리지로 복사
$imageBlobName = $targetImageName + "-osdisk.vhd"
Start-AzureStorageBlobCopy -AbsoluteUri $srcSasUrl -DestContainer $targetImageStorageContainerName -DestContext $targetStorageContext -DestBlob $imageBlobName
Get-AzureStorageBlobCopyState -Container $targetImageStorageContainerName -Blob $imageBlobName -Context $targetStorageContext -WaitForComplete


 # 복사한 VHD 파일에서 Managed Image를 만든다. 
$imageVhdUrl = $targetStorageContext.BlobEndPoint + $targetImageStorageContainerName + "/" + $imageBlobName
$imageConfig = New-AzureRmImageConfig -Location $targetRegion

Set-AzureRmImageOsDisk -Image $imageConfig -OsType Linux -OsState Generalized -BlobUri $imageVhdUrl
 
New-AzureRmImage -ResourceGroupName $targetResourceGroupName -ImageName $targetImageName -Image $imageConfig