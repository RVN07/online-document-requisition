<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Role extends Model
{
    use HasFactory;

    protected $fillable = ['name'];
    
    public $timestamps = true;

    public function users()
    {
        return $this->hasMany(User::class, 'role_id');
    }

    public function census(){
        return $this->hasMany(Census::class, 'role_id');
    }
}
