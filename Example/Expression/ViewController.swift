//
//  ViewController.swift
//  Expression
//
//  Created by TechieCSG on 11/10/2016.
//  Copyright (c) 2016 TechieCSG. All rights reserved.
//

import UIKit
import Expression

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let expressionString = "(1+2)+3"
        let expression = Expression(string: expressionString)
        print(expression.expressionResult())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
