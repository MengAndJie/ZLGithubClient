//
//  ZLReadMeView.swift
//  ZLGitHubClient
//
//  Created by 朱猛 on 2020/10/22.
//  Copyright © 2020 ZM. All rights reserved.
//

import UIKit
import WebKit

@objc protocol ZLReadMeViewDelegate : NSObjectProtocol {
    func onLinkClicked(url : URL?) -> Void
}


class ZLReadMeView: ZLBaseView {
    
    // delegate
    weak var delegate : ZLReadMeViewDelegate?
    
    // view
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var refreshButton: UIButton!
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var webViewHeightConstant: NSLayoutConstraint!
    
    // model
    private var fullName : String?
    private var branch: String?
    
    private var readMeModel : ZLGithubContentModel?
    private var htmlStr : String?
    private var serialNumber : String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.refreshButton.setTitle(ZLLocalizedString(string: "refresh", comment: "刷新"), for: .normal)
        
        self.webView.scrollView.isScrollEnabled = false
        self.webView.contentScaleFactor = 1.0
        self.webView.backgroundColor = UIColor.clear
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        
        self.webView.scrollView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    
    
    func startLoad(fullName: String, branch: String?){
        
        self.stopload()
        
        self.fullName = fullName
        self.branch = branch
        
        self.serialNumber = NSString.generateSerialNumber()
        self.progressView.progress = 0.3
        
        weak var weakSelf = self
        
        ZLRepoServiceModel.shared().getRepoReadMeInfo(withFullName:fullName , branch: branch , isHTML: true, serialNumber:self.serialNumber!, completeHandle: { (resultModel : ZLOperationResultModel) in
            
            if weakSelf?.serialNumber ?? "" != resultModel.serialNumber {
                return
            }
            
            if resultModel.result == false {
                weakSelf?.startRender(codeHtml: "Some Error Happened")
                return
            }
            
            guard let data : String = resultModel.data as? String else {
                weakSelf?.startRender(codeHtml: "Some Error Happened")
                return
            }
            
            weakSelf?.htmlStr = data
            weakSelf?.startRender(codeHtml: data)
            weakSelf?.progressView.progress = 0.75
        })
        
        
        ZLRepoServiceModel.shared().getRepoReadMeInfo(withFullName:fullName , branch: branch , isHTML: false, serialNumber:self.serialNumber!, completeHandle: { (resultModel : ZLOperationResultModel) in
            
            if weakSelf?.serialNumber ?? "" != resultModel.serialNumber {
                return
            }
            
            if resultModel.result == false {
                return
            }
            
            guard let data : ZLGithubContentModel = resultModel.data as? ZLGithubContentModel else {
                return
            }
            
            weakSelf?.readMeModel = data
            
            if weakSelf?.webView.isLoading == false && weakSelf?.htmlStr != nil {
                
            }
        })
    }
    
    func stopload(){
        self.serialNumber = nil
        self.readMeModel = nil
        self.htmlStr = nil
        
        self.progressView.progress = 0.0
        self.progressView.isHidden = false
        self.webView.stopLoading()
    }
    
    
    // 开始渲染页面
    private func startRender(codeHtml : String){
        
        let htmlURL: URL? = Bundle.main.url(forResource: "github_style_1", withExtension: "html")
        
        if let url = htmlURL {
            
            do {
                let htmlStr = try String.init(contentsOf: url)
                let newHtmlStr = NSMutableString.init(string: htmlStr)
                let range = (newHtmlStr as NSString).range(of:"</body>")
                if  range.location != NSNotFound{
                    newHtmlStr.insert(codeHtml, at: range.location)
                }
                
                self.webView?.loadHTMLString(newHtmlStr as String, baseURL: nil)
                
            }catch{
                ZLToastView.showMessage("load Code index html failed");
            }
        } else {
        }
    }
    

    @IBAction func onRefreshButtonClicked(_ sender: Any) {
        if self.fullName != nil {
            self.startLoad(fullName: self.fullName!, branch: self.branch)
        }
    }
    
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "contentSize"{
            
            guard let size : CGSize = change?[NSKeyValueChangeKey.newKey] as? CGSize else{
                return
            }
            
            self.webViewHeightConstant.constant = size.height;
        }
        
    }
    
    
    deinit {
        self.webView.scrollView.removeObserver(self, forKeyPath: "contentSize")
    }
    
}


extension ZLReadMeView : WKNavigationDelegate,WKUIDelegate{
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void)
    {
        
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void)
    {
        
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void)
    {
        
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let urlStr = navigationAction.request.url?.absoluteString;
        
        if navigationAction.navigationType == .linkActivated {
            decisionHandler(.cancel)

            var url : URL? = nil
            
            if urlStr?.count ?? 0 > 0  {
                url = URL.init(string: urlStr!)
                if url?.host == nil {               // 如果是相对路径，组装baseurl
                    url = (URL.init(string: self.readMeModel?.html_url ?? "") as NSURL?)?.deletingLastPathComponent
                    url?.appendPathComponent(urlStr!)
                }
                if self.delegate?.responds(to: #selector(ZLReadMeViewDelegate.onLinkClicked(url:))) ?? false {
                    self.delegate?.onLinkClicked(url: url)
                }
            }
            
        } else {
            decisionHandler(.allow)
        }
    }
       
    
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        self.progressView.progress = 1.0
        self.progressView.isHidden = true
        self.fixPicture()
    }
    
    
    func fixPicture(){
        if self.readMeModel?.download_url != nil {
            let baseURLStr = (URL.init(string: self.readMeModel!.download_url!) as NSURL?)?.deletingLastPathComponent?.absoluteString
            let addBaseScript = "let a = '\(baseURLStr ?? "")';let array = document.getElementsByTagName('img');for(i=0;i<array.length;i++){let item=array[i];if(item.getAttribute('src').indexOf('http') == -1){item.src = a + item.getAttribute('src');}}"
            
            webView.evaluateJavaScript(addBaseScript) { (result : Any?, error : Error?) in
               
            }
        }
    }
    
}
