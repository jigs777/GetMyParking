//
//  Constant.swift
//

import Foundation
import UIKit

/**Log trace*/
//#MARK: - Log trace
public func DLog<T>(_ message:T,  file: String = #file, function: String = #function, lineNumber: Int = #line ) {
    #if DEBUG
    if let text = message as? String {
        print("\((file as NSString).lastPathComponent) -> \(function) line: \(lineNumber): \(text)")
    }
    #endif
}
let kdefaults = UserDefaults.standard
