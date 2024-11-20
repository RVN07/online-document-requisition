<?php

namespace Database\Factories;

use App\Models\Role;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\DocumentRequest>
 */
class DocumentRequestFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $documents = [
            'Barangay Clearance',
            'Residence Certificate',
            'Certificate of Indigency',
            'Barangay ID',
            // Add more documents if needed
        ];
        
        $statuses = [
            'pending', // Default status
            'approved',
            'rejected',
        ];
        $reasons =['Required for Application',
        'For Requirements in other fields'];

        $suffixes = [
            'Jr.', // Default status
            'Sr.',
            'II',
            'III',
            'IV',
        ];

        return [
            'firstName' => $this->faker->firstName,
            'middleName' => $this->faker->firstName,
            'lastName' => $this->faker->lastName,
            'suffix' => $this->faker->randomElement($suffixes),
            'gender' => $this->faker->randomElement(['Male', 'Female']),
            'age' => $this->faker->age,
            'documenttype' => $this->faker->randomElement($documents),
       //     'required' => $this->faker->boolean,
            'email' => $this->faker->email,
            'contact' => $this->faker->phoneNumber,
       //     'valid_id' => $this->faker->imageUrl($width = 640, $height = 400),
            'status' => $this->faker->randomElement($statuses),// Add the status column
            'reason' => $this->faker->randomElement($reasons),
            'submitted_time' => $this->faker->dateTime,
            'claim_date' => $this->faker->date,
        ];
    }
}
