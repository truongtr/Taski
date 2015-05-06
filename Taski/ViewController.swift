//
//  ViewController.swift
//  Taski
//
//  Created by Truc Truong on 27/04/15.
//  Copyright (c) 2015 Truc Truong. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: LPRTableViewController, UITableViewDataSource, UITableViewDelegate,TableViewCellDelegate{
    
   
    
    // make sure to add this sound to your project
    var clickSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("tom2", ofType: "wav")!)
    var releaseSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("tap1", ofType: "wav")!)
    var doneSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("swosh", ofType: "wav")!)
    
    var audioPlayer = AVAudioPlayer()
    var releasePlayer = AVAudioPlayer()
    var donePlayer = AVAudioPlayer()
    
    var toDoItems = [ToDoItem]()
    let pinchRecognizer = UIPinchGestureRecognizer()
    var shouldExitKeyboard = Bool()
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, error: nil)
        audioPlayer = AVAudioPlayer(contentsOfURL: clickSound, error: nil)
        audioPlayer.prepareToPlay()
        releasePlayer = AVAudioPlayer(contentsOfURL: releaseSound, error: nil)
        releasePlayer.prepareToPlay()
        donePlayer = AVAudioPlayer(contentsOfURL: doneSound, error: nil)
        donePlayer.prepareToPlay()

        /*UINavigationBar.appearance().titleTextAttributes = [
        NSForegroundColorAttributeName: UIColor.whiteColor()
        ]*/
        
        //UINavigationBar.appearance().barTintColor = UIColor.blueColor()
         self.navigationController!.navigationBar.alpha = 0.1
         self.navigationController?.navigationBar.translucent = true
        //view.backgroundColor = UIColor.redColor()
        //self.tableView.contentInset = UIEdgeInsetsMake(44,0,0,0);
        //self.tableView.setC
        //self.navigationBar.translucent = true
        
        shouldExitKeyboard = true
        self.tableView.backgroundColor = UIColor.grayColor()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerClass(TableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.separatorStyle = .None
        tableView.rowHeight = 60.0
        self.tableView.showsVerticalScrollIndicator = false
        
        
        
        pinchRecognizer.addTarget(self, action: "handlePinch:")
        
        
        tableView.addGestureRecognizer(pinchRecognizer)
        
        if toDoItems.count > 0 {
            return
        }
        
        
        
        toDoItems.append(ToDoItem(text: "buy eggs"))
        toDoItems.append(ToDoItem(text: "watch WWDC videos"))
        toDoItems.append(ToDoItem(text: "rule the Web"))
        toDoItems.append(ToDoItem(text: "buy a new iPhone"))
        toDoItems.append(ToDoItem(text: "darn holes in socks"))
        toDoItems.append(ToDoItem(text: "master Swift"))
        toDoItems.append(ToDoItem(text: "learn to draw"))
        
        //Looks for single or multiple taps.
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
    /*
    
    override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    var rect:CGRect = self.navigationController!.navigationBar.frame;
    // var y:CGFloat = rect.origin.y-rect.size.height  ;
    self.tableView.contentInset = UIEdgeInsetsMake(44 ,0,0,0);
    }*/
    
    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TableViewCell
        let item = toDoItems[indexPath.row]
        // cell.textLabel?.text = item.text
        // cell.textLabel?.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.selectionStyle = .None
        cell.delegate = self
        //cell.delegate = self
        cell.toDoItem = item
        return cell
    }
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = colorForIndex(indexPath.row)
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
    }
    
    
    // MARK: - Cell Editting
  
    var previousCell = TableViewCell()
    func cellShouldBeginEditing(editingCell: TableViewCell){
        editingCell.becomeFirstResponder()
      //  var editingOffset = self.tableView.contentOffset.y  - editingCell.frame.origin.y as CGFloat
        let visibleCells = self.tableView.visibleCells() as! [TableViewCell]
       // tableView.userInteractionEnabled = false
        /*
        for cell in visibleCells {
            if cell !== editingCell {
                cell.alpha = 0.3
                cell.userInteractionEnabled = false
                
            }
            
        }*/
    }
        
    func cellDidBeginEditing(editingCell: TableViewCell) {
        pullDownInProgress = true
        audioPlayer.play()
        tableView.scrollEnabled = false
        // if(shouldExitKeyboard){
        
        //var editingOffset = tableView.contentOffset.y - editingCell.frame.origin.y as CGFloat
        var editingOffset = tableView.contentOffset.y  - editingCell.frame.origin.y as CGFloat
        
        let visibleCells = tableView.visibleCells() as! [TableViewCell]
        for cell in visibleCells {
            if cell !== editingCell {
                cell.alpha = 0.3
                cell.userInteractionEnabled = false
                
            }
            /*
            UIView.animateWithDuration(0, animations: {() in
                cell.transform = CGAffineTransformMakeTranslation(0, editingOffset)
                if cell !== editingCell {
                    cell.alpha = 0.3
                    cell.userInteractionEnabled = false
                    
                }
            })*/
        }

        
        previousCell = editingCell
        shouldExitKeyboard = false
        /*  }else{
        let visibleCells = tableView.visibleCells() as! [TableViewCell]
        editingCell.textFieldShouldReturn(editingCell.label)
        for cell in visibleCells {
        cell.textFieldShouldReturn(cell.label)
        if (cell === previousCell) {
        // editCell = cell
        cell.textFieldShouldReturn(cell.label)
        break
        }
        }
        
        DismissKeyboard()
        shouldExitKeyboard = true
        }*/
        
        
    }

    func tap(){
        
        self.view.endEditing(true)
    }
    
    func cellDidEndEditing(editingCell: TableViewCell) {
        //shouldExitKeyboard = true
        let visibleCells = tableView.visibleCells() as! [TableViewCell]
        for cell: TableViewCell in visibleCells {
            UIView.animateWithDuration(0.3, animations: {() in
                cell.transform = CGAffineTransformIdentity
                if cell !== editingCell {
                    cell.alpha = 1.0
                    cell.userInteractionEnabled = true
                }
            })
        }
        pullDownInProgress = false
        shouldNotAddMore = true
        tableView.scrollEnabled = true;
        tableView.bounces = true
    }
    
    func toDoItemDeleted(toDoItem: ToDoItem) {
        let index = (toDoItems as NSArray).indexOfObject(toDoItem)
        if index == NSNotFound { return }
        
        // could removeAtIndex in the loop but keep it here for when indexOfObject works
        toDoItems.removeAtIndex(index)
        
        // loop over the visible cells to animate delete
        let visibleCells = tableView.visibleCells() as! [TableViewCell]
        let lastView = visibleCells[visibleCells.count - 1] as TableViewCell
        var delay = 0.0
        var startAnimating = false
        for i in 0..<visibleCells.count {
            let cell = visibleCells[i]
          
            if startAnimating {
                UIView.animateWithDuration(0.2, delay: delay, options: UIViewAnimationOptions.CurveEaseInOut,
                    animations: {() in
                        cell.frame = CGRectOffset(cell.frame, 0.0,
                            -cell.frame.size.height)},
                    completion: {(finished: Bool) in
                        if (cell == lastView) {
                            self.tableView.reloadData()
                        }
                    }
                )
                delay += 0.00
            }
            if cell.toDoItem === toDoItem {
                startAnimating = true
                cell.hidden = true
            }
        }
        
        // use the UITableView to animate the removal of this row
        
        tableView.beginUpdates()
        let indexPathForRow = NSIndexPath(forRow: index, inSection: 0)
        tableView.deleteRowsAtIndexPaths([indexPathForRow], withRowAnimation: .Right)
        tableView.endUpdates()
        
    }
    func toDoItemDone(toDoItem: ToDoItem) {
        donePlayer.play()
        let index = (toDoItems as NSArray).indexOfObject(toDoItem)
        if index == NSNotFound { return }
        // could removeAtIndex in the loop but keep it here for when indexOfObject works
        toDoItems[index].completed = true
        
        toDoItems.sort({ $0.completed != true && $1.completed == true  })
        tableView.reloadData()
        /*
        let toDoItem = ToDoItem(text: toDoItem.text)
        toDoItem.completed = true
        toDoItems.append(toDoItem)*/
        
    }
    func toDoItemUndone(toDoItem: ToDoItem) {
        donePlayer.play()
        let index = (toDoItems as NSArray).indexOfObject(toDoItem)
        if index == NSNotFound { return }
        // could removeAtIndex in the loop but keep it here for when indexOfObject works
        toDoItems[index].completed = false
        
        toDoItems.sort({ $0.completed != true && $1.completed == true  })
        tableView.reloadData()
    }
    
    func colorForIndex(Index:Int)->UIColor{
        let itemCount = 1 + toDoItems.count
        let val = (CGFloat(Index)/CGFloat(itemCount)) * 0.5
        return UIColor(red: 1.0, green: val, blue: 0.15, alpha: 1.0)
    }
    
    // MARK: - Table view data source
    // contains numberOfSectionsInTableView, numberOfRowsInSection, cellForRowAtIndexPath
    
    // MARK: - TableViewCellDelegate methods
    // contains toDoItemDeleted, cellDidBeginEditing, cellDidEndEditing
    
    // MARK: - UIScrollViewDelegate methods
    // contains scrollViewDidScroll, and other methods, to keep track of dragging the scrollView
    
    // a cell that is rendered as a placeholder to indicate where a new item is added
    let placeHolderCell = TableViewCell(style: .Default, reuseIdentifier: "cell")
   // let placeHolderCell2 = TableViewCell(style: .Default, reuseIdentifier: "cell2")
    // indicates the state of this behavior
    var pullDownInProgress = false
    var pullUpInProgress = false

    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        // this behavior starts when a user pulls down while at the top of the table
        pullDownInProgress = scrollView.contentOffset.y <= 0.0
        placeHolderCell.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.15, alpha: 1.0)
        //placeHolderCell2.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.15, alpha: 1.0)
        
        if pullDownInProgress {
            // add the placeholder
            tableView.insertSubview(placeHolderCell, atIndex: 0)
        }
        
        
        pullUpInProgress = 0-scrollView.contentOffset.y > 0.0
       
        
        if pullUpInProgress {
            // add the placeholder
            tableView.insertSubview(placeHolderCell, atIndex: (toDoItems.count-1))
            
        }

        
        
    }
    
    var shouldNotAddMore = true
    var releasePlayOnce = true
    var releasePlayAgain = false
    var releaseBottomOnce = true
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        // Pull down
        var scrollViewContentOffsetY = scrollView.contentOffset.y + 60
        
        if(scrollView.contentOffset.y <= -120){
            if(-scrollViewContentOffsetY > tableView.rowHeight && releasePlayOnce && !releasePlayAgain && pullDownInProgress){
                releasePlayer.play()
                releasePlayOnce = false
                releasePlayAgain = true
            }
        }else{
            
           if(releasePlayAgain){
                releasePlayOnce = true
                releasePlayAgain = false
                println(scrollView.contentOffset.y)
            }

        }
        
       
        if(scrollView.contentOffset.y <= 0){
            if pullDownInProgress && scrollView.contentOffset.y <= 0.0 && shouldNotAddMore{
               // self.tableView.scrollEnabled = true
                if(-scrollViewContentOffsetY>tableView.rowHeight){
                   // scrollView setContentOffset:CGPointMake(0, 0) animated:YES
                    scrollView.setContentOffset(CGPointMake(0, -125), animated: false)
                }
                
                // maintain the location of the placeholder
                placeHolderCell.frame = CGRect(x: 0, y:-tableView.rowHeight ,
                    width: tableView.frame.size.width, height: tableView.rowHeight)
                
                
                placeHolderCell.label.text = -scrollViewContentOffsetY > tableView.rowHeight ?
                    "Release to add item" : "Pull to add item"
                
                
                placeHolderCell.alpha = min(1.0, -scrollViewContentOffsetY / tableView.rowHeight)
            } else {
                pullDownInProgress = false
                // releasePlayOnce = true
                
                
            }
        }else{
            // Pull up
            var scrollViewContentOffsetY2 = 0 - scrollView.contentOffset.y - 60
            // println(scrollViewContentOffsetY2)
            if(scrollView.contentOffset.y > 30.0){
                if pullUpInProgress && scrollView.contentOffset.y > 30.0 && shouldNotAddMore{
                    
                    
                    placeHolderCell.frame = CGRect(x: 0, y:scrollView.contentSize.height ,
                        width: tableView.frame.size.width, height: tableView.rowHeight)
                    
                    
                    
                    placeHolderCell.label.text = scrollViewContentOffsetY > 150 ?
                        "Release to delete" : "Pull to delete done items"
                    
                    placeHolderCell.alpha = min(1.0, scrollViewContentOffsetY*5 / tableView.frame.size.height)
                    
                    if( scrollViewContentOffsetY > 150 && releaseBottomOnce){
                        releasePlayer.play()
                        releaseBottomOnce = false
                        println(scrollViewContentOffsetY)
                    }else{
                       
                    }
                    
                }else{
                    pullUpInProgress = false
                    
                    
                }
            }else{
                 releaseBottomOnce = true
            }
            

        }
        
        
        
    }
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // check whether the user pulled down far enough
       placeHolderCell.removeFromSuperview()
        
        if pullDownInProgress && -scrollView.contentOffset.y-60 > tableView.rowHeight {
            //placeHolderCell.removeFromSuperview()
            audioPlayer.play()
            toDoItemAdded()
            releasePlayOnce = false
            releasePlayAgain = true
           
           // placeHolderCell.removeFromSuperview()
        }
         var scrollViewContentOffsetY2 = 0 - scrollView.contentOffset.y - 60
   

        if pullUpInProgress && -scrollViewContentOffsetY2 > 150{
            // placeHolderCell.removeFromSuperview()
            var newArray = [ToDoItem]()
            for (index, element) in enumerate(toDoItems){
                if(element.completed != true){
                   
                    newArray.append(element)
                }
            }
            toDoItems = newArray
            tableView.reloadData()
            
        }
        scrollView.bounces = true
        
    }

    func toDoItemAdded() {
        toDoItemAddedAtIndex(0)
    }
    
    func toDoItemAddedAtIndex(index: Int) {
        let toDoItem = ToDoItem(text: "")
        toDoItems.insert(toDoItem, atIndex: index)
        tableView.reloadData()
        
        // enter edit mode
        var editCell: TableViewCell
        let visibleCells = tableView.visibleCells() as! [TableViewCell]
        for cell in visibleCells {
            if (cell.toDoItem === toDoItem) {
                editCell = cell
                editCell.label.becomeFirstResponder()
                shouldNotAddMore = false
                releasePlayOnce = true
                releasePlayAgain = false
                break
            }
        }
        
    }
    
    
    // MARK: - pinch-to-add methods
    
    // indicates that the pinch is in progress
    struct TouchPoints {
        var upper: CGPoint
        var lower: CGPoint
    }
    // the indices of the upper and lower cells that are being pinched
    var upperCellIndex = -100
    var lowerCellIndex = -100
    // the location of the touch points when the pinch began
    var initialTouchPoints: TouchPoints!
    // indicates that the pinch was big enough to cause a new item to be added
    var pinchExceededRequiredDistance = false
    // returns the two touch points, ordering them to ensure that
    // upper and lower are correctly identified.
    func getNormalizedTouchPoints(recognizer: UIGestureRecognizer) -> TouchPoints {
        var pointOne = recognizer.locationOfTouch(0, inView: tableView)
        var pointTwo = recognizer.locationOfTouch(1, inView: tableView)
        // ensure pointOne is the top-most
        if pointOne.y > pointTwo.y {
            let temp = pointOne
            pointOne = pointTwo
            pointTwo = temp
        }
        return TouchPoints(upper: pointOne, lower: pointTwo)
    }
    
    func viewContainsPoint(view: UIView, point: CGPoint) -> Bool {
        let frame = view.frame
        return (frame.origin.y < point.y) && (frame.origin.y + (frame.size.height) > point.y)
    }
    var pinchInProgress = false
    
    func handlePinch(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .Began {
            pinchStarted(recognizer)
        }
        if recognizer.state == .Changed && pinchInProgress && recognizer.numberOfTouches() == 2 {
            pinchChanged(recognizer)
        }
        if recognizer.state == .Ended {
            pinchEnded(recognizer)
        }
        
    }
    
    func pinchStarted(recognizer: UIPinchGestureRecognizer) {
        // find the touch-points
        initialTouchPoints = getNormalizedTouchPoints(recognizer)
        
        // locate the cells that these points touch
        upperCellIndex = -100
        lowerCellIndex = -100
        let visibleCells = tableView.visibleCells()  as! [TableViewCell]
        for i in 0..<visibleCells.count {
            let cell = visibleCells[i]
            if viewContainsPoint(cell, point: initialTouchPoints.upper) {
                upperCellIndex = i
                // highlight the cell – just for debugging!
                cell.backgroundColor = UIColor.purpleColor()
            }
            if viewContainsPoint(cell, point: initialTouchPoints.lower) {
                lowerCellIndex = i
                // highlight the cell – just for debugging!
                cell.backgroundColor = UIColor.purpleColor()
            }
        }
        // check whether they are neighbors
        if abs(upperCellIndex - lowerCellIndex) == 1 {
            // initiate the pinch
            pinchInProgress = true
            // show placeholder cell
            let precedingCell = visibleCells[upperCellIndex]
            placeHolderCell.frame = CGRectOffset(precedingCell.frame, 0.0, tableView.rowHeight / 2.0)
            placeHolderCell.backgroundColor = UIColor.redColor()
            placeHolderCell.backgroundColor = precedingCell.backgroundColor
            tableView.insertSubview(placeHolderCell, atIndex: 0)
            
        }
        
    }
    
    func pinchChanged(recognizer: UIPinchGestureRecognizer) {
        // find the touch points
        let currentTouchPoints = getNormalizedTouchPoints(recognizer)
        
        // determine by how much each touch point has changed, and take the minimum delta
        let upperDelta = currentTouchPoints.upper.y - initialTouchPoints.upper.y
        let lowerDelta = initialTouchPoints.lower.y - currentTouchPoints.lower.y
        let delta = -min(0, min(upperDelta, lowerDelta))
        
        // offset the cells, negative for the cells above, positive for those below
        let visibleCells = tableView.visibleCells() as! [TableViewCell]
        for i in 0..<visibleCells.count {
            let cell = visibleCells[i]
            if i <= upperCellIndex {
                cell.transform = CGAffineTransformMakeTranslation(0, -delta)
            }
            if i >= lowerCellIndex {
                cell.transform = CGAffineTransformMakeTranslation(0, delta)
            }
        }
        // scale the placeholder cell
        let gapSize = delta * 2
        let cappedGapSize = min(gapSize, tableView.rowHeight)
        placeHolderCell.transform = CGAffineTransformMakeScale(1.0, cappedGapSize / tableView.rowHeight)
        placeHolderCell.label.text = gapSize > tableView.rowHeight ? "Release to add item" : "Pull apart to add item"
        placeHolderCell.alpha = min(1.0, gapSize / tableView.rowHeight)
        
        // has the user pinched far enough?
        pinchExceededRequiredDistance = gapSize > tableView.rowHeight
        
    }
    
    func pinchEnded(recognizer: UIPinchGestureRecognizer) {
        pinchInProgress = false
        
        // remove the placeholder cell
        placeHolderCell.transform = CGAffineTransformIdentity
        placeHolderCell.removeFromSuperview()
        
        if pinchExceededRequiredDistance {
            pinchExceededRequiredDistance = false
            
            // Set all the cells back to the transform identity
            let visibleCells = self.tableView.visibleCells() as! [TableViewCell]
            for cell in visibleCells {
                cell.transform = CGAffineTransformIdentity
            }
            
            // add a new item
            let indexOffset = Int(floor(tableView.contentOffset.y / tableView.rowHeight))
            toDoItemAddedAtIndex(lowerCellIndex + indexOffset)
        } else {
            // otherwise, animate back to position
            UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseInOut, animations: {() in
                let visibleCells = self.tableView.visibleCells() as! [TableViewCell]
                for cell in visibleCells {
                    cell.transform = CGAffineTransformIdentity
                }
                }, completion: nil)
        }
    }
    
    // MARK: - TableViewDelegate methods
    // contains willDisplayCell and your helper method colorForIndex
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    

    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    // MARK: - Long Press Reorder
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Change this logic to match your needs.
        return (indexPath.section == 0)
    }
    //
    // Important: Update your data source after the user reorders a cell.
    //
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        println("triggered")
        toDoItems.insert(toDoItems.removeAtIndex(sourceIndexPath.row), atIndex: destinationIndexPath.row)
        //objects.insert(objects.removeAtIndex(sourceIndexPath.row), atIndex: destinationIndexPath.row)
    }
    
    //
    // Optional: Modify the cell (visually) before dragging occurs.
    //
    //    NOTE: Any changes made here should be reverted in `tableView:cellForRowAtIndexPath:`
    //          to avoid accidentally reusing the modifications.
    //
    override func tableView(tableView: UITableView, draggingCell cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //		cell.backgroundColor = UIColor(red: 165.0/255.0, green: 228.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        return cell
    }
    
    //
    // Optional: Called within an animation block when the dragging view is about to show.
    //
    override func tableView(tableView: UITableView, showDraggingView view: UIView, atIndexPath indexPath: NSIndexPath) {
        println("The dragged cell is about to be animated!")
    }
    
    //
    // Optional: Called within an animation block when the dragging view is about to hide.
    //
    override func tableView(tableView: UITableView, hideDraggingView view: UIView, atIndexPath indexPath: NSIndexPath) {
        println("The dragged cell is about to be dropped.")
    }
    
    
  

}

