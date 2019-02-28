
import UIKit

extension UIImageView {
    func getPixelColorAt(point:CGPoint) -> UIColor{
        
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context!.translateBy(x: -point.x, y: -point.y)
        layer.render(in: context!)
        let color:UIColor = UIColor(red: CGFloat(pixel[0])/255.0,
                                    green: CGFloat(pixel[1])/255.0,
                                    blue: CGFloat(pixel[2])/255.0,
                                    alpha: CGFloat(pixel[3])/255.0)
        
        pixel.deallocate()
        return color
    }
}


class ColorPickerViewController: UIViewController {
    
    private let boxSize:CGFloat = 32.0 * 1.25

	var delegate: PixelViewController? = nil
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.0).isActive = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    var img: UIImage?
    
    let colorStrip = UIView()
    let recentStrip = UIView()
    
    var lastSelectedColor: UIColor? {
        didSet {
            if let color = lastSelectedColor {
                delegate?.selectedColor = color
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    init() { super.init(nibName: nil, bundle: nil) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupColorStrip()

        view.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: colorStrip.bottomAnchor, constant: 2.0).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.90).isActive = true
        if let image = img {
            imageView.image = image
        }
        
        if let recentColors = delegate?.recentColors {
            let reversed = Array(recentColors.reversed())
            if reversed.count > 7 {
                let just8 = Array(reversed[0...7])
                setupRecentStrip(just8)
            } else {
                setupRecentStrip(reversed)
            }
        } else {
            setupRecentStrip()
        }
        
        
    }
    
    
    func makeColorStripItem(_ color:UIColor) -> UIView {
        let view = UIView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: boxSize, height: boxSize))
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2.0
        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true
        view.backgroundColor = color
        return view
    }
    
    func setupColorStrip(){
        colorStrip.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(colorStrip)
        let guide = view.layoutMarginsGuide
        colorStrip.heightAnchor.constraint(equalToConstant: boxSize).isActive = true
        colorStrip.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 0).isActive = true
        colorStrip.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -2.0).isActive = true
        colorStrip.topAnchor.constraint(equalTo: guide.topAnchor, constant: 4.0).isActive = true
        
        let colors:[UIColor] = [.white,.black,.red,.green,.blue,.purple,.orange,.yellow,]
        
        colors.map({makeColorStripItem($0)}).forEach({
            colorStrip.addSubview($0)
        })
        
        for (i,view) in colorStrip.subviews.enumerated() {
            if i == 0 {
                view.frame.origin.x = 2.0
            } else {
                view.center.x += (CGFloat(i) * (view.bounds.width)) + 2.0
            }
        }
    }
    
    
    func setupRecentStrip(_ colors:[UIColor] = [.white]){
        recentStrip.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(recentStrip)
        let guide = view.layoutMarginsGuide
        recentStrip.heightAnchor.constraint(greaterThanOrEqualToConstant: boxSize).isActive = true
        recentStrip.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 0).isActive = true
        recentStrip.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -2.0).isActive = true
        recentStrip.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4.0).isActive = true
        recentStrip.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -2.0).isActive = true
        
        colors.map({makeColorStripItem($0)}).forEach({
            recentStrip.addSubview($0)
        })
        
        for (i,view) in recentStrip.subviews.enumerated() {
            if i == 0 {
                view.frame.origin.x = 2.0
            } else {
                view.center.x += (CGFloat(i) * (view.bounds.width) ) + 2.0
            }
        }
        
        
        
    }
    
    
    
    
    
    private func touchInImageView(_ touchPoint:CGPoint) {
        if imageView.frame.contains(touchPoint) {
            let color = imageView.getPixelColorAt(point: touchPoint)
            if color != lastSelectedColor {
                lastSelectedColor = color
            }
        }
    }
    
    private func touchInColorStrip(_ touchPoint:CGPoint) {
        for subview in colorStrip.subviews {
            if subview.frame.contains(touchPoint) {
                let color = subview.backgroundColor ?? .white
                if color != lastSelectedColor {
                    lastSelectedColor = color
                }
            }
        }
    }
    
    private func touchInRecentStrip(_ touchPoint:CGPoint) {
        for subview in recentStrip.subviews {
            if subview.frame.contains(touchPoint) {
                let color = subview.backgroundColor ?? .white
                if color != lastSelectedColor {
                    lastSelectedColor = color
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touchPoint = touches.first?.location(in: imageView) {
            touchInImageView(touchPoint)
        }
        
        if let touchPoint = touches.first?.location(in: colorStrip) {
            touchInColorStrip(touchPoint)
        }
        
        if let touchPoint = touches.first?.location(in: recentStrip) {
            touchInRecentStrip(touchPoint)
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if let touchPoint = touches.first?.location(in: imageView) {
            touchInImageView(touchPoint)
        }
        
        if let touchPoint = touches.first?.location(in: colorStrip) {
            touchInColorStrip(touchPoint)
        }
        
        if let touchPoint = touches.first?.location(in: recentStrip) {
            touchInRecentStrip(touchPoint)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if let lastColor = lastSelectedColor {
            if let pv = delegate {
                pv.recentColors.append(lastColor)
                /*
                if !pv.recentColors.contains(lastColor) {
                    pv.recentColors.append(lastColor)
                }
                */
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
}
