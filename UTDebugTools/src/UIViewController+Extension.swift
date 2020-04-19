//
//  UIViewController+Extension.swift
//  UTDebugTools
//
//  Created by teaxus on 2020/4/19.
//  Copyright © 2020 utaidev. All rights reserved.
//

import UTAppEngine
import AudioToolbox


extension UIViewController {
    var debug_helper:UTDebugUISetupHelper?{
        set{
            ut_dict_ex["UTDebugUISetupHelper"] = newValue
        }
        get{
            return ut_dict_ex["UTDebugUISetupHelper"] as? UTDebugUISetupHelper
        }
    }
    var ut_debug_gesture_tap:UITapGestureRecognizer?{
        set{
            debug_helper?.gesture_tap = newValue
        }
        get{
            return debug_helper?.gesture_tap
        }
    }
    var ut_debug_gesture_swip:UISwipeGestureRecognizer?{
        set{
            debug_helper?.gesture_swip = newValue
        }
        get{
            return debug_helper?.gesture_swip
        }
    }
    
    @objc func setupDebug(gesture:UIGestureRecognizer){
        AudioServicesPlaySystemSound(1519)
        let VC_view = debug_helper?.VC_view
        
        if gesture == ut_debug_gesture_tap {
            ut_debug_gesture_tap?.isEnabled = false
            let view_touch = UIView(frame: CGRect(x: 0, y: 0, width: Screen_width, height: Screen_height))
            view_touch.backgroundColor = RGBACOLOR(r: 0, g: 0, b: 0, a: 0.1)
            VC_view?.addSubview(view_touch)
            ut_debug_gesture_swip = UISwipeGestureRecognizer(target: self, action: #selector(setupDebug(gesture:)))
            ut_debug_gesture_swip?.direction = .up
            ut_debug_gesture_swip?.numberOfTouchesRequired = 3
            view_touch.addGestureRecognizer(ut_debug_gesture_swip!)
            UTThreadManage.DelayedAction(ms: 1000) {
                if let gesture = self.ut_debug_gesture_tap {
                    view_touch.removeGestureRecognizer(gesture)
                    view_touch.removeFromSuperview()
                    self.ut_debug_gesture_tap?.isEnabled = true
                }
            }
        }
        else if gesture == ut_debug_gesture_swip{
            ut_debug_gesture_tap?.isEnabled = true
            if let gesture = ut_debug_gesture_swip {
                debug_helper?.debug_tools.setUp()
                ut_debug_gesture_swip?.view?.removeFromSuperview()
                ut_debug_gesture_swip?.view?.removeGestureRecognizer(gesture)
                ut_debug_gesture_swip = nil
            }
        }
    }
}
