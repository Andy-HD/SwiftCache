//
//  HDSwiftCache.swift
//  SwiftCache
//
//  Created by 海底之泪 on 16/7/1.
//  Copyright © 2016年 海底之泪. All rights reserved.
//

import UIKit

private let page = HDSwiftCache(type:.Object)
private let image = HDSwiftCache(type:.Image)
private let voice = HDSwiftCache(type:.Voice)

let clearTimeFlags = "clearTime"
enum CacheFor:String {
    case Object = "hdObject" //页面文件
    case Image = "hdImage"  //图片文件
    case Voice = "hdVoice" //声音文件
}


public class HDSwiftCache {
// MARK: 公开变量
     public class var shareCacheObject:HDSwiftCache{
     
          return page
     }
     
     public class var shareCacheImage:HDSwiftCache{
     
          return image
     }
     
     public class var shareCacheVoice:HDSwiftCache{
     
          return voice
     }
// MARK: 私有变量
     private let defaultCacheName = "hd_default"
     private let cachePrex = "com.hd.hddisk.cache."
     private let iOQueueName = "com.hd.hddisk.cache.ioQueue."
     
     private var fileManager = NSFileManager()
     private let isQueue : dispatch_queue_t
     private var diskCachePath = String()
     private var storType :CacheFor
     private let userDefault = NSUserDefaults.standardUserDefaults()

     
// MARK: 公开的存储方法
     
