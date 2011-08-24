//
//  AppDelegate.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 12/09/09.
//  Copyright Sapus Media 2009. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION
//


#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window_;
	RootViewController *viewController_;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RootViewController *viewController;

@end
