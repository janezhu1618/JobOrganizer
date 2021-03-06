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

#import <Foundation/Foundation.h>

<<<<<<< HEAD
@class FIRAuthCredential;

NS_ASSUME_NONNULL_BEGIN

=======
#import "FIRFederatedAuthProvider.h"

@class FIRAuth;
@class FIROAuthCredential;

NS_ASSUME_NONNULL_BEGIN


/**
    @brief A string constant identifying the Microsoft identity provider.
 */
extern NSString *const FIRMicrosoftAuthProviderID NS_SWIFT_NAME(MicrosoftAuthProviderID);

/**
    @brief A string constant identifying the Yahoo identity provider.
 */
extern NSString *const FIRYahooAuthProviderID NS_SWIFT_NAME(YahooAuthProviderID);


>>>>>>> refs/remotes/origin/master
/** @class FIROAuthProvider
    @brief A concrete implementation of `FIRAuthProvider` for generic OAuth Providers.
 */
NS_SWIFT_NAME(OAuthProvider)
<<<<<<< HEAD
@interface FIROAuthProvider : NSObject
=======
@interface FIROAuthProvider : NSObject<FIRFederatedAuthProvider>

/** @property scopes
    @brief Array used to configure the OAuth scopes.
 */
@property(nonatomic, copy, nullable) NSArray<NSString *> *scopes;

/** @property customParameters
    @brief Dictionary used to configure the OAuth custom parameters.
 */
@property(nonatomic, copy, nullable) NSDictionary<NSString *, NSString*> *customParameters;

/** @property providerID
    @brief The provider ID indicating the specific OAuth provider this OAuthProvider instance
          represents.
 */
@property(nonatomic, copy, readonly) NSString *providerID;

/** @fn providerWithProviderID:
    @param providerID The provider ID of the IDP for which this auth provider instance will be
        configured.
    @return An instance of FIROAuthProvider corresponding to the specified provider ID.
 */
+ (FIROAuthProvider *)providerWithProviderID:(NSString *)providerID;

/** @fn providerWithProviderID:auth:
    @param providerID The provider ID of the IDP for which this auth provider instance will be
        configured.
    @param auth The auth instance to be associated with the FIROAuthProvider instance.
    @return An instance of FIROAuthProvider corresponding to the specified provider ID.
 */
+ (FIROAuthProvider *)providerWithProviderID:(NSString *)providerID auth:(FIRAuth *)auth;
>>>>>>> refs/remotes/origin/master

/** @fn credentialWithProviderID:IDToken:accessToken:
    @brief Creates an `FIRAuthCredential` for that OAuth 2 provider identified by providerID, ID
        token and access token.

    @param providerID The provider ID associated with the Auth credential being created.
    @param IDToken The IDToken associated with the Auth credential being created.
    @param accessToken The accessstoken associated with the Auth credential be created, if
        available.
<<<<<<< HEAD
    @return A FIRAuthCredential for the specified provider ID, ID token and access token.
 */
+ (FIRAuthCredential *)credentialWithProviderID:(NSString *)providerID
                                        IDToken:(NSString *)IDToken
                                    accessToken:(nullable NSString *)accessToken;

=======
    @param pendingToken The pending token used when completing the headful-lite flow.
    @return A FIRAuthCredential for the specified provider ID, ID token and access token.
 */
+ (FIROAuthCredential *)credentialWithProviderID:(NSString *)providerID
                                         IDToken:(NSString *)IDToken
                                     accessToken:(nullable NSString *)accessToken
                                    pendingToken:(nullable NSString *)pendingToken;

/** @fn credentialWithProviderID:IDToken:accessToken:
    @brief Creates an `FIRAuthCredential` for that OAuth 2 provider identified by providerID, ID
        token and access token.

    @param providerID The provider ID associated with the Auth credential being created.
    @param IDToken The IDToken associated with the Auth credential being created.
    @param accessToken The accessstoken associated with the Auth credential be created, if
        available.
    @return A FIRAuthCredential for the specified provider ID, ID token and access token.
 */
+ (FIROAuthCredential *)credentialWithProviderID:(NSString *)providerID
                                         IDToken:(NSString *)IDToken
                                     accessToken:(nullable NSString *)accessToken;
>>>>>>> refs/remotes/origin/master

/** @fn credentialWithProviderID:accessToken:
    @brief Creates an `FIRAuthCredential` for that OAuth 2 provider identified by providerID using
      an ID token.

    @param providerID The provider ID associated with the Auth credential being created.
    @param accessToken The accessstoken associated with the Auth credential be created
    @return A FIRAuthCredential.
 */
<<<<<<< HEAD
+ (FIRAuthCredential *)credentialWithProviderID:(NSString *)providerID
                                    accessToken:(NSString *)accessToken;
=======
+ (FIROAuthCredential *)credentialWithProviderID:(NSString *)providerID
                                     accessToken:(NSString *)accessToken;
>>>>>>> refs/remotes/origin/master

/** @fn init
    @brief This class is not meant to be initialized.
 */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
