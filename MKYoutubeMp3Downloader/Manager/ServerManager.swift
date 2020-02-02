//
//  ServerManager.swift
//  MKYoutubeDownloader
//
//  Created by Madrit Kacabumi on 25.12.19.
//  Copyright © 2019 Madrit Kacabumi. All rights reserved.
//

import Zip
public class ServerManager {
    
    private static let bundleName = "MKYoutubeToMp3DownloaderZip"
    
    private var serverConnectCallback : (() -> Void)?
    
    internal var folderUrl : URL!
    
    var nodejsThread: Thread? = nil
    
    internal static let port = 8080
    
    internal static var serverUrl = "http://127.0.0.1:\(port)"
    
    private var mServerStarted = false
    
    public var serverStarted : Bool {
        get {
            
            if let nodeJsThread = nodejsThread {
                return mServerStarted && nodeJsThread.isExecuting && !(nodeJsThread.isFinished || nodeJsThread.isCancelled)
            }
            
            return mServerStarted
        }
        
        set {
            mServerStarted = newValue
        }
    }
    
    private var pendingServerStarted = false
    
    public static let shared = ServerManager()
    
    private init(){
        copyIfNeededAndExctract()
    }
    
    
    /// Will run the node js server located in app.js server directory
    ///
    ///- Parameter callback: Once the server starts , callback will be fired
    ///
    public func startServer(callback : (() -> Void)? = nil){
        
        guard !pendingServerStarted else {
            
            return
        }
        
        self.serverConnectCallback = callback
        guard !serverStarted else {
           self.serverConnectCallback?()
            return
        }
        
        pendingServerStarted = true
        nodejsThread = Thread(target: self, selector: #selector(startNode), object: nil)
        // Set 5MB of stack space for the Node.js thread.
        nodejsThread?.stackSize = 5 * 1024 * 1024
        nodejsThread?.start()
    }
    
    public func stopServer(){
        nodejsThread?.cancel()
    }
    
    /**
     Will retrieve the server.zip file from the Bundle resources and will extract it to the app folder
     If a previsious extraction had been occurred before it will delete the directory
     */
    private func copyIfNeededAndExctract(){
        guard let bundleUrl = Bundle.main.url(forResource: ServerManager.bundleName, withExtension: "bundle"),
            let mainBundle = Bundle(url: bundleUrl),
            let server = mainBundle.url(forResource: "server", withExtension: "zip")
            
            else { fatalError("server zip file not found") }
        
        let fileManager = FileManager.default
        let tempFolder = getDocumentsDirectory().appendingPathComponent("YoutubeDownloaderServer")
        
        if fileManager.fileExists(atPath: tempFolder.path) {
            do{
                try fileManager.removeItem(at: tempFolder)
            }
            catch {
                print(error.localizedDescription)
            }
        } else {
            
            do{
                try fileManager.createDirectory(at: tempFolder, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
        do {
            try Zip.unzipFile(server, destination: tempFolder, overwrite: true, password: nil, progress: nil)
            
            //todo remove
//            let bundleAppJs = mainBundle.url(forResource: "app", withExtension: "js")!
//            let localAppJs = tempFolder.appendingPathComponent("app.js")
//            try fileManager.removeItem(at: localAppJs)
//            try fileManager.copyItem(at: bundleAppJs, to: localAppJs)
            
        } catch {
            print(error.localizedDescription)
        }
        
        folderUrl = tempFolder
    }
    
    /**
     Retrieve a directory for extracting the files and runnong nodejs server
     - Returns: The directory to extract files `URL`.
     */
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    /**
     - Run the server. by creating a background thread
     */
    @objc func startNode(){
        
        let appJs = folderUrl.appendingPathComponent("app.js")
        let args = ["node", appJs.path]
        serverStarted = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.showGreetings()
            self?.serverConnectCallback?()
            self?.pendingServerStarted = false
        }
        
        NodeRunner.startEngine(withArguments: args)
        serverStarted = false
    }
    
    /**
     - Show about author
     */
    private func showGreetings(){
        let aboutAuthor = "\(ServerManager.serverUrl)/info"
        let aboutAuthorUrl = URL(string: aboutAuthor)
        if let aboutAuthorUrl = aboutAuthorUrl, let versionsData = try? String(contentsOf: aboutAuthorUrl) {
            print(versionsData)
        }
    }
}

