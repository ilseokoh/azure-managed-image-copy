# Azure VM 이미지 
Azure Portal, Powershell, Azure CLI 2.0을 통해서 VM을 통째로 이미지(Managed Image)로 만들 수 있다. [Azure에서 일반화된 VM의 관리 이미지 만들기 (윈도우 서버, PowerShell)](https://docs.microsoft.com/ko-kr/azure/virtual-machines/windows/capture-image-resource), [가상 컴퓨터 또는 VHD의 이미지를 만드는 방법 (리눅스 Azure CLI 2.0)](https://docs.microsoft.com/ko-kr/azure/virtual-machines/linux/capture-image)문서를 참조하면 이미지를 생성할 수 있고 같은 구독과 지역에서 그 이미지로 다시 VM을 만들 수 있다. 이렇게 하면 VM에 설치되어 있는 미들웨어, 프레임워크, 애플리케이션까지 모두 그대로 복사하듯이 VM을 만들 수 있다. 

하지만 2017년 9월 15일 현재 이렇게 만든 이미지를 다른 구독이나 다른 지역으로 복사하는 기능이 제공되지 않는다. 현재 개발중.

# VM을 그대로 다른 지역이나 다른 구독으로 옮기고 싶다. 
이미지 Export를 이용하면 조금 복잡하지만 가능하다. 순서는 아래와 같다. 

1. Azure Portal에서 Image생성 (포탈)
1. Azure Portal에서 Image를 복사할 수 있도록 스토리지 SAS URL 생성 (포탈 Export 기능)
1. URL을 이용하여 소스 구독/지역에서 타겟 구독/지역으로 복사 (Powershell 또는 Azure CLI 2.0)
1. 복사된 VHD 파일을 이미지로 변환 (Powershell 또는 Azure CLI 2.0)
1. 이미지에서 VM 생성(포탈)

# 유튜브 동영상 링크 
전체 프로세스를 동영상으로 제공합니다. 

# 참고자료 