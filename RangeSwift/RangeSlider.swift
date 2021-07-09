//
//  RangeSlider.swift
//  rangeSwift
//
//  Created by Midhet Sulemani on 07/07/2021.
//

import SwiftUI
import Combine

// MARK: SliderValue to restrict double range: 0.0 to 1.0
@propertyWrapper
struct SliderValue {
    var value: Double
    
    init(wrappedValue: Double) {
        self.value = wrappedValue
    }
    
    var wrappedValue: Double {
        get { value }
        set { value = min(max(0.0, newValue), 1.0) }
    }
}

class RangeSlider: ObservableObject {
    
    // MARK: Slider Size
    let sliderWidth: CGFloat
    let sliderHeight: CGFloat
    
    // MARK: Slider Range
    let sliderValueStart: Double
    let sliderValueRange: Double
    
    // MARK: Slider Handle
    var diameter: CGFloat = 19
    var startLocation: CGPoint
    
    // MARK: Current Value
    @Published var currentPercentage: SliderValue
    @Published var value: Double = 0
    
    // MARK: Slider Button Location
    @Published var onDrag: Bool
    @Published var currentLocation: CGPoint
        
    // MARK: Initialisation
    init(sliderWidth: CGFloat,
         sliderHeight: CGFloat,
         sliderValueStart: Double,
         sliderValueEnd: Double,
         startPercentage: SliderValue) {
        
        self.sliderWidth = sliderWidth
        self.sliderHeight = sliderHeight
        
        self.sliderValueStart = sliderValueStart
        self.sliderValueRange = sliderValueEnd - sliderValueStart
        
        let startLocation = CGPoint(x: (CGFloat(startPercentage.wrappedValue)/1.0)*sliderWidth, y: sliderHeight/2)
        
        self.startLocation = startLocation
        self.currentLocation = startLocation
        self.currentPercentage = startPercentage
        
        self.onDrag = false
    }
    
    lazy var sliderDragGesture: _EndedGesture<_ChangedGesture<DragGesture>>  = DragGesture()
        .onChanged { value in
            self.onDrag = true
            
            let dragLocation = value.location
            
            // Restrict possible drag area
            self.restrictSliderBtnLocation(dragLocation)
            
            // Get current value
            self.currentPercentage.wrappedValue = Double(self.currentLocation.x / self.sliderWidth)
            self.value = self.sliderValueStart + self.currentPercentage.wrappedValue * self.sliderValueRange
        }.onEnded { _ in
            self.onDrag = false
        }
    
    private func restrictSliderBtnLocation(_ dragLocation: CGPoint) {
        // On Slider Width
        if dragLocation.x > CGPoint.zero.x && dragLocation.x < sliderWidth {
            calcSliderBtnLocation(dragLocation)
        }
    }
    
    private func calcSliderBtnLocation(_ dragLocation: CGPoint) {
        if dragLocation.y != sliderHeight/2 {
            currentLocation = CGPoint(x: dragLocation.x, y: sliderHeight/2)
        } else {
            currentLocation = dragLocation
        }
    }
    
    func calulateLocation() {
        if !onDrag {
            currentPercentage.wrappedValue = (value - sliderValueStart)/sliderValueRange
            let location = CGPoint(x: (CGFloat(currentPercentage.wrappedValue)/1.0)*sliderWidth, y: sliderHeight/2)
            calcSliderBtnLocation(location)
        }
    }
    
    // MARK: Current Value
    var currentValue: Double {
        return sliderValueStart + currentPercentage.wrappedValue * sliderValueRange
    }
}

class CustomSlider: ObservableObject {
    
    // MARK: Slider Size
    final let width: CGFloat = 300
    final let lineWidth: CGFloat = 4
    
    // MARK: Slider value range from valueStart to valueEnd
    final let valueStart: Double
    final let valueEnd: Double
    
    // MARK: Slider Handle
    @Published var highHandle: RangeSlider
    @Published var lowHandle: RangeSlider
    
    // MARK: Handle start percentage (also for starting point)
    @SliderValue var highHandleStartPercentage = 1.0
    @SliderValue var lowHandleStartPercentage = 0.0

    // MARK: Private Cancellables
    final var anyCancellableHigh: AnyCancellable?
    final var anyCancellableLow: AnyCancellable?
    
    // MARK: Initialisation
    init(start: Double, end: Double) {
        valueStart = start
        valueEnd = end
        
        highHandle = RangeSlider(sliderWidth: width,
                                  sliderHeight: lineWidth,
                                  sliderValueStart: valueStart,
                                  sliderValueEnd: valueEnd,
                                  startPercentage: _highHandleStartPercentage
                                )
        
        lowHandle = RangeSlider(sliderWidth: width,
                                  sliderHeight: lineWidth,
                                  sliderValueStart: valueStart,
                                  sliderValueEnd: valueEnd,
                                  startPercentage: _lowHandleStartPercentage
                                )
        
        anyCancellableHigh = highHandle.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
        
        anyCancellableLow = lowHandle.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
    }
    
    // Percentages between high and low handle
    var percentagesBetween: String {
        return String(format: "%.2f",
                      highHandle.currentPercentage.wrappedValue -
                        lowHandle.currentPercentage.wrappedValue)
    }
    
    // Value between high and low handle
    var valueBetween: String {
        return String(format: "%.2f",
                      highHandle.value -
                        lowHandle.value)
    }
}
