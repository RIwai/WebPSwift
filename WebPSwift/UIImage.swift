//
//  UIImage.swift
//  WebPSwift
//
//  Created by Ryota Iwai on 2016/09/13.
//  Copyright © 2016年 Ryota Iwai. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    convenience init?(webPData: NSData, resize size: CGSize = CGSize.zero) {
        var config: WebPDecoderConfig = WebPDecoderConfig()
        if WebPInitDecoderConfig(&config) == 0 {
            return nil
        }

        let webPDataP: UnsafePointer<UInt8> = webPData.bytes.assumingMemoryBound(to: UInt8.self)
        if WebPGetFeatures(webPDataP, webPData.length, &config.input) != VP8_STATUS_OK {
            return nil
        }

        config.output.colorspace = config.input.has_alpha != 0 ? MODE_rgbA : MODE_RGB
        config.options.use_threads = 1

        if size.width > 0 && size.height > 0 {
            config.options.use_scaling = 1
            config.options.scaled_width = Int32(size.width)
            config.options.scaled_height = Int32(size.height)
        }

        // Decode the WebP image data into a RGBA value array.
        if WebPDecode(webPDataP, webPData.length, &config) != VP8_STATUS_OK {
            return nil
        }

        var width: Int32 = config.input.width
        var height: Int32 = config.input.height
        if config.options.use_scaling != 0 {
            width = config.options.scaled_width
            height = config.options.scaled_height
        }

        // Construct a UIImage from the decoded RGBA value array.
        let provider = CGDataProvider(dataInfo: nil,
                                      data: config.output.u.RGBA.rgba,
                                      size: config.output.u.RGBA.size,
                                      releaseData: { (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> Void in
                                            free(UnsafeMutableRawPointer(mutating: data))
                                        })
        guard let wrappedProvider = provider else {
            return nil
        }
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: CGBitmapInfo = config.input.has_alpha != 0 ?
            [CGBitmapInfo.byteOrder32Big, CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)] : CGBitmapInfo(rawValue: 0)
        let components: size_t = config.input.has_alpha != 0 ? 4 : 3
        let renderingIntent: CGColorRenderingIntent = .defaultIntent
        guard let imageRef = CGImage(width: Int(width),
                                     height: Int(height),
                                     bitsPerComponent: 8,
                                     bitsPerPixel: components * 8,
                                     bytesPerRow: components * Int(width),
                                     space: colorSpaceRef,
                                     bitmapInfo: bitmapInfo,
                                     provider: wrappedProvider,
                                     decode: nil,
                                     shouldInterpolate: false,
                                     intent: renderingIntent) else {
                                            return nil
        }
        
        self.init(cgImage: imageRef)
    }
}
