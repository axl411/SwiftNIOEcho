//
//  EchoServer.swift
//  SwiftNIOEcho
//
//  Created by Gu Chao on 2018/11/16.
//

import Foundation
import NIO

public class EchoServer {
    private let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    private let host: String
    private let port: Int

    init(host: String, port: Int) {
        self.host = host
        self.port = port
    }

    func run() throws {
        let channel = try serverBootstrap.bind(host: host, port: port).wait()
        print("\(channel.localAddress!) is now open")
        try channel.closeFuture.wait()
    }

    func shutdown() {
        do {
            try group.syncShutdownGracefully()
        } catch let error {
            print("Could not shutdown gracefully - forcing exit (\(error.localizedDescription))")
            exit(0)
        }
        print("Server closed")
    }

    private var serverBootstrap: ServerBootstrap {
        return
            ServerBootstrap(group: group)
                .serverChannelOption(ChannelOptions.backlog, value: 256)
                .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
                .childChannelInitializer { channel in
                    channel.pipeline.add(handler: BackPressureHandler()).then { v in
                        channel.pipeline.add(handler: EchoHandler())
                    }
                }
                .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
                .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
                .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
                .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())
    }
}
