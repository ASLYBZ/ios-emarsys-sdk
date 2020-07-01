//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <WebKit/WebKit.h>
#import "EMSInlineInAppView.h"
#import "EMSDependencyContainer.h"
#import "EMSRequestManager.h"
#import "EMSDependencyInjection.h"
#import "EMSRequestFactory.h"
#import "EMSResponseModel.h"

@interface EMSInlineInAppView (Tests)

@property(nonatomic, strong) WKWebView *webView;

- (void)fetchInlineInappMessage;

@end

@interface EMSInlineInappViewTests : XCTestCase

@property(nonatomic, strong) EMSInlineInAppView *inappView;
@property(nonatomic, strong) EMSDependencyContainer *mockContainer;
@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;
@end

@implementation EMSInlineInappViewTests

- (void)setUp {
    _inappView = [[EMSInlineInAppView alloc] initWithFrame:CGRectMake(0, 0, 640, 480)];
    _mockContainer = OCMClassMock([EMSDependencyContainer class]);
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);

    [EMSDependencyInjection setupWithDependencyContainer:self.mockContainer];
    OCMStub([self.mockContainer requestManager]).andReturn(self.mockRequestManager);
    OCMStub([self.mockContainer requestFactory]).andReturn(self.mockRequestFactory);
}

- (void)tearDown {
    [EMSDependencyInjection tearDown];
}

- (void)testFetchInlineInappMessage_shouldSendInlineInappRequestWithManager {
    EMSRequestModel *requestModel = OCMClassMock([EMSRequestModel class]);
    OCMStub([self.mockRequestFactory createInlineInappRequestModelWithViewId:@"testViewId"]).andReturn(requestModel);

    [self.inappView loadInAppWithViewId:@"testViewId"];
    [self.inappView fetchInlineInappMessage];
    OCMVerify([EMSDependencyInjection.dependencyContainer.requestFactory createInlineInappRequestModelWithViewId:@"testViewId"]);
    OCMVerify([self.mockRequestManager submitRequestModelNow:requestModel
                                                successBlock:[OCMArg any]
                                                  errorBlock:[OCMArg any]]);
}

- (void)testFetchInlineInappMessage_shouldLoadMessage {
    EMSResponseModel *mockResponse = OCMClassMock([EMSResponseModel class]);

    OCMStub([mockResponse parsedBody]).andReturn((@{
            @"inlineMessages": @[
                    @{
                            @"html": @"<HTML><BODY></BODY></HTML>",
                            @"campaignId": @"testCampaignId",
                            @"viewId": @"testViewId"
                    },
                    @{
                            @"html": @"<HTML></HTML>",
                            @"campaignId": @"testCampaignId2",
                            @"viewId": @"testViewId2"
                    }
            ]
    }));
    OCMStub([self.mockRequestManager submitRequestModelNow:[OCMArg any]
                                              successBlock:([OCMArg invokeBlockWithArgs:@"testRequestId",
                                                                                        mockResponse,
                                                                                        nil])
                                                errorBlock:[OCMArg any]]);

    [self.inappView loadInAppWithViewId:@"testViewId"];
    [self.inappView fetchInlineInappMessage];

    OCMVerify([self.inappView.webView loadHTMLString:@"<HTML><BODY></BODY></HTML>"
                                             baseURL:nil]);
}

@end