//
//  SocketClient.swift
//  WatsonSTT
//
//  Created by Eralp Karaduman on 12/17/16.
//  Copyright © 2016 Super Damage. All rights reserved.
//

import Starscream

typealias JsonObject = [String: Any?]

protocol SocketClientDelegate: class {
    func socketClientDidConnect(socketClient: SocketClient)
    func socketClientDidDisconnect(socketClient: SocketClient)
    func socketClient(_ socketClient: SocketClient, didReceiveJsonObject jsonObject: JsonObject)
}

class SocketClient {

    private var socket: WebSocket? = nil

    weak var delegate: SocketClientDelegate? = nil

    var connected: Bool {
        return socket?.isConnected ?? false
    }

    init() {

    }

    func connect(streamURLString: String, token: String) {

        socket?.delegate = nil
        socket?.disconnect()

        var components = URLComponents(string: streamURLString)
        components?.scheme = "wss"
        guard let baseURL  = components?.url else { fatalError() }

        let url = baseURL.appendingQueryParameters([
            "model": "en-US_BroadbandModel"
        ])

        socket = WebSocket(url: url)
        socket?.headers = [
            "X-Watson-Authorization-Token": token
        ]
        socket?.delegate = self
        socket?.connect()
    }

    func writeJSON(_ json: [String: Any?]) {

        guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }
        guard let dataString = String(data: data, encoding: .utf8) else { return }
        socket?.write(string: dataString)
    }

    func writeData(_ data: Data) {
        socket?.write(data: data)

    }
}

extension SocketClient: WebSocketDelegate {

    func websocketDidConnect(socket: WebSocket) {
        delegate?.socketClientDidConnect(socketClient: self)
    }

    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        delegate?.socketClientDidDisconnect(socketClient: self)
    }

    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        guard let data = text.data(using: .utf8) else { return }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data)
        as? JsonObject else { return }

        if let jsonObject = jsonObject {
            delegate?.socketClient(self, didReceiveJsonObject: jsonObject)
        }
    }

    func websocketDidReceiveData(socket: WebSocket, data: Data) {

    }
}
