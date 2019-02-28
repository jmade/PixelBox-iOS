
import UIKit


extension UIColor {
    
    var redValue: CGFloat{ return CIColor(color: self).red }
    var greenValue: CGFloat{ return CIColor(color: self).green }
    var blueValue: CGFloat{ return CIColor(color: self).blue }
    var alphaValue: CGFloat{ return CIColor(color: self).alpha }
    
    func textColor() -> UIColor {
        if self.redValue < 0.5 && self.greenValue < 0.5 && self.blueValue < 0.5 {
            return UIColor.white
        } else {
            return UIColor.black
        }
    }
    
    func pixelValue() -> (Int,Int,Int) {
        return (
            Int(self.redValue * CGFloat(255.0)),
            Int(self.greenValue * CGFloat(255.0)),
            Int(self.blueValue * CGFloat(255.0))
        )
    }
}



//: MARK: - PixelValue -
struct PixelValue {
    let id:(Int,Int)
    let color:(Int,Int,Int)
    var uiColor: UIColor {
        return UIColor(r: color.0, g: color.1, b: color.2)
    }
    var store:[String:String] {
        return [
            "\(id.0),\(id.1)" : "\(color.0),\(color.1),\(color.2)",
        ]
    }
    
    func lowered() -> PixelValue {
        var y = id.1 + 1
        if y > 15 { y = 0 }
        return PixelValue(id: (id.0,y), color: uiColor.pixelValue())
    }
}

extension PixelValue {
    init(_ data:[String:String]){
        let entry = data[data.startIndex]
        
        let x = entry.key.split(",")[0]
        let y = entry.key.split(",")[1]
        let id = (Int(x) ?? 0,Int(y) ?? 0)
        
        let r = entry.value.split(",")[0]
        let g = entry.value.split(",")[1]
        let b = entry.value.split(",")[2]
        let color = (Int(r) ?? 0,Int(g) ?? 0,Int(b) ?? 0)
        
        
        self.color = color
        self.id = id
    }
}


extension PixelValue {
    func pixelMessage() -> PixelMessage {
        return PixelMessage.with {
            $0.x = Int32(id.0)
            $0.y = Int32(id.1)
            $0.r = Int32(color.0)
            $0.g = Int32(color.1)
            $0.b = Int32(color.2)
        }
    }
}


//: MARK: - PixelView -
final class PixelView: UIView {
    var pixelID: (Int,Int) = (0,0)
    required init?(coder aDecoder: NSCoder) {fatalError()}
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}




