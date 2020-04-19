// The MIT License (MIT)
//
// Copyright (c) 2015 Joakim Gyllström
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit
import Photos

/// Settings for BSImagePicker
public class Settings {
    public static let shared = Settings()

    // Move all theme related stuff to UIAppearance
    public class Theme {
        /// Main background color
        public lazy var backgroundColor: UIColor = .white
        
        /// What color to fill the circle with
        public lazy var selectionFillColor: UIColor = UIView().tintColor
        
        /// Color for the actual checkmark
        public lazy var selectionStrokeColor: UIColor = .white
        
        /// Shadow color for the circle
        public lazy var selectionShadowColor: UIColor = .black
    }

    public class Selection {
        /// Max number of selections allowed
        public lazy var max: Int = Int.max
        
        /// Min number of selections you have to make
        public lazy var min: Int = 1
    }

    public class List {
        /// How much spacing between cells
        public lazy var spacing: CGFloat = 2
        
        /// How many cells per row
        public lazy var cellsPerRow: (_ verticalSize: UIUserInterfaceSizeClass, _ horizontalSize: UIUserInterfaceSizeClass) -> Int = {(verticalSize: UIUserInterfaceSizeClass, horizontalSize: UIUserInterfaceSizeClass) -> Int in
            switch (verticalSize, horizontalSize) {
            case (.compact, .regular): // iPhone5-6 portrait
                return 3
            case (.compact, .compact): // iPhone5-6 landscape
                return 5
            case (.regular, .regular): // iPad portrait/landscape
                return 7
            default:
                return 3
            }
        }
    }

    public class Preview {
        /// Is preview enabled?
        public lazy var enabled: Bool = true
    }

    public class Fetch {
        public class Album {
            /// Fetch options for albums/collections
            public lazy var options: PHFetchOptions = {
                let fetchOptions = PHFetchOptions()
                return fetchOptions
            }()

            /// Fetch results for asset collections you want to present to the user
            public lazy var fetchResults: [PHFetchResult<PHAssetCollection>] = [
                PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: options),
                PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: options),
                PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: options),
                PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumSelfPortraits, options: options),
                PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumPanoramas, options: options),
                PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: options),
            ]
        }

        public class Assets {
            /// Fetch options for assets

            /// Simple wrapper around PHAssetMediaType to ensure we only expose the supported types.
            public enum MediaTypes {
                case image
                case video

                fileprivate var assetMediaType: PHAssetMediaType {
                    switch self {
                    case .image:
                        return .image
                    case .video:
                        return .video
                    }
                }
            }
            public lazy var supportedMediaTypes: Set<MediaTypes> = [.image]

            public lazy var options: PHFetchOptions = {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [
                    NSSortDescriptor(key: "creationDate", ascending: false)
                ]

                let rawMediaTypes = supportedMediaTypes.map { $0.assetMediaType.rawValue }
                let predicate = NSPredicate(format: "mediaType IN %@", rawMediaTypes)
                fetchOptions.predicate = predicate

                return fetchOptions
            }()
        }

        public class Preview {
            public lazy var photoOptions: PHImageRequestOptions = {
                let options = PHImageRequestOptions()
                options.isNetworkAccessAllowed = true

                return options
            }()

            public lazy var livePhotoOptions: PHLivePhotoRequestOptions = {
                let options = PHLivePhotoRequestOptions()
                options.isNetworkAccessAllowed = true
                return options
            }()

            public lazy var videoOptions: PHVideoRequestOptions = {
                let options = PHVideoRequestOptions()
                options.isNetworkAccessAllowed = true
                return options
            }()
        }

        /// Album fetch settings
        public lazy var album = Album()
        
        /// Asset fetch settings
        public lazy var assets = Assets()

        /// Preview fetch settings
        public lazy var preview = Preview()
    }
    
    public class Dismiss {
        /// Should the image picker dismiss when done/cancelled
        public lazy var enabled = true
    }

    /// Theme settings
    public lazy var theme = Theme()
    
    /// Selection settings
    public lazy var selection = Selection()
    
    /// List settings
    public lazy var list = List()
    
    /// Fetch settings
    public lazy var fetch = Fetch()
    
    /// Dismiss settings
    public lazy var dismiss = Dismiss()

    /// Preview options
    public lazy var preview = Preview()
}
