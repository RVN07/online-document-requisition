<?php

namespace App\Http\Controllers\Api\V1;

use Illuminate\Support\Facades\Mail;
use App\filters\DocumentRequestFilter;
use App\Http\Controllers\Controller;
use Endroid\QrCode\Builder\Builder;
use Endroid\QrCode\Color\Color;
use Endroid\QrCode\Encoding\Encoding;
use Endroid\QrCode\ErrorCorrectionLevel;
use Endroid\QrCode\Label\Font\NotoSans;
use Endroid\QrCode\Label\Label;
use Endroid\QrCode\Label\LabelAlignment;
use Endroid\QrCode\Writer\PngWriter;
use Endroid\QrCode\Logo\Logo;
use Endroid\QrCode\RoundBlockSizeMode;
use Endroid\QrCode\Writer\SvgWriter;
use Illuminate\Support\Facades\Storage;
use App\Mail\DocumentRequestApproval;

use App\Notifications\DocumentRequestApproved;
use App\Notifications\DocumentRequestRejected;

use App\Http\Requests\UpdateDocumentRequestRequest;
use App\Http\Resources\V1\DocumentRequestCollection;
use App\Http\Resources\V1\DocumentRequestResource;
use App\Models\DocumentRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\File;
use Intervention\Image\Facades\Image;
use Endroid\QrCode\QrCode;
//use SimpleSoftwareIO\QrCode\Facades\QrCode;
use Illuminate\Support\Str;
use Carbon\Carbon;
use Illuminate\Support\Facades\Cache;

use Intervention\Image\Facades\Image as ImageIntervention;



class DocumentRequestController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $filter = new DocumentRequestFilter();
        $filterItem = $filter->transform($request);
    
        $documentRequests = DocumentRequest::when(count($filterItem) > 0, function ($query) use ($filterItem) {
            return $query->where($filterItem);
        })->get();
    
        // Transform the 'required' attribute to 'Yes' or 'No' based on the boolean value
        $documentRequests->transform(function ($documentRequest) {
            $documentRequest->required = $documentRequest->required ? 'Yes' : 'No';
            return $documentRequest;
        });
    
        return new DocumentRequestCollection($documentRequests);
    }
    
    
//public function getPendingRequests(Request $request)
 //   {
  //      try {
   //         $status = $request->input('status', 'pending');
//
            // Check if the provided status is valid
   //         if (!in_array($status, ['pending', 'approved', 'rejected'])) {
   //             return response()->json(['error' => 'Invalid status provided.'], 400);
    //        }
//
     //       $pendingRequests = DocumentRequest::where('status', $status)->get();

    //        if ($pendingRequests->isEmpty()) {
     //           return response()->json(['message' => "No $status requests found."], 404);
     //       }

    //        return response()->json(['data' => $pendingRequests], 200);
   //     } catch (\Exception $e) {
    //        return response()->json(['error' => $e->getMessage()], 500);
   //     }
  //  }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
public function store(Request $request)
{
    $request->validate([
        'firstName' => 'required',
        'middleName' => 'required',
        'lastName' => 'required',
        'suffix' => 'sometimes',
        'gender' => 'required',
        'age' => 'required',
        'address' => 'required',
        'documenttype' => 'required',
        'email' => 'required',
        'contact' => 'required',
        'reason' => 'sometimes',
    ]);

    try {
        // Save the data to the database
        $documentRequest = new DocumentRequest($request->all());
        $documentRequest->submitted_time = now(); // Assuming you want to save the current timestamp
        $documentRequest->save();

        return response()->json(['message' => 'Document request submitted successfully.']);
    } catch (\Exception $e) {
        return response()->json(['message' => 'Error submitting document request.', 'error' => $e->getMessage()], 500);
    }
}


public function requestDocumentPending(Request $request)
{
    $user = auth()->user();
    Log::info('Authenticated User:', ['user' => $user]);

    $userData = [
        'firstName' => $user->firstname,
        'middleName' => $user->middlename,
        'lastName' => $user->lastname,
        'suffix' => $user->suffix,
        'gender' => $user->gender,
        'age' => $user->age,
        'address' => $user->address,
        'documenttype' => $request->documenttype,
        'email' => $user->email,
        'contact' => $user->contactnumber,
        'reason' => $request->reason,
    ];

    try {
        // Merge user data with request data
        $requestData = array_merge($userData, $request->all());

        // Save the data to the database
        $documentRequest = new DocumentRequest($requestData);
        $documentRequest->submitted_time = now(); // Assuming you want to save the current timestamp
        $documentRequest->save();

        return response()->json(['message' => 'Document request submitted successfully.']);
    } catch (\Exception $e) {
        return response()->json(['message' => 'Error submitting document request.', 'error' => $e->getMessage()], 500);
    }
}

