import Foundation

typealias JSONClosure = ([String:Any]) -> ()

struct MessageResponse {
    var serverMessage:String
    
    init(_ json:[String:Any]) {
        self.serverMessage = json["message"] as? String ?? "-"
    }
}


struct MessageInfoController {
    
    func sendAction(_ action:String,completion: @escaping (MessageResponse?) -> Void) {
        startRain {
            completion(MessageResponse($0))
        }
    }
    
}

extension MessageInfoController {
    
    private
    func makeRequestFor(_ action:String,completion: @escaping (MessageResponse?) -> Void) {


        func makeBodyData(_ params:[String:String]) -> Data {
            let encodedParams = "&"+params.map {"\($0)=\($1)"}.joined(separator: "&")
            return encodedParams.data(using: .utf8, allowLossyConversion: false)!
        }
        
        let parameters:[String:String] = [
            "action" : action,
        ]
        
        let httpBodyData = makeBodyData(parameters)
        
        var request = URLRequest(url:URL(string: "http://192.168.0.21:8080/siri")!)
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("\(httpBodyData.count)", forHTTPHeaderField: "Content-Length")
        request.httpMethod = "POST"
        request.httpBody = httpBodyData
        request.timeoutInterval = 10.0
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(data ?? "-")
            
            guard let data = data else {
                DispatchQueue.main.async(execute: {
                    print("Error No Data")
                    completion(nil)
                })
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] {
                    DispatchQueue.main.async(execute: {
                      completion(MessageResponse(json))
                    })
                    
                }
            } catch let error {
                print("Error Parsing JSON: \(error.localizedDescription)")
                DispatchQueue.main.async(execute: {
                    completion(nil)
                })
            }
        
        }
        
        task.resume()
    }
    
}



extension MessageInfoController {
    
    private
    func makeActionRequest(_ action:String,completion: @escaping (MessageResponse?) -> Void) {
        
        let powerTVOn = "TV Power On"
        let atvMenu = "Menu"
        
        func makeBodyData(_ params:[String:String]) -> Data {
            let encodedParams = "&"+params.map {"\($0)=\($1)"}.joined(separator: "&")
            return encodedParams.data(using: .utf8, allowLossyConversion: false)!
        }
        
        let parameters:[String:String] = [
            "action" : action,
            ]
        
        let httpBodyData = makeBodyData(parameters)
        
        var request = URLRequest(url:URL(string: "http://192.168.0.5:8080/siri")!)
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("\(httpBodyData.count)", forHTTPHeaderField: "Content-Length")
        request.httpMethod = "POST"
        request.httpBody = httpBodyData
        request.timeoutInterval = 10.0
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(data ?? "-")
            
            guard let data = data else {
                DispatchQueue.main.async(execute: {
                    print("Error No Data")
                    completion(nil)
                })
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] {
                    DispatchQueue.main.async(execute: {
                        completion(MessageResponse(json))
                    })
                    
                }
            } catch let error {
                print("Error Parsing JSON: \(error.localizedDescription)")
                DispatchQueue.main.async(execute: {
                    completion(nil)
                })
            }
            
        }
        
        task.resume()
    }
    
}



extension MessageInfoController {
    
    private
    func startRain(_ closure: @escaping JSONClosure) {
        
        var request = URLRequest(url:URL(string: "http://192.168.0.21:8080/rain_start")!)
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

    
}



