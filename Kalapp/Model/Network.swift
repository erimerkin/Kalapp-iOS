////
////  Network.swift
////  Kalapp
////
////  Created by Arkhin on 1.02.2018.
////  Copyright © 2018 KalÖM. All rights reserved.
////
//
//import Foundation
//import Moya
//
//enum KalappAPI {
//    
//    //MARK: - User
//    case login(userName: Int, password: String, frbToken: String)
//    case userInfo
//    case changeDetails
//    
//    
//    //MARK: - Duyuru
//    case duyuruGetir
//    case duyuruArama
//    
//    //MARK: - Anket
//    case anketGetir
//    case anketArama
//}
//
//extension KalappAPI: TargetType {
//
//    var baseURL : URL { return URL(string: "http://kalapp.kalfest.com/?action=")!}
//    
//    var path: String {
//        switch self {
//            
//        case .login:
//            return "login"
//            
//        case .userInfo:
//            return "user_info"
//            
//        case .changeDetails:
//            return "update_user"
//            
//        case .duyuruGetir:
//            return "duyuru"
//            
//        case .duyuruArama:
//            return "search&do=duyuru"
//            
//        case .anketGetir:
//            return "anket"
//            
//        case .anketArama:
//            return "search&do=anket"
//            
//    }
//        
//    var method: Moya.Method {
//        return .get
//    }
//        
//    var parameterEncoding: ParameterEncoding {
//            return JSONEncoding.default
//        }
//        
//        
//    var sampleData: Data {
//            return Data()
//    }
//        
//        
//
//        
//    var parameters: [String: Any]? {
//        switch self {
//                
//            case .login(let userName, let password, let frbToken):
//                var parameters = [String : Any?]()
//                parameters["okul_no"] = userName
//                parameters["pass"] = password
//                parameters["fcms_token"] = frbToken
//                return parameters
//                
//            default:
//                return nil
//        }
//    }
//        
//    }
//}

