/*
 * Copyright 2017 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "FIROAuthCredential.h"

<<<<<<< HEAD
=======
#import "FIRAuthCredential_Internal.h"
#import "FIRAuthExceptionUtils.h"
#import "FIROAuthCredential_Internal.h"
>>>>>>> refs/remotes/origin/master
#import "FIRVerifyAssertionRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface FIROAuthCredential ()

- (nullable instancetype)initWithProvider:(NSString *)provider NS_UNAVAILABLE;

@end

@implementation FIROAuthCredential

<<<<<<< HEAD
- (nullable instancetype)initWithProviderID:(NSString *)providerID
                                    IDToken:(nullable NSString *)IDToken
                                accessToken:(nullable NSString *)accessToken {
=======
- (nullable instancetype)initWithProvider:(NSString *)provider {
  [FIRAuthExceptionUtils raiseMethodNotImplementedExceptionWithReason:
      @"Please call the designated initializer."];
  return nil;
}

- (instancetype)initWithProviderID:(NSString *)providerID
                           IDToken:(nullable NSString *)IDToken
                       accessToken:(nullable NSString *)accessToken
                      pendingToken:(nullable NSString *)pendingToken {
>>>>>>> refs/remotes/origin/master
  self = [super initWithProvider:providerID];
  if (self) {
    _IDToken = IDToken;
    _accessToken = accessToken;
<<<<<<< HEAD
=======
    _pendingToken = pendingToken;
  }
  return self;
}

- (instancetype)initWithProviderID:(NSString *)providerID
                         sessionID:(NSString *)sessionID
            OAuthResponseURLString:(NSString *)OAuthResponseURLString {
  self = [self initWithProviderID:providerID IDToken:nil accessToken:nil pendingToken:nil];
  if (self) {
    _OAuthResponseURLString = OAuthResponseURLString;
    _sessionID = sessionID;
>>>>>>> refs/remotes/origin/master
  }
  return self;
}

- (void)prepareVerifyAssertionRequest:(FIRVerifyAssertionRequest *)request {
  request.providerIDToken = _IDToken;
  request.providerAccessToken = _accessToken;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
  return YES;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
  NSString *IDToken = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"IDToken"];
  NSString *accessToken = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"accessToken"];
<<<<<<< HEAD
  self = [self initWithProviderID:self.provider IDToken:IDToken accessToken:accessToken];
=======
  NSString *pendingToken = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"pendingToken"];
  self = [self initWithProviderID:self.provider
                          IDToken:IDToken
                      accessToken:accessToken
                     pendingToken:pendingToken];
>>>>>>> refs/remotes/origin/master
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:self.IDToken forKey:@"IDToken"];
  [aCoder encodeObject:self.accessToken forKey:@"accessToken"];
<<<<<<< HEAD
}

NS_ASSUME_NONNULL_END

@end
=======
  [aCoder encodeObject:self.pendingToken forKey:@"pendingToken"];
}

@end

NS_ASSUME_NONNULL_END
>>>>>>> refs/remotes/origin/master
