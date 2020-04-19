//
//  UTDebugeTools.swift
//  UTDebugTools
//
//  Created by teaxus on 2020/4/19.
//  Copyright © 2020 utaidev. All rights reserved.
//

import UTAppEngine
import AFNetworking
import SSZipArchive
import KVNProgress

public class UTDebugeTools {
    static var share = UTDebugeTools()
    let str_flex_tools_url = "https://teaxus.xyz/FLEX.zip"
    let path_download_file_url = FilePath.getFileFromUserTemporaryBy(name: "FLEX.zip",hasProtocol: true)
    let ex_file_url = FilePath.getFileFromUserTemporaryBy(name: "FLEX.framework",hasProtocol: false)
    let file_manager = FileManager.default
    var try_time = 3
    var req_flex:URLRequest {
        return  URLRequest(url: str_flex_tools_url.url!)
    }
    var flex_obj:NSObject?
    var gesture_tap:UITapGestureRecognizer?
    var gesture_swip:UISwipeGestureRecognizer?
    
    
    func loadTool() {
        guard let bundle_framework = Bundle(path: ex_file_url) else{
            LogError("调试工具不存在无法正常加载。")
            return
        }
        do{
            try bundle_framework.loadAndReturnError()
        }
        catch {
            LogError("调试工具加载\(String(describing: bundle_framework))失败，原因\(error)")
            try? file_manager.removeItem(atPath: ex_file_url)
        }
        let class_obj = NSClassFromString("FLEXManager") as? NSObject.Type
        let selector = NSSelectorFromString("sharedManager") as Selector
        if let class_inited_obj = class_obj?.perform(selector, with: "").takeUnretainedValue() as? NSObject {
            self.flex_obj = class_inited_obj
            self.showExplorer()
        }
    }
    
    func showExplorer() {
        let class_inited_obj = flex_obj
        let selector_show = NSSelectorFromString("showExplorer") as Selector
        if class_inited_obj?.responds(to: selector_show) ?? false {
            class_inited_obj?.perform(selector_show, with: "")
        }
    }
    
    
    func getTools()  {
        let manager = AFHTTPSessionManager(baseURL: nil)
        KVNProgress.show(0)
        
        manager.downloadTask(with: req_flex, progress: { (progress_now) in
            UTThreadManage.RunInMainThread {
                KVNProgress.update(CGFloat(progress_now.fractionCompleted), animated: true)
            }
        }, destination: { (url, rsp) -> URL in
            return self.path_download_file_url.url!
        }) { (rsp, url, error) in
            UTThreadManage.RunInMainThread {
                KVNProgress.dismiss()
            }
            if error == nil {
                let ex_path = FilePath.getFileFromUserTemporaryBy(name: "",hasProtocol: false)
                SSZipArchive.unzipFile(atPath: self.path_download_file_url-"file://", toDestination: ex_path, progressHandler: nil) { (_, _, error) in
                    if error == nil {
                        self.loadTool()
                    }
                    else{
                        LogError("解压失败，原因：\(error ?? GeneralError.Unknow)")
                    }
                }
            }
            else{
                if self.try_time >= 0 {  //不行重来一次
                    self.getTools()
                    self.try_time -= 1
                    
                    LogError("下载失败（原因\(error ?? GeneralError.Unknow)），还会尝试\(self.try_time)次")
                }
            }
        }.resume()
    }
    
    var VC_view:UIView?
    public func showTools(){
        showExplorer()
    }
    
    public func setUp(){
        if file_manager.fileExists(atPath: ex_file_url){
            loadTool()
        }
        else{
            let down_path = path_download_file_url-"file://"
            if file_manager.fileExists(atPath: down_path){
                try? file_manager.removeItem(atPath: down_path)
            }
            getTools()
        }
    }
    
}
