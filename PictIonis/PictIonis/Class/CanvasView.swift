//
//  CanvasView.swift
//  PictIonis
//
//  Created by Agnieszka Niewiadomski on 09/09/2020.
//  Copyright © 2020 niewiajuzain_ad. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

struct TouchPointAndColor {
    var color: String?
    var width: CGFloat?
    var points: [CGPoint]?
    var key: String
    let ref: DatabaseReference?

    init(color: String, points: [CGPoint], width: CGFloat = 1.0, key: String = "") {
        self.color = color
        self.points = points
        self.width = width
        self.key = key
        self.ref = nil

    }
    
    init(snapshot: DataSnapshot) {
        self.key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.points = (snapshotValue["points"] as! [CGPoint])
        self.color = (snapshotValue["color"] as! String)
        self.ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return[
            "points": convert(points: points ?? []) as Any,
            "color": color as Any,
            "width": width as Any
        ]
    }
    
    func convert(points : [CGPoint]) -> [[NSNumber]] {
         return points.map {
             [NSNumber(value: $0.x.native),
              NSNumber(value: $0.y.native)]
         }
     }
}

class CanvasView: UIView {
    let uid = Auth.auth().currentUser?.uid
    var idGame: String = ""

    private lazy var drawRef: DatabaseReference! = Database.database().reference(withPath: "Drawing").child(idGame)
    private var drawRefHandle: DatabaseHandle?
        
    var lines = [TouchPointAndColor]()
    var strokeWidth: CGFloat = 4.0
    var strokeColor: String = "000000"
    
    // MARK: - Actions

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        lines.forEach { (line) in
            for (i, p) in (line.points?.enumerated())! {
                if i == 0 {
                    context.move(to: p)
                } else {
                    context.addLine(to: p)
                }
                
                context.setStrokeColor(UIColor.hexStringToUIColor(hex: line.color ?? "000000").cgColor)
                context.setLineWidth(line.width ?? 1.0)
            }
            context.setLineCap(.round)
            context.strokePath()
        }
        
        if isUserInteractionEnabled, let lastLine = lines.last {
            let newDrawRef = drawRef.child("lines/\(lines.count)")
            let drawInfo = TouchPointAndColor(color: lastLine.color ?? "000000", points: lastLine.points ?? [], width: lastLine.width ?? 1.0)
            
            newDrawRef.setValue(drawInfo.toAnyObject())
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lines.append(TouchPointAndColor(color: String(), points: [CGPoint](), width: CGFloat()))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first?.location(in: self) else {
            return
        }
        
        guard var lastPoint = lines.popLast() else {
            return
        }
        
        lastPoint.points?.append(touch)
        lastPoint.color = strokeColor
        lastPoint.width = strokeWidth
        lines.append(lastPoint)
        
        setNeedsDisplay()
    }
    
    func clearCanvasView() {
        let newDrawRef = drawRef.child("lines")
        newDrawRef.removeValue()
        
        lines.removeAll()
        setNeedsDisplay()
    }
    
    func undoDraw() {
        if lines.count > 0 {
            if isUserInteractionEnabled {
                let newDrawRef = drawRef.child("lines/\(lines.count)")
                newDrawRef.removeValue()
            }

            lines.removeLast()
            setNeedsDisplay()
        }
    }
    
    // Draw at the arrival
    func addNewLines(_ newlines: [[String: Any]]) {
        print("---- addLines ---- \(newlines.count)")
        newlines.forEach { (newline) in
            let points = newline["points"] as? [Any] ?? []
            var ps: [CGPoint] = []
            
            for point in points {
                if let array = point as? [CGFloat], array.count > 1 {
                    ps.append(CGPoint(x: array[0], y: array[1]))
                }
            }
            
            let width = newline["width"] as? CGFloat ?? 4.0
            let color = newline["color"] as? String ?? "000000"
            
            let line = TouchPointAndColor(color: color, points: ps, width: width)
            self.lines.append(line)
        }

        setNeedsDisplay()
    }
    
    // Draw at the arrival
    func addNewLine(_ newline: [String: Any], for key: Int) {
        let points = newline["points"] as? [Any] ?? []
        var ps: [CGPoint] = []
        
        for point in points {
            if let array = point as? [CGFloat], array.count > 1 {
                ps.append(CGPoint(x: array[0], y: array[1]))
            }
        }
        
        let width = newline["width"] as? CGFloat ?? 4.0
        let color = newline["color"] as? String ?? "000000"
        
        if lines.count == key {
            lines.removeLast()
            
            let line = TouchPointAndColor(color: color, points: ps, width: width)
            self.lines.append(line)
        } else {
            let line = TouchPointAndColor(color: color, points: ps, width: width)
            self.lines.append(line)
        }
        
        setNeedsDisplay()
    }
    
    // MARK: - Helper functions

//    func checkUserOwner() -> Bool {
//        var isOk: Bool = false
//        drawRef.observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value
//            let value = snapshot.value as? NSDictionary
//            let author = value?["author"] as? String ?? ""
//
//
//            if let email = Auth.auth().currentUser?.email, email == author {
//                isOk = true
//            }
//          }) { (error) in
//            print(error.localizedDescription)
//        }
//
//        return isOk
//    }
    
}

extension UIColor {
    class func hexStringToUIColor (hex:String) -> UIColor {
          var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

          if (cString.hasPrefix("#")) {
              cString.remove(at: cString.startIndex)
          }

          if ((cString.count) != 6) {
              return UIColor.gray
          }

          var rgbValue:UInt64 = 0
          Scanner(string: cString).scanHexInt64(&rgbValue)

          return UIColor(
              red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
              green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
              blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
              alpha: CGFloat(1.0)
          )
      }
}
