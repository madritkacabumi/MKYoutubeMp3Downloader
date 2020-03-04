//
//  YoutubeDownloaderExtensionViewController.swift
//  MKYoutubeMp3DownloaderExampleShare
//
//  Created by Madrit Kacabumi on 2.2.20.
//  Copyright © 2020 Madrit Kacabumi. All rights reserved.
//

import UIKit
import MKYoutubeMp3Downloader
import AVFoundation
import MobileCoreServices

internal class YoutubeDownloaderExtensionViewController: UIViewController {
    var player: AVAudioPlayer?
    var mp3FilePath : URL?
    
    var youtubeUrl = "";
    
    private var currentManager : YoutubeDownloadManager?
    
    private var hasInfo = false {
        didSet{
            guard hasInfo != oldValue else { return }
            if hasInfo, let urlImage = currentManager?.ytVideoInfo?.thumbnail {
                thumbnailImage.imageFromServerURL(urlImage, placeHolder: #imageLiteral(resourceName: "yt-music-icon"))
            } else {
                thumbnailImage.image = #imageLiteral(resourceName: "yt-music-icon")
            }
        }
    }
    
    private var consoleMessage : String = "" {
        didSet {
            consoleContainer.isHidden = consoleMessage.isEmpty
            consoleText.text = consoleMessage
        }
    }
    
    @IBOutlet weak var mp3FileName: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressText: UILabel!
    @IBOutlet weak var mainActionBtn: UIButton!
    @IBOutlet weak var consoleContainer: UIView!
    @IBOutlet weak var consoleText: UILabel!
    @IBOutlet weak var shareBtnOutlet: UIButton!
    
    @IBAction func actionBtnPressed(_ sender: UIButton) {
        view.endEditing(true)
        guard ServerManager.shared.serverStarted else {
            startServer()
            return
        }
        
        guard currentManager != nil else {
            startYoutubeMp3DownloadOperation()
            return
        }
        download()
    }
    
    @IBAction func shareBtnClick(_ sender: UIButton) {
        guard let documentData = mp3FilePath, let audioFileName = currentManager?.ytVideoInfo?.title else { return }
        
        // we can directly use `mp3FilePath` for file path to share in *UIActivityViewController*
        // but the file filename will have and and encoded title
        // so we create a temporary custom file
        let fileManager = FileManager.default
        
        let tempFile = fileManager.temporaryDirectory.appendingPathComponent("/\(audioFileName).mp3", isDirectory: false)
        let data = NSData(contentsOf: documentData)
        
        data?.write(to: tempFile, atomically: true)
        
        let activityController = UIActivityViewController(activityItems: [audioFileName, tempFile], applicationActivities: nil)
        activityController.completionWithItemsHandler = { type , isFinished, fun, error in
            try? fileManager.removeItem(at: tempFile)
        }
        
        self.present(activityController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    private func startServer(){
        if !ServerManager.shared.serverStarted {
            self.view.isUserInteractionEnabled = false
            self.progressIndicator.startAnimating()
            self.progressText.text = "Turning local node server ON"
            ServerManager.shared.startServer { [weak self] in
                self?.view.isUserInteractionEnabled = true
                self?.progressIndicator.stopAnimating()
                self?.progressText.text = "Server started"
                self?.startYoutubeMp3DownloadOperation()
            }
        }
    }
    
    internal func startYoutubeMp3DownloadOperation(){
        
        guard ServerManager.shared.serverStarted else {
            startServer()
            return
        }
        
        if currentManager != nil, currentManager?.ytVideoInfo != nil {
            self.download()
        } else {
            getInfo(youtubeUrl: youtubeUrl) { [weak self] in
                self?.download()
            }
        }
    }
    
    private func getInfo(youtubeUrl : String, infoRetrieved : (() -> Void)? ){
        self.progressIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.progressText.textColor = .black
        self.consoleMessage = ""
        self.mainActionBtn.isHidden = true
        currentManager = YoutubeDownloadManager(youtubeUrl: youtubeUrl)
        
        currentManager?.getYoutubeVideoInfo(callback: { [weak self] (manager, infoModel, error) in
            guard let self = self else { return }
            self.progressIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if let error = error {
                self.progressText.text = "Error while gathering info"
                self.consoleMessage = error.message
                self.mainActionBtn.isHidden = false
            } else if let ytInfo = infoModel {
                self.mp3FileName.text = ytInfo.title
                self.hasInfo = true
                infoRetrieved?()
            }
        })
    }
    
    private func download(){
        self.progressIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.progressText.textColor = .black
        self.consoleMessage = ""
        
        guard let manager = currentManager, manager.ytVideoInfo != nil else {
            startYoutubeMp3DownloadOperation()
            return
        }
        
        manager.downloadYoutubeVideo(youtubeVideoName: manager.ytVideoInfo?.title, callback: {[weak self] (ytDownloadModel, error) in
            if let error = error {
                self?.progressIndicator.stopAnimating()
                self?.progressText.textColor = .red
                self?.progressText.text = error.message
                self?.view.isUserInteractionEnabled = true
            } else if let ytModel = ytDownloadModel {
                
                switch ytModel.action {
                case .startVideoDownload:
                    self?.progressText.text = "Starting video download"
                    self?.consoleMessage = ""
                    
                case .progressVideoDownload:
                    self?.progressText.text = "Downloading"
                    self?.consoleMessage = "Downloaded => \(ytModel.downloaded)\(ytModel.sizeLabel) of \(ytModel.totalSize)\(ytModel.sizeLabel) \n Total downloaded : \(ytModel.percent) \n  Estimated time left : \(ytModel.estimatedTimeLeft)"
                    
                case .endVideoDownload:
                    self?.progressText.text = "Video downloaded, Converting ...."
                    self?.consoleMessage = ""
                    
                case .startVideoConverting:
                    self?.progressText.text = "Starting converting to mp3"
                    self?.consoleMessage = ""
                    
                case .proccessingVideoConverting:
                    self?.progressText.text = "Converting to mp3"
                    self?.consoleMessage = ytModel.message
                    
                case .finishedVideoConverting:
                    self?.progressText.text = "Mp3 successfully finished"
                    self?.mp3FilePath = ytModel.mp3AudioFile
                    self?.consoleMessage = ytModel.message
                    self?.progressIndicator.stopAnimating()
                    self?.view.isUserInteractionEnabled = true
                    self?.shareBtnOutlet.isHidden = false
                    
                case .errorVideoDownload:
                    self?.progressText.textColor = .red
                    self?.progressText.text = ytModel.error
                    self?.consoleMessage = ytModel.message
                    self?.progressIndicator.stopAnimating()
                    self?.view.isUserInteractionEnabled = true
                    self?.mainActionBtn.isHidden = false
                }
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        currentManager?.cleanUp()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            exit(0)
        }
    }
}
