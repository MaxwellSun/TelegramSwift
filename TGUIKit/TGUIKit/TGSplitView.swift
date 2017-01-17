//
//  SplitView.swift
//  TGUIKit
//
//  Created by keepcoder on 06/09/16.
//  Copyright © 2016 Telegram. All rights reserved.
//

import Foundation

/*
 if(![self.delegate splitViewIsMinimisize:_controllers[_splitIdx]])
 {
 [[NSCursor resizeLeftCursor] set];
 } else {
 [[NSCursor resizeRightCursor] set];
 }
 
 -(void)mouseDown:(NSEvent *)theEvent {
 [super mouseDown:theEvent];
 
 _startPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
 
 _splitIdx = 0;
 _splitSuccess = NO;
 
 [self.subviews enumerateObjectsUsingBlock:^(TGView *obj, NSUInteger idx, BOOL *stop) {
 
 if(fabs(_startPoint.x - NSMaxX(obj.frame)) <= 10)
 {
 _splitSuccess = YES;
 _splitIdx = idx;
 *stop = YES;
 }
 
 }];
 
 
 }
 
 -(void)mouseUp:(NSEvent *)theEvent {
 [super mouseUp:theEvent];
 
 _startPoint = NSMakePoint(0, 0);
 _splitSuccess = NO;
 [[NSCursor arrowCursor] set];
 }
 
 -(void)mouseDragged:(NSEvent *)theEvent {
 [super mouseDragged:theEvent];
 
 if(_startPoint.x == 0 || !_splitSuccess)
 return;
 
 NSPoint current = [self convertPoint:[theEvent locationInWindow] fromView:nil];
 
 
 if(![self.delegate splitViewIsMinimisize:_controllers[_splitIdx]])
 {
 [[NSCursor resizeLeftCursor] set];
 } else {
 [[NSCursor resizeRightCursor] set];
 }
 
 if(_startPoint.x - current.x >= 100) {
 
 _startPoint = current;
 
 [self.delegate splitViewDidNeedMinimisize:_controllers[_splitIdx]];
 
 
 } else if(current.x - _startPoint.x >= 100) {
 
 _startPoint = current;
 
 [self.delegate splitViewDidNeedFullsize:_controllers[_splitIdx]];
 
 }
 }

 
 */

fileprivate class SplitMinimisizeView : Control {
    
    private var startPoint:NSPoint = NSZeroPoint
    weak var splitView:SplitView?
    override init() {
        super.init()
        userInteractionEnabled = false
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(frame frameRect: NSRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    fileprivate override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        if mouseInside() {
            NSCursor.resizeLeft()
        } else {
            NSCursor.arrow()
        }
    }
    
    fileprivate override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        if mouseInside() {
            NSCursor.resizeLeft()
        } else {
            NSCursor.arrow()
        }
    }
    
    
    
    fileprivate override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        NSCursor.arrow()
    }
    
    fileprivate override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        
        if let splitView = splitView, let delegate = splitView.delegate {
            if splitView.state == .minimisize {
                NSCursor.resizeRight()
            } else {
                NSCursor.resizeLeft()
            }
            
            let current = splitView.convert(event.locationInWindow, from: nil)
            
            
            if startPoint.x - current.x >= 100, splitView.state != .minimisize {
                splitView.needMinimisize()
                startPoint = current
            } else if current.x - startPoint.x >= 100, splitView.state == .minimisize {
                splitView.needFullsize()
                startPoint = current
            }
        }
    }
    
    fileprivate override func mouseUp(with event: NSEvent) {
        startPoint = NSZeroPoint
    }
    
    fileprivate override func mouseDown(with event: NSEvent) {
        if let splitView = splitView {
            startPoint = splitView.convert(event.locationInWindow, from: nil)
        }
        
    }
}

public struct SplitProportion {
    var min:CGFloat = 0;
    var max:CGFloat = 0;
    
    public init(min:CGFloat, max:CGFloat) {
        self.min = min;
        self.max = max;
    }
}

public enum SplitViewState : Int {
    case none = -1;
    case single = 0;
    case dual = 1;
    case triple = 2;
    case minimisize = 3
}


public protocol SplitControllerDelegate : class {
    func splitViewDidNeedSwapToLayout(state:SplitViewState) -> Void
    func splitViewDidNeedMinimisize(controller:ViewController) -> Void
    func splitViewDidNeedFullsize(controller:ViewController) -> Void
    func splitViewIsMinimisize(controller:ViewController) -> Bool
}


public class SplitView : View {
    
    private let minimisizeOverlay:SplitMinimisizeView = SplitMinimisizeView()
    private let container:View
    fileprivate(set) var state: SplitViewState = .none {
        didSet {
            var notify:Bool = state != oldValue;
            assert(notify);
            if(notify) {
                self.delegate?.splitViewDidNeedSwapToLayout(state: state);
            }
        }
    }
    
    
    public var canChangeState:Bool = true;
    public weak var delegate:SplitControllerDelegate?
    
    
    private var _proportions:[Int:SplitProportion] = [Int:SplitProportion]()
    private var _startSize:[Int:NSSize] = [Int:NSSize]()
    private var _controllers:[ViewController] = [ViewController]()
    private var _issingle:Bool?
    private var _layoutProportions:[SplitViewState:SplitProportion] = [SplitViewState:SplitProportion]()
    
