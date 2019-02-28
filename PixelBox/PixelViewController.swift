import UIKit


//: MARK: - PixelViewController -
final class PixelViewController: UIViewController {
    
    let colorWheel = ColorWheelImage.Image()
    
    var serverIsOn: Bool = false {
        didSet {
            if serverIsOn {
                print("Server is Running!")
            }
        }
    }
    
    var rainMode:Bool = false {
        didSet {
            resetPixelPositions(true)
            animatePixelsIntoPosition()
        }
    }
    
    var selectedColor = UIColor.red {
        didSet {
            View.prepareButton(colorPickerButton, selectedColor, "Color",selectedColor.textColor())
        }
    }
    
    var recentColors:[UIColor] = []
    
    var lastTouchedPixelView: PixelView?
    var pixels: [PixelView] = []
    
    let pixelContainer = UIView()
    var colorPickerButton = UIButton()
    
    var history: [[PixelValue]] = []
    var currentOperation: [PixelValue] = []
    
    var firstLoad: Bool = true
    
    var baseSwitch: Bool = true {
        didSet {
            resetPixelPositions()
            animatePixelsIntoPosition()
        }
    }

    var timer:Timer? = nil
    var timing:Double = 0.5 {
        didSet {
            print("Resetting Pixel Fall Operation")
            if (timer != nil) {
                endLowerPixels()
                startLowerPixels()
            }
        }
    }
    
    enum Direction {
        case left,right,up,down
    }
    
