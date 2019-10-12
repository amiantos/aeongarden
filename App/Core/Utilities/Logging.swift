//
//  Logging.swift
//  Aeon Garden
//
//  Created by Brad Root on 10/6/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Foundation

/**
 *  A simple log that outputs to the console via ```print()````
 */
open class Log {
    // MARK: Configuration

    /**
     Represents a level of detail to be logged.
     */
    public enum Level: Int {
        case verbose
        case debug
        case info
        case warn
        case error
        case off

        var name: String {
            switch self {
            case .verbose: return "Verbose"
            case .debug: return "Debug"
            case .info: return "Info"
            case .warn: return "Warn"
            case .error: return "Error"
            case .off: return "Disabled"
            }
        }

        var emoji: String {
            switch self {
            case .verbose: return "📖"
            case .debug: return "🐝"
            case .info: return "✏️"
            case .warn: return "⚠️"
            case .error: return "⁉️"
            case .off: return ""
            }
        }
    }

    /// The log level, defaults to .Off
    public static var logLevel: Level = .off

    /// If true, prints emojis to signify log type, defaults to off
    public static var useEmoji: Bool = true

    /// If this is non-nil, we will call it with the same string that we
    /// are going to print to the console. You can use this to pass log
    /// messages along to your crash reporter, analytics service, etc.
    /// - warning: Be mindful of private user data that might end up in
    ///            your log statements! Use log levels appropriately
    ///            to keep private data out of logs that are sent over
    ///            the Internet.
    public static var handler: ((Level, String) -> Void)?

    // MARK: Private

    /// Date formatter for log
    private static let dateformatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "Y-MM-dd H:m:ss.SSSS"
        return dateFormatter
    }()

    /// Generic log method
    private static func log<T>(_ object: @autoclosure () -> T, level: Log.Level, _ fileName: String, _: String, _ line: Int) {
        if logLevel.rawValue <= level.rawValue {
            let date = Log.dateformatter.string(from: Date())
            let components: [String] = fileName.components(separatedBy: "/")
            let objectName = components.last ?? "Unknown Object"
            let levelString = Log.useEmoji ? level.emoji : "|" + level.name.uppercased() + "|"
            let logString = "\(levelString) [\(date)] \(objectName) line \(line): \(object())"
            print(logString)
            handler?(level, logString)
        }
    }

    // MARK: Log Methods

    public static func error<T>(
        _ object: @autoclosure () -> T,
        _ fileName: String = #file,
        _ functionName: String = #function,
        _ line: Int = #line
    ) {
        log(object(), level: .error, fileName, functionName, line)
    }

    public static func warn<T>(
        _ object: @autoclosure () -> T,
        _ fileName: String = #file,
        _ functionName: String = #function,
        _ line: Int = #line
    ) {
        log(object(), level: .warn, fileName, functionName, line)
    }

    public static func info<T>(
        _ object: @autoclosure () -> T,
        _ fileName: String = #file,
        _ functionName: String = #function,
        _ line: Int = #line
    ) {
        log(object(), level: .info, fileName, functionName, line)
    }

    public static func debug<T>(
        _ object: @autoclosure () -> T,
        _ fileName: String = #file,
        _ functionName: String = #function,
        _ line: Int = #line
    ) {
        log(object(), level: .debug, fileName, functionName, line)
    }

    public static func verbose<T>(
        _ object: @autoclosure () -> T,
        _ fileName: String = #file,
        _ functionName: String = #function,
        _ line: Int = #line
    ) {
        log(object(), level: .verbose, fileName, functionName, line)
    }
}