//generate QR Code

public function generateQRCode(Request $request)
{
    try {
        // Log the request data
        Log::info('QR Code Generation Request:', ['request' => $request->all()]);

        // Authenticate the user
        $user = auth()->user();
        Log::info('Authenticated User:', ['user' => $user]);

        // Prepare user data
        $userData = [
            'firstName' => $user->firstname,
            'middleName' => $user->middlename,
            'lastName' => $user->lastname,
            'suffix' => $user->suffix,
            'gender' => $user->gender,
            'age' => $user->age,
            'address' => $user->address,
            'documenttype' => $request->documenttype,
            'email' => $user->email,
            'contact' => $user->contactnumber,
            'reason' => $request->reason,
        ];

        // Convert the user data array to a JSON string
        $jsonData = json_encode($userData);

        // Encode the JSON string using base64
        $base64EncodedData = base64_encode($jsonData);

        // Create QR code without a logo
        $result = Builder::create()
            ->writer(new SvgWriter())
            ->writerOptions([])
            ->data($base64EncodedData) // Use base64 encoded data directly
            ->encoding(new Encoding('UTF-8'))
            ->errorCorrectionLevel(ErrorCorrectionLevel::High)
            ->size(300)
            ->margin(10)
            ->roundBlockSizeMode(RoundBlockSizeMode::Margin)
            ->validateResult(false)
            ->build();

        // Save the SVG content to a file (e.g., public_path('images/qrcode.svg'))
        $result->saveToFile(public_path('storage/images/qrcode.svg'));

        // You can also save it as a PNG image if needed
        $result->saveToFile(public_path('storage/images/qrcode.png'));

        $token = Str::random(32);


        // Store the link creation time in the cache
        Cache::put($token . '_created_at', now(), 5); // 5 minutes expiration time

        $response = "Please click or tap on the link provided and save or screenshot your QR Code. and wait for the confirmation in your email from the system.";

        $imageUrl = asset('storage/images/qrcode.svg') . '?token=' . $token;

        // Log successful QR code generation
        Log::info('QR Code Generated Successfully:', ['user' => $user, 'image_url' => $imageUrl]);

        // Return a response (you can customize this based on your needs)
        return response()->json(['response' => $response, 'image_url' => $imageUrl, 'token' => $token]);
    } catch (\Exception $e) {
        // Log the error
        Log::error('QR Code Generation Failed:', ['error' => $e->getMessage(), 'trace' => $e->getTrace()]);

        // Return an error response
        return response()->json(['error' => 'Failed to generate QR code.'], 500);
    }
}


// check link of qr code generated if is expired or not
public function checkLinkExpiration(Request $request)
{
    $token = $request->get('token');

    // Check if the link creation time is in the cache
    if (Cache::has($token . '_created_at')) {
        // Get the link creation time from the cache
        $createdAt = Cache::get($token . '_created_at');

        // Check if the link has expired (5 minutes in this example)
        if (now()->diffInMinutes($createdAt) > 5) {
            // Return a response indicating that the link has expired
            return response()->json(['error' => 'The QR code link has expired.'], 400);
        }

        // Link is still valid; continue processing
        // ...

        // Optionally, you can remove the link creation time from the cache
        Cache::forget($token . '_created_at');
    } else {
        // Return a response indicating that the link is not valid
        return response()->json(['error' => 'Invalid QR code link.'], 400);
    }
}

// for QR Code Scanner

