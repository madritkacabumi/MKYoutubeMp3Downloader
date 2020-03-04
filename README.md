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
pod 'MKYoutubeToMp3Downloader'
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
The YoutubeDownloaderModel object will provide downloading or converting progres or error each time is invoked.
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
With the project's General tab still open, update the Bundle Identifier value. The project's Lister target ships with the value:

com.example.apple-samplecode.Lister

You should modify the reverse DNS portion to match the format that you use:

com.yourdomain.Lister

Repeat this process for the following targets:

- Lister
- ListerKit
- ListerToday
- ListerOSX
- ListerKitOSX
- ListerOSXToday

4) Change the iCloud Capability's container name.

With the project still open, select the Capabilities tab for the Lister target. Under the iCloud capability there will be an area marked Containers, click the + button in this area to add a new container name. Accept Xcode's proposed name (noting the expanded value). Finally, remove the container name provided with the project (iCloud.com.example.apple-samplecode.Lister.Documents) by unchecking the checkbox beside that container name.

Now update the iCloud capability for the remaing targets by setting up their containers to match the Lister target. The capability from the Lister target should appear in the container list allowing you to simply click its checkbox and uncheck the one that shipped with the sample. If you do have to add it manually, make sure to type in the expanded value from the Lister target rather than the one Xcode proposes. Only these targets require changes:

- ListerToday
- ListerOSX
- ListerOSXToday

5) Ensure Automatic is chosen for the Provisioning Profile setting in the Code Signing section of Target > Build Settings for the following Targets:

- Lister
- ListerToday
- ListerOSX
- ListerOSXToday

6) Ensure iOS Developer is chosen for the Code Signing Identity setting in the Code Signing section of Target > Build Settings for the following Targets:

- Lister
- ListerToday

And that Mac Developer is chosen for the Code Signing Identity setting in the Code Signing section of Target > Build Settings for the following Targets:

- ListerOSX
- ListerOSXToday

## About Lister

Lister is a Cocoa productivity sample code project for iOS and OS X. In this sample, the user can create lists, add items to lists, and track the progress of items in the lists.

## Written in Objective-C and Swift

This sample is written in both Objective-C and Swift. Both versions of the sample are at the top level directory of this project in folders named "Objective-C" and "Swift". Both versions of the application have the exact same visual appearance; however, the code and structure may be different depending on the choice of language.

Note: The List class in Swift is conceptually equivalent to the AAPLList class in Objective C. The same applies to other classes mentioned in this README; Swift drops the AAPL from the class. To refer to conceptually-equivalent classes, this README uses the format {AAPL}List.  


## Application Architecture

The Lister project includes iOS and OS X app targets, iOS and OS X app extensions, and frameworks containing shared code.

### OS X

Lister for OS X is a document-based application with a single window per document. To organize the implementation of the app, Lister takes a modular design approach. Three main controllers are each responsible for different portions of the user interface and document interaction: {AAPL}ListWindowController manages a single window and owns the document associated with the window. The window controller also implements interactions with the window’s toolbar such as sharing. The window controller is also responsible for presenting an {AAPL}AddItemViewController object that allows the user to quickly add an item to the list. The {AAPL}ListViewController class is responsible for displaying each item in a table view in the window.

Lister's design and controller interactions are implemented in a Mac Storyboard. A storyboard makes it easy to visualize the relationships between view controllers and to lay out the user interface of the app. Lister also takes advantage of Auto Layout to fluidly resize the interface as the user resizes the window. If you're opening the project for the first time, the Storyboard.storyboard file is a good place to understand how the app works.

Although much of the view layer is implemented with built–in AppKit views and controls, there are several interesting custom views in Lister. The {AAPL}ColorPaletteView class is an interface to select a list's color. When the user shows or hides the color palette, the view dynamically animates the constraints defined in Interface Builder. The {AAPL}ListTableView and {AAPL}TableRowView classes are responsible for displaying list items in the table view.

Document storage in Lister is implemented in the {AAPL}ListDocument class, a subclass of NSDocument. Documents are stored as keyed archives. {AAPL}ListDocument reuses much of the same model code shared between the OS X and iOS apps. Additionally, the {AAPL}ListDocument class enables Auto Save and Versions, undo management, and more. With the {AAPL}ListFormatting class, the user can copy and paste items between Lister and other apps, and even share items.

The Lister app manages a Today list that it stores in iCloud document storage. The {AAPL}TodayListManager class is responsible for creating, locating, and retrieving the today {AAPL}ListDocument object from the user's iCloud container. Open the Today list with the Command-T key combination.

### iOS

The iOS version of Lister follows many of the same design principles as the OS X version—the two versions share common code. The iOS version also follows the Model-View-Controller (MVC) design pattern and uses modern app development practices including Storyboards and Auto Layout. In the iOS version of Lister, the user manages multiple lists using a table view implemented in the {AAPL}ListDocumentsViewController class.

