<?php

namespace Database\Factories;

use App\Models\Role;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\User>
 */
class UserFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {

        $suffixes = [
            'Jr.', // Default status
            'Sr.',
            'II',
            'III',
            'IV',
            '',
        ];

        $genders = [
            'Male',
            'Female',
        ];
        return [
            'role_id' => Role::where('name', 'Staff')->firstOrFail()->id,
            'firstname' => $this->faker->firstName,
            'middlename' => $this->faker->firstName,
            'lastname' => $this->faker->lastName,
            'suffix' => $this->faker->randomElement($suffixes),
            'gender' => $this->faker->randomElement($genders),
            'age' => $this->faker->numberBetween($min = 10, $max = 60),
            'address' => $this->faker->address,
            'birthDate' => $this->faker->date,
            'contactnumber' => $this->faker->phoneNumber,
            'username' => $this->faker->userName,
            'email' => $this->faker->email,
            'password' => $this->faker->password,
            'image' => $this->faker->imageUrl($width = 640,$height = 400),
        ];
    }

    public function unverified()
    {
        return $this->state(fn (array $attributes) => [
            'email_verified_at' => null,
        ]);
    }
}
