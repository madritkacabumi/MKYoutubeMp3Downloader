//
//  ViewController.swift
//  MKYoutubeMp3DownloaderExample
//
//  Created by Madrit Kacabumi on 27.12.19.
//  Copyright © 2019 Madrit Kacabumi. All rights reserved.
//

import UIKit
import MKYoutubeMp3Downloader

internal class ViewController: UIViewController {
    
    
    @IBOutlet weak var youtubeInput: UITextField!
    @IBOutlet weak var serverSwitch: UISwitch!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressText: UILabel!
    @IBOutlet weak var downloadBtnOutlet: UIButton!
    @IBOutlet weak var playPauseBtn: UIButton!
    
    
    @IBAction func downloadBtnPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func playPauseBtnPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if sender.isOn, !ServerManager.shared.serverStarted {
            self.view.isUserInteractionEnabled = false
            self.progressIndicator.startAnimating()
            self.progressText.text = "Turning server ON"
            ServerManager.shared.startServer { [weak self] in
                self?.view.isUserInteractionEnabled = true
                self?.progressIndicator.stopAnimating()
                self?.progressText.text = "Server started"
                sender.isUserInteractionEnabled = false
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        serverSwitch.setOn(false, animated: false)
    }
    
    private func initViews(){
        
    }
    
    private func download(){
        let manager = YoutubeDownloadManager(youtubeUrl: "https://www.youtube.com/watch?v=Rht7rBHuXW8")
        manager.getYoutubeVideoInfo() { ytManager, info, error in
            ytManager.downloadYoutubeVideo(callback: { (ytDownloadModel, error) in
                if let error = error {
                    print("Error Downloading video => " + error.message)
                } else {
                    print(ytDownloadModel?.action.rawValue)
                    if ytDownloadModel?.action == .finishedVideoConverting {
                    }
                }
            })
        }
    }
}

