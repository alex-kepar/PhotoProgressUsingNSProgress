/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
                PhotoCollectionViewCell is a UICollectionViewCell subclass that shows a Photo.
            
*/

import UIKit

/// The KVO context used for all `PhotoCollectionViewCell` instances.
private var photoCollectionViewCellObservationContext = 0

class PhotoCollectionViewCell: UICollectionViewCell {
    // MARK: Properties

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var progressView: UIProgressView!

    private let fractionCompletedKeyPath = "photoImport.progress.fractionCompleted"

    private let imageKeyPath = "image"
    
    var photo: Photo? {
        willSet {
            guard let formerPhoto = photo where IS_USING_KVO else { return }
            formerPhoto.removeObserver(self, forKeyPath: fractionCompletedKeyPath, context: &photoCollectionViewCellObservationContext)
            formerPhoto.removeObserver(self, forKeyPath: imageKeyPath, context: &photoCollectionViewCellObservationContext)
            print("removed observer for \(formerPhoto.imageURL.lastPathComponent)")
        }

        didSet {
            if let newPhoto = photo where IS_USING_KVO {
                newPhoto.addObserver(self, forKeyPath: fractionCompletedKeyPath, options: [], context: &photoCollectionViewCellObservationContext)
                newPhoto.addObserver(self, forKeyPath: imageKeyPath, options: [], context: &photoCollectionViewCellObservationContext)
                print("added observer for \(newPhoto.imageURL.lastPathComponent)")
            } else {
                print("skipped observation for cell")
            }

            updateImageView()
            updateProgressView()
        }
    }
    
    private func updateProgressView() {
        if let photoImport = photo?.photoImport {
            let fraction = Float(photoImport.progress.fractionCompleted)
            progressView.progress = fraction
            
            progressView.hidden = false
        }
        else {
            progressView.hidden = true
        }
    }

    private func updateImageView() {
        UIView.transitionWithView(imageView, duration: 0.5, options: .TransitionCrossDissolve, animations: {
            self.imageView.image = self.photo?.image
        }, completion: nil)
    }
    
    // MARK: Key-Value Observing
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard context == &photoCollectionViewCellObservationContext else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            if keyPath == self.fractionCompletedKeyPath {
                self.updateProgressView()
            }
            else if keyPath == self.imageKeyPath {
                self.updateImageView()
            }
        }
    }
}
