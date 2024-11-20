<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Notifications\Notifiable;
use Illuminate\Database\Eloquent\Model;

class DocumentRequest extends Model
{
    use HasFactory;
    use Notifiable;

    protected $fillable = [
        'id',
        'firstName',
        'middleName',
        'lastName',
        'suffix',
        'gender',
        'age',
        'address',
        'documenttype',
   //     'required',
        'email',
        'contact',
    //    'valid_id',
        'status',
        'reason',
        'submitted_time',
        'claim_date',
    ];

    public function getRequiredAttribute($value)
    {
        return $value ? 'Yes' : 'No';
    }

    protected $casts = [
        'valid_id' => 'array',
    ];

}
