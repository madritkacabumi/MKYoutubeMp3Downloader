//
//  PreviewViewController.swift
//  MKYoutubeMp3DownloaderExample
//
//  Created by Madrit Kacabumi on 29.2.20.
//  Copyright © 2020 Madrit Kacabumi. All rights reserved.
//

import UIKit

internal class PreviewViewController: UIViewController {
    internal let index : Int
    internal let image : UIImage!
    var previewImage : UIImageView!
    
    internal init(index : Int, image : UIImage){
        self.index = index
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    private func initViews(){
        previewImage = UIImageView()
        previewImage.attachTo(view: view)
        previewImage.contentMode = .scaleAspectFill
        previewImage.image = image
    }
}
