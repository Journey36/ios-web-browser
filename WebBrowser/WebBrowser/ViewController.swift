import UIKit
import WebKit

final class ViewController: UIViewController {
    //MARK:- IBOutlets
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var urlSearchButton: UIBarButtonItem!
    @IBOutlet weak var moveBackwardsButton: UIBarButtonItem!
    @IBOutlet weak var moveForwardButton: UIBarButtonItem!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    private let refreshControl = UIRefreshControl()
    private var isRefreshing = false
    
    //MARK:- IBActions
    @IBAction func moveToURL(_ sender: UIBarButtonItem) {
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
        urlTextField.adjustsFontForContentSizeCategory = true
        urlTextField.font = UIFont.preferredFont(forTextStyle: .body)
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
    
    private func adjustTextFieldLayout() {
        var frame: CGRect = urlTextField.frame
        frame.size.width = view.frame.width
        urlTextField.frame = frame
    }

    @objc private func pullDownRefresh(_ refreshControl: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            while !self.webView.isLoading {
                self.isRefreshing = true
                print(self.isRefreshing)
                self.webView.reload()
            }

            refreshControl.endRefreshing()
        }
    }

    private func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(pullDownRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = .label
        webView.scrollView.refreshControl = refreshControl
    }

    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setKeyboardAttribute()
        configureRefreshControl()
        webView.navigationDelegate = self
        urlTextField.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let homePage: String = "https://www.google.com"
        presentWebPage(homePage)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustTextFieldLayout()
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
        loadingIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if isRefreshing == true {
            isRefreshing = false
            return
        }

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
