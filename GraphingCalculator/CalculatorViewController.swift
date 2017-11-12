//
//  ViewController.swift
//  Calculator
//
//  Created by Li Yang on 6/23/17.
//  Copyright © 2017 Rice University. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, UISplitViewControllerDelegate {
    
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var sequenceOfOperands: UILabel!
    @IBOutlet weak var variableValue: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    
//    private func showSizeClasses() {
//        if !userIsInTheMiddleOfTyping {
//            display.textAlignment = .center
//            display.text = "Width" + traitCollection.horizontalSizeClass.description + " height" + traitCollection.verticalSizeClass.description
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        showSizeClasses()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
//        coordinator.animate(alongsideTransition: {coordinator in self.showSizeClasses()}, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        brain.addUnaryOperation(named: "✅") { [weak weakSelf = self] in
            weakSelf?.display.textColor = UIColor.green
            return sqrt($0)
        } // Trailing Closures
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            display.text! += digit == "." && display.text!.contains(".") ? "" : digit
        } else {
            display.text! = (digit == "." ? "0" : "") + digit
            userIsInTheMiddleOfTyping = true
        }
        
    }
    
    private struct Number {
        let formatter = NumberFormatter()
        init() {
            formatter.maximumFractionDigits = 6
            formatter.minimumIntegerDigits = 1
        }
    }
    
    private var number = Number()
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = number.formatter.string(from: NSNumber(value: newValue))
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            displayValue = result
        }
        if brain.resultIsPending {
            sequenceOfOperands.text = brain.description + " ..."
        } else {
            sequenceOfOperands.text = brain.description + " ="
        }
        
        
    }
    @IBAction func setVariables(_ sender: UIButton) {
        variables = ["M": displayValue]
        variableValue.text! = "M = " + display.text!
        (brain.result, brain.resultIsPending, brain.description) = brain.evaluate(using: variables)
        if let result = brain.result {
            displayValue = result
        }
        if brain.resultIsPending {
            sequenceOfOperands.text = brain.description + " ..."
        } else {
            sequenceOfOperands.text = brain.description + " ="
        }
    }
    
    @IBAction func getVariables(_ sender: UIButton) {
        brain.setOperand(variable: "M")        
        (brain.result, brain.resultIsPending, brain.description) = brain.evaluate(using: variables)
        if let result = brain.result {
            displayValue = result
        }
        if brain.resultIsPending {
            sequenceOfOperands.text = brain.description + " ..."
        } else {
            sequenceOfOperands.text = brain.description + " ="
        }
    }
    
    @IBAction func Undo(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            if display.text!.characters.count > 1 {
                display.text!.remove(at: display.text!.index(before: display.text!.endIndex))
            } else {
                display.text = "0"
            }
        } else {
            if !brain.sequence.isEmpty {
                brain.sequence.removeLast()
            }
        }
    }
    
    
    @IBAction func clearAll(_ sender: UIButton) {
        display.text = "0"
        sequenceOfOperands.text = "0"
        variableValue.text! = "M = 0"
        userIsInTheMiddleOfTyping = false
        brain.clearAll()

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.splitViewController?.delegate = self;
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if brain.result != nil {
            var destinationViewController = segue.destination
            if let navigationVontroller = destinationViewController as? UINavigationController {
                destinationViewController = navigationVontroller.visibleViewController ?? destinationViewController
            }
            if let functionGraphingViewController = destinationViewController as? FunctionGraphingViewController {
    //            let identifier = segue.identifier,
                functionGraphingViewController.function = { [weak self] in self?.brain.evaluate(using: ["M": $0]).result }
                functionGraphingViewController.navigationItem.title = brain.description
            }
        }
    }
    
    // if no graph, collapse
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController
        ) -> Bool {
        //        return true
        if primaryViewController.contents == self {
            print("yes")
            if let fgvc = secondaryViewController.contents as? FunctionGraphingViewController, fgvc.function == nil {
                print("yes")
                return true
            }
        }
        return false
    }
    
}


extension UIViewController
{
    // reuseable
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}


//extension UIUserInterfaceSizeClass: CustomStringConvertible {
//    public var description: String {
//        switch self {
//        case .compact: return "Compact"
//        case .regular: return "Regular"
//        case .unspecified: return "??"
//        }
//    }
//}

