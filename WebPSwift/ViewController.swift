//
//  ViewController.swift
//  WebPSwift
//
//  Created by Ryota Iwai on 2016/09/13.
//  Copyright © 2016年 Ryota Iwai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var jpegImageView: UIImageView!
    @IBOutlet weak var jpegImageSizeLabel: UILabel!
    @IBOutlet weak var webpImageView: UIImageView!
    @IBOutlet weak var webpImageSizeLabel: UILabel!
    @IBOutlet weak var button: UIButton!

    private let jpegImagesURLStrings: [String] = [
        "https://www.gstatic.com/webp/gallery/1.jpg",
        "https://www.gstatic.com/webp/gallery/2.jpg",
        "https://www.gstatic.com/webp/gallery/4.jpg",
        "https://www.gstatic.com/webp/gallery/5.jpg"
        ]
    private let webpImagesURLStrings: [String] = [
        "https://www.gstatic.com/webp/gallery/1.webp",
        "https://www.gstatic.com/webp/gallery/2.webp",
        "https://www.gstatic.com/webp/gallery/4.webp",
        "https://www.gstatic.com/webp/gallery/5.webp"
    ]
    private var currentIndex: Int = 0

    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clear()
    }

    // MARK: - IBAction
    @IBAction func tapButton(_ sender: AnyObject) {
        self.clear()
        self.downloadWebPImage()
        self.downloadJpegeImage()

        self.currentIndex += 1
        if self.currentIndex >= self.jpegImagesURLStrings.count {
            self.currentIndex = 0
        }
    }

    // MARK: - Private
    private func clear() {
        self.jpegImageView.image = nil
        self.jpegImageSizeLabel.text = self.sizeString(size: 0)
        self.webpImageView.image = nil
        self.webpImageSizeLabel.text = self.sizeString(size: 0)
    }

    private func downloadJpegeImage() {
        guard let imageURL = URL(string: self.jpegImagesURLStrings[self.currentIndex]) else {
            return
        }
        DispatchQueue.global().async {
            guard
                let imageData = try? Data(contentsOf: imageURL),
                let jpgeImage = UIImage(data: imageData) else {
                    return
            }
            DispatchQueue.main.async {
                self.jpegImageView.image = jpgeImage
                self.jpegImageSizeLabel.text = self.sizeString(size: imageData.count)
            }
        }
    }

    private func downloadWebPImage() {
        guard let imageURL = URL(string: self.webpImagesURLStrings[self.currentIndex]) else {
            return
        }
        DispatchQueue.global().async {
            guard
                let imageData = try? Data(contentsOf: imageURL),
                let webpImage = UIImage(webPData: imageData as NSData) else {
                    return
            }
            DispatchQueue.main.async {
                self.webpImageView.image = webpImage
                self.webpImageSizeLabel.text = self.sizeString(size: imageData.count)
            }
        }
    }

    private func sizeString(size: Int) -> String {
        if size < 1024 {
            return "\(size) Bytes"
        }
        let kByte = size / 1024
        if kByte < 1024 {
            return "\(kByte) KBytes"
        }
        let mByte = kByte / 1024
        return "\(mByte) MBytes"
    }
}

