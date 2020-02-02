//
//  ShareViewController.swift
//  MKYoutubeMp3DownloaderExampleShare
//
//  Created by Madrit Kacabumi on 2.2.20.
//  Copyright © 2020 Madrit Kacabumi. All rights reserved.
//

import UIKit
import Social
import MKYoutubeMp3Downloader
import MobileCoreServices
class ShareViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBackground()
        DispatchQueue.main.async { [weak self] in
            self?.loadUrl()
        }
    }
    
    private func loadUrl(){//public.plain-text
        if let item = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProvider = item.attachments?.first as? NSItemProvider{
            
            let itemIdentifier = itemProvider.hasItemConformingToTypeIdentifier("public.url") ? "public.url" : (itemProvider.hasItemConformingToTypeIdentifier("public.plain-text") ? "public.plain-text" : "")

            guard !itemIdentifier.isEmpty else {
                return
            }
            
            itemProvider.loadItem(forTypeIdentifier: itemIdentifier, options: nil) { [weak self] (url, error) in
                if let shareURL = url as? URL {
                    if let childVc = self?.children.first(where: { (vcInquery) -> Bool in
                        return vcInquery is YoutubeDownloaderExtensionViewController
                    }) as? YoutubeDownloaderExtensionViewController {
                        childVc.youtubeUrl = shareURL.absoluteString
                        DispatchQueue.main.async {
                            childVc.startYoutubeMp3DownloadOperation()
                        }
                    }
                }
            }
        }
    }
    
    private func loadBackground(){
        // only apply the blur if the user hasn't disabled transparency effects
        if UIAccessibility.isReduceTransparencyEnabled == false {
            view.backgroundColor = .clear

            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            view.insertSubview(blurEffectView, at: 0)
        } else {
            view.backgroundColor = .black
        }
    }
}
