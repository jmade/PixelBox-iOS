//
//  Extentions.swift
//  Tracker
//
//  Created by Justin Madewell on 6/1/18.
//  Copyright © 2018 Earthwave Technologies. All rights reserved.
//

import UIKit

extension String {
    public func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
   public mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension Date {
    
    func offsetFrom(date : Date) -> String {
        
        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        let difference = Calendar.current.dateComponents(dayHourMinuteSecond, from: date, to: self)
        
        let seconds = "\(difference.second ?? 0)s"
        let minutes = "\(difference.minute ?? 0)m" + " " + seconds
        let hours = "\(difference.hour ?? 0)h" + " " + minutes
        let days = "\(difference.day ?? 0)d" + " " + hours
        
        if let day = difference.day, day          > 0 { return days }
        if let hour = difference.hour, hour       > 0 { return hours }
        if let minute = difference.minute, minute > 0 { return minutes }
        if let second = difference.second, second > 0 { return seconds }
        
        return ""
    }
    
}

func headingFromDegrees(_ degrees: Double) -> String{
    switch degrees{
    case 22.5..<67.5:   return "NE"
    case 67.5..<112.5:  return "E"
    case 112.5..<157.5: return "SE"
    case 157.5..<202.5: return "S"
    case 202.5..<247.5: return "SW"
    case 247.5..<292.5: return "W"
    case 292.5..<337.5: return "NW"
    default:            return "N"
    }
}



extension DateFormatter {
    
    
    public static var timestamp: DateFormatter {
        return DateFormatter.timestampDateFormatter
    }
    
    private static let timestampDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss zzz"
        return dateFormatter
    }()
    
    
    public static var local: DateFormatter {
        return DateFormatter.localDateFormatter
    }
    
    private static let localDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "MMM dd YYYY h:mm:ss a"
        return dateFormatter
    }()
    
    
    // The way the server date's will be coming back
    public static var app: DateFormatter {
        return DateFormatter.appDateFormatter
    }
    
    private static let appDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()
    
    //
    public static var iso8601: DateFormatter {
        return DateFormatter.iso8601DateFormatter
    }
    
    private static let iso8601DateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }()
    
}

extension UIView {
    
   public func fadeInSubviews(){
        UIView.animate(withDuration: 0.3) { [weak self] in
            if let strongSelf = self {
                strongSelf.subviews.forEach({
                    $0.alpha = 1.0
                })
            }
        }
    }
    
    public func fadeOutSubviews(){
        UIView.animate(withDuration: 0.3) { [weak self] in
            if let strongSelf = self {
                strongSelf.subviews.forEach({
                    $0.alpha = 0
                })
            }
        }
    }
    
}


import CoreLocation


extension CLHeading {
    
    func requestParams() -> [String:String] {
        return [
            "headingTrue":"\(trueHeading)",
            "magnetic":"\(magneticHeading)",
            "headingTimestamp":"\(DateFormatter.app.string(from: timestamp))",
            "accuracy":"\(headingAccuracy)",
            "x":"\(x)",
            "y":"\(y)",
            "z":"\(z)",
        ]
    }
    
    func formatted() -> String {
        func vectorStringFromHeading(_ heading:CLHeading) -> String {
            return "X: \(String(format: "%2.4f", heading.x))\n Y: \(String(format: "%2.4f", heading.y))\n Z: \(String(format: "%2.4f", heading.z)) "
        }
        
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "MMM d YYYY h:mm:ss a"
        
        let magnetic = self.magneticHeading
        return """
        Heading:
        Magnetic: \(headingFromDegrees(magnetic)) (\(Int(magnetic)))
        True: \(headingFromDegrees(self.trueHeading)) (\(Int(self.trueHeading)))
        Accuracy: \(Int(self.headingAccuracy))
        Vector:
        \(vectorStringFromHeading(self))
        Timestamp: \(dateFmt.string(from: self.timestamp))
        """
    }
    
//    func apiRequest() -> APIRequest {
//        return APIRequest(.heading, nil, requestParams()) {
//            print("Heading Send Response: \($0.value)")
//        }
//    }
    
    
}


extension CLLocation {
    
    func requestParams() -> [String:String] {
        return [
            "latitude" : "\(coordinate.latitude)",
            "longitude":"\(coordinate.longitude)",
            "speed":"\(speed)",
            "locationTimestamp":"\(DateFormatter.app.string(from: timestamp))",
            "horizontalAccuracy":"\(horizontalAccuracy)",
            "verticalAccuracy":"\(verticalAccuracy)",
            "coarse":"\(course)",
        ]
    }
    
}


