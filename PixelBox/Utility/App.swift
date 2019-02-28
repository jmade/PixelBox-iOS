
import UIKit

struct App {}

extension App {
    
    public struct Theme {
        struct Colors {
            static let app = #colorLiteral(red: 0.3121859333, green: 0.2966189455, blue: 0.8899508249, alpha: 1)
            static let tint = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
            static let green = #colorLiteral(red: 0, green: 1, blue: 0.4282035359, alpha: 1)
            static let interval = #colorLiteral(red: 1, green: 0.7256781276, blue: 0.396567274, alpha: 1)
            static let motion = #colorLiteral(red: 0.3045019005, green: 0.7660791595, blue: 1, alpha: 1)
            static let motionOff = #colorLiteral(red: 0.8549447404, green: 0.8674731391, blue: 0.9228267766, alpha: 1)
        }
        static func apply(){
            let attrs = [NSAttributedString.Key.foregroundColor: UIColor.white,]
            
            UINavigationBar.appearance().prefersLargeTitles = true
            UINavigationBar.appearance().largeTitleTextAttributes = attrs
            UINavigationBar.appearance().titleTextAttributes = attrs
            UINavigationBar.appearance().barTintColor = Theme.Colors.app
            UINavigationBar.appearance().tintColor = Theme.Colors.tint
            
            UIToolbar.appearance().barTintColor = Theme.Colors.app
            UIToolbar.appearance().tintColor = Theme.Colors.tint
            
            UIBarButtonItem.appearance().tintColor = Theme.Colors.tint
            UINavigationBar.appearance().titleTextAttributes = attrs
            
            let cancelButtonAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor : Theme.Colors.app ]
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(cancelButtonAttributes, for: .normal)
            
        }
    }

    
}


//: MARK: - Audio/Haptics -
extension App {
    struct Audio {
        // Hapitc
        static func makeSuccessFeedback(){
            if #available(iOS 10.0, *) {
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(.success)
            }
        }
        
        static func makeSelectionFeedback(){
            if #available(iOS 10.0, *) {
                let generator = UISelectionFeedbackGenerator()
                generator.selectionChanged()
            }
        }
    }
}


