//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import UIKit
import Toast_Swift
import Alamofire
import AlamofireImage
import Async
import CarbonKit

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    @IBOutlet var viewLoading: UIView!
    @IBOutlet var lblLoading: UILabel!
    @IBOutlet var indicatorLoading: UIActivityIndicatorView!

    @IBOutlet var timeLine: UITableView!

    private var carbonRefresh:CarbonSwipeRefresh!

    private var imageCache:AutoPurgingImageCache!

    private var timelineTitle:String!
    private var timelineType:C.TimelineType!
    private var tabType:C.TabType!

    private var items:Array<TimelineItem>!
    private var posts:Array<Post>!

    private var currentIndexPath:NSIndexPath?

    private var cellHeight:CGFloat = 352

    private var isSearchView:Bool=false
    private var isViewLoaded:Bool=false
    private var isFirstVideoPlayedByDelegate:Bool=false

    func setAsSearchView(){
        self.isSearchView = true
    }

    func setType(timelineType:C.TimelineType){
        self.timelineType = timelineType

        self.isSearchView = false

        switch timelineType {
            case C.TimelineType.SHOPS:
                timelineTitle = C.TOP_TAB_NAME_HOME_SHOPS
                tabType = C.TabType.HOME_SHOPS
            case C.TimelineType.HERBS:
                timelineTitle = C.TOP_TAB_NAME_HOME_HERBS
                tabType = C.TabType.HOME_HERBS
            case C.TimelineType.TUNES:
                timelineTitle = C.TOP_TAB_NAME_HOME_TUNES
                tabType = C.TabType.HOME_TUNES
            case C.TimelineType.VIBES:
                timelineTitle = C.TOP_TAB_NAME_HOME_VIBES
                tabType = C.TabType.HOME_VIBES
            case C.TimelineType.LIVE:
                timelineTitle = C.TOP_TAB_NAME_LIVE_STREAMS_LIVE
                tabType = C.TabType.LIVE
            case C.TimelineType.SEARCH:
                timelineTitle = C.TOP_TAB_NAME_SEARCH
                tabType = C.TabType.SEARCH
                self.isSearchView = true
        }
    }

    func setLoadingState(){
        if (isViewLoaded) {
            viewLoading.hidden = false
            indicatorLoading.hidden = true
            lblLoading.hidden = true
            lblLoading.text = "Loading..."

            carbonRefresh.startRefreshing()
        }
    }

    func setEmptyState(){
        if (isViewLoaded) {
            viewLoading.hidden = false
            indicatorLoading.hidden = true
            lblLoading.hidden = false
            lblLoading.text = "No items to display"
            timeLine.hidden = true

            carbonRefresh.endRefreshing()
        }
    }

    func setBlankState(){
        if (isViewLoaded) {
            viewLoading.hidden = true
            timeLine.hidden = true

            carbonRefresh.endRefreshing()
        }
    }

    func setWithContentState(){
        if (isViewLoaded) {
            viewLoading.hidden = true
            timeLine.hidden = false

            carbonRefresh.endRefreshing()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imageCache = AutoPurgingImageCache(
                memoryCapacity: 100 * 1024 * 1024,
                preferredMemoryUsageAfterPurge: 60 * 1024 * 1024
                )


            carbonRefresh = CarbonSwipeRefresh(scrollView: timeLine)
            carbonRefresh.colors = [ThemeUtil.getMainColor(self.tabType)]
            self.view.addSubview(carbonRefresh)

        if(!isSearchView){
            carbonRefresh.addTarget(self, action: #selector(TimelineViewController.refreshContent(_:)), forControlEvents: UIControlEvents.ValueChanged)
        }

        cellHeight =  UIScreen.mainScreen().bounds.width * 1.1

        currentIndexPath = NSIndexPath(forRow:0, inSection:0);

        isViewLoaded = true

        if (!isSearchView) {
            loadData()
        }else{
            setBlankState()

            items = Array<TimelineItem>()
            posts = Array<Post>()

            timeLine.dataSource = self
            timeLine.delegate = self
        }
        setupListeners()
    }

    override func viewWillDisappear(animated: Bool) {
        pauseAllVideos(self.timeLine)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        isViewLoaded = true

        //playCurrentVisibleVideo()

        Request.addAcceptableImageContentTypes(["binary/octet-stream"])

        if let _ = timelineType{
            NSNotificationCenter.defaultCenter().postNotificationName(C.TOP_TAB_CHANGED, object: self, userInfo:["TabType":tabType.rawValue])
        }
    }

    private func loadData(){
        items = TimelineManager.getTimelineByType(timelineType)
        if(items.count>0){
            setWithContentState()
        }else{
            setLoadingState()
        }

        timeLine.dataSource = self
        timeLine.delegate = self

        timeLine.reloadData()
    }

    private func setupListeners(){
        if(isSearchView) {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TimelineViewController.onPostDownloadedNotification(_:)), name: C.SEARCH_POSTS_DOWNLOADED, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TimelineViewController.onPostNotDownloadedNotification(_:)), name: C.SEARCH_POSTS_NOT_DOWNLOADED, object: nil)
        }else{
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TimelineViewController.onPostDownloadedNotification(_:)), name: C.POSTS_DOWNLOADED, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TimelineViewController.onPostNotDownloadedNotification(_:)), name: C.POSTS_NOT_DOWNLOADED, object: nil)
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TimelineViewController.stopAllPlayers(_:)), name:C.TOP_TAB_CHANGED, object: nil)

    }

    func refreshContent(sender: AnyObject){
        pauseAllVideos(self.timeLine)

        TimelineManager.fetchTimelineFromServer()
        setLoadingState()
    }

    @objc func onPostDownloadedNotification(notification: NSNotification){
        if(!isSearchView) {
            items = TimelineManager.getTimelineByType(timelineType)

            if(items.count==0){
                setEmptyState()
            }else{
                setWithContentState()
            }
        }else{
            posts = TimelineManager.getPostFromSearch()

            if(posts.count==0){
                setEmptyState()
            }else{
                setWithContentState()
            }
        }
        timeLine.reloadData()

    }

    @objc func onPostNotDownloadedNotification(notification: NSNotification){
        if((items.count==0)||(isSearchView)){
            setEmptyState()
        }
    }

    @objc func stopAllPlayers(notification: NSNotification){
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        if let type = userInfo["TabType"] {
            if(tabType.rawValue != type){
                pauseAllVideos(self.timeLine)
            }
        }

    }

    func tableView(tableView: UITableView, numberOfSectionsInTableView section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(isSearchView){
            return posts.count
        }else {
            return items.count
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("TimelineCell", forIndexPath: indexPath)
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let item = cell as? TimelineCell {

            if(isSearchView){
                let post:Post = posts[indexPath.row] as Post

                item.setPost(post)

            }else {
                let timelineItem:TimelineItem = items[indexPath.row] as TimelineItem

                item.setPost(timelineItem.post)
            }

            if(!SimplePersistence.getBool("OPEN_VIDEO_FROM_NOTIFICATION")) {
                item.setTabType(self.tabType)
                if ((indexPath.row == 0) && (!isFirstVideoPlayedByDelegate)) {
                    Async.main(after: 0.5) {
                        item.play()
                        self.isFirstVideoPlayedByDelegate = true
                    }
                }
            }


            //}else if let ad = timelineItem.adSpace {
            //set ad
            //}else{
            //do nothing ???
            //}
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        NSObject.cancelPreviousPerformRequestsWithTarget(self)

        self.performSelector(#selector(TimelineViewController.scrollViewDidEndScrollingAnimation(_:)), withObject:nil, afterDelay: 0.5)

        pauseNoLongerFullyVisibleVideo(timeLine)
    }

    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        NSObject.cancelPreviousPerformRequestsWithTarget(self)

        playVisibleVideo(timeLine)
    }

    func pauseAllVideos(tableView:UITableView){
        for tuple in getAllCells(tableView){
            tuple.0.stop()
        }
    }

    func pauseNoLongerFullyVisibleVideo(tableView:UITableView){
        for tuple in getVisibleCells(tableView){
            if(!isVideoPlayerInsideCellVisible(tuple.0,indexPath:tuple.1,tableView:tableView)){
                tuple.0.pause()
            }
        }
    }

    func playVisibleVideo(tableView:UITableView){
        //print("looking for visible cells")
        for tuple in getVisibleCells(tableView){
            //print("checking visible video on " + String(tuple.1.row))
            if(isVideoPlayerInsideCellVisible(tuple.0,indexPath:tuple.1,tableView:tableView)){
                //print("visible video on " + String(tuple.1.row))
                tuple.0.play()
            }
        }
    }

    func getAllCells(tableView:UITableView)->Array<(TimelineCell,NSIndexPath)>{
        var cells:Array<(TimelineCell,NSIndexPath)> = Array<(TimelineCell,NSIndexPath)>()

        for section in 0 ..< timeLine.numberOfSections {
            for row in 0 ..< timeLine.numberOfRowsInSection(section) {

                let indexPath = NSIndexPath(forRow: row, inSection: section)
                if let cell = tableView.cellForRowAtIndexPath(indexPath){
                    cells.append(cell as! TimelineCell,indexPath)
                }
            }
        }

        return cells
    }

    func getVisibleCells(tableView:UITableView)->Array<(TimelineCell,NSIndexPath)>{
        let indexPaths = tableView.indexPathsForVisibleRows
        
        var cells:Array<(TimelineCell,NSIndexPath)> = Array<(TimelineCell,NSIndexPath)>()
        
        if let _ = indexPaths {
            for indexPath in indexPaths!{
                if let cell: TimelineCell = getTimelineCellFromIndexPath(indexPath){
                    cells.append(cell,indexPath)
                }
            }
        }
        return cells
    }

    func getTimelineCellFromIndexPath(indexPath:NSIndexPath)->TimelineCell?{
        if let _ = timeLine.cellForRowAtIndexPath(indexPath) {
            if let cell: TimelineCell = timeLine.cellForRowAtIndexPath(indexPath) as? TimelineCell {
                return cell
            }
        }
        return nil
    }

    func getPreviousTimelineCellFromIndexPath(indexPath:NSIndexPath)->TimelineCell?{
        if((indexPath.row-1)>=0) {
            let newIndexPath: NSIndexPath = NSIndexPath(forRow: currentIndexPath!.row - 1, inSection: currentIndexPath!.section);

            return getTimelineCellFromIndexPath(newIndexPath)
        }
        return nil
    }

    func getNextTimelineCellFromIndexPath(indexPath:NSIndexPath)->TimelineCell?{
        if((indexPath.row+1)>=0) {
            let newIndexPath: NSIndexPath = NSIndexPath(forRow: currentIndexPath!.row + 1, inSection: currentIndexPath!.section);

            return getTimelineCellFromIndexPath(newIndexPath)
        }
        return nil
    }

    func isVideoPlayerInsideCellVisible(cell:TimelineCell,indexPath:NSIndexPath,tableView:UITableView)->Bool{


        let cellRect = tableView.rectForRowAtIndexPath(indexPath)

        var videoViewRect = cell.videoView.frame

        videoViewRect.origin.y = cellRect.origin.y + videoViewRect.origin.y

        return timeLine.bounds.contains(videoViewRect)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}