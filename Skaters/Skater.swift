import UIKit
import SceneKit

let SHAPE__FOOT = 0
let SHAPE__CALF = 1
let SHAPE_THIGH = 2
let SHAPE__BODY = 3
let SHAPE_SHULD = 4
let SHAPE__FARM = 5
let SHAPE__HAND = 6
let SHAPE__HEAD = 7
let S__BODY = 0
let S__HEAD = 1
let S_LSHLD = 2
let S_RSHLD = 3
let S_LFARM = 4
let S_RFARM = 5
let S_LHAND = 6
let S_RHAND = 7
let S_LTHGH = 8
let S_RTHGH = 9
let S_LCALF = 10
let S_RCALF = 11
let S_LFOOT = 12
let S_RFOOT = 13
let NUM_SEGMENT = 14
let X = 0
let Y = 1
let Z = 2
let NONE = -1
let NUM_POSITIONS = 2

var scaleFactor:Float = 1.0
var scaleFactor2:Float = 1.0
var katnis = 0

let fleshColor = UIColor(red:CGFloat(0xcd)/CGFloat(255.0), green:CGFloat(0x9a)/CGFloat(255.0), blue:CGFloat(0x85)/CGFloat(255.0), alpha:1)
let skateColor = UIColor(red:0.8, green:0.8, blue:0.75, alpha:1.0)

struct Vertex {
    var pt = Array<Float>()
    
    init() { self.init(0,0,0) }
    
    init(_ p1:Float, _ p2:Float, _ p3:Float) {
        for _ in 0 ..< 3 {
            pt.append(Float())
        }
        pt[0] = p1
        pt[1] = p2
        pt[2] = p3
    }
};

struct SegmentData {
    var parentIndex:Int!
    var position:SCNVector3!
    var angle:SCNVector3!
    var color:UIColor!
    var node: SCNNode!
};

struct PositionList {
    var position:SCNVector3!
    var angle = Array<SCNVector3>()
    
    init() {
        for _ in 0 ..< NUM_SEGMENT {
            angle.append(SCNVector3())
        }
    }
};

func fRandom(_ max:Int) -> Float { return Float(arc4random_uniform(UInt32(max))) }

// MARK: Skater

class Skater {
    var sData = Array<SegmentData>()
    var aIndex1:Int
    var aIndex2:Int
    var percent:Float
    var pHop:Float
    var wAngle:Float
    var wRadius:Float
    var color1:UIColor
    var color2:UIColor
    var pList = Array<PositionList>()
    var emitter = Array<SCNParticleSystem>()
    
    var trailEmitter1:SCNParticleSystem!
    var trailEmitter2:SCNParticleSystem!
    var trailEmitter3:SCNParticleSystem!
    var trailEmitter4:SCNParticleSystem!
    
    init(_ c1:UIColor, _ c2:UIColor) {
        aIndex1 = 0
        aIndex2 = 1
        color1 = c1
        color2 = c2
        percent = fRandom(100)
        wAngle = fRandom(360)
        wRadius = 40.0 + fRandom(50)
        pHop = 3 + fRandom(3)
        
        for _ in 0 ..< NUM_SEGMENT { sData.append(SegmentData()) }
        for _ in 0 ..< NUM_POSITIONS { pList.append(PositionList()) }
        
        let eColor = UIColor(red:rColor(), green:rColor(), blue:0, alpha:1.0)
        let eBox = SCNBox(width:20, height:5, length:5, chamferRadius:0)
        let eNames = [ "fire.scnp","reactor.scnp","boken.scnp","smoke.scnp" ]
        for i in 0 ..< eNames.count {
            emitter.append(SCNParticleSystem())
            emitter[i] = SCNParticleSystem(named:eNames[i], inDirectory: nil)!
            emitter[i].emitterShape = eBox
            emitter[i].particleColor = eColor
        }
        
        segmentsInit()
    }
    
    func rColor() -> CGFloat { return CGFloat(0.3 + Float(arc4random_uniform(UInt32(1024))) / 1024.0) }
    
    func toggleKatnis() {
        for i in 0 ..< 4 {
            sData[S__BODY].node.removeParticleSystem(emitter[i])
        }
        
        if katnis > 0 {
            sData[S__BODY].node.addParticleSystem(emitter[katnis-1])
        }
    }
    