     public func store(key:String,value:AnyObject? = nil,image:UIImage?,voice:NSData?,cacheCount:Int?,clearTime:Int64?, completHandle:(()->())?=nil){
     
          let path = self.cachePathForKey(key)
          switch storType {
          case .Object:
               self.ObjectStore(key, value: value, path: path,cacheCount: cacheCount,clearTime:clearTime, completeHandler: completHandle )
          case .Image:
               self.imageStore(image!, key: key, path: path,cacheCount:cacheCount,clearTime: clearTime,  completHandle: completHandle)
          case .Voice:
               self.voiceStore(voice!, key: key, path: path,cacheCount: cacheCount,clearTime: clearTime, completHandle: completHandle)
          }
          
     }
// MARK: 工开的获取方法
     public func getStore(key:String ,getObjectHandle:((object:AnyObject?)->())?,getImage:((image:UIImage?)->())?,getVoice:((voice:NSData?)->())?){

          let path = self.cachePathForKey(key)
          switch storType {
          case .Object:
               self.getObject(key, path: path, ObjectGetHandle: getObjectHandle)
          case .Image:
               self.getImage(path, imageGetHandle: getImage)
          case .Voice:
               self.getVoice(path, voiceGetHandel: getVoice)
          }
          
     }
     
     
     
// MARK: 初始化
    init(type:CacheFor){
    
        self.storType = type
        let cacheName = cachePrex+type.rawValue
        isQueue = dispatch_queue_create(iOQueueName+type.rawValue, DISPATCH_QUEUE_SERIAL)
        // 获取缓存目
         let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
          //创建缓存下子目录
          diskCachePath = (paths.first! as NSString).stringByAppendingPathComponent(cacheName)
     
          dispatch_async(isQueue) { () -> Void in
          
               self.fileManager = NSFileManager()
               
               do {
               
                  try  self.fileManager.createDirectoryAtPath(self.diskCachePath, withIntermediateDirectories: true, attributes: nil)
               }catch _{}
          }
     
        
    }
     
// MARK: 文件存储
     /**
      文件存储
      
      - parameter key:             键
      - parameter value:           文件
      - parameter path:            路径
      - parameter cacheCount:      限制缓存大小
      - parameter completeHandler: 完成后的回调
      */
     private func ObjectStore(key:String? ,value:AnyObject? ,path:String,cacheCount:Int?,clearTime:Int64?,completeHandler:(()->())? = nil){
         //按大小缓存清理
          if cacheCount != nil {
               self.removeCacheWithSize(cacheCount!)
          }
          if clearTime != nil {
               self.removeCacheWithTime(clearTime!)
          }
          let filePath = path+key!+".plist"
          value?.writeToFile(filePath, atomically: true)
          self.saveTimestamp(clearTime)
          
//          var isArchive = Bool()
//              isArchive = NSKeyedArchiver.archiveRootObject(value!, toFile: path)
//          if isArchive {
//               if clearTime != nil {
//                    self.saveTimestamp(clearTime!)
//               }
//               print("归档成功")
//          }else{
//          
//               print("归档失败")
//          }
     }
     /**
      图片存储
      
      - parameter key:             键
      - parameter value:           图片
      - parameter path:            路径
      - parameter cacheCount:      限制缓存大小
      - parameter completeHandler: 完成后的回调
      */
     private func imageStore(image:UIImage ,key:String ,path:String,cacheCount:Int?,clearTime:Int64?,completHandle:(()->())?=nil){

          if cacheCount != nil {
               self.removeCacheWithSize(cacheCount)
          }
          if clearTime != nil {
               self.removeCacheWithTime(clearTime)
          }
          let data = UIImagePNGRepresentation(image)
          if let data = data {
               self.fileManager.createFileAtPath(path, contents: data, attributes: nil)
               self.saveTimestamp(clearTime)
          }
          
     }
     /**
      音频存储
      
      - parameter key:             键
      - parameter value:           音频
      - parameter path:            路径
      - parameter cacheCount:      限制缓存大小
      - parameter completeHandler: 完成后的回调
      */     private func voiceStore(data:NSData?,key:String,path:String,cacheCount:Int?,clearTime:Int64?,completHandle:(()->())?=nil){
          if cacheCount != nil {
               self.removeCacheWithSize(cacheCount)
          }
          if clearTime != nil{
               self.removeCacheWithTime(clearTime)
          }
          
          if let data = data {
               self.fileManager.createFileAtPath(path, contents: data, attributes: nil)
               if clearTime != nil {
                    self.saveTimestamp(clearTime)
               }
          }
     }
     
// MARK: 获取存储的文件
     /**
      获取Object
      - parameter key:             键
      - parameter path:            路径
      - parameter ObjectGetHandle: 获取完成的回调
      */
     private func getObject(key:String ,path:String ,ObjectGetHandle:((object:AnyObject?)->())?){

          
          print(path+key)
          let cachData = NSDictionary(contentsOfFile:path+key+".plist")
          let cacheData2 = NSArray.init(contentsOfFile: path+key+".plist")
          
          print("websData == \(cachData)")
          if cachData != nil {
               ObjectGetHandle!(object:cachData)
          }else if cacheData2 !=  nil {
          
               ObjectGetHandle!(object:cacheData2)
          }else{
                ObjectGetHandle!(object:nil)
          }
     }
     /**
      图片文件获取
      
      - parameter path:           路径
      - parameter imageGetHandle: 获取后的回调
      */
     private func getImage(path:String ,imageGetHandle:((image:UIImage?)->())?){
     
               if let data = NSData.init(contentsOfFile: path){
                    if let image = UIImage(data:data){
                    
                         imageGetHandle?(image:image)
                         
                    }else{
                    
                         imageGetHandle?(image:nil)
                    }
                    
               }
     }
     /**
      获取声音文件
      
      - parameter path:           路径
      - parameter voiceGetHandel: 获取后的回调
      */
     private func getVoice(path:String,voiceGetHandel:((data:NSData?)->())?){
                    if let data = NSData.init(contentsOfFile: path){
     
                    voiceGetHandel?(data:data)
               }else{
                    
                    voiceGetHandel?(data:nil)
               }
     }
   
     
// MARK: 按缓存大小清理缓存
     /**
      按文件大小清除缓存
      
      - parameter cacheCount: 规定的文件大小
      */
     private func removeCacheWithSize(cacheCount:Int?){
          if cacheCount != nil {
               
               if fileManager.fileExistsAtPath(diskCachePath) {
                    
                    let cache = self.fileSizeOfCache(diskCachePath)
                    if cache > cacheCount  {
                         
                         self.clearCache(diskCachePath)
                         
                         print("size=\(self.fileSizeOfCache(diskCachePath))")
                    }
               }
          }

     }
     
