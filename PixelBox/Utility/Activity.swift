
import UIKit

class CustomActivity: UIActivity {
    
    override class var activityCategory: UIActivity.Category {
        return .action
    }
    
    override var activityType: UIActivity.ActivityType? {
        guard let bundleId = Bundle.main.bundleIdentifier else {return nil}
        return UIActivity.ActivityType(rawValue: bundleId + "\(self.classForCoder)")
    }
    
    override var activityTitle: String? {
        return "Save Tracked Data"
    }
    
    override var activityImage: UIImage? {
       return #imageLiteral(resourceName: "pixels").withRenderingMode(.alwaysTemplate)
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    func _shouldExcludeActivityType(activity: UIActivity) -> Bool {
        if activity.activityType == activityType {
            return false
        } else {
            return true
        }
    }
    
    func matchingURLsInActivityItems(activityItems: [Any]) -> [Any] {
        return activityItems.filter {
            if let url = ($0 as? URL), !url.isFileURL {
                print("URL: \(url)")
                return url.pathExtension.caseInsensitiveCompare("jpg") == .orderedSame
                    || url.pathExtension.caseInsensitiveCompare("png") == .orderedSame
            }
            
            return false
        }
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        //
    }
    
    override func perform() {
        activityDidFinish(true)
    }
}

import UIKit

let TrackerSaveActivityType = "com.tracker.activity.SaveTrackerData"

class TrackerSaveActivity: UIActivity {
    // MARK: - UIActivity
    class func activityCategory() -> UIActivity.Category {
        return .action
    }
    
    class func activityType() -> String? {
        return TrackerSaveActivityType
    }
    
    class func activityTitle() -> String? {
        return NSLocalizedString("Save Tracker Data", comment: "Fuck Yeah!")
    }
    
    class func activityImage() -> UIImage {
        return #imageLiteral(resourceName: "target")
    }
}
