import UIKit
import WebKit

typealias ActionHandler = (UIAlertAction) -> Void

class ViewController: UIViewController {
    //MARK:- IBOutlets
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var urlSearchButton: UIButton!
    
    //MARK:- IBActions
    @IBAction func moveToURL(_ sender: UIButton) {
        guard let inputURLString = urlTextField.text,
              !inputURLString.isEmpty else {
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
        webView.navigationDelegate = self
        presentHomePage()
    }
}

//MARK:- Extensions
//MARK: Methods
extension ViewController {
    private func presentHomePage() {
        let homePage: String = "https://www.naver.com"

        guard let homeUrl = URL(string: homePage) else { return }

        let request = URLRequest(url: homeUrl)
        webView.load(request)
    }

    private func setKeyboardAttribute() {
        urlTextField.keyboardType = UIKeyboardType.URL
        urlTextField.autocorrectionType = UITextAutocorrectionType.no
        urlTextField.returnKeyType = UIReturnKeyType.go
        urlTextField.clearButtonMode = UITextField.ViewMode.whileEditing
    }

    private func setFirstResponder() -> ActionHandler? {
        urlTextField.becomeFirstResponder()
        return nil
    }

    private func checkURL() {
        let errorMessage: String = "주소창에 이동하고자 하는 페이지의 주소를 입력해주세요."
        let urlCheckingAlert = UIAlertController(title: Alert.title, message: errorMessage, preferredStyle: .alert)
        let okAction: UIAlertAction = UIAlertAction(title: Action.ok, style: .default, handler: setFirstResponder())
        urlCheckingAlert.addAction(okAction)
        present(urlCheckingAlert, animated: true, completion: nil)
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
            let errorMessage: String = "입력한 주소가 올바른 형태가 아닙니다. http:// 또는 https:// 를 주소에 포함시켜주세요!"
            let invalidURLAlert = UIAlertController(title: Alert.title, message: errorMessage, preferredStyle: .alert)
            let okAction: UIAlertAction = UIAlertAction(title: Action.ok, style: .default, handler: setFirstResponder())
            invalidURLAlert.addAction(okAction)
            present(invalidURLAlert, animated: true, completion: nil)
        }
    }
}

//MARK: Protocols
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        moveToURL(urlSearchButton)
        return true
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let errorMessage: String = "요청하신 페이지를 찾을 수 없습니다."
        let pageNotFoundAlert = UIAlertController(title: Alert.title, message: errorMessage, preferredStyle: .alert)
        let okAction: UIAlertAction = UIAlertAction(title: Action.ok, style: .default, handler: setFirstResponder())
        pageNotFoundAlert.addAction(okAction)
        present(pageNotFoundAlert, animated: true, completion: nil)
    }
}