    var direction:Direction = .down {
        didSet {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkForServer { [weak self] in
            if let message = $0["message"] as? String {
                print(message)
                if message == "P0NG!" {
                    self?.serverIsOn = true
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstLoad {
            
            for v in view.subviews {
                if v is UISwitch {
                    if (v as! UISwitch).onTintColor != .blue {
                        (v as! UISwitch).setOn(baseSwitch, animated: true)
                    }
                    
                    if (v as! UISwitch).onTintColor == .blue {
                        (v as! UISwitch).setOn(false, animated: true)
                    }
                }
            }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("View Did Appear")
        if firstLoad {
            print("Animating In")
            animatePixelsIntoPosition()
            sendToServer()
            firstLoad = false
        }
    }
    
    //Protobuf
    
    func makeProtoBof(){
        let _ = PixelMessage.with {
                $0.x = 0
                $0.y = 0
                $0.r = 255
                $0.g = 255
                $0.b = 255
             }
    }
    

    //: MARK: - UI Interaction -
    @objc
    func baseSwitchToggled(_ sender:UISwitch) {
        baseSwitch = sender.isOn
        sendToServer()
    }
    
    @objc
    func lowerSwitchToggled(_ sender:UISwitch) {
        sender.isOn ? startLowerPixels() : endLowerPixels()
    }
    
    @objc
    func timingButtonFired(){
        showTimerDialog()
    }
    
    @objc
    func rainButtonFired(_ sender:UIButton){
        //addLoadingView(pixelContainer)
        if rainMode {
            stopRain { [weak self] in
                if let message = $0["message"] as? String {
                    if message == "Rain Stopped." {
                        DispatchQueue.main.async(execute: {
                            self?.rainMode = false
                            sender.setAttributedTitle(View.buttonAttributedTitle("Start Rain"), for: UIControl.State())
                            sender.backgroundColor = .green
                            removeLoadingView((self?.pixelContainer)!)
                        })
                    }
                }
                
            }
        } else {
            startRain { [weak self] in
                if let message = $0["message"] as? String {
                    if message == "Rain Complete" {
                        DispatchQueue.main.async(execute: {
                            self?.rainMode = true
                            sender.setAttributedTitle(View.buttonAttributedTitle("Stop Rain"), for: UIControl.State())
                            sender.backgroundColor = .red
                            removeLoadingView((self?.pixelContainer)!)
                        })
                    }
                }
            }
        }
        App.Audio.makeSuccessFeedback()
    }

    
    @objc
    func resetCanvas(){
        App.Audio.makeSuccessFeedback()
        resetPixelPositions(true)
        animatePixelsIntoPosition()
        sendToServer()
    }
    
    
    @objc
    func undo(){
        App.Audio.makeSuccessFeedback()
        guard !history.isEmpty else {return}
        let lastChange = history.removeLast()
        lastChange.forEach({ pixelValue in
            for pixel in pixels where pixel.pixelID == pixelValue.id {
                pixel.backgroundColor = baseSwitch ? .black : .white
            }
        })
        sendToServer()
    }
    
    
    @objc
    func saveButtonPressed(){
        App.Audio.makeSuccessFeedback()
        sendToServer()
        performSave()
    }
    
    // from other screen
    func remoteLoad(_ pixelBox:PixelBox){
        for pv in pixelBox.pixelValues {
            for pixel in pixels where pixel.pixelID == pv.id {
                pixel.backgroundColor = pv.uiColor
            }
        }
        sendToServer()
    }
    
    
    func performSave() {
        let imageKey = UUID().uuidString
        if let image = takeScreenshot(pixelContainer) {
            saveImageDocumentDirectory(image, imageKey)
        }
        
        var tag = ""
        if let id = UUID().uuidString.split("-").first {
            tag = id
        }
        
        let saveData = makePixelSaveData(imageKey,"pixelbox_\(tag)")
        
        save(saveData, "pixelbox_\(tag)")
    }
    
    func createCurrentPixelData() -> [PixelValue] {
        return pixels.map({
            PixelValue(
                id: $0.pixelID,
                color: ($0.backgroundColor ?? .black).pixelValue()
            )
        })
    }
    
    func makePixelSaveData(_ pixelKey:String,_ filename:String) -> SaveData {
        
        let pixelData = pixels.map({
            PixelValue(
                id: $0.pixelID,
                color: $0.backgroundColor!.pixelValue()
            )
        }).map({$0.store})
        
        return [
            "date" : DateFormatter.timestamp.string(from: Date()),
            "pixelKey" : pixelKey,
            "pixelData" : pixelData,
            "filename" : filename,
        ] as NSDictionary
    }
    
}




// Touches
extension PixelViewController {

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touchPoint = touches.first?.location(in: pixelContainer) {
            handleTouch(touchPoint)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let touchPoint = touches.first?.location(in: pixelContainer) {
            handleTouch(touchPoint)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        history.append(currentOperation)
        currentOperation = []
    }
    
    func getColumnPixelValues(_ pixelValue:PixelValue) -> ([PixelView],[String:Any]) {
        let x = pixelValue.id.0
        
        let columnIds = Array(0...15).map({(x,$0)})
        
        var columnPixelViews:[PixelView] = []
        
        for id in columnIds {
            for pixel in pixels where pixel.pixelID == id {
                columnPixelViews.append(pixel)
            }
        }
        
        let data = PixelValue(id: (x,0), color: selectedColor.pixelValue()).store
        return (columnPixelViews,data)
    }
    
    func handleTouch(_ touchPoint:CGPoint) {
        for pixel in pixels where pixel.frame.contains(touchPoint) {
            if rainMode {
                
                if pixel != lastTouchedPixelView {
                    
                    lastTouchedPixelView = pixel
                    let column = getColumnPixelValues(PixelValue(
                        id: pixel.pixelID,
                        color: selectedColor.pixelValue()
                    ))
                    
                    for pv in pixels {
                        if column.0.contains(pv) {
                            pv.backgroundColor = selectedColor
                        } else {
                            pv.backgroundColor = .black
                        }
                    }
                    
                    App.Audio.makeSelectionFeedback()
                    send(["img_data" :column.1], toEndPoint: "rain_add_drop")
                }
            } else {
                if pixel != lastTouchedPixelView {
                    lastTouchedPixelView = pixel
                    App.Audio.makeSelectionFeedback()
                    pixel.backgroundColor = selectedColor
                    let pv = PixelValue(
                        id: pixel.pixelID,
                        color: selectedColor.pixelValue()
                    )
                    currentOperation.append(pv)
                    send(["img_data" : pv.store], toEndPoint: "pixel_update")
                }
            }
        }
    }
    
    
}



//: MARK: - UI Setup -
extension PixelViewController {
    
    func setupUI() {
        view.backgroundColor = .lightGray
        makePixelContainer()
        setupPixelViews()
        setupButtons()
    }
    
    
    func setupButtons(){
        
        let resetButton = View.makeButton(self, #selector(resetCanvas), .red, "Reset")
        resetButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3).isActive = true
        resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        resetButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -10.0).isActive = true
        
        let undoButton = View.makeButton(self, #selector(undo), .blue, "Undo")
        undoButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/4).isActive = true
        undoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4.0).isActive = true
        undoButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -10.0).isActive = true
        
        let saveButton = View.makeButton(self, #selector(saveButtonPressed), .green, "Save")
        saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/4).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4.0).isActive = true
        saveButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -10.0).isActive = true
        
        colorPickerButton = View.makeButton(self, #selector(showColorPicker), selectedColor, "Color")
        colorPickerButton.layer.borderColor = UIColor.gray.cgColor
        colorPickerButton.layer.borderWidth = 2.0
        
        colorPickerButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/4).isActive = true
        colorPickerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        colorPickerButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 30.0).isActive = true
        
//        let timingButton = View.makeButton(self, #selector(timingButtonFired), App.Theme.Colors.interval, "Time")
//        timingButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/4).isActive = true
//        timingButton.leadingAnchor.constraint(equalTo: pixelContainer.leadingAnchor, constant: 4.0).isActive = true
//        timingButton.bottomAnchor.constraint(equalTo: pixelContainer.topAnchor, constant: -8.0).isActive = true
        
        
        let rainButton = View.makeButton(self, #selector(rainButtonFired), App.Theme.Colors.green, "Rain")
        rainButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3).isActive = true
        rainButton.trailingAnchor.constraint(equalTo: pixelContainer.trailingAnchor, constant: -4.0).isActive = true
        rainButton.bottomAnchor.constraint(equalTo: pixelContainer.topAnchor, constant: -8.0).isActive = true
        
        let baseSwitch = UISwitch()
        baseSwitch.tintColor = .black
        baseSwitch.onTintColor = .black
        baseSwitch.thumbTintColor = .white
        baseSwitch.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(baseSwitch)
        baseSwitch.addTarget(self, action: #selector(baseSwitchToggled(_:)), for: .valueChanged)
        baseSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        baseSwitch.topAnchor.constraint(equalTo: pixelContainer.bottomAnchor, constant: -2.0).isActive = true
        
//        let lowerSwitch = UISwitch()
//        lowerSwitch.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(lowerSwitch)
//        lowerSwitch.tintColor = App.Theme.Colors.tint
//        lowerSwitch.onTintColor = .blue
//        lowerSwitch.addTarget(self, action: #selector(lowerSwitchToggled(_:)), for: .valueChanged)
//        lowerSwitch.bottomAnchor.constraint(equalTo: pixelContainer.topAnchor, constant: -20.0).isActive = true
//        lowerSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -50.0).isActive = true
    }
    
    
    func makePixelContainer() {
        // Make the Pixel Container View
        pixelContainer.frame = CGRect(origin: .zero, size: .init(min(view.bounds.width,view.bounds.height), min(view.bounds.width,view.bounds.height)))
        pixelContainer.center = view.center
        view.addSubview(pixelContainer)
    }
    
    func setupPixelViews(){
        let centerSize = min(view.bounds.width,view.bounds.height)
        
        let padding: CGFloat = 4.0
        let interPixelSpacing: CGFloat = 2.0
        let totalPadding = (padding * 2) + (interPixelSpacing * 15)
        
        let pixelSize = (centerSize - totalPadding)/16
        let pixelRect = CGRect(origin: .zero, size: .init(pixelSize, pixelSize))
        
        (0..<16).forEach({ y in
            (0..<16).forEach({ x in
                let pixelView = makePixelView(pixelRect)
                pixelView.pixelID = (x,y)
                pixels.append(pixelView)
                pixelContainer.addSubview(pixelView)
                
                let rotation = CGFloat(Double.random(-360.0, 360.0) * (Double.pi/180.0))
                pixelView.transform = CGAffineTransform(rotationAngle: rotation)
                pixelView.center = pixelContainer.center
                
            })
        })
    }
    
    
}





// Utility Pixle Functions
extension PixelViewController {
    