    // -----------------------------------------------
    func bodyShape() -> SCNNode {
        let box = SCNBox(width:2, height:5, length:3, chamferRadius:2)
        box.firstMaterial?.diffuse.contents = color1
        
        let skirt = SCNCone(topRadius:0, bottomRadius:5, height:3)
        skirt.firstMaterial?.diffuse.contents = color1
        let sn = SCNNode(geometry:skirt)
        sn.position.y = -2
        
        let bn = SCNNode(geometry:box)
        bn.addChildNode(sn)
        
        return bn
    }
    
    // -----------------------------------------------
    func thighShape() -> SCNNode {
        let box = SCNBox(width:2, height:6, length:2, chamferRadius:1)
        box.firstMaterial?.diffuse.contents = color2
        let bn = SCNNode(geometry:box)
        bn.pivot = SCNMatrix4MakeTranslation(0,3,0)
        return bn
    }
    
    // -----------------------------------------------
    func calfShape() -> SCNNode {
        let box = SCNBox(width:1.5, height:5.5, length:1.5, chamferRadius:1)
        box.firstMaterial?.diffuse.contents = color2
        
        let bn = SCNNode(geometry:box)
        bn.pivot = SCNMatrix4MakeTranslation(0,2.75,0)
        return bn
    }
    
    // -----------------------------------------------
    let f1:CGFloat = 1.2
    let f2:CGFloat = 2.5
    
    func footShape() -> SCNNode {
        let box1 = SCNBox(width:f1, height:f1, length:f1, chamferRadius:0.3)
        box1.firstMaterial?.diffuse.contents = color1
        
        let box2 = SCNBox(width:f2, height:f1, length:f1, chamferRadius:0.5)
        box2.firstMaterial?.diffuse.contents = color1
        
        let bn1 = SCNNode(geometry:box1)
        bn1.pivot = SCNMatrix4MakeTranslation(0,Float(f1/2),0)
        
        let bn2 = SCNNode(geometry:box2)
        bn2.position = SCNVector3(0.5,-0.75,0)
        
        bn1.addChildNode(bn2)
        
        let box3a = SCNBox(width:0.3, height:0.6, length:0.1, chamferRadius:0)
        box3a.firstMaterial?.diffuse.contents = skateColor
        let bn3a = SCNNode(geometry:box3a)
        bn3a.position = SCNVector3(0.5,-0.75,0)
        bn2.addChildNode(bn3a)
        
        let bn3b = SCNNode(geometry:box3a)
        bn3b.position = SCNVector3(-0.5,-0.75,0)
        bn2.addChildNode(bn3b)
        
        let box3c = SCNBox(width:3, height:0.2, length:0.1, chamferRadius:0)
        box3c.firstMaterial?.diffuse.contents = skateColor
        let bn3c = SCNNode(geometry:box3c)
        bn3c.position = SCNVector3(0.5,-1.3,0)
        bn2.addChildNode(bn3c)
        
        return bn1
    }
    
    // -----------------------------------------------
    let shoulderWidth:CGFloat = 1
    let shoulderLength:CGFloat = 3.8
    
    func shoulderShape() -> SCNNode {
        let box = SCNBox(width:shoulderWidth, height:shoulderLength, length:shoulderWidth, chamferRadius:1)
        box.firstMaterial?.diffuse.contents = color2
        
        let bn = SCNNode(geometry:box)
        bn.pivot = SCNMatrix4MakeTranslation(0,Float(shoulderLength/2),0)
        return bn
    }
    
    // -----------------------------------------------
    let farmWidth:CGFloat = 0.8
    let farmLength:CGFloat = 3.8
    
    func foreArmShape() -> SCNNode {
        let box = SCNBox(width:farmWidth, height:farmLength, length:farmWidth, chamferRadius:1)
        box.firstMaterial?.diffuse.contents = color2
        
        let bn = SCNNode(geometry:box)
        bn.pivot = SCNMatrix4MakeTranslation(0,Float(farmLength/2),0)
        return bn
    }
    
    // -----------------------------------------------
    let handWidth:CGFloat = 1
    let handLength:CGFloat = 1.2
    
    func handShape() -> SCNNode {
        let box = SCNBox(width:handWidth, height:handLength, length:handWidth/2, chamferRadius:1)
        box.firstMaterial?.diffuse.contents = color1
        return SCNNode(geometry:box)
    }
    