     //获取缓存文件大小
     private func fileSizeOfCache(path:String)-> Int {
          
          //缓存目录路径
          print(path)
          
          // 取出文件夹下所有文件数组
          let fileArr = NSFileManager.defaultManager().subpathsAtPath(path)
          
          //快速枚举出所有文件名 计算文件大小
          var size = 0
          for file in fileArr! {
               
               // 把文件名拼接到路径中
               let filepath = path.stringByAppendingString("/\(file)")
               // 取出文件属性
               let floder = try! NSFileManager.defaultManager().attributesOfItemAtPath(filepath)
               // 用元组取出文件大小属性
               for (abc, bcd) in floder {
                    // 累加文件大小
                    if abc == NSFileSize {
                         size += bcd.integerValue
                    }
               }
          }
          
          let mm = size / 1024 / 1024
          
          return mm
     }
     //清除缓存
     private func clearCache(path:String) {
          
          
          // 取出文件夹下所有文件数组
          let fileArr = NSFileManager.defaultManager().subpathsAtPath(path)
          
          // 遍历删除
          for file in fileArr! {
               
               let filepath = path.stringByAppendingString("/\(file)")
               if NSFileManager.defaultManager().fileExistsAtPath(filepath) {
                    
                    do {
                         try NSFileManager.defaultManager().removeItemAtPath(filepath)
                    } catch {
                         
                    }
               }
          }
     }
     
// MARK: 按时间清理缓存
     //按时间清除缓存是的判断
     private func removeCacheWithTime(clearTime:Int64?)->Void{
          
          //按时间清理缓存 或者按时间进行缓存
          let nowTime = NSDate()
          let nowTimeString = self.timeTurnString(nowTime)
          let nowTimeStamp = self.stringTurnToTimestamp(nowTimeString)
          let nowTimeInt64 = Int64(nowTimeStamp)
          
          var clear = String?()
          clear = userDefault.getDefaults(clearTimeFlags) as? String
          var clearInt64 = Int64?()
          if clear != nil {
               clearInt64 =  Int64(clear!)
          }
          
          if clearTime != nil{
               
               if nowTimeInt64 >= clearInt64 {
                    
                    print("清除缓存")
                    //此处清除缓存，同时一并清除缓存的时间戳，以便再次缓存
                    userDefault.removeDefaults(clearTimeFlags)
               }
               //
          }
     }
     
     
     //返回时间字符串
     private func timeTurnString(date:NSDate)->String {
          let dformatter = NSDateFormatter()
          dformatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
          let timeString = dformatter.stringFromDate(date)
          return timeString
     }
     
     
     //字符串返回时间戳
     private func stringTurnToTimestamp(stringTime:String)->String {
          
          let dfmatter = NSDateFormatter()
          dfmatter.dateFormat="yyyy年MM月dd日 HH:mm:ss"
          let date = dfmatter.dateFromString(stringTime)
          
          let dateStamp = date?.timeIntervalSince1970
          
          let dateSt = Int64(dateStamp!)
          return String(dateSt)
          
     }

     
     //缓存完成后存储时间戳
     private func saveTimestamp(clearTime:Int64?)->Void{
     
          //判断缓存时的时间戳是否保存，如果保存则不再保存
          if clearTime != nil {
               var clear = String?()
               clear =  userDefault.objectForKey(clearTimeFlags) as? String
               if clear == nil {
                    let cacheDate = NSDate()
                    let nowString = self.timeTurnString(cacheDate)//NSDate转换为时间字符串
                    print("缓存时间戳==\(self.stringTurnToTimestamp(nowString))")//时间字符串转换为时间戳
                    let time = NSTimeInterval.init(integerLiteral: clearTime!)
                    let clearDate  = cacheDate.dateByAddingTimeInterval(time)
                    let clearTimeString = self.timeTurnString(clearDate)
                    print("时间戳是啊==\(self.stringTurnToTimestamp(clearTimeString))")
                    userDefault.setDefaults(clearTimeFlags, value:self.stringTurnToTimestamp(clearTimeString))
                    print(clearTimeString)
               }
          }
     }
     
     //webView缓存
     
     
}
//对象存储的时候需要一个路径和一个key，这里写了两个方法来管理这个key，key既作为路径也作为取值的key并对它进行md5加密
extension HDSwiftCache{

     func cachePathForKey(key:String) -> String {
          
          let fileName = cachePathForFileName(key)//MD5加密
          return (diskCachePath as NSString).stringByAppendingPathComponent(fileName)
     }
     //MD5加密
     func cachePathForFileName(key:String) -> String {
          
          return key.hd_MD5()
     }
}
