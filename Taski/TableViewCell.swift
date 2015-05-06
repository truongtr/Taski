//
//  TableViewCell.swift
//  Taski
//
//  Created by Truc Truong on 27/04/15.
//  Copyright (c) 2015 Truc Truong. All rights reserved.
//

import UIKit
import QuartzCore
import AVFoundation

// A protocol that the TableViewCell uses to inform its delegate of state change
protocol TableViewCellDelegate {
    // indicates that the given item has been deleted
    func toDoItemDeleted(todoItem: ToDoItem)
    
    // indicates that the given item has been remark undone
    func toDoItemUndone(todoItem: ToDoItem)
    
    // indicates that the given item has been markeddone
    func toDoItemDone(todoItem: ToDoItem)
    // Should begin edititing
    func cellShouldBeginEditing(editingCell: TableViewCell)
    
    // Indicates that the edit process has begun for the given cell
    func cellDidBeginEditing(editingCell: TableViewCell)
    // Indicates that the edit process has committed for the given cell
    func cellDidEndEditing(editingCell: TableViewCell)
}


class TableViewCell: UITableViewCell,UITextFieldDelegate {
    
    let gradientLayer = CAGradientLayer()
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false, completeOnDragRelease = false
    let label: StrikeThroughText
    var itemCompleteLayer = CALayer()
    var tickLabel: UILabel, crossLabel: UILabel
    
