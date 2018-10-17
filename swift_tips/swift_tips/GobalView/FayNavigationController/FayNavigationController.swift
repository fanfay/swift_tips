//
//  FayNavigationController.swift
//  swift_tips
//
//  Created by fay on 2018/10/17.
//  Copyright © 2018 fay. All rights reserved.
//

import UIKit

let lock: NSLock = NSLock()
class FayNavigationController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置手势代理
        self.interactivePopGestureRecognizer?.delegate = self
        self.navigationBar.barTintColor = UIColor.white
        self.navigationBar.barStyle = .default
        self.navigationBar.isTranslucent = false
        self.delegate = self
    }
    
    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.visibleViewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if animated {
            self.interactivePopGestureRecognizer?.isEnabled = false
        }
        
        DispatchQueue.main.async {
            lock.lock()
            super.pushViewController(viewController, animated: animated)
            lock.unlock()
        }
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if animated {
            self.interactivePopGestureRecognizer?.isEnabled = false
        }
        return super.popToViewController(viewController, animated: animated)
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if animated {
            self.interactivePopGestureRecognizer?.isEnabled = false
        }
        return super.popToRootViewController(animated: animated)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController.hidenNavigation! {
            _hidenNavigation()
        }else{
            _showNavigation()
        }
        
    }
    
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        self.interactivePopGestureRecognizer?.isEnabled = viewController.enableGesture!
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == interactivePopGestureRecognizer {
            if self.viewControllers.count < 2 || self.visibleViewController == self.viewControllers[0] {
                return false
            }
        }
        return true
    }

    private func _hidenNavigation() {
        self.setNavigationBarHidden(true, animated: true)
    }
    
    private func _showNavigation() {
        self.setNavigationBarHidden(false, animated: true)
    }
    
}

private var KEnableGesture = "enableGesture";
private var KHidenNavigation = "hidenNavigation";
extension UIViewController{
    /// 是否开启手势侧滑 默认true
    public var enableGesture: Bool? {
        get{
            return objc_getAssociatedObject(self, &KEnableGesture) as? Bool ?? true
        }set{
            return objc_setAssociatedObject(self, &KEnableGesture, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    /// 是否隐藏导航栏 默认false
    public var hidenNavigation: Bool? {
        get {
            return objc_getAssociatedObject(self, &KHidenNavigation) as? Bool ?? false
        }set{
            return objc_setAssociatedObject(self, &KHidenNavigation, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