    func makePixelView(_ frame:CGRect) -> PixelView {
        let pixel = PixelView(frame: frame)
        pixel.layer.borderColor = UIColor.black.cgColor
        pixel.layer.borderWidth = 1.0
        pixel.layer.cornerRadius = 4.0
        pixel.layer.masksToBounds = true
        pixel.backgroundColor = .white
        return pixel
    }
    

    
    func gridCenterPoints() -> [CGPoint] {
        var centerPoints: [CGPoint] = []
        let centerSize = min(view.bounds.width,view.bounds.height)
        let padding: CGFloat = 4.0
        let interPixelSpacing: CGFloat = 2.0
        let totalPadding = (padding * 2) + (interPixelSpacing * 15)
        let pSize = (centerSize - totalPadding)/16
        let pixelSize = CGSize(pSize, pSize)
        var origin = CGPoint(x: padding, y: 2.0)
        (0..<16).forEach({ y in
            (0..<16).forEach({ x in
                centerPoints.append(CGRect(origin: origin, size: pixelSize).center)
                origin.x += (pSize+interPixelSpacing)
            })
            origin.y += (pSize+interPixelSpacing)
            origin.x = padding
        })
        return centerPoints
    }
    
    
    
    func animatePixelsIntoPosition(){
        let points = gridCenterPoints()
        let ps = pixels
        for (pixel,point) in zip(ps,points) {
            UIView.animate(
                withDuration: .random(0.12, 0.65),
                delay: .random(0.01, 0.3),
                usingSpringWithDamping: CGFloat(Double.random(0.31, 0.55)),
                initialSpringVelocity: CGFloat(Double.random(0.15, 0.25)),
                options: [], animations: { [weak self] in
                    if !(self?.baseSwitch)! {
                        if pixel.backgroundColor! == .black {
                            pixel.backgroundColor = .white
                        }
                    } else {
                        if pixel.backgroundColor! == .white {
                            pixel.backgroundColor = .black
                        }
                    }
                    //pixel.backgroundColor = (self?.baseSwitch)! ? .black : .white
                    pixel.center = point
                    pixel.transform = .identity
            }, completion: nil)
        }
    }
    
    
    func resetPixelPositions(_ reset:Bool = false) {
        
        for pixel in pixels {
            let rotation = CGFloat(Double.random(-720.0, 720.0) * (Double.pi/180.0))
            pixel.transform = CGAffineTransform(rotationAngle: rotation).concatenating(CGAffineTransform(scaleX: 0.2, y: 0.2))
            pixel.center = CGPoint(x: view.center.x, y: view.center.y-200.0)
            
            if reset {
                pixel.backgroundColor = baseSwitch ? .white : .black
            } else {
                if baseSwitch {
                    if pixel.backgroundColor! == .black {
                        pixel.backgroundColor = .white
                    }
                } else {
                    if pixel.backgroundColor! == .white {
                        pixel.backgroundColor = .black
                    }
                }
            }
            
        }
    }
    
    
    
    
    
}



// Lowering...
extension PixelViewController {
    
