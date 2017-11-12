//
//  ViewController.swift
//  GraphingCalculator
//
//  Created by Li Yang on 7/9/17.
//  Copyright © 2017 Rice University. All rights reserved.
//

import UIKit

class FunctionGraphingViewController: UIViewController {
    
    /*
     
     for a given function draw its curves.
     
     */
    
    // the function as a closure
    var function: ((Double) -> Double?)? = nil
    
    override func viewDidLoad() {
        if function != nil {
            functionGraphingView.function = self
        }
    }
    
    @IBOutlet weak var functionGraphingView: FunctionGraphingView! {
        didSet {
            let pinchRecognizer = UIPinchGestureRecognizer(
                target: functionGraphingView,
                action: #selector(FunctionGraphingView.changeScale(byReactingTo:))
            )
            functionGraphingView.addGestureRecognizer(pinchRecognizer)
            
            let panRecognizer = UIPanGestureRecognizer(
                target: functionGraphingView,
                action: #selector(FunctionGraphingView.moveOrigin(byReactingTo:))
            )
            functionGraphingView.addGestureRecognizer(panRecognizer)
            
            let tapRecognizer = UITapGestureRecognizer(
                target: functionGraphingView,
                action: #selector(FunctionGraphingView.jumpOrigin(byReactingTo:))
            )
            tapRecognizer.numberOfTapsRequired = 2
            functionGraphingView.addGestureRecognizer(tapRecognizer)
        }
    }
}

extension FunctionGraphingViewController: FunctionDelegate {
    func value(at x: CGFloat) -> CGFloat? {
        if let functionValue = function!(Double(x)) {
            return CGFloat(functionValue)
        } else {
            return nil
        }
    }
}

