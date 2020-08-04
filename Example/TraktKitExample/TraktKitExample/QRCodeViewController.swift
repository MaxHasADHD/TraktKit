import UIKit
import TraktKit

final class QRCodeViewController: UIViewController {
    var data:DeviceCode?
    
    private let codeLabel:UILabel = UILabel()
    private let qrImageView:UIImageView = UIImageView()
    
    public func set(_ data:DeviceCode) {
        self.codeLabel.text = data.user_code
        self.qrImageView.image = data.getQRCode()
        self.data = data
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.qrImageView.frame = CGRect(x: 0, y: 100, width: 300, height: 300)
        self.codeLabel.frame = CGRect(x: 0, y: 400, width: 300, height: 100)
        
        self.view.addSubview(self.qrImageView)
        self.view.addSubview(self.codeLabel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.start()
    }
    
    
    private func start() {
        TraktManager.sharedManager.getTokenFromDevice(code: self.data) { result  in
            switch result {
            case .fail(let progress):
                print(progress)
                if progress == 0 {
                    self.dismisOnMainThread()
                }
            case .success:
                self.dismisOnMainThread()
            }
        }
    }
    
    private func dismisOnMainThread() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: false)
        }
    }
}
