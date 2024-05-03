//
//  ViewController.swift
//  UICalendarMyOwnTest
//

import UIKit
import SwiftUI

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    //    @IBSegueAction func embedSwiftUIView(_ coder: NSCoder) -> UIViewController? {
    //        return UIHostingController(coder: coder, rootView: TestSwiftUIView())
    //    }
    
    @IBSegueAction func embedSwiftUIView(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: EventsCalendarView().environmentObject(EventStore(preview: true)))
    }
}

//https://stackoverflow.com/questions/60591196/passing-an-environmentobject-from-an-nshostingcontroller-to-a-swiftui-view
