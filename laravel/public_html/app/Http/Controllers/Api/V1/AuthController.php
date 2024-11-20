<?php

namespace App\Http\Controllers\Api\V1;

use App\Mail\VerificationEmail;
use App\Models\User;
use Dotenv\Exception\ValidationException;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Password;

class AuthController extends Controller
{
    /**
     * Login The User
     * @param Request $request
     * @return User
     */
    public function loginUser(Request $request)
    {
        try {
            $validateUser = Validator::make(
                $request->all(),
                [ 
                    'email' => 'required|email',
                    'password' => 'required'
                ]
            );

            if ($validateUser->fails()) {
                return response()->json([
                    'status' => false,
                    'message' => 'Validation error',
                    'errors' => $validateUser->errors()
                ], 401);
            }

            if (!Auth::attempt($request->only(['email', 'password']))) {
                return response()->json([
                    'status' => false,
                    'message' => 'Email & Password does not match with our record.',
                ], 401);
            }

            $user = User::where('email', $request->email)->first();

            return response()->json([
                'status' => true,
                'message' => 'User Logged In Successfully',
                'token' => $user->createToken("API TOKEN")->plainTextToken
            ], 200);

        } catch (\Throwable $th) {
            return response()->json([
                'status' => false,
                'message' => $th->getMessage()
            ], 500);
        }
    }

    public function loginStaff(Request $request)
{
    try {
        $validateUser = Validator::make(
            $request->all(),
            [ 
                'email' => 'required|email',
                'password' => 'required'
            ]
        );

        if ($validateUser->fails()) {
            return response()->json([
                'status' => false,
                'message' => 'Validation error',
                'errors' => $validateUser->errors()
            ], 401);
        }

        if (!Auth::attempt($request->only(['email', 'password']))) {
            return response()->json([
                'status' => false,
                'message' => 'Email & Password do not match with our records.',
            ], 401);
        }

        $user = User::where('email', $request->email)->first();

        // Return the user's role in the response
        return response()->json([
            'status' => true,
            'message' => 'User Logged In Successfully',
            'token' => $user->createToken('API TOKEN')->plainTextToken,
            'role' => $user->role_id,
        ], 200);
    } catch (\Throwable $th) {
        return response()->json([
            'status' => false,
            'message' => $th->getMessage()
        ], 500);
    }
}

public function logoutUser(Request $request)
{
    try {
        $validateUser = Validator::make($request->all(), [
            'email' => 'required',
            'password' => 'required'
        ]);

        if ($validateUser->fails()) {
            return response()->json([
                'status' => false,
                'message' => 'Validation error',
                'errors' => $validateUser->errors()
            ], 401);
        }

        if (!Auth::attempt($request->only(['email', 'password']))) {
            return response()->json([
                'status' => false,
                'message' => 'Email and password do not match with our records.',
            ], 401);
        }

        $user = $request->user();
        $user = User::where('email', $request->email)->first();
        // Reset the token count
        $this->resetTokenCount($request);

        // Delete the user's tokens
        $user->tokens()->delete();

            // Update the expires_at field in the personal_access_tokens table
            $user->tokens()->update([
                'expires_at' => now()
            ]);

        return response()->json([
            'status' => true,
            'message' => 'User logged out successfully'
        ], 200);
    } catch (\Throwable $th) {
        return response()->json([
            'status' => false,
            'message' => $th->getMessage()
        ], 500);
    }
}
public function requestVerificationCode(Request $request)
{
    try {
        // Validate the user's email
        $request->validate([
            'email' => 'required|email|exists:users,email',
        ]);

        $user = User::where('email', $request->email)->first();
        
    // Check the user's role
        if ($user->role_id === 4 || $user->role_id === 1) {
            return response()->json(['error' => 'Staff and Admin users are not eligible for password reset.'], 403);
        } else {

        // Generate a random 8-digit number for the verification code
        $verificationCode = str_pad(mt_rand(1, 99999999), 8, '0', STR_PAD_LEFT);

        // Store the verification code
        $user->verification_code = $verificationCode;
        $user->save();

        // Send an email with the verification code
        $to = $user->email;
        $subject = 'Email Verification Code';
        $message = 'Your verification code is: ' . $verificationCode;
        $headers = 'From: ecensusonlinerequest.online';

        if (mail($to, $subject, $message, $headers)) {
            return response()->json(['message' => 'Verification code sent. Check your email.']);
        } else {
            Log::error("Email sending failed for user: {$user->email}");
            return response()->json(['error' => 'Email sending failed. Please try again later.'], 500);
        }
    }
    } catch (\Throwable $e) {
        return response()->json(['error' => 'Verification code request failed. Please try again later.'], 500);
    }
}


public function VerifyCodeAndResetPassword(Request $request)
{
    try {
        // Validate the user's email, verification code, and new password
        $request->validate([
            'email' => 'required|email|exists:users,email',
            'verification_code' => 'required|digits:8',
            'password' => 'required|min:6',
        ]);

        // Find the user by email and verification code
        $user = User::where('email', $request->email)
            ->where('verification_code', $request->verification_code)
            ->first();

        if (!$user) {
            return response()->json(['error' => 'Invalid verification code or email.'], 400);
        }

        // Reset the user's password
        $user->password = Hash::make($request->password);
        $user->verification_code = null; // Clear the verification code
        $user->save();

        return response()->json(['message' => 'Password reset successful.']);
    } catch (\Throwable $e) {
        return response()->json(['error' => 'Password reset failed. Please try again later.'], 500);
    }
}

