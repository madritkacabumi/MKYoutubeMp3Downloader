//
//  YoutubeDownloaderDataModel.swift
//  MKYoutubeDownloader
//
//  Created by Madrit Kacabumi on 24.12.19.
//  Copyright © 2019 Madrit Kacabumi. All rights reserved.
//

import UIKit

internal struct YoutubeDownloaderDataModel {
    
    private let kSuccess = "success"
    private let kActions_file = "actions_file"
    
    internal let success : Bool
    internal let actions_file : String?
    
    init(jsonBody : [String : Any]) {
        success = jsonBody[kSuccess] as? Bool ?? false
        actions_file = jsonBody[kActions_file] as? String
    }
}
