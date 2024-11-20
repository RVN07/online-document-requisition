<?php

namespace App\Filters;

use App\filters\ApiFilter;
use Illuminate\Http\Request;

class UserFilter extends ApiFilter {
    protected $safeParams = [
        'role_id' => ['eq'],
        'firstname' => ['eq'],
        'middlename' => ['eq'],
        'lastname' => ['eq'],
        'suffix'=> ['eq'],
        'gender'=> ['eq'],
        'address' => ['eq'],
        'age' => ['eq', 'gt', 'gte', 'lt', 'lte'],
        'birthDate' => ['eq', 'gt', 'gte', 'lt', 'lte'],
        'contactnumber' => ['eq'],
        'email' => ['eq'],
        'username' => ['eq'],
        'password' => ['eq'],
    ];

    protected $columnMap = [
        
    ];

    protected $operatorMap = [
        'eq' => '=',
        'lt' => '<',
        'lte' => '<=',
        'gt' => '>',
        'gte' => '>='
    ];
}