public function verifyDocumentRequest(Request $request)
{
    try {
        // Log the decrypted JSON data
        Log::info('Decrypted JSON Data:', ['data' => $request->data]);

        // Check if 'data' key exists and is not null
        if (!$request->has('data') || $request->data === null) {
            return response()->json(['error' => 'Invalid or missing data key in the request'], 400);
        }

        // Use the decoded data directly
        $decodedData = $request->data;
        
        if ($decodedData['email'] === auth()->user()->email) {
    return response()->json(['error' => 'Scanning your own QR code is not allowed.'], 400);
}

        // Search for the document request in the database
        $documentRequest = DocumentRequest::where([
            'firstName' => $decodedData['firstName'],
            'middleName' => $decodedData['middleName'],
            'lastName' => $decodedData['lastName'],
            'gender' => $decodedData['gender'],
            'age' => $decodedData['age'],
            'address' => $decodedData['address'],
            'documenttype' => $decodedData['documenttype'],
            'email' => $decodedData['email'],
            'contact' => $decodedData['contact'],
            'reason' => $decodedData['reason'],
            'status' => 'approved'
        ])->first();

        if ($documentRequest) {
            // Document request found, you can perform further actions here
            Log::info('Document Request Verified:', ['document_request' => $documentRequest]);

            // Check the status and return the appropriate action
            $action = ($documentRequest->status === 'approved') ? 'show_verification' : 'other_action';
         //   $action = ($documentRequest->status === 'pending') ? 'show_notif_pending' : 'other_action';

            return response()->json(['message' => 'Document request verified successfully', 'action' => $action]);
        } else {
            // Document request not found
            Log::info('Document Request not verified, is it pending, claimed or rejected?');

            return response()->json(['error' => 'Document request not found'], 404);
        }
    } catch (\Exception $e) {
        // Log the error
        Log::error('Error verifying document request:', ['error' => $e->getMessage(), 'trace' => $e->getTrace()]);

        // Return an error response
        return response()->json(['error' => 'Failed to verify document request.'], 500);
    }
}

    /**
     * Display the specified resource.
     */
    public function show(DocumentRequest $documentRequest,$id)
    {
      //  $this->authorize('view', $documentRequest);
        $documentRequest = DocumentRequest::findOrFail($id);
        return new DocumentRequestResource($documentRequest);
    }
    /**
     * Show the form for editing the specified resource.
     */
    public function edit(DocumentRequest $documentRequest)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateDocumentRequestRequest $request, DocumentRequest $documentRequest)
    {
     //   $this->authorize('update', $documentRequest); // Authorize based on the specific $census record
        $validated = $request->validated();
    
        $documentRequest->update($validated);
        return new DocumentRequestResource($documentRequest);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id)
{
    try {
        // Find the document request by its ID
        $documentRequest = DocumentRequest::find($id);

        // Check if the document request exists
        if (!$documentRequest) {
            return response()->json(['message' => 'Document request not found.'], 404);
        }

        // Delete the row from the database
        $documentRequest->delete();

        return response()->json(['message' => 'Document request deleted successfully.']);
    } catch (\Exception $e) {
        // Handle the exception and return an error response
        return response()->json(['error' => 'An error occurred while deleting the document request.'], 500);
    }
}

    
    

public function serveImage($filename)
{
    $path = storage_path('app/public/uploads/' . $filename);

    if (file_exists($path)) {
        // Return the image as a response
        return response()->file($path);
    }

    // Handle the case where the image file doesn't exist
    return response()->json(['error' => 'Image not found'], 404);
}


public function searchNamePending(Request $request)
{
    $this->validate($request, [
        'full_name' => 'required|string',
    ]);

    $fullName = $request->input('full_name');
    Log::info('Full Name: ' . $fullName);

    // Check if the comma delimiter exists in the $fullName string
    if (strpos($fullName, ',') !== false) {
        list($firstName, $lastName) = explode(',', $fullName);

        // Search for users with matching first and last names and status 'pending'
        $users = DocumentRequest::where([
            'firstName' => $firstName,
            'lastName' => $lastName,
            'status' => 'pending',
        ])->get();

        if ($users->isNotEmpty()) {
            // If user(s) found in the census with 'pending' status, return the user information
            return response()->json(['users' => $users]);
        } else {
            return response()->json(['message' => "User not found or not in 'pending' status"], 404);
        }
    } else {
        return response()->json(['message' => "Invalid full name format"], 400);
    }
}



public function searchNameReport(Request $request)
{
    $this->validate($request, [
        'full_name' => 'required|string',
    ]);

    $fullName = $request->input('full_name');
    Log::info('Full Name: ' . $fullName);

    // Check if the comma delimiter exists in the $fullName string
    if (strpos($fullName, ',') !== false) {
        list($firstName, $lastName) = explode(',', $fullName);

        // Search for users with matching first and last names and status either 'rejected' or 'claimed'
        $users = DocumentRequest::where([
            'firstName' => $firstName,
            'lastName' => $lastName,
        ])->whereIn('status', ['rejected', 'claimed'])->get();

        if ($users->isNotEmpty()) {
            // If user(s) found in the census with 'rejected' or 'claimed' status, return the user information
            return response()->json(['users' => $users]);
        } else {
            return response()->json(['message' => "User not found or not in 'rejected' or 'claimed' status"], 404);
        }
    } else {
        return response()->json(['message' => "Invalid full name format"], 400);
    }
}


public function claim(Request $request, $id)
{
    $documentRequest = DocumentRequest::findOrFail($id);
//    $this->authorize('update', $documentRequest);

    $documentRequest->update([
        'status' => 'claimed',
        //'claim_date' => $claimDateFromRequest, // Update claim_date from the request
    ]);
}


