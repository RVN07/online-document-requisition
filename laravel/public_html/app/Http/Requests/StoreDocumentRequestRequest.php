<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use App\Rules\Base64Image;
class StoreDocumentRequestRequest extends FormRequest
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
        return [
            'firstName' => ['required'],
            'middleName' => ['sometimes'],
            'lastName' => ['required'],
            'suffix'=> ['sometimes'],
            'gender'=> ['required'],
            'age' => ['required'],
            'address' => ['required'],
            'documenttype' => ['required'],
       //     'required' => ['required'],
            'email' => ['required'],
            'contact' => ['required'],
       //     'valid_id' => ['required', 'string', new Base64Image],
            'status' => ['required'],
            'reason' => ['sometimes'],
            'submitted_time' => ['required'],
            'claim_date' => ['sometimes'],
        ];
    }
    protected function prepareForValidation() {
        $this->merge([
            'documenttype' => $this->documenttype
        ]);
    }
}
