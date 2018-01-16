//
//  NetworkComm.swift
//  Conway Game of Life
//
//  Created by Shannon on 1/5/18.
//  Copyright © 2018 GGDragonStudios. All rights reserved.
//

import UIKit

protocol NetworkCommDelegate: class {
    func receivedMessage(message: Message)
}

class NetworkComm: NSObject {
    // holds reference to NetworkComm's current delegate
    weak var delegate: NetworkCommDelegate?
    
    // Create socket-based connection between app and chat server
    var inputStream: InputStream!
    var outputStream: OutputStream!
    
    // name of current user
    var username = ""
    
    // max length of message
    let maxReadLength = 4096
    
    func setupNetworkCommunication() {
        // Set up socket streams
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        // Bind read and write socket streams together
        // connect them to the socket of the host (80)
        // last 2 args: pointers to read and write streams to be initialized by the function
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, "127.0.0.1" as CFString, 22000, &readStream, &writeStream)
        
        // store references; prevents memroy leaks
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        // conform to StreamDelegate protocol
        inputStream.delegate = self
        
        // allow app to react to networking events
        inputStream.schedule(in: .current, forMode: .commonModes)
        outputStream.schedule(in: .current, forMode: .commonModes)
        
        inputStream.open()
        outputStream.open()
    }
    
    func joinChat(username: String) {
        // construct message using a predefined protocol
        let data = "iam: \(username)".data(using: .ascii)!
        
        // save name that gets passed in to be used for sending messages later
        self.username = username
        
        // write message to output stream
        _ = data.withUnsafeBytes { outputStream.write($0, maxLength: data.count) }
    }
    
    func sendMessage(header: String, message: String) {
        let data = "\(header):\(message)".data(using: .ascii)!
        
        _ = data.withUnsafeBytes { outputStream.write($0, maxLength: data.count) }
    }
    
    func stopChatSession() {
        inputStream.close()
        outputStream.close()
    }
}

// catches messages and turns them into Message objects
extension NetworkComm: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            print("New message received")
            readAvailableBytes(stream: aStream as! InputStream)
        case Stream.Event.endEncountered:
            print("New message recevied")
            stopChatSession()
        case Stream.Event.errorOccurred:
            print("Encountered an error")
        case Stream.Event.hasSpaceAvailable:
            print("Has space available")
        default:
            print("Unknown event occurred")
            break
        }
    }
    
    // handles incoming messages
    private func readAvailableBytes(stream: InputStream) {
        // set up a buffer to read incoming bytes
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        
        // loop as long as the input stream has bytes that need to be read
        while stream.hasBytesAvailable {
            // call read(_:maxLength:) to read bytes from stream and put them into a buffer
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
            
            // if error on read...
            if numberOfBytesRead < 0 {
                if let _ = inputStream.streamError {
                    break
                }
            }
            if let message = processedMessageString(buffer: buffer, length: numberOfBytesRead) {
                // notify people involved
                delegate?.receivedMessage(message: message)
            }
            
            
            
        }
    }
    
    private func processedMessageString(buffer: UnsafeMutablePointer<UInt8>, length: Int) -> Message? {
        // initialize a String to hold the stuff in the buffer
        // treat text as ASCII and free buffer when done
        // split on ':' to parse message contents
        guard let stringArray = String(bytesNoCopy: buffer, length: length, encoding: .ascii, freeWhenDone: true)?.components(separatedBy: ":"),
            let header = stringArray.first,
            let message = stringArray.last else {
                return nil
        }
//        
//        // figure out if I or someone else sent the message
//        let messageSender:MessageSender = (name == self.username) ? .ourself : .someoneElse
        
        // construct a Message with the info and return it
        return Message(message: message, header: header)
    }
}
