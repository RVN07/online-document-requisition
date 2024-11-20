<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use App\Rules\Base64Image;

class StoreUserRequest extends FormRequest
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
            'role_id' => ['required', 'exists:roles,id'],
            'firstname' => ['required'],
            'middlename' => ['sometimes'],
            'lastname' => ['required'],
            'suffix' => ['sometimes'],
            'gender'=> ['required'],
            'age' => ['required'],
            'address' => ['required'],
            'birthDate' => ['required', 'date'],
            'contactnumber' => ['required'],
            'username' => ['required'],
            'email' => ['required', 'unique:users,email', 'email'],
            'password' => ['required'],
            'image' => ['sometimes', new Base64Image],
        ];
    }
}
