//
//  ViewController.swift
//  MKYoutubeMp3DownloaderExample
//
//  Created by Madrit Kacabumi on 27.12.19.
//  Copyright © 2019 Madrit Kacabumi. All rights reserved.
//

import UIKit
internal class ViewController: UIViewController {

    var items = [
        UIImage(named: "Screen_1"),
        UIImage(named: "Screen_2"),
        UIImage(named: "Screen_3"),
        UIImage(named: "Screen_4")
    ]
    
    var currentIndex = 0
    
    @IBOutlet private weak var pagerViewContainer: UIView!
    @IBOutlet private weak var pagerController: UIPageControl!
    
    private var viewPager : UIPageViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
    }
    
    private func initViews(){
        
        viewPager = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        viewPager.delegate = self
        viewPager.dataSource = self
        
        addChild(viewPager)
        viewPager.view.attachTo(view: pagerViewContainer)
        
        if let vc = viewControllerAtIndex(index: currentIndex) {
            viewPager.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
        }
        
        pagerController.numberOfPages = items.count
        pagerController.currentPage = currentIndex
    }
}

//MARK:- UIPageViewControllerDelegate, UIPageViewControllerDataSource
extension ViewController : UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    private func viewControllerAtIndex(index : Int) -> PreviewViewController? {
        if index < 0 || index >= items.count {
            return nil
        }
        
        return PreviewViewController(index: index, image: items[index]!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return viewControllerAtIndex(index: currentIndex - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return viewControllerAtIndex(index: currentIndex + 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let vc = pageViewController.viewControllers?.first as? PreviewViewController {
            currentIndex = vc.index
            pagerController.currentPage = currentIndex
            print(currentIndex)
        }
    }
}
