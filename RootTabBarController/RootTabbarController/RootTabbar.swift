//
//  RootTabbar.swift
//  BartRootTabBarViewController
//
//  Created by mac on 2019/6/13.
//  Copyright © 2019年 simpsons. All rights reserved.
//

import UIKit

/// 上传按钮点击代理
protocol RootTabBarDelegate: NSObjectProtocol {
    func addClick()
}

/// 自定义tabbar，修改UITabBarButton的位置
class RootTabBar: UITabBar {
    
    weak var addDelegate: RootTabBarDelegate?
    
    var configModel: RootTabBarConfig!
    
    private lazy var addButton:UIButton = {
        let btn = UIButton(type: .custom)
        btn.adjustsImageWhenHighlighted = false
        btn.addTarget(self, action: #selector(addButtonClick), for: .touchUpInside)
        btn.layer.shadowColor = UIColor(r: 176, g: 176, b: 176, a: 1.0).cgColor
        btn.layer.shadowOffset = CGSize()
        btn.layer.shadowOpacity = 0.8
        btn.layer.shadowRadius = 6.0
        btn.clipsToBounds = false
        return btn
    }()
    private let addBgImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "mainFake")
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    private let leftLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 235, g: 235, b: 235, a: 0.43)
        view.layer.shadowColor = UIColor(r: 235, g: 235, b: 235, a: 0.43).cgColor
        view.layer.shadowOffset = CGSize()
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 0.2
        view.clipsToBounds = false
        return view
    }()
    private let rightLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 235, g: 235, b: 235, a: 0.43)
        view.layer.shadowColor = UIColor(r: 235, g: 235, b: 235, a: 0.43).cgColor
        view.layer.shadowOffset = CGSize()
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 0.2
        view.clipsToBounds = false
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(addBgImage)
        self.addSubview(addButton)
        self.addSubview(leftLineView)
        self.addSubview(rightLineView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(_ config: RootTabBarConfig) {
        addButton.setImage(config.centerImage, for: .normal)
        self.backgroundImage = config.tabBarBackgroundImg ?? UIColor.creatImageWithColor(color: config.tabBarBackgroundColor!,size: CGSize(width: screenWidth, height: self.bounds.height))
        configModel = config
    }
    
    @objc func addButtonClick(){
        if addDelegate != nil{
            addDelegate?.addClick()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let vcCount = configModel.viewControllerCount
        let buttonX = self.frame.size.width/CGFloat(configModel.tabBarStyle == .normal ? vcCount : vcCount )
        var index: Int = 0
        for barButton in self.subviews {
            if barButton.isKind(of: NSClassFromString("UITabBarButton")!){
                if configModel.tabBarStyle == .center && addButton.currentImage != nil {
                    if index == vcCount/2 {
                        addBgImage.frame = CGRect(x: buttonX * CGFloat(index), y: -4, width: buttonX, height: 53)
                        /// 设置中间特殊按钮位置
                        addButton.frame.size = CGSize.init(width: (addButton.currentImage?.size.width)!, height: (addButton.currentImage?.size.height)!)
                        addButton.center = CGPoint.init(x: self.center.x, y: (self.frame.size.height - safeAreaBottomHeight)/2 - configModel.centerInsetUp)
        
                    }
                }
                if index == vcCount/2 {
                    barButton.isUserInteractionEnabled = false
                }
                barButton.frame = CGRect(x: buttonX * CGFloat(index), y: 0, width: index == vcCount/2 ? 0 : buttonX, height: index == vcCount/2 ? 0 : 49)
                index += 1
            }
        }
        self.bringSubviewToFront(addButton)
        
        let lineWidth = (screenWidth-self.addBgImage.bounds.width)/2
        self.leftLineView.frame = CGRect(x: 0, y: 0, width: lineWidth - 0.5, height: 1.5)
        self.rightLineView.frame = CGRect(x: addBgImage.frame.maxX + 0.5, y: 0, width: lineWidth, height: 1.5)
    }
    
    /// 重写hitTest方法，监听按钮的点击 让凸出tabbar的部分响应点击
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        /// 判断是否为根控制器
        if self.isHidden {
            /// tabbar隐藏 不在主页 系统处理
            return super.hitTest(point, with: event)
        } else {
            /// 将单钱触摸点转换到按钮上生成新的点
            let onButton = self.convert(point, to: self.addButton)
            let onSelf = self.convert(point, to: self)
            /// 判断新的点是否在按钮上
            if self.addButton.point(inside: onButton, with: event) {
                if configModel.isAnimation {
                    animationTap(addButton)
                }
                return addButton
            } else if self.point(inside: onSelf, with: event) {
                /// 不在按钮上 系统处理
                let tapView = super.hitTest(point, with: event)
                if configModel.isAnimation {
                    if tapView!.isKind(of: NSClassFromString("UITabBarButton")!) {
                        animationTap(tapView)
                    }
                }
                return tapView
            } else {
                return super.hitTest(point, with: event)
            }
        }
    }
    
    func animationTap(_ tapView: UIView?) {
        if tapView == nil { return }
        if configModel.animation == .scaleDown {
            let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
            impliesAnimation.values = [1.0 ,0.72, 1.12, 0.92, 1.10, 1.02, 1.0]
            impliesAnimation.duration = 0.6
            impliesAnimation.calculationMode = CAAnimationCalculationMode.cubic
            tapView!.layer.add(impliesAnimation, forKey: nil)
        } else if configModel.animation == .scaleUp {
            let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
            impliesAnimation.values = [1.0 ,1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
            impliesAnimation.duration = 0.6
            impliesAnimation.calculationMode = CAAnimationCalculationMode.cubic
            tapView!.layer.add(impliesAnimation, forKey: nil)
        } else if configModel.animation == .rotation {
            let scaleAnim = CABasicAnimation()
            scaleAnim.keyPath = "transform.rotation.z"
            scaleAnim.duration = 0.35
            scaleAnim.fromValue = 0
            scaleAnim.toValue = 2 * Double.pi
            tapView!.layer.add(scaleAnim, forKey: nil)
        }
        
    }
}



