// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "FUTestRecorder.h"
#include <sys/sysctl.h>
#include <mach/mach.h>


@interface FUTestRecorder ()

@property (nonatomic,strong) NSString *logPath;

@end

@implementation FUTestRecorder

+ (FUTestRecorder *)shareRecorder{
  static FUTestRecorder *_shareRecorder = NULL;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _shareRecorder = [[FUTestRecorder alloc] init];
  });
  return _shareRecorder;
}


/* 海报耗时表 */
-(NSString *)logPath{
  if (!_logPath) {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd HHmmssSSS";
    
    NSDate *date = [NSDate date];
    
    NSString *currnetDate = [formatter stringFromDate:date];
    
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES).firstObject;
    
    NSString *fileName =   [NSString stringWithFormat:@"%@.csv",currnetDate];
    
    _logPath = [docPath stringByAppendingPathComponent:fileName];
    
  }
  
  return _logPath;
}


- (void)setupRecord{
  self.logPath = nil ;
  [self createFile:self.logPath];
  NSFileHandle* fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.logPath];
  [fileHandle seekToEndOfFile];
  NSString * str = @"time,fps,cpu,memory\n";
  NSData *stringData = [str dataUsingEncoding:NSUTF8StringEncoding];
  [fileHandle writeData:stringData];
  [fileHandle closeFile];
}


- (void)createFile:(NSString *)fileName {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  [fileManager removeItemAtPath:fileName error:nil];
  
  if (![fileManager createFileAtPath:fileName contents:nil attributes:nil]) {
    NSLog(@"不能创建文件");
  }
  
}

static CFAbsoluteTime oldTime = 0;
static float totalTime = 0.0;
static float totalCpu= 0.0;
static int frame= 0;

-(void)processFrameWithLog{
  CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
  CFAbsoluteTime currentFrameTime = startTime - oldTime;
  oldTime = startTime;
  totalTime += currentFrameTime;
  totalCpu += [self GetCpuUsage];
  int count = 100;
  //
  frame++;
  if (frame % count == 0) {
    float frameTime = totalTime ;
    float cpu = totalCpu ;
    totalTime = 0.0;
    totalCpu = 0.0;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss:SSS";
    NSDate *date = [NSDate date];
    NSString *currnetDate = [formatter stringFromDate:date];
    double memory = [self usedMemory];
    
    frameTime = frameTime/count;
    float fps = 1.0 / frameTime ;
    if (fps > 30) {
      fps = 30 ;
    }
    //        NSLog(@"%@,%d,%.01f,%.02f\n",currnetDate,(int)fps,cpu/count,memory);
    NSString *performance = [NSString stringWithFormat:@"%@,%d,%.01f,%.02f\n",currnetDate,(int)fps,cpu/count,memory];
    
    NSLog(@"⭐️%@", performance);
    
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.logPath];
    NSData *stringData = [performance dataUsingEncoding:NSUTF8StringEncoding];
    //将节点调到文件末尾
    [fileHandle seekToEndOfFile];
    //追加写入数据
    [fileHandle writeData:stringData];
    [fileHandle closeFile];
  }
}


- (double)usedMemory {
  
  task_vm_info_data_t vmInfo ;
  mach_msg_type_number_t count = TASK_VM_INFO_COUNT ;
  kern_return_t result = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t)&vmInfo, &count) ;
  
  if(result != KERN_SUCCESS) {
    return -1.0;
  }
  return vmInfo.phys_footprint / 1024.0 / 1024.0;
}

- (double)GetCpuUsage {
  kern_return_t kr;
  task_info_data_t tinfo;
  mach_msg_type_number_t task_info_count;
  
  task_info_count = TASK_INFO_MAX;
  kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
  if (kr != KERN_SUCCESS) {
    return -1;
  }
  
  task_basic_info_t      basic_info;
  thread_array_t         thread_list;
  mach_msg_type_number_t thread_count;
  
  thread_info_data_t     thinfo;
  mach_msg_type_number_t thread_info_count;
  
  thread_basic_info_t basic_info_th;
  uint32_t stat_thread = 0; // Mach threads
  
  basic_info = (task_basic_info_t)tinfo;
  
  // get threads in the task
  kr = task_threads(mach_task_self(), &thread_list, &thread_count);
  if (kr != KERN_SUCCESS) {
    return -1;
  }
  if (thread_count > 0)
    stat_thread += thread_count;
  
  long tot_sec = 0;
  long tot_usec = 0;
  float tot_cpu = 0;
  int j;
  
  for (j = 0; j < thread_count; j++)
  {
    thread_info_count = THREAD_INFO_MAX;
    kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                     (thread_info_t)thinfo, &thread_info_count);
    if (kr != KERN_SUCCESS) {
      return -1;
    }
    
    basic_info_th = (thread_basic_info_t)thinfo;
    
    if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
      tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
      tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
      tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
    }
    
  } // for each thread
  
  kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
  assert(kr == KERN_SUCCESS);
  
  return tot_cpu;
}


@end
