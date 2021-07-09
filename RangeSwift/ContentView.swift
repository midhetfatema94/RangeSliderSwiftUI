//
//  ContentView.swift
//  rangeSwift
//
//  Created by Midhet Sulemani on 07/07/2021.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @ObservedObject var sliderVal = CustomSlider(start: 0, end: 100)
    
    var body: some View {
        //Adding formatting to textfield decimals
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.roundingMode = NumberFormatter.RoundingMode.halfUp
        formatter.maximumFractionDigits = 0
        
        return VStack(spacing: 20) {
            HStack {
                Text("Lower: ")
                
                TextField("", value: $sliderVal.lowHandle.value, formatter: formatter)
                    .valueChanged(value: sliderVal.lowHandle.value) { _ in
                        sliderVal.lowHandle.calulateLocation()
                    }
                    .background(Color.gray)
                    .multilineTextAlignment(.center)
                
                Text("Upper: ")
                
                TextField("", value: $sliderVal.highHandle.value, formatter: formatter)
                    .valueChanged(value: sliderVal.highHandle.value) { _ in
                        sliderVal.highHandle.calulateLocation()
                    }
                    .background(Color.gray)
                    .multilineTextAlignment(.center)
            }
            
            // Custom Range Slider
            SliderView(slider: sliderVal)
        }
        .padding()
    }
}

extension View {
    /// A backwards compatible wrapper for iOS 14 `onChange`
    @ViewBuilder func valueChanged<T: Equatable>(value: T, onChange: @escaping (T) -> Void) -> some View {
        if #available(iOS 14.0, *) {
            self.onChange(of: value, perform: onChange)
        } else {
            self.onReceive(Just(value)) { (value) in
                onChange(value)
            }
        }
    }
}
