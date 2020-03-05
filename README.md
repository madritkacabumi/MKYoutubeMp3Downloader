# MKYoutubeMp3Downloader
Download youtube videos to mp3 iOS library.

The library will use a node js server in-mobile built in (local server).
It will use a node js script will download a youtube video.
Then using a ffmpeg external swift library will convert the video in mp3.

## First Things First!

This is totally **against Youtube Legal** stuff. This is **ONLY** for educational purposes and it is not intended to be used in commercial activities (Please use it only for fun).
Most probably it will be **rejected** from the **AppStore** if you use it in your app and want to distribute as it infringes Apple guidelines and stuff.
Im not responsible for the misuse of this library. Use it at **your own responsibility**.

## Version

1.0.0

## Build and Runtime Requirements
+ Xcode 11.0 or later
+ iOS 11.0 or later
+ Bitcode disabled

## Installation

```ruby
pod 'MKYoutubeMp3Downloader'
```

## Technical overview
The library will run a local node js server on your app at the port **3000**.
The framework will perform requests to this server retrieving youtube video info and/or download it.
Then the framework using ffmpeg will convert it to a mp3 file.

## Usage
**Important: Make sure the local server is on.**

1. Start the server if is of before downloading or retrieving info.
   ```ruby
   guard ServerManager.shared.serverStarted else {
            ServerManager.shared.startServer {
                // start downloading or retrieving info
            }
            return
        }
    ```

2. Create a ```YoutubeDownloadManager```
   ```ruby
   let manager = YoutubeDownloadManager(youtubeUrl: youtubeUrl)
    ```
    The manager is only usable with the youtube video url provided at it's initialisation.
3. Retrieve youtube video info:
   ```ruby
   manager.getYoutubeVideoInfo(callback: { [weak self] (manager, infoModel, error) in
            guard let self = self else { return }
            self.progressIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if let error = error {
                self.infoLabelTitle = error.message
            } else if let ytInfo = infoModel {
                self.mp3FileName.text = ytInfo.title
                self.lengthVideo = "\(ytInfo.length) seconds"
                if !ytInfo.thumbnail.isEmpty {
                    thumbnailImage.imageFromServerURL(ytInfo.thumbnail)
                }
            }
        })
        
        // you can access this info later on the manager, in case it has already retrieved the info.
        if let info = manager.ytVideoInfo {
            // lets use the info we already have
        }
    ```

4. Download youtube video and get the progress from the download start until video successfully converted to mp3.
   ```ruby
        manager.downloadYoutubeVideo(youtubeVideoName: manager.ytVideoInfo?.title, callback: {[weak self] (ytDownloadModel, error) in
            // check the progress
        })
    ```

5. Progress and error handling
The YoutubeDownloaderModel object will provide downloading or converting progress or error each time is invoked.
If an error occurs it stops it's job.
The progress: YoutubeDownloaderModel::action is an enum containing all the flow starting from video download until mp3 convertion or error:
   ```ruby
    case startVideoDownload
    case progressVideoDownload
    case endVideoDownload
    case errorVideoDownload
    case startVideoConverting
    case proccessingVideoConverting
    case finishedVideoConverting
    ```
   A simple example how to use it:
   ```ruby
           manager.downloadYoutubeVideo(youtubeVideoName: manager.ytVideoInfo?.title, callback: {[weak self] (ytDownloadModel, error) in
            if let error = error {
                //this is another type of error wich is not involved in the downloading & converting proccess
                self?.progressText.textColor = .red
                self?.progressText.text = error.message
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
                    
                case .errorVideoDownload:
                    self?.progressText.textColor = .red
                    self?.progressText.text = ytModel.error
                    self?.consoleMessage = ytModel.message
                }
            }
        })
     ```
     YoutubeDownloaderModel contains a lot of additional data that are available depending on the case like the example above

6. Example

Clone the project and you will find an Example app using this framework. The app target does nothing but it is shipped with a Share Extension that can be used as a downloading instance.
Open your browser, navigate to a video on youtube and share it. In the list of the apps to share find (if you are not finding it just add it as an option) and select it. It will do the Job.

## Drawback
The third party library [nodejs-mobile](https://github.com/JaneaSystems/nodejs-mobile) has a drawback on it's own. It requires a thread that will run infinitely, so, unless the app is terminated it will be running and right now it is quite challenging stopping it. If you put your app in the background, after a while (the app is in background) the system will terminate it.
This shut's down the server and you cannot use it to until a totally restart of your app.
This could happen if you use this framework on the app instance (it could take a while once your app is in background for the thread to be terminated).

Using
```ruby
exit(0)
```
would terminate the app instance but still it is not a nice thing as it looks like an app crash.

<img src="https://raw.githubusercontent.com/devMadrit/MKYoutubeMp3Downloader/develop/attachments/smart_image.jpg" alt="alt text" width="250" height="250">

A nice trick/workaround would be using an apple extension (ex: ShareExtension) that in our case could be seen as an "independent instance" where we can start the serve and once we download what wee need we kill this instance using exit(0)
and if our app is opened wont be affected by this extension termination.


### TODO's

- [x] Example case using an extension
- [ ] Terminating programmatically the thread and starting it whenever is required
- [ ] Updating the example for sharing the extension to be working on the iOS youtube app.


### Third parties

- [nodejs-mobile](https://github.com/JaneaSystems/nodejs-mobile)
- [mobile-ffmpeg](https://github.com/tanersener/mobile-ffmpeg)
- [Zip](https://github.com/marmelroy/Zip)




## Author

Madrit Kacabumi, dev.madrit.kacabumi@gmail.com

## License

Use it at you risk/responsibility. Use it for educational purposes.
## 🇦🇱
