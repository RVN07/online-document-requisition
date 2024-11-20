<?php

namespace App\filters;

use App\filters\ApiFilter;
use Illuminate\Http\Request;

class DocumentRequestFilter extends ApiFilter{
    protected $safeParams = [
            'firstName' => ['eq'],
            'middleName' => ['eq'],
            'lastName' => ['eq'],
            'suffix'=> ['eq'],
        'gender'=> ['eq'],
         'age' => ['eq', 'lt', 'lte', 'gt', 'gte'],
         'address' => ['eq'],
            'documenttype'=> ['eq'],
      //      'required' => ['eq'],
            'email' => ['eq'],
           
            'contact' => ['eq'],
       //     'valid_id' => ['eq'],
            'status' => ['eq'],
            'reason' => ['eq'],
            'submitted_time' => ['eq', 'lt', 'lte', 'gt', 'gte'],
            'claim_date' => ['eq', 'lt', 'lte', 'gt', 'gte'],
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