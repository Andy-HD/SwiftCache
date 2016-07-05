//
//  ViewController.swift
//  SwiftCache
//
//  Created by 海底之泪 on 16/7/1.
//  Copyright © 2016年 海底之泪. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet weak var WebView: UIWebView!
    //手动清除
    @IBAction func click(sender: UIButton) {
        
        $.deleteCache("webView")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //网页缓存
        $.shareCacheWebViewFloderName("webView")
        WebView.loadRequest(NSURLRequest.init(URL: NSURL.init(string: "http://www.sina.com")!))
        //定量清除
        //$.deleteCacheFolder("webView", size: 10)
        //对象缓存
        let arr = [12,34,55,11,44]
        $.savePage("xxx", value: arr, cacheCount: 1024*1024, clearTime: 24*60*60)
        
        $.getPage("xxx") { (object) in
            
            print(object)
        }
        
        //图片缓存
        let imageView = UIImageView.init(frame: CGRectMake(0,self.view.bounds.size.height-250,250, 300))
        self.view.addSubview(imageView)
        $.saveImage("sss", image: UIImage(named: "1"), cacheCount: 102481024, clearTime: 24*60)
        $.getImage("sss") { (image) in
            imageView.image = image
        }
        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}


//NSUserDefaults 类扩展
extension NSUserDefaults{
    //NSUserDefaults 封装
    
    public  func setDefaults(key:String ,value:AnyObject?) -> Void {
        if value == nil {
            
            NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
        }
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    
    public func removeDefaults(key:String?) -> Void {
        if key != nil {
            
            NSUserDefaults.standardUserDefaults().removeObjectForKey(key!)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
    }
    
    public func getDefaults(key:String?) -> AnyObject?{
        return NSUserDefaults.standardUserDefaults().objectForKey(key!)
    }
    
    
}

