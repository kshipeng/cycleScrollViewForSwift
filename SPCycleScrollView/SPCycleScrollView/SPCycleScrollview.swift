//
//  SPCycleScrollview.swift
//  轮播图
//
//  Created by 康世朋 on 16/7/5.
//  Copyright © 2016年 SP. All rights reserved.
/*
                                 _ooOoo_
                                o8888888o
                                88" . "88
                                (| -_- |)
                                O\  =  /O
                             ____/`---'\____
                           .'  \\|     |//  `.
                          /  \\|||  :  |||//  \
                         /  _||||| -:- |||||_  \
                         |   | \\\  -  /// |   |
                         | \_|  ''\---/''  |_/ |
                         \  .-\__  `-`  ___/-. /
                      ___ `. .'  /--.--\  `. . ___
                   . "" '<  `.___\_<|>_/___.'   >'"".
                   | | :  `- \`.;`\ _ /`;.`/ - ` : | |
                   \  \ `-.   \_ __\ /__ _/   .-` /  /
              ======`-.____`-.___\_____/___.-`____.-'======
                                 `=---='
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                           佛祖保佑       永无BUG
                佛曰:
                           写字楼里写字间，写字间里程序员；
                           程序人员写程序，又拿程序换酒钱。
                           酒醒只在网上坐，酒醉还来往下眠；
                           酒醉酒醒日复日，网上网下年复年。
                           但愿老死电脑间，不愿鞠躬老板前；
                           奔驰宝马贵者趣，公交自行程序员。
                           别人笑我忒疯癫，我笑自己命太贱；
                           不见满街漂亮妹，哪个归得程序员？
*/
//

import UIKit

@objc protocol SPCycleScrollViewDelegate: NSObjectProtocol{
    optional func spcycleScrollView(cycleScrollView: SPCycleScrollview, didSelectItemAtIndex index: Int) -> Void
}
typealias selectBlock = (index: Int, cycleScrollView: SPCycleScrollview) -> Void

class SPCycleScrollview: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource{

    var delegate: SPCycleScrollViewDelegate!
    private var didSelectItemAtIndex: selectBlock?
    var autoScrollTimeInterval = 2.0 {
        didSet{
            if self.autoScroll {
                addTimer(autoScrollTimeInterval)
            }
        }
    }

    var autoScroll = true {
        didSet{
            self.timer.invalidate()
            if autoScroll {
                addTimer(self.autoScrollTimeInterval)
            }
        }
    }
    var imageUrlGroup: [String]! {
        didSet{
            imagetype = imageType.NetWork
            configureLastArray(imageUrlGroup)
            self.mainCollectionView.reloadData()
            pageControl.numberOfPages = imageUrlGroup.count
        }
    }
    
    var imageLocalGroup: [String]! {
        didSet{
            imagetype = imageType.Loacl
            configureLastArray(imageLocalGroup)
            self.mainCollectionView.reloadData()
            pageControl.numberOfPages = imageLocalGroup.count
        }
    }
    //MARK: 分页控件的一些设置
    var showPageControl = true {
        didSet {
            pageControl.hidden = true
            if showPageControl == true {
                pageControl.hidden = false
            }
        }
    }
    var currentPageTintColor = UIColor.redColor() {
        didSet {
            pageControl.currentPageIndicatorTintColor = currentPageTintColor
        }
    }
    var pageControlIndicatorTintColor = UIColor.whiteColor() {
        didSet {
            pageControl.pageIndicatorTintColor = pageControlIndicatorTintColor
        }
    }
    
