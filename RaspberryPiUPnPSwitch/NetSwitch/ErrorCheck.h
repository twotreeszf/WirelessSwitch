//
//  ErrorCheck.h
//  UPnPSwitch
//
//  Created by zhang fan on 13-8-5.
//  Copyright (c) 2013年 twotrees. All rights reserved.
//

#ifndef UPnPSwitch_ErrorCheck_h
#define UPnPSwitch_ErrorCheck_h

#ifdef DEBUG
#import <UIKit/UIKit.h>

#define XASSERT(exp)\
do\
{\
	if (!(exp))\
	{\
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"assert failed"\
														message:[NSString stringWithUTF8String:#exp]\
													   delegate:nil\
											  cancelButtonTitle:@"OK"\
											  otherButtonTitles:nil];\
		[alert show];\
		alert = nil;\
		asm("int $3");\
	}\
}\
while(0)

#else

#define XASSERT(exp) ((void)0)

#endif

#define CHECK_BOOL(exp)													\
do {																	\
    if (!(exp))															\
	{																	\
        goto Exit0;														\
	}																	\
} while(0)

#define ERROR_CHECK_BOOL(exp)											\
do {																	\
    if (!(exp))															\
	{																	\
        XASSERT(!"ERROR_CHECK Faild:" #exp);						\
        goto Exit0;														\
	}																	\
} while(0)

#define CHECK_BOOLEX(exp, exp1)											\
do {																	\
    if (!(exp))															\
	{																	\
        exp1;															\
        goto Exit0;														\
	}																	\
} while(0)

#define ERROR_CHECK_BOOLEX(exp, exp1)									\
do {																	\
    if (!(exp))			    											\
	{																	\
        XASSERT(!"ERROR_CHECK Faild:" #exp);						\
        exp1;															\
        goto Exit0;														\
	}																	\
} while(0)

#define QUIT()      \
do                  \
{                   \
    goto Exit0;     \
} while (0)

#endif