    var bamboo = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("bambooTap", ofType: "wav")!)
    
    var audioPlayer = AVAudioPlayer()
    
    
    // The object that acts as delegate for this cell.
    var delegate: TableViewCellDelegate?
    // The item that this cell renders.
    var toDoItem: ToDoItem? {
        didSet {
            label.text = toDoItem!.text.capitalizedString
            label.strikeThrough = toDoItem!.completed
            itemCompleteLayer.hidden = !label.strikeThrough
        }
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        // create a label that renders the to-do item text
        label = StrikeThroughText(frame: CGRect.nullRect)
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(19)
        label.backgroundColor = UIColor.clearColor()
        
        // utility method for creating the contextual cues
        func createCueLabel() -> UILabel {
            let label = UILabel(frame: CGRect.nullRect)
            label.textColor = UIColor.whiteColor()
            label.font = UIFont.boldSystemFontOfSize(32.0)
            label.backgroundColor = UIColor.clearColor()
            return label
        }
        
        // tick and cross labels for context cues
        tickLabel = createCueLabel()
        tickLabel.text = "\u{2713}"
        tickLabel.textAlignment = .Right
        crossLabel = createCueLabel()
        crossLabel.text = "\u{2717}"
        crossLabel.textAlignment = .Left
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        label.delegate = self
        label.contentVerticalAlignment = .Center
        
        
        addSubview(label)
        addSubview(tickLabel)
        addSubview(crossLabel)
        
        
        // gradient layer for cell
        gradientLayer.frame = bounds
        let color1 = UIColor(white: 1.0, alpha: 0.3).CGColor as CGColorRef
        let color2 = UIColor(white: 1.0, alpha: 0.2).CGColor as CGColorRef
        //let color3 = UIColor.clearColor().CGColor as CGColorRef
        let color3 = UIColor(white: 1.0, alpha: 0.1).CGColor as CGColorRef
        let color4 = UIColor(white: 0.0, alpha: 0.45).CGColor as CGColorRef
        gradientLayer.colors = [color4, color3, color2, color1]
        gradientLayer.locations = [0.001, 0.0, 0.95, 1.0]
        layer.insertSublayer(gradientLayer, atIndex: 0)
        
        var recognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
        
        var singleTap = UITapGestureRecognizer(target: self, action: "resignOnTap:")
        singleTap.delegate = self
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        addGestureRecognizer(singleTap)
        
        
        
        
        
        
        addSubview(label)
        // remove the default blue highlight for selected cells
        selectionStyle = .None
        // tick and cross labels for context cues
        tickLabel = createCueLabel()
        tickLabel.text = "\u{2713}"
        tickLabel.textAlignment = .Right
        addSubview(tickLabel)
        crossLabel = createCueLabel()
        crossLabel.text = "\u{2717}"
        crossLabel.textAlignment = .Left
        addSubview(crossLabel)
        // add a layer that renders a green background when an item is complete
        itemCompleteLayer = CALayer(layer: layer)
        /*itemCompleteLayer.backgroundColor = UIColor(red: 0.0, green: 0.6, blue: 0.0,
        alpha: 1.0).CGColor*/
        itemCompleteLayer.backgroundColor = UIColor.grayColor().CGColor
        itemCompleteLayer.hidden = true
        layer.insertSublayer(itemCompleteLayer, atIndex: 0)
        
        audioPlayer = AVAudioPlayer(contentsOfURL: bamboo, error: nil)
        audioPlayer.prepareToPlay()

        
    }
    
    let kLabelLeftMargin: CGFloat = 15.0
    let kUICuesMargin: CGFloat = 10.0, kUICuesWidth: CGFloat = 50.0
    override func layoutSubviews() {
        super.layoutSubviews()
        // ensure the gradient layer occupies the full bounds
        gradientLayer.frame = bounds
        itemCompleteLayer.frame = bounds
        label.frame = CGRect(x: kLabelLeftMargin, y: 0,
            width: bounds.size.width - kLabelLeftMargin,
            height: bounds.size.height)
        tickLabel.frame = CGRect(x: -kUICuesWidth - kUICuesMargin, y: 0,
            width: kUICuesWidth, height: bounds.size.height)
        crossLabel.frame = CGRect(x: bounds.size.width + kUICuesMargin, y: 0,
            width: kUICuesWidth, height: bounds.size.height)
    }
    
    
    
    
    //MARK: - horizontal pan gesture methods
    
    var playSoundOnce = true;
     var deleteSoundOnce = true;
    func handlePan(recognizer: UIPanGestureRecognizer) {
        // 1
        if recognizer.state == .Began {
            // when the gesture begins, record the current center location
            originalCenter = center
        }
        // 2
        if recognizer.state == .Changed {
            let translation = recognizer.translationInView(self)
            center = CGPointMake(originalCenter.x + translation.x, originalCenter.y)
            // fade the contextual clues
            let cueAlpha = fabs(frame.origin.x) / (frame.size.width / 2.0)
            tickLabel.alpha = cueAlpha
            crossLabel.alpha = cueAlpha
            
            
            
            // has the user dragged the item far enough to initiate a delete/complete?
            deleteOnDragRelease = frame.origin.x < -frame.size.width / 3
            completeOnDragRelease = frame.origin.x > frame.size.width / 3
            if(completeOnDragRelease){
                crossLabel.textColor = UIColor.redColor()
                if(toDoItem?.completed == false){
                    label.strikeThrough = true
                    itemCompleteLayer.hidden = false
                    tickLabel.textColor =  UIColor.greenColor()
                    if(playSoundOnce){
                        audioPlayer.play()
                        playSoundOnce = false
                    }
                    
                    // toDoItem!.completed = true
                    // crossLabel.textColor = UIColor.whiteColor()
                }else{
                    // toDoItem!.completed = false
                    
                    label.strikeThrough = false
                    itemCompleteLayer.hidden = true
                    
                    //tickLabel.textColor =  UIColor.whiteColor()
                    
                    
                }
                
            }else{
                crossLabel.textColor = UIColor.whiteColor()
                tickLabel.textColor =  UIColor.whiteColor()
                 playSoundOnce = true
                if(toDoItem?.completed == false){
                    label.strikeThrough = false
                    itemCompleteLayer.hidden = true
                    // tickLabel.textColor =  UIColor.whiteColor()
                }else{
                    label.strikeThrough = true
                    itemCompleteLayer.hidden = false
                    //tickLabel.textColor =  UIColor.whiteColor()
                }
                
            }
            if( deleteOnDragRelease){
                crossLabel.textColor =  UIColor.redColor()
                if(deleteSoundOnce){
                    audioPlayer.play()
                    deleteSoundOnce = false
                }
            }else{
                 deleteSoundOnce = true
            }
            
            // indicate when the user has pulled the item far enough to invoke the given action
            
            //crossLabel.textColor = deleteOnDragRelease ? UIColor.redColor() : UIColor.whiteColor()
        }
        // 3
        if recognizer.state == .Ended {
            // the frame this cell had before user dragged it
            let originalFrame = CGRect(x: 0, y: frame.origin.y,
                width: bounds.size.width, height: bounds.size.height)
            if !deleteOnDragRelease {
                // if the item is not being deleted, snap back to the original location
                UIView.animateWithDuration(0.1, animations: {self.frame = originalFrame})
            }
            if deleteOnDragRelease {
                if delegate != nil && toDoItem != nil {
                    // notify the delegate that this item should be deleted
                    delegate!.toDoItemDeleted(toDoItem!)
                }
            } else if completeOnDragRelease {
                if toDoItem != nil {
                    
                    if(toDoItem?.completed == true){
                        toDoItem!.completed = false
                        label.strikeThrough = false
                        itemCompleteLayer.hidden = true
                        
                        delegate!.toDoItemUndone(toDoItem!)
                    }else{
                        toDoItem!.completed = true
                        label.strikeThrough = true
                        itemCompleteLayer.hidden = false
                        delegate!.toDoItemDone(toDoItem!)
                        
                    }
                }
                
                
                UIView.animateWithDuration(0.1, animations: {self.frame = originalFrame})
            } else {
                UIView.animateWithDuration(0.1, animations: {self.frame = originalFrame})
            }
        }
        
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translationInView(superview!)
            
            // let translation2 = gestureRecognizer.translationInView(self!)
            
            //println(fabs(translation2.x))
            if(fabs(translation.x)>10){
                return false
            }
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
    
    
    // MARK: - UITextFieldDelegate methods
    var shouldResignFirstResponser = Bool()
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // close the keyboard on Enter
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        delegate!.cellShouldBeginEditing(self)
        // disable editing of completed to-do items
        textField.keyboardAppearance = UIKeyboardAppearance.Dark
        //textField.keyboardAppearance = UI
        //textField.keyboardType = UIKeyboardAppearance.Dark
        if toDoItem != nil {
            return !toDoItem!.completed
        }
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if delegate != nil {
            delegate!.cellDidEndEditing(self)
        }
        if toDoItem != nil {
            if textField.text == "" {
                delegate!.toDoItemDeleted(toDoItem!)
            } else {
                toDoItem!.text = textField.text
            }
        }
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        //textField.resignFirstResponder()
        
        if delegate != nil {
            delegate!.cellDidBeginEditing(self)
        }
    }
    
    
}
