//
//  ViewController.swift
//  轮播图
//
//  Created by 康世朋 on 16/7/5.
//  Copyright © 2016年 SP. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SPCycleScrollViewDelegate{
    var cycleView: SPCycleScrollview!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cycleView = SPCycleScrollview(frame: CGRectMake(0, 20, self.view.frame.size.width, 175), placeholderImage: UIImage(named: "1")!, delegate: self)
        cycleView.autoScroll = true //是否自动滚动
        cycleView.showPageControl = true //是否显示分页控件
        cycleView.imageUrlGroup = ["http://pic1.zhimg.com/05a55004e42ef9d778d502c96bc198a4.jpg", "http://pic3.zhimg.com/cd1240013a1c68392c81ba2df54ebb52.jpg"] //网络图片地址数组
        //cycleView.imageLocalGroup = ["1", "2", "3"] // 本地图片名称
        cycleView.autoScrollTimeInterval = 2 //滚动时间间隔
        
        //--点击事件---
        cycleView.didSelectItemAtIndex {
            print("闭包1点击的是第\($0)个")
        }
        cycleView.didSelectItemAtIndex { (index, cycleScrollView) in
            
            print("闭包2点击的是第\(index)个")
        }
        //-------
        self.view.addSubview(cycleView)
        //performSelector(#selector(self.changeFrame), withObject: nil, afterDelay: 2)
    }
    func changeFrame() {
        cycleView.frame = CGRectMake(30, 0, self.view.frame.size.width-60, 200)
        cycleView.imageUrlGroup = ["3","4"]
    }
    func spcycleScrollView(cycleScrollView: SPCycleScrollview, didSelectItemAtIndex index: Int) {
        print("代理\(index)")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

