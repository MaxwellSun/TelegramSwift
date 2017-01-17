//
//  TableRowView.swift
//  TGUIKit
//
//  Created by keepcoder on 07/09/16.
//  Copyright © 2016 Telegram. All rights reserved.
//

import Cocoa

open class TableRowView: NSTableRowView, CALayerDelegate {
    
    open private(set) weak var item:TableRowItem?
   // var selected:Bool?
    
    open var border:BorderType?
    public var animates:Bool = true
    
    public private(set) var contextMenu:ContextMenu?
    
    
    required public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
       // self.layer = (self.layerClass() as! CALayer.Type).init()
        self.wantsLayer = true

        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
        self.layer?.delegate = self
        self.layer?.drawsAsynchronously = System.drawAsync
    }
    

    open func layerClass() ->AnyClass {
        return CALayer.self;
    }
    
    open var backdorColor: NSColor {
        return .white
    }
    
    open var isSelect: Bool {
        return false
    }
    
    open override func draw(_ dirtyRect: NSRect) {
        
    }
    
    open func draw(_ layer: CALayer, in ctx: CGContext) {
        ctx.setFillColor(backdorColor.cgColor)
        ctx.fill(layer.bounds)
       
        if let border = border {
            
            ctx.setFillColor(NSColor.border.cgColor)
            
            if border.contains(.Top) {
                ctx.fill(NSMakeRect(0, NSHeight(self.frame) - .borderSize, NSWidth(self.frame), .borderSize))
            }
            if border.contains(.Bottom) {
                ctx.fill(NSMakeRect(0, 0, NSWidth(self.frame), .borderSize))
            }
            if border.contains(.Left) {
                ctx.fill(NSMakeRect(0, 0, .borderSize, NSHeight(self.frame)))
            }
            if border.contains(.Right) {
                ctx.fill(NSMakeRect(NSWidth(self.frame) - .borderSize, 0, .borderSize, NSHeight(self.frame)))
            }
            
        }
        
    }
    
    open var interactionContentView:NSView {
        return self
    }
    
    open var firstResponder:NSResponder? {
        return self
    }
    
    open override func mouseUp(with event: NSEvent) {
        if event.clickCount == 2 {
            doubleClick(in: convert(event.locationInWindow, from: nil))
            return
        }
        super.mouseUp(with: event)
    }
    
    open func doubleClick(in location:NSPoint) -> Void {
        
    }
    
    open override func menu(for event: NSEvent) -> NSMenu? {
        if let menuItems = item?.menuItems() {
            var menu = ContextMenu()
            menu.onShow = { [weak self] menu in
                self?.contextMenu = menu
                self?.onShowContextMenu()
            }
            menu.delegate = menu
            menu.onClose = { [weak self] _ in
                self?.contextMenu = nil
                self?.onCloseContextMenu()
            }
            for item in menuItems {
                menu.addItem(item)
            }
            return menu
        }
        return nil
    }
    
    
    open func onShowContextMenu() ->Void {
        self.layer?.setNeedsDisplay()
    }
    
    open func onCloseContextMenu() ->Void {
        self.layer?.setNeedsDisplay()
    }
        
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func updateMouse() {
        
    }
    
    public var isInsertionAnimated:Bool {
        if let layer = layer?.presentation(), layer.animation(forKey: "position") != nil {
            return true
        }
        return false
    }
    
    public var rect:NSRect {
        if let layer = layer?.presentation(), layer.animation(forKey: "position") != nil {
            let rect = NSMakeRect(layer.position.x, layer.position.y, frame.width, frame.height)
            return rect
        }
        return frame
    }
    
    open override func setFrameSize(_ newSize: NSSize) {
        let update = self.frame.size != newSize
        super.setFrameSize(newSize)
        if update {
            self.layer?.setNeedsDisplay()
        }
    }
    
    deinit {
        var bp:Int = 0
        bp += 1
    }
    
    open override func copy() -> Any {
        let view:View = View(frame:bounds)
        view.backgroundColor = self.backdorColor
        return view
    }
    
    open func set(item:TableRowItem, animated:Bool = false) -> Void {
        self.item = item;
    }
    
    open func focusAnimation() {
        
    }
    
}