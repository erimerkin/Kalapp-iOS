//
//  Networking.swift
//  Kalapp
//
//  Created by Arkhin & Barziş on 13.02.2018.
//  Copyright © 2018 KalÖM. All rights reserved.
//

import Foundation
import Alamofire


class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}


