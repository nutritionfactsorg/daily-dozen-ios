//
//  MapHelper.swift
//  DailyDozenUITests
//
//  Copyright © 2021 Nutritionfacts.org. All rights reserved.
//

import Foundation
import CoreGraphics

struct MapHelper {
    let colors = [ 
        "hsl(0, 100%, 25%)",
        "hsl(32, 100%, 25%)", 
        "hsl(80, 100%, 25%)", 
        "hsl(167, 100%, 25%)", 
        "hsl(206, 100%, 25%)", 
        "hsl(256, 100%, 25%)", 
        "hsl(290, 100%, 25%)",
    ]
    // Text Alignment
    let xStart = 360
    let yStart = 12
    let yStep = 24
    // Page Setup    
    let ppi: CGFloat
    let pageMargin: CGFloat
    let pageWidth: CGFloat 
    let pageHeight: CGFloat 
    // Data
    var rectList: [CGRect]
    var rectNameList: [String]
    
    init(windowSize: CGSize = CGSize(width: 320, height: 568)) {
        // device window: SE 1st gen: 320 x 568
        self.ppi = 72.0 // point per inch
        // Note: (72/2 = 36) < (612 - 568 = 44), margin allows full screen height
        self.pageMargin = CGFloat(0.5 * ppi) // 0.25 inch each side
        self.pageWidth = CGFloat((11.0 * ppi)) - pageMargin 
        self.pageHeight = CGFloat((8.5 * ppi)) - pageMargin 
        
        self.rectList = [CGRect]()
        self.rectNameList = [String]()
        // first rect element is the window (required)
        self.rectList.append(CGRect(origin: CGPoint(x: 0, y: 0), size: windowSize))
        self.rectNameList.append("window")
    }
    
    mutating func addRect(_ r: CGRect, name: String) {
        rectList.append(r)
        rectNameList.append(name)
    }

    mutating func addRectList(_ list: [(rect: CGRect, name: String)]) {
        for item in list {
            rectList.append(item.rect)
            rectNameList.append(item.name)            
        }
    }
    
    func getSvg() -> String {
        var svg = ""
        svg.append(svgHeader())
        
        for i in 0 ..< rectList.count {
            let rect = rectList[i]
            let name = rectNameList[i]
            svg.append(svgRect(rect, name: name, index: i))
        }
        
        svg.append(svgFooter())
        return svg
    }
    
    func svgHeader() -> String {
        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" 
            "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
        <svg version="1.1" 
            xmlns="http://www.w3.org/2000/svg" 
            xmlns:xlink="http://www.w3.org/1999/xlink" 
            width="\(pageWidth)" height="\(pageHeight)"  
            xml:space="preserve" 
            id="canvas1">
        
        """
    }
    
    func svgRect(_ r: CGRect, name: String, index: Int) -> String {
        let xLine = xStart
        let yLine = yStart + (index * yStep)
        var text = "\(name): "
        text.append("{\(r.minX), \(r.minY)} [\(r.width) x \(r.height)] {\(r.maxX), \(r.maxY)}")
        return """
        <rect id="canvas1-\(name)" stroke="\(colors[index])" fill="none" stroke-width="2"
              x="\(r.minX)" y="\(r.minY)" width="\(r.width)" height="\(r.height)" />
        <text fill="\(colors[index])" x="\(xLine)" y="\(yLine)" 
              font-family="DejaVuSansMono, 'DejaVu Sans Mono', monospace" 
              font-size="12" text-anchor="start" >
            \(text)
        </text>
        
        """
    }
        
    func svgFooter() -> String {
        return """
        </svg>
        
        """
    }
    
}
