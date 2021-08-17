# 웹 브라우저

> Webkit을 사용한 웹 브라우저 앱

<img width="350" alt="default" src="https://user-images.githubusercontent.com/73573732/129638448-b19e4cd5-805a-410e-bf4f-f01b91f222f1.gif">   <img width="350" alt="dynamicType" src="https://user-images.githubusercontent.com/73573732/129639523-88f569be-cec3-47c6-9c69-fe0c1a87d606.gif">



## 1. 함께한 사람들

- 팀원 및 기간: 개인으로 2020.11.09 ~ 2020.11.15, 총 1주 동안 진행
- 코드 리뷰어: [yagom](https://github.com/yagom)
- 학습 키워드: `Webkit`, `TextField`, `UIResponder`, `UIAlertController`, `ATS`



## 2. 앱 상세



## 3. 앱 구현 과정 및 트러블 슈팅

### 3.1 UI 및 기능 구현

 주소창에 주소를 입력한 후, `이동` 버튼을 누르면 해당 페이지로 이동하고, 하단에 툴바를 두어 내부에 새로고침, 이전 및 다음 페이지로 갈 수 있도록 버튼을 구현했습니다. 그리고 페이지를 로드 중일 때, `UIActivityIndicatorView`가 나타나도록 구현했습니다.

<***해당 부분에서 했던 고민점들***>

* 다른 유효한 주소는 접속이 가능한데, 네이버로 접속이 안되는 이유가 뭘까?
  * 네이버는 `https`로 연결됨에도 불구하고 `ATS`를 해제하지 않으면 페이지에 연결이 되지않는 문제가 있었습니다. 아직 특별한 이유를 찾지 못했는데, 네이버 측의 문제가 아닐까 생각됩니다. 그래서 네이버에 접속하기 위해 `ATS` 를 해제해줘야했는데, 전체를 다 해제하는 것은 권장되지 않으므로, 네이버만 HTTP 접속에 대해 허용하도록 추가했습니다. `ATS` 에 대한 자료는 [TIL](https://github.com/Journey36/TIL/blob/main/iOS/ATS.md) 레포에 정리되어 있습니다.

### 3.2 주소 자동 변경

 `WKNavigationDelegate`의 `webView(_:didFinish:)` 메서드를 통해 주소창에 현재 주소가 나타나도록 했고, 내부에 이전 페이지와 다음 페이지로 넘어갈 수 있을 때 이전 버튼, 다음 버튼이 활성화되도록 함께 구현했습니다.

### 3.3 ActivityIndicator

 `UIActivityIndicatorView`를 페이지 로딩 중 나타나도록 구현했습니다.

<***해당 부분에서 했던 고민점들***>

-   activity indicator를 넣는 이유는 무엇일까?
    -   H.I.G에 의하면 activity indicator는 복잡한 데이터를 로드하거나 동기화하는 등 정량화할 수 없는 작업을 사용자에게 알려주는 역할을 한다고 명시되어 있습니다. 해당 뷰가 없으면, 사용자가 현재 페이지가 로드가 되고 있는 것인지, 프로세스가 멈춘 것인지 확인하기 어렵습니다. 그렇기 때문에 프로세스가 진행 중이라면 indicator가 계속 회전함으로써 프로세스 진행을 알리는 것이 필요합니다.

### 3.4 국제화

 국제화 학습을 위해서 영어를 기본으로, 한국어, 일본어를 지원하고자 했습니다.

<***해당 부분에서 했던 고민점들***>

-   기존 문자열을 사용하던 코드를 모두 `NSLocalizedString(_:comment:)` 로 모두 변경해주어야 하는가?

    -   보통 현업에서는 `String`을 확장해서 연산 프로퍼티로 만들어서 사용한다는 글을 봤다.

        ```swift
        extension String {
            /// Apply `NSLocalizedString` to target string.
            var localized: String {
                return NSLocalizedString(self, comment: "")
            }
        }
        ```

        결국 이렇게 해도 기존의 문자열에 적용해줘야하지만, 기존 문자열 리터럴을 `NSLocalizedString(_:comment:)` 로 만들어주는 것보다 첨자로 추가해주기만 하면 되므로 조금 더 편리한 방법이라고 생각한다.

### 3.5 Dynamic Type 적용

 저시력자를 위한 다이나믹 타입을 적용해봤습니다. 그리고 사용자가 접근성 다이나믹 타입 사이즈를 사용하고 있을 때, 내비게이션 바 또는 탭 바에 있는 버튼을 누르면 해당 아이콘과 설명이 크게 팝업되도록 시스템 아이콘과 타이틀을 지정해줬습니다.

<***해당 부분에서 했던 고민점들***>

-   접근성을 적용하려고 할 때, 주소창과 검색 버튼을 어떤 방식으로 구현하는 것이 좋을까?

    -   간단하게 UITextField와 UIButton을 UIStackView를 통해 묶어서 구현해도 된다고 생각했습니다. 하지만 접근성을 고려하기 시작했을 때, 어떤 방법이 더 좋을지 고민했습니다. 그러다 [WWDC17 Design For Everyone](https://developer.apple.com/videos/play/wwdc2017/806/) 영상에서 iOS 11부터 내비게이션 바 또는 탭 바처럼 내부의 아이템의 레이아웃을 개발자 임의로 변경할 수 없는 것들에 대해 특별한 UI를 구현해놨다는 것을 봤습니다. 그래서 만약 사용자가 다이나믹 타입의 접근성 사이즈를 사용하고 있다면, 내비게이션 바 또는 탭 바의 버튼을 길게 눌렀을 때 아래 이미지처럼 해당 버튼이 확대되어 어떤 버튼인지 알 수 있도록 구현해봤습니다.

        <img width="240" alt="accessibility type for english" src="https://user-images.githubusercontent.com/73573732/129690514-1c08379d-3378-4cd5-9c06-ad3e5d582031.png"> <img width="240" alt="accessibility type for korean" src="https://user-images.githubusercontent.com/73573732/129716546-16cb5608-0d23-433c-bba8-e26946b4414f.png"> <img width="240" alt="accessibility type for japanese" src="https://user-images.githubusercontent.com/73573732/129716725-99818104-77da-4345-8e13-5a2d408896d5.png">

-   텍스트 필드가 내비게이션 바 내부에 포함된 경우에는 어떻게 동적으로 크기를 조절할 수 있을까?

    -   내비게이션 바 또는 탭바에서는 오토 레이아웃을 통해 레이아웃을 조절할 수 없게 설정되어있었습니다. 그래서 다이나믹 타입을 적용했을 때 주소창 UI가 깨지는 현상이 있었습니다. 하지만 뷰가 서브뷰의 레이아웃을 변경하기 직전에 호출되는 `viewWillLayoutSubviews()`에서 주소창의 `frame`을 변경해주는 작업으로 문제를 해결했습니다.

        ```swift
        private func adjustTextFieldLayout() {
          var frame: CGRect = urlTextField.frame
          frame.size.width = view.frame.width
          urlTextField.frame = frame
        }
        
        // ....
        
        override func viewWillLayoutSubviews() {
          super.viewWillLayoutSubviews()
          adjustTextFieldLayout()
        }
        ```

        
