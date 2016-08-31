//
//  ViewController.swift
//  sc
//
//  Created by Emiaostein on 8/31/16.
//  Copyright © 2016 Emiaostein. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private var transitioning = false
    private var beganPosition = CGPoint.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        addObservers()
        collectionView.panGestureRecognizer.addTarget(self, action: #selector(ViewController.pan(_:)))
    }
}

extension ViewController {
    
    private func addObservers() {
        collectionView.addObserver(self, forKeyPath: "contentOffset", options: [.Old, .New], context: nil)
    }
    
    private func removeObservers() {
        collectionView.removeObserver(self, forKeyPath: "contentOffset")
    }
}

extension ViewController {
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "contentOffset", let offset = (change?[NSKeyValueChangeNewKey] as? NSValue)?.CGPointValue() {
            if offset.y <= 0 && collectionView.dragging && collectionView.tracking {
                transitioning = true
                removeObservers()
                beganPosition = collectionView.panGestureRecognizer.locationInView(view)
                
                let snapshot = collectionView.snapshotViewAfterScreenUpdates(false)
                snapshot.tag = 1000
                view.insertSubview(snapshot, atIndex: 0)
                snapshot.frame.origin = CGPoint(x: 0, y: 20)
                
                collectionView.transform = CGAffineTransformMakeTranslation(0, -view.bounds.height)
                count += 1
                collectionView.reloadData()
            }
        }
    }
    
    func pan(sender: UIPanGestureRecognizer) {
        let location = sender.locationInView(view)
        let distance = (view.bounds.height - beganPosition.y)
        
        switch sender.state {
        case .Changed:
            if transitioning {
                let height = view.bounds.height
                let progress = (location.y - beganPosition.y) / distance
                
                collectionView.setContentOffset(CGPoint.zero, animated: false)
                collectionView.transform = CGAffineTransformMakeTranslation(0, max(-height, -height + height * progress))
            }
            
        case .Ended:
            let progress = (location.y - beganPosition.y) / distance
            let canceled = progress <= 0.5
            if transitioning {
                if canceled {
                    transitioning = false
                    count -= 1
                    UIView.animateWithDuration(0.3, animations: { [weak self] in
                        self?.collectionView.transform = CGAffineTransformMakeTranslation(0, -self!.view.bounds.height)
                        }, completion: { [weak self] (finished) in
                            self?.collectionView.reloadData()
                            self?.collectionView.transform = CGAffineTransformIdentity
                            self?.view.viewWithTag(1000)?.removeFromSuperview()
                            self?.addObservers()
                        })
                } else {
                    transitioning = false
                    UIView.animateWithDuration(0.3, animations: { [weak self] in
                        self?.collectionView.transform = CGAffineTransformIdentity
                        }, completion: { [weak self] (finished) in
                            self?.view.viewWithTag(1000)?.removeFromSuperview()
                            self?.addObservers()
                        })
                }
            }
        default:
            ()
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1000
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        
        cell.contentView.backgroundColor = nextColor
        
        return cell
    }
}

var count = 0
private var nextColor: UIColor {
    return [
        UIColor(red:0.83, green:0.88, blue:0.61, alpha:1.00),
        UIColor(red:0.78, green:0.92, blue:0.94, alpha:1.00),
        UIColor(red:0.30, green:0.46, blue:0.67, alpha:1.00)
        ][max(count, 0) % 3]
}

