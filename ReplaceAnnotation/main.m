//
//  main.m
//  ReplaceAnnotation
//
//  Created by Ade on 2019/9/12.
//  Copyright © 2019 Ade. All rights reserved.
//

#import <Foundation/Foundation.h>

void printFormat(NSString *str) {
    printf("%s\n", str.UTF8String);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        // 判断参数是否够
        if (argc == 1) {
            printFormat(@"参数错误, 请传入正确的路径");
            return 0;
        }
        
        NSString *filePath = [NSString stringWithUTF8String:argv[1]];
        printFormat([NSString stringWithFormat:@"工程路径: %@", filePath]);
        
        // 判断该路径是否存在
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            printFormat(@"路径无效, 请传入一个有效的路径");
            return 0;
        }
        
        NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:filePath];
        NSString *fileName = nil;
        
        // 遍历文件夹
        while (fileName = [directoryEnumerator nextObject]) {
            
            NSString *fullPath = [filePath stringByAppendingPathComponent:fileName];
            
            // 过滤.DS_Store
            if (![fullPath containsString:@".DS_Store"]) {
                
                BOOL isDir;
                [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir];
                
                if (!isDir) {
                    
                    NSString *extension = [fullPath pathExtension];
                    if ([extension isEqualToString:@"h"]
                        || [extension isEqualToString:@"m"]
                        || [extension isEqualToString:@"mm"]) {
                        
                        printFormat([NSString stringWithFormat:@"正在处理%@...", fullPath]);
                        
                        NSString *content = [[NSString alloc] initWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:nil];
                        
                        NSMutableString *resultContent = [content mutableCopy];
                        
                        // 开始匹配 '//' 类型的注释
                        NSRegularExpression *reg1 = [NSRegularExpression regularExpressionWithPattern:@"(?<!:)\\/\\/[^\n]*" options:0 error:nil];
                        NSArray *results1 = [reg1 matchesInString:content options:0 range:NSMakeRange(0, content.length)];
                        for (NSTextCheckingResult *result in results1) {
                            NSString *annotation = [content substringWithRange:result.range];
                            NSRange realRange = [resultContent rangeOfString:annotation];
                            [resultContent replaceOccurrencesOfString:annotation withString:@"" options:NSCaseInsensitiveSearch range:realRange];
                        }
                        
                        // 开始匹配 '/**/' 类型的注释
                        NSRegularExpression *reg2 = [NSRegularExpression regularExpressionWithPattern:@"\\/\\*(\\s|.)*?\\*\\/" options:0 error:nil];
                        content = [resultContent copy];
                        NSArray *results2 = [reg2 matchesInString:content options:0 range:NSMakeRange(0, content.length)];
                        for (NSTextCheckingResult *result in results2) {
                            NSString *annotation = [content substringWithRange:result.range];
                            NSRange realRange = [resultContent rangeOfString:annotation];
                            [resultContent replaceOccurrencesOfString:annotation withString:@"" options:NSCaseInsensitiveSearch range:realRange];
                        }
                        
                        [resultContent writeToFile:fullPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    }
                }
            }
        }
        printFormat(@"替换完成!");
    }
    return 0;
}

