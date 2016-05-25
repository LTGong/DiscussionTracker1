//
//  BarGraphViewController.swift
//  DiscussionTracker1
//
//  Created by Liam Gong on 5/16/16.
//  Copyright © 2016 Liam Gong. All rights reserved.
//

import Foundation
import UIKit

//Model:
class contBarGraph{
    let contributions: Array<Contribution>
    init(withContributions conts: Array<Contribution>){
        self.contributions = conts;
    }
    // so this is an initialization inside of a computed property. I suspect that I'm kind of making a performance mistake here, but would need to look up the implementation to be sure.
    var cols:colList {
        var contribDict = [Contributor: Array<Contribution>]()
        for contrib in contributions{
            if (contribDict[contrib.contributor] != nil){
                contribDict[contrib.contributor]!.append(contrib)
            }else{
                contribDict[contrib.contributor] = [contrib]
            }
        }
        var columnList = Array<barColumn>()
        for contrib in contribDict.keys{
            var segArr = Array<barSegment>()
            for cont in contribDict[contrib]!{
                segArr.append(barSegment(duration:Double(cont.duration)))
            }
            let col = barColumn(name: contrib.initials, color: contrib.color, segments: segArr)
            columnList.append(col)
        }
        return colList(columns: columnList)
    }
}

//List of columns
struct colList{
    let columns: Array<barColumn>
    var count:Int{
        return self.columns.count
    }
    var maxVal:Double{
        var max = 0.0
        for col in columns{
            let dur = col.duration
            if dur > max{
                max = dur
            }
        }
        return max
    }
}


// single column, made up of segments that display length of inividual comment.
struct barColumn {
    let name:String
    let color:UIColor
    let segments:Array<barSegment>
    var duration:Double {
        var dur = 0.0
        for segment in segments{
            dur += segment.duration
        }
        return dur
    }
}

// individual comment's segment, encapsulated because I might want to extend amount of data attached to individual comments.
struct barSegment {
    let duration:Double // in seconds.
}


// View Controller

class BarGraphViewController:UIViewController{
    //iVars:
    var barModel = contBarGraph(withContributions:Array<Contribution>())//refactor for viewController initializers
    
    @IBOutlet weak var displayText: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.displayData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //self.displayData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayData(){
        if self.barModel.contributions.count != 0{
            self.displayText.text! = ""
            _ = self.generateButtons()// refactor return value
            /*for but in buttonArr{
                self.view!.addSubview(but)
            }*/
        }else{
            self.displayText.text! = "Please track a discussion to see the duration bar chart."
        }
        
    }
    
    
    func generateButtons()->Array <UIButton>{
        let maxHeight = Double(self.view.frame.height) * 0.8
        let spaceWidth =  Double(self.view.frame.width) / Double(self.barModel.cols.count)
        let width = 0.8*spaceWidth// TK magic #!
        //var butArr = Array<UIButton>()
        //there was some bug here having to do with iteration.
        let whatTheHell = self.barModel.cols
        let whatTheHellList = whatTheHell.columns
        for ind in 0 ..< whatTheHellList.count{
            let col = self.barModel.cols.columns[ind]
            let xOrigin = Double(ind) * Double(self.view.frame.width) / Double(self.barModel.cols.count) + (spaceWidth - width)/2.0
            var yOrigin = Double(self.view.frame.height)//start from the bottom of the screen
            for (ind, segment) in col.segments.enumerate(){
                let height = (maxHeight * segment.duration)/self.barModel.cols.maxVal
                yOrigin -= height
                let butRect = CGRect(x: xOrigin , y: yOrigin, width: width, height: height)
                let button = UIButton(frame: butRect)
                //button.layer.borderWidth = 1 // to differentiate
                if ind%2 == 0{
                    button.backgroundColor = col.color
                }else{
                    button.backgroundColor = col.color.colorWithAlphaComponent(0.7)// magic number!
                }
                if ind == col.segments.count-1{
                    button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                    button.setTitle(col.name, forState: UIControlState.Normal)
                }
                self.view.addSubview(button)
            }
        }
        return Array <UIButton>()//butArr
    }

}