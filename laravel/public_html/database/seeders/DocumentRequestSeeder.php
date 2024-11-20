<?php

namespace Database\Seeders;

use App\Models\DocumentRequest;
use Illuminate\Database\Seeder;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;

class DocumentRequestSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DocumentRequest::factory()
            ->count(0)
            ->create();
        DocumentRequest::factory()
            ->count(0)
            ->create();
    }
}
