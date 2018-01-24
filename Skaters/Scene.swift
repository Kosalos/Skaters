import UIKit
import SceneKit

var timer = Timer()
var scenePtr:Scene!

let NUMSKATER = 10
var skater = [Skater]()

var light:SCNNode!
var lightAngle:Float = 0

public func mult(left: SCNMatrix4, _ right: SCNVector3) -> SCNVector3 {
    let x = left.m11*right.x + left.m21*right.y + left.m31*right.z
    let y = left.m12*right.x + left.m22*right.y + left.m32*right.z
    let z = left.m13*right.x + left.m23*right.y + left.m33*right.z
    
    return SCNVector3(x: x, y: y, z: z)
}

class Scene: SCNScene {
    override init() {
        super.init()
        scenePtr = self
        
        for _ in 0 ..< NUMSKATER {
            let color1 = UIColor(red:rColor(), green:rColor(), blue:rColor(), alpha:1.0)
            let color2 = UIColor(red:rColor(), green:rColor(), blue:rColor(), alpha:1.0)
            
            skater.append(Skater(color1,color2))
        }
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zNear = 0.01
        cameraNode.camera?.zFar = Double(4000)
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 500)
        
        rootNode.addChildNode(cameraNode)

        
        let myFloor = SCNFloor()
        myFloor.reflectivity = 0.5
        //        myFloor.reflectionResolutionScaleFactor = 1
        //        myFloor.reflectionFalloffStart = 2.0
        //        myFloor.reflectionFalloffEnd = 10.0
        
        let myFloorNode = SCNNode(geometry: myFloor)
        myFloorNode.position = SCNVector3(x: 0, y: -16, z: 0)
        rootNode.addChildNode(myFloorNode)
        
        let spotLight = SCNLight()
        spotLight.type = SCNLight.LightType.spot
        spotLight.castsShadow = true
        spotLight.spotOuterAngle = 90.0
        spotLight.zFar = 600
        
        light = SCNNode()
        light.light = spotLight
        light.position = SCNVector3(x:0, y: 30, z:200)
        rootNode.addChildNode(light)
        
        timer = Timer.scheduledTimer(timeInterval: 1.0/60.0, target:self, selector: #selector(timerHandler), userInfo: nil, repeats:true)
    }
    
    required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @objc func timerHandler() {
        for s in skater { s.move() }
    }
    
    func rColor() -> CGFloat { return CGFloat(0.1 + Float(arc4random_uniform(UInt32(1024))) / 1024.0) }
    
}
