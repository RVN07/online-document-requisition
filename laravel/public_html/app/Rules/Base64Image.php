<?php

namespace App\Rules;

use Closure;
use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Support\Facades\Validator;

class Base64Image implements ValidationRule
{
    /**
     * Run the validation rule.
     *
     * @param  \Closure(string): \Illuminate\Translation\PotentiallyTranslatedString  $fail
     */
    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        //
    }
    public function passes($attribute, $value)
    {
        // Ensure that the value is a valid base64 string
        if (!preg_match('/^[a-zA-Z0-9/+]*={0,2}$/', $value)) {
            return false;
        }

        // Attempt to decode the base64 string
        $decodedValue = base64_decode($value, true);

        // Check if decoding was successful and the result is not empty
        return !empty($decodedValue);
    }

    public function message()
    {
        return 'The :attribute must be a valid base64-encoded string.';
    }
}

