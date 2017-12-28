// ViewController.swift

import UIKit
import Parse
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, sendCodeProtocol, BarcodeScannerControllerDelegate {
    
    func sendScannedBarcode(text: String?) {
        //Not sure why this had to be added...
    }
    

    // Added code below
    
    var videoCaptureDevice: AVCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)!
    var output = AVCaptureMetadataOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var highlightView : UIView = UIView()
    
    var captureSession = AVCaptureSession()
    var code: String?
    
    var scannedCode = UILabel()
    var finalCode: String?
    
    var scannedCodeFromParse: String?
    
    var finalScannedCodeFromScannerVC: String?
    
    func setupCamera() {
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let barcodeScannerController = segue.destination as? BarcodeScannerController {
            barcodeScannerController.finalCode = scannedCodeLabel.text
            barcodeScannerController.delegate = self
        }
    }
        
        // New code above
    
    
    
    
    
    
    func sendScannedCode(scannedCode: String) {
        self.scannedCodeLabel.text = scannedCode
    }
    

    @IBOutlet var scannedCodeLabel: UILabel!
    
    var codeFromScannerVC:String?
    
    //var code: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /*
        print("Back from scanner.")

        if PFObject(className: "BookLibrary").object(forKey: "barcode") != nil {
            print(String(describing: PFObject(className: "BookLibrary").object(forKey: "barcode")))
            scannedCodeLabel.text = PFObject(className: "BookLibrary")["barcode"] as? String //String(describing: PFObject(className: "BookLibrary").object(forKey: "barcode"))
        }
        
        if PFObject(className: "BookLibrary").object(forKey: "title") != nil {
            var title = PFObject(className: "BookLibrary").object(forKey: "title") as! String
            print(title)
        }
        */
        
        scannedCodeLabel.text = String(describing: PFObject(className: "BookLibrary").object(forKey: "barcode"))
        
    }
    
    /*
    func scannedCodeFromScanner(scannedCode: String) {
        self.codeFromScannerVC = finalScannedCodeFromScannerVC
    }
    */

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        scannedCodeLabel.text = "0 Barcodes"
        
    }

    @IBAction func scanButton(_ sender: Any) {

        //let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "BarcodeScannerController") as! BarcodeScannerController
        
        //secondVC.delegate = self
        
        //self.navigationController?.pushViewController(secondVC, animated: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

