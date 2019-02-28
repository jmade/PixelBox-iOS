//
//  ImageSave.swift
//  PixelBox
//
//  Created by Justin Madewell on 8/21/18.
//  Copyright © 2018 Jmade Technologies. All rights reserved.
//

import UIKit

struct RGBA32: Equatable {
    private var color: UInt32
    
    var redComponent: UInt8 {
        return UInt8((color >> 24) & 255)
    }
    
    var greenComponent: UInt8 {
        return UInt8((color >> 16) & 255)
    }
    
    var blueComponent: UInt8 {
        return UInt8((color >> 8) & 255)
    }
    
    var alphaComponent: UInt8 {
        return UInt8((color >> 0) & 255)
    }
    
    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        color = (UInt32(red) << 24) | (UInt32(green) << 16) | (UInt32(blue) << 8) | (UInt32(alpha) << 0)
    }
    
    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    
    static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
        return lhs.color == rhs.color
    }
    
    static let black = RGBA32(red: 0, green: 0, blue: 0, alpha: 255)
    static let red   = RGBA32(red: 255, green: 0, blue: 0, alpha: 255)
    static let green = RGBA32(red: 0, green: 255, blue: 0, alpha: 255)
    static let blue  = RGBA32(red: 0, green: 0, blue: 255, alpha: 255)
}



func createImage(width: Int, height: Int, from array: [RGBA32], completionHandler: @escaping (UIImage?, String?) -> Void) {
    DispatchQueue.global(qos: .utility).async {
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = RGBA32.bitmapInfo
        
        guard array.count == width * height else {
            completionHandler(nil, "Array size \(array.count) is incorrect given dimensions \(width) x \(height)")
            return
        }
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            completionHandler(nil, "unable to create context")
            return
        }
        
        guard let buffer = context.data else {
            completionHandler(nil, "unable to get context data")
            return
        }
        
        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
        
        for (index, color) in array.enumerated() {
            pixelBuffer[index] = color
        }
        
        let cgImage = context.makeImage()!
        
        let image = UIImage(cgImage: cgImage)
        completionHandler(image, nil)
    }
    
}



func takeScreenshot(_ view:UIView,_ shouldSave: Bool = false) -> UIImage? {
    var screenshotImage :UIImage?
    let layer = view.layer
    let scale = UIScreen.main.scale
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
    guard let context = UIGraphicsGetCurrentContext() else {return nil}
    layer.render(in:context)
    screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    if let image = screenshotImage, shouldSave {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    return screenshotImage
}


func saveImageDocumentDirectory(_ image:UIImage,_ imageName:String){
    let fileManager = FileManager.default
    let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
    print(paths)
    let imageData = image.jpegData(compressionQuality: 0.5)!
    fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
}