A user can store their documents both locally or in iCloud. To abstract the storage mechanism away from the type of storage (iCloud or local), Lister uses a {AAPL}ListController class that notifies the {AAPL}ListDocumentsViewController about new lists, lists that have been removed, and also lists that have been updated. The {AAPL}ListController has an {AAPL}ListCoordinator property which is resonsible for tracking the relevant URLs. In Lister, there are two types of {AAPL}ListCoordinator objects: the {AAPL}CloudListCoordinator object as well as the {AAPL}LocalListCoordinator object. The only place that these objects are used directly is within the {AAPL}ListController. The storage mechanism is determined by the {AAPL}AppDelegate, which asks the user what their storage preference is. Once their preference is known, the app delegate creates an {AAPL}ListCoordinator and passes it to the app delegate's {AAPL}ListController property. The app delegate passes the {AAPL}ListController object throughout the application to ensure that it's used as the single place to manage lists.

Once the list of documents is visible, a user can tap on a list to show the {AAPL}ListViewController. This class displays and manages a single document. If a user wants to create a new list, they can tap on the "+" to display an instance of the {AAPL}NewListDocumentController. Lists are represented with the {AAPL}ListDocument class, a subclass of UIDocument, which is responsible for serialization and deserialization of a list. Rather than directly manage {AAPL}List objects, the {AAPL}ListDocumentsViewController class manages an array of {AAPL}ListInfo objects. The {AAPL}ListInfo class caches properties that are required, like the list's color, for display.

Note: Lister leverages the document picker on iOS. This requires that code signing, entitlements, and provisioning for the project have been configured before you run Lister. If you run the app without configuring entitlements correctly and create a new document via the "+" button, an exception will be raised about a missing iCloud entitlement.

### Shared Code

Much of the model layer code for Lister is used throughout the entire project, across the iOS and OS X platforms. {AAPL}List and {AAPL}ListItem are the two main model objects. The {AAPL}ListItem class represents a single item in a list. It contains only three stored properties: the text of the item, a boolean value indicating whether the user has completed it, and a unique identifier. Along with these properties, the {AAPL}ListItem class also implements the functionality required to compare, archive, and unarchive a {AAPL}ListItem object. The {AAPL}List class holds an array of these {AAPL}ListItem objects, as well as the desired list color. The {AAPL}List class also supports indexed subscripting, archiving, unarchiving, and equality.

Archiving and unarchiving are specifically designed and implemented so that model objects can be unarchived regardless of the language, Swift or Objective–C, or the platform, iOS or OS X, that they were archived on.

In addition to model code, by subclassing CALayer (a class shared by iOS and OS X), Lister shares check box drawing code with both platforms. The project includes a control class for each platform with user interface framework–specific code. These {AAPL}CheckBox classes use the designable and inspectable attributes so that the custom drawing code is viewable and adjustable live in Interface Builder.

### iOS and OS X Today Widget

Lister Today widgets are available on both iOS and OS X. Lister shares much of the same model, controller, and drawing code between the app extensions and apps by using a shared framework. This is also very valuable because it centralizes the core code into a single location. See the "Shared" Code section above for more info on the details of the code sharing. Both iOS and OS X implement a view controller subclass called {AAPL}TodayViewController; this can be found in the ListerToday target for iOS and ListerTodayOSX for OS X.

## Swift Features

The Lister sample leverages many features unique to Swift, including the following:

#### Nested types

The List.Color enumeration represents a list's associated color.

#### String Constants

Constants are defined using structs and static members to avoid keeping constants in the global namespace. One example is notification constants, which are typically defined as global string constants in Objective-C. Nested structures inside types allow for better organization of notifications in Swift.

#### Extensions on Types at Different Layers of a Project

The List.Color enum is defined in the List model object. It is extended in the UI layer (ListColorUI.swift) so that it can be easily converted into a platform-specific color object.

#### Subscripting

The List class provides access to its ListItem objects through indexed subscripting. The List object stores ListItem objects in an in-memory array.

#### Tuples

List is responsible for managing the order of its ListItem objects. When an item is moved from one row to another, the list returns a lightweight tuple that contains both the "from" and "to" indices. This tuple is used in a few different methods in the List class.

## Unit Tests

Lister has unit tests written for the {AAPL}List and {AAPL}ListItem classes. These tests are in the ListerKitTests group. The same tests can be run on an iOS or Mac target to ensure that the cross-platform code works as expected. To run the unit tests, select either the ListerKit (for iOS) or ListerKitOSX (for OS X) scheme in the Scheme menu. Then hold the Run button down and select the "Test" option, or press Command+u to run the tests.

Copyright (C) 2014 Apple Inc. All rights reserved.

