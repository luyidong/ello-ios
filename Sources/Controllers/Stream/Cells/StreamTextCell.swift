//
//  StreamTextCell.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import WebKit
import Foundation

public class StreamTextCell: UICollectionViewCell, UIWebViewDelegate {
    typealias WebContentReady = (webView : UIWebView)->()

    @IBOutlet weak var webView:UIWebView!
    @IBOutlet weak var leadingConstraint:NSLayoutConstraint!
    weak var webLinkDelegate: WebLinkDelegate?
    var webContentReady: WebContentReady?

    override public func awakeFromNib() {
        super.awakeFromNib()
        webView.scrollView.scrollEnabled = false
    }

    func onWebContentReady(handler: WebContentReady?) {
        webContentReady = handler
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        webView.stopLoading()
    }

    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return ElloWebViewHelper.handleRequest(request, webLinkDelegate: webLinkDelegate)
    }

    public func webViewDidFinishLoad(webView: UIWebView) {
        webView.stringByEvaluatingJavaScriptFromString("document.documentElement.style.webkitUserSelect='none';")
        webView.stringByEvaluatingJavaScriptFromString("document.documentElement.style.webkitTouchCallout='none';")
        UIView.animateWithDuration(0.15, animations: {
            self.contentView.alpha = 1.0
        })
        webContentReady?(webView: webView)
    }
}
