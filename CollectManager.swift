import SwiftUI
import Vision
class Collect: ObservableObject {
    var request: VNRecognizeTextRequest!
    // Temporal string tracker
    let numberTracker = StringTracker()
    init() {
        request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
    }
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        print("1234")
        var numbers = [String]()
        var redBoxes = [CGRect]() // Shows all recognized text lines
        var greenBoxes = [CGRect]() // Shows words that might be serials
        
        guard let results = request.results as? [VNRecognizedTextObservation] else {
            return
        }
        
        let maximumCandidates = 1
        
        for visionResult in results {
            
            guard let candidate = visionResult.topCandidates(maximumCandidates).first else { continue }
            
            // Draw red boxes around any detected text, and green boxes around
            // any detected phone numbers. The phone number may be a substring
            // of the visionResult. If a substring, draw a green box around the
            // number and a red box around the full string. If the number covers
            // the full result only draw the green box.
            var numberIsSubstring = true
            print(candidate.string)
            if let result = candidate.string.extractPhoneNumber() {
                let (range, number) = result
                print(result)
                // Number may not cover full visionResult. Extract bounding box
                // of substring.
                if let box = try? candidate.boundingBox(for: range)?.boundingBox {
                    numbers.append(number)
                    greenBoxes.append(box)
                    numberIsSubstring = !(range.lowerBound == candidate.string.startIndex && range.upperBound == candidate.string.endIndex)
                }
            }
            if numberIsSubstring {
                redBoxes.append(visionResult.boundingBox)
            }
        }
        
        // Log any found numbers.
        numberTracker.logFrame(strings: numbers)
        //show(boxGroups: [(color: UIColor.red.cgColor, boxes: redBoxes), (color: UIColor.green.cgColor, boxes: greenBoxes)])
        
        // Check if we have any temporally stable numbers.
        if let sureNumber = numberTracker.getStableString() {
            print(sureNumber)
            //showString(string: sureNumber)
            numberTracker.reset(string: sureNumber)
        }
    }
    func readImage(_ img: CIImage ) {
        request.recognitionLevel = .fast
        // Language correction won't help recognizing phone numbers. It also
        // makes recognition slower.
        request.usesLanguageCorrection = false
        // Only run on the region of interest for maximum speed.
        //request.regionOfInterest = regionOfInterest
        
        let requestHandler = VNImageRequestHandler(ciImage: img, orientation: .up, options: [:])
        request = VNRecognizeTextRequest(completionHandler: { request, error in
            guard let results = request.results as? [VNRecognizedTextObservation] else {
                return
            }
            var stringToInt = ""
                for visionResult in results {
                    let numbers = visionResult.topCandidates(1).map{$0.string}
                    for word in numbers {
                    for letter in word.unicodeScalars{
                        // 1
                        print(letter)
                        if 48...57 ~= letter.value {
                            stringToInt.append(String(letter))
                        } else {
                                
                            }
                }
                    }
            
                }
            print(stringToInt)
        })
        do {
            try requestHandler.perform([request])
        } catch {
            print(error)
        }
    }
    
    
    
    // MARK: - Bounding box drawing
    
    // Draw a box on screen. Must be called from main queue.
    var boxLayer = [CAShapeLayer]()
    func draw(rect: CGRect, color: CGColor) {
        let layer = CAShapeLayer()
        layer.opacity = 0.5
        layer.borderColor = color
        layer.borderWidth = 1
        layer.frame = rect
        boxLayer.append(layer)
        if rect.contains(CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2 )) {
            print("left")
        }
        //previewView.videoPreviewLayer.insertSublayer(layer, at: 1)
    }
    
    // Remove all drawn boxes. Must be called on main queue.
    func removeBoxes() {
        for layer in boxLayer {
            layer.removeFromSuperlayer()
        }
        boxLayer.removeAll()
    }
    
    typealias ColoredBoxGroup = (color: CGColor, boxes: [CGRect])
    
    // Draws groups of colored boxes.
    
}
