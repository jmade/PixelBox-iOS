
import UIKit

struct Base {
    static let prefix = "http://"
    static let base = prefix+home+":8080/"
    static let ft_wayne = "10.0.1.9"
    static let home = "192.168.0.6"
}



//: MARK: - API Error -
struct APIError {
    let endpoint: String
    let message: String
    let status: Int
    init(_ data:[String:Any]){
        self.endpoint = data["endpoint"] as? String ?? ""
        self.message = data["message"] as? String ?? ""
        self.status = data["status"] as? Int ?? 0
    }
    func toDictionary() -> [String:String] {
        return [
            "Endpoint" : endpoint,
            "Message" : message,
            "Status" : "\(status)"
        ]
    }
}


//: MARK: - Networking -
//
typealias APICompletionClosure = (CheckedJSON) -> Void

//: MARK: - APIRequest -
struct APIRequest {
    let endpoint: String
    let sender: UIViewController?
    let additionalParameters:[String: String]?
    let completion: APICompletionClosure
    init(_ endpoint:String = Base.base+"set_pixel_box",_ sender:UIViewController? = nil,_ additionalParameters:[String: String]? = nil,_ completion: @escaping APICompletionClosure = { _ in } ){
        self.endpoint = endpoint
        self.sender = sender
        self.additionalParameters = additionalParameters
        self.completion = completion
    }
}


extension APIRequest {
    
    var parameters: [String:String] {
        get {
            var returnParams: [String:String] = [
                "mobile_id": UIDevice.current.identifierForVendor?.uuidString ?? "",
            ]
            guard let additionalParams = additionalParameters else { return returnParams }
            for key in additionalParams.keys {
                if let value = additionalParams[key] {
                    returnParams.updateValue(value, forKey: key)
                }
            }
            return returnParams
        }
    }
    
    var url: URL {
        get {
            return URL(string: endpoint)!
        }
    }
    
    var bodyData: Data {
        get {
            func makeBodyData(_ params:[String:String]) -> Data {
                let encodedParams = "&"+params.map {"\($0)=\($1)"}.joined(separator: "&")
                return encodedParams.data(using: .utf8, allowLossyConversion: false)!
            }
            return makeBodyData(parameters)
        }
    }
    
    var request: URLRequest {
        get {
            var request = URLRequest(url:url)
            request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue("\(bodyData.count)", forHTTPHeaderField: "Content-Length")
            request.httpMethod = "POST"
            request.httpBody = bodyData
            request.timeoutInterval = 10.0
            return request
        }
    }
    
}


//: MARK: - makeAPIRequest -
func makeAPIRequestWith(_ apiRequest:APIRequest) {
    URLSession.shared.dataTask(with: apiRequest.request) { (data, response, error) in
        if error != nil {
            print("URL Session Error: \(String(describing: error))")
            DispatchQueue.main.async(execute: {
                apiRequest.completion(CheckedJSON(["Error No Data":500]))
            })
            return
        }
        
        guard data != nil else {
            DispatchQueue.main.async(execute: {
                apiRequest.completion(CheckedJSON(["Error No Data":500]))
            })
            return
        }
        let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
        guard responseJSON != nil else {
            DispatchQueue.main.async(execute: {apiRequest.completion(CheckedJSON(["success":500]))})
            return
        }
        
        // Handle Response
        if let httpResponse = response as? HTTPURLResponse {
            print("Response Code: \(httpResponse.statusCode)")
            switch httpResponse.statusCode {
            case 200:
                DispatchQueue.main.async(execute: {
                    apiRequest.completion(CheckedJSON(responseJSON))
                })
            case 403:
                print("Not Authenticated")
            default:
                break
            }
        }
    }.resume()
}


//: MARK: - CheckedJSON -

struct CheckedJSON {
    var value: [String:Any]
    init(_ data:[String:Any]?){
        if let unwrappedData = data {
            value = unwrappedData
        } else {
            value = [:]
        }
    }
    
    var isUsable: Bool {
        get {
            if let status = value["success"] as? Int {
                if status == 500 {
                    return false
                } else {
                    return true
                }
            } else {
                return false
            }
        }
    }
}

//: MARK: - decodeInto Item -
extension CheckedJSON {
    func decodeInto<Item>(_ key:String,_ mapFunc: @escaping ([String:Any]) -> Item) -> [Item]? {
        guard
            isUsable,
            let list = value[key] as? [[String:Any]]
        else { return nil }
        return list.map({mapFunc($0)})
    }
}


//: MARK: - LOADINGVIEW -

// UIView
func addLoadingView(_ toView:UIView,_ opaque:Bool=false){
    DispatchQueue.main.async(execute: {
        let loadingView = LoadingView(frame: .zero)
        if opaque { loadingView.backgroundColor = UIColor(white: 1.0, alpha: 1.0) }
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        toView.addSubview(loadingView)
        toView.bringSubviewToFront(loadingView)
        loadingView.topAnchor.constraint(equalTo: toView.topAnchor).isActive = true
        loadingView.bottomAnchor.constraint(equalTo: toView.bottomAnchor).isActive = true
        loadingView.leadingAnchor.constraint(equalTo: toView.leadingAnchor).isActive = true
        loadingView.trailingAnchor.constraint(equalTo: toView.trailingAnchor).isActive = true
    })
}


