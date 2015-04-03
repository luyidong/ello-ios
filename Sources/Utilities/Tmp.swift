//
//  Tmp.swift
//  Ello
//
//  Created by Colin Gray on 3/18/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct Tmp {
    public static let uniqDir = Tmp.uniqueName()

    public static func fileExists(fileName: String) -> Bool {
        let fileURL = self.fileURL(fileName)
        if let filePath = fileURL.path {
            return NSFileManager.defaultManager().fileExistsAtPath(filePath)
        }
        else {
            return false
        }
    }

    public static func directoryURL() -> NSURL {
        let directoryName = NSTemporaryDirectory().stringByAppendingPathComponent(Tmp.uniqDir)
        return NSURL.fileURLWithPath(directoryName, isDirectory: true)!
    }

    public static func fileURL(fileName: String) -> NSURL {
        let fileURL = directoryURL().URLByAppendingPathComponent(fileName)
        return fileURL
    }

    static func uniqueName() -> String {
        return NSProcessInfo.processInfo().globallyUniqueString
    }

    public static func write(toDataable: ToNSData, to fileName: String) -> NSURL? {
        if let data = toDataable.toNSData() {
            let directoryURL = self.directoryURL()
            NSFileManager.defaultManager().createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil, error: nil)

            let fileURL = self.fileURL(fileName)
            data.writeToURL(fileURL, atomically: true)

            return fileURL
        }
        return nil
    }

    public static func read(fileName: String) -> NSData? {
        if fileExists(fileName) {
            return NSData(contentsOfURL: fileURL(fileName))
        }
        return nil
    }

    public static func read(fileName: String) -> String? {
        if let data : NSData = read(fileName) {
            return NSString(data: data, encoding: NSUTF8StringEncoding) as? String
        }
        return nil
    }

    public static func read(fileName: String) -> UIImage? {
        if let data : NSData = read(fileName) {
            return UIImage(data: data)
        }
        return nil
    }

    public static func remove(fileName: String) -> Bool {
        let fileURL = self.fileURL(fileName)
        if let filePath = fileURL.path {
            if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
                return NSFileManager.defaultManager().removeItemAtPath(filePath, error: nil)
            }
        }
        return false
    }

}
