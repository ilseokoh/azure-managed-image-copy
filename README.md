## Azure VM 이미지 
Azure Portal을 통해서 Managed Disk로 생성한 VM을 이미지(Managed Image)로 만들 수 있다. [Azure에서 일반화된 VM의 관리 이미지 만들기 (윈도우 서버, PowerShell)](https://docs.microsoft.com/ko-kr/azure/virtual-machines/windows/capture-image-resource), [가상 컴퓨터 또는 VHD의 이미지를 만드는 방법 (리눅스 Azure CLI 2.0)](https://docs.microsoft.com/ko-kr/azure/virtual-machines/linux/capture-image) 문서를 참조하면 이미지를 생성할 수 있고 같은 구독과 지역에서 그 이미지로 다시 VM을 만들 수 있다. 이렇게 하면 VM에 설치되어 있는 미들웨어, 프레임워크, 애플리케이션까지 모두 그대로 복사하듯이 VM을 만들 수 있다. 

하지만 2017년 9월 15일 현재 이렇게 만든 이미지를 다른 구독이나 다른 지역으로 복사하는 기능이 제공되지 않는다. 현재 개발중.

여기서 설명되는 스크립트는 OS 디스크만 가지고 있는 VM에 대한 내용이고 데이터 디스크가 여러개 있는 경우는 같은 방법으로 반복하면 된다. 

## Azure VM을 그대로 다른 지역이나 다른 구독으로 이동 
디스크 Export를 이용하면 조금 복잡하지만 가능하다. 순서는 아래와 같다. 

1. (옵션) 포탈에서 대상이 되는 VM의 디스크를 Snapshot으로 백업한다. ([참조문서](https://docs.microsoft.com/ko-kr/azure/virtual-machines/windows/snapshot-copy-managed-disk))
1. VM을 일반화 (Generalize)한다. (참조문서 [윈도우 서버](https://docs.microsoft.com/ko-kr/azure/virtual-machines/windows/capture-image-resource), [리눅스](https://docs.microsoft.com/ko-kr/azure/virtual-machines/linux/capture-image))
1. (옵션) 포탈에서 VM에서 이미지를 만들고 VM으로 잘 생성되는지 테스트한다. 
1. 포탈에서 디스크를 찾아 Export 메뉴로 스토리지 SAS URL 생성
1. 타겟이 되는 지역에 리소스그룹과 스토리지를 하나 만들어준다. 
1. Powershell 또는 Azure CLI 2.0을 이용하여 스크립트 실행. 스크립트 상단에 변수를 설정해야 한다. 

스크립트에서는 다음과 같은 작업을 한다. 
1. 타겟 지역에 만들어 둔 스토리지의 키와 SAS 토큰 생성 
1. 컨테이너 생성 
1. 디스크(VHD파일) 복사 시작 
1. 디스크 복사 진행 체크 
1. 복사한 VHD 파일에서 Managed Disk 생성 
1. 포탈에서 새로운 VM 생성 
1. 이미지와 스토리지는 삭제

## 유튜브 데모 동영상 링크 
전체 프로세스를 동영상으로 제공합니다. 
[유튜브: Azure 가상머신 이미지 이동](https://www.youtube.com/watch?v=5n4256-z16o)

## 참고자료 

[가상 컴퓨터 또는 VHD의 이미지를 만드는 방법 (linux)](https://docs.microsoft.com/ko-kr/azure/virtual-machines/linux/capture-image)

[Install Azure CLI 2.0](https://docs.microsoft.com/ko-kr/cli/azure/install-azure-cli?view=azure-cli-latest)

[Install and configure Azure PowerShell](https://docs.microsoft.com/ko-kr/powershell/azure/install-azurerm-ps?view=azurermps-4.4.0)

[백업된 Snapshot에서 새로운 VM 생성](https://github.com/ilseokoh/azuresnapshot2vm)

[New-AzureRmImageConfig](https://docs.microsoft.com/en-us/powershell/module/azurerm.compute/new-azurermimageconfig?view=azurermps-4.4.0)