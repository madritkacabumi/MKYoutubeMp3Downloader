//
//  YoutubeDownloaderInfoModel.swift
//  MKYoutubeDownloader
//
//  Created by Madrit Kacabumi on 24.12.19.
//  Copyright © 2019 Madrit Kacabumi. All rights reserved.
//

import UIKit

public struct YoutubeDownloaderInfoModel {
    
    private let kTitle = "title"
    private let kThumbnail = "thumbnail"
    private let kLength = "length"
    
    let title : String
    let thumbnail : String
    let length : Double
    
    init(body : [String : Any]) {
        title = body[kTitle] as? String ?? ""
        thumbnail = body[kThumbnail] as? String ?? ""
        length = body[kLength] as? Double ?? -0.0
    }
}