public function approve(Request $request, $id)
{
    $documentRequest = DocumentRequest::findOrFail($id);
    $claimDateFromRequest = $request->input('claim_date');
    $to = $documentRequest->email;

    if (!empty($to)) {
        $subject = 'Document Request Approved';

        // Generate HTML content based on documenttype
        $documentType = $documentRequest->documenttype;
        $imagePath = '';

        if ($documentType === 'Barangay ID') {
            $imagePath = 'storage/images/barangay_id_sample.jpg'; // Assuming the image is in the public/images directory
        } elseif ($documentType === 'Barangay Clearance') {
            $imagePath = 'storage/images/brgy_clearance_sample.PNG';
        } elseif ($documentType === 'Barangay Certificate') {
            $imagePath = 'storage/images/brgy_certificate_sample.PNG';
        } elseif ($documentType === 'Certificate of Indigency') {
            $imagePath = 'storage/images/cert_of_indigency_sample.PNG';
        }

        $imageUrl = url($imagePath);

        // Build the HTML content with inline CSS styles and embedded image
$message = "
    <html>
        <head>
            <style>
                p {
                    font-size: 16px;
                    line-height: 1.5;
                    color: #333;
                }
                img {
                    max-width: 100%;
                    height: auto;
                    border: 0;
                    margin: 10px 0;
                }
            </style>
        </head>
        <body>
            <p>Hello! {$documentRequest->firstName} {$documentRequest->lastName},</p>
            <p>Your document request of {$documentRequest->documenttype} has been approved and is now currently processed. You will claim your document on {$claimDateFromRequest}.</p>
";

if ($documentRequest->documenttype === 'Barangay ID') {
    $message .= "<img src='{$imageUrl}' alt='Barangay ID Sample'>";
} elseif ($documentRequest->documenttype === 'Barangay Clearance') {
    $message .= "<img src='{$imageUrl}' alt='Barangay Clearance Sample'>";
} elseif ($documentRequest->documenttype === 'Barangay Certificate') {
    $message .= "<img src='{$imageUrl}' alt='Barangay Certificate Sample'>";
} elseif ($documentRequest->documenttype === 'Certificate of Indigency') {
    $message .= "<img src='{$imageUrl}' alt='Certificate of Indigency Sample'>";
}

$message .= "
            <p>Thank you for using our service.</p>
        </body>
    </html>
";


        $headers = [
            'From' => 'ecensusonlinerequest.online',
            'Content-Type' => 'text/html; charset=UTF-8',
        ];

        // Use PHP's mail function to send the email with improved HTML content
        if (mail($to, $subject, $message, $headers)) {
            // Update the status to 'approved' and set the claim_date
            $documentRequest->update([
                'status' => 'approved',
                'claim_date' => $claimDateFromRequest,
            ]);
          //   $documentRequest->notify(new DocumentRequestApproved($documentRequest, $claimDateFromRequest));

            Log::info('claim_date after update: ' . $documentRequest->claim_date);

            return response()->json(['message' => 'Document request approved successfully. Email sent.']);
        } else {
            // Handle the case where the email couldn't be sent
            return response()->json(['message' => 'Document request approved successfully, but email sending failed.'], 500);
        }
    } else {
        // Handle the case where the email is empty in the document_requests table
        return response()->json(['message' => 'Document request approved successfully, but recipient email is missing.']);
    }
}




public function reject(Request $request, $id)
{
    $documentRequest = DocumentRequest::findOrFail($id);
  //  $this->authorize('update', $documentRequest); 
    // Get the receiver's email from the document_requests table
    $to = $documentRequest->email;

    if (!empty($to)) {
        $subject = 'Document Request Rejected';
        $message = 'We are sorry, '. $documentRequest->firstname .' '. $documentRequest->lastname . ', Based from your provided reason: '. $documentRequest->reason .', your document request has been rejected.';
        $headers = 'From: ecensusonlinerequest.online';

        // Use PHP's mail function to send the email
        if (mail($to, $subject, $message, $headers)) {
            // Update the status to 'rejected'
            $documentRequest->update(['status' => 'rejected']);
           //$documentRequest->notify(new DocumentRequestRejected($documentRequest));

            return response()->json(['message' => 'Document request rejected successfully. Email sent.']);
        } else {
            // Handle the case where the email couldn't be sent
            return response()->json(['message' => 'Document request rejected successfully, but email sending failed.'], 500);
        }
    } else {
        // Handle the case where the email is empty in the document_requests table
        return response()->json(['message' => 'Document request rejected successfully, but recipient email is missing.']);
    }
}

}

