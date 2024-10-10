//
//  Logger.swift
//  Cafeyn
//
//  Created by Antoine Antoiniol on 07/10/2024.
//

import Foundation

//Logger types
enum LogType: String {
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case success = "SUCCESS"
    case requestError = "REQUEST_ERROR"
    case noData = "NO_DATA_RECEIVED"
    case decodingError = "DECODING_ERROR"
    
    var logDescription: String {
        switch self {
        case .info: 
            return "Fetching data from URL:"
        case .warning: 
            return "Invalid response from server 🚫 :"
        case .error: 
            return "Invalid URL 🚫 :"
        case .success:
            return "Data successfully decoded ✅"
        case.requestError:
            return "Request failed with error 🚫"
        case .noData:
            return "No data received from server 🚫"
        case .decodingError:
            return "Decoding error 🚫"
        }
    }
}

class Logger {
    
    static func log(message: String, level: LogType = .info, file: String = #file, function: String = #function, line: Int = #line) {
        
        //Date for log message
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let timestamp = dateFormatter.string(from: Date())
        
        let fileName = (file as NSString).lastPathComponent
        
        let logMessage = "[\(timestamp)] [\(level.rawValue)] [\(fileName):\(line)] \(function): \(message)"
        
        print(logMessage)
    }
    
    //Logger for info
    static func info(message: String) {
        log(message: message, level: .info)
    }
    
    //Logger for warning
    static func warning(message: String) {
        log(message: message, level: .warning)
    }
    
    //Logger for erroe
    static func error(message: String) {
        log(message: message, level: .error)
    }
    
    //Logger for debug
    static func debug(message: String) {
        log(message: message, level: .success)
    }
}
