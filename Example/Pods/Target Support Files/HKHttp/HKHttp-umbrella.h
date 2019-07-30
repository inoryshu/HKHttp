#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "HKHttp+RequestManager.h"
#import "HKHttp.h"
#import "HKNetworkingHelper.h"

FOUNDATION_EXPORT double HKHttpVersionNumber;
FOUNDATION_EXPORT const unsigned char HKHttpVersionString[];

