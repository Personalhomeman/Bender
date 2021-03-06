//
//  CropAndFormatLayer.swift
//  Bender
//
//  Created by Joaquin Rocco on 12/16/16.
//  Copyright © 2017 Xmartlabs. All rights reserved.
//

import MetalPerformanceShaders
import MetalPerformanceShadersProxy

/// This layer crops the input image to the desired size. The cropRect is taken from the center of the input image.
open class Crop: NetworkLayer {

    public init(device: MTLDevice, croppedSize: LayerSize, id: String? = nil) {
        super.init(id: id)
        outputSize = croppedSize
    }

    open override func initialize(network: Network, device: MTLDevice, temporaryImage: Bool = true) {
        super.initialize(network: network, device: device, temporaryImage: temporaryImage)
        createOutputs(size: outputSize, temporary: temporaryImage)
    }

    open override func validate() {
        let incoming = getIncoming()
        assert(incoming.count == 1, "Crop must have one input, not \(incoming.count)")
    }

    open override func execute(commandBuffer: MTLCommandBuffer, executionIndex index: Int = 0) {
        let input = getIncoming()[0].getOutput(index: index)
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()!
        blitEncoder.copy(from: input.texture, sourceSlice: 0, sourceLevel: 0,
                         sourceOrigin: MTLOrigin(x: (input.width - outputSize.w) / 2,
                                                 y: (input.height - outputSize.h) / 2,
                                                 z: 0),
                         sourceSize: MTLSizeMake(outputSize.w, outputSize.h, 1),
                         to: getOrCreateOutput(commandBuffer: commandBuffer, index: index).texture, destinationSlice: 0, destinationLevel: 0,
                         destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
        blitEncoder.endEncoding()
    }
}