    //MARK: 私有变量
    private var placeholderImage: UIImage!
    private var urlArray = NSMutableArray()
    private var mainCollectionView: UICollectionView!
    private var currentItem = 1
    private var timer = NSTimer()
    private var flowLayout: UICollectionViewFlowLayout!
    private var currentIndex: NSIndexPath!
    private var selectIndexPath: NSIndexPath!
    private var imagetype: imageType!
    private var pageControl: UIPageControl!
    //MARK: 重写init
    init(frame: CGRect, localImageArray: [String], delegate: SPCycleScrollViewDelegate) {
        super.init(frame: frame)
        
        self.delegate = delegate
        imagetype = imageType.Loacl
        configureLastArray(localImageArray)
        self.currentIndex = NSIndexPath(forItem: 1, inSection: 0)
        setupCollectionView()
    }
    
    init(frame: CGRect, placeholderImage: UIImage, delegate: SPCycleScrollViewDelegate) {
        super.init(frame: frame)
        self.delegate = delegate
        self.imagetype = imageType.NetWork
        self.placeholderImage = placeholderImage
        self.currentIndex = NSIndexPath(forItem: 1, inSection: 0)
        setupCollectionView()
    }
    //MARK: 一些设置
    func configureLastArray(arr:[String]) -> Void {
        urlArray.removeAllObjects()
        urlArray.addObjectsFromArray(arr)
        if arr.count > 1 {
            urlArray.insertObject(arr.last!, atIndex: 0)
            urlArray.addObject(arr.first!)
        }
    }
    //MARK: 创建集合视图
    func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0.0;
        flowLayout.scrollDirection = .Horizontal
        self.flowLayout = flowLayout
        
