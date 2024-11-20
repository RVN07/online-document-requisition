<?php

namespace App\Http\Controllers\Api\V1;

use App\Mail\VerificationEmail;
use App\Models\User;

use App\filters\UserFilter;
use App\Http\Resources\V1\UserCollection;
use App\Http\Resources\V1\UserResource;
use Dotenv\Exception\ValidationException;
use Illuminate\Routing\Controller;
use App\Http\Requests\StoreUserRequest;
use App\Http\Requests\UpdateUserRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
class UserController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
       $filter = new UserFilter();
       $filterItem = $filter->transform($request);

       if (count($filterItem) == 0) {
            return new UserCollection(User::get());
       } else {
            return new UserCollection(User::where($filterItem)->get());
       }
    }

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
    public function store(StoreUserRequest $request)
    {

        $data = $request->all();
        $data['password'] = Hash::make($request->password);
    
        $user = User::create($data);
    
        return new UserResource($user);
      //  $data = $request->all();
    //$data['password'] = Hash::make($request->password);

    //$user = User::create($data);

      //  return new UserResource(User::create($request->all()));
    }



    /**
     * Display the specified resource.
     */
    public function show($email)
{
    $user = User::where('email', $email)->first();

    if (!$user) {
        return response()->json(['message' => 'User not found'], 404);
    }

    return new UserResource($user);
}


    /**
     * Show the form for editing the specified resource.
     */
    public function edit(User $user)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateUserRequest $request, User $user)
    {
        $data = $request->all();

        // Check if a new password is provided in the request
        if ($request->has('password')) {
            $data['password'] = Hash::make($request->password);
        }
    
        $user->update($data);
    }
    

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Request $request, User $user)
    {
        if (!$user) {
            return response()->json(['message' => 'Resident not found'], 404);
        }

        $user->delete();

        return response()->json(['message' => 'Resident deleted successfully']);
    }
}
