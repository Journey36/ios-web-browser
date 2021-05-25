import UIKit
import WebKit

final class ViewController: UIViewController {
    //MARK:- IBOutlets
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var urlSearchButton: UIButton!
    @IBOutlet weak var moveBackwardsButton: UIBarButtonItem!
    @IBOutlet weak var moveForwardButton: UIBarButtonItem!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    //MARK:- IBActions
    @IBAction func moveToURL(_ sender: UIButton) {
        guard var inputURLString = urlTextField.text,
              !inputURLString.isEmpty else {
            presentErrorAlert(with: .emptyURL)
            return
        }

        if !checkValidation(to: inputURLString) {
            inputURLString = "https://" + inputURLString
        }

        presentWebPage(inputURLString)
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

    //MARK:- Methods
    private func presentWebPage(_ url: String) {
        guard let targetURL = URL(string: url) else { return }

        let request = URLRequest(url: targetURL)
        urlTextField.endEditing(true)
        webView.load(request)
    }

    private func setKeyboardAttribute() {
        urlTextField.keyboardType = UIKeyboardType.URL
        urlTextField.autocorrectionType = UITextAutocorrectionType.no
        urlTextField.returnKeyType = UIReturnKeyType.go
        urlTextField.clearButtonMode = UITextField.ViewMode.whileEditing
    }

    private func checkValidation(to url: String) -> Bool {
        let range = NSRange(location: 0, length: url.count)
        guard let regExpForValidURL = try? NSRegularExpression(pattern: "http(s)?://") else { return false }

        return regExpForValidURL.firstMatch(in: url, range: range) != nil ? true : false
    }

    private func presentErrorAlert(with errorMessage: ErrorMessage) {
        let title: String = "경고".localized
        let alert: UIAlertController = UIAlertController(title: title, message: errorMessage.rawValue.localized, preferredStyle: .alert)
        let ok: String = "확인".localized
        let okAction: UIAlertAction = UIAlertAction(title: ok, style: .default) { _ in
            self.urlTextField.becomeFirstResponder()
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setKeyboardAttribute()
        webView.navigationDelegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let homePage: String = "https://www.google.com"
        presentWebPage(homePage)
    }
}

//MARK:- Extensions
//MARK: Methods
extension ViewController {
    enum ErrorMessage: String {
        case emptyURL = "주소창에 이동하고자 하는 페이지의 주소를 입력해주세요."
        case pageNotFound = "요청하신 페이지를 찾을 수 없습니다."
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
        presentErrorAlert(with: .pageNotFound)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        urlTextField.text = webView.url?.absoluteString
        moveBackwardsButton.isEnabled = webView.canGoBack
        moveForwardButton.isEnabled = webView.canGoForward
        loadingIndicator.stopAnimating()
    }
}

extension String {
    /// Apply `NSLocalizedString` to target string.
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
