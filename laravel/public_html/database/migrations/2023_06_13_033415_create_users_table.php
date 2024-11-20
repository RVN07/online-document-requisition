<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('role_id');
            $table->string('firstname');
            $table->string('middlename')->nullable();
            $table->string('lastname');
            $table->string('suffix')->nullable();
            $table->string('gender');
            $table->unsignedInteger('age');
            $table->string('address');
            $table->date('birthDate');
            $table->string('contactnumber');
            $table->string('username');
            $table->string('email')->unique();
            $table->string('password');
            $table->binary('image')->nullable();
            $table->string('status')->default('Pending');
            $table->string('verification_code', 8)->nullable();
            $table->timestamp('email_verified_at')->nullable();
            $table->timestamp('last_code_request')->nullable();
            $table->timestamps();
           
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
