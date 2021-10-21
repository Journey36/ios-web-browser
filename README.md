# 웹 브라우저

> Webkit을 사용한 웹 브라우저 앱

<img width="350" alt="default" src="https://user-images.githubusercontent.com/73573732/129638448-b19e4cd5-805a-410e-bf4f-f01b91f222f1.gif">   <img width="350" alt="dynamicType" src="https://user-images.githubusercontent.com/73573732/129639523-88f569be-cec3-47c6-9c69-fe0c1a87d606.gif">

<br/>



## 목차

- [웹 브라우저](#웹-브라우저)
  - [목차](#목차)
  - [함께한 사람들](#함께한-사람들)
  - [앱 구현 과정 및 트러블 슈팅](#앱-구현-과정-및-트러블-슈팅)
    - [UI 및 기능 구현](#ui-및-기능-구현)
      - [해당 부분에서 했던 고민점들](#해당-부분에서-했던-고민점들)
    - [주소 자동 변경](#주소-자동-변경)
      - [해당 부분에서 했던 고민점들](#해당-부분에서-했던-고민점들-1)
    - [국제화](#국제화)
      - [해당 부분에서 했던 고민점들](#해당-부분에서-했던-고민점들-2)
    - [접근성 적용](#접근성-적용)
      - [해당 부분에서 했던 고민점들](#해당-부분에서-했던-고민점들-3)

<br/>



## 함께한 사람들

- 팀원 및 기간: 개인으로 2020.11.09 ~ 2020.11.15, 총 1주 동안 진행
- 코드 리뷰어: [yagom](https://github.com/yagom)
- 학습 키워드: `Webkit`, `TextField`, `UIResponder`, `UIAlertController`, `ATS`

<br/>



## 앱 구현 과정 및 트러블 슈팅

### UI 및 기능 구현

|                                                     주소창 이동 및 로딩 시 인디케이터 표시                                                     |                                                                   당겨서 새로고침                                                                   |                                                                   이전, 다음 페이지 이동 및 새로고침                                                                   |
| :--------------------------------------------------------------------------------------------------------------------------------------------: | :-------------------------------------------------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| <img width="300" alt="주소창이동" src="https://user-images.githubusercontent.com/73573732/138051524-a65f1548-aab6-41bb-a15b-24148266bd10.gif"> | <img width="300" alt="당겨서 새로고침" src="https://user-images.githubusercontent.com/73573732/138127015-6b2bf4e7-adce-4e20-bfab-8cbfff4d81bf.gif"> | <img width="300" alt="이전, 다음 페이지 이동 및 새로고침" src="https://user-images.githubusercontent.com/73573732/138052769-aae6a714-2ffd-43cd-ac18-a4acb79be6a7.gif"> |
|                              주소창에 주소 입력 후 해당 페이지로 이동<br/> 페이지가 로드 중일 때 인디케이터 표시                               |                                                           웹 뷰를 아래로 당겨서 새로고침                                                            |                                                                  이전, 다음 페이지로 이동 및 새로고침                                                                  |

#### 해당 부분에서 했던 고민점들

|                                    문제                                     |
| :-------------------------------------------------------------------------: |
| 다른 유효한 주소는 접속이 가능한데, 네이버는 접속이 안되는 이유는 무엇일까? |

네이버는 `https`로 연결됨에도 불구하고 `ATS`를 해제하지 않으면 페이지에 연결이 되지않는 문제가 있었습니다. 아직 특별한 이유를 찾지 못했는데, 네이버 측의 문제가 아닐까 생각됩니다. 그래서 네이버에 접속하기 위해 `ATS` 를 해제해줘야했는데, 전체를 다 해제하는 것은 권장되지 않으므로, 네이버만 HTTP 접속에 대해 허용하도록 추가했습니다. ([`ATS` 정리](https://github.com/Journey36/TIL/blob/main/iOS/Network/ATS.md))<br/>



|                            고민                             |
| :---------------------------------------------------------: |
| 사용자에게 Activity Indicator를 나타내주는 이유는 무엇일까? |

[Human Interface Guideline](https://developer.apple.com/design/human-interface-guidelines/ios/controls/progress-indicators/)에 의하면 Activity Indicator는 복잡한 데이터를 로드하거나 동기화하는 등 정량화할 수 없는 작업을 사용자에게 알려주는 역할을 한다고 명시되어 있습니다. Activity Indicator가 없으면, 사용자가 현재 페이지가 로드가 되고 있는 것인지, 프로세스가 멈춘 것인지 확인하기 어렵습니다. 그렇기 때문에 프로세스가 진행 중이라면 Indicator가 계속 회전함으로써 프로세스 진행을 알리는 것이 필요합니다.

<br/>



|                               문제                                |                                                                        현상                                                                         |
| :---------------------------------------------------------------: | :-------------------------------------------------------------------------------------------------------------------------------------------------: |
| 당겨서 새로고침 시, UIActivityIndicatorView가 두 번 표시되는 현상 | <img width="300" alt="인디케이터 중복" src="https://user-images.githubusercontent.com/73573732/138051031-827c9071-54ca-4f8f-839b-49587956c5b2.gif"> |

기존에 `UIRefreshControl`을 구현한 뒤, 새로고침 했을 때, 다음과 같이 Activity Indicator를 두 번 표시하는 현상이 있었습니다. 그 원인은

```swift
func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {...}
```

위 메소드에서 `UIActivityIndicatorView`가 애니메이션되도록 구현했기 때문입니다. 즉, `UIRefreshControl`과 연결된 `targetAction` 로직에 의해 새로 페이지가 로드되면서 위 메서드를 다시 호출했기 때문에 이와 같은 현상이 일어난 것입니다. 해결을 위해 '당겨서 새로고침' 상태를 나타내는 `isPullDownRefreshing` 변수를 하나 생성했고, 해당 변수의 값에 따라  `UIRefreshControl`이 동작 중일 때는 해당 델리게이트 메서드가 호출되더라도 바로 반환되도록 구현했습니다.

```swift
private var isPullDownRefreshing = false

// ...

@objc private func pullDownRefresh(_ refreshControl: UIRefreshControl) {
	DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
		while !self.webView.isLoading {
			self.isRefreshing = true
			self.webView.reload()
		}

		refreshControl.endRefreshing()
	}
}

// ...

func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    if isPullDownRefreshing == true {
		isPullDownRefreshing = false
        return
	}

	loadingIndicator.startAnimating()
}
```

<br/>



### 주소 자동 변경

|                                                               현재 페이지 주소 표시                                                                |
| :------------------------------------------------------------------------------------------------------------------------------------------------: |
| <img width="300" alt="주소 자동 변경" src="https://user-images.githubusercontent.com/73573732/138133217-5a449e20-1b63-4bd6-8770-f7abff0c2bde.gif"> |
|                                                         이동한 페이지의 주소 및 경로 표시                                                          |

#### 해당 부분에서 했던 고민점들

|                          고민                          |
| :----------------------------------------------------: |
| 텍스트를 유효한 URL로 만들기 위해서는 어떻게 해야할까? |

```swift
private func checkValidation(to url: String) -> Bool {
    let range = NSRange(location: 0, length: url.count)
    guard let regExpForValidURL = try? NSRegularExpression(pattern: "http(s)://") 
    	else { return false }
    
    return regExpForValidURL.firstMatch(in: url, range: range) != nil 
		? true : false
}
```

<br/>



### 국제화

|                                                                영어(기본)                                                                |                                                                   한국어                                                                   |                                                                   일본어                                                                   |
| :--------------------------------------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------------------------------: |
| <img width="300" alt="영어" src="https://user-images.githubusercontent.com/73573732/138136428-e1ce3542-20b9-48f6-a203-58d9015ca0a3.gif"> | <img width="300" alt="한국어" src="https://user-images.githubusercontent.com/73573732/138299280-6a5439a2-679c-454f-8ca1-862c86bb8a33.gif"> | <img width="300" alt="일본어" src="https://user-images.githubusercontent.com/73573732/138136459-8897ccbb-e4be-45ae-ba38-26b0c9f0dcd4.gif"> |
|                                                  플레이스홀더 및 경고창 등 영어로 표기                                                   |                                                  플레이스홀더 및 경고창 등 한국어로 표기                                                   |                                                  플레이스홀더 및 경고창 등 일본어로 표기                                                   |

#### 해당 부분에서 했던 고민점들

|                                         고민                                         |
| :----------------------------------------------------------------------------------: |
| 기존에 사용하던 문자열 코드를 모두  `NSLocalizedString(_:comment:)`로 변경해야 할까? |

String을 연산 프로퍼티로 확장하여 사용할 수 있습니다.

```swift
extension String 
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
```

결국 이렇게 해도 기존의 문자열에 모두 적용해줘야 합니다. 하지만 기존 문자열 리터럴을 `NSLocalizedString(_:comment:)` 로 변경하는 것보다, 끝에 프로퍼티를 추가하는 방식이 확장성도 좋고 더 쉽게 접근할 수 있어서 더 편리한 방법이라고 생각합니다. 해당 프로젝트에서는 포맷을 적용하지 않았지만, 포맷이 필요한 경우는 `String(format:)`을 적용할 수 있습니다.

```swift
extension String {
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
    
    func localized(with argument: CVarArg = [], comment: String = "") -> String {
        return String(format: self.localized(comment: comment), argument)
    }
}

let uploadTime = "%d seconds ago" // "5 seconds ago"
let uploadTimeForKorean = "%d seconds ago".localized(with: 5) // "5분 전"
```

<br/>



### 접근성 적용

|                                                                  다이나믹 타입 적용                                                                   |                                                                   Accessibility Label 적용                                                                   |
| :---------------------------------------------------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------------------------------------------------: |
| <img width="300" alt="dynamic type 적용" src="https://user-images.githubusercontent.com/73573732/138311169-4024b831-1b9e-4ea2-810a-f1a4d882003e.gif"> | <img width="650" alt="accessibility label 적용" src="https://user-images.githubusercontent.com/73573732/138308346-2c3f862a-f558-4241-be28-89f7c356c828.gif"> |
|                                                  다이나믹 타입 적용에 의한 텍스트 및 버튼 크기 증가                                                   |                                                     추후 VoiceOver 구현을 위한 Accessibility Label 설정                                                      |

#### 해당 부분에서 했던 고민점들

| 고민 |      |
| ---- | ---- |
|  |      |



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

-   Accessibility Insepctor attribute 적용한 것ㅁ
