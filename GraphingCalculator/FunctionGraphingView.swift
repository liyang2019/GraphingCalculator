//
//  GraphingView.swift
//  GraphingCalculator
//
//  Created by Li Yang on 7/9/17.
//  Copyright © 2017 Rice University. All rights reserved.
//

import UIKit

@IBDesignable
class FunctionGraphingView: UIView {
    
    // the scale for the drawing
    @IBInspectable
    var scale: CGFloat = 20 { didSet { setNeedsDisplay() } }
    
    // the orgin of data in the draw coordinate system
    @IBInspectable
    var origin: CGPoint? { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var axesColor: UIColor = UIColor.black { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var plotColor: UIColor = UIColor.blue { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var discontinutyShreshold: CGFloat = 750.0 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    private var axesDrawer = AxesDrawer() { didSet { setNeedsDisplay() } }
    
    
    func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer)
    {
        switch pinchRecognizer.state {
        case .changed, .ended:
            scale *= pinchRecognizer.scale
            pinchRecognizer.scale = 1
//            origin!.x = (origin!.x - bounds.midX) * scale + bounds.midX
//            origin!.y = (origin!.y - bounds.midY) * scale + bounds.midY
        default:
            break
        }
    }
    
    func moveOrigin(byReactingTo panRecognizer: UIPanGestureRecognizer)
    {
        switch panRecognizer.state {
        case .changed, .ended:
            let translation = panRecognizer.translation(in: self)
            origin!.x += translation.x
            origin!.y += translation.y
            panRecognizer.setTranslation(CGPoint(), in: self)
        default:
            break
        }
    }
    
    // double tap to move the origin
    func jumpOrigin(byReactingTo tapRecognizer: UITapGestureRecognizer)
    {
        if tapRecognizer.state == .ended {
            origin = tapRecognizer.location(in: self)
        }
    }
    
    // this protocal is implemented in Controller
    @IBInspectable
    var function: FunctionDelegate? { didSet { setNeedsDisplay() } }
    
    private func pathForFunctionCurve() -> UIBezierPath
    {
        let path = UIBezierPath()
        // is this round OK?
        let leftPixel = round(bounds.minX * contentScaleFactor)
        let rightPixel = round(bounds.maxX * contentScaleFactor) + 1
        var lastPointIsValid = false
        for currpixel in stride(from: leftPixel, to: rightPixel, by: CGFloat(1.0)) {
            let xDraw = currpixel / contentScaleFactor
            let xData = (xDraw - origin!.x) / scale
            // check if this point is valid
            if let yData = function!.value(at: xData), yData.isNormal || yData.isZero {
                // reflect the y-Axes
                let yDraw = -yData * scale + origin!.y
                // logical operator short circuit
                if lastPointIsValid && abs(yDraw - path.currentPoint.y) < discontinutyShreshold {
                    path.addLine(to: CGPoint(x: xDraw, y: yDraw))
                } else {
                    path.move(to: CGPoint(x: xDraw, y: yDraw))
                }
                lastPointIsValid = true
            } else {
                lastPointIsValid = false
            }
        }
        return path
    }
    
    
    override func draw(_ rect: CGRect) {
        if origin == nil {
            origin = CGPoint(x: bounds.midX, y: bounds.midY)
        }
        axesDrawer.color = axesColor
        axesDrawer.contentScaleFactor = contentScaleFactor
        axesDrawer.drawAxes(in: bounds, origin: origin!, pointsPerUnit: scale)
        if function != nil {
            plotColor.set()
            discontinutyShreshold = 2 * bounds.size.height / contentScaleFactor
            pathForFunctionCurve().stroke()
        }
    }
}

// this protocal is implemented in Controller, to get the function value f(x)
protocol FunctionDelegate {
    func value(at x: CGFloat) -> CGFloat?
}
