//
//  YoutubeDownloadManager.swift
//  MKYoutubeDownloader
//
//  Created by Madrit Kacabumi on 25.12.19.
//  Copyright © 2019 Madrit Kacabumi. All rights reserved.
//
import mobileffmpeg

public typealias YoutubeDownloaderHandler = ((_ info : YoutubeDownloaderModel?, _ error : YoutubeErrorModel?) -> ())

public class YoutubeDownloadManager: NSObject {
    
    /* When downloading check how many attemts are allowed until successful action file read*/
    private let retries = 25
    
    /* Counting failed attempts */
    private var readLocalFileRetryCount = 0
    
    /* Global youtube url */
    private let youtubeUrl : String
    
    /* Timeout operations check until video download */
    private var timeout = 3 * 60 // 5 minutes by default
    
    /* timestamp for downloading video */
    private var startedDownloadTime = Date()
    
    /* refresh function for reading actions file */
    private let readFileRefreshRate = 0.3
    
    /* Check if this download is consumed */
    public var isConsumed = false
    
     /* Downloading and converting callback */
    private var mCallback : YoutubeDownloaderHandler?
    
    /* stored info object for youtube video */
    public var ytVideoInfo : YoutubeDownloaderInfoModel?
    
     /* stored response from node backend regarding downloading info actions file */
    private var ytDataModel : YoutubeDownloaderDataModel?
    
    
    public init(youtubeUrl : String) {
        self.youtubeUrl = youtubeUrl
    }
    
    /// Set the timeout for video downloading
    ///
    /// - Parameters:
    ///     - timeout: timeout in seconds
    ///
    public func timeout(timeout : Int) -> Self{
        self.timeout = timeout
        return self
    }
    
