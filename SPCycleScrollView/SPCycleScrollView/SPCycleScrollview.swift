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
    @objc optional func spcycleScrollView(_ cycleScrollView: SPCycleScrollview, didSelectItemAtIndex index: Int) -> Void
}
typealias selectBlock = (_ index: Int, _ cycleScrollView: SPCycleScrollview) -> Void

class SPCycleScrollview: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource{

    var delegate: SPCycleScrollViewDelegate!
    fileprivate var didSelectItemAtIndex: selectBlock?
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
            imagetype = imageType.netWork
            configureLastArray(imageUrlGroup)
            self.mainCollectionView.reloadData()
            pageControl.numberOfPages = imageUrlGroup.count
        }
    }
    
    var imageLocalGroup: [String]! {
        didSet{
            imagetype = imageType.loacl
            configureLastArray(imageLocalGroup)
            self.mainCollectionView.reloadData()
            pageControl.numberOfPages = imageLocalGroup.count
        }
    }
    //MARK: 分页控件的一些设置
    var showPageControl = true {
        didSet {
            pageControl.isHidden = true
            if showPageControl == true {
                pageControl.isHidden = false
            }
        }
    }
    var currentPageTintColor = UIColor.red {
        didSet {
            pageControl.currentPageIndicatorTintColor = currentPageTintColor
        }
    }
    var pageControlIndicatorTintColor = UIColor.white {
        didSet {
            pageControl.pageIndicatorTintColor = pageControlIndicatorTintColor
        }
    }
    
    //MARK: 私有变量
    fileprivate var placeholderImage: UIImage!
    fileprivate var urlArray = NSMutableArray()
    fileprivate var mainCollectionView: UICollectionView!
    fileprivate var currentItem = 1
    fileprivate var timer = Timer()
    fileprivate var flowLayout: UICollectionViewFlowLayout!
    fileprivate var currentIndex: IndexPath!
    fileprivate var selectIndexPath: IndexPath!
    fileprivate var imagetype: imageType!
    fileprivate var pageControl: UIPageControl!
    //MARK: 重写init
    init(frame: CGRect, localImageArray: [String], delegate: SPCycleScrollViewDelegate) {
        super.init(frame: frame)
        
        self.delegate = delegate
        imagetype = imageType.loacl
        configureLastArray(localImageArray)

        setupCollectionView()
    }
    
    init(frame: CGRect, placeholderImage: UIImage, delegate: SPCycleScrollViewDelegate) {
        super.init(frame: frame)
        self.delegate = delegate
        self.imagetype = imageType.netWork
        self.placeholderImage = placeholderImage

        setupCollectionView()
    }
    //MARK: 一些设置
    fileprivate func configureLastArray(_ arr:[String]) -> Void {
        urlArray.removeAllObjects()
        urlArray.addObjects(from: arr)
        if arr.count > 1 {
            urlArray.insert(arr.last!, at: 0)
            urlArray.add(arr.first!)
            self.currentIndex = IndexPath(item: 1, section: 0)

        }else{
            self.currentIndex = IndexPath(item: 0, section: 0)

        }
    }
    //MARK: 创建集合视图
    fileprivate func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0.0;
        flowLayout.scrollDirection = .horizontal
        self.flowLayout = flowLayout
        
        let mainCollectionView = UICollectionView(frame: self.bounds, collectionViewLayout: flowLayout)
        mainCollectionView.backgroundColor = UIColor.white
        mainCollectionView.showsVerticalScrollIndicator = false
        mainCollectionView.showsHorizontalScrollIndicator = false
        mainCollectionView.isPagingEnabled = true
        mainCollectionView.register(SPCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        self.addSubview(mainCollectionView)
        if urlArray.count>1 && self.autoScroll == true{
            let indexPath = IndexPath(item: 1, section: 0)
            mainCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: false)
            addTimer(self.autoScrollTimeInterval)
        }
        self.mainCollectionView = mainCollectionView
        createPageControl(urlArray.count - 2)
    }
    //MARK: 分页控件
    fileprivate func createPageControl(_ pages: Int) {
        pageControl = UIPageControl(frame: CGRect(x: (self.bounds.width - 100)/2, y: self.bounds.height-20, width: 100, height: 20))
        pageControl.currentPageIndicatorTintColor = UIColor.red
        pageControl.pageIndicatorTintColor = UIColor.white
        pageControl.numberOfPages = pages
        
        self.addSubview(pageControl)
    }
    //MARK: 自动滚动
    fileprivate func addTimer(_ interval: Double) {
        self.timer.invalidate()
        let timer = Timer(timeInterval: self.autoScrollTimeInterval, target: self, selector: #selector(self.changePicture), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        self.timer = timer
    }
    
    @objc fileprivate func changePicture() {
        guard urlArray.count > 1 else { return }
        var toIndex: IndexPath!        
        currentItem += 1
        if currentItem <= urlArray.count-1 {
            toIndex = IndexPath(item: currentItem, section: 0)
            self.mainCollectionView.scrollToItem(at: toIndex, at: UICollectionViewScrollPosition(), animated: true)
        }
        if currentItem == urlArray.count - 1 {
            currentItem = 1
            perform(#selector(self.toFirstItem), with: nil, afterDelay: 0.3)
        }
        pageControl.currentPage = currentItem-1
    }
    
    @objc fileprivate func toFirstItem() {
        let toIndex = IndexPath(item: 1, section: 0)
        self.mainCollectionView.scrollToItem(at: toIndex, at: UICollectionViewScrollPosition(), animated: false)
    }
    //MARK: 子视图布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.mainCollectionView.frame = self.bounds
        self.flowLayout.itemSize = self.bounds.size
        self.mainCollectionView.reloadData()
        if self.mainCollectionView != nil && self.currentIndex != nil && urlArray.count > 1{
            self.mainCollectionView.scrollToItem(at: currentIndex, at: UICollectionViewScrollPosition(), animated: false)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: 集合视图代理方法
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if placeholderImage != nil && urlArray.count == 0 {
            return 1
        }
        return urlArray.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SPCollectionViewCell
        cell.imagetype = self.imagetype
        cell.placeholderImage = self.placeholderImage
        if urlArray.count != 0 {
            cell.imageStr = urlArray[(indexPath as NSIndexPath).item] as? NSString
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectIndexPath = indexPath
        if self.delegate != nil {
            self.delegate.spcycleScrollView!(self, didSelectItemAtIndex: urlArray.count>1 ? (indexPath as NSIndexPath).row - 1 : (indexPath as NSIndexPath).item)
        }
        
        if didSelectItemAtIndex != nil {
            didSelectItemAtIndex!(urlArray.count>1 ? (indexPath as NSIndexPath).item - 1 : (indexPath as NSIndexPath).item, self)
        }
    }
    
    func didSelectItemAtIndex(_ block: @escaping selectBlock) -> Void {
        didSelectItemAtIndex = block
    }
    
    // MARK: 滚动视图代理方法
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let lastIndex: IndexPath = mainCollectionView.indexPathsForVisibleItems.last!
        self.currentIndex = lastIndex
        var toIndex: IndexPath!
        currentItem = (lastIndex as NSIndexPath).item
        if (lastIndex as NSIndexPath).item == urlArray.count - 1 {
            toIndex = IndexPath(item: 1, section: 0)
            self.mainCollectionView.scrollToItem(at: toIndex, at: UICollectionViewScrollPosition(), animated: false)
            currentItem = toIndex.item
            currentIndex = toIndex
        }else if (lastIndex as NSIndexPath).item == 0 {
            let rowForItem = urlArray.count - 2
            toIndex = IndexPath(item: rowForItem, section: 0)
            self.mainCollectionView.scrollToItem(at: toIndex, at: UICollectionViewScrollPosition(), animated: false)
            currentItem = toIndex.item
            currentIndex = toIndex
        }
        pageControl.currentPage = currentItem-1
        guard autoScroll else {return}
        addTimer(self.autoScrollTimeInterval)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.timer.invalidate()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    //MARK: 清除图片缓存
    func clearCache() {
        SPCache.shareCache.removeAllObjects()
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
private class SPCollectionViewCell: UICollectionViewCell {
    fileprivate var imageView = UIImageView()
    
    var imagetype: imageType!
    var placeholderImage: UIImage! {
        didSet{
            guard placeholderImage != nil && imagetype == imageType.netWork else {return}
            imageView.image = placeholderImage
        }
    }
    
    var imageStr: NSString! {
        didSet {
            guard imagetype != nil else {return}
            if imagetype == imageType.loacl {
                imageView.image = UIImage(named: self.imageStr as String)
            }
            guard imagetype == imageType.netWork else {return}
            SPNetworking().requsetWithPath(imageStr as String) { (cdata) in
                let img = UIImage(data: cdata)
                self.imageView.image = img
                if img == nil {
                    self.imageView.image = self.placeholderImage
                }
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
    case loacl
    case netWork
}

//MARK: 网络请求
typealias successBlock = (_ data: Data) ->Void
private class SPNetworking: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    fileprivate var successful: successBlock!
    fileprivate var urlKey: String!
    fileprivate var myData = NSMutableData()
    fileprivate var muData: NSMutableData!
    @discardableResult
    func requsetWithPath(_ path: String, successed: @escaping successBlock) ->(SPNetworking){
        successful = successed
        if (SPCache.shareCache.object(forKey: path as AnyObject) != nil && successful != nil && (SPCache.shareCache.object(forKey: path as AnyObject) as! Data).count != 0) {
            let cdata = SPCache.shareCache.object(forKey: path as AnyObject) as! Data
            successful(cdata)
            return self
        }
        
        self.urlKey = path
        muData = NSMutableData()
        let url = URL(string: path)
        let config = URLSessionConfiguration.default
        let session = Foundation.URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: url!)
        task.resume()
        
        return self
    }
    @objc func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        muData.append(data)
        self.myData = muData
        
    }
    
    @objc func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if successful != nil {
            successful(myData as Data)
        }
        SPCache.shareCache.setObject(myData, forKey: self.urlKey as AnyObject)
    }
    
    func successed(_ success: @escaping successBlock) {
        successful = success
    }
}

//MARK: 图片数据缓存
private class SPCache: NSCache<AnyObject, AnyObject> {
    static let shareCache = SPCache()
    fileprivate override init() {
        super.init()
//        self.countLimit = 10
//        self.totalCostLimit = 50
    }
}