    public function resetTokenCount(Request $request)
{
    try {
        $user = $request->user();

        // Revoke all the user's tokens
        $user->tokens()->delete();

        // Update the expires_at field in the personal_access_tokens table
        $user->tokens()->update([
            'expires_at' => now()->subDays(1), // Set to a time in the past
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Token count reset successfully',
        ], 200);
    } catch (\Throwable $th) {
        return response()->json([
            'status' => false,
            'message' => $th->getMessage()
        ], 500);
    }
}

    public function registerUser(Request $request)
    {
        try {
            // Validate user input
            $this->validate($request, [
                'role_id' => 'required',
                'firstname' => 'required',
                'middlename' => 'sometimes',
                'lastname' => 'required',
                'suffix'=> 'sometimes',
                'gender' => 'required',
                'age' => 'required',
                'address' => 'required',
                'birthDate' => 'required',
                'contactnumber' => 'required',
                'username' => 'required',
                'email' => 'required',
                'password' => 'required|min:6',
            ]);
    
            // Create a new user
            $user = User::create([
                'role_id' => $request->role_id,
                'firstname' => $request->firstname,
                'middlename' => $request->middlename,
                'lastname' => $request->lastname,
                'suffix'=> $request->suffix,
                'gender'=> $request->gender,
                'age' => $request->age,
                'address' => $request->address,
                'birthDate' => $request->birthDate,
                'contactnumber' => $request->contactnumber,
                'username' => $request->username,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'status' => 'Pending',
            ]);
    
            // Generate a random 8-digit number
            $verificationCode = str_pad(mt_rand(1, 99999999), 8, '0', STR_PAD_LEFT);
    
            // Store the verification code and mark email as unverified
            $user->verification_code = $verificationCode;
            $user->email_verified_at = null;
            $user->last_code_request = now();
            $user->save();
    
            // Send an email with the verification code
            $to = $user->email;
            $subject = 'Email Verification';
            $message = 'Thank you for registering with us. Your verification code is: ' . $verificationCode;
            $headers = 'From: ecensusonlinerequest.online';
    
            if (mail($to, $subject, $message, $headers)) {
                return response()->json(['message' => 'Registration successful. Please check your email for verification.'], 201);
            } else {
                // Email sending failed
                Log::error("Email sending failed for user: {$user->email}");
                return response()->json(['error' => 'Email sending failed. Please try again later.'], 500);
            }
        } catch (ValidationException $e) {
            // Validation failed
            return response()->json(['errors' => $e], 422);
        } catch (\Exception $e) {
            // Other exceptions (e.g., database errors)
            Log::error("Registration failed: {$e->getMessage()}");
            return response()->json(['error' => 'Registration failed. Please try again later.'], 500);
        }
    }
    
}