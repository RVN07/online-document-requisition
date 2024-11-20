<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'role_id' => $this->role_id,
            'firstname' => $this->firstname,
            'middlename' => $this->middlename,
            'lastname' => $this->lastname,
            'suffix'=> $this->suffix,
            'gender'=> $this->gender,
            'address' => $this->address,
            'age' => $this->age,
            'birthDate' => $this->birthDate,
            'contactnumber' => $this->contactnumber,
            'username' => $this->username,
            'email' => $this->email,
            'password' => $this->password,
        ];
    }
}
