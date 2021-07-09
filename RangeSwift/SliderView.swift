//
//  SliderView.swift
//  rangeSwift
//
//  Created by Midhet Sulemani on 07/07/2021.
//

import SwiftUI
import Combine

// MARK: Complete Slider
struct SliderView: View {
    
    // MARK: Interactive Values
    @ObservedObject var slider: CustomSlider
    
    // MARK: SwiftUI Body
    var body: some View {
        RoundedRectangle(cornerRadius: slider.lineWidth)
            .fill(Color.gray.opacity(0.2))
            .frame(width: slider.width, height: slider.lineWidth)
            .overlay(
                ZStack {
                    // Path between both handles
                    SliderPathBetweenView(slider: slider)
                    
                    // Low Handle
                    SliderHandleView(handle: slider.lowHandle)
                        .highPriorityGesture(slider.lowHandle.sliderDragGesture)
                    
                    // High Handle
                    SliderHandleView(handle: slider.highHandle)
                        .highPriorityGesture(slider.highHandle.sliderDragGesture)
                }
            )
    }
}

// MARK: The circular buttons which adjust the slider
struct SliderHandleView: View {
    
    // MARK: Interactive Values
    @ObservedObject var handle: RangeSlider
    
    // MARK: SwiftUI Body
    var body: some View {
        Circle()
            .frame(width: handle.diameter, height: handle.diameter)
            .foregroundColor(Color.white)
            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 0)
            .scaleEffect(handle.onDrag ? 1.3 : 1)
            .contentShape(Rectangle())
            .position(x: handle.currentLocation.x, y: handle.currentLocation.y)
    }
}

// MARK: Highlighted Slider path
struct SliderPathBetweenView: View {
    
    // MARK: Private Types
    @ObservedObject var slider: CustomSlider
    
    // MARK: SwiftUI Body
    var body: some View {
        Path { path in
            path.move(to: slider.lowHandle.currentLocation)
            path.addLine(to: slider.highHandle.currentLocation)
        }
        .stroke(Color.green, lineWidth: slider.lineWidth)
    }
}
