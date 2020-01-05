//
//  YoutubeDownloaderModel.swift
//  MKYoutubeDownloader
//
//  Created by Madrit Kacabumi on 24.12.19.
//  Copyright © 2019 Madrit Kacabumi. All rights reserved.
//

import UIKit

public struct YoutubeDownloaderModel{
    
    internal static let kAction = "action"
    private static let kError = "error"
    private static let kPercent = "percent"
    private static let kDownloaded = "downloaded"
    private static let kTotalSize = "totalSize"
    private static let kSizeLabel = "sizeLabel"
    private static let kEstimatedTimeLeft = "estimatedTimeLeft"
    private static let kVideo_file_url = "video_file_url"
    internal static let kMessage = "message"
    internal static let kMp3AudioFile = "mp3AudioFile"
    
    public let action : YoutubeDownloaderAction
    public let error : String
    public let percent : String
    public let downloaded : String
    public let totalSize : String
    public let sizeLabel : String
    public let estimatedTimeLeft : String
    public let videoFileUrl : String?
    public let message : String
    
    public let mp3AudioFile : URL?
    
    public init?(params : [String : Any]) {
        if let mActionString = params[YoutubeDownloaderModel.kAction] as? String, let mAction = YoutubeDownloaderAction(rawValue: mActionString) {
            self.action = mAction
        } else {
            return nil
        }
        
        error = params [YoutubeDownloaderModel.kError] as? String ?? ""
        percent = params [YoutubeDownloaderModel.kPercent] as? String ?? ""
        downloaded = params [YoutubeDownloaderModel.kDownloaded] as? String ?? ""
        totalSize = params [YoutubeDownloaderModel.kTotalSize] as? String ?? ""
        sizeLabel = params [YoutubeDownloaderModel.kSizeLabel] as? String ?? ""
        estimatedTimeLeft = params [YoutubeDownloaderModel.kEstimatedTimeLeft] as? String ?? ""
        videoFileUrl = params[YoutubeDownloaderModel.kVideo_file_url] as? String
        message = params[YoutubeDownloaderModel.kMessage] as? String ?? ""
        mp3AudioFile = params[YoutubeDownloaderModel.kMp3AudioFile] as? URL
    }
}