        let mainCollectionView = UICollectionView(frame: self.bounds, collectionViewLayout: flowLayout)
        mainCollectionView.backgroundColor = UIColor.whiteColor()
        mainCollectionView.showsVerticalScrollIndicator = false
        mainCollectionView.showsHorizontalScrollIndicator = false
        mainCollectionView.pagingEnabled = true
        mainCollectionView.registerClass(SPCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        self.addSubview(mainCollectionView)
        if urlArray.count>1 && self.autoScroll == true{
            let indexPath = NSIndexPath(forItem: 1, inSection: 0)
            mainCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .None, animated: false)
            addTimer(self.autoScrollTimeInterval)
        }
        self.mainCollectionView = mainCollectionView
        createPageControl(urlArray.count - 2)
    }
    //MARK: 分页控件
    func createPageControl(pages: Int) {
        pageControl = UIPageControl(frame: CGRectMake((self.bounds.width - 100)/2, self.bounds.height-20, 100, 20))
        pageControl.currentPageIndicatorTintColor = UIColor.redColor()
        pageControl.pageIndicatorTintColor = UIColor.whiteColor()
        pageControl.numberOfPages = pages
        
        self.addSubview(pageControl)
    }
    //MARK: 自动滚动
    func addTimer(interval: Double) {
        self.timer.invalidate()
        let timer = NSTimer(timeInterval: self.autoScrollTimeInterval, target: self, selector: #selector(self.changePicture), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        self.timer = timer
    }
    
    func changePicture() {
        guard urlArray.count > 1 else { return }
        var toIndex: NSIndexPath!        
        currentItem += 1
        if currentItem <= urlArray.count-1 {
            toIndex = NSIndexPath(forItem: currentItem, inSection: 0)
            self.mainCollectionView.scrollToItemAtIndexPath(toIndex, atScrollPosition: .None, animated: true)
        }
        if currentItem == urlArray.count - 1 {
            currentItem = 1
            performSelector(#selector(self.toFirstItem), withObject: nil, afterDelay: 0.3)
        }
        pageControl.currentPage = currentItem-1
    }
    
    func toFirstItem() {
        let toIndex = NSIndexPath(forItem: 1, inSection: 0)
        self.mainCollectionView.scrollToItemAtIndexPath(toIndex, atScrollPosition: .None, animated: false)
    }
    //MARK:
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.mainCollectionView.frame = self.bounds
        self.flowLayout.itemSize = self.bounds.size
        self.mainCollectionView.reloadData()
        if self.mainCollectionView != nil && self.currentIndex != nil{
            self.mainCollectionView.scrollToItemAtIndexPath(currentIndex, atScrollPosition: .None, animated: false)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: 集合视图代理方法
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urlArray.count;
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return self.bounds.size
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! SPCollectionViewCell
        cell.imagetype = self.imagetype
        cell.placeholderImage = self.placeholderImage
        cell.imageStr = urlArray[indexPath.item] as? NSString
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectIndexPath = indexPath
        if self.delegate != nil {
            self.delegate.spcycleScrollView!(self, didSelectItemAtIndex: urlArray.count>1 ? indexPath.row - 1 : indexPath.item)
        }
        
        if didSelectItemAtIndex != nil {
            didSelectItemAtIndex!(index: urlArray.count>1 ? indexPath.item - 1 : indexPath.item, cycleScrollView: self)
        }
    }
    
    func didSelectItemAtIndex(block: selectBlock) -> Void {
        didSelectItemAtIndex = block
    }
    
    // MARK: 滚动视图代理方法
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let lastIndex: NSIndexPath = mainCollectionView.indexPathsForVisibleItems().last!
        self.currentIndex = lastIndex
        var toIndex: NSIndexPath!
        currentItem = lastIndex.item
        if lastIndex.item == urlArray.count - 1 {
            toIndex = NSIndexPath(forItem: 1, inSection: 0)
            self.mainCollectionView.scrollToItemAtIndexPath(toIndex, atScrollPosition: .None, animated: false)
            currentItem = toIndex.item
            currentIndex = toIndex
        }else if lastIndex.item == 0 {
            let rowForItem = urlArray.count - 2
            toIndex = NSIndexPath(forItem: rowForItem, inSection: 0)
            self.mainCollectionView.scrollToItemAtIndexPath(toIndex, atScrollPosition: .None, animated: false)
            currentItem = toIndex.item
            currentIndex = toIndex
        }
        pageControl.currentPage = currentItem-1
        guard autoScroll else {return}
        addTimer(self.autoScrollTimeInterval)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.timer.invalidate()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

//MARK: cell
class SPCollectionViewCell: UICollectionViewCell {
    private var imageView = UIImageView()
    
    var imagetype: imageType!
    var placeholderImage: UIImage! {
        didSet{
            guard placeholderImage != nil && imagetype == imageType.NetWork else {return}
            imageView.image = placeholderImage
        }
    }
    
    var imageStr: NSString! {
        didSet {
            guard imagetype != nil else {return}
            if imagetype == imageType.Loacl {
                imageView.image = UIImage(named: self.imageStr as String)
            }
            guard imagetype == imageType.NetWork else {return}
            SPNetworking().requsetWithPath(imageStr as String) {
                self.imageView.image = UIImage(data: $0)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(imageView)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: 图片类型(本地or网络)
enum imageType {
    case Loacl
    case NetWork
}

//MARK: 网络请求
typealias successBlock = (data: NSData) ->Void
class SPNetworking: NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate {
    private var successful: successBlock!
    private var urlKey: String!
    func requsetWithPath(path: String, successed: successBlock) ->(SPNetworking){
        successful = successed
        if (SPCache.shareCache.objectForKey(path) != nil && successful != nil) {
            let cdata = SPCache.shareCache.objectForKey(path) as! NSData
            successful(data: cdata)
            return self
        }
        
        self.urlKey = path
        let url = NSURL(string: path)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        let task = session.dataTaskWithURL(url!)
        task.resume()
        
        return self
    }
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        let muData = NSMutableData()
        muData.appendData(data)
        if successful != nil {
            successful(data: muData)
        }
        SPCache.shareCache.setObject(muData, forKey: self.urlKey)
        session.finishTasksAndInvalidate()
    }
    
    func successed(success: successBlock) {
        successful = success
    }
}

//MARK: 图片数据缓存
class SPCache: NSCache {
    static let shareCache = SPCache()
    private override init() {
        super.init()
        self.countLimit = 10
        self.totalCostLimit = 50
    }
}


