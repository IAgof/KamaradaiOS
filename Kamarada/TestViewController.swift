import UIKit
import GPUImage

class TestViewController: UIViewController, UISplitViewControllerDelegate {
    
    @IBOutlet var filterView: GPUImageView?
    
    let videoCamera: GPUImageVideoCamera
    var blendImage: GPUImagePicture?
    
    required init(coder aDecoder: NSCoder)
    {
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: .Back)
        videoCamera.outputImageOrientation = .Portrait;
        
        super.init(coder: aDecoder)!
    }
    
    var filterOperation: FilterOperationInterface? {
        didSet {
            self.configureView()
        }
    }
    
    func configureView() {
        let filter:GPUImageMosaicFilter = GPUImageMosaicFilter.init()
        videoCamera.addTarget(filter)
        filter.addTarget(filterView)
        videoCamera.startCameraCapture()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