    @objc
    func timerFire() {
        print("Timer Fired")
        lowerPixels()
    }
    
    func startTimer() {
        timer = Timer(timeInterval: timing, target: self, selector: #selector(timerFire), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
    }
    
    func startLowerPixels() {
        print("Starting Pixel Fall")
        startTimer()
    }
    
    func endLowerPixels() {
        print("Ending Pixel Fall")
        timer?.invalidate()
        timer = nil
    }
    
    func lowerPixels() {
        let loweredPixelValues = createCurrentPixelData().map({$0.lowered()})
        let imgData = loweredPixelValues.map({$0.store})
        
        // UI
        renderPixelViewsUsing(loweredPixelValues)
        // Server
        sendImageToPixelBox(["img_data" : imgData])
    }
    
    
    func renderPixelViewsUsing(_ pixelValues:[PixelValue]) {
        for pv in pixelValues {
            for pixel in pixels where pixel.pixelID == pv.id {
                pixel.backgroundColor = pv.uiColor
            }
        }
    }
    
    
    func showTimerDialog(){
        let title = "Set Pixel Fall Timing"
        let message = "Set the Timing for the Pixel Fall effect, Ya Dingus!"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .decimalPad
        }
        
        let okAction = UIAlertAction(title: "Set Timing", style: .default){ _ in
            if alert.textFields!.first!.text != "" {
                if let newValue = Double(alert.textFields!.first!.text!) {
                    self.timing = newValue
                }
            }
        }
        
        alert.addAction(okAction)
        
        alert.addAction(UIAlertAction(title: "Up", style: .default, handler: { _ in self.direction = .up }))
        alert.addAction(UIAlertAction(title: "Down", style: .default, handler: { _ in self.direction = .down}))
        alert.addAction(UIAlertAction(title: "Left", style: .default, handler: { _ in self.direction = .left }))
        alert.addAction(UIAlertAction(title: "Right", style: .default, handler: { _ in self.direction = .right }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) {_ in})
        
        
        self.present(alert, animated: true, completion: {})
    }
    
    
}





extension PixelViewController: UIPopoverPresentationControllerDelegate {
    
