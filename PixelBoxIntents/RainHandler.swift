//
//  RainHandler.swift
//  PixelBoxIntents
//
//  Created by Justin Madewell on 9/18/18.
//  Copyright © 2018 Jmade Technologies. All rights reserved.
//

import Foundation

class RainHandler: NSObject, RainIntentHandling {
    let action = "Ambilight On"
    
    func handle(intent: RainIntent, completion: @escaping (RainIntentResponse) -> Void) {
        let messageController = MessageInfoController()
        messageController.sendAction(action) { (messageResponse) in
            if let messageResponse = messageResponse {
                completion(RainIntentResponse.success(serverMessage: messageResponse.serverMessage))
            } else {
                completion(RainIntentResponse.success(serverMessage: "No Message"))
            }
        }
    }
    
    func confirm(intent: RainIntent, completion: @escaping (RainIntentResponse) -> Void) {
        completion(RainIntentResponse(code: .ready, userActivity: nil))
    }
}


