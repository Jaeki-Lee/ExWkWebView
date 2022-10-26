//
//  ExWKWebViewController.swift
//  EXWKWebView
//
//  Created by trost.jk on 2022/10/25.
//

import Foundation
import UIKit
import WebKit
import SnapKit
import Then

class ExWKWebViewController: UIViewController {
    
    var url: String = ""
    
    init(url: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var headers: [String: String] {
        let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        var header = ["Content-Type": "application/json"]
        header["device-uuid"] = UUID().uuidString
        header["device-os-version"] = UIDevice.current.systemVersion
        header["device-device-manufacturer"] = "apple"
        header["version"] = bundleVersion
        return header
    }

    private var authCookie: HTTPCookie? {
        let cookie = HTTPCookie(properties: [
            .domain: "https://ios-development.tistory.com/",
            .path: "748",
            .name: "CID_AUTH",
            .value: "test-access-token",
            .maximumAge: 7200, // Cookie의 유효한 지속시간
            .secure: "TRUE"
        ])
        return cookie
    }
    
    private var webViewConfig: WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        let wkUserContentController = WKUserContentController()
        //webview 에 cookie 저장
        if let authCookie = authCookie {
            //webview 에 대한 데이터 device disk 공간
//            let dataStore = WKWebsiteDataStore.default()
            //webview 에 대한 데이터 device 메모리 공간
            let dataStore = WKWebsiteDataStore.nonPersistent()
            dataStore.httpCookieStore.setCookie(authCookie)
            config.websiteDataStore = dataStore
        }
        
        //webview 에 message 삽입
        wkUserContentController.add(self, name: "AmessageKey")
        wkUserContentController.add(self, name: "BmessageKey")
        config.userContentController = wkUserContentController
        
        //한개의 webview 에 여러 웹을 랜더링 할때 싱글스레드로 작동하는게 유리하고 그렇게 해주는 코드?
        config.processPool = WKProcessPool()
        
        return config
    }
    
    private lazy var webView = WKWebView(frame: .zero, configuration: self.webViewConfig).then {
        $0.backgroundColor = .clear
        $0.scrollView.backgroundColor = .clear
        $0.isOpaque = false
        $0.allowsBackForwardNavigationGestures = true
        $0.navigationDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
//    func onDismiss(result: [String : String]) {
//        if result["id"] == "/mobile/partner/search/filter" {
//            var param = result
//            param.removeValue(forKey: "id")
//            if let jsonData = try? JSONSerialization.data(withJSONObject: param),
//               let jsonString = String.init(data: jsonData, encoding: .utf8)
//               {
//                self.evaluateJavaScript("searchPartnersByOption(\(jsonString))")
//            }
//
//        }
//    }
    
    func evaluateJavaScript(_ script: String) {
        //현재 webview 에 띄어져 있는 페이지의 script 이름의 함수를 호출. 파라미터도 넣을수 있다. 위 onDismiss 부분 참고
        self.webView.evaluateJavaScript(script) { _, error in
            print(error.debugDescription)
        }
    }
    
    
}

extension ExWKWebViewController: WKNavigationDelegate {
    /// WKWebView에서 다른곳으로 이동할때마다 호출되는 메소드 (didFinish와 짝꿍)
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("show loading indicator ...")
    }
    
    /// WKWebView에서 다른곳으로 이동된 후에 호출되는 메소드 (didCommit와 짝꿍)
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("hide loading indicator ...")
    }
    
    /// webview 에서 웹페이지 이동시 (링크 클릭 다른 페이지 이동..) 해당 url 을 webview 에서 열지, 열지 않을지 판단 decisionHandler(.allow / .cancel)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        if let url = navigationAction.request.url, url.scheme == "mailto" || url.scheme == "tel" {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            // url이 mailto, tel인 경우, webView에서 열리지 않도록 .cancel
            decisionHandler(.cancel)
            return
        }

        // url이 네이티브에서 여는작업이 아닌 경우, webView에서 열리도록 .allow
        decisionHandler(.allow)
    }
}

extension ExWKWebViewController: WKScriptMessageHandler {
    //Web 으로 부터 message 를 받아서 해당 message 에 대한것을 네이티브에서 처리
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        //"AmessageKey" 가 넘어왔을때 처리
        if message.name == "AmessageKey" {
            
        //"BmessageKey" 가 넘어왔을때 처리
        } else if message.name == "BmessageKey" {
            
        }
        
    }
}
