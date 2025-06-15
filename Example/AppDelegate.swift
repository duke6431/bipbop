//
//  AppDelegate.swift
//  Example
//
//  Created by Duc IT. Nguyen Minh on 01/05/2022.
//

import UIKit
import BipBop

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private(set) static var main = UIApplication.shared.delegate as? AppDelegate
    let mainGroup = StepGroup(name: "main")
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let jumpingAround = StepGroup(name: "jump", steps: [
            Step(action: .searchAndExec("Tap me!", nil, { (button: UIButton) in button.tap() })),
            Step(action: .searchAndExec("Tap me!", nil, { (button: UIButton) in button.tap() })),
            Step(action: .searchAndExec("Tap me!", nil, { (button: UIButton) in button.tap() })),
            Step(action: .searchAndExec("Tap me!", nil, { (button: UIButton) in button.tap() })),
            Step(action: .searchAndExec("Tap me!", nil, { (button: UIButton) in button.tap() }))
        ])
        mainGroup.steps = [
            jumpingAround,
            Step<WaitComponent>(action: .wait(2)),
            Step(action: .searchAndExec("Tap me!", nil, { (button: UIButton) in button.tap() }))
        ]
        return true
    }
}

