#!/bin/sh

SRC_DIR='/Users/riq/src/box2d-read-only/Box2D/Box2D'

cp "$SRC_DIR"/* .
cp "$SRC_DIR/Collision"/* Collision/
cp "$SRC_DIR/Collision/Shapes"/* Collision/Shapes/
cp "$SRC_DIR/Common"/* Common/
cp "$SRC_DIR/Dynamics"/* Dynamics/
cp "$SRC_DIR/Dynamics/Contacts"/* Dynamics/Contacts/
cp "$SRC_DIR/Dynamics/Joints"/* Dynamics/Joints/
