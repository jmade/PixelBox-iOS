//
//  IntentHandler.swift
//  PixelBoxIntents
//
//  Created by Justin Madewell on 9/18/18.
//  Copyright © 2018 Jmade Technologies. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        if intent is RainIntent {
            return RainHandler()
        }
        
        return self
    }
    
}
