<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateUserRequest extends FormRequest
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
            'role_id' => ['sometimes'],
            'firstname' => ['sometimes'],
            'middlename' => ['sometimes'],
            'lastname' => ['required'],
            'suffix'=> ['sometimes'],
            'gender'=> ['required'],
            'age' => ['sometimes'],
            'address' => ['sometimes'],
            'birthDate' => ['sometimes'],
            'contactnumber' => ['sometimes'],
            'username' => ['sometimes'],
            'email' => ['required'],
            'password' => ['sometimes'],
            'image' => ['sometimes'],
        ];} else {
            return [
                'role_id' => ['sometimes', 'exists:roles,id'],
                'firstname' => ['sometimes'],
                'middlename' => ['sometimes'],
                'lastname' => ['sometimes' ],
                'suffix'=> ['sometimes'],
                'gender'=> ['sometimes'],
                'age' => ['sometimes'],
                'address' => ['sometimes'],
                'birthDate' => ['sometimes'],
                'contactnumber' => ['sometimes'],
                'username' => ['sometimes'],
                'email' => ['sometimes'],
                'password' => ['sometimes'],
                'image' => ['sometimes'],
            ];
            }
    }
}