    /// Will retrieve info for a youtube video file, saving response for avoiding multiple calls to info.
    ///
    /// - Parameters:
    ///     - callback: handler with the info response., will be called in the main thread
    ///     - ytManager: the manager instance.
    ///     - info: the info response parsed into the **YoutubeDownloaderInfoModel** model.
    ///     - error:n case we encounter errors like:
    ///   ## Error types
    ///     - Network failure
    ///     - Backend response status code invalid, *400* for validation failure
    ///     - Invalid responses
    ///
    public func getYoutubeVideoInfo(callback : @escaping ((_ ytManager : YoutubeDownloadManager, _ info : YoutubeDownloaderInfoModel?, _ error : YoutubeErrorModel?) -> ())){
        
        guard ytVideoInfo == nil else { // we allready have the info , dont get them again
            callback(self, ytVideoInfo, nil)
            return
        }
        
        let url = URL(string: ServerManager.serverUrl + "/youtubeVideoInfo")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = [
            "youtubeUrl": youtubeUrl
        ]
        request.httpBody = parameters.percentEncoded()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, errorResponse in
            
            guard let data = data,
                let response = response as? HTTPURLResponse,
                errorResponse == nil else {
                    let errorMessage = "error : \(errorResponse?.localizedDescription  ?? "Unknown error or no connection to internet")"
                    let error = YoutubeErrorModel(message: errorMessage)
                    DispatchQueue.main.async {
                        callback(self, nil, error)
                    }
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                if response.statusCode == 400, let jsonResponseError = try? JSONSerialization.jsonObject(with:
                    data, options: []) as? [String : Any] {
                    
                    let error = YoutubeErrorModel(jsonBody: jsonResponseError)
                    DispatchQueue.main.async {
                        callback(self, nil, error)
                    }
                    
                } else {
                    
                    let errorMessage = "statusCode should be 2xx, but is \(response.statusCode)" + "\n" + "response = \(response)"
                    let error = YoutubeErrorModel(message: errorMessage)
                    DispatchQueue.main.async {
                        callback(self, nil, error)
                    }
                }
                return
            }
            
            if let jsonResponse = try? JSONSerialization.jsonObject(with:
                data, options: []) as? [String : Any] {
                self.ytVideoInfo = YoutubeDownloaderInfoModel(body: jsonResponse)
                
                DispatchQueue.main.async {
                    callback(self, self.ytVideoInfo, nil)
                }
                
            } else {
                let parsedError = String(data: data, encoding: .utf8) ?? "Uknown error from parsing the response"
                let errorMessage = "Invalid json format or invalid properties => \(parsedError)"
                let error = YoutubeErrorModel(message: errorMessage)
                DispatchQueue.main.async {
                    callback(self, nil, error)
                }
            }
        }
        task.resume()
    }
    
    /// Will download youtube video by the url given in the constructor,
    /// Once the server gives success response, the server is in the
    /// download mode of the video so we check periodically the staus by reading an action file
    /// wich will be given by the local backend in the response
    ///
    /// - Parameters:
    ///     - youtubeVideoName: optional name for the final music audio.
    ///     - callback: **YoutubeDownloaderHandler** => handler with the info response., will be called in the main thread.
    ///   ## Error types
    ///     - Network failure
    ///     - Backend response status code invalid, *400* for validation failure
    ///     - Invalid responses
    ///
    public func downloadYoutubeVideo(youtubeVideoName : String? = nil, callback : @escaping YoutubeDownloaderHandler){
        
        guard !isConsumed else {
            let error = YoutubeErrorModel(message: "This download object was consumed, create a new one")
            mCallback?(nil, error)
            return
        }
        
        self.mCallback = callback
        
        let url = URL(string: ServerManager.serverUrl + "/downloadYoutubeVideo")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        var parameters: [String: Any] = [
            "youtubeUrl": youtubeUrl
        ]
        
        if let name = youtubeVideoName {
            parameters["videoFileName"] = name
        }
        
        request.httpBody = parameters.percentEncoded()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, errorResponse in
            
            guard let data = data,
                let response = response as? HTTPURLResponse,
                errorResponse == nil else {
                    let errorMessage = "error : \(errorResponse?.localizedDescription  ?? "Unknown error or no connection to internet")"
                    let error = YoutubeErrorModel(message: errorMessage)
                    callback(nil, error)
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                let errorMessage = "statusCode should be 2xx, but is \(response.statusCode)" + "\n" + "response = \(response)"
                let error = YoutubeErrorModel(message: errorMessage)
                callback(nil, error)
                return
            }
            
            if let jsonResponse = try? JSONSerialization.jsonObject(with:
                data, options: []) as? [String : Any] {
                self.ytDataModel = YoutubeDownloaderDataModel(jsonBody: jsonResponse)
                self.startedDownloadTime = Date()
                self.isConsumed = true
                self.updateProgress()
            } else {
                let parsedError = String(data: data, encoding: .utf8) ?? "Uknown error from parsing the response"
                let errorMessage = "Invalid json format or invalid properties => \(parsedError)"
                let error = YoutubeErrorModel(message: errorMessage)
                callback(nil, error)
            }
        }
        
        task.resume()
    }
    
    /// Will periodically check the options file by reading it in the *YoutubeDownloaderDataModel::actions_file* path.
    /// If fails (example concurrency between local running server and app) it will retry by increasing the *readLocalFileRetryCount*
    /// In case of progress it will call the callback in the main thread so the progress can be display to the user
    /// in case of errors will call the callback in the main thread, and ignore further operations
    ///   ## Error types
    ///     - File not exists failure
    ///     - File not readable, (example concurrency between local running server and app)
    ///     - timeout configured at *timeout*
    ///
    private func updateProgress() {
        
        guard let dateComponentsSeconds = Calendar.current.dateComponents([.second], from: self.startedDownloadTime, to: Date()).second else {
            self.isConsumed = false
            
            let error = YoutubeErrorModel(message: "Invalid timeout calculations due to `startDownloadTime` and current time")
            dispatchActions(ytModel: nil, ytError: error)
            return
        }
        
        guard dateComponentsSeconds <= timeout else {
            self.isConsumed = false
            
            let error = YoutubeErrorModel(message: "Request timeout")
            dispatchActions(ytModel: nil, ytError: error)
            return
        }
        
        let fileManager = FileManager.default
        
        guard let actionsFile = ytDataModel?.actions_file, fileManager.fileExists(atPath: actionsFile) else {
            readLocalFileRetryCount += 1
            if readLocalFileRetryCount >= retries {
                self.isConsumed = false
                
                let error = YoutubeErrorModel(message: "Could not read the actions file, file is missing")
                dispatchActions(ytModel: nil, ytError: error)
                
                return
            }
            dispatchProgressUpdate()
            return
        }
        
        if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: actionsFile)),
            let actionsJsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any],
            let ytAction = YoutubeDownloaderModel(params: actionsJsonObject) {
            
            //discard the counter
            readLocalFileRetryCount = 0
            
            dispatchActions(ytModel: ytAction, ytError: nil)
            
            switch ytAction.action {
            case.endVideoDownload:
                convertVideoToMp3(videoPath: ytAction.videoFileUrl)
                return
            case .errorVideoDownload:
                mCallback = nil // stop everything
                return
            default:
                break
            }
            
            dispatchProgressUpdate()
            
        } else {
            
            readLocalFileRetryCount += 1
            
            if readLocalFileRetryCount >= retries {
                self.isConsumed = false
                let error = YoutubeErrorModel(message: "Could not read the actions file, could not parse it, parse went bad")
                dispatchActions(ytModel: nil, ytError: error)
                return
            }
            
            dispatchProgressUpdate()
        }
    }
    
    /// Will call after a certain amount of time the the #updateProgress Function
    ///
    private func dispatchProgressUpdate(){
        DispatchQueue.main.asyncAfter(deadline: .now() + readFileRefreshRate) {
            self.updateProgress()
        }
    }
    
    /// Convert the video into mp3 using FFMPEG in a worker thread
    /// Create a new mp3 file with the same name as the video
    /// Once finished the callback with be called on the main thread
    /// in case of errors will call the callback in the main thread, and ignore further operations
    ///
    /// - Parameters:
    ///     - videoPath: The downloaded video path
    ///
    ///   ## Error types
    ///     - Missing video file
    ///     - File not readable
    ///     - FFMpeg thrown errors
    ///
    private func convertVideoToMp3(videoPath : String?){
        MobileFFmpegConfig.setLogDelegate(self)
        MobileFFmpegConfig.setLogLevel(AV_LOG_VERBOSE)
        
        let fileManager = FileManager.default
        
        guard let videoPath = videoPath, fileManager.fileExists(atPath: videoPath) else {
            let error = YoutubeErrorModel(message: "Downloaded video file is missing")
            dispatchActions(ytModel: nil, ytError: error)
            return
        }
        
        let videoUrl = URL(fileURLWithPath: videoPath)
        let audioUrlString = videoUrl.absoluteString.replacingOccurrences(of: videoUrl.pathExtension, with: "mp3")
        let audioUrl = URL(string: audioUrlString)!
        
        let ytManagerAction = YoutubeDownloaderModel(params: [
            YoutubeDownloaderModel.kAction : YoutubeDownloaderAction.startVideoConverting.rawValue,
            YoutubeDownloaderModel.kMessage : "Starting video convertion"
        ])
        
        dispatchActions(ytModel: ytManagerAction, ytError: nil)
        
        DispatchQueue.global(qos: .background).async {
            MobileFFmpeg.execute("-i \(videoUrl.path) -c:v mp3 \(audioUrl.path)")
            
            let rc = MobileFFmpeg.getLastReturnCode()
            let outPut = MobileFFmpeg.getLastCommandOutput() ?? "No execution output"
            
            var error : YoutubeErrorModel?
            var ytdAction : YoutubeDownloaderModel?
            
            switch rc {
            case RETURN_CODE_SUCCESS:
                ytdAction = YoutubeDownloaderModel(params: [
                    YoutubeDownloaderModel.kAction : YoutubeDownloaderAction.finishedVideoConverting.rawValue,
                    YoutubeDownloaderModel.kMessage : "Video successfully converted",
                    YoutubeDownloaderModel.kMp3AudioFile : audioUrl
                ])
            default:
                let errorMsg = "Command execution failed with rc=\(rc) and output=\(outPut)"
                error = YoutubeErrorModel(message: errorMsg)
            }
            
            self.dispatchActions(ytModel: ytdAction, ytError: error)
        }
    }
    
    /// Will send a result or an error  in  for the operations reading
    ///
    /// - Parameters:
    ///     - ytModel: The **YoutubeDownloaderModel** wich contains all the informations about an action the backend is performing
    ///     - ytError: and error of type **YoutubeErrorModel** describing what failed during download/conversion
    ///   ## Error types
    ///     - Timeout Calculations
    ///     - Timeot
    ///     - Reading file failure , (concurrency in reading/writting the file)
    ///     - Retries Multiple retries on reading the files
    ///     - FFMpeg thrown errors
    ///
    private func dispatchActions(ytModel : YoutubeDownloaderModel?, ytError : YoutubeErrorModel?) {
        
        DispatchQueue.main.async {
            self.mCallback?(ytModel, ytError)
        }
    }
}

//MARK: - LogDelegate
extension YoutubeDownloadManager : LogDelegate {
    
    public func logCallback(_ level: Int32, _ message: String!) {

        let ytManagerAction = YoutubeDownloaderModel(params: [
            YoutubeDownloaderModel.kAction : YoutubeDownloaderAction.proccessingVideoConverting.rawValue,
            YoutubeDownloaderModel.kMessage : message ?? "NAN"
        ])
        self.mCallback?(ytManagerAction, nil)
    }
}
