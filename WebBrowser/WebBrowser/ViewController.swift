import UIKit
import WebKit

class ViewController: UIViewController {
    //MARK:- IBOutlets
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var urlSearchButton: UIButton!
    
    //MARK:- IBActions
    @IBAction func moveToURL(_ sender: UIButton) {
        guard let inputURLString = urlTextField.text else {
            checkURL()
            return
        }
        checkValidation(to: inputURLString)
    }
    
    @IBAction func moveBackwards(_ sender: Any) {
        webView.goBack()
    }

    @IBAction func moveForwards(_ sender: Any) {
        webView.goForward()
    }

    @IBAction func refresh(_ sender: Any) {
        webView.reload()
    }

    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setKeyboardAttribute()
        self.webView.navigationDelegate = self
        presentHomePage()
    }
}

//MARK:- Extensions
//MARK: Methods
extension ViewController {
    private func presentHomePage() {
        guard let homeUrl = URL(string: "https://www.naver.com") else { return }
        let request = URLRequest(url: homeUrl)
        webView.load(request)
    }
    private func setKeyboardAttribute() {
        urlTextField.keyboardType = UIKeyboardType.URL
        urlTextField.autocorrectionType = UITextAutocorrectionType.no
        urlTextField.returnKeyType = UIReturnKeyType.go
        urlTextField.clearButtonMode = UITextField.ViewMode.whileEditing
    }
    private func checkURL() {
        let urlCheckingAlert = UIAlertController(title: "경고", message: "주소창에 이동하고자 하는 페이지의 주소를 입력해주세요.", preferredStyle: .alert)
        let okAction: UIAlertAction = UIAlertAction(title: "확인", style: .default) { _ in
            self.urlTextField.becomeFirstResponder()
        }
        urlCheckingAlert.addAction(okAction)
        self.present(urlCheckingAlert, animated: true, completion: nil)
    }

    private func checkValidation(to url: String) {
        let range = NSRange(location: 0, length: url.count)
        guard let regExpForValidURL = try? NSRegularExpression(pattern: "http(s)?://") else { return }

        if regExpForValidURL.firstMatch(in: url, range: range) != nil {
            guard let url = URL(string: url) else { return }
            let request = URLRequest(url: url)
            urlTextField.endEditing(true)
            webView.load(request)
        } else {
            let invalidURLAlert = UIAlertController(title: "경고", message: "입력한 주소가 올바른 형태가 아닙니다. http:// 또는 https:// 를 넣은 주소로 입력해주세요.", preferredStyle: .alert)
            invalidURLAlert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                self.urlTextField.becomeFirstResponder()
            }))
            self.present(invalidURLAlert, animated: true, completion: nil)
        }
    }
}

//MARK: Protocols
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.moveToURL(urlSearchButton)
        return true
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let pageNotFoundAlert = UIAlertController(title: "경고", message: "요청하신 페이지를 찾을 수 없습니다.", preferredStyle: .alert)
        pageNotFoundAlert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            self.urlTextField.becomeFirstResponder()
        }))
        self.present(pageNotFoundAlert, animated: true, completion: nil)
    }
}
