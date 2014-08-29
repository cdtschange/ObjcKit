//
//  ExAFJSONRequest.m
//  exAFNetworking
//
//  Created by Wei Mao on 8/27/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "ExAFJSONRequest.h"
#import "AFNetworking.h"

@interface ExAFJSONRequest()

@end

@implementation ExAFJSONRequest

-(void)dealloc{
}

#pragma mark - Override
-(void)willRequest:(NSMutableURLRequest *)request{
    [super willRequest:request];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    [self.client registerHTTPOperationClass:[AFJSONRequestOperation class]];
}

-(void)requestWithMethod:(ExAFNetworkHttpMethod)httpMethod path:(NSString *)path param:(NSDictionary *)param success:(void (^)(NSHTTPURLResponse *, id))success failure:(void (^)(NSHTTPURLResponse *, NSError *))failure{
    NSString *methodStr;
    switch (httpMethod) {
        case ExAFNetworkHttpMethodGet:      methodStr = @"GET";     break;
        case ExAFNetworkHttpMethodPost:     methodStr = @"POST";    break;
        case ExAFNetworkHttpMethodPut:      methodStr = @"PUT";     break;
        case ExAFNetworkHttpMethodDelete:   methodStr = @"DELETE";  break;
        default:                            methodStr = @"GET";     break;
    }
    NSString *pathEncode = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [self.client requestWithMethod:methodStr path:pathEncode parameters:param];
    [self willRequest:request];
    __weak ExAFJSONRequest *weakself = self;
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            [weakself didGetResponse:operation.response];
            success(operation.response, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation.response, error);
        }
    }];
    [operation start];
}
@end
