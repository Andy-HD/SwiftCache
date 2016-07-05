//
//  HDCacheHelper.swift
//  SwiftCache
//
//  Created by 海底之泪 on 16/7/1.
//  Copyright © 2016年 海底之泪. All rights reserved.
//

/****************************说明**************************
*1.该缓存库目前对自定义的对象没有做缓存处理
*2.对于相同类型的对象将采用Plist文件进行存储
*3.对于自定义的对象可采用归档和接归档的形式进行存储读取
*4.目前尚未进行数据库的存储，将会在接下来的时间进行完善，添加重量结数据的存储问题
*5.已完善webview缓存，并设置手动与自动两种清除缓存的方式
*6.使用之前请导入SystemConfiguration.framework
**********************************************************/

import UIKit

typealias $ = HDCacheHelper

public struct HDCacheHelper {
//MARK: 存储

    /**
     文件，对象缓存
     
     - parameter key:
     - parameter value:         存储对象
     - parameter cacheCount:    按内存的大小清理内存（可选）
     - parameter clearTime:     按时间清理内存（可选）
     - parameter completHandle: 完成后的回调
     */
    static func savePage(key:String,value:AnyObject?,cacheCount:Int?,clearTime:Int64?,completHandle:(()->())?=nil){
        
        HDSwiftCache.shareCacheObject.store(key, value: value, image: nil, voice: nil, cacheCount: cacheCount,clearTime: clearTime, completHandle: completHandle)
    }
    /**
     图片缓存
     
     - parameter key:           键
     - parameter value:         存储对象
     - parameter cacheCount:    按内存的大小清理内存（可选）
     - parameter clearTime:     按时间清理内存（可选）
     - parameter completHandle: 完成后的回调
     */
    static func saveImage(key:String,image:UIImage?,cacheCount:Int?,clearTime:Int64?,completHandle:(()->())?=nil){
    
        
      
        HDSwiftCache.shareCacheImage.store(key, value: nil, image: image, voice: nil, cacheCount: cacheCount,clearTime:clearTime,completHandle: completHandle)
    
    }
    /**
     声音缓存
     
     - parameter key:           键
     - parameter value:         存储对象
     - parameter cacheCount:    按内存的大小清理内存（可选）
     - parameter clearTime:     按时间清理内存（可选）
     - parameter completHandle: 完成后的回调
     */
    static func saveVoice(key:String,value:NSData?,cacheCount:Int?,clearTime:Int64?,completHnadle:(()->())?=nil){
    
        HDSwiftCache.shareCacheImage.store(key, value: nil, image: nil, voice: value,cacheCount: cacheCount,clearTime: clearTime,completHandle: completHnadle)
    }
    
// MARK: 获取
    /**
     获取对象
     
     - parameter key:           key
     - parameter completHandle: 完成回调
     */
    static func getPage(key:String,completHandle:((object:AnyObject?)->())){
    
        HDSwiftCache.shareCacheObject.getStore(key, getObjectHandle: completHandle, getImage: nil, getVoice: nil)
    }
    /**
     获取图片
     
     - parameter key:           key
     - parameter completHandle: 完成回调
     */
    static func getImage(key:String,completHandle:((image:UIImage?)->())){
    
        HDSwiftCache.shareCacheImage.getStore(key, getObjectHandle: nil, getImage: completHandle, getVoice: nil)
        
    }
    /**
     获取声音
     
     - parameter key:           key
     - parameter completHandle: 完成回调
     */
    static func getVoice(key:String,completHandle:((data:NSData?)->())){
    
        HDSwiftCache.shareCacheVoice.getStore(key, getObjectHandle: nil, getImage: nil, getVoice: completHandle)
        
    }
    
// MARK: 网页缓存
    //删除缓存
    static func deleteCacheFolder(floderName:String,size:UInt64){
        
        WebCacheProtocol.deleteCacheFolderWithFolderName(floderName, floderSize: size)
    }
    //缓存文件名
    static func shareCacheWebViewFloderName(floderName:String){
    
        let web = WebCacheProtocol()
        web.WebCacheFolder = floderName
    }
    //手动删除
    static func deleteCache(name:String){
    
        WebCacheProtocol.deleteCache(name)
    }
    
    
    
}