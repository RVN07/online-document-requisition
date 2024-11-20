<?php

namespace App\Filters\Api;

use App\Filters\ApiFilter;
use Illuminate\Http\Request;

class RoleFilter extends ApiFilter{
    protected $safeParams = [
        'id' => ['eq'],
        'name' => ['eq']
    ];

    protected $columnMap = [];

    protected $operatorMap = [
        'eq' => '=',
        'lt' => '<',
        'lte' => '<=',
        'gt' => '>',
        'gte' => '>='
    ];
}