<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasFactory;
    use HasApiTokens;
    use Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'role_id',
        'firstname',
        'middlename',
        'lastname',
        'suffix',
        'gender',
        'age',
        'address',
        'birthDate',
        'contactnumber',
        'username',
        'email',
        'password',
        'image'
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $searchableFields = ['*'];
    
    
    public $timestamps = true;

   // protected $hidden = [
    //    'password',
   //     'remember_token',
   // ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>p
     */
    protected $casts = [
        'birthDate' => 'date',
    ];
    

    public function roles()
    {
        return $this->belongsTo(Role::class, 'role_id');

    }

    public function isAdmin()
    {
        return $this->roles->name === 'Admin';
    }

    public function isStaff()
    {
        return $this->roles->name === 'Staff';
    }

    public function isResident()
    {
        return $this->roles->name === 'Resident';
    }
}