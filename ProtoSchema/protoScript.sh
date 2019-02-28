#!/bin/bash
echo 'Running ProtoBuf Compiler to convert .proto schema to Swift'
protoc --swift_out=. pxl.proto
echo 'Running Protobuf Compiler to convert .proto schema to Python'
protoc -I=. --python_out=. ./pxl.proto