    // -----------------------------------------------
    func headShape() -> SCNNode {
        let box = SCNSphere(radius:1)
        box.firstMaterial?.diffuse.contents = fleshColor
        let bn = SCNNode(geometry:box)
        
        let hat = SCNCone(topRadius:0, bottomRadius:2, height:1.2)
        hat.firstMaterial?.diffuse.contents = color1
        let hn = SCNNode(geometry:hat)
        hn.transform = SCNMatrix4MakeRotation(1,0,0,1)
        hn.position.x = -0.5
        hn.position.y = 0.475
        
        bn.addChildNode(hn)
        return bn
    }
    
    // MARK: initalize segments
    
    func segmentDataInit(_ index:Int, _ shapeIndex:Int, _ pIndex:Int, _ pPosition:SCNVector3) {
        sData[index].parentIndex = pIndex
        sData[index].position = pPosition
        
        switch shapeIndex  {
        case SHAPE__FOOT : sData[index].node = footShape();     break
        case SHAPE__CALF : sData[index].node = calfShape();     break
        case SHAPE_THIGH : sData[index].node = thighShape();    break
        case SHAPE__BODY : sData[index].node = bodyShape();     break
        case SHAPE_SHULD : sData[index].node = shoulderShape(); break
        case SHAPE__FARM : sData[index].node = foreArmShape();  break
        case SHAPE__HAND : sData[index].node = handShape();     break
        case SHAPE__HEAD : sData[index].node = headShape();     break
        default : break
        }
    }
    
    func segmentsInit() {
        let v1 = SCNVector3()
        segmentDataInit(S__BODY,SHAPE__BODY,NONE,v1)
        
        // -------------------------------------
        let v2 = SCNVector3(0,3.5,0)
        segmentDataInit(S__HEAD,SHAPE__HEAD,S__BODY,v2)
        
        // -------------------------------------
        let shY:Double = 1.8
        let shZ:Double = -0.8
        let v3 = SCNVector3(0,shY,shZ)
        let v4 = SCNVector3(0,shY,-shZ)
        segmentDataInit(S_LSHLD,SHAPE_SHULD,S__BODY,v3)
        segmentDataInit(S_RSHLD,SHAPE_SHULD,S__BODY,v4)
        
        // -------------------------------------
        let v5 = SCNVector3(0,-1.7,0) // (0,-1.7, 0)
        segmentDataInit(S_LFARM,SHAPE__FARM,S_LSHLD,v5)
        segmentDataInit(S_RFARM,SHAPE__FARM,S_RSHLD,v5)
        
        // -------------------------------------
        let v7 = SCNVector3(0.2,-2.2, 0)
        segmentDataInit(S_LHAND,SHAPE__HAND,S_LFARM,v7)
        segmentDataInit(S_RHAND,SHAPE__HAND,S_RFARM,v7)
        
        // -------------------------------------
        let thighX:Double = 0
        let thighY:Double = -2
        let v9 = SCNVector3(thighX,thighY, -1)
        let va = SCNVector3(thighX,thighY, 1 )
        segmentDataInit(S_LTHGH,SHAPE_THIGH,S__BODY,v9)
        segmentDataInit(S_RTHGH,SHAPE_THIGH,S__BODY,va)
        
        // -------------------------------------
        let calfX:Double = 0.5
        let calfY:Double = -2.5
        let vb = SCNVector3(calfX,calfY, 0)
        let vc = SCNVector3(calfX,calfY, 0)
        segmentDataInit(S_LCALF,SHAPE__CALF,S_LTHGH,vb)
        segmentDataInit(S_RCALF,SHAPE__CALF,S_RTHGH,vc)
        
        // -------------------------------------
        let footY:Double = -2.75
        let vd = SCNVector3(0,footY, 0)
        segmentDataInit(S_LFOOT,SHAPE__FOOT,S_LCALF,vd)
        segmentDataInit(S_RFOOT,SHAPE__FOOT,S_RCALF,vd)
        
        for i in 0 ..< NUM_SEGMENT {
            let data = sData[i]
            let parent = data.parentIndex
            
            if parent == NONE {
                scenePtr.rootNode.addChildNode(sData[i].node)
            }
            else {
                sData[parent!].node.addChildNode(sData[i].node)
            }
            
            sData[i].node.position = data.position
        }
    }
    
