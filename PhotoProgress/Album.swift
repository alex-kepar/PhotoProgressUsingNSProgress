/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
                Album has an array of Photos loaded from the application bundle
            
*/

import UIKit

class Album: NSObject {
    // MARK: Properties

    let photos: [Photo]

    // MARK: Initializers

    override init () {

        var photosCombiner: [Photo] = []

        for (var photoBlockId = 0; photoBlockId < 10; photoBlockId++) {
            let blockSubdirectory = String(format: "Photos/block copy %02d", photoBlockId)
            guard let imageURLs = NSBundle.mainBundle().URLsForResourcesWithExtension("jpg", subdirectory: blockSubdirectory) else {
                fatalError("Unable to load photos")
            }
            photosCombiner = photosCombiner + imageURLs.map { Photo(URL: $0) }
        }
        photos = photosCombiner
    }
    
    func importPhotos() -> NSProgress {
        let progress = NSProgress()
        progress.totalUnitCount = Int64(photos.count)
        
        for photo in photos {
            let importProgress = photo.startImport()

            progress.addChild(importProgress, withPendingUnitCount: 1)
        }
        
        return progress
    }
    
    func resetPhotos() {
        for photo in photos {
            photo.reset()
        }
    }
}
