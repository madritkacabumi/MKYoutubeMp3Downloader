//
//  ViewController.swift
//  MKYoutubeMp3DownloaderExample
//
//  Created by Madrit Kacabumi on 27.12.19.
//  Copyright © 2019 Madrit Kacabumi. All rights reserved.
//

import UIKit
import MKYoutubeMp3Downloader
import AVFoundation

internal class ViewController: UIViewController {
    var player: AVAudioPlayer?
    var mp3FilePath : URL?
    
    private var currentManager : YoutubeDownloadManager?
    
    private var hasDownloadedVideo = false {
        didSet {
            if hasDownloadedVideo != oldValue,hasDownloadedVideo {
                self.downloadBtnOutlet.setTitle("Start Over", for: .normal)
                self.downloadBtnOutlet.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
            }
        }
    }
    
    private var hasInfo = false {
        didSet{
            guard hasInfo != oldValue else { return }
            
            let btnTitle = hasInfo ? "Download" : "Get Info"
            let btnImage = hasInfo ? UIImage(systemName: "arrow.down.square") : UIImage(systemName: "info.circle.fill")
            downloadBtnOutlet.setTitle(btnTitle, for: .normal)
            downloadBtnOutlet.setImage(btnImage, for: .normal)
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
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var youtubeInput: UITextField!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressText: UILabel!
    @IBOutlet weak var downloadBtnOutlet: UIButton!
    @IBOutlet weak var playPauseBtn: UIButton!
    @IBOutlet weak var consoleContainer: UIView!
    @IBOutlet weak var consoleText: UILabel!
    @IBOutlet weak var shareBtnOutlet: UIButton!
    
    @IBAction func pasteBtnClicked(_ sender: UIButton) {
        youtubeInput.text = UIPasteboard.general.string
        resetEverything()
        view.endEditing(true)
    }
    
    @IBAction func downloadBtnPressed(_ sender: UIButton) {
        guard ServerManager.shared.serverStarted, let youtubeUrl = youtubeInput.text, !youtubeUrl.isEmpty else {
            if !ServerManager.shared.serverStarted {
                startServer()
            }
            return
        }
        
        guard !hasDownloadedVideo else {
            resetEverything()
            return
        }
        
        view.endEditing(true)
        
        if hasInfo {
            download(youtubeUrl: youtubeUrl)
        } else {
            getInfo(youtubeUrl: youtubeUrl)
        }
    }
    
    @IBAction func onInputChangeAction(_ sender: UITextField) {
        resetEverything()
    }
    
    
    @IBAction func playPauseBtnPressed(_ sender: UIButton) {
        guard let player = player else {
            resetEverything()
            return
        }
        
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
        playPauseBtn.setImage(UIImage(systemName: player.isPlaying ? "pause" : "play"), for: .normal)
    }
    
    @IBAction func shareBtnClick(_ sender: UIButton) {
        guard let documentData = mp3FilePath, let audioFileName = currentManager?.ytVideoInfo?.title else { return }
        
        let activityController = UIActivityViewController(activityItems: [audioFileName, documentData], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startServer()
    }
    
    private func startServer(){
        //        resetEverything()
        if !ServerManager.shared.serverStarted {
            self.view.isUserInteractionEnabled = false
            self.progressIndicator.startAnimating()
            self.progressText.text = "Turning local node server ON"
            ServerManager.shared.startServer { [weak self] in
                self?.view.isUserInteractionEnabled = true
                self?.downloadBtnOutlet.isHidden = false
                self?.progressIndicator.stopAnimating()
                self?.progressText.text = "Server started"
            }
        }
    }
    
    private func getInfo(youtubeUrl : String){
        self.progressIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.progressText.textColor = .black
        self.consoleMessage = ""
        currentManager = YoutubeDownloadManager(youtubeUrl: youtubeUrl)
        currentManager?.getYoutubeVideoInfo(callback: { [weak self] (manager, infoModel, error) in
            guard let self = self else { return }
            self.progressIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if let error = error {
                self.progressText.text = "Error while gathering info"
                self.consoleMessage = error.message
            } else if let ytInfo = infoModel {
                self.progressText.text = ytInfo.title
                self.hasInfo = true
            }
        })
    }
    
    private func download(youtubeUrl : String){
        self.progressIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.progressText.textColor = .black
        self.consoleMessage = ""
        guard let manager = currentManager else {
            resetEverything()
            return
        }
        
        var fileName : String?
        
        if let title = manager.ytVideoInfo?.title {
            fileName = "\(title)"
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
                    self?.hasDownloadedVideo = true
                    self?.showPlayer(ytModel: ytModel)
                    self?.view.isUserInteractionEnabled = true
                case .errorVideoDownload:
                    self?.progressText.textColor = .red
                    self?.progressText.text = ytModel.error
                    self?.consoleMessage = ytModel.message
                    self?.progressIndicator.stopAnimating()
                    self?.view.isUserInteractionEnabled = true
                }
            }
        })
    }
    
    private func showPlayer(ytModel : YoutubeDownloaderModel){
        guard let youtubeMp3File = self.mp3FilePath else {
            progressText.text = "Error finding the file"
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: youtubeMp3File, fileTypeHint: AVFileType.mp3.rawValue)
            playPauseBtn.isHidden = false
            shareBtnOutlet.isHidden = false
            
        } catch let error {
            print(error.localizedDescription)
            progressText.text = "Error playing audio file"
            consoleMessage = error.localizedDescription
        }
    }
    
    private func resetEverything(){
        currentManager = nil
        mp3FilePath = nil
        hasInfo = false
        consoleMessage = ""
        progressText.text = "Enter or paste youtube url"
        currentManager = nil
        hasDownloadedVideo = false
        playPauseBtn.setImage(UIImage(systemName:"play"), for: .normal)
        playPauseBtn.isHidden = true
        player?.stop()
        player = nil
        shareBtnOutlet.isHidden = true
    }
}

// MARK:- UITextViewDelegate

extension UIViewController : UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
