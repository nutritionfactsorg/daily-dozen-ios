//
//  SnapHelper.swift
//  DailyDozenUITests
//
//  Copyright © 2021 Nutritionfacts.org. All rights reserved.
//

import XCTest

struct SnapHelper {
    // --- Singleton ---
    static let shared = SnapHelper()
    // --- External Properties ---
    var verbose = true
    // --- Internal Properties ---
    private var _app: XCUIApplication!
    private let _logUrl = UrlHelper.shared.dirTopic("Screen Log")
    private let _colorArea = UIColor(hue: 0.5, saturation: 1.0, brightness: 0.6, alpha: 0.4).cgColor
    private let _colorAreaStroke = UIColor(hue: 0.5, saturation: 1.0, brightness: 1.0, alpha: 1.0).cgColor
    private let _colorTouchPoint = UIColor(hue: 0.8, saturation: 1.0, brightness: 0.6, alpha: 0.8).cgColor
    private var _scaleX = CGFloat(1.0)
    private var _scaleY = CGFloat(1.0)
    
    // Set `app` and scale
    mutating func setup(app: XCUIApplication) {
        _app = app
        
        let screenshot = app.screenshot()
        let screenshotSize: CGSize = screenshot.image.size
        
        let window = app.windows.firstMatch
        let windowFrameSize: CGSize = window.frame.size

        _scaleX = screenshotSize.width / windowFrameSize.width
        _scaleY = screenshotSize.height / windowFrameSize.height
        
        print("""
        ### SnapHelper init: scaling setup ###
                screenshotSize = \(screenshotSize.debugDescription)
               windowFrameSize = \(windowFrameSize.debugDescription)
            (_scaleX, _scaleY) = (  \(_scaleX),   \(_scaleY)) 
        """)
        
        if _scaleX != _scaleY {
            fatalError("SnapHelper init expected _scaleX == _scaleY ")
        }
    }
    
    func addMarkers(_ screenshot: XCUIScreenshot, areas: [CGRect], points: [CGPoint], toPng: Bool = true) -> Data {
        let image: UIImage = screenshot.image
        let imageSize: CGSize = image.size
        let scale: CGFloat = 1.0 // do not use 0.0
        let isOpaque = false // keep alpha channel
        UIGraphicsBeginImageContextWithOptions(
            imageSize, // points. size to return when completed
            isOpaque,  // alpha channel flag
            scale
        )
        
        guard let context = UIGraphicsGetCurrentContext()
        else {
            fatalError("SnapHelper.addMarkers(…) context nil")
        }
        
        // add background image
        image.draw(at: CGPoint.zero)
        // add area rectangles
        for rectangle in areas {
            drawArea(rectangle, context: context)
        }
        // add points
        for touchPoint in points {
            drawTouchpoint(touchPoint, context: context)
        }
        
        guard 
            let img = UIGraphicsGetImageFromCurrentImageContext(),
            let data = toPng ? img.pngData() : img.jpegData(compressionQuality: 0.9)
        else {
            UIGraphicsEndImageContext() // cleanup
            fatalError("SnapHelper.addMarkers(…) image data nil")
        }
        
        UIGraphicsEndImageContext() // cleanup
        return data
    }
    
    private func drawArea(_ rect: CGRect, context: CGContext) {
        // point frame
        let frame = CGRect(
            x: (rect.origin.x * _scaleX),
            y: (rect.origin.y * _scaleY),
            width: rect.size.width * _scaleX,
            height: rect.size.height * _scaleY
        )

        if verbose {
            print("""
            ### AREA ###
                    context: \(context.width) x \(context.height)
              original_rect: origin=\(rect.origin) size=\(rect.size)
                scaled_rect: origin=\(frame.origin) size=\(frame.size)
            """)
        }
        
        context.setFillColor(_colorArea)
        context.setStrokeColor(_colorAreaStroke)
        context.addRect(frame)
        context.drawPath(using: .fillStroke)
    }

    private func drawTouchpoint(_ point: CGPoint, context: CGContext) {
        // point dimension
        let side: CGFloat = 12.0
        let halfSide = side/2.0

        // point frame
        let frame = CGRect(
            x: (point.x * _scaleX) - halfSide,
            y: (point.y * _scaleY) - halfSide,
            width: side,
            height: side
        )
        
        if verbose {
            print("""
            ### TOUCHPOINT ###
              original_point: \(point.debugDescription)
                scaled_point: (\(frame.midX), \(frame.midY))
            """)
        }
        
        context.setFillColor(_colorTouchPoint)
        context.setStrokeColor(_colorTouchPoint)
        context.addRect(frame)
        context.drawPath(using: .fill)
    }
        
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func logScreen(cellList: [XCUIElement], coordinateList: [XCUICoordinate], name: String, text: String? = nil) {
        let screenshot: XCUIScreenshot = XCUIScreen.main.screenshot()
        
        var areas = [CGRect]()
        for cell in cellList {
            areas.append(cell.frame)
        }
        var points = [CGPoint]()
        for coordinate in coordinateList {
            points.append(coordinate.screenPoint)
        }
        
        let png = addMarkers(screenshot, areas: areas, points: points)
        let pngUrl = _logUrl.appendingPathComponent(name, isDirectory: false)
        do {
            try png.write(to: pngUrl)
        } catch {
            print(":FAIL: logScreen \(pngUrl.path) ")
        }
        
        if var text = text {
            text.append("\n\n##### Points of Interest #####\n\n")
            text.append("# CELLS\n")
            for cell in cellList {
                text.append("at \(cell.frame.origin) with size \(cell.frame.size)\n")
            }
            text.append("# COORDINATES\n")
            for coordinate in coordinateList {
                text.append("\(coordinate.screenPoint)\n")
            }
            let textUrl = pngUrl.appendingPathExtension(".txt")
            try? text.write(to: textUrl, atomically: false, encoding: .utf8)
        }
        
    }
    
}
