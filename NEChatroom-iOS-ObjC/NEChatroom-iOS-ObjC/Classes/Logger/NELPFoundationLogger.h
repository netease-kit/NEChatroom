//
//  NELPFoundationLogger.h
//  Pods
//
//  Created by amao on 2016/12/16.
//
//

#ifndef NELPFoundationLogger_h
#define NELPFoundationLogger_h

#import "NELPLogger.h"

#ifdef __cplusplus
extern "C" {
#endif
    
void NELPLOG(NELPLogLevel level, const char *file, const char *function,NSInteger line, NSString *format, ...) NS_FORMAT_FUNCTION(5,6);
    
#ifdef __cplusplus
}
#endif


#define NELPLogDebug(frmt, ...)     NELPLOG(NELPLogLevelDebug,      __FILE__, __FUNCTION__, __LINE__,frmt,##__VA_ARGS__)
#define NELPLogInfo(frmt, ...)      NELPLOG(NELPLogLevelInfo,       __FILE__, __FUNCTION__, __LINE__,frmt,##__VA_ARGS__)
#define NELPLogWarn(frmt, ...)      NELPLOG(NELPLogLevelWarning,    __FILE__, __FUNCTION__, __LINE__,frmt,##__VA_ARGS__)
#define NELPLogError(frmt, ...)     NELPLOG(NELPLogLevelError,      __FILE__, __FUNCTION__, __LINE__,frmt,##__VA_ARGS__)



#endif /* NELPFoundationLogger_h */
