import Foundation

let server = EchoServer(host: "localhost", port: 1717)
do {
    try server.run()
} catch let error {
    print("Error: \(error.localizedDescription)")
    server.shutdown()
}
