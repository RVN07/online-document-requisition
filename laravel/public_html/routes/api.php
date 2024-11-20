<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

Route::group(['prefix' => 'v1', 'namespace' => 'App\Http\Controllers\Api\V1'], function(){


      //auth 
      
      Route::post('new/user', 'AuthController@registerUser');
      Route::post('auth/login', 'AuthController@loginUser');
      Route::post('auth/login-staff', 'AuthController@loginStaff');
      Route::post('auth/logout', 'AuthController@logoutUser');
      Route::post('reset-password/request', 'AuthController@requestVerificationCode');
      Route::post('verify-code/reset-password', 'AuthController@VerifyCodeAndResetPassword');

      // to open image 
      Route::get('uploads/{filename}', 'DocumentRequestController@serveImage')->where('filename', '.*');
  
      //for testing QR Code
      
      
      // routes in ChatbotInteractionController for handling document requests in chatbot page in Flutter.
  });

Route::namespace('App\Http\Controllers\Api\V1') // Set the namespace
    ->prefix('v1') // Set the prefix
    ->middleware('auth:sanctum') // Apply the auth middleware
    ->group(function () {
        // routes for UserController only for Admin.
        
        Route::apiResource('roles', RoleController::class);
        Route::apiResource('users', UserController::class);

         // routes in CensusController connected in Flutter UI for user accounts that has Staff role
         
        Route::apiResource('censuses', CensusController::class);
        Route::post('search-address', 'CensusController@searchAddress');
        Route::delete('censuses/{id}', 'CensusController@destroy');
        Route::get('profile/{email}', 'UserController@show');
        
        
               //  Route::patch('updateUser/{id}', 'UserController@updateUserData');
        // Route::patch('updateUserPassword/{id}', 'UserController@updateUserPassword');
        
        // routes on the document requests. 
        
        
        Route::post('verify-documentrequest', 'DocumentRequestController@verifyDocumentRequest');
        Route::post('documentrequests/{id}/approve', 'DocumentRequestController@approve');
        Route::post('documentrequests/{id}/reject', 'DocumentRequestController@reject');
         Route::post('documentrequests/generate-qrcode', 'DocumentRequestController@generateQRCode');
        Route::apiResource('documentrequests', DocumentRequestController::class);
        Route::post('searchNamePending', 'DocumentRequestController@searchNamePending');
        Route::post('searchNameReport', 'DocumentRequestController@searchNameReport');
        Route::post('documentrequests/{id}/claim', 'DocumentRequestController@claim');
        Route::delete('documentrequests/{id}', 'DocumentRequestController@destroy');
      //  Route::get('/documentrequests', 'DocumentRequestController@getPendingRequests');

        
        
        Route::post('doc-request', 'DocumentRequestController@requestDocumentPending');
        
        // routes in ChatbotInteractionController for handling document requests in chatbot page in Flutter also that one store function in my document request.
        Route::post('search-census', 'ChatbotInteractionController@searchCensus')->name('search.census');
        Route::post('process-message', 'ChatbotInteractionController@processMessage');
    });



