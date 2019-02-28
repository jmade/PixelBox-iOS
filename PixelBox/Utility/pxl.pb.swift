// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: pxl.proto
//
// For information on using the generated types, please see the documenation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that your are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

struct PixelMessage {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var x: Int32 = 0

  var y: Int32 = 0

  var r: Int32 = 0

  var g: Int32 = 0

  var b: Int32 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension PixelMessage: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
    
    func _protobuf_generated_isEqualTo(other: PixelMessage) -> Bool {
        return self == other
    }
    
  static let protoMessageName: String = "PixelMessage"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "x"),
    2: .same(proto: "y"),
    3: .same(proto: "r"),
    4: .same(proto: "g"),
    5: .same(proto: "b"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularInt32Field(value: &self.x)
      case 2: try decoder.decodeSingularInt32Field(value: &self.y)
      case 3: try decoder.decodeSingularInt32Field(value: &self.r)
      case 4: try decoder.decodeSingularInt32Field(value: &self.g)
      case 5: try decoder.decodeSingularInt32Field(value: &self.b)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.x != 0 {
      try visitor.visitSingularInt32Field(value: self.x, fieldNumber: 1)
    }
    if self.y != 0 {
      try visitor.visitSingularInt32Field(value: self.y, fieldNumber: 2)
    }
    if self.r != 0 {
      try visitor.visitSingularInt32Field(value: self.r, fieldNumber: 3)
    }
    if self.g != 0 {
      try visitor.visitSingularInt32Field(value: self.g, fieldNumber: 4)
    }
    if self.b != 0 {
      try visitor.visitSingularInt32Field(value: self.b, fieldNumber: 5)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: PixelMessage, rhs: PixelMessage) -> Bool {
    if lhs.x != rhs.x {return false}
    if lhs.y != rhs.y {return false}
    if lhs.r != rhs.r {return false}
    if lhs.g != rhs.g {return false}
    if lhs.b != rhs.b {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
