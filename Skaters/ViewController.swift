import UIKit
import SceneKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scnView = self.view as! SCNView
        scnView.scene = Scene()
        scnView.backgroundColor = UIColor.black
    
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = true
    }

    override var prefersStatusBarHidden : Bool { return true;  }

    @IBAction func katnisButton(_ sender: UIButton) {
        katnis += 1
        if katnis > 4 { katnis = 0 }
        
        for s in skater {
            s.toggleKatnis()
        }
    }
    
    @IBAction func scaleSliderChanged(_ sender: UISlider) {
        scaleFactor = sender.value / 100.0
    }
    @IBAction func scale2FactorChanged(_ sender: UISlider) {
        scaleFactor2 = sender.value / 100.0
    }
    
    @IBOutlet var scaleF1: UISlider!
    @IBOutlet var scaleF2: UISlider!
    
    @IBAction func resetButton(_ sender: UIButton) {
        scaleF1.value = 100
        scaleF2.value = 100
        scaleFactor = 1
        scaleFactor2 = 1
    }
}
