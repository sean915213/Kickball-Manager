//
//  Logger.swift
//
//  Created by Sean G Young on 2/8/15.
//  Copyright (c) 2015 Sean G Young. All rights reserved.
//

import Foundation

public typealias LoggingBlock = (String) -> Void

// Defaults
fileprivate let defaultLogFormat = "[\(Logger.FormatPlaceholder.sourceName.rawValue)] \(Logger.FormatPlaceholder.level.rawValue) - \(Logger.FormatPlaceholder.value.rawValue)"
fileprivate let defaultLogBlock: LoggingBlock = { NSLog($0) }

/**
 *  Provides a logging interface with a predefined structure.
 */
public class Logger {
    
    // MARK: - Static Enums
    
    /**
     The log levels supported by Logger.
     
     - debug: A debugging logging.  Generally considered temporary.
     - info: An informational log.  Denotes a log that is useful to see and indicates no problems.
     - warning: A warning log.  Denotes an issue that can be recovered from, but should be noted as it is likely not functioning properly.
     - error: An error log.  Denotes a crtitical error that may or may not be recovered from and should be addressed immediately.
     */
    public enum Level: String {
        case debug = "Debug",
        info = "Info",
        warning = "Warning",
        error = "Error"
    }
    
    public enum FormatPlaceholder: String {
        case sourceName = "$context",
        level = "$logLevel",
        value = "$logValue"
    }
    
    // MARK: - Initialization
    
    /**
     Initializes a SerialLogger instance.
     
     :param: source The name that all logs printed using this instance will be prefixed with.
     
     :returns: An instance of the SerialLogger class.
     */
    public convenience init(source: String) {
        // Use default log format
        self.init(source: source, logFormat: defaultLogFormat, logBlock: defaultLogBlock)
    }
    
    public convenience init(source: String, logBlock: @escaping LoggingBlock) {
        // Use default log format
        self.init(source: source, logFormat: defaultLogFormat, logBlock: logBlock)
    }
    
    public init(source: String, logFormat: String, logBlock: @escaping LoggingBlock) {
        self.source = source
        self.logFormat = logFormat
        self.logBlock = logBlock
    }
    
    // MARK: - Properties
    
    /// The description prefixed to logs.  Assigned on initialization.
    public var source: String
    /// The format used to create the final logging string.
    public let logFormat: String
    /// The block used to perform actual logging action.
    fileprivate let logBlock: LoggingBlock
    
    // MARK: - Methods
    
    /**
     Executes a log statement.
     
     :param: description The text to log.
     :param: level       The log level to display.
     */
    public func log(_ description: String, level: Level = .debug) {
        // Create log description by replacing placeholders w/ their respective values
        var log = logFormat.replacingOccurrences(of: FormatPlaceholder.sourceName.rawValue, with: source)
        log = log.replacingOccurrences(of: FormatPlaceholder.level.rawValue, with: level.rawValue)
        log = log.replacingOccurrences(of: FormatPlaceholder.value.rawValue, with: description)
        // Log it
        logBlock(log)
    }
}

// MARK: Convenience Methods Extension

extension Logger {
    
    public func logDebug(_ value: String) {
        log(value, level: .debug)
    }
    
    public func logInfo(_ value: String) {
        log(value, level: .info)
    }
    
    public func logWarning(_ value: String) {
        log(value, level: .warning)
    }
    
    public func logError(_ value: String) {
        log(value, level: .error)
    }
}

// MARK: Type Source Extensions

extension Logger {
    
    public class func log(_ description: String, from source: Any.Type, level: Logger.Level) {
        Logger(source: source).log(description, level: level)
    }
    
    public class func logDebug(_ description: String, from source: Any.Type) {
        log(description, from: source, level: .debug)
    }
    
    public class func logInfo(_ description: String, from source: Any.Type) {
        log(description, from: source, level: .info)
    }
    
    public class func logWarning(_ description: String, from source: Any.Type) {
        log(description, from: source, level: .warning)
    }
    
    public class func logError(_ description: String, from source: Any.Type) {
        log(description, from: source, level: .error)
    }
    
    public convenience init(source: Any.Type) {
        self.init(source: String(describing: source))
    }
}
