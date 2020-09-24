import Cocoa
import AppKit

// turn gif into list of URL's to TIFF data of each frame
func getSequence(gifNamed: String) -> [Int: URL] {

    guard let bundleURL = Bundle.main.url(forResource: gifNamed, withExtension: "gif")
        else {
            print("This image named \"\(gifNamed)\" does not exist!")
            return [:]
    }
    
    guard let imageData = try? Data(contentsOf: bundleURL) else {
        
        print("Cannot turn image named \"\(gifNamed)\" into NSData")
        return [:]
    }
    
    let gifOptions = [
        kCGImageSourceShouldAllowFloat as String : true as NSNumber,
        kCGImageSourceCreateThumbnailWithTransform as String : true as NSNumber,
        kCGImageSourceCreateThumbnailFromImageAlways as String : true as NSNumber
    ] as CFDictionary
    
    guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, gifOptions)
        else {
            debugPrint("Cannot create image source with data!")
            return [:]
    }
    
    //    dictionary to store URLs
    var framesURL:Dictionary<Int, URL> = [:]
    
    // create temporary directory to store images
    let tempURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    
    // convert CGImage to TIFF arguements
    let ctx = CIContext.init()
    
    // number of frames
    print(CGImageSourceGetCount(imageSource))
    
    // through each frame of gif
    for index in 0...(CGImageSourceGetCount(imageSource)-1) {
        
        // current images random URL within temporary directory
        let tempFileName = ProcessInfo().globallyUniqueString
        let tempFileURL = tempURL.appendingPathComponent(tempFileName)
        
        // CGImage representation of frame
        let tempCGIimage = CGImageSourceCreateImageAtIndex(imageSource, index, nil)
        let imageCI = CIImage(cgImage: tempCGIimage!)
        
           do {
//                
                // convert CGImage to TIFF
                try ctx.writeTIFFRepresentation(of:imageCI, to:tempFileURL, format:CIFormat.RGBA16, colorSpace:CGColorSpaceCreateDeviceRGB(), options:[:])
               
                // write into dictionary
                framesURL[index] = tempFileURL
               
           } catch{}
        
    }
    return framesURL
}
    
    // list of frames of gif
    let frameList = getSequence(gifNamed: "rooftop")

    //workspace and screen
    let workspace = NSWorkspace.shared
    let screen = NSScreen.main
    
    // options for each frame
    var options = workspace.desktopImageOptions(for: screen!)
    options![NSWorkspace.DesktopImageOptionKey.allowClipping] = true
    
    var index = 0
    while true {
        do {
            
        // gets URL through index key from {frameList}
        try workspace.setDesktopImageURL(frameList[index]!, for: screen!, options: options!)
        // pause distance
        usleep(80000)
    
        // increments index (key)
        index+=1
        index %= frameList.count-1
            
        } catch{}
}
