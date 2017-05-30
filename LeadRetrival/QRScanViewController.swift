//
//  QRScanViewController.swift
//  LeadRetrival
//
//  Created by Kimani Walters on 21/01/2016.
//  Copyright © 2016 DiveChronicles. All rights reserved.
//

import UIKit
import AVFoundation

struct LeadQRCInfo {
    let firstName: String
    let lastName: String
    let email: String
    let phoneNumber: String
    let postalCode: String
    
    init(csvString: String) {
        let components = csvString.components(separatedBy: ", ")
        if(components.count == 5){
            firstName = components[0]
            lastName = components[1]
            email = components[2]
            phoneNumber = components[3]
            postalCode = components[4]
        }else{
            firstName = ""
            lastName = ""
            email = ""
            phoneNumber = ""
            postalCode = ""
        }
        
    }
}

class QRScanViewController: UIViewController {
    
    // MARK: - Properties
    
    var deleget: LeadViewController!
    var captureSession: AVCaptureSession!
    
    // MARK: - Controller Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(QRScanViewController.didClickCancelAction(_:)))
        navigationItem.leftBarButtonItem = cancelButton
        
        startScanning()
    }
    
    // MARK: - Actions
    
    func didClickCancelAction(_ sender: UIBarButtonItem) {
        deleget.dismissQRScanViewController()
    }
    
    // MARK: - Scan QR Code
    
    func startScanning() {
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // Get an instance of the AVCaptureDeviceInput class using the previous device object.
        let input: AVCaptureDeviceInput
        do { input = try AVCaptureDeviceInput(device: captureDevice) } catch { return }
        
        // Initialize the captureSession object.
        captureSession = AVCaptureSession()
        
        // Set the input device on the capture session.
        captureSession.addInput(input)
        
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        
        // Create a new serial dispatch queue.
        let dispatchQueue = DispatchQueue(label: "myQueue", attributes: [])
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatchQueue)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
    }
    
    func stopScanning() {
        captureSession.stopRunning()
    }
    
    func setCapturedQRCodeData(_ csvString: String) {
        stopScanning()
        
        let leadQRCInfo = LeadQRCInfo(csvString: csvString)
        deleget.dismissQRScanViewController(leadQRCInfo)
    }
}

// MARK: - AVCapture Metadata Output Objects Delegate

extension QRScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        guard metadataObjects != nil && metadataObjects.count > 0 else { return }
        guard let metadataObj = metadataObjects.first, (metadataObj as AnyObject).type == AVMetadataObjectTypeQRCode else { return }
        var strData:String
        strData=""
        //new
        for metadata in metadataObjects {
            let readableObject = metadata as! AVMetadataMachineReadableCodeObject
            strData = readableObject.stringValue
            self.dismiss(animated: true, completion: nil)
            break;
        }
        ///
        performSelector(onMainThread: Selector("setCapturedQRCodeData:"), with: strData, waitUntilDone: false)
    }
}