    private var _splitIdx:Int?
    
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override required public init(frame frameRect: NSRect)  {
        container = View(frame: NSMakeRect(0,0,frameRect.width, frameRect.height))
        super.init(frame: frameRect);
        self.autoresizingMask = [NSAutoresizingMaskOptions.viewWidthSizable, NSAutoresizingMaskOptions.viewHeightSizable]
        self.autoresizesSubviews = true
        container.autoresizesSubviews = false
        container.autoresizingMask = [NSAutoresizingMaskOptions.viewWidthSizable, NSAutoresizingMaskOptions.viewHeightSizable]
        addSubview(container)
        minimisizeOverlay.splitView = self

    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func addController(controller:ViewController, proportion:SplitProportion) ->Void {
        controller.viewWillAppear(false)
        container.addSubview(controller.view);
        _controllers.append(controller);
        _startSize.updateValue(controller.view.frame.size, forKey: controller.internalId);
        _proportions.updateValue(proportion, forKey: controller.internalId)
        controller.viewDidAppear(false)
    }
    
    func removeController(controller:ViewController) -> Void {
        
        controller.viewWillDisappear(false)
        let idx = _controllers.index(of: controller)!;
        
       // assert([NSThread isMainThread]);
        
        if(idx != nil) {
            container.subviews[idx].removeFromSuperview();
            _controllers.remove(at: idx);
            _startSize.removeValue(forKey: controller.internalId);
            _proportions.removeValue(forKey: controller.internalId);
        }
        controller.viewDidDisappear(false)
    }
    
    public func removeAllControllers() -> Void {
        
        var copy:[ViewController] = []
        
        
        for controller in _controllers {
            copy.append(controller)
        }
        
        for controller in copy {
            controller.viewWillDisappear(false)
        }
        
        container.removeAllSubviews();
        _controllers.removeAll();
        _startSize.removeAll();
        _proportions.removeAll();
        
        for controller in copy {
            controller.viewDidDisappear(false)
        }
    }
    
    public func setProportion(proportion:SplitProportion, state:SplitViewState) -> Void {
        _layoutProportions[state] = proportion;
    }
    
    public func removeProportion(state:SplitViewState) -> Void {
        _layoutProportions.removeValue(forKey: state);
        if(_controllers.count > state.rawValue) {
            _controllers.remove(at: state.rawValue)
        }
    }
    
    public func updateStartSize(size:NSSize, controller:ViewController) -> Void {
        _startSize[controller.internalId] = size;
        
        _proportions[controller.internalId] = SplitProportion(min:size.width, max:size.height);
        
       update();

    }
    
    public func update() -> Void {
        needsLayout = true
    }
    
    public override func layout() {
        super.layout()
        
        let s = _layoutProportions[.single]
        
        let single:SplitProportion! = _layoutProportions[.single]
        let dual:SplitProportion! = _layoutProportions[.dual]
        let triple:SplitProportion! = _layoutProportions[.triple]
        
        
        
        if acceptLayout(prop: single) && canChangeState && state != .minimisize {
            if frame.width < single.max  {
                if self.state != .single {
                    self.state = .single;
                }
            } else if acceptLayout(prop: dual) {
                if acceptLayout(prop: triple) {
                    if frame.width >= dual.min && frame.width <= dual.max {
                        if state != .dual {
                            state = .dual;
                        }
                    } else if state != .triple {
                        self.state = .triple;
                    }
                } else {
                    if state != .dual && frame.width >= dual.min {
                        self.state = .dual;
                    }
                }
                
            }
            
        }
        
        var x:CGFloat = 0;
        
        for (index, obj) in _controllers.enumerated() {
            
            var proportion:SplitProportion = _proportions[obj.internalId]!;
            var startSize:NSSize = _startSize[obj.internalId]!;
            var size:NSSize = NSMakeSize(x, frame.height);
            var min:CGFloat  = startSize.width;
            
            
            
            min = proportion.min;
            
            if(proportion.max == CGFloat.greatestFiniteMagnitude && index != _controllers.count-1) {
                
                var m2:CGFloat = 0;
                
                for i:Int in index + 1 ..< _controllers.count - index  {
                    
                    var split:ViewController = _controllers[i];
                    
                    var proportion:SplitProportion = _proportions[split.internalId]!;
                    
                    m2+=proportion.min;
                }
                
                min = frame.width - x - m2;
                
            }
            

            if(index == _controllers.count - 1) {
                min = frame.width - x;
            }
            
            size = NSMakeSize(x + min > frame.width ? (frame.width - x) : min, frame.height);
            
            var rect:NSRect = NSMakeRect(x, 0, size.width, size.height);
            
            if(!NSEqualRects(rect, obj.view.frame)) {
                obj.view.frame = rect;
            }
            
            x+=size.width;
            
        }
        
        //assert(state != .none)
        if state != .none {
            if state == .dual || state == .minimisize {
                if let first = container.subviews.first {
                    if minimisizeOverlay.superview == nil {
                        addSubview(minimisizeOverlay)
                    }
                    minimisizeOverlay.frame = NSMakeRect(first.frame.maxX - 5, 0, 10, frame.height)
                }
                
            } else {
                minimisizeOverlay.removeFromSuperview()
            }
        }

    }
    
    
    public func needFullsize() {
        self.state = .none
        self.needsLayout = true
    }
    
    public func needMinimisize() {
        self.state = .minimisize
        self.needsLayout = true
    }
    

    func acceptLayout(prop:SplitProportion!) -> Bool {
        return prop != nil ? (prop!.min > 0 && prop!.max > 0) : false;
    }
    
}