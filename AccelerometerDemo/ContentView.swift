//
//  ContentView.swift
//  AccelerometerDemo
//
//  Created by HuangHui on 2021/9/1.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    var body: some View {
        AccelerometerView(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, maxAngleX: 30, maxAngleY: 40, foregroundScale: 1.1, backgroundScale: 1.3)
    }
}

struct AccelerometerView: View {
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    
    var width: CGFloat
    var height: CGFloat
    var maxAngleX: CGFloat
    var maxAngleY: CGFloat
    var foregroundScale: CGFloat?
    var backgroundScale: CGFloat?
    
    let time: TimeInterval = 0.02
    
    @State var backgroundOffset: CGSize = .zero
    @State var foregroundOffset: CGSize = .zero
    
    var body: some View {
        ZStack{
            Image("jsd_b")
                .resizable()
                .scaleEffect(backgroundScale ?? 1)
                .offset(backgroundOffset)
            Text("圣诞快乐")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .offset(y: -150)
            Image("jsd_f")
                .resizable()
                .scaleEffect(foregroundScale ?? 1)
                .offset(foregroundOffset)
        }
        .frame(width: width, height: height)
        .onAppear{
            self.motionManager.startDeviceMotionUpdates(to: self.queue) { (data: CMDeviceMotion?, error: Error?) in
                guard let data = data else {
                    print("Error: \(error!)")
                    return
                }
                
                let attitude: CMAttitude = data.attitude
                
                let deltaOffset: CGSize = gyroscopeToOffset(x: CGFloat(-attitude.roll), y: CGFloat(-attitude.pitch))

                DispatchQueue.main.async {
                    self.backgroundOffset = considerBoundary(origin: deltaOffset + self.backgroundOffset)
                    self.foregroundOffset = getForegroundOffset(backgroundOffset: backgroundOffset)
                }
            }
        }
    }
    
    func getForegroundOffset(backgroundOffset: CGSize) -> CGSize {
        let offsetRate: CGFloat = ((foregroundScale ?? 1) - 1)/((backgroundScale ?? 1) - 1)
        return CGSize(width: -backgroundOffset.width * offsetRate, height: -backgroundOffset.height * offsetRate)
    }
    
    var maxBackgroundOffset: CGSize {
        return CGSize(
            width: ((backgroundScale ?? 1) - 1) * width / 2,
            height: ((backgroundScale ?? 1) - 1) * height / 2
        )
    }
    
    func considerBoundary(origin: CGSize) -> CGSize {
        let maxOffset = maxBackgroundOffset
        var x = origin.width
        var y = origin.height
        if x > maxOffset.width {
            x = maxOffset.width
        }
        if origin.width < -maxOffset.width {
            x = -maxOffset.width
        }
        if y > maxOffset.height {
            y = maxOffset.height
        }
        if origin.height < -maxOffset.height {
            y = -maxOffset.height
        }
        return CGSize(width: x, height: y)
    }
    
    func gyroscopeToOffset(x: CGFloat, y: CGFloat) -> CGSize{
        var angleX: CGFloat = x * CGFloat(time) * 180 / .pi
        var angleY: CGFloat = y * CGFloat(time) * 180 / .pi
        angleX = angleX >= maxAngleX ? maxAngleX : angleX
        angleY = angleY >= maxAngleY ? maxAngleY : angleY
        return CGSize(
            width: (angleX / maxAngleX) * maxBackgroundOffset.width,
            height: (angleY / maxAngleY) * maxBackgroundOffset.height
        )
    }
}

func + (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width + right.width, height: left.height + right.height)
}
