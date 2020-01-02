//
//  YoutubeDownloaderAction.swift
//  MKYoutubeMp3Downloader
//
//  Created by Madrit Kacabumi on 26.12.19.
//  Copyright © 2019 Madrit Kacabumi. All rights reserved.
//

import Foundation

public enum YoutubeDownloaderAction : String {
    
    public typealias RawValue = String
    
    case startVideoDownload = "START_VIDEO_DOWNLOAD"
    case progressVideoDownload = "PROGRESS_VIDEO_DOWNLOAD"
    case endVideoDownload = "END_VIDEO_DOWNLOAD"
    case errorVideoDownload = "ERROR_VIDEO_DOWNLOAD"
    case startVideoConverting = "START_VIDEO_CONVERTING"
    case proccessingVideoConverting = "PROCCESS_VIDEO_CONVERTING"
    case finishedVideoConverting = "FINISHED_VIDEO_CONVERTING"
}
