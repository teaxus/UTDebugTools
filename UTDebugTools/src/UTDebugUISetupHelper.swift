//
//  UTDebugUISetupHelper.swift
//  UTDebugTools
//
//  Created by teaxus on 2020/4/19.
//  Copyright © 2020 utaidev. All rights reserved.
//

import UIKit

public class UTDebugUISetupHelper {
    var gesture_tap:UITapGestureRecognizer?
    var gesture_swip:UISwipeGestureRecognizer?
    var VC_view:UIView?
    let debug_tools = UTDebugeTools()
    public required init(){
        
    }
    public func setUp(VC:UIViewController){
        gesture_tap = UITapGestureRecognizer(target: VC, action: #selector(VC.setupDebug(gesture:)))
        VC.debug_helper = self
        gesture_tap?.numberOfTapsRequired = 3
        gesture_tap?.numberOfTouchesRequired = 3
        VC.view.addGestureRecognizer(gesture_tap!)
        VC_view = VC.view
        VC_view?.addGestureRecognizer(gesture_tap!)
    }
}