    @objc
    func showColorPicker(){
        let popoverVC = ColorPickerViewController()
        popoverVC.img = colorWheel
        popoverVC.modalPresentationStyle = .popover
        popoverVC.preferredContentSize = CGSize(width: (view.bounds.width * 0.90), height: view.bounds.height * 0.52  )
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.sourceView = colorPickerButton
            popoverController.sourceRect = CGRect(colorPickerButton.bounds.midX, colorPickerButton.bounds.midY+colorPickerButton.bounds.height/2, 0, 0)
            popoverController.permittedArrowDirections = .up
            popoverController.delegate = self
            popoverVC.delegate = self
        }
        present(popoverVC, animated: true, completion: nil)
        App.Audio.makeSelectionFeedback()
    }
    
    // Override the iPhone behavior that presents a popover as fullscreen
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .none
    }

}


// Image Handleing
extension PixelViewController {
    
    
    func saveImage(){
        handleNewImage(takeScreenshot(pixelContainer,true))
    }
    
    // Handle New Image
    func handleNewImage(_ img:UIImage?){
        if let image = img {
            saveImageDocumentDirectory(image, "pixel_image_\(Date().timeIntervalSince1970)")
        }
    }
    
    // Encode Image Data.
    func encodeImage(_ image:UIImage) -> Data {
        let imageData:Data = image.pngData()! as Data
        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        return Data(base64Encoded: strBase64)!
    }
    
    
    @objc
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "The screenshot has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    
}





// Data Transmission
extension PixelViewController {
    
    func sendToServer(){
        let imgData = pixels.map({
            PixelValue(
                id: $0.pixelID,
                color: $0.backgroundColor!.pixelValue()
            )
        }).map({$0.store})
        let params = ["img_data" : imgData]
        sendImageToPixelBox(params)
    }
    
    
    func sendImageToPixelBox(_ imgData:[String:Any]) {
        send(imgData, toEndPoint: "set_pixel_box")
    }
    
    
    func send(_ data:[String:Any],toEndPoint endpoint:String) {
        guard serverIsOn else { return }
        
        //create the session object
        let session = URLSession.shared
        let url = URL(string: Base.base+"\(endpoint)")!
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10.0
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else { return }
            guard let data = data else { return }
            
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                    // handle json...
                }
            } catch let error { print(error.localizedDescription) }
        })
        // Set it off
        task.resume()
    }
    
}






typealias JSONClosure = ([String:Any]) -> ()

func checkForServer(_ closure: @escaping JSONClosure) {
    
    var request = URLRequest(url:URL(string: Base.base+"ping")!)
    request.httpMethod = "POST"
    
    URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
        guard error == nil else { return }
        guard let data = data else { return }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                closure(json)
            } else {
                closure(["message":"error decoding json."])
            }
        } catch let error { closure(["message":error.localizedDescription]) }
        
    }).resume()
}


func startRain(_ closure: @escaping JSONClosure) {
    
    var request = URLRequest(url:URL(string: Base.base+"rain_toggle")!)
    request.httpMethod = "POST"
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: ["rain":"!"], options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        
    } catch let error {
        print(error.localizedDescription)
    }
    
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.timeoutInterval = 10.0
    
    URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
        guard error == nil else { return }
        guard let data = data else { return }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                closure(json)
            } else {
                closure(["message":"error decoding json."])
            }
        } catch let error { closure(["message":error.localizedDescription]) }
        
    }).resume()
}


func stopRain(_ closure: @escaping JSONClosure) {
    
    var request = URLRequest(url:URL(string: Base.base+"rain_toggle")!)
    request.httpMethod = "POST"
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: ["rain":"!"], options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        
    } catch let error {
        print(error.localizedDescription)
    }
    
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.timeoutInterval = 10.0
    
    URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
        guard error == nil else { return }
        guard let data = data else { return }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                closure(json)
            } else {
                closure(["message":"error decoding json."])
            }
        } catch let error { closure(["message":error.localizedDescription]) }
        
    }).resume()
}




