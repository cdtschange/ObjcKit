//
//  ExAFTXTRequest.m
//  exAFNetworking
//
//  Created by Wei Mao on 8/27/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "ExAFXMLRequest.h"
#import "AFNetworking.h"

@interface ExAFXMLRequest()

@end

@implementation ExAFXMLRequest

#pragma mark - Override
-(void)willRequest:(NSMutableURLRequest *)request{
    [super willRequest:request];
    [request setValue:@"application/xml" forHTTPHeaderField:@"Accept"];
    [self.client registerHTTPOperationClass:[AFXMLRequestOperation class]];
}
@end
