<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use App\Rules\Base64Image;
class UpdateDocumentRequestRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array|string>
     */
    public function rules(): array
    {
        $method = $this->method();
        if ($method == 'PUT') {  return [
            'firstName' => ['required'],
            'middleName' => ['required'],
            'lastName' => ['required'],
            'suffix'=> ['sometimes'],
            'gender'=> ['required'],
            'age' => ['required'],
            'address' => ['required'],
            'documenttype' => ['required'],
        //    'required' => ['required'],
            'email' => ['required'],
            'contact' => ['required'],
        //    'valid_id' => ['required', , new Base64Image],
            'status' => ['required'],
            'reason' => ['sometimes'],
            'submitted_time' => ['required'],
            'claim_date' => ['sometimes'],
        ];} else {
            return [
                'firstName' => ['required'],
                'middleName' => ['sometimes'],
                'lastName' => ['required'],
                'suffix'=> ['sometimes'],
                'gender'=> ['required'],
                'age' => ['required'],
                'address' => ['required'],
                'documenttype' => ['required'],
        //        'required' => ['required'],
                'email' => ['required'],
                'contact' => ['required'],
        //        'valid_id' => ['required', , new Base64Image],
                'status' => ['required'],
                'reason' => ['sometimes'],
                'submitted_time' => ['required'],
                'claim_date' => ['sometimes'],
            ];
            }
    }
}
