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
        Schema::create('document_requests', function (Blueprint $table) {
            $table->id();
            $table->string('firstName')->nullable();
            $table->string('middleName')->nullable();
            $table->string('lastName')->nullable();
            $table->string('suffix')->nullable();
            $table->string('gender');
            $table->unsignedInteger('age')->nullable();
            $table->string('address');
            $table->string('documenttype');
        //    $table->boolean('required');
            $table->string('email')->nullable();
            $table->string('contact')->nullable();
        //    $table->binary('valid_id');
            $table->string('status')->default('pending');
            $table->string('reason')->nullable();
            $table->string('submitted_time');
            $table->string('claim_date')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('document_requests');
    }
};