func removeLoadingView(_ fromView:UIView){
    DispatchQueue.main.async(execute: {
        for view in fromView.subviews {
            if view is LoadingView {
                (view as! LoadingView).end()
            }
        }
    })
}

//: MARK: - MessageView -  
func addMessageViewTo(_ toView:UIView,_ message:String){
    let messageView = UIView()
    messageView.backgroundColor = UIColor(white: 0.98, alpha: 0.7)
    let label = UILabel()
    label.text = message
    
    label.font = UIFont.preferredFont(forTextStyle: .headline)
    label.textAlignment = .center
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    label.translatesAutoresizingMaskIntoConstraints = false
    
    messageView.addSubview(label)
    label.topAnchor.constraint(equalTo: messageView.topAnchor).isActive = true
    label.leadingAnchor.constraint(equalTo: messageView.leadingAnchor).isActive = true
    label.trailingAnchor.constraint(equalTo: messageView.trailingAnchor).isActive = true
    label.bottomAnchor.constraint(equalTo: messageView.bottomAnchor).isActive = true
    messageView.translatesAutoresizingMaskIntoConstraints = false
    
    toView.addSubview(messageView)
    messageView.topAnchor.constraint(equalTo: toView.topAnchor).isActive = true
    messageView.bottomAnchor.constraint(equalTo: toView.bottomAnchor).isActive = true
    messageView.leadingAnchor.constraint(equalTo: toView.leadingAnchor).isActive = true
    messageView.trailingAnchor.constraint(equalTo: toView.trailingAnchor).isActive = true
}



//: MARK: - API Error Handling

func newHandleAPIError(apiError: APIError,
                       msg: String?,
                       viewController: UIViewController?,
                       retryFunction: (()->())?)
{
    guard let vc = viewController else { return }
    
    let errorView = UIView()
    errorView.backgroundColor = UIColor(white: 0.20, alpha: 0.99)
    
    let errorLabel = UILabel()
    errorLabel.text = "Error Retrieving \(apiError.endpoint)"
    errorLabel.textColor = .white
    errorLabel.translatesAutoresizingMaskIntoConstraints = false
    errorLabel.textAlignment = .center
    errorLabel.font = UIFont.preferredFont(forTextStyle: .body)
    errorLabel.adjustsFontSizeToFitWidth = true
    errorLabel.allowsDefaultTighteningForTruncation = true
    errorLabel.numberOfLines = 0
    errorLabel.lineBreakMode = .byWordWrapping
    errorView.addSubview(errorLabel)
    errorLabel.topAnchor.constraint(equalTo: errorView.topAnchor).isActive = true
    errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor).isActive = true
    errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor).isActive = true
    errorLabel.bottomAnchor.constraint(equalTo: errorView.bottomAnchor).isActive = true
    
    let errorSize = CGSize(width: vc.view.bounds.size.width * 0.90, height: 52.0)
    let visibleY = vc.view.bounds.size.height-errorSize.height
    let underY = vc.view.bounds.size.height+errorSize.height
    let errorOrigin = CGPoint(x:(vc.view.bounds.size.width - errorSize.width)/2,y: underY)
    let underRect = CGRect(origin: errorOrigin, size: errorSize)
    let visibleRect = CGRect(x: errorOrigin.x,y: visibleY,width: errorSize.width,height: errorSize.height)
    
    let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: errorSize), byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: 12, height: 12))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    errorView.layer.mask = mask
    
    errorView.alpha = 0
    vc.view.addSubview(errorView)
    
    errorView.frame = underRect
    
    UIView.animate(withDuration: 1.0, animations: {
        errorView.alpha = 1.0
        errorView.frame = visibleRect
    }) { (complete) in
        UIView.animate(withDuration: 0.5, delay: 3.5, options: [], animations: {
            errorView.frame = underRect
            errorView.alpha = 0
        }) { (complete) in
            errorView.removeFromSuperview()
        }
    }
}



//: MARK: - NEWLOADINGVIEW -
public class LoadingView : UIView {
    
    let loadingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.text = "LOADING"
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let progress: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    required public init?(coder aDecoder: NSCoder) {fatalError()}
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        addSubview(progress)
        addSubview(loadingLabel)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: progress, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: progress, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 30.0),
            NSLayoutConstraint(item: loadingLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: loadingLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 52.0),
            ])
    }
    
    override public func willRemoveSubview(_ subview: UIView) {
        if subview == progress { progress.stopAnimating() }
        super.willRemoveSubview(subview)
    }
    
    override public func didMoveToWindow() {
        super.didMoveToWindow()
        progress.startAnimating()
    }
    
    public func end(){
        DispatchQueue.main.async(execute: { [weak self] in
            UIView.animate(withDuration: 1/3, animations: {
                self?.alpha = 0
            }, completion: { _ in
                self?.removeFromSuperview()
            })
        })
    }
}














