//
//  UIImage+Extension.swift
//  SwiftNews
//
//  Created by NowOrNever on 31/07/2017.
//  Copyright © 2017 Focus. All rights reserved.
//

import UIKit

extension UIImage {
    public func fixedOrientation() -> UIImage {

        // No-op if the orientation is already correct
        guard imageOrientation != .up else {
            return self
        }
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform:CGAffineTransform = CGAffineTransform.identity
        switch imageOrientation {
        case .down,.downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left,.leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi * 0.5)
        case .right,.rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi * -0.5)
        default:
            break
        }

        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }

        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx: CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    
        ctx.concatenate(transform)
    
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
    
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
    
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
    
        // And now we just create a new UIImage from the drawing context
        let cgImage: CGImage = ctx.makeImage()!
    
        return UIImage(cgImage: cgImage)
    }
}



