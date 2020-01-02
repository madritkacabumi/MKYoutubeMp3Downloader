//
//  YoutubeErrorModel.swift
//  MKYoutubeDownloader
//
//  Created by Madrit Kacabumi on 22.12.19.
//  Copyright © 2019 Madrit Kacabumi. All rights reserved.
//

import UIKit

public class YoutubeErrorModel: NSObject {
    
   public let message : String
    
    internal init(message : String){
        self.message = message
    }
    
    init(jsonBody : [String : Any]) {
        message = jsonBody["errorMessage"] as? String ?? "Uknown error"
    }
}