    func percentVector(_ v1:SCNVector3, _ v2:SCNVector3) -> SCNVector3 {
        var result = SCNVector3()
        let fPercent = Float(percent) / 100.0
        
        result.x = v1.x + (v2.x - v1.x) * fPercent
        result.y = v1.y + (v2.y - v1.y) * fPercent
        result.z = v1.z + (v2.z - v1.z) * fPercent
        return result
    }
    
    func radian(_ deg:Float) -> Float { return deg * Float(Double.pi) / 180.0 }
    func randomAngle(_ min:Int, _ max:Int) -> Float { return radian(Float(min) + fRandom(max - min)) }
    
    // MARK: move
    
    func move() {
        if percent >= 100  {
            aIndex1 = aIndex2
            aIndex2 += 1
            if aIndex2 >= NUM_POSITIONS { aIndex2 = 0 }
            
            percent = 0
            pHop = 1 + fRandom(3)
            
            var brotate:Int = 40
            if fRandom(16) < 3 { brotate = 200 }
            pList[aIndex2].angle[S__BODY].y	= randomAngle(-brotate,brotate)
            
            let bodyZ = randomAngle(-30,0)
            pList[aIndex2].angle[S__BODY].z	= bodyZ
            
            pList[aIndex2].angle[S__HEAD].y	= randomAngle(-50,50)
            pList[aIndex2].angle[S__HEAD].z	= randomAngle(-50,0)
            
            pList[aIndex2].angle[S_LSHLD].x	= randomAngle(10,160)
            pList[aIndex2].angle[S_LSHLD].z	= randomAngle(-60,60)
            pList[aIndex2].angle[S_LFARM].z	= randomAngle(1,50)
            pList[aIndex2].angle[S_LHAND].x	= randomAngle(-40,40)
            pList[aIndex2].angle[S_LHAND].z	= randomAngle(-40,40)
            
            pList[aIndex2].angle[S_RSHLD].x	= randomAngle(-160,-10)
            pList[aIndex2].angle[S_RSHLD].z	= randomAngle(-60,60)
            pList[aIndex2].angle[S_RFARM].z	= randomAngle(1,50)
            pList[aIndex2].angle[S_RHAND].x	= randomAngle(-40,40)
            pList[aIndex2].angle[S_RHAND].z	= randomAngle(-40,40)
            
            pList[aIndex2].angle[S_LTHGH].z	= -bodyZ*2 + radian(fRandom(80) - 40)
            pList[aIndex2].angle[S_RTHGH].z	= -pList[aIndex2].angle[S_LTHGH].z
            
            pList[aIndex2].angle[S_LCALF].z	= randomAngle(-60,0)
            pList[aIndex2].angle[S_RCALF].z	= randomAngle(-60,0)
            pList[aIndex2].angle[S_LFOOT].z	= randomAngle(-20,20)
            pList[aIndex2].angle[S_RFOOT].z	= randomAngle(-20,20)
        }
        
        for i in 0 ..< NUM_SEGMENT {
            sData[i].angle = percentVector(pList[aIndex1].angle[i], pList[aIndex2].angle[i])
            let rx = SCNMatrix4MakeRotation(sData[i].angle.x,1,0,0)
            let ry = SCNMatrix4MakeRotation(sData[i].angle.y,0,1,0)
            let rz = SCNMatrix4MakeRotation(sData[i].angle.z,0,0,1)
            
            var p:SCNVector3 = sData[i].position
            p.x *= scaleFactor
            p.y *= scaleFactor
            
            var tt:SCNMatrix4!
            
            if i == S__BODY {
                wAngle += 0.3 + pHop / 12.0
                if wAngle >= 360 { wAngle -= 360 }
                let rad = radian(wAngle)

                tt = SCNMatrix4MakeTranslation(p.x + sinf(rad)*wRadius,p.y,p.z + cosf(rad)*wRadius)
            }
            else {
                tt = SCNMatrix4MakeTranslation(p.x,p.y,p.z)
            }
            
            tt = SCNMatrix4Scale(tt,scaleFactor2,scaleFactor2,scaleFactor2)
            
            sData[i].node.transform = SCNMatrix4Mult(SCNMatrix4Mult(SCNMatrix4Mult(rz,ry),rx),tt)
        }
        
        percent += pHop
    }
};

