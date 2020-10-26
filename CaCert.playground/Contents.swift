import Foundation
import PlaygroundSupport

// convert pem to der
// openssl x509 -in callisto_staging_ca.pem -outform der -out callisto_staging_ca.der
let certUrl = Bundle.main.url(forResource: "callisto_staging_ca", withExtension: "der")!
let certData = try! Data(contentsOf: certUrl)

print("Data count: \(certData.count)")

let cert = SecCertificateCreateWithData(nil, certData as CFData)!
print("cert: \(cert)")
let summary = SecCertificateCopySubjectSummary(cert)! as String
print("cert summary: \(summary)")

let ip = "52.72.125.50"

let url = URL(string: "https://\(ip)/hello")!

class Handler: NSObject, URLSessionDelegate {
 
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let trust = challenge.protectionSpace.serverTrust!
        
        let err = SecTrustSetAnchorCertificates(trust, [cert] as CFArray)
        if err != errSecSuccess {
            print("failed to set trust anchor certs")
        }
        
        let err2 = SecTrustSetAnchorCertificatesOnly(trust, false)
        if err2 != errSecSuccess {
            print("failed to disable 'anchor certs only'")
        }
        if evaluate(trust: trust) {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            print("Eval failed!")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
    
    func evaluate(trust: SecTrust) -> Bool {
        var error: CFError?
        let isTrusted = SecTrustEvaluateWithError(trust, &error)
        if let error = error {
            print("Eval failed with error: \(error.localizedDescription)")
            print("Full error: \(error)")
        }
        return isTrusted
    }
    
}

let handler = Handler()

let session = URLSession(configuration: .default,
                         delegate: handler,
                         delegateQueue: nil)

session.dataTask(with: url, completionHandler: { data, response, error in
    if let error = error {
        print(error)
    }
    if let response = response {
        print(response)
    }
}).resume()

PlaygroundPage.current.needsIndefiniteExecution = true


