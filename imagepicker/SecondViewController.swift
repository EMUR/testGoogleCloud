//
//  SecondViewController.swift
//  imagepicker
//
//  Created by E on 4/6/17.
//  Copyright © 2017 Sara Robinson. All rights reserved.
//


import UIKit
import AVFoundation

class SecondViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var scannedBarcode: UITextView!
    @IBOutlet weak var cameraPreviewView: UIView!
    
    let captureSession = AVCaptureSession()
    var captureLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupScanningSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Start the camera capture session as soon as the view appears completely.
        self.captureSession.startRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rescanButtonPressed(sender: AnyObject) {
        // Start scanning again.
        self.captureSession.startRunning()
    }
    
    @IBAction func copyButtonPressed(sender: AnyObject) {
        // Copy the barcode text to the clipboard.
        let clipboard = UIPasteboard.general
        clipboard.string = self.scannedBarcode.text
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        self.captureSession.stopRunning()
        self.dismiss(animated: true, completion: nil)
    }
    
    // Local method to setup camera scanning session.
    func setupScanningSession() {
        // Set camera capture device to default.
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        var _: NSErrorPointer = nil
        
    
            guard let input = try? AVCaptureDeviceInput(device: captureDevice) else
            {
               return
            }

        
        self.captureSession.addInput(input)

        
        let output = AVCaptureMetadataOutput()
        // Set recognisable barcode types as all available barcodes.
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        // Create a new queue and set delegate for metadata objects scanned
        let dispatchQueue = DispatchQueue(label: "scanQueue")
        output.setMetadataObjectsDelegate(self, queue: dispatchQueue)
        // Set output to camera session.
        self.captureSession.addOutput(output)
        
        self.captureLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.captureLayer!.frame = self.cameraPreviewView.frame
        self.captureLayer!.videoGravity = AVLayerVideoGravityResizeAspect
        self.cameraPreviewView.layer.addSublayer(self.captureLayer!)
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        var capturedBarcode: String
        
        // Speify the barcodes you want to read
        let supportedBarcodeTypes = [AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                                     AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                                     AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode]
        
        // In all scanned values..
        for barcodeMetadata in metadataObjects {
            // ..check if it is a suported barcode
            for supportedBarcode in supportedBarcodeTypes {
                
                if supportedBarcode == (barcodeMetadata as AnyObject).type {
                    // This is a supported barcode
                    // Note barcodeMetadata is of type AVMetadataObject
                    // AND barcodeObject is of type AVMetadataMachineReadableCodeObject
                    let barcodeObject = self.captureLayer!.transformedMetadataObject(for: barcodeMetadata as! AVMetadataObject)
                    capturedBarcode = (barcodeObject as! AVMetadataMachineReadableCodeObject).stringValue
                    // Got the barcode. Set the text in the UI and break out of the loop.
                    
                    DispatchQueue.global(qos: .default).async(execute: {
                        self.captureSession.stopRunning()
                        self.scannedBarcode.text = capturedBarcode
                    })
                    
                    return
                }
            }
        }
    }
  
}

