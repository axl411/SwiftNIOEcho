//
//  EchoHandler.swift
//  SwiftNIOEcho
//
//  Created by Gu Chao on 2018/11/16.
//

import Foundation
import NIO

class EchoHandler: ChannelInboundHandler {
    public typealias InboundIn = ByteBuffer
    public typealias OutboundOut = ByteBuffer

    private var context: ChannelHandlerContext?
    lazy private var timer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource()
        timer.setEventHandler { [weak self] in
            guard let `self` = self else { return }
            guard let context = self.context else { return }
            self.send(ctx: context)
//            DispatchQueue.global().asyncAfter(deadline: .now() + 4, execute: {
//                context.eventLoop.execute {
//                    context.close(promise: nil)
//                }
//            })
        }
        timer.schedule(deadline: .now(), repeating: 2)
        return timer
    }()

    var shouldSend = false {
        didSet {
            if shouldSend {
                timer.resume()
            } else {
                timer.suspend()
            }
        }
    }

    func channelRegistered(ctx: ChannelHandlerContext) {
        print(#function)
    }

    func channelUnregistered(ctx: ChannelHandlerContext) {
        print(#function)
    }

    func channelActive(ctx: ChannelHandlerContext) {
        print(#function)
        shouldSend = true
        context = ctx
    }

    func channelInactive(ctx: ChannelHandlerContext) {
        print(#function)
        shouldSend = false
    }

    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        var buffer = unwrapInboundIn(data)
        let readableBytes = buffer.readableBytes
        if let received = buffer.readString(length: readableBytes) {
            print("Received: \(received)")
        }
    }

//    func channelReadComplete(ctx: ChannelHandlerContext) {
//        print(#function)
//    }

    public func errorCaught(ctx: ChannelHandlerContext, error: Error) {
        print("error: ", error)
        ctx.close(promise: nil)
    }

    private func send(ctx: ChannelHandlerContext) {
        ctx.eventLoop.execute {
            let echo = "[ServerPing]"
            var buffer = ctx.channel.allocator.buffer(capacity: echo.utf8.count)
            buffer.write(string: echo)
            if self.shouldSend {
                _ = ctx.writeAndFlush(self.wrapOutboundOut(buffer))
//                print("ServerPing sent")
            }
        }
    }
}
