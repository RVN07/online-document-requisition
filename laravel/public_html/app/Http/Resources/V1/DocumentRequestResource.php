<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DocumentRequestResource extends JsonResource
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
            'firstName' => $this->firstName,
            'middleName' => $this->middleName,
            'lastName' => $this->lastName,
            'suffix'=> $this->suffix,
            'gender'=> $this->gender,
            'age' => $this->age,
            'address' => $this->address,
            'documenttype' => $this->documenttype,
            
        //    'required' => $this->required,
            'email' => $this->email,
            'contact' => $this->contact,
        //    'valid_id' => $this->valid_id,
            'status' => $this->status,
            'reason' => $this->reason,
            'submitted_time' => $this->submitted_time,
            'claim_date' => $this->claim_date,
        ];
    }
}
