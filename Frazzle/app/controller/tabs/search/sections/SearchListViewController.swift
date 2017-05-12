//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import UIKit
import Toast_Swift
import Alamofire


class SearchListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate{//UITableViewDataSource, UITableViewDelegate,
    @IBOutlet var viewLoading: UIView!
    @IBOutlet var lblLoading: UILabel!
    @IBOutlet var indicatorLoading: UIActivityIndicatorView!

    @IBOutlet var postList: UITableView!

    private var manager:SearchManager!
    private var timelineTitle:String! = "POSTS"
    private var tabType:C.TabType = C.TabType.SEARCH
    private var items:Array<Post>!

    private var currentIndexPath:NSIndexPath?
    private var isViewLoaded:Bool=false

    func setSearchItems(items:Array<Post>){
        self.items = items
    }

    func setLoadingState(){
        if (isViewLoaded) {
            viewLoading.hidden = false
        }
    }

    func setEmptyState(){
        if (isViewLoaded) {
            viewLoading.hidden = false
            indicatorLoading.hidden = true
            lblLoading.text = "No items to display"
            postList.hidden = true
        }
    }

    func setBlankState(){
        if (isViewLoaded) {
            viewLoading.hidden = true
            postList.hidden = true
        }
    }

    func setContentState(){
        if (isViewLoaded) {
            viewLoading.hidden = true
            postList.hidden = false
        }
    }

    override func viewDidLoad() {

        currentIndexPath = NSIndexPath(forRow:0, inSection:0);
        super.viewDidLoad()

        isViewLoaded = true

        loadData()

        setupListeners()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        isViewLoaded = true

        Request.addAcceptableImageContentTypes(["binary/octet-stream"])
    }

    private func loadData(){

        manager = SearchManager()
        items = Array<Post>()

        self.setBlankState()

        postList.dataSource = self
        postList.delegate = self
    }

    private func setupListeners(){

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchListViewController.onPostsDownloadedNotification(_:)), name: C.SEARCH_POSTS_DOWNLOADED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchListViewController.onPostsNotDownloadedNotification(_:)), name: C.SEARCH_POSTS_NOT_DOWNLOADED, object: nil)


        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchListViewController.stopAllPlayers(_:)), name:C.TOP_TAB_CHANGED, object: nil)

    }

    @objc func onPostsDownloadedNotification(notification: NSNotification){
        items = manager.getPostsFromSearch()
        postList.reloadData()

        if(items.count==0){
            self.setEmptyState()
        }else{
            self.setContentState()
        }

    }

    @objc func onPostsNotDownloadedNotification(notification: NSNotification){
        if(items.count==0){
            viewLoading.hidden = false
            indicatorLoading.hidden = true
            lblLoading.text = "No items to display"
        }
    }

    @objc func stopAllPlayers(notification: NSNotification){
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        if let type = userInfo["TabType"] {
            if(tabType.rawValue != type){
                stopPlayer()
            }
        }

    }

    func tableView(tableView: UITableView, numberOfSectionsInTableView section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("TimelineCell", forIndexPath: indexPath)

        if let item = cell as? TimelineCell {

            let post:Post = items[indexPath.row] as Post
        
            item.setPost(post)

            if(indexPath.row==0){
                item.play()
            }
            //}else if let ad = timelineItem.adSpace {
                //set ad
            //}else{
                //do nothing ???
            //}
        }

        return cell
    }

    func stopPlayer() {
        if let indexPaths = postList.indexPathsForVisibleRows {
            for indexPath in indexPaths {
                currentIndexPath = indexPath

                if (items.count > 0) && (currentIndexPath!.section >= 0) && (currentIndexPath!.row >= 0) {
                    stopPlayerBasedOnIndexPath(currentIndexPath!);

                    if ((currentIndexPath!.row + 1) <= items.count) {
                        let newIndexPath: NSIndexPath = NSIndexPath(forRow: currentIndexPath!.row + 1, inSection: currentIndexPath!.section);

                        stopPlayerBasedOnIndexPath(newIndexPath);
                    }

                    if ((currentIndexPath!.row - 1) >= 0) {
                        let newIndexPath: NSIndexPath = NSIndexPath(forRow: currentIndexPath!.row - 1, inSection: currentIndexPath!.section);

                        stopPlayerBasedOnIndexPath(newIndexPath);
                    }
                }
            }
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let indexPaths = postList.indexPathsForVisibleRows{
            
            
            //If we reach the end of the table.
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
                //Add  more rows and reload the table content.
                
            }else{
                for indexPath in indexPaths{
                    currentIndexPath = indexPath
                    
                    if(items.count > 0)&&(currentIndexPath!.section >= 0)&&(currentIndexPath!.row >= 0){
                        changePlayerStatusBasedOnIndexPath(currentIndexPath!);
                        
                        if((currentIndexPath!.row + 1)<=items.count){
                            let newIndexPath:NSIndexPath = NSIndexPath(forRow:currentIndexPath!.row+1, inSection:currentIndexPath!.section);
                            
                            changePlayerStatusBasedOnIndexPath(newIndexPath);
                        }
                        
                        if((currentIndexPath!.row-1)>=0){
                            let newIndexPath:NSIndexPath = NSIndexPath(forRow:currentIndexPath!.row-1, inSection:currentIndexPath!.section);
                            
                            changePlayerStatusBasedOnIndexPath(newIndexPath);
                        }
                    }
                }
            }
        }
    }

    func changePlayerStatusBasedOnIndexPath(indexPath:NSIndexPath){

        if let _ = postList.cellForRowAtIndexPath(indexPath) {
            let cellRect = postList.rectForRowAtIndexPath(indexPath)

            if let cell: TimelineCell = postList.cellForRowAtIndexPath(indexPath) as! TimelineCell {
                var videoViewRect = cell.videoView.frame

                videoViewRect.origin.y = cellRect.origin.y + videoViewRect.origin.y

                let completelyVisible = postList.bounds.contains(videoViewRect)
                if (completelyVisible) {
                    cell.play();
                }else{
                    cell.pause();
                }
            }
        }
    }

    func stopPlayerBasedOnIndexPath(indexPath:NSIndexPath){
        if let _ = postList.cellForRowAtIndexPath(indexPath) {
            if let cell: TimelineCell = (postList.cellForRowAtIndexPath(indexPath) as! TimelineCell) {
                cell.pause();
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}