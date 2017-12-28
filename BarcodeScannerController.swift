// BarcodeScannerController.swift

import UIKit
import Parse
import AVFoundation

protocol sendCodeProtocol {
    func sendScannedCode(scannedCode: String)
}

protocol BarcodeScannerControllerDelegate: class {
    func sendScannedBarcode(text:String?)
}

class BarcodeScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    /*
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var barcodeFrameView:UIView?
    */
    
    //var videoCaptureDevice: AVCaptureDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInDualCamera, for: AVMediaType.video, position: AVCaptureDevice.Position.back)!
    var videoCaptureDevice: AVCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)!
    var device = AVCaptureDevice.default(for: AVMediaType.video)
    var output = AVCaptureMetadataOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    var captureSession = AVCaptureSession()
    var code: String?
    
    var scannedCode = UILabel()
    var finalCode: String?
    var finalBarcode: String?
    
    var delegate1:sendCodeProtocol?
    
    var delegate: BarcodeScannerControllerDelegate?
    
    var debugMessage: String = ""
    
    private func setupCamera() {
        
        let input = try? AVCaptureDeviceInput(device: videoCaptureDevice)
        
        if self.captureSession.canAddInput(input!) {
            self.captureSession.addInput(input!)
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer.frame = self.view.bounds
        view.layer.addSublayer(self.previewLayer)
        
        let metadataOutput = AVCaptureMetadataOutput()
        if self.captureSession.canAddOutput(metadataOutput) {
            self.captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.upce, AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.ean8]
        } else {
            print("Could not add metadata output.")
        }
    }
    
    private func addLabelforDisplayingCode() {
        
        view.addSubview(scannedCode)
        scannedCode.translatesAutoresizingMaskIntoConstraints = false
        
        scannedCode.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20.0).isActive = true
        scannedCode.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0).isActive = true
        scannedCode.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0).isActive = true
        
        scannedCode.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        scannedCode.font = UIFont.preferredFont(forTextStyle: .title2)
        scannedCode.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        scannedCode.textAlignment = .center
        scannedCode.textColor = UIColor.white
        scannedCode.text = "Scanning..."
        
    }
    
    @objc func cancelButton() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        print("Scanner View Dismissed")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setupCamera()
        self.addLabelforDisplayingCode()
        
        let button = UIButton(frame: CGRect(x: 16, y: 16, width: 30, height: 30))
        let buttonImage = UIImage(named: "cancel.png")
        button.setTitle("", for: .normal)
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(cancelButton), for: .touchUpInside)
        
        self.view.addSubview(button)
        
        /*
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession?.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.ean13]

        } catch {
            print(error)
            return
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        captureSession?.startRunning()
 
        */

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession.isRunning == false) {
            captureSession.startRunning()
        }
        
        delegate1?.sendScannedCode(scannedCode: finalCode!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession.isRunning == true) {
            captureSession.stopRunning()
        }

        //sendScannedCode(scannedCode: finalCode!)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ViewController {
            destination.code = scannedCode.text
        }
    }
    */
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        print(metadataObjects)
        
        for metadata in metadataObjects {
            let readableObject = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
            //let code = readableObject.stringValue
            scannedCode.text = readableObject //code
            
            finalCode = readableObject //code

            //print("The barcode is " + finalCode!)
            
            //self.delegate?.sendScannedCode(scannedCode: finalCode!)
            //delegate?.sendScannedCode(scannedCode: finalCode!)
            
            var bookLibrary = PFObject(className: "BookLibrary")
            bookLibrary["barcode"] = String(describing: finalCode!)
            bookLibrary["available"] = false
            
            bookLibrary.saveInBackground { (success, error) in
                if (success) {
                    print("Barcode saved to Parse Server.")
                } else {
                    print("Problem saving to Parse Server.")
                }
            }
            
        }

        delegate?.sendScannedBarcode(text: String(describing: finalCode))
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? ViewController {
            destVC.scannedCodeLabel.text = finalCode!
        }
    }
    */
    
    func sendScannedCode(scannedCode: String) {
        //performSegue(withIdentifier: "segueBack", sender: self)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
